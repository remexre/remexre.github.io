+++
title = "Pinebook Pro OSDev Notes"

[taxonomies]
categories = ["notebook"]
tags = []
+++

The Hardware
============

This is written about and on the ANSI model of the [Pinebook Pro](https://www.pine64.org/pinebook-pro/). Additionally, I use a cable to access the serial port, which wires it up to a 3.5mm headphone jack physical connector. Pine sells a nicely packaged cable, but as people on the forums note (and I've verified), it runs at 5 volts, which causes spooky behavior (up to and including hardware damage) on the Pinebook. Instead, I'm using some jumpers spliced to a headphone cord I cut in half to provide the physical connector to the board.

Initially, I tried [Adafruit's USB to TTL Serial Cable](https://www.adafruit.com/product/954), since I already had it sitting around. However, it turns out it's based on the CP2102 chip, which only supports speeds up to 1Mbps (1000000 baud). The TODO MAINBOARD, however, boots at 1.5Mbps (1500000 baud). Instead, I bought a converter based on the PL2302DX (TODO VERIFY), which can do up to 12Mbps.

Out of the Box
==============

The Pinebook Pro ships with an ancient (oldstable?) version of Debian. I ditched it for Manjaro running off an SD card. From the default install, I `systemctl disable`d lightdm and installed i3 instead. I'm doing most of my usage (including typing this!) from the kernel console in tmux, though.

A hardware switch needs to be flipped inside the device to enable UART2, which provides a serial port over the headphone jack. The Pine wiki documents the location of the switch fairly well; check it for pictures.

U-Boot
======

**TODO INVALID BECAUSE OF MAX BAUD RATE:** I'm currently trying to get a shell in U-Boot. I've been told holding Ctrl-C as the machine boots should cause it to boot to the U-Boot shell instead of automatically booting the Linux kernel. However, `minicom` at the recommended 1500000 baud doesn't work (I get garbage that suggests ANSI codes instead of an actual shell), though I'm unconvinced I'm actually seeing uboot rather than the Linux kernel, since the boot time seems unaffected by holding Ctrl-C.
