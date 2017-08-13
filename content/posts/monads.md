+++
date = "2017-08-04"
draft = true
tags = ["Monads", "Theory"]
title = "Monads: Another Explanation"
+++

# What is a Monad?

> Once you finally understand monads, you lose the ability to explain monads to others.
>
> -- Douglas Crockford

This tutorial walks through the definition of a monad using one of the simplest useful monads, `Maybe`.

Every monad is also an applicative functor, and every applicative functor is also a functor.

Note to purists: Some liberty is taken with the definitions of the typeclasses, to remove functions irrelevant to discussion.
The essence of the typeclasses remains the same.

## Functors

Simply put, a functor is a container for values.

The definition of functor is:

```haskell
-- This defines a typeclass called Functor
class Functor f where
  -- Which has one function, fmap, of type ((a -> b) -> f a -> f b)
  fmap :: (a -> b) -> f a -> f b
```

Note that `fmap` is also written as `(<$>)`; that is, with `<$>` used as an infix operator.
That is, `fmap f x` is equivalent to `f <$> x`.

Essentially, this states that a functor is anything that can be `fmap`ped.
Since the function type constructor is right-associative, it can also be written `(a -> b) -> (f a -> f b)`.
This shows a better way of thinking of fmap: it transforms a function `a -> b` to `f a -> f b`.

In the case of `Maybe`, fmap could be written:

```haskell
fmap :: (a -> b) -> (Maybe a -> Maybe b)
fmap f = f'
  where f' (Just x) = Just (f x)
        f' Nothing = Nothing
```

This is more traditionally factored as:

```haskell
fmap :: (a -> b) -> Maybe a -> Maybe b
fmap f (Just x) = Just (f x)
fmap f Nothing = Nothing
```

The functorality of `Maybe` allows for a "normal" function to run on `Maybe`s instead:

```haskell
-- An example function; any function works.
f :: String -> Int
f s = 1 + length s

f' :: Maybe String -> Maybe Int
f' = fmap f

x :: Maybe String
x = f "foo"
-- x = 4

y :: Maybe Int
y = f' (Just "foo")
-- y = Just 4

z :: Maybe Int
z = f' Nothing
-- z = Nothing
```

## Applicative Functors

An applicative functor is the next step towards monad-ness.
It is defined as:

```haskell
class Functor f => Applicative f where
  pure :: a -> f a
  -- This defines an infix operator <*>, so you can write e.g. f <*> x
  (<*>) :: f (a -> b) -> f a -> f b
```

`pure` simply embeds a "pure" calculation (that is, a non-applicative one) into an applicative container.

An applicative functor can be used when both the function and the value may be in a container.
For example,

```haskell
f :: Maybe (Int -> String)
f = Just (show . (+1))

g :: Maybe (Int -> String)
g = Nothing

x :: Maybe Int
x = Just 5

y :: Maybe Int
y = Nothing

a :: Maybe String
a = f <*> x
-- a = Just "6"

b :: Maybe String
b = f <*> y
-- b = Nothing

c :: Maybe String
c = g <*> x
-- c = Nothing

d :: Maybe String
d = g <*> y
-- d = Nothing
```

Due to Haskell's currying, this can also be used to use multi-argument functions in functors:

```haskell
f :: Int -> Int -> String
f a b = concat [a', " + ", b', " = ", c']
  where a' = show a
        b' = show b
		c' = show c
		c = a + b

x :: String
x = f 3 8
-- x = "3 + 8 = 11"

y :: Maybe String
y = f <$> Just 3 <*> Just 8
-- y = Just "3 + 8 = 11"
```

This works because:

```haskell
f :: Int -> Int -> String
f <$> Just 3 :: Maybe (Int -> String)
f <$> Just 3 <*> Just 8 :: Maybe String
```

Almost every useful functor is an applicative functor as well.

## Monads

Just a recap before taking the plunge:

 - A functor allows boxing up a value and using it with a function.
 - An applicative functor is a functor whose functions can be boxed up too.

A monad is defined as:

```haskell
class Applicative m => Monad m where
  (>>=) :: m a -> (a -> m b) -> m b
  return :: a -> m a
```

`return` is equivalent to `Applicative`'s `pure`, and exists for historical reasons (`Monad` was introduced to Haskell before `Applicative`).

The type signature of `(>>=)` (also known as *bind*) is a bit hard to read, and I believe much of the bad reputation monads have is because of this.
`(>>=)` takes a boxed value, and a function that transforms and boxes a value, resulting in the boxed value.
That is, it removes the box from the input, and performs a computation.

The primary innovation `Monad` adds over `Applicative` is ordering.
This is most critical in a lazy language (such as Haskell), but remains useful in a strict language, when composing functions that return monadic results.

Monads are most easily used in do-notation, which allows the free intermixing of monadic (`<-`) and non-monadic (`let`) code:

```haskell
getFoo :: Maybe Int
getBar :: Maybe String

baz :: Maybe Int
baz = do
  foo <- getFoo
  bar <- getBar
  let bar' = length bar
  return (foo * bar')
```

`baz` is equivalent to:

