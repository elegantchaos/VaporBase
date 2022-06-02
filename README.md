
# VaporBase

This is intended to form the bases of a Vapor website, using Postgres as the database.

It defines and handles two model types: `User`, and `Token`.

It supplies pages to handle:

- registering
- logging in
- verifying email address (via mailgun)
- display a basic profile page for the logged in user
- updating a user's name/password
- displaying an admin page
- editing user's information as an admin

Some default `.leaf` files are supplied with a simple user interface for this.

It is expected that a client of this library will:

- define more Model classes, pages, leaf file and controllers for the actual website content
- replace some or all of the default `.leaf` files

A test project which uses this package as a client [can be found here](https://github.com/elegantchaos/VaporBaseTest).

## What's Missing

Lots of stuff! Including:

- quite a lot of error handling
- validating a changed email address
- password reset request


## Local Testing

To test locally, you need to install postgres (`brew install postgresql`).

By default the framework expects a database called "vaporbasetest", a user "vapor", with a password "vapor", running on "localhost" (these details can be changed when setting up a custom site).

You can use `psql postgres`, to create the role and database:

```
CREATE ROLE vapor WITH LOGIN PASSWORD 'vapor';
ALTER ROLE vapor CREATEDB;
CREATE DATABASE vaporbasetest;
```

If you later need to migrate a database after upgrading postgres, you can do it with `brew postgresql-upgrade-database`.
 

