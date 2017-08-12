+++
date = "2017-08-11"
draft = true
tags = ["databases", "oftlisp"]
title = "oftdb: A Graph Database"
+++

For many problems, graph databases are as useful or more useful than table-based relational databases.
`oftdb` is a mutable, parallel, in-memory database in and for OftLisp.
TODO blather on for the rest of an introduction.

In `oftdb`, a node is a symbol with values associated with it, similar to Common Lisp's symbol plists.
Edges are directed, and hold a single symbol and value.

```oftlisp
(get-directed-edge db from-node to-node edge-type) => stm value
(put-directed-edge db from-node to-node edge-type edge-value) => stm bool
(rem-directed-edge db from-node to-node edge-type) => stm bool
```
