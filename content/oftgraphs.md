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

All operations on the database are STM transactions; see [STM in OftLisp]({{< relref "oftlisp-stm.md" >}}).

```
(new-graph-db) => graph-db

(add-node graph-db node-name) => stm bool
(rm-node  graph-db node-name) => stm bool
(get-node-prop graph-db node-name prop) => stm value
(put-node-prop graph-db node-name prop value) => stm bool

(get-directed-edge graph-db from-node to-node edge-type) => stm value
(put-directed-edge graph-db from-node to-node edge-type value) => stm bool
(rm-directed-edge  graph-db from-node to-node edge-type) => stm bool

(query-nodes graph-db node-query) => stm node-query-result
(query-edges graph-db edge-query) => stm edge-query-result
```

Queries are of the form:

```
node-query = ('has-prop prop)
           | ('prop-eq  prop value)
prop = symbol

edge-query = ('from node-name)
           | ('to   node-name)
           | ('type edge-type)
           | ('and edge-query...)
           | ('or  edge-query...)
		   | ('not edge-query)
edge-type = symbol
```
