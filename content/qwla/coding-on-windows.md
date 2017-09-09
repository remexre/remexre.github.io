+++
date = "2017-09-09"
draft = true
title = "Getting Started with Coding on Windows"
+++

1. Microsoft has their own ecosystem we don't teach here, and not a ton of people use in academia.
This includes Visual \<insert name of normal language\>, C#, F#, ASP, and anything else that sounds enterprise-y.
(Although I head that F# is really nice.)

2. WSL is a thing from Microsoft that lets you install Linux as a program into Windows.
Because they're realizing that a lot of development tools only work or work best on Unix (Mac or Linux), so they would rather it be possible to use them on Windows and not lose the market share among developers.

3. MingW and Cygwin are similar to WSL, but not from Microsoft. If you're on Windows 10, use WSL, otherwise, Cygwin.

4. installing Linux in a VM means you can't fuck up your system, but Linux is still there as an application.
If you have one of the "fancy" versions of Windows with Hyper-V, use that, otherwise, VirtualBox.
(Although it's been alleged that CSE gets free VMware, which is apparently better, but idk.)

5. SSH is a thing that lets you connect to any of the U's hundreds of Linux machines and work there.
You can use it with PuTTY, which the U posts directions on how to use.

Summary:
It mainly depends on what language you want to use; it might be possible to do everything from Windows.
But everyone else here is on a Unix platform, so troubleshooting is going to assume you're using Linux or OS X.

Once you have some means of accessing Unix, Matt Might's [Survival guide for Unix newbies](http://matt.might.net/articles/basic-unix/) is a solid next step.
