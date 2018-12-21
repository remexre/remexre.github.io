+++
title = "An ableC Extension for Logic Programming"

[taxonomies]
tags = ["ableC", "Logic Programming", "Project Ideas"]
+++

**EDIT** (2018-12-20): Lucas Kramer ([GitHub](https://github.com/krame505)) did this: [ableC-prolog](https://github.com/melt-umn/ableC-prolog).

# Introduction

I'd like to see an ableC extension that embeds a simple Prolog dialect into C with easy interoperability, such that it's trivial to call C code from Prolog or run Prolog queries from C.
An example of what I'm envisioning might be:

```c
#include <ableC-logic-language.h>
#include <stdio.h>

char* append_strings(char*, char*);
int factorial(int);
char* pprint_node(int nodeIdx);

ruleset exampleRules {
	facFixPt(X) :- Y is factorial(X), X = Y.

	path(N, N, [N]).
	path(A, B, [A, B]) :-
		edge(A, B).
	path(From, To, [From|Rest]) :-
		edge(From, N),
		path(N, To, Rest).

	printPath([], "").
	printPath([H|T], Out) :-
		HStr is pprint_node(H),
		printPath(T, TStr),
		Out is append_strings(HStr, TStr).

	pathDesc(From, To, Desc) :-
		path(From, To, Path),
		printPath(Path, Desc).
}

int main(void) {
	LogicEngine* e = LogicEngine_new(exampleRules);
	LogicEngine_load_facts_from_file(e, "graph.pl");

	int count = 0;
	// This needs syntax bikeshedding.
	query e for pathDesc(1, 10, Path) with (p as Path) {
		puts("Found path:");
		puts(p);
		count++;
	}

	printf("Found %d paths total.", count);
	LogicEngine_free(e);

	return 0;
}
```

# Motivation

I've recently gotten sucked into logic programming, and tried to integrate some Prolog code with other code in [a larger project](https://github.com/remexre/extlint).

My biggest takeaway from this project is that *current Prolog FFIs suck*.
A large part of this is definitely the fact that most Prolog systems aren't meant for embedding, but rather for implementing entire projects in.
The ISO Prolog specification also requires enough features for a large amount of standard library Prolog code, which isn't great for embeddability.
Lastly, the popularity of [miniKanren](http://minikanren.org/) dialects takes away impetus for creating embeddable Prologs.

For me, the benefit of Prolog over miniKanren, or even trickiness like defining a nondeterminism monad, isn't in its capabilities so much as the terseness of its syntax.
Prolog syntax is simple enough to pick up in a single lecture, encouraging prototyping, and its uniformity makes transferring knowledge between projects easier.

# Implementation

The concrete syntax should be fairly simple, with the exclusion of custom operators.
Custom operators aren't used in most Prolog code (that I've seen), so this shouldn't be overly harmful.

Being able to handle both C's case-insensitive variables and Prolog's case-dependent atoms/variables is potentially another good way to showcase the advantage of Copper's context-aware lexing.

Implementing the abstract syntax should be straightforward as well.

For implementing the actual Prolog interpreter, I like the approach in [Implementation of a high-speed Prolog interpreter](https://doi.org/10.1145/29650.29663).
The approach here is simpler than a typical WAM, and (according to that paper's "Comparison with compilers" section) is faster than many compilers while still supporting `assert` and `retract`.
At a minimum, `assert` should be supported for the `LogicEngine_load_facts_from_file` function to work efficiently.
