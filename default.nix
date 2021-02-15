let
  pkgs = import <nixpkgs> {};
  fib = import ./fib/default.nix;
in

pkgs.stdenv.mkDerivation {
  name = "remexre.github.io";
  src = pkgs.nix-gitignore.gitignoreSource [] ./.;
  buildInputs = [ pkgs.deno fib pkgs.graphviz ];
  # sigh... waiting on deno 1.7.x to be in nixpkgs......
  # buildPhase = "fib --out $out";
  buildPhase = ''
    export DENO_DIR=$TMPDIR/deno-dir
    mkdir -p $DENO_DIR
    cp -r ${(import ./fib/nix/deno.nix { lockFile = ./fib/lock.json; }).deps}/deps -t $DENO_DIR
    deno run --allow-read --allow-run --allow-write --unstable fib/src/main.ts --out $out
  '';
  installPhase = "true";
}
