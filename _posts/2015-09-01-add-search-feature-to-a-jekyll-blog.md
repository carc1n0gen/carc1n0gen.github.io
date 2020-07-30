---
layout: post
author: Carson Evans
---

In this post we will be creating a dynamic(ish) JSON file that we read through an AJAX call to implement searching on a Jekyll blog.

{% raw %}

## What is Jekyll?

[Jekyll](https://github.com/jekyll/jekyll) is a static site generator.  This 
means that you build a website using their templating language and other 
conventions, and then Jekyll will compile the site in to static html documents. It 
is sort of like caching output from PHP using the ob\_start, ob\_stop, etc... functions.

## Why Use Javascript and Ajax?

Jekyll websites are static files.  There is no backend scripting language like
PHP or anything.  This means that in Jekyll, you can't make a search form that
submits to some backend script with logic to capture form input values.

Instead, we use Jekyll templating to generate a JSON file that contains the 
metadata information about the blog posts.  Then we use AJAX to get the 
contents of this JSON file, and use the text of a search box to filter down
to relevant posts.

## The Code

There are three parts to the code.  First we use liquid templating to generate a 
JSON file containing metadata about all the posts, second we need to write some 
JavaScript that will get that metadata through AJAX, and last some html.

### The JSON

Create a `search.json` file at the root with the following content:

```python
---
---
[{% for post in site.posts %}
    {
        "title":"{{post.title}}",
        "url":"{{post.url}}"
    }{% if forloop.last == false %},{% endif %}
{% endfor %}]
```

Sample generated JSON file:

```json
[
    {
        "title":"Jekyll Is Cool",
        "url":"/2015/08/24/jekyll-is-cool"
    },
    {
        "title":"PHP Is Also Cool",
        "url":"/2015/08/15/php-is-also-cool"
    },
    {
        "title":"Static Websites Are fast",
        "url":"/2015/08/01/static-websites-are-fast"
    }
]
```

### The JavaScript

I have commented the key parts of this code.  In summary, we create an AJAX request,
parse the JSON response to an array of objects, then using the search box value we
filter to matching posts.

```js
(function() {
    var request = new XMLHttpRequest();
    var searchBox = document.getElementById("search-box");
    var resultBox = document.getElementById("search-results");
    var posts;
    var results;
    var html = "";

    request.onreadystatechange = function(e) {

        // the request is done and successful.
        if (request.readyState === 4 && request.status === 200) {

            // parse the json response in to an array of objects.
            posts = JSON.parse(request.responseText);

            // filter the posts to those who's title contains text from the search box.
            results = posts.filter(function(post) {
                if (post.title.toLowerCase().indexOf(searchBox.value.trim().toLowerCase()) > -1) {
                    return true;
                }
            });

            // if there are results, show a list item and link for each result.
            if (results.length > 0 && searchBox.value.trim() != "") {
                html += "<ul>";
                for (var i = 0; i < results.length; i++) {
                    html += "<li><a href=\"" + results[i].url + "\">" + results[i].title + "</a></li>";
                }
                html += "</ul>";

                resultBox.innerHTML = html;
            }
        }
    };

    // detect input on the search box.
    searchBox.onkeyup = function(e) {
        resultBox.innerHTML = "";
        html = "";
        results = [];
        request.open("GET", "/search.json");
        request.send();
    };
})();
```

### The HTML

```html
<label for="search-box">Search</label>
<input type="text" id="search-box" placeholder="Search for a post...">
<div id="search-results"></div>
```

## Demo

[Here](https://github.com/carc1n0gen/tutorial-apps/tree/master/jekyll-search) is full working code for a sample app that is out of the box ready to be run, to demonstrate all this put together.
{% endraw %}