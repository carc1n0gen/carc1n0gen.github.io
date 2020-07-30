---
layout: post
author: Carson Evans
---

This post is a little bit of a rant about trying to be too clever in code.  The kind of code that you might have written 3 months ago and now can't decipher, let alone other people.

## Intro: Welcome To Lambda Hell

A while ago I wrote a function composition helper.  A function that takes in a
list of functions to apply on an initial argument.  It was used like this:

```python
def double(num):
    return num * 2
		
def square(num):
    return num * num

composed_function = compose(double, square)
result = composed_function(2)
print(result)
# Output: 16
```

I had written that compose function only a couple of months ago.  Upon taking
a look at it again more recently, I had totally forgotten how the heck it worked,
and it took me quite a while to figure it out again.  So here's the code:

```python
from functools import reduce

def compose(*fns):
    return lambda v: reduce(lambda accum, fn: fn(accum), fns, v)
```

In order to figure it out, I actually had to pretty much reverse engineer it in
to regular functions.  So I began my quest to make the function easier to
understand.

## But Reduce Is Cool Right?

I told (lied to) myself that I can could make it more readable while not totally
giving up on the use of `functools.reduce`.  So I came up with this:

```python
def _reducer(accum, fn):
    return fn(accum)

def compose(*fns):
    def f(v):
        return reduce(_reducer, fns, v)
    return f
```

There is no doubt that this is easier to understand than "lambda hell". But
should I really stop at just more readable? Or should I make it as readable as
possible?

## Just Stop

Stop. Being. Clever.

```python
def compose(*fns):
    def f(v):
        result = v
        for fn in fns:
            result = fn(result)
        return result
    return f
```

Just look at that!  It's still pretty compact, and perfectly readable.  You
don't have to understand reduce, and you don't have to decipher the nested lambdas.
You just know exactly what is happening through simple control flow.  Or maybe
I'm totally wrong.  Maybe in another 3 months, I will no longer understand at a
glance what this function is doing.  Only time will tell.