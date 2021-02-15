+++
title = "Pinebook Pro OSDev: Hello World"
tags = ["osdev", "pbp"]
comment_issue = 7
+++

I recently got a Pinebook Pro, and I want to port [StahlOS](@/stahl/dream/#stahlos) to it. The journey of a thousand miles begins with a single step, so here's a journal entry on getting a "Hello, world" program running on it.

The Hardware
============

This is written about (and largely on) the ANSI model of the [Pinebook Pro](https://www.pine64.org/pinebook-pro/). Additionally, I use a cable to access the serial port, which wires it up to a 3.5mm headphone jack physical connector. Pine sells a nicely packaged cable, but as people on the forums note (and I've verified), it runs at 5 volts, which causes spooky behavior (up to and including hardware damage) on the Pinebook. Instead, I'm using some jumpers spliced to a headphone cord I cut in half to provide the physical connector to the board.

Initially, I tried [Adafruit's USB to TTL Serial Cable](https://www.adafruit.com/product/954), since I already had it sitting around. However, it turns out it's based on the CP2102 chip, which only supports speeds up to 1Mbps (1000000 baud). The RK3399 (the board inside the Pinebook Pro), however, boots at 1.5Mbps (1500000 baud). Instead, I bought a converter based on the PL2302DX, which can do up to 12Mbps.

Out of the Box
==============

The Pinebook Pro ships with an ancient (oldstable?) version of Debian. I ditched it for Manjaro running off an SD card. From the default install, I `systemctl disable`d lightdm and installed i3 instead. I'm doing most of my usage (including typing this!) from the kernel console in tmux, though.

A hardware switch needs to be flipped inside the device to enable UART2, which provides a serial port over the headphone jack. The [Pine wiki](https://wiki.pine64.org/index.php/Pinebook_Pro_Main_Page) documents the location of the switch fairly well; check it for [pictures](https://wiki.pine64.org/index.php/Pinebook_Pro_Main_Page#Pinebook_Pro_Internal_Layout).

U-Boot
======

Once the serial port is connected, rebooting the machine shows the boot logs. Mashing Ctrl-C (or any key on the Manjaro U-Boot, it appears) gets a shell, with vaguely sh-like semantics.

I recommend updating to Manjaro's U-Boot; the U-Boot the Pinebook Pro ships with (as of the January 2020 batch) can't boot from 64-bit ELF files. If your machine boots with an amber power LED instead of a green one, that's a strong indicator you're on the newer Manjaro U-Boot.

The commands in the shell I find most useful are:

-	`bootelf`: Loads the ELF file at the given address, and jumps to its entrypoint.
-	`go`: Jumps to the given address. Useful when loading raw binaries (not ELFs).
-	`load`: Loads a file from a filesystem to an arbitrary address.
-	`loady`: Loads a file over the [ymodem protocol](https://en.wikipedia.org/wiki/YMODEM) to an arbitrary address.
-	`md`: Gives a hexdump of an arbitrary address. Note that it displays in little endian. Also callable as `md.b`, `md.w`, `md.l`, `md.q` to display with different widths for atoms of data.

Toolchain
=========

You'll need at least binutils for the `aarch64-none-elf` target. On Gentoo, this is fairly easy with [crossdev](https://wiki.gentoo.org/wiki/Crossdev). It'll also probably be useful to have your system binutils be built multitarget; this doesn't apply to `gas`, though, so the `aarch64-none-elf` versions are still necessary.

Writing to the UART
===================

The RK3399's [Technical Reference Manual](http://opensource.rock-chips.com/images/e/ee/Rockchip_RK3399TRM_V1.4_Part1-20170408.pdf) is your friend for all of this; it notes that UART2 is mapped to `0xff1a0000`. There's also some information on how to interface with the chip; if you're familar with programming the [8250](https://en.wikipedia.org/wiki/8250_UART) or [16550](https://en.wikipedia.org/wiki/16550_UART) UARTs, I believe it's effectively the latter. (Note that unlike how x86 serial ports are typically connected, the UARTs in the Pinebook Pro are all memory-mapped.)

We can write to the UART with an assembly sequence like:

```armasm
ldr x0, =0xff1a0000 /* Load the x0 register with 0xff1a0000 */
mov x1, '!'         /* Load the x1 register with '!' (zero-extended) */
strb w1, [x0]       /* Store the value in x1 to the address given by x0 */
```

This stores the `!` character in the Transmit Holding Register of the UART. Technically, we need to wait for the Transmit Holding Register Empty Bit of the Line Status Register to be 1. We do this with:

```armasm
	ldr x0, =0xff1a0000
wait_for_tx_ok:
	ldrb w1, [x0, #0x14]      /* Offset the address in x0 by 0x14 */
	tbz w1, 5, wait_for_tx_ok /* Loop if bit 5 of x1 is zero */
```

Of course, a real OS should use the FIFOs, be interrupt-triggered, and maybe even use DMA. That's outside the scope of this article, but I'll probably touch on it in a future post.

Putting it All Together
=======================

We can use the above with a bit of glue code to make our "Hello, world" program:

```armasm
.section .text

.global _start
_start:
	ldr x0, =0xff1a0000
	ldr x3, =msg
	mov x4, len
	bl write_string     /* Call the write_string procedure */
	b .                 /* Infinite loop */

/** write_string: Writes a string to a UART
 *
 * Input:
 *   x0: UART base address
 *   x3: Address of first character of string
 *   x4: Length of string
 *
 * Side Effects:
 * - Trashes x1, x2, x5
 */
write_string:
	cbz x4, write_string.end /* If x4 is zero, go to write_string.end */

write_string.wait_for_tx_ok:
	ldrb w1, [x0, #0x14]
	tbz w1, 5, write_string.wait_for_tx_ok

	ldrb w2, [x3], #1 /* After fetching a byte to w2, increment x3 */
	sub x4, x4, 1     /* Decrement x4 */
	strb w2, [x0]

	b write_string
write_string.end:
	ret

.section .rodata

msg: .string "Hello, world!\r\n"
.equ len, . - msg
```

We also need a linker script for this:

```ld
OUTPUT_FORMAT(elf64-littleaarch64)
ENTRY(_start)

MEMORY {
	kernel : ORIGIN = 0x00280000, LENGTH = 0x00080000
}

SECTIONS {
	.text : {
		. += SIZEOF_HEADERS;
		*(.text)
	} > kernel
	.rodata : { *(.rodata) } > kernel
}
```

We compile and link with:

```
aarch64-none-elf-as -o main.o main.s
aarch64-none-elf-ld -o main.elf -T linker.ld main.o -N -z max-page-size=4096
```

Aside: Tricks for a Smaller Executable
--------------------------------------

Thanks to `clever` and `doug16k` in the `#osdev` channel on Freenode for showing me a couple of tricks to reduce the size of the ELF file:

-	Adding `. += SIZEOF_HEADERS;` to the first section, and passing `-N` to `ld` lets LD overlap the `.text` section with the ELF header itself.
-	Passing `-z max-page-size=4096` to `ld` lets it only align the sections to 4k instead of 64k.

This brings the binary size down from 66k to 1.3k.

Hello, world!
=============

Finally, we're ready to run our program. Connect the Pinebook Pro to your serial port, connect Minicom to the serial port, and boot it. Hit a key to drop to the U-Boot shell, then run `loady 0x00880000` to start the upload. Hit Ctrl-A, S to open Minicom's "Send files" menu. Once the file is uploaded, run `bootelf 0x00880000`. If all's gone well, you should see `Hello, world!` printed, followed by the machine hanging.

{{ asciinema(297430) }}
