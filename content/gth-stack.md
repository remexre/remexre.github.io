+++
date = "2017-08-13"
publishDate = "2017-08-13"
tags = []
title = "The GTH Stack"
+++

This blog is hosted on what I'm calling the "GTH" stack, for the three major parts:

 - [**G**itHub Pages](https://pages.github.com/) -- Hosting
 - [**T**ravis CI](https://travis-ci.org/) -- Runs Hugo
 - [**H**ugo](https://gohugo.io/) -- Site Generator

# Pros

I like this configuration mainly because (once it's set up!) I can write posts in Markdown, with a minimum of friction.
Tags and RSS are automatically generated, and theming is relatively painless.

[Shortcodes](https://gohugo.io/content-management/shortcodes/) are another cool innovation; they're essentially custom Markdown elements.
For example, the tweet in the "[Pygments Caching]({{< relref "#pygments-caching" >}})" section below is created with `{{</* tweet 447202124753952768 */>}}`.

The whole thing boils down to Go's [`html/template`](https://golang.org/pkg/html/template/) package, which is pretty easy to work with.
(My first paid dev job was in Go, so it was a shoo-in for me to use!)

# Cons

The documentation for all three of these components is somewhat lacking.

GitHub Pages seems to really want you to use Jekyll, and for a user site (i.e. `user.github.io`, as opposed to `user.github.io/project`) there are a few quirks if you're not doing so.

Whenever I use Travis CI, there are at least 3 commits of the form, "Maybe this fixes Travis", "CI fixes?", "whyyyyyyyyyy".

I've had to go to Hugo's source more than once to figure out why "unintuitive behavior" (a design bug?) was happening.

# Tips

There have been a few speed bumps along the way, listed here for posterity.
(And for myself, in case I need to set something similar up again.)

## Custom Syntax Highlighting

Hugo uses Pygments for syntax highlighting, meaning that a custom lexer can be used:

```oftlisp
(defn foo (x y z)
  (def xy (mod x y))
  (map \(+ xy @) z))
```

Once you have a working Pygments lexer, just run `python setup.py install --user`.
Check to make sure it shows up in `pygmentize -L`.
If it does, you can use it in Markdown code blocks with any of its aliases.

## Caching

{{< tweet 447202124753952768 >}}

Hugo caches pygments runs, by default to `/tmp/hugo_cache`.
If you're developing a lexer and find outdated results, try `rm`ing this first.
