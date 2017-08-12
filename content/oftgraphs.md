+++
date = "2017-08-11"
draft = true
tags = ["Databases", "OftLisp"]
title = "An OftLisp Graph Database"
+++

For many problems, graph databases are as useful or more useful than table-based relational databases.
`oftgraphdb` is a mutable, parallel, in-memory database in and for OftLisp.
TODO blather on for the rest of an introduction.

In `oftgraphdb`, a node is a symbol with values associated with it, similar to Common Lisp's symbol plists.
Edges are directed, and hold a single symbol and value.

All operations on the database are STM transactions; see {{< relref "

```oftlisp
(add-node db name) => stm bool
(rm-node db name) => stm bool
(put-node-prop TODO)

(get-directed-edge db from-node to-node edge-type) => stm value
(put-directed-edge db from-node to-node edge-type value) => stm bool
(rm-directed-edge db from-node to-node edge-type) => stm bool
```
