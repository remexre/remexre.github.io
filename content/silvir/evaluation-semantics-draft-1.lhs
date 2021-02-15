+++
title = "SilvIR: Evaluation Semantics, Draft 1"
draft = true
tags = ["silvir"]
# comment_issue = 12
quotes_to_code = "haskell"
+++

*This post assumes you've read the [previous one in the series](@/silvir/definition-draft-1).*

This post might have a higher "difficulty of read to usefulness of reading" ratio than the others in the series...
I'll try to precisely specify the evaluation semantics of the IR defined in the previous draft here.
This post is a Literate Haskell file; if you clone [the repo backing this site](https://github.com/remexre/remexre.github.io) and run this post (`content/silvir/2021-02-14-evaluation-semantics-draft-1.lhs`) under GHCi, you can get a live version of these semantics you can play with interactively.

We translate the definitions from the previous post into Haskell datatypes.

> data Literal
>   = L'Int Integer
>   | L'String Text
>   deriving Show
>
> data PrimPattern
>   = P'Var LocalName
>   | P'Lit Literal
>   | P'Any
>   deriving Show

```
> Pattern ::= recordPat(Map<String, PrimPattern>)
> |  treeOrTermPat(ProdName, List<PrimPattern>)
> |  primPat(PrimPattern)
> 
> IsChildDecorable ::= childIsDecorable
> |  childIsntDecorable
> 
> Expr ::= local(LocalName)
> |  global(GlobalName)
> |  lit(Literal)
> |  let(LocalName, Expr, Expr)
> |  letrec(Map<LocalName, Expr>, Expr)
> |  lam(List<LocalName>, Expr)
> |  call(Expr, List<Expr>)
> |  error(Expr)
> |  thunk(Expr)
> |  force(Expr)
> |  case(Expr, List<Pair<Pattern, Expr>>)
> |  pureForeign(String, List<Expr>)
> |  impureForeign(String, List<Expr>)
> |  makeRecord(Map<String, Expr>)
> |  getRecordMember(String, Expr)
> |  cons(ProdName, List<Pair<IsChildDecorable, Expr>>)
> |  getChild(Nat, Expr)
> |  getAttr(AttrName, Expr)
> |  setAttr(AttrName, Expr, Expr, Expr)
> |  combineAttr(AttrName, Expr, Expr, Expr, Expr)
> |  copyTree(Expr)
> |  decorate(Expr, Map<AttrName, Expr>)
> |  undecorate(Expr)
> 
> Priority ::= Int
> 
> TopLevelItem ::= globalDecl(GlobalName, Expr)
> |  prodDecl(ProdName, NTName)
> |  defaultProdBodyDecl(NTName, Priority, LocalName, Expr)
> |  prodBodyDecl(ProdName, Priority, LocalName, Expr)
> 
> Program ::= Set<TopLevelItem>
```
