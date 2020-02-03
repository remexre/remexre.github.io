+++
title = "Notebook: Vulkan"

[taxonomies]
categories = ["notebook"]
tags = ["vulkan"]
+++

nova
====

goal:

-	type-safe
-	sync-safe
-	raii

biggest new abstraction: monad for commands on a command buffer

-	have an operator `merge : (M a, M b) -> M (a, b)` that makes commands ordering-independent
-	probably helpers `mergeAll : [M a] -> M [a]`, `mergeAll_ : [M ()] -> M ()`
-	in theory, nothing but `>>=` should require synchronization
-	consequently, discourage `>>=` -- maybe don't even define a `Monad` instance?
-	this would also allow a custom `>>` operator for subpasses
-	maybe want an explicit operator for secondary command buffers?

issue for command monad: resource synchronization

-	rust-style (or use rust) `&mut`?
-	would need to give the resource back... after the `>>=`
-	might make sense to make ops often be `a -o M a` instead of `a -> M ()`
-	this would allow typestates too: `T S1 -o M (T S2)`

### API

`Device : *`

Device also contains instance.

-	`make_device : Target t => t -o Device`

`Cmd : * -> *`

-	`pure : a -o Cmd a`
-	`and_then : (a -o Cmd b) -> Cmd a -o Cmd b`
-	`par : Cmd a -o Cmd b -o Cmd (a, b)`
-	`par_ : Cmd () -o Cmd () -o Cmd ()`
-	`run : Device -> Cmd a -o a`

`CmdBufUsage : *`

-	`OneTimeSubmit : CmdBufUsage`
-	`Reusable : CmdBufUsage`

`CmdBufTypeState : *`

-	`Initial : CmdBufTypeState`
-	`Recording : CmdBufUsage -> CmdBufTypeState`
-	`Executable : CmdBufUsage ->CmdBufTypeState`
-	`Pending : CmdBufUsage -> CmdBufTypeState`
-	`Invalid : CmdBufTypeState`

`Invalidatable : CmdBufTypeState -> Constraint`

-	`Invalidatable Initial`
-	`Invalidatable Recording`
-	`Invalidatable Executable`

`Resettable : CmdBufTypeState -> Constraint`

-	`Resettable Recording`
-	`Resettable Executable`
-	`Resettable Invalid`

`CmdBuf : CmdBufTypeState -> *`

-	`allocate : Device -> CmdBuf Initial`
-	`destroy : Resettable t => CmdBuf t -o Unit`
-	`begin : (t : CmdBufUsage) -> CmdBuf Initial -o CmdBuf (Recording t)`
-	`end : CmdBuf (Recording t) -o CmdBuf (Executable t)`
-	`submit : CmdBuf (Executable t) -o CmdBuf (Pending t)`
-	`waitComplete : CmdBuf (Pending Reusable) -o CmdBuf (Executable Reusable)`
-	`waitCompleteOne : CmdBuf (Pending OneTimeSubmit) -o CmdBuf Invalid`
-	`invalidate : Invalidatable t => CmdBuf t -o CmdBuf Invalid`
-	`reset : Resettable t => CmdBuf t -o CmdBuf Initial`

`Image : *`

-	`create : Device -> Image`
-	`destroy : Image -o ()`
