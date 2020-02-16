+++
title = "StahlOS Forth: Errors"
draft = true

[taxonomies]
tags = ["stahl"]

[extra]
# comment_issue = 3
+++

In [StahlOS Forth](@/stahl/stahlos-forth.md), there are a variety of errors that can be encountered. For example, if the `+` word is executed when the stack is empty, there's no reasonable way to continue, so an error occurs. Currently, all errors are handled with the `panic` procedure ([impl](https://github.com/remexre/stahlos/blob/180befd900866e3378b41ffd03acea605f621e26/src/kernel-aarch64/panic.s)\). This procedure prints the cause of the panic, the string `"panic!"`, then halts the CPU.

However, when a REPL is being run by the Forth system directly, killing the system whenever a typo occurs is definitely overkill, especially if the REPL is being used to repair a system already in an unhealthy state. A better error-handling mechanism is therefore needed.

Previous Mechanism
------------------

In the last iteration of StahlOS (on amd64), each process' has associated with it a set of execution tokens for words that may need to be overwritten; namely, [`ABORT`](https://forth-standard.org/standard/core/ABORT), `BP` (breakpoint), [`EMIT`](https://forth-standard.org/standard/core/EMIT), and [`QUIT`](https://forth-standard.org/standard/core/QUIT)\. In practice, this wasn't useful, since every non-REPL process would use the same definitions for these words. Additionally, there's not a ton of free space left in the [current process table](https://github.com/remexre/stahlos/blob/180befd900866e3378b41ffd03acea605f621e26/doc/kernel/aarch64/abi.md#process-table), and I'd rather conserve it as much as possible.

Forth 2012 Exceptions
---------------------

The Forth 2012 spec [defines](https://forth-standard.org/standard/exception) a mechanism for error handling. It's fairly straightforward; there are two words `THROW` and `CATCH`. `CATCH` takes the address of code to execute, and wraps it such that `THROW` calls result in the execution completing.

For example:

```forth
: foo 1 2 3 THROW ;
: bar 4 5 6 ;

7 8 9
' foo CATCH .S
' bar CATCH .S
```

will print

```
<4> 7 8 9 3
<8> 7 8 9 3 4 5 6 0
```

Notably, the specification of `THROW` makes it unsafe to consume items on the data stack before `THROW`ing; the following reads from uninitialized memory.

```
: foo + 42 THROW ;
2 3 ' foo CATCH .S
```

With GForth on my machine, it prints `<3> 5 140418305966048 42` rather than the likely expected `<2> 5 42`.

Conditions-Inspired Exceptions
------------------------------

A third option would be to have a more Common Lisp-like handler mechanism, where the handler is passed to `CATCH` as an execution token, and invoked at the point `THROW` is, rather than unwinding before invoking the handler. This allows a handler to perform error recovery actions inline with the code.

Additional words `CONTINUE`, `RETURN-TO-CATCH`, etc. would probably be defined as well. A hypothetical example:

```forth
: handler ." caught error" CR .S CONTINUE ;
: foo + THROW ." after throw" CR ;
2 3 ' foo ' handler CATCH .S
```

The above would print:

```
caught error
<1> 5
after throw
<1> 5
```
