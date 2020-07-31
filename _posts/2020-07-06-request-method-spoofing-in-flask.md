---
layout: post
author: Carson Evans
---

I recently found myself wanting to do method spoofing in flask.  It turned out this isn't such a simple straight forward thing to do.  So sit back while I take you down the rabbit hole that is method spoofing in flask.

## What Is Method Spoofing?

Browsers can only submit GET or POST requests.  So if you want the route in the backend to respond to DELETE requests, a common workaround is to "spoof" the method using a hidden input on a POST form.

```html
<form method="POST">
    <input type="hidden" name="_method" value="DELETE">
    <button type="submit">Submit</button>
</form>
```

Then on the backend, you would do some sort of processing of the form in a middleware or something that checks for the existence of this field, and sets the request method accordingly.  But again, this isn't such a simple task in flask.

## The Naive Solution

Originally I figured I could use a before_request hook to check if a `_method` key existed in `request.form`.

```python
from flask import request

@app.before_request
def before_request():
    method = request.form.get('_method')
        if method:
            # override the request method if there was a method spoofing form field.
            request.method = method
```

But I was quickly given a error explaining that the request object was read only.  So It was clear I was going to have to do this in a wsgi middleware, which executes before the flask app code.  This also turned out to be not so simple. This is my original naive solution.

```python
class MethodSpooferMiddleware():
  	"""
    A WSGI middleware that checks for a method spoofing form field
    and overrides the request method accordingly.
    """

    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
      	# We only want to spoof if the request method is POST
        if environ['REQUEST_METHOD'].upper() == 'POST':
            request = Request(environ)
            method = request.form.get('_method')
            if method:
              	# override the request method if there was a method spoofing form field.
                environ['REQUEST_METHOD'] = method

        return self.app(environ, start_response)
      

app = Flask(__name__)
app.wsgi_app = MethodSpooferMiddleware(app.wsgi_app)
```

This worked great at first.  This correctly made a submitted POST form invoke a route set to respond to a DELETE request in the flask app.  There is a problem that arises when you try to access form data in the flask app though.  When we did `request = Request(environ)`, we actually consumed the whole `wsgi.input` stream.  This is the raw request body data that wsgi applications parse to get the submitted data.  The problem is that this stream can only be read once. So I did a little googling, and it turned out I was not to first to go down this rabbit hole, and also hit this problem.

## A Not So Great Workaround

I found [a stackoverflow question](https://stackoverflow.com/a/17828333) from someone who had run in to the exact same problem as me.  There was a "workaround" in the accepted answer where you would consume the `wsgi.input` stream in to a BytesIO stream, and then replace `wsgi.input` with this new stream. The reason is that a BytesIO stream can seek back to the beginning when you reach the end, where as the original stream could not. So we simply call `stream.seek(0)` once we have parsed the form data, so that it can be read again.

```python
from werkzeug.formparser import parse_form_data
from werkzeug.wsgi import get_input_stream
from io import BytesIO

class MethodSpooferMiddleware():
    """Don't actually do this. The disadvantages are not worth it."""

    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        if environ['REQUEST_METHOD'].upper() == 'POST':
            environ['wsgi.input'] = stream = \
                BytesIO(get_input_stream(environ).read())
            form = parse_form_data(environ)[1]
            stream.seek(0)

            method = form.get('_method', '').upper()
            if method:
                environ['REQUEST_METHOD'] = method

        return self.app(environ, start_response)
```

This actually works, and if I hadn't of looked close enough at the snippet, I would have stopped here and called it a working solution.  But then I noticed the docstring `"""Don't actually do this. The disadvantages are not worth it."""`, so I took another look at stackoverflow answer.  The problem with this workaround is that you end up processing the form twice.  Once inside the middleware where the spoofing happens, and again in your flask app.  The workaround was just hiding the problem.  Resetting the stream back to its start is _not_ a good solution if it means processing the data twice.  What we really need to do is parse the form, and cache it somewhere the flask app can access instead of trying to parse the form twice.

## Override All The Things

So I sort of came up with a hybrid solution.  I parsed the form data, and then stored the parsed form data on the wsgi environ, where the flask app can access it later.  I then created a custom Request class that checks if this previously parsed form data exists, and uses it if it does.  This way, we don't have the problem with `wsgi.input` stream already being consumed, and we don't parse the form data twice either. I also created a file like object class that I replace the `wsgi.input` stream with after parsing the form data.  This so if you do try to read from it again, there will be an error raised that explains the data has already been consumed, and to check `wsgi._post_form` and `wsgi._post_files` for the parsed form data instead.

So first things first, here is the final WSGI middleware, and the custom Request class.  Hopefully the comments do a good job of explaining what everything does.

```python
from flask import Request


class InputProcessed():
    """A file like object that just raises an error when it is read."""

    def read(self, *args):
        raise EOFError(
            'The wsgi.input stream has already been consumed, check environ["wsgi._post_form"] \
             and environ["wsgi._post_files"] for previously processed form data.'
        )
    readline = readlines = __iter__ = read


class MethodSpooferMiddleware():
    """
    A WSGI middleware that checks for a method spoofing form field
    and overrides the request method accordingly.
    """

    def __init__(self, app, input_name='_method'):
        self.app = app
        self.input_name = input_name

    def __call__(self, environ, start_response):
        # We only want to spoof if the request method is POST
        if environ['REQUEST_METHOD'].upper() == 'POST':
            stream, form, files = parse_form_data(environ)

            # Replace the wsgi.input stream with an object that will raise an error if
            # it is read again, and explaining how to get previously processed form data.
            environ['wsgi.input'] = InputProcessed()

            # Set the processed form data on environ so it can be retrieved again inside
            # the app without having to process the form data again.
            environ['wsgi._post_form'] = form
            environ['wsgi._post_files'] = files

            method = form.get(self.input_name)
            if method:
                # Override the request method _if_ there was a method spoofing field.
                environ['REQUEST_METHOD'] = method
        return self.app(environ, start_response)

      
class CustomRequest(Request):
    """
    A custom request object that checks for previously processed form data
    instead of possibly processing form data twice.
    """

    @property
    def form(self):
        if 'wsgi._post_form' in self.environ:
            # If cached form data exists.
            return self.environ['wsgi._post_form']
        # Otherwise return the normal dict like object you would usually use.
        return super().form

    @property
    def files(self):
        if 'wsgi._post_files' in self.environ:
            # If cached files data exists.
            return self.environ['wsgi._post_files']
        # Otherwise return the normal dict like object you would usually use.
        return super().files 
```

Finally, here is a snippet showing how to use this middleware and the custom request class in a flask app.

```python
app = Flask(__name__)
app.request_class = CustomRequest
app.wsgi_app = MethodSpooferMiddleware(app.wsgi_app)
```

Now I just want to make the disclaimer that after _all_ of this work, I don't think I'm going to be doing method spoofing in my app.  This solution works very well, but it still feels like a hack. I think I'll stick to having to use POST for all operations when using html forms.  But if you are okay with all of this added code, then have at it.  Don't let me tell you what to do.  It's going to come down to ones own feelings/opinions.

Something else I should raise is that if your app also uses `request.json` to get json data from requests, you're going to want to skip doing any of the spoofing at all.  Don't consume the `wsgi.input` stream, and just leave everything as it was. I'll leave that as an exercise for the reader (Hint: will need to check if the content type is `application/json`).

If you would like to reference a complete working flask app that ties all of this together, I have one right [here on github](https://github.com/carc1n0gen/tutorial-apps/tree/master/flask-method-spoofing).
