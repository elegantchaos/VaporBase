
# VaporBase

This is a base Vapor setup, which handles basic login/logout and user profile management.

It has no content model of its own - that should be added by the client package.

It's very simple at the moment, with a minimal UI.


## Local Testing

### Install Postgres

Install with `brew install postgresql`

(Migrate database with `brew postgresql-upgrade-database`)

### Create Database 

Setup database:

> psql postgres

> CREATE ROLE vapor WITH LOGIN PASSWORD 'vapor';
> ALTER ROLE vapor CREATEDB;
> CREATE DATABASE vaporbasetest;
