+++
title = "Pinebook Pro OSDev: Forth"
draft = true

[taxonomies]
categories = ["post"]
tags = ["forth", "osdev", "pbp"]

[extra]
# comment_issue = 5
+++

*This post assumes you've read the [previous one in the series](@/pbp-osdev/hello-world.md).*

TODO

As the joke goes, if you’ve seen one Forth implementation, you’ve seen one Forth implementation &mdash; many Forth implementations don't particularly adhere to any standard. This all works out, partially due to the bottom-up design philosophy typically used in Forth: if a somewhat rarely-used primitive changes, it's more often than not results in a small number of changes to low-level words (functions).

This makes sense given the small size of most implementations, and the bottom-up design style used in most Forth programs: it doesn't hugely matter to the language's community if implemtnati

I generally take inspiration from the [Forth 2012 Standard](https://forth-standard.org/), but I'm not making compliance a particular goal.
