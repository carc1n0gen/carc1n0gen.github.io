---
layout: post
author: Carson Evans
---

I've been using Flask to build web applications for over a year now. I always use WTForms for my form validation Eventually I needed to create a more interactive form that submitted with AJAX instead of a more traditional form submit, but I wanted to continue to use WTForms for validation. Here I will demonstrate how I reused my existing WTForms validation with JSON/AJAX requests.

{% raw %}

## The Traditional Way

First let's start with the _traditional_ way of doing things, where a form
submit will cause a page reload.

### The Form

We're going to define a username which must be at least 3 but no longer than
15 characters long, and an age which must be at least 14.

```python
class Form(FlaskForm):
    username = StringField('Username', [
        Length(min=3, max=15, message='Username must be at least %(min)s but no more than %(max)s characters')
    ])
    age = IntegerField('Age', [
        NumberRange(min=14, message='You must be %(min)s or older to sign up')
    ])
```

### The Endpoint

This is the pattern I like to use with wtforms and traditional submits. The
`form.validate_on_submit` function will evaluate true if the request method
was `POST` and validation passed.  If the request method was `POST` but did not
pass validation, the page will re-render, and the form instance will contain
error messages.

```python
@app.route('/traditional', methods=['GET', 'POST'])
def traditional():
    form = Form()
    if form.validate_on_submit():
        return 'WOOT WOOT!'
    return render_template('traditional.html', form=form)
```

### The Template

Now let's render the form fields, with their labels.  We're using bootstrap
styles for demonstration purposes.  We add the `is-invalid` class to the inputs
if there is an error message for the input, which automatically renders the
inputs in an error state for us.

```jinja
<form method="POST">
		{{ form.csrf_token }}
    <div class="form-group">
        {% set class = 'form-control is-invalid' if form.username.errors else 'form-control' %}
        {{ form.username.label }}
        {{ form.username(class=class) }}
        {% if form.username.errors %}
        <div class="invalid-feedback">
            {{ form.username.errors[0] }}
        </div>
        {% endif %}
    </div>
    <div class="form-group">
        {% set class = 'form-control is-invalid' if form.age.errors else 'form-control' %}
        {{ form.age.label }}
        {{ form.age(class=class) }}
        {% if form.age.errors %}
        <div class="invalid-feedback">
            {{ form.age.errors[0] }}
        </div>
        {% endif %}
    </div>
    <button class="btn btn-primary">Signup</button>
</form>
```

Submit that form empty, or with data that doesn't meet the validation we defined
and the page will "reload". The inputs will be in an error state, with their
first error message shown.

## Now With AJAX

There's nothing we need to change with the form.  We can use it completely
unchanged.  We will of course need to change the endpoint to respond with a JSON
structure containing the error messages for each input, or a success message.
We will no longer be returning the template in the case of validation errors.

### The New Endpoint

The new endpoint will work a little different.  Instead of using the
`validate_on_submit` function, we're going to check if `request.method` was
POST and call the `validate` function.  If that returns `True` then respond
with a success message.  Otherwise we use `jsonify` (imported from flask) to
serialize the form errors in to a JSON response.

```python
@app.route('/withajax', methods=['GET', 'POST'])
def withajax():
    form = Form()
    if request.method == 'POST':
        if form.validate():
            return 'WOOT WOOT!'
        return jsonify(form.errors), 400
    return render_template('withajax.html', form=form)
```

We no longer need the jinja conditions to show the inputs in an invalid state,
as we will be doing that logic in JavaScript now.

### The New Template

```jinja
<form id="form" method="POST">
    {{ form.csrf_token }}
    <div class="text-danger my-2" id="csrf_token-error">
    </div>
    
    <div class="form-group">
        {{ form.username.label }}
        {{ form.username(class='form-control') }}
        <div id="username-error" class="invalid-feedback"></div>
    </div>
    <div class="form-group">
        {{ form.age.label }}
        {{ form.age(class='form-control') }}
        <div id="age-error" class="invalid-feedback"></div>
    </div>
    <button class="btn btn-primary">Signup</button>
</form>
```

