+++
title = "enterprise: Strawman Proposal"
draft = true

[taxonomies]
tags = ["enterprise", "rust"]

[extra]
# comment_issue = 3
+++

A friend ([Michael Zhang](https://iptq.io/)) and I may be working on a web framework for Rust, [`enterprise`](https://crates.io/crates/enterprise). This post serves as a strawman proposal for this framework, and as documentation for what the framework may eventually be.

Also note that despite the authorial "we," this is almost entirely my vision (hence the S-expressions, use of Prolog, etc.), so expect this to be a strawman that's lit aflame rather than fortified.

Introduction
============

The model we use for webapps is described by a dependency diagram:

```dot
digraph "dependency graph" {
	graph[bgcolor="#1e1f29"];

	BLogic[color="#8be9fe" fontcolor="#8be9fe" label="Business\nLogic" URL="#business-logic"];
	Actions[color="#8be9fe" fontcolor="#8be9fe" URL="#actions"];
	Schema[color="#8be9fe" fontcolor="#8be9fe" URL="#schema"];
	Views[color="#fc4cb4" fontcolor="#fc4cb4" URL="#views"];
	ViewAdapters[color="#f0fb8c" fontcolor="#f0fb8c" label="View\nAdapters" URL="#view-adapters"];
	Authentication[color="#f0fb8c" fontcolor="#f0fb8c" URL="#authentication"];
	Authorization[color="#fc4cb4" fontcolor="#fc4cb4" URL="#authorization"];

	Actions -> Schema [color="#fc4346"];
	Authorization -> Actions [color="#fc4346"];
	Authorization -> Authentication [color="#fc4346"];
	Authorization -> Schema [color="#fc4346"];
	BLogic -> Actions [color="#fc4346"];
	BLogic -> Authentication [color="#fc4346"];
	BLogic -> Schema [color="#fc4346"];
	Views -> Authentication [color="#fc4346"];
	Views -> Schema [color="#fc4346"];
	Views -> ViewAdapters [color="#fc4346"];
}
```

As well as a dataflow diagram for server-side rendering:

```dot
digraph "dataflow graph" {
	graph[bgcolor="#1e1f29"];

	HTTP[color="#cfcfcf" fontcolor="#cfcfcf" shape=plaintext];
	Databases[color="#cfcfcf" fontcolor="#cfcfcf" label="Databases and\nExternal Services" shape=plaintext];

	Authorization[color="#fc4cb4" fontcolor="#fc4cb4" URL="#authorization"];
	Actions[color="#8be9fe" fontcolor="#8be9fe" URL="#actions"];
	BLogic[color="#8be9fe" fontcolor="#8be9fe" label="Business\nLogic" URL="#business-logic"];
	DAL[color="#f0fb8c" fontcolor="#f0fb8c" URL="#data-access-layer"];
	Router[color="#f0fb8c" fontcolor="#f0fb8c" URL="#router"];
	ViewAdapters[color="#f0fb8c" fontcolor="#f0fb8c" label="View\nAdapters" URL="#view-adapters"];
	Views[color="#fc4cb4" fontcolor="#fc4cb4" URL="#views"];
	Authentication[color="#f0fb8c" fontcolor="#f0fb8c" URL="#authentication"];

	{rank=same; Authentication, ViewAdapters};
	{rank=same; BLogic, Views};
	{rank=same; Actions, Authorization};

	HTTP -> Router [color="#cfcfcf"];
	Router -> HTTP [color="#cfcfcf"];
	Databases -> DAL [color="#cfcfcf"];
	DAL -> Databases [color="#cfcfcf"];

	// When the router gets a request, it passes it to the business logic,
	// along with the results of authentication.
	Router -> BLogic [color="#50fb7c"];
	Router -> Authentication [color="#50fb7c"];
	Authentication -> BLogic [color="#50fb7c"];

	// The business logic performs actions (and gets data from them).
	BLogic -> Actions [color="#50fb7c"];
	Actions -> BLogic [color="#50fb7c"];

	// Actions are allowed or disallowed based on the results of
	// authorization, which is also informed by authentication and the
	// database (via the DAL).
	Authentication -> Authorization [color="#50fb7c"];
	Authorization -> Actions [color="#50fb7c"];
	DAL -> Authorization [color="#50fb7c"];

	// Actions communicate with the database via the DAL.
	Actions -> DAL [color="#50fb7c"];
	DAL -> Actions [color="#50fb7c"];

	// The business logic then communicates the response to views, which
	// are rendered with view adapters, which then send a rendered response
	// to the router.
	BLogic -> Views [color="#50fb7c"];
	Views -> ViewAdapters [color="#50fb7c"];
	ViewAdapters -> Router [color="#50fb7c"];
}
```

In the above diagrams, <span style="color: #f0fb8c">yellow</span> components are provided by `enterprise`, <span style="color: #8be9fe">blue</span> components are written by the application author in Rust, and <span style="color: #fc4cb4">pink</span> components are written by the application author in a DSL.

The Schema and DAL components are taken from [Ted Kaminski's "Stateless MVC,"](https://www.tedinski.com/2018/09/11/stateless-mvc.html) which describes them in detail.

Schema
======

The Schema component contains type declarations for each of the "domain objects." If a type ends up being sent over the network, it should probably be declared here. [Derive macros](https://iptq.io/magic-forms-with-proc-macros/) are provided to allow the Router to validate these values.

The only exports of the Schema should be types -- if you find yourself exporting functions, they probably belong in the business logic.

Actions
=======

Actions are the atomic primitive functions that are used to define the business logic. Macros are available to define CRUD actions for types in the Schema (relative to some data store supported by the DAL).

Business Logic
==============

The Business Logic module transforms requests into data that can be handled directly by a View.

Views
=====

Views are written in a React-like DSL.

View Adapters
=============

View Adapters are backends for Views -- one exists to translate to HTML, another to translate to JSON, and another that performs tree-diffing to efficiently update HTML.

Auth
====

The generic phrase "auth" confusingly can refer to either "authentication" or "authorization." These are conflated both by the term and in many people's heads, so we avoid it, and make a strong split between the two.

Authentication
--------------

Authentication is the answer to the question "what user does this request correspond to?" As with other parts of a web application, `enterprise` simplifies authentication by abstracting it heavily.

For our app, we want to allow a plethora of authentication methods, while also allowing a user to have multiple authentication methods. (This is useful since a user might forget whether they registered with their Google account or email, and it allows an anonymous user to add an email and stop being anonymous!)

In `app.sexp`:

```lisp
(authentication
  (multiple true)
  (providers
    anonymous-cookie
    (email-password :reset email)
    oauth-facebook
    oauth-google
    oauth-twitter))
```

In `views/login.sexp`:

```lisp
TODO
```

Authorization
-------------

Authorization is the answer to the question "can this user perform this action?" This is almost entirely application-specific, so we leave the logic here to the app author.

But wait, we're using logic on a question with a boolean answer? Well, I know the best way to do this! `enterprise` apps specify authorization information with a Prolog dialect.

For our app, TODO.

In `src/authorization.pro`:

```pro
authorized(UserID, Action). # TODO
```
