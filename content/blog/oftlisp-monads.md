+++
date = 2017-08-09
draft = true
tags = ["Monads", "OftLisp"]
title = "Monads in OftLisp"
+++

**NOTE**: If you're unfamiliar with monads, check this out: [Monads: Another Explanation]({{< relref "monads.md" >}})

# Overview

Monads in OftLisp are defined using [the object system]({{< relref "oftlisp-oop.md" >}}).
Any class that is a monad should be defined like:

```oftlisp
(defclass example-monad ()
  (var value))

(defmethod bind ((m example-monad) f)
  (f (value m)))
```

This is equivalent to the Haskell:

```haskell
data ExampleMonad a = ExampleMonad a

instance Monad ExampleMonad where
  (>>=) (ExampleMonad value) f = f value
  return = ExampleMonad
```
