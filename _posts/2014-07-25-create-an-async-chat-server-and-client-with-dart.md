---
layout: post
author: Carson Evans
---

Before starting this tutorial you should be familiar with my previous post about [creating your first webapp in dart](http://blog.carsonevans.ca/2014/07/11/create-your-first-webapp-with-google%27s-dart-programming-language/).  In this tutorial we are going to make two Dart projects.  The first one will be a command line application for the server, the second one will be a web application for the client.  We will be using WebSockets for communication between server and client.

## Creating the server

Open up the Dart IDE and start a new project.  Name it ChatServer and pick the `Command-line application` template.  A command line application means this project has no GUI, it just runs in the command prompt or terminal.  The default command line application has a bin folder with one main script that acts as the entry point for the application.  The script should look something like this:

```dart
void main() {
  print("Hello, World!");
}
```

Above the main function we need to add an import, create a constant to hold the port the server will listen too, and create a list to hold web socket connections:

```dart
import 'dart:io';

const int PORT = 9090;

List<WebSocket> connections;
```

In Dart, to make a websocket server you make a http server and *transform* it into a websocket server.  Delete the contents of the main function, initialize the connections list, and bind an http server using the constant we made earlier as the port number:

```dart
import 'dart:io';

const int PORT = 9090;

List<WebSocket> connections;

void main() {
  connections = new List<WebSocket>();

  HttpServer.bind(InternetAddress.ANY_UP_V4, PORT).then((HttpServer server) {
    print('Server listening on port ${PORT}.');
  });
}
```

This syntax might look a little strange to people not familiar Dart or asynchronous programming.  The `bind` method of the HttpServer class is asynchronous and will return an instance of a HttpServer some time in the future.  All asynchronous methods in Dart act this way and have a `then` method that is called when they are done.  You provide the `then` method with a callback that accepts the type returned by the asynchronous method.  This callback is executed when the asynchronous method is complete and the `then` method is run.  In our case, we are passing an anonymous function as a callback to the `then` method, and all this callback does at this point is print what port the server is listening on.

Now lets make the http server listen for requests:

```dart
print('Server listening on port ${PORT}.');
server.listen((HttpRequest request) {
  if (WebsocketTransformer.isUpgradeRequest(request)) {
    // Transform to websocket
  } else {
    request.response.statusCode = HttpStatus.FORBIDDEN;
    request.response.reasonPhrase = 'Websocket connections only!';
    request.response.close();
  }
});
```

Here we are checking if the request is a websocket request and if it is not then we send the client connecion an error message.  Next we will do the websocket work.

```dart
if (WebsocketTransformer.isUpgradeRequest(request)) {
  WebSocketTransformer.upgrade(request).then((WebSocket ws) {
    connections.add(ws);
    print('Client connected, there are now ${connections.length} client(s) connected.');
    ws.listen((String message) {
      for (WebSocket connection in connections) {
        connection.add(message);
      }
    },
    onDone: () {
      connections.remove(ws);
      print('Client disconnected, there are now ${connections.legnth} client(s) connected.');
    });
  });
} else {
  request.response.statusCode = HttpStatus.FORBIDDEN;
  request.response.reasonPhrase = 'Websocket connections only!';
  request.response.close();
}
```

Here we transform the request to a websocket connection and add it to our list of connections.  Then we listen for messages coming from the websocket connection and send that message to every connection in the list of connections.

The complete code should look like this:

```dart
import 'dart:io';

const int PORT = 9090;

List<WebSocket> connections;

void main() {
  connections = new List<WebSocket>();

  HttpServer.bind(InternetAddress.ANY_IP_V4, PORT).then((HttpServer server) {
    print('Server listening on port ${PORT}.');
    server.listen((HttpRequest request) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request).then((WebSocket ws) {
          connections.add(ws);
          print('Client connected, there are now ${connections.length} client(s) connected.');
          ws.listen((String message) {
            for (WebSocket connection in connections) {
              connection.add(message);
            }
          },
          onDone: () {
            connections.remove(ws);
            print('Client disconnected, there are now ${connections.length} client(s) connected.');
          });
        });
      } else {
        request.response.statusCode = HttpStatus.FORBIDDEN;
        request.response.reasonPhrase = 'Websocket connections only!';
        request.response.close();
      }
    });
  });
}
```

You can now run this project, but it doesn't do anything because there is no client to connect with

## Creating the client

Start another new project with the name ChatClient with the `Web application` template.  In Dart web applications have a web folder where everything will go.  By default there will be a html, css, and dart file.  Open up the html file and delete everything inside the body tags then add the following:

```html
<body>
<h1>ChatClient</h1>

<input id="nickname" type="text" /><button id="savenickname">Save</button>
<div id="output"></div>
<textarea id="input"></textarea>
<button id="send">Send</button>

<script type="application/dart" src="chatclient.dart"></script>
<script src="packages/browser/dart.js"></script>
</body>
```

The first input is where you will enter your nickname with a button that saves it.  Then there is a `div` that will be used for do display chat messages, a `textarea` for chat input, and a send button for sending message to the server.  At the end there is two script references.

The first script reference is the main Dart script for the web application and is where we will be coding our logic.  The second script is a special script used to detect if the web browser supports Dart or not and will fallback to the JavaScript compiled version of the web app.

Open up the css file and delete everything and add the following:

```css
#output {
  width: 600px;
  height: 400px;
  margin: 0 auto;
}
```

Open up the Dart script and delete everything below the main function and inside the main function.  Above the main function add an import for DOM support:

```dart
import 'dart:html';
```

Inside the main function we need to select the elements we need with `querySelector`:

```dart
void main() {
  InputElement nickname = querySelector('#nickname');
  DivElement output = querySelector('#output');
  TextAreaElement input = querySelector('#input');
  ButtonElement send = querySelector('#send');
  ButtonElement savenickname = querySelector('#savenickname');
}
```

Next create a WebSocket connection:

```dart
WebSocket ws = new WebSocket('ws://localhost:9090');
```

Now when the save nickname button is clicked we need to make the nickname field read only.

```dart
savenickname.onClick.listen((MouseEvent event) {
  if (nickname.value != '') {
    nickname.readOnly = true;
  }
});
```

Then we make the send button actually send the contents of the input to the server.  We only want to send the message if the nickname is read only (has been saved) and the input isnt empty:

```dart
send.onClick.listen((MouseEvent event) {
  if (nickname.value != '' && nickname.readOnly) {
    String message = input.value;
    input.value = '';
    input.focus();
    ws.send("${nickname.value}: ${message}");
  }
});
```

Finally we need to listen to the connection to the server for messages to display in the output `div`:

```dart
ws.addEventListener('message', (event) {
  String message = event.data;
  output.innerHtml += '<p>${message}</p>';
});
```

Here is the complete code:

```dart
import 'dart:html';

void main() {
  InputElement nickname = querySelector('#nickname');
  DivElement output = querySelector('#output');
  TextAreaElement input = querySelector('#input');
  ButtonElement send = querySelector('#send');
  ButtonElement savenickname = querySelector('#savenickname');
  WebSocket ws = new WebSocket('ws://localhost:9090');

  savenickname.onClick.listen((MouseEvent event) {
    if (nickname.value != '') {
      nickname.readOnly = true;
    }
  });

  send.onClick.listen((MouseEvent event) {
    if (nickname.value != '' && nickname.readOnly) {
      String message = input.value;
      input.value = '';
      input.focus();
      ws.send("${nickname.value}: ${message}");
    }
  });

  ws.addEventListener('message', (event) {
    Message msg = new Message.FromJson(event.data);
    output.innerHtml += '<p>${message}</p>';
  });
}
```

## Conclusion

Now you can run the chat server, then run the chat client.  Enter a nickname, enter a message and click send.  You should then see your message.  You can copy the url for the chat client and open multiple tabs and go to that url.  Each tab will count as a new connection to the server so they can all talk to each other.