# Nix shell expression for the oil shell (formatted with nixfmt)
#   Note: run `nixfmt shell.nix` in nix-shell to reformat in-place
#
# By default fetch the most-recent 19.09 version of the stable NixOS release.
# This should be fine, but if it causes trouble it can be pinned to ensure
# everyone is running exactly the same versions.
{ pkgs ? import ./nixpkgs.nix }:

let
  drv = import ./default.nix { inherit pkgs; };
in with pkgs;

# build shell atop derivation from default.nix
drv.overrideAttrs (attrs: {
  src = null;
  buildInputs = attrs.buildInputs ++ [
    nixfmt # `nixfmt *.nix` to format in place
  ];
  # Note: Nix automatically adds identifiers declared here to the environment!
  _NIX_SHELL_LIBCMARK = "${cmark}/lib/libcmark${stdenv.hostPlatform.extensions.sharedLibrary}";

  # Need nix to relax before it'll link against a local file.
  NIX_ENFORCE_PURITY = 0;
  LOCALE_ARCHIVE = pkgs.lib.optionalString (buildPlatform.libc == "glibc") "${glibcLocales}/lib/locale/locale-archive";
  LC_CTYPE= pkgs.lib.optionalString stdenv.isDarwin "UTF-8";
  LANG="en_US.UTF-8";
})
