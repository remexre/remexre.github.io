+++
title = "Notebook: Vulkan"

[taxonomies]
categories = ["notebook"]
tags = ["vulkan"]
+++

nova
====

-	goal:
	-	type-safe
	-	sync-safe
	-	raii
-	biggest new abstraction: monad for commands on a command buffer
	-	have an operator `merge : (M a, M b) -> M (a, b)` that makes commands ordering-independent
	-	probably helpers `mergeAll : [M a] -> M [a]`, `mergeAll_ : [M ()] -> M ()`
	-	in theory, nothing but `>>=` should require synchronization
	-	consequently, discourage `>>=` -- maybe don't even define a `Monad` instance?
	-	this would also allow a custom `>>` operator for subpasses
-	issue for command monad: resource synchronization
	-	rust-style (or use rust) `&mut`?
	-	would need to give the resource back... after the `>>=`
	-	might make sense to make ops often be `a -o M a` instead of `a -> M ()`
	-	this would allow typestates too: `T S1 -o M (T S2)`
