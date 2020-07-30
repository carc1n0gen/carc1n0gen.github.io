---
layout: post
author: Carson Evans
---

Flight PHP is a micro framework for web applications. Flight requires PHP 5.3 or greater, and is released under the [MIT license](http://flightphp.com/license). Flight takes care of some of the most common tasks a web application might need such as; routing, named parameters with friendly URL's, views/layouts, and errors handling. Flight is built to be extremely extensible to go beyond those features. If you want to learn how Flight works internally you can take a look at its [github page](https://github.com/mikecao/flight).

## Installing Flight

There are two ways to install Flight.  With composer (recommended), or manually

### Installing Flight with Composer

Create a composer.json file with the following contents:

```json
{
    "require": {
        "mikecao/flight": "1.*"
    }
}
```

Then from the command line run: `php composer.phar install`

### Install Flight manually

From the Flight [github page](https://github.com/mikecao/flight), download the zip of the repository and extract the framework files to your web app directory.

### Setting up your server

For Apache web servers you will need to create or edit your .htaccess file with the following:

```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
```

For Nginx web servers edit your server declaration with the following:

```nginx
server {
    location / {
        try_files $uri $uri/ /index.php;
    }
}
```

## Flight hello world

Create an index.php file in your web directory and start editing it. If you installed Flight with Composer then add the following to the top of the file:

```php
require_once 'vendor/autoload.php';
```

Or, if you installed Flight manually then:

```php
require_once 'flight/Flight.php';
```

Create a route for the index of the application:

```php
Flight::route('/', function(){
    echo 'hello world!';
});
```

Then start Flight:

```php
Flight::start();
```

The complete code should look like this:

```php
require_once 'vendor/autoload.php';
//require_once 'flight/Flight.php'; // If you installed Flight manually

Flight::route('/', function(){
    echo 'hello world!';
});

Flight::start();
```

Now open your browser and navigate to your web applications URL. You should see a "hello world" message

## Create a JSON web service with Flight PHP

### Preface

This part of the tutorial assumes you have basic knowledge of PHP and MySQL and can do basic operations such as; connect to database through a shell or workbench, creating a database, creating tables, and query a MySQL database from PHP.

### Setting up the database

First thing we are going to do is to set up a simple database. For this example I am going to using MySQL. Either in a MySQL console, or in MySQL workbench create a new database for this tutorial. Make sure the new database is selected with `USE database` replaceing "database" with the name you gave the database. Now execute the following:

```sql
CREATE TABLE posts (
    id int unsigned NOT NULL AUTO_INCREMENT,
    title varchar(50) DEFAULT NULL,
    body text,
    published tinyint DEFAULT 0,
    PRIMARY KEY (id)
);
```

Then insert some data:

```sql
INSERT
  INTO posts (title, body)
VALUES ("Flight PHP", "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.");

INSERT
  INTO posts (title, body)
VALUES ("Dog and the Fox", "The quick brown fox jumps over the lazy dog.");

INSERT
  INTO posts (title, body)
VALUES ("PHP", "PHP is cool!");
```

### Create the Flight app

Now it is time to create the Flight app. For this app, lets get our JSON data from the `/json-data` route.

```php
Flight::route('GET /json-data', function() {

});
```

### Connect to the database

```php
$db = new PDO('mysql:host=localhost;dbname=db', 'username', 'password');
```

You will need to put your database name in place of "db" right after "dbname=", and replace the username/password with yours.

### Gather the data

Next we will create a prepared statement and execute it.

```php?start_inline=1
$stmt = $db->prepare("SELECT * FROM posts");
$stmt->execute();
```

### Present the data

And finally, we need to set the content type header to application/json to let the client that connects to this service know what type of data they are receiving. Then we display the results from the prepared statement is JSON format. At the very end close the database connection.

```php
header('Content-type: application/json');
echo json_encode($stmt->fetchAll());

$db = null;
```

### Conclusion

The final product should look something like this:

```php
require_once 'vendor/autoload.php';
//require_once 'flight/Flight.php'; // If you installed Flight manually

Flight::route('GET /json-data', function() {
    $db = new PDO('mysql:host=localhost;dbname=dbname', 'username', 'password');

    $stmt = $db->prepare("SELECT * FROM posts");
    $stmt->execute();

    header('Content-type: application/json');
    echo json_encode($stmt->fetchAll());

    $db = null;
});

Flight::start();
```


If you navigate to you the URL of your web app you should be able to see a JSON string representing each row of the database. Now using either an AJAX call, or a server side HTTP request you will be able to get this JSON data and parse it for a specific use.

[Further reading](http://flightphp.com/learn)