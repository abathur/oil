# This file just defines non-oil/osh shells we need to build to run the tests.
{ pkgs ? import nix/nixpkgs.nix }:

with pkgs; stdenv.mkDerivation rec {
  # when we use pkgs.mkShell, nix doesn't need a name
  # when it's building a true package, the name is required.
  # I don't know the objectives here, so I'm just building it as a package for simplicity.
  name = "NIX_WANTS_A_NAME";
  src = ./.;
  buildInputs = [
    python27
    (python37.withPackages (ps: with ps; [ mypy ]))
  ];
  buildPhase = ''
    cd mycpp
    # The existing hard-coded clang stuff is in the way
    # I just hard-patched it to "clang++"
    type clang
    ./run.sh build-all      # translate and compile all examples
    ./run.sh test-all       # check for correctness
    ./run.sh benchmark-all  # compare speed
  '';
}
