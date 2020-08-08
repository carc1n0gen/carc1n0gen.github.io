In this post I'll be showing how you can pretty easily write your own vanilla JavaScript to replace jQuery when using bootstrap modals.

## Preparation

First things first, let's get a super basic template ready with the bootstrap styles for us to work with.

```html	
<html>
  <head>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
  </head>
  <body>
    
  </body>
</html>
```

Now let's grab one of the demos out of the bootstrap examples, and we'll use that to mess around with.  Put this in the body.

```html
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
  Launch demo modal
</button>

<!-- Modal -->
<div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Modal title</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        ...
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary">Save changes</button>
      </div>
    </div>
  </div>
</div>
```

Now if you try to load this up in a browser right now, all you will see is the button.  We need make it so when we click the button, we toggle the necessary states/classes on the modal to make it show.  First let's find out what those classes we need to toggle are. 

## Showing The Modal

We can simply open up the [demo we copied this sample code from](https://getbootstrap.com/docs/4.5/components/modal/#live-demo), open up our browser inspector tools, and watch what changes when we click the button and close the modal.

So the first thing we notice is that the root modal div changes from `class="modal fade"` to `class="modal fade show"`, and the inline style changes to `style="display: block;"`.

<video controls>
  <source src="/post-assets/bootstrap-modals-without-jquery/1.mp4" type="video/mp4">
</video>

But this isn't actually enough, turns out `class="modal-open"` is also added the body

<video controls>
  <source src="/post-assets/bootstrap-modals-without-jquery/2.mp4" type="video/mp4">
</video>

Finally the backdrop div is injected to the bottom of the body which gives the dark, partially transparent shadow behind the modal.

<video controls>
  <source src="/post-assets/bootstrap-modals-without-jquery/3.mp4" type="video/mp4">
</video>

So if we manually update our code to have these changes the modal will show.

```html
<html>
  <head>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css"
      integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
  </head>
  <body class="modal-open">
    <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
      Launch demo modal
    </button>

    <!-- Modal -->
    <div class="modal fade show" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true" style="display: block;">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="exampleModalLabel">Modal title</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            ...
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            <button type="button" class="btn btn-primary">Save changes</button>
          </div>
        </div>
      </div>
    </div>
    <div class="modal-backdrop fade show"></div>
  </body>
</html>
```

But we don't always want the modal to show.  So now let's undo those changes and start writing the JavaScript to handle the button click.

## Plain Old JavaScript DOM Manipulation

```js
function closeModal(modal) {
  //
}

function openModal(modal) {
  alert('Open the modal!');
}

// This is similar to $(document).ready(...) but in plain JavaScript
window.addEventListener('load', () => {
  // In bootstrap, buttons (or whatever element) that open a modal will have the 
  // attribute data-toggle="modal" on them.  So we want to select all elements with
  // this attribute and add a click handler to them.
  document.querySelectorAll('[data-toggle=modal]').forEach((element) => {
    element.addEventListener('click', () => {
      // In bootstrap, elements that open modals will have a `data-target` attribute
      // which points to the modal that element should open. The `dataset` is how you
      // access data attributes in JavaScript. For example if the data attribute was
      // called `data-foo` you would use `element.dataset.foo` to get the value.
      const target = element.dataset.target;
      const modal = document.querySelector(target);
      // If the target modal is found, let's open it.
      if (modal) {
       	openModal(modal);
      }
    });
  });
  
  // In bootstrap, buttons (or whatever element) that close modals have the 
  // attribute data-dismiss="modal" on them.  So want want to select all elements with 
  // this attribute and add aclick handler to them.
  document.querySelectorAll('[data-dismiss=modal]').forEach((element) => {
    element.addEventListener('click', () => {
      // Get the current open modal (the modal with the `show` class).
      const modal = document.querySelector('.modal.show');
      // If an open modal is found, close it.
      if (modal) {
        closeModal(modal);
      }
    });
  });
});
```

If we click the button, we'll now get an alert box showing.  Now let's focus on the `openModal` and `closeModal` functions to actually open and close the modal.

```js
function closeModal(modal) {
  // Get the backdrop so we can remove it from the body
  const backdrop = document.querySelector('.modal-backdrop.fade.show');
  // Remove the `modal-open` class from the body
  document.body.classList.remove('modal-open');
  // Re-hide the modal from screen readers
  modal.setAttribute('aria-hidden', 'true');
  // Remove the `show` class from the backdrop
  backdrop.classList.remove('show');
  // Remove the `show` class from the modal 
  modal.classList.remove('show');
  // Change the modal `display` style to `none`
  modal.style.display = 'none';
  // Remove the backdrop div from the body
  backdrop.remove();
}

function openModal(modal) {
  // Create the backdrop div element
  const backdrop = document.createElement('div');
  // Add the required classes to it.
  backdrop.classList.add('modal-backdrop', 'fade', 'show');
  // Add the `modal-open` class to the body
  document.body.classList.add('modal-open');
  // Append the backdrop div to the body
  document.body.appendChild(backdrop);
  // Set the `display` style of the modal to `block`
  modal.style.display = 'block';
  // This is for accessibility tools.  We want to make it no longer hidden to screen readers.
  modal.setAttribute('aria-hidden', 'false', 'show');
  // Add the show class to the modal
  modal.classList.add('show');
}
```

At this point the modal will show and hide.  But we don't have the smooth animations/transitions.  It just instantly shows and hides.  This is because we need to change some of the classes/states asynchronously or outside of the regular DOM thread in order for the transitions to be able to take effect.  We can use the `setTimeout` function in order to have this effect.

```js
function closeModal(modal) {
  const backdrop = document.querySelector('.modal-backdrop.fade.show');
  modal.setAttribute('aria-hidden', 'true');
  backdrop.classList.remove('show');
  // We want to remove the show class from the modal outside of the regular DOM thread so that
  // transitions can take effect
  setTimeout(() => {
    modal.classList.remove('show');
  });
  
  // We want to set the display style back to none and remove the backdrop div from the body
  // with a delay of 500ms in order to give their transition/animations time to complete
  // before totally hiding and removing them.
  setTimeout(() => {
    modal.style.display = 'none';
  	backdrop.remove();
  }, 500); // this time we specified a delay
}

function openModal(modal) {
  const backdrop = document.createElement('div');
  // Remove the show from the initial classList, we will add it in the timeout
  //
  // backdrop.classList.add('modal-backdrop', 'fade', 'show');
  backdrop.classList.add('modal-backdrop', 'fade');
  document.body.classList.add('modal-open');
  document.body.appendChild(backdrop);
  modal.style.display = 'block';
  modal.setAttribute('aria-hidden', 'false', 'show');
  
  // We don't need to specify the milliseconds in this timeout, since we don't want a delay,
  // we just want the changes to be done outside of the normal DOM thread.
  setTimeout(() => {
    // Move adding the show class to inside this setTimeout
    modal.classList.add('show');
    // Add the show class to the backdrop in this setTimeout
    backdrop.classList.add('show');
  });
}
```

## It Works!

Now when you show and hide the modal, you'll see we now have the exact same transitions/animations that bootstrap modals normally have, but with no jQuery!

Now obviously there are plenty of other bootstrap components that also depend on jQuery.  Hopefully this post gives you an idea on how you can use plain JavaScript to handle those without jQuery too.  Maybe I will write about some of the other components in the future also.

NOTE: I was unable to figure out how to make it so when you click the backdrop it closes the modal.  If I figure it out, I will update the post.  Or if anyone reading this has an idea, feel free to comment below, or reach out to me on my [contact form](https://blog.carsonevans.ca/contact/).

If you wish to reference a complete fully working demo of all of this instead of the broken up chunks in this post, I have one [here on my GitHub](https://github.com/carc1n0gen/tutorial-apps/tree/master/bootstrap-modal-without-jquery). I also have a [live demo](/post-assets/bootstrap-modals-without-jquery/demo.html)