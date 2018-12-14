+++
tags = ["ableC", "Concurrency", "Project Ideas"]
title = "STM in ableC"
+++

# Introduction

Software Transactional Memory (STM) has been described in many places, and is present in many languages, including Clojure and Haskell.
The best introduction to STM I know of is [Beautiful Concurrency](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/beautiful.pdf), by Simon Peyton Jones.
I'll summarize it here for the busy reader.

Simply put, STM is a way to synchronize concurrent data accesses that is composable and much more intuitive than traditional locks.
It does this by grouping data accesses to shared memory into transactions.
For example, the two pieces of code are roughly equivalent:

```c
// With locks in C11

int alice_balance = 0;
mtx_t alice_balance_lock;

int bob_balance = 0;
mtx_t bob_balance_lock;

void transfer(int amount, int* from, int* to, mtx_t *fromLock, mtx_t *toLock);

int main() {
	assert(mtx_init(&alice_balance_lock, mtx_plain));
	assert(mtx_init(&bob_balance_lock, mtx_plain));

	// thread1() and thread2() get spawned off
}

void thread1() {
	transfer(100, &alice_balance, &bob_balance, &alice_balance_lock,
		&bob_balance_lock);
}

void thread2() {
	transfer(45, &bob_balance, &alice_balance, &bob_balance_lock,
		&alice_balance_lock);
}

void transfer(int amount, int* from, int* to, mtx_t *fromLock, mtx_t *toLock) {
	mtx_lock(fromLock);
	mtx_lock(toLock);

	*from -= amount;
	*to += amount;

	mtx_unlock(toLock);
	mtx_unlock(fromLock);
}
```

```c
// With transactions in ableC

stm<int> alice_balance = 0;
stm<int> bob_balance = 0;

void transfer(int amount, stm<int> from, stm<int> to);

int main() {
	// No init needed!

	// thread1() and thread2() get spawned off
}

void thread1() {
	transfer(100, alice_balance, bob_balance);
}

void thread2() {
	transfer(45, bob_balance, alice_balance);
}

void transfer(int amount, stm<int> from, stm<int> to) {
	run_transaction(transaction {
		*from -= amount;
		*to += amount;
	});
}
```

Clearly, the transaction-using version is much simpler.
There is also a difference in functionality between the two versions, however.
The lock-using variant can potentially deadlock, if `thread1()` acquires `alice_balance_lock` after `thread2()` acquires `bob_balance_lock`.
(See [here](https://deadlockempire.github.io/#L2-deadlock) for an interactive example of the unsafety.)
This can be worked around, but the work-arounds don't generalize to variable numbers of locks being required.
Additionally, checking for deadlocks requires observing all the code that acquires a lock in the entire program.

In STM, however, locks are not used as the basis for concurrency; transactions are instead.
Transactions instead work by performing all the operations required, then *committing* them.
The commit operation is performed by `run_transaction` in the above example.
If a conflict (e.g. another thread has written to variables we read from/write to) is detected, the transaction is *aborted* (rolled back) and *retried*.

This gives the similar performance characteristics to a hand-crafted lock-free data structure, without the complexity of implementing one.
With the algorithm described in [Transactional Locking II](http://dx.doi.org/10.1007/11864219_14), STM was benchmarked against mutexes, and resulted in an order-of-magnitude reduction in program run time.

# Implementation

## `stm` Types

`stm<T>` types should have operators overloaded on them such that the dereference operator (unary `*`) will keep track of reads and writes as specified in TL2 (cited above).

## The `transaction` Type

Transactions are more complex; I'm not sure of the best way to implement them.
Compiling transaction blocks to lambda-lifted functions or closures might work; making `transaction_t` a typedef for a function pointer would then work for cheap, copyable transactions.
The translation for closures would need to be different from the existing [ableC-closure](https://github.com/melt-umn/ableC-closure)'s method, as to enable restartable transactions, it must be possible to roll back the environment to an earlier state.
This could perhaps be done by copying the closed-over variables from the closure's saved environment to local variables at the start of the function.

## Side Effects

One tricky thing about this is then ensuring that all the code that runs in a transaction can be safely rolled back.
To that end, it is usually necessary to prevent side effects to non-`stm` variables.
In Haskell, this is simply a matter of not exposing the `IO` monad, to prevent side-effects other than reading from and writing to STM variables.

In ableC, on the other hand, we can add a `pure` type qualifier to function types.
This type qualifier is inferred for functions that are themselves composed of only `pure` function calls and pure operations (e.g. math operations), but can also be manually added (with the caveat that misannotating an impure function as pure will cause undefined behavior).

Inside a `transaction` block, only `pure` functions should be able to be called.

## Runtime Support

In theory, a full implementation of TL2 should be included in the runtime.
Garbage collection (as needed in the ableC-closure extension) will also probably be needed.
