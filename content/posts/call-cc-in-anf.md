+++
date = "2017-08-30"
draft = true
tags = ["Theory"]
title = "`call/cc` in A-Normal Form"
+++

# Introduction

`call/cc` is an function in Scheme that is possibly the most advanced control-flow operator in *any* language.

It can be used to implement [exceptions](http://matt.might.net/articles/implementing-exceptions/), [cooperative threading](http://matt.might.net/articles/programming-with-continuations--exceptions-backtracking-search-threads-generators-coroutines/), and many other things usually thought of as complicated primitives.

If you are not familiar with `call/cc`, the second link above can provide a decent tutorial.
The rest of this post will assume you understand `call/cc` and continuations.

## Continuation-Passing Style

One common intermediate form for compiling functional languages is continuation-passing style (CPS), in which each construct explicitly passes control to a continuation.
This makes the language being compiled much simpler, as most explicit control constructs are converted into function calls.

```oftlisp
;;; Example Code Snippet

(defn average (p q)
  (/ (+ p q) 2))

(defn max (p q)
  (if (> p q) p q))

(defn highest-average (x y z)
  (def a (average x y))
  (def b (average y z))
  (def c (average x z))
  (max (max a b) c))
```

```oftlisp
;;; Continuation-Passing Style Translation

(def average (fn (p q k)
  (+ p q (fn (tmp)
    (/ tmp 2 k)))))

(def max (fn (p q k)
  (> p q (fn (tmp)
    (if tmp
      (k p)
      (k q))))))

(def highest-average (fn (x y z k)
  (average x y (fn (a)
    (average y z (fn (b)
      (average x z (fn (c)
        (max a b (fn (tmp)
          (max tmp c k)))))))))))
```

The simplicity afforded by continuation-passing style allows many optimizations' implementations to be much simpler as well.

## A-Normal Form

A-Normal Form (ANF) was created as a simplification of CPS, which is easier to work with, involving fewer passes.
The A-Normal Form version of the above would be:

```oftlisp
(def average (fn (p q)
  (let (tmp (+ p q))
    (/ tmp 2))))

(def max (fn (p q)
  (let (tmp (> p q))
    (if tmp p q))))

(def highest-average (fn (x y z)
  (let (a (average x y))
    (let (b (average y z))
      (let (c (average x z))
	    (let (tmp (max a b))
		  (max tmp c)))))))
```

As you can see, this is essentially equivalent to the CPS version, but without the explicit continuation parameter, and using `let`s to bind variables instead of `lambda`s.

# Implementing `call/cc` in Continuation-Passing Style

Although `call/cc` is usually difficult to implement, it is trivial in continuation-passing style:

```oftlisp
(defn f (x)
  (+ (call/cc g) x))
```

```oftlisp
(def f (fn (x k)
  (def tmp-func (fn (tmp k2)
    (+ tmp x k2)))
  (g tmp-func tmp-func)))
```

In direct form, this would typically involve having to perform analysis on `g`.