```haskell
baz' :: Maybe Int
baz' = getFoo >>= (\foo ->
         getBar >>= (\bar ->
		   let bar' = length bar
		   in return (foo * bar')))
```

As you can see, the `do`-notation form is a lot easier to read!
It is also clear that the definition of `(>>=)` has control over whether the evaluation of `getFoo` and `getBar` can be delayed.

# Where are monads useful?

The traditional answer involves preserving order of I/O operations while still having laziness.
However, unless you're using Haskell, this isn't horribly useful.

I see three highly useful monads for a strict language:

## Maybe

`Maybe` is the monad I've been using throughout this post.
It should be familiar (perhaps under the name `Nullable`, `Option`, or `Optional`).

It is defined as:

```haskell
data Maybe a
  = Just a
  | Nothing
```

It's essentially a nullable value.
Did the proofreaders get this far? Mention code samples having weird margins if you did.
Syntax similar to do-notation already exists in some languages as the "Elvis" operator.
For example, the C# code:

```csharp
// As an object type, string is implicitly possibly-null.
int? foo(string bar) {
	return bar?.Length;
}
```

bears a striking resemblance to the Haskell:

```haskell
foo :: String -> Int
foo bar = do
  bar' <- bar
  return (length bar')
```

## Result

`Result` is used for error handling without exceptions.
It is also known as `Either`.

It is defined as:

```haskell
data Result e a
  = Ok a
  | Err e
```

Note that while `Result` is not a monad, `Result e` is for any `e`.

## Async

The `Async` monad is equivalent to `Future`s or `Promise`s in other languages, but its monadic formulation allows for additional flexibility.

If you're a JavaScript dev, the `Async` monad will already be familiar to you by the name of `Promise`.
`Promise.then` is essentially the same as `(>>=)` (the main difference being that `Promise.then` works for both `a -> b` and `a -> Async b`, as JavaScript is a dynamic language):

```javascript
function wait(time, returnValue) {
	return new Promise(function(resolve, reject) {
		setTimeout(function() {
			resolve(returnValue);
		}, time);
	});
}

function asyncPrint(value) {
	const out = console.log(value);
	return Promise.resolve(out);
}

const out = wait(1000, "one second passed")
	.then(s => s.length)
	.then(asyncPrint);
// out == undefined
```

versus

```haskell
wait :: Int -> a -> Async a
asyncPrint :: Int -> Async ()

out :: Async ()
out = wait 1000 "one second passed" >>= (\s -> length s) >>= asyncPrint
```

If C# is more to your liking, note that `async` and `await` are also equivalent to `do`-notation:

```csharp
async int getFoo() {
	...
}
async String getBar() {
	...
}

async int baz() {
	int foo = await getFoo();
	String bar = await getBar();
	int bar2 = foo + bar.length();
	return foo * bar2;
}
```

versus

```haskell
getFoo :: Async Int
getBar :: Async String

baz :: Async Int
baz = do
  foo <- getFoo
  bar <- getBar
  let bar' = foo + length bar
  return (foo * bar')
```

# Why monads?

## A Comparison with Rust

Rust has `Maybe a`, `Result e a`, and `Async a` (as `Option<T>`, `Result<T, E>`, and `Future<Item=T, Error=E>`), but hasn't felt the need to unite the three.
Haskell that would be written:

```haskell
getFoo :: TheMonadUnderDiscussion Int
getBar :: TheMonadUnderDiscussion String

baz :: TheMonadUnderDiscussion Int
baz = do
  foo <- getFoo
  bar <- getBar
  let bar' = foo + length bar
  return (foo * bar')
```

In Rust, this might be written for `Maybe`/`Option` as:

```rust
// Using the try_opt! macro
fn baz_option_macro() -> Option<usize> {
	let foo = try_opt!(get_foo());
	let bar = try_opt!(get_bar());
	let bar2 = foo + bar.len();
	Some(bar2) // Some(x) in Rust is the same as (Just x) in Haskell
}

// Without try_opt!
fn baz_option_match() -> Option<usize> {
	let foo = if let Some(foo) = get_foo() {
		foo
	} else {
		return None;
	};

	let bar = if let Some(bar) = get_bar() {
		bar
	} else {
		return None;
	};

	let bar2 = foo + bar.len();
	Some(bar2)
}

// Or alternatively:
fn baz_option_deep() -> Option<usize> {
	match get_foo() {
		Some(foo) => match get_bar() {
			Some(bar) => Some(foo + bar.len()),
			None => None,
		},
		None => None,
	}
}

// Or:
fn baz_option_methods() -> Option<usize> {
	get_foo().and_then(|foo| {
		get_bar().map(|bar| {
			foo + bar.len()
		})
	})
}
```

The first option, using a macro, is most convenient (in my opinion).
In a totally shocking twist, it's very close to do-notation.

Some in the Rust community also prefer the last formulation.
This is possibly because the type signature of `(>>=)` is equivalent to that of `.and_then()`, and `fmap`'s is likewise like `.map()`.

Next, the case where the result is a `Result`.
For the purposes of this code sample, an imaginary `Error` type will be used.

