+++
date = 2018-12-05
tags = ["Rust"]
title = "Passing Ownership Up in Rust"
+++

# Introduction

Sometimes, we want to be able to return an object, alongside its owner. For example,

```rust
enum Foo<'a> {
	Leaf(&'a Bar),
	Branch(Box<Foo<'a>>, Box<Foo<'a>>),
}

struct Bar {
  	name: String,
  	weight: usize,
}
```

If there are many more `Foo` leaves than distinct instances of `Bar`, this approach makes a lot of sense -- we can allocate the `Bar`s in a single `Vec` and just have the `Foo`s own instances of them, which is much better for cache usage.

However, if we want to have a function that returns both of these, we're in a bit of a pickle:

```rust
fn load_foo<P: AsRef<Path>>(path: P) -> (Vec<Bar>, Foo<'uhhhh_those_bars_before_me>) {
	// ...
}
```

The solution I'm using is this:

```rust
fn load_foo<P: AsRef<Path>>(path: P) -> (Vec<Bar>, impl FnOnce(&[Bar]) -> Foo) {
    let (bars, foo_tree) = load_foo_tree(path);
	(bars, move |bars| foo_tree.add_bar_refs(bars))
}

fn load_foo_tree<P: AsRef<Path>>(path: P) -> (Vec<Bar>, FooTree) {
    // ...
}

enum FooTree {
    Leaf(usize),
	Branch(Box<FooTree>, Box<FooTree>),
}

impl FooTree {
	fn add_bar_refs<'a>(self, bars: &'a [Bar]) -> Foo<'a> {
		match self {
			FooTree::Leaf(i) => Foo::Leaf(&bars[i]),
			FooTree::Branch(l, r) => Foo::Branch(l.add_bar_refs(bars), r.add_bar_refs(bars)),
		}
	}
}
```

A warning if you try to use this in real life: as far as I can tell, in rustc 1.30.1, it's not possible to return a closure for the function in `Result<(T, impl FnOnce(&U) -> V), E>`. Thanks to `talchas` on the `#rust` IRC for showing me this hack:

```rust
fn load_foo<P: AsRef<Path>>(path: P) -> Result<(Vec<Bar>, impl FnOnce(&[Bar]) -> Foo), Error> {
	fn hack(tree: FooTree) -> impl FnOnce(&[Bar]) -> Foo {
		move |bars| foo_tree.add_bar_refs(bars)
	}

    let (bars, foo_tree) = load_foo_tree(path)?;
	Ok((bars, hack(foo_tree)))
}

fn load_foo_tree<P: AsRef<Path>>(path: P) -> Result<(Vec<Bar>, FooTree), Error> {
    // ...
}
```
