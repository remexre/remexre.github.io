+++
title = "Template Render Worker"
+++

## Overview

If your frontend uses one of the big JavaScript frameworks, you're probably not going to be able to display the page unless the user has JavaScript enabled.
Furthermore, JavaScript is a battery drain, and waiting for it to load can worsen user experience.
[Isomorphic JavaScript](https://en.wikipedia.org/wiki/Isomorphic_JavaScript) is the solution to these problems -- a worker runs the JavaScript on the server-side initially, to be able to send the client fully rendered pages without requiring the user to have JavaScript enabled.

This is not really *necessary*, but it's certainly a nice-to-have.
And, as a bonus, if your JS can run on the server, it's probably a lot easier to test.

## Tech Recommendation

[React](https://reactjs.org/) supports server-side rendering, in addition to being pretty decent overall.
[Svelte](https://svelte.technology/) perhaps a better option, but is less popular.

It's (sadly) necessary to implement the worker in node.js; there should be minimal JS code outside of your frontend, at least.
