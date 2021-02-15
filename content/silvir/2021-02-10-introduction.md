+++
title = "SilvIR: Introduction"
tags = ["silvir"]
comment_issue = 10
+++

I'm planning to work on an IR for [Silver](https://github.com/melt-umn/silver), an attribute-grammar based language for compiler construction.
This'll probably form the core of my MS thesis work, so my advisor recommended I blog about it as a way to communicate everything properly to the rest of the group, with the side benefits of getting a head start on laying everything out for writing the actual thesis.

Background
==========

*(If you're a MELT group member I'm making read this, feel free to skip this section.)*

Attribute grammars are a formalism for describing computations on trees.
The core idea is that you describe the syntax (concrete or abstract) of your language with a grammar, and then can perform transformations on it by describing them in terms of attributes.

Generally, attributes can be divided into two classes, *inherited* and *synthesized*.
Inherited attributes (informally, inhs) are passed from the parent node down to its children.
Synthesized attributes (informally, syns) are computed from inherited attributes and children, and typically are passed from children up to their parents.

Typical examples of inherited attributes include the environment and other information about the context of a term.
Typical examples of synthesized attributes include the type of a term, the errors present on a term and its subterms, and the translation of a term to an IR or target language.

Silver implements one particular evaluation strategy for attribute grammars, demand-driven evaluation.
This looks approximately like a lazy functional language, and many idioms are shared between Haskell and Silver as a result.

Motivation
==========

Silver is super convenient to use for writing compilers with, but its performance is a lot worse than I wish it was.
Furthermore, lots of optimizations that would be really nice to have implemented are pretty dang tricky.
This is mostly for historical reasons relating to the implementation of Silver, rather than its properties or expressiveness as a language -- Silver best-practices didn't exist when Silver was written, so it doesn't follow them.

Currently, Silver compiles directly (i.e., without an IR!) to a huge amount of Java source code, which is unideal from an aesthetic perspective, and makes implementing additional passes pretty tricky.

The big goals of SilvIR as an IR for Silver are:

- To make experimenting with different translations easier (eg. "can we do aggressive stack allocation *a la* Go to reduce GC pressure?" "would [Perceus](https://www.microsoft.com/en-us/research/uploads/prod/2020/11/perceus-tr-v1.pdf) result in measurable speedups?")
- To implement "linking," which should drastically reduce startup time versus the Java translation
- To make writing relatively low-level optimization passes (eg. and esp. strictness analysis) easier

Initially I plan to compile Silver to SilvIR, and write an interpreter for SilvIR with the [Truffle Language Implementation Framework](https://www.graalvm.org/graalvm-as-a-platform/language-implementation-framework/) in order to get access to a fast runtime and high-throughput GC easily.

Furthermore, as "stretch goals," it'd be kinda nice to have:

- A real profiler that can map hotspots to source language positions (via [VisualVM's GraalVM support](https://visualvm.github.io/graal.html))
- A real debugger (via [GraalVM's Chrome DevTools Protocol support](https://www.graalvm.org/tools/chrome-debugger/))
- [Code coverage checking](https://www.graalvm.org/tools/code-coverage/) for seeing what dark corners of the compiler are never exercised (and for test coverage purposes in general)
- A JavaScript or WASM backend, as a step towards being able to do a non-cursed "try Silver in the browser" thing
- A formal semantics of SilvIR in Coq or Lean, to talk about the correctness of optimizations and backends

Design Considerations
=====================

Silver supports a large number of extensions to the basic idea of attribute grammars, and supporting all of them is necessarily a goal.
Notable extensions include:

- [Aspect productions](http://melt.cs.umn.edu/silver/concepts/aspects/)
- [Automatic attributes](http://melt.cs.umn.edu/silver/concepts/automatic-attributes/), including functor and monoid attributes.
- [Collection attributes](http://melt.cs.umn.edu/silver/concepts/collections/)
- [Forwarding](http://melt.cs.umn.edu/silver/ref/stmt/forwarding/)
- [Higher-order attributes](http://melt.cs.umn.edu/silver/concepts/decorated-vs-undecorated/#higher-order-undecorated)
- [Pattern matching](http://melt.cs.umn.edu/silver/ref/expr/pattern-matching/), which has some [unusual consequences](https://github.com/melt-umn/silver/issues/387) when combined with forwarding ([though you shouldn't do this anyway](http://melt.cs.umn.edu/silver/concepts/interference/#patterns-arent-exceptions))
- [Reference attributes](http://melt.cs.umn.edu/silver/concepts/decorated-vs-undecorated/#reference-decorated)

All of these are used within the implementation of Silver, so must be supported before Silver can be bootstrapped on SilvIR.
In the [next post](@/silvir/2021-02-12-definition-draft-1.md), we'll look at (the current draft of) the actual definition of the IR.
