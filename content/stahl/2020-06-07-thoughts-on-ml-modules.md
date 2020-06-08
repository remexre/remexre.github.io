+++
title = "Thoughts on ML-style Modules"
draft = true

[taxonomies]
tags = ["pl", "stahl"]

# [extra]
# comment_issue = 3
+++

# Introduction

I've been confused for a while about why SML/OCaml advocates tout the module system as being such a useful thing.
I mean, sure, it's useful to be able to be able to talk about interfaces and relationships between types and functions, but I'd argue that typeclasses are a far more ergonomic solution to that problem.
A claim that I've heard was that they enable "programming in the large."
This term is a reference to [Programming-in-the-large versus Programming-in-the-small][DeRemer75].
From that paper:

> We argue that structuring a large collection of modules to form a "system" is
> an essentially distinct and different intellectual activity from that of
> constructing the individual modules. That is, we distinguish
> programming-in-the-large from programming-in-the-small. Correspondingly, we
> believe that essentially distinct and different languages should be used for
> the two activities.

The [Wikipedia page about the paper][WikiProgLarge] further references [Ousterhout's dichotomy][WikiOusterhout], the idea that languages can be divided into glue languages and applications languages.
Ousterhout (the creator of Tcl) theorizes that useful, high-performing, correct programs can be assembled by using a glue language to combine several components written in applications languages.
Others have noticed a separation here as well; my favorite presentation is Ted Kaminski's [Programmer as wizard, programmer as engineer][TedinskiWizEng].

# Goal

I feel like the major annoyances I have with ML-style modules are:

1. For many things that need modules in OCaml, typeclasses or [instance arguments][AgdaInstArgs] seem obviously superior (e.g. `Eq`, `Ord`, `Show`).
2. The interfaces between modules need to be designed to fit together, otherwise the resulting glue code is both tedious and unfortunately sometimes long.
   And if you need to design the system ahead of time, why not just build software the "normal" way, with coupling between all your (non-external) components, ignoring the module language.

The former can obviously be solved by having typeclasses alongside modules.

The latter is the more interesting problem.
To take a narrative voice,

> Alice is writing CRUD endpoints for a service that exposes an HTTP API.
> She needs to parse a `Foo` from a request and store it in the database, performing appropriate access validation checks.
> She can simply write `{get-current-request parse-json store db}`, and the system will attempt to generate "reasonable" configurations.
> TODO
>
> Bob is performing a similar task without the tooling Alice has access to.
> TODO

[AgdaInstArgs]: https://agda.readthedocs.io/en/v2.5.2/language/instance-arguments.html
[DeRemer75]: https://doi.org/10.1145/800027.808431
[TedinskiWizEng]: https://www.tedinski.com/2018/03/20/wizarding-vs-engineering.html
[WikiOusterhout]: https://en.wikipedia.org/wiki/Ousterhout%27s_dichotomy
[WikiProgLarge]: https://en.wikipedia.org/wiki/Programming_in_the_large_and_programming_in_the_small
