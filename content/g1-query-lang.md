+++
title = "G1's Query Language"
draft = true

[taxonomies]
categories = ["post"]
tags = ["g1", "rust"]

[extra]
# comment_issue = 2
+++

The G1 query language is a variant of Datalog, a sound subset of Prolog whose properties make it a useful query language. Datalog queries are provably terminating in polynomial time (with respect to the size of the DB), and can be analyzed and optimized ahead of time for significant speed boosts.

G1's implementation is unusual largely in that there exists both a parser for strings of Datalog source code and a parser that operates on Rust tokens, and also allows interpolation, for use in a procedural macro.

Syntax
======

The G1 grammar is (somewhat informally) as follows:

```ebnf
<query> ::= <clause>* "?-" <predicate> "."

<clause> ::= <predicate> "."
<clause> ::= <predicate> ":-" commaSeparated1(<possiblyNegatedPredicate>) "."

<possiblyNegatedPredicate> ::= <predicate>
<possiblyNegatedPredicate> ::= "!" <predicate>

<predicate> ::= <var> "(" commaSeparated(<value>) ")"

<value> ::= "_"
<value> ::= <string>
<value> ::= <var>

<string> ::= '"' <stringChar>* '"'

<var> ::= "'" <stringChar>* "'"
<var> ::= /[A-Za-z][0-9A-Za-z_]*/

<stringChar> ::= any printable character other than "'", '"', or "\"
<stringChar> ::= "\" <escChar>

<escChar> ::= "\"
<escChar> ::= "'"
<escChar> ::= '"'
<escChar> ::= "n"
<escChar> ::= "r"
<escChar> ::= "t"

commaSeparated(NT) ::=
commaSeparated1(NT) ::= commaSeparated1(NT)

commaSeparated1(NT) ::= NT
commaSeparated1(NT) ::= commaSeparated1(NT) "," NT
```

Note that unlike Prolog, Datalog doesn't allow functors as values (i.e. `foo(1, bar(2))` is not a predicate). Also of note is the G1 query language's choices regarding strings -- double quotes are **always** used for strings, and unquoted and single-quoted symbols are **always** variables. This differs significantly from Prolog, which uses case to disambiguate between variables and atoms.

String Parser
-------------

The parser for strings is able to be a fairly traditional LALR parser, using [LALRPOP](https://github.com/lalrpop/lalrpop) as a parser generator and [Logos](https://github.com/maciejhirsz/logos) as a lexer generator. This parser is rather straightforward, so there's not much more to say about it here.

Proc Macro Parser
-----------------

The parser for the `query!()` macro is more complex, because it needs to operate on Rust tokens. So that macros don't need to break compatibility with future Rust syntax changes, procedural macros receive a `TokenStream` type, which is an iterator of `TokenTree`s.

A `TokenTree` is either a token (an identifier, literal, or piece of punctuation) or a bracket-delimited `TokenStream`. This is reasonably easy to parse with a hand-written recursive-descent parser, but it doesn't fit well with LALRPOP. The `g1_macros` crate therefore defines a `Token` type that represents a single token, with delimiters explicitly present.

For example, the Rust tokens

```rust
foo(bar, baz, _).
```

become the `TokenStream`

```rust
TokenStream::from(vec![
	TokenTree::Ident(Ident::new("foo", Span::call_site())),
	TokenTree::Group(Group::new(Delimiter::Parenthesis, TokenStream::from(vec![
		TokenTree::Ident(Ident::new("bar", Span::call_site())),
		TokenTree::Punct(Punct::new(',', Spacing::Alone)),
		TokenTree::Ident(Ident::new("baz", Span::call_site())),
		TokenTree::Punct(Punct::new(',', Spacing::Alone)),
		TokenTree::Ident(Ident::new("_", Span::call_site())),
	]))),
	TokenTree::Punct(Punct::new('.', Spacing::Alone)),
])
```

which in turn becomes the `Vec<Token>`

```rust
vec![
	Token::Ident(Ident::new("foo", Span::call_site())),
	Token::ParenOpen(Span::call_site()),
	Token::Ident(Ident::new("bar", Span::call_site())),
	Token::Punct(Punct::new(',', Spacing::Alone)),
	Token::Ident(Ident::new("baz", Span::call_site())),
	Token::Punct(Punct::new(',', Spacing::Alone)),
	Token::Hole(Span::call_site()),
	Token::ParenClose(Span::call_site()),
	Token::Punct(Punct::new('.', Spacing::Alone)),
]
```

Note that since we use Rust's lexer, the `query!()` proc macro will inherit e.g. Rust's string escapes (which are a superset of the ones the string parser's lexer supports). Additionally, quoted symbols are not supported, since they conflict with Rust's character literals.

Semantic Analysis
=================

Restrictions
------------

In order to maintain Datalog's properties, two restrictions hold for G1 queries. Both of the restrictions are based around ensuring the following statement is true:

> A Datalog program can be evaluated bottom-up and incrementally, in finite time.

### Positivity

The positivity restriction ensures a clause always computes a finite number of tuples of strings (i.e. without them containing variables).

Examples of violating clauses include:

```pro
// Disallowed, since this computes the set of all strings, which is infinite.
alwaysSucceeds(X).

// Disallowed, since the complement of a finite set is infinite.
color("red").
color("green").
color("blue").
notColor(X) :- !color(X).
```

It turns out there's a simple rule we can use to check this:

> Every variable that either appears in the head of the clause or in a negative call must also appear in a positive call.

Currently, a negative call is negated and a positive call is non-negated. This isn't true of all Datalog variants (nor of other Prolog-like languages) in general, but in the G1 query language this definition holds.

### Stratification

The stratification restriction ensures a clause can be evaluated in finite time, and gives an order for evaluating bottom-up, by disallowing some forms of recursion. We want to disallow clauses like:

```pro
// Inherently paradoxical.
paradox(X) :- !paradox(X).

// Could require infinite deductions.
foo(X) :- bar(X).
bar(X) :- foo(X).
```

However, we want to be able to preserve recursion like:

```pro
// A bit useless, but still well-defined.
foo(X) :- foo(X).

// This is well-defined, and even useful.
path(X, X) :- atom(X).
path(X, Z) :- edge(X, Y, _), path(Y, Z).
```

It turns out the procedure for ensuring recursion is well-behaved is fairly simple. Each clause name is assigned an index, and the recursion is judged to be well-behaved if:

-	If any clause with the name `i` calls the name `j` (including recursively), `i <= j`.
-	If any clause with the name `i` calls the negation of the name `j` (including recursively), `i < j`.

(As an implementation note: we define the names as signed integers, assigning only non-negative ones to user-defined predicates, and negative ones to built-in predicates.)

Implementation
--------------

Since we have multiple "first-level ASTs," we use the [visitor pattern](https://en.wikipedia.org/wiki/Visitor_pattern) to hide some of the more annoying bits (assigning indices to names, deduplicating strings, etc.).

These visitors directly assign stratification indices using [the `topological-sort` crate](https://crates.io/crates/topological-sort). It only supports `<` bounds (rather than `<=`), so a simple test for self-recursion is needed, which fails for negated self-recursion.

The positivity test is then easy to define on the resulting `VerifiedQuery` AST.
