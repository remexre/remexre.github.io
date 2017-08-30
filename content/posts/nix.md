+++
date = "2017-08-30"
publishDate = "2017-08-30"
tags = ["CLI", "Guides", "UMN"]
title = "Installing the Nix Package Manager on UMN Machines"
+++

Sometimes, you want to install a package to mess around with, or want to install something not in the Ubuntu repos.
You *could* email the operator, or you could install it to your home directory.
If you go down the install-to-home-directory path, you tend to learn a lot about why people use package managers ([dependency hell](https://en.wikipedia.org/wiki/Dependency_hell), [uninstallation woes](https://stackoverflow.com/questions/1439950/#answer-1439989), etc.).
The [Nix](https://nixos.org/nix/) package manager is a purely functional (which means it's inherently good, of course) package manager that supports installing packages to the home folder, when compiled correctly.
This is a howto for setting up Nix on the CS machines.

# Compiling Nix

The default Nix installation tries to install packages to `/nix`, which you (as a non-root user) can't write to or create.
This can be changed relatively easily with a compile-time flag, though.
Note that Nix will still build all packages from source, however; the binary packages are compiled assuming that they will live in `/nix`.
I'm not aware of any way to get around this, with Nix or other package management systems (without needing root, of course).

## APT Dependencies

From a barebones Ubuntu install, the following APT packages should be installed:

 - autoconf
 - bison
 - curl
 - flex
 - libbz2-dev
 - libcurl4-openssl-dev
 - liblzma-dev
 - libseccomp-dev
 - libsqlite3-dev
 - libssl-dev
 - pkg-config

On the CS machines, I *believe* the only one that needs to be installed is `libseccomp-dev`.
`cs-kona.cs` already has it, so if you don't want to ask the operators to install it, you can SSH to that machine to do the build.
(Note: You don't need `libseccomp-dev` to run Nix, only to build it.)

## Perl Dependencies

Nix's Perl dependencies don't require root to install, thankfully.
First, we install `cpanm`:

```shell
cpan App::cpanminus
```

It will ask you if you want to use the default options; you do.

Next, install the curl and SQLite bindings:

```shell
cpanm DBD::SQLite
cpanm WWW::Curl
```

## Building and Installing

Nix is fairly standard to build, once you have the dependencies:

```shell
curl -L https://nixos.org/releases/nix/nix-1.11.13/nix-1.11.13.tar.xz | tar xJ
cd nix-1.11.13
./configure --prefix="${HOME}/.local" --with-store-dir="${HOME}/.nix/store" \
	--localstatedir="${HOME}/.nix/var" --disable-doc-gen
make
make install
```

# Getting Ready to Use Nix

## Adjusting your `~/.profile`

After this section, remember to log out and back in!

### Adding `~/.local/*` to your path variables

Add the following lines to your `~/.profile`:

```shell
export LIBRARY_PATH="${HOME}/.local/lib"
export MANPATH="${HOME}/.local/share/man:${MANPATH:-$(manpath)}";
export PATH="${HOME}/.local/bin:${PATH}";
```

This ensures that things installed to `~/.local` (including Nix) can be accessed by the rest of the system.

### Changing `$TMPDIR`

Add the following two lines to your `~/.profile`.

```shell
export TMPDIR="/export/scratch/$(whoami)-tmp"
mkdir -p "${TMPDIR}"
```

`$TMPDIR` sets the directory for temporary build files.
By default, this is `/tmp`.
However, `/tmp` is only a couple of gigabytes on most lab systems (2 on my machine), which isn't enough space for GCC to successfully build.
By changing the build directory to be in `/export/scratch`, we build on the machine's disk, which usually has hundreds of gigabytes free.
Nix also deletes temporary files after a build, so don't worry about needing to do that yourself.

### Adding Nix's `profile` changes

Nix installs things to paths that are probably not in your `PATH` yet.
To remedy this, add the following line to the end of your `~/.profile`:

```shell
source ~/.local/etc/profile.d/nix.sh
```

### zsh-specific tweak

If you use zsh, run

```shell
ls -s ~/.profile ~/.zprofile
```

`zsh` prefers to have profile settings in `~/.zprofile` instead.

## Adding a channel

By default, Nix does not have any repositories (or in Nix parlance, *channels*) added.
This can be remedied by adding the `nixpkgs-unstable` channel:

```shell
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
```

# Installing Packages

A good test installation is [GNU Hello](https://www.gnu.org/software/hello/), an implementation of Hello World from the GNU project that exercises most of the GNU build system.
It can be installed with:

```shell
nix-env -i hello
```

This will probably take a while -- it builds glibc, GCC, and the kernel headers, and does a lot of other (thankfully one-time) time-consuming tasks.
You might want to leave it overnight.

After it completes, you should be able to run `hello` and get `Hello, world!` in response.
