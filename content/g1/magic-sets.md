+++
title = "G1: The Magic Sets Transformation"
draft = true

[taxonomies]
tags = ["g1", "rust"]

[extra]
# comment_issue = 4
+++

*This post assumes you've read the [previous one in the series](@/g1/2020-02-01-query-lang.md).*

One advantage of Datalog over some other query languages is the ease by which it can be computed incrementally and bottom-up. This allows for a fairly simple async IO implementation of queries with limits; in pseudo-Rust:

```rust
let mut results = QueryResults::new(&query);
let (done_send, done_recv) = oneshot();
read_db_to_stream()
	.take_until(done_recv)
	.for_each(|tuple| {
		results.insert(tuple);
		if results.len() > query.max_results {
			done_send.send(());
		}
	}).await;
```

In theory, this results in no IO wasted by continuing to traverse after we have the minimum required to satisfy the query. In practice, this wastes an enormous amount of IO -- it's reading the whole database in, every query!
Even if a more efficient means for pulling tuples from disk were used, there would still be computation wasted: tuples are computed without regard to whether they're useful in the producing results.

The Magic Sets transformation works to ensure that only necessary tuples are computed, by creating and using specialized clauses when possible.

For example, take the query:

```pro
friend(Me, You) :-
	edge(Me, You, "friend").

friendOfFriend(Me, You) :-
	friend(Me, Other),
	friend(Other, You).

sameAtom(X, X) :- atom(X).

frenemyName(Me, YourName) :-
	friendOfFriend(Me, You),
	! friend(Me, You),
	! sameAtom(Me, You),
	attr(You, "name", YourName).

?- frenemyName("59760f34-eee0-44e2-9358-f48d46c686ee", YourName).
```

This can be optimized to:

```pro
friend(Me, You) :-
	edge(Me, You, "friend").

sameAtom_bb("59760f34-eee0-44e2-9358-f48d46c686ee", "59760f34-eee0-44e2-9358-f48d46c686ee") :-
	atom("59760f34-eee0-44e2-9358-f48d46c686ee").

friend_bf(You) :-
	edge("59760f34-eee0-44e2-9358-f48d46c686ee", You, "friend").

friendOfFriend_bf(You) :-
	friend_bf(Other),
	friend(Other, You).

frenemyName_bf(YourName) :-
	friendOfFriend_bf(You),
	! friend_bf(You),
	! sameAtom_bb("59760f34-eee0-44e2-9358-f48d46c686ee", You),
	attr(You, "name", YourName).

?- frenemyName_bf(YourName).
```
