---
layout: post
author: Carson Evans
---

[Dart](https://www.dartlang.org/) is a structured programming language for the web created by Google. The goal of Dart is to replace JavaScript as the most popular language for web development. For now, due to lack of availability in mainstream browsers Dart is compiled to JavaScript. Dart syntax resembles that of Java and C# in that it has class-base objects with C-style syntax.

## Getting the Dart IDE

You can find downloads links for either 32bit or 64bit OS from the Dart [home page](https://www.dartlang.org/). The IDE requires a version of [Java](https://www.java.com/en/) that matches the platform of the IDE to be installed in order to run.

## Create a new project

Once you have the IDE open, select the new project option from the file menu. A dialog will appear allowing you to enter a project name, select the projects location on your computer, and to select from a list of project templates. Name the project anything you want and just leave the parent directory default unless you really want to change it. For this tutorial we will use the web application template. Click finish and the IDE will create a basic web app template. You can now press the green play button in the IDE to test the web app.

## Lets add some stuff

Now lets play around with the dart language. In the html file of the project delete everything inside the body. Now create a canvas with a width and height of 300, two buttons, one with the text and id "left", one with the text and id "right".

```html
<canvas width="300" height="300"></canvas>
<button id="left">left</button>
<button id="right">right</button>
```

Now open up the .dart file. In here we can manipulate the DOM just like a JavaScript file can. Delete the contents of the main function and delete the "reverseText" function. Now above the main function lets create some global variables:

```dart
var rotation = 0.0;
var screen = querySelector("canvas");
var leftButtonPressed = false;
var rightButtonPressed = false;
```

Now below the main function create a draw function to draw a simple square on the canvas:

```dart
void draw(num delta) {
  screen.context2D.clearRect(0, 0, screen.width, screen.height);
  screen.context2D.fillStyle = "#000";
  screen.context2D.fillRect(screen.width / 4, screen.width / 4, screen.width / 2, screen.width / 2);

  window.animationFrame.then(draw);
}
```

Then in the main function call the draw function:

```dart
void main() {
  window.animationFrame.then(draw);
}
```

Run the project and you should see a black square on the page. Well this is a little boring so lets ad the ability to rotate the square with the left and right buttons. First in the main function before calling the draw function add some mouse event listeners to the left and right buttons:

```dart
void main() {
  querySelector("#left").onMouseDown.listen((e) {
    leftButtonPressed = true;
  });

  querySelector("#left").onMouseUp.listen((e) {
    leftButtonPressed = false;
  });

  querySelector("#right").onMouseDown.listen((e) {
    rightButtonPressed = true;
  });

  querySelector("#right").onMouseUp.listen((e) {
    rightButtonPressed = false;
  });

  window.animationFrame.then(draw);
}
```

At the top of the file add `import 'dart:math';`. From the math library we are going to use the PI constant to calculate the rotation of the square. The new draw function is as follows:

```dart
void draw(num delta) {
  screen.context2D.clearRect(0, 0, screen.width, screen.height);
  screen.context2D.fillStyle = "#000";
  screen.context2D.save();
  screen.context2D.translate(screen.width / 2, screen.height / 2);
  screen.context2D.rotate(rotation * PI/180);
  screen.context2D.translate(-screen.width / 2, -screen.height / 2);
  screen.context2D.fillRect(screen.width / 4, screen.width / 4, screen.width / 2, screen.width / 2);
  screen.context2D.restore();

  if (leftButtonPressed) {
    rotation -= 5;
  }
  if (rightButtonPressed) {
    rotation += 5;
  }
  window.animationFrame.then(draw);
}
```

The final product should look like this:

```dart
import 'dart:html';
import 'dart:math';

var rotation = 0.0;
var screen = querySelector("canvas");
var leftButtonPressed = false;
var rightButtonPressed = false;

void main() {
  querySelector("#left").onMouseDown.listen((ee) {
    leftButtonPressed = true;
  });

  querySelector("#left").onMouseUp.listen((ee) {
    leftButtonPressed = false;
  });

  querySelector("#right").onMouseDown.listen((ee) {
    rightButtonPressed = true;
  });

  querySelector("#right").onMouseUp.listen((ee) {
    rightButtonPressed = false;
  });

  window.animationFrame.then(draw);
}


void draw(num delta) {
  screen.context2D.clearRect(0, 0, screen.width, screen.height);
  screen.context2D.fillStyle = "#000";
  screen.context2D.save();
  screen.context2D.translate(screen.width / 2, screen.height / 2);
  screen.context2D.rotate(rotation * PI/180);
  screen.context2D.translate(-screen.width / 2, -screen.height / 2);
  screen.context2D.fillRect(screen.width / 4, screen.width / 4, screen.width / 2, screen.width / 2);
  screen.context2D.restore();

  if (leftButtonPressed) {
    rotation -= 5;
  }
  if (rightButtonPressed) {
    rotation += 5;
  }
  window.animationFrame.then(draw);
}
```

## Conclusion

Run the project and you can now rotate the square using the left and right buttons. If you would like to learn more about the Dart programming you can read their [API docs](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/home).