# Nix shell expression for the oil shell (formatted with nixfmt)
#   Note: run `nixfmt shell.nix` in nix-shell to reformat in-place
#
# By default fetch the most-recent 19.09 version of the stable NixOS release.
# This should be fine, but if it causes trouble it can be pinned to ensure
# everyone is running exactly the same versions.
{ pkgs ? import ./nixpkgs.nix, dev ? "all", test ? "smoke", cleanup ? true }:

let
  shells = import ./test_shells.nix { inherit pkgs; };
  drv = import ./default.nix { inherit pkgs; };
  deps = import ./oil_deps.nix { inherit pkgs; };
  # Added the following 3 declarations (and parameters/defaults above) to
  # demonstrate how you could make the behavior a little configurable.
  #
  # By default, it will run:
  # - "all" dev build (--argstr dev minimal or none to disable)
  # - the "smoke" tests (--argstr test osh-all or none to disable)
  # - and clean on exit (ex: --argstr cleanup none to disable)
  build_oil = if dev == "none" then
    "echo Skipping Oil build."
  else ''
    echo Building \'${dev}\' Oil.
    "$PWD/build/dev.sh" ${dev}
  '';
  test_oil = if test == "none" then
    "echo Skipping Oil tests."
  else ''
    echo Running Oil \'${test}\' tests.
    "$PWD/test/spec.sh" ${test}
  '';
  cleanup_oil = if cleanup == "none" then ''
    echo "Note: nix-shell will *NOT* clean up Oil dev build on exit!"
    trap 'echo "NOT cleaning up Oil dev build."' EXIT
  '' else ''
    echo "Note: nix-shell will clean up the dev build on exit."
    trap 'echo "Cleaning up Oil dev build."; "$PWD/build/dev.sh" clean' EXIT
  '';
in with pkgs;

# Create a shell with packages we need.
mkShell rec {
  # pull most deps from default.nix
  buildInputs = drv.buildInputs ++ [
    nixfmt # `nixfmt *.nix` to format in place
  ];

  # Note: Nix automatically adds identifiers declared here to the environment!
  _NIX_SHELL_LIBCMARK =
    "${cmark}/lib/libcmark${stdenv.hostPlatform.extensions.sharedLibrary}";

  # Need nix to relax before it'll link against a local file.
  NIX_ENFORCE_PURITY = 0;
  LANG = "en_US.UTF-8";

  # can just tell the tests where the shells are since we already know
  OIL_TEST_SHELL_DASH = "${shells.test_dash}/bin/dash";
  OIL_TEST_SHELL_BASH = "${shells.test_bash}/bin/bash";
  OIL_TEST_SHELL_MKSH = "${shells.test_mksh}/bin/mksh";
  OIL_TEST_SHELL_ZSH = "${shells.test_zsh}/bin/zsh";
  OIL_TEST_SHELL_ASH =
    pkgs.lib.optionalString stdenv.isLinux "${shells.test_busybox}/bin/ash";

  # do setup work you want to do every time you enter the shell
  # Here are a few ideas that made sense to me:
  shellHook = ''
    ${if glibcLocales != null then
      "export LOCALE_ARCHIVE='${glibcLocales}/lib/locale/locale-archive'"
    else
      ""}

    if [[ ! -a "$PWD/py-yajl/setup.py" ]]; then
      git submodule update --init --recursive
    fi

    if [[ ! -a "$PWD/libc.so" ]]; then
      ${build_oil}
      ${test_oil}
    else
      echo "Dev build already exists. If you made changes, run:"
      echo "    'build/dev.sh clean' and "
      echo "    'build/dev.sh all' or 'build/dev.sh minimal'"
    fi

    ${cleanup_oil}

    echo NIX_SHELL LC_CTYPE=$LC_CTYPE
  '';
}
