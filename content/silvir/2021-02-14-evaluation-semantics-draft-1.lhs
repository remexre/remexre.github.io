+++
title = "SilvIR: Evaluation Semantics, Draft 1"
draft = true

[render_options]
quotes_to_code = "haskell"

[taxonomies]
tags = ["silvir"]

[extra]
comment_issue = 12
+++

Birthday post!

*This post assumes you've read the [previous one in the series](@/silvir/2021-02-12-definition-draft-1.md).*

This post might have a higher "difficulty of read to usefulness of reading" ratio than the others in the series...
I'll try to precisely specify the evaluation semantics of the IR defined in the previous draft here.
This post is a Literate Haskell file; if you clone [the repo backing this site](https://github.com/remexre/remexre.github.io) and run this post (`content/silvir/2021-02-14-evaluation-semantics-draft-1.lhs`) under GHCi, you can get a live version of these semantics you can play with interactively.

> module Main where
> main = putStrLn "Hello, world!"
