---
layout: post
author: Carson Evans
tags: flask password hash hashing bcrypt
---

There is a plethora of guides out there about how to securely store passwords, but there are not as many of those guides that apply to Flask specifically.  I spend quite a bit of my free time on the Pallets discord helping people out with their Flask questions, and often enough we have people storing passwords as plain text.  So I thought I would write about the different options one has for correctly storing passwords in a Flask app.

## How To Store Passwords

Quite simply put, the only way to securely store a password is to not store it at all. Instead what we do is put the password through a hashing algorithm, and store the hash output.  There are so many in-depth articles about how hashing algorithms work, but in this post I'm just going to get straight to the point and show examples on how to hash/verify passwords.

There are three main options for password hashing in a Flask app.  First is werkzeug's built in password hashing functions, which is the easiest since Flask is built on werkzeug so you don't have to install anything extra.  Another is bcrypt which is one of the most common password hash algorithms and has implementations in just about every language.  Last you could roll your own, but seriously, when it comes to cryptographic functions, please don't roll your own.  There are probably other library/options out there, but in this post I am going to focus on werkzeug's built in password hashing functions, and bcrypt.

## Werkzeug Functions

Werkzeug contains two password related functions in the `werkzeug.security` module. First is `generate_password_hash` which is used to create a password hash, and second is `check_password_hash` which is used to validate a password.  It is used as follows.

```python
from werkzeug.security import generate_password_hash, check_password_hash

hashed_password = generate_password_hash('foobar')

print(check_password_hash(hashed_password, 'foobar')) # prints True
print(check_password_hash(hashed_password, 'foobarbaz')) # prints False
```

[The werkzeug docs](https://werkzeug.palletsprojects.com/en/1.0.x/utils/#module-werkzeug.security) go in to more detail about extra parameters you can pass in to customize how the password is hashed, and I encourage readers look further in to that. Here is an example of how one might use these functions in signup and signin view functions of a Flask app.

```python
@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        if username and password:
            # Hash the password when inserting a new user
            insert_user(username, generate_password_hash(password))
            return redirect(url_for('signin'))
    return render_template('signup.html')

@app.route('/signin', methods=['GET', 'POST'])
def signin():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        user = get_user(username)
        # Check that a user matching the username exists, and that the password matches
        if user is not None and check_password_hash(user.password, password):
            session['user_id'] = user.id
            return redirect(url_for('dashboard'))
    return render_template('signin.html')
```

The `insert_user` and `get_user` are just made up functions.  In your app you would have to replace them with how you insert and find user records.

## Bcrypt

In order to use bcrypt, you'll first need to install its package.

```bash
pip install bcrypt
# or
pipenv install bcrypt
```

Once it is installed, it is very similar to the werkzeug functions to use.  You use the `hashpw`, `checkpw` functions, and there is also a `gensalt` function.

```python
from bcrypt import hashpw, checkpw, gensalt

hashed_password = hashpw('foobar'.encode('utf-8'), gensalt())

print(checkpw('foobar'.encode('utf-8'), hashed_password)) # prints True
print(checkpw('foobarbaz'.encode('utf-8'), hashed_password)) # prints False
```

There are three usage differences you will need to pay attention with bcrypt.  First, you must pass in a salt, whereas werkzeug does that automatically. Luckily bcrypt has the `gensalt` function to make that easy. Second, the order of parameters for checking if a password is valid is opposite to the werkzeug functions. Last, you must encode passwords being passed in for hashing or checking. Just like with the werkzeug functions, you can read more about the optional parameters the bcrypt functions accept [in their examples](https://github.com/pyca/bcrypt/#usage). Here are the same Flask view function examples, but using the bcrypt functions.

```python
@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        if username and password:
            # Hash the password when inserting a new user
            insert_user(username, hashpw(password.encode('utf-8'), gensalt()))
            return redirect(url_for('signin'))
    return render_template('signup.html')

@app.route('/signin', methods=['GET', 'POST'])
def signin():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        user = get_user(username)
        # Check that a user matching the username exists, and that the password matches
        if user is not None and checkpw(password.encode('utf-8'), user['password']):
            session['user_id'] = user['id']
            return redirect(url_for('dashboard'))
    return render_template('signin.html')
```

As mentioned in the werkzeug example, the `insert_user` and `get_user` are just made up functions.  In your app you would have to replace them with how you insert and find user records.

## Which One Should You Use?

If you are building a brand new app, with a brand new database, I would say just use the werkzeug functions.  Why introduce a dependency if you don't need to?  But if you are rewriting an app or something, and have an existing database that already has bcrypt hashed passwords, then you'll want to go with bcrypt, unless you are prepared to force every single user to reset their password.  This is the nice thing about bcrypt having implementations in just about every single language.  You can rewrite your app in a different language, and keep using existing hashed passwords.


I have full working Flask examples using [werkzeug password functions](https://github.com/carc1n0gen/tutorial-apps/tree/master/flask-password-hashing-werkzeug) and [bcrypt](https://github.com/carc1n0gen/tutorial-apps/tree/master/flask-password-hashing-bcrypt) for password hashing if you wish to reference those.

