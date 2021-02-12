+++
title = "SilvIR: Definition, Draft 1"
draft = true

[taxonomies]
tags = ["silvir"]

[extra]
comment_issue = 11
+++

*This post assumes you've read the [previous one in the series](@/silvir/2021-02-10-introduction.md).*

As covered in the previous post, Silver has a bunch of features that require some trickiness in SilvIR to make implementable.
I'll dump the full grammar, then go over it in pieces.

```
Literal ::= Int
         |  String

PrimPattern ::= varPat(LocalName)
             |  litPat(Literal)
             |  anyPat

Pattern ::= recordPat(Map<String, PrimPattern>)
         |  treeOrTermPat(ProdName, List<PrimPattern>)
         |  primPat(PrimPattern)

IsChildDecorable ::= childIsDecorable
                  |  childIsntDecorable

Expr ::= local(LocalName)
      |  global(GlobalName)
      |  lit(Literal)
      |  let(LocalName, Expr, Expr)
      |  letrec(Map<LocalName, Expr>, Expr)
      |  lam(List<LocalName>, Expr)
      |  call(Expr, List<Expr>)
      |  error(Expr)
      |  thunk(Expr)
      |  force(Expr)
      |  case(Expr, List<Pair<Pattern, Expr>>)
      |  pureForeign(String, List<Expr>)
      |  impureForeign(String, List<Expr>)
      |  makeRecord(Map<String, Expr>)
      |  getRecordMember(String, Expr)
      |  cons(ProdName, List<Pair<IsChildDecorable, Expr>>)
      |  getChild(Nat, Expr)
      |  getAttr(AttrName, Expr)
      |  setAttr(AttrName, Expr, Expr, Expr)
      |  combineAttr(AttrName, Expr, Expr, Expr, Expr)
      |  copyTree(Expr)
      |  decorate(Expr, Map<AttrName, Expr>)
      |  undecorate(Expr)

Priority ::= Nat

TopLevelItem ::= globalDecl(GlobalName, Expr)
              |  prodDecl(ProdName, NTName)
	      |  defaultProdBodyDecl(NTName, Priority, LocalName, Expr)
	      |  prodBodyDecl(ProdName, Priority, LocalName, Expr)

Program ::= Set<TopLevelItem>
```

## `Literal`s

```
Literal ::= Int
         |  String
```

Literals are used in a few places in the grammar; they are a subset of the runtime values that exist.
Runtime values also include functions (which are constructed with `lam`), thunks (which are constructed with `thunk`), records (which are constructed with `makeRecord`), terms (which are constructed with `cons`), and trees (which are constructed with `decorate`).

## `Pattern`s

```
PrimPattern ::= varPat(LocalName)
             |  litPat(Literal)
             |  anyPat

Pattern ::= recordPat(Map<String, PrimPattern>)
         |  treeOrTermPat(ProdName, List<PrimPattern>)
         |  primPat(PrimPattern)
```

Patterns in SilvIR are restricted to "simple patterns," which disallow nested patterns.
SilvIR patterns also do *not* interact with forwarding in any way; there will be later discussion on this.

Note that `recordPat` implements a "subset match"; fields not present in the pattern are ignored.
As an example, the following expression evaluates to `1`:

```
case(makeRecord({ "a" = lit(1), "b" = lit(2) }),
  [ (recordPat({ "a" = varPat("x") }), local("x"))
  , (anyPat, lit(3))
  ])
```

Everything else in patterns should have fairly intuitive semantics.

## `Expr`s and `TopLevelItem`s, the FP-looking parts

```
Expr ::= local(LocalName)
      |  global(GlobalName)
      |  lit(Literal)
      |  let(LocalName, Expr, Expr)
      |  letrec(Map<LocalName, Expr>, Expr)
      |  lam(List<LocalName>, Expr)
      |  call(Expr, List<Expr>)
      |  error(Expr)
      |  thunk(Expr)
      |  force(Expr)
      |  case(Expr, List<Pair<Pattern, Expr>>)
      |  pureForeign(String, List<Expr>)
      |  impureForeign(String, List<Expr>)
      |  makeRecord(Map<String, Expr>)
      |  getRecordMember(String, Expr)
      |  ...

TopLevelItem ::= globalDecl(GlobalName, Expr)
              |  ...

Program ::= Set<TopLevelItem>
```

Most of what appears here should look "fairly normal" for a dynamically-typed, call-by-value, functional language with multi-argument functions and optional laziness.
(Well, I guess I said "tastes like Scheme" in more words...)

