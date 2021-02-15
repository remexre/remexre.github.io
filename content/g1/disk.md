+++
title = "G1: The On-Disk Format"
draft = true
tags = ["g1", "rust"]
comment_issue = 1234
+++

*This post assumes you've read the [previous one in the series](@/g1/2020-02-01-query-lang.md).*

Currently, I'm not caring all that much about maximum efficiency, instead preferring a simple approach. This approach is therefore based off of what a "real" database might do, but much simpler.

At a high level, the on-disk format is an append-only structure composed of fixed-length blocks, which define several immutable data structures, all linked to by the final block:

```
               +---------+         +-----------------------------+
               |         |         |                             |
               v         |         v                             |
+---------+---------+---------+---------+---------+---------+---------+---------+
| Initial |  Atoms  |  Atoms  |  Edges  |  Attrs  | Garbage |  Edges  |   Meta  |
|         |    1    |    2    |    1    |    1    |         |    2    |   data  |
+---------+---------+---------+---------+---------+---------+---------+---------+
                         ^                   ^                   ^         |
                         |                   |                   |         |
                         +-------------------+-------------------+---------+
```

This has the advantage that since blocks before (and including) the metadata block are immutable, the slow write operation doesn't block any read operations, nor invalidate the page cache. Additionally, the "undo log" is very simple -- just the old length. Furthermore, the only operations that need to be serialized are writes, and serializing writes provides isolation. Most of the data structures are functional trees of various sorts.
