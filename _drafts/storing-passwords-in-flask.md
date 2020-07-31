There is a plethora of guides out there about how to securly store passwords, but there are not as many of those guides that apply to [Flask](#) specifically.  I spend quite a but of my free time on the Pallets discord helping people out with their Flask questions, and often enough we have people storing passwords as plain text.  So I thought I woud write about the different options one has for correctly storing passwords in a Flask app.

## How To Store Passwords

Quite simply put, the only way to securely store a password, is to not store it at all. Instead what we do is put the password through a hashing algorithm, and store the hash output.  Then when you need to check if a password is correct on a login form for example, you hash the submitted password, and compare that hash with the hash you have stored in the database.  If they match, then the password is correct.

You don't want to use just any general purpose hashing algorithm though (md5, sha1/2/3 as examples).  Those are designed to be as fast as possible, and some of them are old and have been defeated by faster modern hardware.  Another reason to not use a general purpose hashing algorithm is that it is easy to obtain something called a "rainbow table", which is a giant list of precalculated password input and hash output combinations.  If you use a general purpose hash algorith, and your database is breached, someone can just use this ranbow table to reverse lookup what the original password was.  In a perfect world this would not matter too much, since people should not use the same password on multiple websites/services, but we do not live in a perfect world.

Instead of a general purpose hashing algorithm, you want to use an algorithm designed for passwords.  These algorithms combine the password with a random "salt", which is a relatively short random string, and a cost/work/iterations factor, which is a number used to increase the number of hashing rounds (the hash output will be hashed again and again...) in order to increase the time it takes to hash the password.  With these two strategies combined, you are protected against rainbow tables, since a rainbow table can't take in to account a random salt, and better protecfted agains brute force attacks on your site, since you can configure the time it takes to hash/verify a password to be long enough to make bruce force attacks ineffecient.

In a Flask app, you have 3 main choices.  First werkzeug's built in password hashing functions, which is the easiest since Flask is built on werkzeug so you don't have to install anything extra.  Another is brcrypt which is one of the most common password hash algorithms and has implementations in just about every langauge.  Last you could roll your own.  But seirously, when it comes to cryptographic functions, please don't roll your own.  There are probably other library/options out there, but in this post I am going to focus on werkzeug's built in password hashing functions, and bcrypt.

## Werkzeug Functions

## Bcrypt

## Which One Should You Use?


(link to sample apps demonstrating sign up and login with both)

(unfinished)