```rust
fn baz_result_do() -> Result<usize, Error> {
	let foo = get_foo()?;
	let bar = get_bar()?;
	let bar2 = foo + bar.len();
	Ok(bar2)
}
fn baz_result_bind() -> Result<usize, Error> {
	get_foo().and_then(|foo| {
		get_bar().map(|bar| {
			foo + bar.len()
		})
	})
}
```

The bodies of the `baz_option_methods` and `baz_result_bind` functions are actually the same!
This is due to `Option` and `Result` sharing many methods (those needed to provide a monadic interface, essentially).
The additional variations used for `Option` could be used here again, but they are awkward at best.

The `baz_option_macro` and `baz_result_do` functions are also very similar, but with `try_opt!(expr)` becoming `expr?`.
In the past, `try!(expr)` would have been used instead of `expr?`.
Due to the common usage of this pattern, however, the `expr?` syntax was added.
In the future, the `expr?` syntax will be extended to work with `Option` as well.

Finally, the case of `Future`. This is a bit more complicated, since `Future` is a trait (Rust's version of a typeclass) instead of a concrete type. For this reason, we return a `Box<Future<T, E>>`, which allows for an unknown `Future` to be returned.

Also of note is that `Future` includes `Result`-like functionality, even when it never resolves to an error.
This is addressed later, but make a note of it now.

```rust
fn baz_future() -> BoxFuture<usize, Error> {
	get_foo().and_then(|foo| {
		get_bar().map(|bar| {
			foo + bar.len()
		})
	}).boxed()
}
```

Well, that looked familiar again!
`Future` again has many of the monadic methods that `Option` and `Result` share.
However, it's still not possible to write "sequential-looking" code with `Future`s; a TODO.

## Consistency

One of the advantages of having a single `Monad` typeclass to encapsulate `Option`, `Result`, and `Future` is simply the consistency it provides.
Rust currently shares `map`, `and_then`, `or_else`, etc. as common functions on `Option`, `Result`, and `Future`, but having a trait for all of them would allow using do-notation uniformly.
This has been proposed for Rust, but there is currently no RFC for do-notation to be added to the language.

## Composition

The biggest advantage of a unified monadic interface is that the composition of two monads is also a monad.
This is less obviously useful in Rust, where `Future` comes with `Result` baked in.
For the following illustrative example, assume `Async` is a variation on `Future` that does not have an `Error` associated type:

```rust
fn next_user_input() -> Async<String> { ... }

type Fetch<T> = Result<Async<Result<T, ReadError>>, ConnectError>;
fn fetch(resource_name: String) -> Fetch<String> { ... }

type Parse<T> = Result<T, ParseError>;
fn parse_foo_list(s: String) -> Parse<Vec<Foo>> { ... }

fn barrest_foo(l: Vec<Foo>) -> Option<Foo> { ... }

enum GetFooError {
	Connect(ConnectError),
	Read(ReadError),
	Parse(ParseError),
}

// This is the code sample we're judging:
fn select_a_foo() -> Async<Result<Option<Foo>, GetFooError>> {
	next_user_input().and_then(|resource_name| {
		match fetch(resource_name) {
			Ok(f) => f.and_then(|r| {
				match r {
					Ok(body) => match parse_foo_list(body) {
						Ok(foos) => Ok(barrest_foo(foos)),
						Err(e) => Err(GetFooError::Parse(e)),
					},
					Err(e) => Err(GetFooError::Fetch(e)),
				}
			}),
			Err(e) => Async::now(Err(GetFooError::Connect(e))),
		}
	})
}
```

Not pretty!
At least part of the blame lies with the error conversions; these can (and should) be sugared away.
With the errors magically converted, we get:

```rust
fn select_a_foo_sugared_conversions() -> Async<Result<Option<Foo>, GetFooError>> {
	next_user_input().and_then(|resource_name| {
		fetch(resource_name).and_then(|r| {
			r.and_then(|body| {
				parse_foo_list(body).map(|foos| {
					barrest_foo(foos)
				})
			})
		})
	})
}
```

This is a bit better, but still not great.
Let's see how Haskell does it.

```haskell
nextUserInput :: Async String

type Fetch a = EitherT ConnectError AsyncT (Either ReadError a)
fetch :: String -> Fetch String

type Parse a = Either ParseError a
parseFooList :: String -> Parse [Foo]

barrestFoo :: [Foo] -> Maybe Foo

data GetFooError
  = Connect ConnectError
  | Read ReadError
  | Parse ParseError

selectAFoo :: AsyncT (EitherT GetFooError Maybe) Foo
selectAFoo = do -- TODO Fixme
  resourceName <- nextUserInput
  body <- lift (fetch resourceName)
  foos <- lift (parseFooList body)
  barrestFoo foos
```

## Extensibility

There are other useful monads, such as the Reader monad (which simplifies scoped resource management).
Having a simple, fixed interface for which `do`-notation and helpers such as `sequence` can operate upon eases the burden of defining these other monads.
In addition, a generic "monad cons" would be useful for defining monad stacks, rather than monad transformers.

TODO