Submit that form empty, and the browser will load a new page containing
a JSON structure. Now obviously we can't leave it that way, so let's add some
JavaScript that overrides what happens on form submit.

### The New Template With JavaScript

First let's get use `getElementById` to get references to all the elements we
will need.

```html
<script>
const form = document.getElementById('form');
const successMessage = document.getElementById('success-message');
const fields = {
    csrf_token: {
        input: document.getElementById('csrf_token'),
        error: document.getElementById('csrf_token-error')  
    },
    username: {
        input: document.getElementById('username'),
        error: document.getElementById('username-error')
    },
    age: {
        input: document.getElementById('age'),
        error: document.getElementById('age-error')
    }
}
</script>
```

Now we could have simply stored references in to individual variables instead
of an object structure, but doing it like this will be make things easier.

Next let's override the form submit behaviour.

```html
<script>
...

form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const response = await fetch('/withajax', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            csrf_token: fields.csrf_token.input.value,
            username: fields.username.input.value,
            age: fields.age.input.value
        })
    });
    if (response.ok) {
        successMessage.innerHTML = await response.text();
        form.style.display = 'none';
        successMessage.style.display = 'block';
    } else {
        const errors = await response.json();
        Object.keys(errors).forEach((key) => {
           fields[key].input.classList.add('is-invalid');
           fields[key].error.innerHTML = errors[key][0];
        });
    }
});
</script>
```

So you'll see in the `else` of the `if (response.ok)` check we actually
iterate over the keys of the response object.  This is what I meant earlier
when I said storing references to our inputs in an object structure would make
out lives easier.  We can simply iterate the keys in the validation errors,
and use those keys to refer to the input that needs to be updated to be in an
error state.

One last thing we need before this will work is to create the div used to
display the success message when validation passes.

```html
<div id="success-message" style="display: none;"></div>
```

### Here's the final template

```jinja
<form id="form" method="POST">
    {{ form.csrf_token }}
    <div class="text-danger my-2" id="csrf_token-error">
    </div>
    
    <div class="form-group">
        {{ form.username.label }}
        {{ form.username(class='form-control') }}
        <div id="username-error" class="invalid-feedback"></div>
    </div>
    <div class="form-group">
        {{ form.age.label }}
        {{ form.age(class='form-control') }}
        <div id="age-error" class="invalid-feedback"></div>
    </div>
    <button class="btn btn-primary">Signup</button>
</form>
<div id="success-message" style="display: none;"></div>
```

```html
<script>
const form = document.getElementById('form');
const successMessage = document.getElementById('success-message');
const fields = {
    csrf_token: {
        input: document.getElementById('csrf_token'),
        error: document.getElementById('csrf_token-error')
    },
    username: {
        input: document.getElementById('username'),
        error: document.getElementById('username-error')
    },
    age: {
        input: document.getElementById('age'),
        error: document.getElementById('age-error')
    }
}
form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const response = await fetch('/withajax', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            csrf_token: fields.csrf_token.input.value,
            username: fields.username.input.value,
            age: fields.age.input.value
        })
    });
    if (response.ok) {
        successMessage.innerHTML = await response.text();
        form.style.display = 'none';
        successMessage.style.display = 'block';
    } else {
        const errors = await response.json();
        Object.keys(errors).forEach((key) => {
           fields[key].input.classList.add('is-invalid');
           fields[key].error.innerHTML = errors[key][0];
        });
    }
});
</script>
```

Submit that with invalid data, and the fields will change to an error state
with error messages.  Submit valid data, and you'll get a success message.

If you would like to reference a complete working flask app demonstrating all
this, I have one right [here on github](https://github.com/carc1n0gen/tutorial-apps/tree/master/flask-wtforms-ajax).
{% endraw %}
