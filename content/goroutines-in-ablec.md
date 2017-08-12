+++
date = "2017-05-10"
publishDate = "2017-08-10"
tags = ["ableC", "Concurrency"]
title = "Why ableC-goConcurrency shouldn't emulate Go"
+++

# I/O Issues

The first problem with implementing a coroutine-based green-thread system as an ableC extension is I/O; it would require annotating every blocking I/O function as such, and redirecting calls to them to instead send requests to a scheduler thread.
The scheduler would then perform an async call, and suspend the coroutine.
This would require a per-platform implementation, which is hard.

## Async File I/O Is Broken on Linux

The obvious way to do asynchronous file I/O is to use `O_NONBLOCKING` in all reads and writes.
This is simple, standardized by POSIX, and broken.
On Linux with glibc, this actually causes a userspace I/O thread to be spawned to perform the I/O.
Although this isn't *terribly* bad, it's still generally not what is meant by "async I/O."
Furthermore, it's usually not expected when one reaches for coroutines, although it may be acceptable for goroutines.

`select` is non-functional for files, per the manpage.
`select` will always claim that these files are ready to be read/written.
The same is true for the `poll` function.

`epoll` fixes many of the issues with `select` and `poll`.
Unfortunately, it still doesn't support regular files.

POSIX asynchronous I/O, the `aio` API, is not actually implemented with kernel support -- glibc implements it entirely in userspace, with threads!

Finally, there are a series of kernel functions, mainly `io_submit`.
It is essentially the kernelspace implementation of a subset of the `aio` functions.
However, it doesn't implement all of them, and still doesn't function for regular files.

These are all the ways (I know of) to do asynchronous I/O on Linux, and not a single one works!
The least dysfunctional is probably `epoll`, although care is needed to ensure that regular files are handled through a separate mechanism (a fixed number of I/O threads and an I/O queue?).

## It's Better On Windows

> I/O completion ports are awesome.
> There's no better word to describe them.
> If anything in Windows was done right, it's completion ports.
> 
> -- Damon on [StackOverflow](https://stackoverflow.com/a/5284537/1333945)

Windows has I/O Completion Ports, or IOCPs.
They're essentially a lock that threads can wait on.
Once an I/O operation is complete, a thread gets woken up.
They can also handle inter-thread messages.
Additionally, they have a mechanism to limit the number of threads doing processing to the number of cores the CPU has.

The only limitation of IOCPs seems to be that they don't work for `stdin`/`stdout` or anonymous pipes.
Overall, however, these are relatively small limitations; (hopefully) nobody's bottleneck is stdio.

# Loops Block

The next problem is that for a machine that spreads the coroutines among *N* threads, latency dramatically increases as soon as *N* compute-heavy tasks are scheduled.
The core issue here is essentially that a tight loop prevents any calls to the scheduler, so once all the compute tasks are running, any other tasks must wait for a compute task to complete.
The traditional solution to this is to unroll these loops, then add a check to an atomic per-thread "block soon" variable.
For example,

```c
for(int i = 0; i < j; i++) {
    b += a[i] * a[j - i - 1];
}

// becomes

int i;
for(i = 0; i < j; i += 8) {
    // This lazily makes the assumption that j is divisible by 8; fix it in
	// real code.
    b += a[i    ] * a[j - i - 1];
    b += a[i + 1] * a[j - i - 2];
    b += a[i + 2] * a[j - i - 3];
    b += a[i + 3] * a[j - i - 4];
    b += a[i + 4] * a[j - i - 5];
    b += a[i + 5] * a[j - i - 6];
    b += a[i + 6] * a[j - i - 7];
    b += a[i + 7] * a[j - i - 8];
    if(atomic_load(scheduler_should_preempt))
        scheduler_on_preempt();
}
```

The core assumption this makes is that the overhead of the preempt check is relatively insignificant when amortized over the loop iterations.
This generally turns out to be a safe assumption -- the branch is *extremely* predictable, and the check typically is two instructions (when not taken) on amd64 machines.
Spread over an eight-fold unrolling, this comes to a quarter of an instruction per iteration.

# "Foreign" Calls

> Excessive cgo usage breaks Go’s promise of lightweight concurrency.
>
> -- [Dave Cheney](https://dave.cheney.net) on [golang-nuts](https://groups.google.com/d/msg/golang-nuts/8gszDBRZh_4/Jj3pfIdrutYJ)

Even after we hook into I/O calls and unroll loops, we still run into the issue of other code that contains I/O or loops.
For example, let's look at `libcurl`.
libcurl both performs network I/O and potentially blocks; getting it to cooperate with scheduled ableC code would therefore require one of:

 - Compiling `libcurl` (and all other libraries that perform I/O or have loops) with ableC,
 - Moving C calls onto their own dedicated threads, or
 - Allowing "foreign" calls (to non-ableC C libraries) to block an OS thread

The disadvantage of the first option should be clear: at that point, you've created a distinct language from C that cannot freely interoperate with it.

The second option allows long-running calls to not block any scheduler threads, but *significantly* increases the overhead of all C calls.

The last option is what Go uses.
The advantage of this method is the low overhead when making "quick" C calls, around `100ns`.
If this method is implemented in ableC, the overhead would likely be lower.
However, this comes with the same issues Go has.

As mentioned above, Go can't handle large-scale use of cgo without losing concurrency.
Once `GOMAXPROCS` concurrent C calls are performed at the same time, no more can be performed.

# Conclusion

Assuming one wanted to go through the effort of:

 - replacing every I/O-performing function with a copy that instead enqueues the I/O job to a scheduler thread,
 - performing a code-injection while unrolling loops (which we don't currently do),
 - recompiling all dependencies, and
 - implementing this on all relevant platforms

it would theoretically be possible to implement a goroutine-style library for ableC.

To be continued...
