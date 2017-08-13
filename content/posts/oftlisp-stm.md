+++
date = "2017-08-13"
draft = true
tags = ["Concurrency", "OftLisp"]
title = "STM in OftLisp"
+++

# API

The OftLisp STM library is based on Haskell's [stm package](https://hackage.haskell.org/package/stm).

```oftlisp
(atomically (fn () -> stm 'a)) => 'a

(stm 'a) => stm 'a
(stm-var 'a) => stm-var 'a
(stm-read (stm-var 'a)) => stm 'a
(stm-write (stm-var 'a) 'a) => stm ()
```

`stm` is also a [monad]({{< relref "oftlisp-monads.md" >}}), allowing for simple composition of `stm` transactions.
This gives it the `bind` method:

```oftlisp
(bind (stm 'a) (fn ('a) -> stm 'b)) => stm 'b
```

There are also two new macros defined, `defvar` and `transaction`:

```oftlisp
(defvar name initial-value)
(transaction exprs...)
```

`(defvar x y)` is equivalent to `(def x (stm-var y))`, and is used to define a mutable variable.
(STM is the only built-in mechanism for mutation, and in the contention-free case, STM's speed hit is negligible.)

`transaction` is used to create a new transaction. Transactions are niliadic functions which return a `stm 'a`.
Due to `stm`'s monadic nature, `transaction` is actually just `do`-notation.

# Example

Here is the classic bank transfer example from [Beautiful Concurrency](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/beautiful.pdf):

```oftlisp
(defvar alice-balance 0)
(defvar bob-balance 0)

(defn transfer (amount from to)
  (transaction
    (<- from-bal (stm-read from))
	(stm-write from (- from-bal amount))

	(<- to-bal (stm-read to))
	(stm-write to (+ to-bal amount))))

(defn main ()
  (atomically (transfer 100 alice-balance bob-balance))
  (atomically (transfer 45 bob-balance alice-balance))
  (atomically (transaction
    (<- alice (stm-read alice-balance))
    (<- bob (stm-read bob-balance))

	(println "Alice's Balance: " alice)
	(println "Bob's Balance: " bob)

	(stm nil)))
```
