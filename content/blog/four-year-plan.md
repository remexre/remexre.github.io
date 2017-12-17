+++
date = "2017-09-11"
draft = true
tags = ["The Four Year Plan", "OftLisp"]
title = "My Four Year Plan"
+++

# Introduction

I get bored easily, I distrust books, and I get distracted quickly.
TODO REWORD THIS TO NOT MAKE ME SOUND UNHIREABLE

So I'm setting up a series of long-term projects in order to ensure that I don't get *too* distracted in school, while still learning as much as I can while I have the resources of a university.

Also, I really want a Glass-style device that lets me write and run code directly on it (with a wireless keyboard, of course; I'm not insane).

# 2017 -- [Language (OftLisp)](https://github.com/oftlisp)

The first goal, and the one I'm working on now, is making my own language.
[Since Lisp is the most powerful language](http://www.paulgraham.com/avg.html) (or at least seems to be), I chose for it to be a Lisp dialect.
The slightly more practical part is that having macros allows for implementing most language features using them, reducing the amount of work needed in the compiler.

It's a Lisp-1 (i.e. there is a single namespace, rather than one for functions and one for data) with macro expansion occurring at compile-time (rather than Arc's first-class macros).

Right now, I have working interpretation and compilation to a bytecode based on A-Normal Form.
Once I get macros working better (their implementation is still a bit sketchy), I'll add an LLVM backend.

Note on naming: The Oft in OftLisp definitely used to be an acronym.
I just have no idea what it was.

# 2018 -- Operating System

I've done [some toying around](https://git.remexre.xyz/remexre/ActrOS) with OSDev in the past, but I've never gotten to userspace, or made anything generally usable.
My goal for this year will be to develop an operating system that runs on amd64 and RISC-V, with support for loadable drivers, proper userspace (including paging), and SMP.

I'm planning to base the filesystem on how Plan 9's [Venti](https://en.wikipedia.org/wiki/Venti) system works, where blocks are written to disk permanently, and only able to be accessed by their hash.
My theory is that disk space is cheaper than debugging time and data recovery (if needed).
I haven't studied much about actual filesystem design, so I'll need to spend a month or so there.
Efficiency is honestly a non-goal, as this is mainly an educational project.

I'd like the kernel to be a micro/nano-kernel, again for reasons of debuggability and to force myself to organize things in a rewrite-friendly way.
(Because again, learning-project code is not shining, beautiful, efficient code.)
Also, this will make it easier to have the actual kernel be in Rust, while the majority of the system's code is in OftLisp.

I'll probably end up making a few types of IPC, ideally structured so that IPC I/O doesn't involve a syscall.

# 2019 -- Hardware

I really like the concept of RISC-V being a RISC open-source ISA, and it looks like it's getting broad enough industry adoption to be able to purchase a usable RISC-V CPU supporting user mode by 2019.
If not, I'll probably switch this to ARM; having LLVM as a backend for both OftLisp and Rust makes this easier than it would otherwise be.

In either case, [it looks like](https://hackaday.io/project/18033-raspberry-pi-zero-prism) it's reasonably easy to make a smartglass device that is based of a simple SoC.
The linked project uses a Raspberry Pi Zero.
Since I don't anticipate the wearable portion to take anywhere near the full year, I'm probably going to try to make a custom board to host a RISC-V CPU.
Otherwise, I'm sure something like [Sifive's Hifive1](https://www.sifive.com/products/hifive1/), but with the user mode instruction set, will be available by then.

Worst case, ARM port of the OS to whatever the equivalent of a Raspberry Pi Zero will be.

# 2020 -- Application

TODO Basically, a [memex](https://en.wikipedia.org/wiki/Memex) backed by a graph database.
Also, a postfix calculator, because math be hard yo.
