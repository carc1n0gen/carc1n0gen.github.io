---
layout: post
author: Carson Evans
---

[DigitalOcean](https://www.digitalocean.com/) has just launched their most requested feature, [FreeBSD droplets](https://www.digitalocean.com/company/blog/presenting-freebsd-how-we-made-it-happen/). So here is how to install Nginx with PHP support on one of their FreeBSD droplets.

All of the commands used in this post will require root or sudo access.

## Install Nginx ##

```python
pkg install nginx
```

### Configure Nginx ###

Open `/usr/local/etc/nginx/nginx.conf` and edit the existing uncommented `server { ... }` section.

```nginx
server {
    listen       80;

    ## Where to serve files from
    root /usr/local/www/nginx;

    index index.php index.html index.htm;

    ## Optionally change this to match the domain you want to listen on ex: www.example.com
    server_name  localhost;

    ## Attempt to serve file and fallback to 404 on fail.
    location / {
        try_files $uri $uri/ =404;
    }

    ## Custom error pages
    error_page  404              /404.html;
    error_page  500 502 503 504  /50x.html;

    ## PHP FastCGI
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        ## Optional fastcgi settigns
        #fastcgi_buffer_size 128k;
        #fastcgi_buffers 256 16k;
        #fastcgi_busy_buffers_size 256k;
        #fastcgi_temp_file_write_size 256k;
        include fastcgi_params;
    }
}
```

## Install PHP 5.6 ##

```python
pkg install php56
```

### Configure PHP 5.6 ###

There are two sample php.ini files provided by default.  A production and development version.  Copy the one you would like to use to enable it.

```python
cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
```

Make a small security adjustment to the php.ini.  Find the commented line with:

```ini
; cgi.fix_pathinfo=1
```

Uncomment it and set it to 0

```ini
cgi.fix_pathinfo=0
```

## Enable Services ##

Edit `/etc/rc.conf` and add:

```ini
nginx_enable="YES"
php_fpm_enable="YES"
```

## Start Services ##

```python
service php-fpm start
```

```python
service nginx start
```

## Create a Test page ##

Create an `index.php` under `/usr/local/www/nginx` with the content:

```php
<?php
phpinfo();
```

Now point your browser to the ip or domain of your server and you will see all the settings for your PHP installation.