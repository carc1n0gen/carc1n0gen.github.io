---
layout: post
author: Carson Evans
---

When developing a website it is much easier to create page layouts with a grid framework.  Especially if the framework is responsive.  The problem with most grid frameworks is that they either come as part of a larger framework, or require JavaScript.

## K.I.S.S.

KEEP IT SIMPLE STUPID!  Grids don't need to be very complicated.  So lets build a basic grid framework in under 50 lines of CSS with no JavaScript at all.

## Creating A Responsive Grid Framework With Pure CSS

### Writing Reusable CSS

Before going off and diving in to the CSS we should think about how to keep things reusable.  A good rule of thumb is to pick a prefix for all classes in order to prevent conflicts with other CSS.  This is similar to packages in Java and namespaces in C++ or C#.  For the purpose of this tutorial I will be using `prefix` as the prefix, but feel free to pick your own.

### The HTML Markup

Before creating the CSS rules we need some HTML:

```html
<div class="prefix-grid">

</div>
```

This `div` will be the grid container to hold the columns.  Next add some columns:

```html
<div class="prefix-grid">
  <div class="prefix-col-1-4">
  </div>
  <div class="prefix-col-3-4">
  </div>
</div>
```

Now we have added two columns to the grid.  One will take one quarter of the grid width, and the second will take  three quarters of the grid width.  Of course as it is now it will not display like a grid yet.

### The CSS

To get the grid to display grid like, we need to write some minimal CSS rules.  First we will work on getting the types of columns we have used to work, and then we will finish with other column width options.

```css
/* clear the floated columns */
.prefix-grid:after {
  content: "";
  display: table;
  clear: both;
}

/* float all columns to the left */
[class*='prefix-col-'] {
  float: left;
  width: 100%; /* mobile first */
}

/* override the 100% width columns if the screen is wide enough */
@media only screen and (min-width: 48em) {
  .lite-col-1-4 { width: 25%; }
  .lite-col-3-4 { width: 75%; }
}
```

Lets inspect this part by part now:

```css
/* clear the floated columns */
.prefix-grid:after {
  content: "";
  display: table;
  clear: both;
}
```

This is needed to clear the columns because they are all floated.  When all of a containers children are floated, the container won't actually wrap the children because floating takes them out of normal flow of the page.  This is basically a fix that will correct that.

```css
/* float all columns to the left */
[class*='prefix-col-'] {
  float: left;
  width: 100%; /* mobile first */
}
```

To some people the selector used here might look a little strange.  It is sort of a wild card selector that matches part of the class. `[class*='prefix-col-']` means any elements whos class begins with `prefix-col-` will have these rules.  This means it will work on both `prefix-col-1-4` and `prefix-col-3-4`.  We are going the mobile first approach so by default all columns display 100% width.

```css
/* override the 100% width columns if the screen is wide enough */
@media only screen and (min-width: 48em) {
  .lite-col-1-4 { width: 25%; }
  .lite-col-3-4 { width: 75%; }
}
```

Here is where we actually make the columns work more like columns.  I like to use `em` instead of `px` in my media queries because then very large text will also trigger the mobile look and allow the content to still be read without scrolling horizontally.  The `1-4` and `3-4` are meant to be easy to read an understand as the fractions `1/4` and `3/4`.  Add some text in the columns and they should display as one quarter and three quarters columns.

Here is the full grid framework with more rules for more width percentages:

```css
/* clear floated columns */
.prefix-grid:after {
  content: "";
  display: table;
  clear: both;
}

/* float all columns to the left */
[class*='prefix-col-'] {
  float: left;
  width: 100%; /* mobile first */
}

/* create gutters */
[class*='prefix-col-'] > div {
  margin: .5em;
}

/* override the 100% width columns if the screens min width is great enough */
@media only screen and (min-width: 48em) {
  .prefix-col-1-1 { width: 100%; }

  .prefix-col-1-2 { width: 50%; }

  .prefix-col-1-3 { width: 33.33%; }
  .prefix-col-2-3 { width: 66.66%; }

  .prefix-col-1-4 { width: 25%; }
  .prefix-col-3-4 { width: 75%; }

  .prefix-col-1-5 { width: 20%; }
  .prefix-col-2-5 { width: 40%; }
  .prefix-col-3-5 { width: 60%; }
  .prefix-col-4-5 { width: 80%; }

  .prefix-col-1-6 { width: 16.66%; }
  .prefix-col-4-6 { width: 66.64%; }
  .prefix-col-5-6 { width: 83.3%; }

  .prefix-col-1-8 { width: 12.5%; }
  .prefix-col-3-8 { width: 37.5%; }
  .prefix-col-5-8 { width: 62.5%; }
  .prefix-col-7-8 { width: 87.5%; }
}
```

With grids gutters can be very complicated to impliment, but in this version of the CSS I have made it so that any `div` inside of any column will have a margin.  This is a very simple way to create gutters without complicating the CSS.

## Conclusion

Now you have a basic responsive pure CSS grid framework with about 45 lines of CSS (including comments).