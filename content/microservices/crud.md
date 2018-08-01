+++
title = "CRUD Worker"
+++

## Overview

CRUD = Create, Read, Update, Delete

Most of your API endpoints are going to be one of these four things.
These are annoying not because they're hard to code, but because they end up involving a lot of boilerplate.
Additionally, they're going to be the bulk of the total number of requests, so it's important that the server here supports handling huge numbers of concurrent connections.

## Tech Recommendation

I like Go with [Gin](https://gin-gonic.github.io/gin/) for the web parts of this -- Gin removes a decent amount of boilerplate, and I wrote [a small utility wrapper](https://github.com/remexre/gin-utils) that makes it even easier.
Check the MinneHack Backend if you want to see it in action.

Go has the built-in `database/sql` package, which is fairly good.
I'm against ORMs, because they tend to encourage stupid schema design.
