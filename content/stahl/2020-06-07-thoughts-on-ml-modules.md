+++
title = "Thoughts on ML-style Modules"
draft = true

[taxonomies]
tags = ["pl", "stahl"]

# [extra]
# comment_issue = 3
+++

I've been confused for a while about why SML/OCaml advocates tout the module system as being such a useful thing. I mean, sure, it's useful to be able to be able to talk about interfaces and relationships between types and functions, but I'd argue that typeclasses are a far more ergonomic solution to that problem.

A claim that I've heard was that they enable "programming in the large." This term seems to be a reference to [Programming-in-the-large versus Programming-in-the-small][DeRemer75]. From that paper:

> We argue that structuring a large collection of modules to form a "system" is
> an essentially distinct and different intellectual activity from that of
> constructing the individual modules. That is, we distinguish
> programming-in-the-large from programming-in-the-small. Correspondingly, we
> believe that essentially distinct and different languages should be used for
> the two activities.

[DeRemer75]: https://doi.org/10.1145/800027.808431
