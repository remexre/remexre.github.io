+++
title = "The StahlDream"
draft = true

[taxonomies]
categories = ["post"]
tags = ["stahl"]

[extra]
# comment_issue = 5
+++

The StahlDream is the shorthand I use for constructing a personal computing system, from the hardware up. This encompasses several programming languages, an operating system, at least two databases, and everything one needs to support all of the above. (And that's before I get to any actual applications.)

I realized I don't actually have all this written down in one place anywhere, so this serves as a snapshot into the current vision.

This is certainly inspired by [Oberon](https://en.wikipedia.org/wiki/Oberon_(operating_system)), which showed one could create a single-machine system in a few thousand lines of code (12,227 by [one count](http://www.edm2.com/0608/oberon.html)). I don't think I can fit a system in so few lines of code, but I also want to have a much more complicated language in use for most of the system.

StahlOS
=======

The part I'm currently working on is an operating system on which the rest of the system runs. The system is quite minimal &mdash; there's neither MMU-based process isolation, nor pre-emptive multitasking (though the latter may change).

The StahlOS model fundamentally relies on all actual machine code executed by the CPU to be trustworthy, and disallows loading binaries other than the kernel itself. Instead, system drivers and essential processes are written in [StahlOS Forth](#stahlos-forth), which user programs are compiled to at runtime. Even the Forth programs themselves are only loadable from a read-only filesystem (excepting those that are compiled into the kernel), since Forth is low-level enough that it might as be machine code, security-wise.

Each of the compiler processes only memory-safe code; assuming this property and the correctness of the above TCB, all code the system can run is memory-safe. This allows wholly ignoring the MMU as a security mechanism. Instead, memory ownership is implicit, and controlled at the page level. Each process (with exceptions such as a low-level debugging REPL) is shared-nothing, with message-passing as a fundamental operation, implemented as the transfer of page ownership. (I haven't ruled out eventually allowing shared pages with STM or similar for concurrent modification, but I'm leery of shared pointers.)

StahlOS will also provide Erlang-like mechanisms for orchestrating processes (i.e. monitors and links). However, cross-machine message-passing will not be directly supported (and for this reason, message-passing should only really be considered a intra-app mechanism, despite being inter-process). Instead, applications should generally use the [tuple space](#tuple-space) as a synchronization point: it's not significantly more expensive than message passing for local communications, but allows remove communications.

Languages
=========

Stahl
-----

The primary language being designed currently, and the most complicated one by far, is Stahl. Stahl is a dependently typed lambda calculus with a Lisp-like syntax.

I'm probably basing the core type theory on the type theory presented in [Homotopy Type Theory](https://homotopytypetheory.org/book/), but without the univalence axiom (at least, until I can figure out how to make it computable).

I also want to make the language the testbed for experimenting with automated theorem proving and making manual theorem proving convenient in a "casual" setting (e.g. from a smartphone while on a bus).

StahlOS Forth
-------------

StahlOS uses a Forth dialect as the low-level programming language. [Forth](https://en.wikipedia.org/wiki/Forth_(programming_language)) is the best language I've found for bare-metal development. A Forth system can be constructed with amazingly little machine code; the resulting language is capable of Common Lisp-tier metaprogramming, while also being able to peek and poke at memory, without needing dynamic memory allocation.

Databases
=========

Tuple Space
-----------

[Tuple spaces](https://en.wikipedia.org/wiki/Tuple_space) are a sufficiently old, and sufficiently nice-seeming database abstraction that I'm honestly surprised there isn't a high-quality implementation some programming subculture is smugly using (in same way similar subcultures exist for e.g. Smalltalk, Erlang, Common Lisp).

Essentially, a tuple space is a distributed multiset with five primitive operations:

-	`put TUPLE` adds a tuple to the multiset
-	`try-take PATTERN` returns a tuple matching `PATTERN` if one exists in the multiset, removing it from the multiset
-	`try-peek PATTERN` returns a tuple matching `PATTERN` if one exists in the multiset, without removing it from the multiset
-	`take PATTERN, TIMEOUT` returns a tuple matching `PATTERN` if one can be found within `TIMEOUT`, removing it from the multiset
-	`peek PATTERN, TIMEOUT` returns a tuple matching `PATTERN` if one can be found within `TIMEOUT`, without removing it from the multiset

With a sufficiently expressive pattern language, it becomes easy to have applications sharing a database with loose coupling between them.

I need more design work to determine many of the details of this tuple space (as well as a name for it!) &mdash; particularly, I'm unsure of how precisely I want to make the database distributed. Given that I'm using it as a coordination mechanism as well as a (short-term) database, it's not clear what semantics I actually want on netsplit. Furthermore, it seems like there ought to be a large class of optimizations I could apply to make common patterns of use more efficient, though these might require real-world usage data to evaluate.

G1
--

I'm already writing about G1 [elsewhere](@/g1/2019-12-15-intro.md) on this blog, but I'll summarize how it fits into the larger StahlDream.

The tuple space doesn't seem particularly good as a database for bulk storage &mdash; I'm planning to implement it with the expectation that it will contain at most a few megabytes of data at once. I therefore want a flexible database for storing and querying larger data.

I'm planning to implement the tuple space on top of both StahlOS and some Linux system, likely with the Linux implementation being in Rust. The thinking here is somewhat similar to Erlang's port drivers, which allow interfacing with a native-code process as if it were an Erlang process. G1 can then be easily bridged to StahlOS, by acting on the tuple space directly.
