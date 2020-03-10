# Nix shell expression for the oil shell (formatted with nixfmt)
#   Note: run `nixfmt shell.nix` in nix-shell to reformat in-place
#
# By default fetch the most-recent 19.09 version of the stable NixOS release.
# This should be fine, but if it causes trouble it can be pinned to ensure
# everyone is running exactly the same versions.
{ pkgs ? import ./nixpkgs.nix }:


with pkgs; let
  shells = import ./test_shells.nix { inherit pkgs; };
  deps = import ./oil_deps.nix { inherit pkgs; };

# Standard builder from Nixpkgs that we use to build oil
in python27Packages.buildPythonPackage rec {

  pname = "oil";
  version = "undefined";
  allowSubstitutes = false;
  # Take the current folder
  src = ./.;

  # or take the git repo
  # src = builtins.fetchGit ./.;

  # or get it from a git commit
  # src = fetchFromGitHub {
  #   owner = "oilshell";
  #   repo = "oil";
  #   rev = "c40f53898db021bdb9dbd3fcbcfb11201fe92fe6";
  #   sha256 = "1jhczk0cr8v0h0vi3k2m9a61hgdaxlf1nrfbkz8ks5k7xw58mwss";
  #   fetchSubmodules = true;
  # };
  buildInputs = deps.buildInputs;
  nativeBuildInputs = deps.binary ++ deps.commands ++ [ deps.oilPython deps.py-yajl ];
  propagatedBuildInputs = [ re2c deps.oilPython deps.py-yajl ];  #configureFlags = [ "--with-readline" ];

  checkInputs = with shells; [ test_bash test_dash test_mksh test_zsh ] ++ [ deps.oilPython deps.py-yajl mypy ] ++ lib.optionals (stdenv.isLinux) [ shells.test_busybox ];
  doCheck = true;
  dontStrip = true;

  # Cannot build wheel otherwise (zip 1980 issue)
  SOURCE_DATE_EPOCH=315532800;

  LOCALE_ARCHIVE = pkgs.lib.optionalString (buildPlatform.libc == "glibc") "${glibcLocales}/lib/locale/locale-archive";
  LC_CTYPE= pkgs.lib.optionalString stdenv.isDarwin "UTF-8";
  LANG="en_US.UTF-8";

  preBuild = ''
    build/dev.sh all
  '';

  # Patch shebangs so Nix can find all executables
  postPatch = ''
    patchShebangs asdl benchmarks build core doctools frontend native oil_lang spec test types
    #substituteInPlace build/dev.sh --replace "native/libc_test.py" "# native/libc_test.py"
    #substituteInPlace build/codegen.sh --replace "re2c() { _deps/re2c-1.0.3/re2c" "# re2c() { _deps/re2c-1.0.3/re2c"
    substituteInPlace test/spec.sh --replace 'readonly REPO_ROOT=$(cd $(dirname $0)/..; pwd)' "REPO_ROOT=$out"
  '';

  dontWrapPythonPrograms = true;

  postInstall = ''
    mkdir -p $out/_devbuild/gen/ $out/_devbuild/help/
    install _devbuild/gen/*.marshal $out/_devbuild/gen/
    install _devbuild/help/* $out/_devbuild/help/
    install oil-version.txt $out/${deps.oilPython.sitePackages}/

    buildPythonPath "$out $propagatedBuildInputs"

    for executable in oil osh; do
      makeWrapper $out/bin/oil.py $out/bin/$executable \
        --add-flags $executable \
        --prefix PATH : "$program_PATH" \
        --prefix PYTHONPATH : "$program_PYTHONPATH" \
        --set _OVM_RESOURCE_ROOT "$out/${deps.oilPython.sitePackages}" \
        --set PYTHONNOUSERSITE true ${if glibcLocales != null then
        " --run \"export LOCALE_ARCHIVE='${glibcLocales}/lib/locale/locale-archive' LC_CTYPE='C.UTF-8'\""
        else ""}
      substituteInPlace $out/bin/$executable --replace "${bash}/bin/bash" "${shells.bang_bash}/bin/bash"
    done
  '';

  # can just tell the tests where the shells are since we already know
  OIL_TEST_SHELL_DASH = "${shells.test_dash}/bin/dash";
  OIL_TEST_SHELL_BASH = "${shells.test_bash}/bin/bash";
  OIL_TEST_SHELL_MKSH = "${shells.test_mksh}/bin/mksh";
  OIL_TEST_SHELL_ZSH = "${shells.test_zsh}/bin/zsh";
  OIL_TEST_SHELL_ASH = pkgs.lib.optionalString stdenv.isLinux "${shells.test_busybox}/bin/ash";

  checkPhase = ''
    env | grep OIL_TEST_SHELL
    # status=0
    # if ./test.sh > test_output ; then
    #   mkdir -p $out/_tmp/spec/ _tmp/spec/
    #   cp -r _tmp/spec/ $out/_tmp/
    #   cp test_output $out/test_output
    # else
    #   status=$?
    # fi
    # echo "---- START TEST OUTPUT (status: $status) ----"
    # cat test_output
    # echo "----   END TEST OUTPUT (status: $status) ----"
    # exit $status
  '';

  # Note: Nix automatically adds identifiers declared here to the environment!
  prePatch = ''
    substituteInPlace ./doctools/cmark.py --replace "/usr/local/lib/libcmark.so" "${cmark}/lib/libcmark${stdenv.hostPlatform.extensions.sharedLibrary}"
  '';
}