SilvIR is a call-by-value language, but supports thunks as a built-in type in order to support Silver's demand-driven attribute evaluation strategy.
Thunks are created with the `thunk` AST node, but also result from using `global` to access global variables, and `local` to access variables bound by a `letrec`.
This is because laziness is also used to implement circular/recursive values, which one can create with both global bindings and letrec-created bindings.

Calls to foreign functions are split into "pure" and "impure" versions.
Essentially, a call is considered pure if there is no non-UB way for the function to exhibit side effects, *including non-termination*.
This gives the optimizer leeway to aggressively transform, duplicate, or eliminate calls to these functions.
Examples of pure foreign functions are arithmetic operators on integers, string concatenation, and `reflect`.
Examples of impure foreign functions are `genInt` and `error` (though, `error` has its own AST node to facilitate debugger integration).

At program startup, a global environment is established from the top-level items.
The expression `call(force(global("main")))` is then evaluated.

## `Expr`s and `TopLevelItem`s, the attribute-grammar-specific parts

```
Expr ::= ...
      |  cons(ProdName, List<Pair<IsChildDecorable, Expr>>)
      |  getChild(Nat, Expr)
      |  getAttr(AttrName, Expr)
      |  setAttr(AttrName, Expr, Expr, Expr)
      |  combineAttr(AttrName, Expr, Expr, Expr, Expr)
      |  copyTree(Expr)
      |  decorate(Expr, Map<AttrName, Expr>)
      |  undecorate(Expr)

IsChildDecorable ::= childIsDecorable
                  |  childIsntDecorable

TopLevelItem ::= ...
              |  prodDecl(ProdName, NTName)
	      |  defaultProdBodyDecl(NTName, Priority, LocalName, Expr)
	      |  prodBodyDecl(ProdName, Priority, LocalName, Expr)

Priority ::= Nat
```

The attribute-grammar-specific parts of SilvIR are the complicated part with potentially-controversial semantics, so this might be unclear.

TODO: copy-paste tree vs term here

Undecorated terms can be constructed with the `cons` expression.
It takes the name of the production the value belongs to (sometimes referred to as the tag) and a list of arguments, as well as a flag describing whether the child is decorable.
This flag (formerly, misleadingly, known as `IsChildDeclaredDecorated`) determines whether the child will be traversed at tree-construction time.
This is effectively a single bit of type information; in the future, SilvIR may be changed to provide this information via `prodDecl` instead.
Most nonterminal types should be declared `childIsDecorable`.
Examples of types for which this should be `childIsntDecorable` are `Integer` (since integers aren't nonterminal types), `Decorated Foo` (since references to other trees shouldn't be redecorated), and skolem variables (since these may be instantiated to one of the former).
If the exact semantics of this are unclear, they should hopefully become more clear later, when the execution semantics are gone over.

`getChild` simply reads a child from a term or tree.
It's UB to read a child that doesn't exist, etc, etc.

`getAttr` reads an attribute off of a tree.

`setAttr` and `combineAttr` are used at tree-construction time to write attributes to a tree.
`setAttr(attr, tree, value, next)` evaluates to the same value `next` evaluates to, after performing the side effect of setting the attribute `attr` on the tree `tree` to the value that results from evaluating `value`.
This possibly replaces a previous value of the attribute.
`combineAttr(attr, tree, value, func, next)` is similar, and is used to implement collection attributes.
If `attr` was already set on `tree`, it sets it to the result of evaluating `call(func, getAttr(attr, tree), value)`.
If `attr` was not already set on `tree`, it sets it to the result of evaluating `value`.
This whole `combineAttr` expression then evalutes to the result of evaluating `next`.

`copyTree` simply copies a tree, so mutations can be made on it without disturbing the original.
This copy is deep in the decorable-term-structure of the tree, but shallow in the attributes and in the non-decorable-children.
(This isn't needed by current Silver semantics, but will come in handy for Lucas' redecoration work, and is easy.)

`undecorate` returns a copy of a tree as a term, stripping off all attributes on decorable children.
This copy is deep in the decorable-term-structure of the tree, but shallow in the non-decorable-children.

All these pieces come together with `decorate`.
TODO Finish`

## Remarks

For a worked-through example of a simple grammar translated to this IR and run, see [here]({{ get_url(path="/silvir/arithmetic-example.html") }}).

TODO mention annotations lol
