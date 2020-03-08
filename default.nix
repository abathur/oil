# Nix shell expression for the oil shell (formatted with nixfmt)
#   Note: run `nixfmt shell.nix` in nix-shell to reformat in-place
#
# By default fetch the most-recent 19.09 version of the stable NixOS release.
# This should be fine, but if it causes trouble it can be pinned to ensure
# everyone is running exactly the same versions.
{ pkgs ? import (fetchTarball "channel:nixos-19.09") {} }:


with pkgs; let
  py-yajl = python27Packages.buildPythonPackage rec {
    pname = "oil-pyyajl";
    version = "unreleased";
    src = fetchFromGitHub {
      owner = "oilshell";
      repo = "py-yajl";
      rev = "eb561e9aea6e88095d66abcc3990f2ee1f5339df";
      sha256 = "17hcgb7r7cy8r1pwbdh8di0nvykdswlqj73c85k6z8m0filj3hbh";
      fetchSubmodules = true;
    };
    nativeBuildInputs = [ git ];
  };

  test_busybox = busybox-sandbox-shell.overrideAttrs (oldAttrs: rec {
    name = "busybox-1.31.1";
    src = fetchurl {
      url = "https://busybox.net/downloads/${name}.tar.bz2";
      sha256 = "1659aabzp8w4hayr4z8kcpbk2z1q2wqhw7i1yb0l72b45ykl1yfh";
    };
  });

  bang_bash = bash.overrideAttrs (oldAttrs: rec{
    buildInputs = oldAttrs.buildInputs ++ [ makeWrapper ];
    outputs = ["out"];
    postPatch = ''
      substituteInPlace shell.c --replace "unbind_variable" "// unbind_variable"
    '';
    # postInstall = ''
    #   wrapProgram "$out/bin/bash" ${if glibcLocales != null then
    #     "--run "export LOCALE_ARCHIVE='${glibcLocales}/lib/locale/locale-archive' LC_CTYPE='C.UTF-8'""
    #     else ""}
    # '' + (oldAttrs.postInstall or "");
  });

  interactive_bash = bash.override { interactive = true; };
  test_bash = interactive_bash.overrideAttrs (oldAttrs: rec{
    configureFlags = lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
      "bash_cv_job_control_missing=nomissing"
      "bash_cv_sys_named_pipes=nomissing"
      "bash_cv_getcwd_malloc=yes"
    ] ++ lib.optionals stdenv.hostPlatform.isCygwin [
      "--without-libintl-prefix"
      "--without-libiconv-prefix"
      "--enable-readline"
      "bash_cv_dev_stdin=present"
      "bash_cv_dev_fd=standard"
      "bash_cv_termcap_lib=libncurses"
    ] ++ lib.optionals (stdenv.hostPlatform.libc == "musl") [
      "--without-bash-malloc"
      "--disable-nls"
    ];
    buildInputs = [ makeWrapper ];
    outputs = ["out"];
    postInstall = if glibcLocales != null then ''
      wrapProgram "$out/bin/bash" --run "export LOCALE_ARCHIVE='${glibcLocales}/lib/locale/locale-archive' LC_CTYPE='C.UTF-8'"
      substituteInPlace $out/bin/bash --replace "$runtimeShell" "${bang_bash}/bin/bash"
    '' else "" + (oldAttrs.postInstall or "");
  });

  test_dash = dash.overrideAttrs (oldAttrs: rec {
    name = "dash-0.5.8";

    src = fetchurl {
      url = "http://gondor.apana.org.au/~herbert/dash/files/${name}.tar.gz";
      sha256 = "03y6z8akj72swa6f42h2dhq3p09xasbi6xia70h2vc27fwikmny6";
    };
    buildInputs = [ makeWrapper ];
    postInstall = if glibcLocales != null then ''
      wrapProgram "$out/bin/dash" --run "export LOCALE_ARCHIVE='${glibcLocales}/lib/locale/locale-archive' LC_CTYPE='C.UTF-8'"
      substituteInPlace $out/bin/dash --replace "${bash}/bin/bash" "${bang_bash}/bin/bash"
    '' else "" + (oldAttrs.postInstall or "");
  });

  test_mksh = mksh.overrideAttrs (oldAttrs: rec {
    version = "52";
    src = fetchurl {
      urls = [
        "https://www.mirbsd.org/MirOS/dist/mir/mksh/mksh-R${version}.tgz"
        "http://pub.allbsd.org/MirOS/dist/mir/mksh/mksh-R${version}.tgz"
      ];
      sha256 = "13vnncwfx4zq3yi7llw3p6miw0px1bm5rrps3y1nlfn6sb6zbhj5";
    };
    buildInputs = [ makeWrapper ];
    preFixup = if glibcLocales != null then ''
      wrapProgram "$out/bin/mksh" --run "export LOCALE_ARCHIVE='${glibcLocales}/lib/locale/locale-archive' LC_CTYPE='C.UTF-8'"
      substituteInPlace $out/bin/mksh --replace "${bash}/bin/bash" "${bang_bash}/bin/bash"
    '' else "" + (oldAttrs.preFixup or "");
  });

  test_zsh = zsh.overrideAttrs (oldAttrs: rec {
    version = "5.1.1";

    src = fetchurl {
      url = "mirror://sourceforge/zsh/zsh-${version}.tar.xz";
      sha256 = "1v1xilz0fl9r9c7dr2lnn7bw6hfj0gbcz4wz1ybw1cvhahxlbsbl";
    };
    buildInputs = oldAttrs.buildInputs ++ [ makeWrapper ];
    postInstall = if glibcLocales != null then ''
      wrapProgram "$out/bin/zsh" --run "export LOCALE_ARCHIVE='${glibcLocales}/lib/locale/locale-archive' LC_CTYPE='C.UTF-8'"
      substituteInPlace $out/bin/zsh --replace "${bash}/bin/bash" "${bang_bash}/bin/bash"
    '' else "" + (oldAttrs.postInstall or "");
  });

  # Most of the items you listed in #513 are here now. I'm not sure what the
  # remaining items here mean, so I'm not sure if they're covered.
  #
  # static analysis
  #   mypy library for mycpp
  # benchmarks
  #   ocaml configure, etc. This is just source though.
  # C deps
  #   python headers for bootstrapping
  # big one: Clang for ASAN and other sanitizers (even though GCC has some)
  #   Clang for coverage too

  # nixpkgs: busybox linux only; no smoosh
  # could append something like: ++ lib.optionals stdenv.isLinux [ busybox ]
  spec_tests = [ test_bash test_dash test_mksh test_zsh ];

  oilPython = python27.withPackages (ps: with ps; [ flake8 pyannotate six typing ]);

  static_analysis = [
    mypy # This is the Python 3 version
    oilPython
    # python3Packages.black # wink wink :)
  ];

  binary = [ re2c ];
  doctools = [ cmark ];
  c_deps = [ readline ];

  shell_deps = [
    gawk
    time
    # additional command dependencies I found as I went
    # guessing they go here...
    # run with nix-shell --pure to make missing deps easier to find!
    file
    git
    hostname
    which
  ];

  nix_deps = [
    nixfmt # `nixfmt shell.nix` to format in place
    makeWrapper
  ];

# Standard builder from Nixpkgs that we use to build oil
in python27Packages.buildPythonPackage rec {

  pname = "oil";
  version = "undefined";
  allowSubstitutes = false;
  # Take the current folder
  # src = lib.sourceByRegex ./. ["[^_].*" "_devbuild"];

  # or take from github
  # src = builtins.fetchGit ./.;
  src = ./.;
  # src = fetchFromGitHub {
  #     owner = "abathur";
  #     repo = "oil";
  #     rev = "259e582598689cb5077c44819f3234dda79c34fa";
  #     sha256 = "0rx68y8r82sr8qmbr806iaz2pispn02f64k6xywxpj5lx05jynlz";
  #   };
  # src = fetchFromGitHub {
  #   owner = "oilshell";
  #   repo = "oil";
  #   rev = "c40f53898db021bdb9dbd3fcbcfb11201fe92fe6";
  #   sha256 = "1jhczk0cr8v0h0vi3k2m9a61hgdaxlf1nrfbkz8ks5k7xw58mwss";
  #   fetchSubmodules = true;
  # };

  buildInputs = c_deps ++ binary ++ spec_tests ++ static_analysis ++ doctools
    ++ shell_deps ++ nix_deps ++ doctools ++ [py-yajl];
  nativeBuildInputs = binary ++ shell_deps ++ [ oilPython py-yajl ];
  propagatedBuildInputs = [ re2c oilPython py-yajl ];  #configureFlags = [ "--with-readline" ];

  checkInputs = [ test_bash test_dash test_mksh test_zsh oilPython py-yajl mypy ] ++ lib.optionals (stdenv.isLinux) [ test_busybox ];
  doCheck = true;
  dontStrip = true;

  # Cannot build wheel otherwise (zip 1980 issue)
  SOURCE_DATE_EPOCH=315532800;

  LOCALE_ARCHIVE = pkgs.lib.optionalString (buildPlatform.libc == "glibc") "${glibcLocales}/lib/locale/locale-archive";
  # LC_CTYPE="en_US.UTF-8";
  LC_CTYPE= pkgs.lib.optionalString stdenv.isDarwin "UTF-8";
  LANG="en_US.UTF-8";

  #dontConfigure = true;
  preBuild = ''
    build/dev.sh all
  '';
  # buildPhase = ''
  #   set -x
  #   build/dev.sh all
  #   set +x
  # '';

  # Patch shebangs so Nix can find all executables
  postPatch = ''
    patchShebangs build asdl frontend oil_lang native doctools test spec core types
    #substituteInPlace build/dev.sh --replace "native/libc_test.py" "# native/libc_test.py"
    #substituteInPlace build/codegen.sh --replace "re2c() { _deps/re2c-1.0.3/re2c" "# re2c() { _deps/re2c-1.0.3/re2c"
    substituteInPlace test/spec.sh --replace 'readonly REPO_ROOT=$(cd $(dirname $0)/..; pwd)' "REPO_ROOT=$out"
  '';

  dontWrapPythonPrograms = true;

  postInstall = ''
    mkdir -p $out/_devbuild/gen/ $out/_devbuild/help/
    install _devbuild/gen/*.marshal $out/_devbuild/gen/
    install _devbuild/help/* $out/_devbuild/help/
    install oil-version.txt $out/${oilPython.sitePackages}/

    buildPythonPath "$out $propagatedBuildInputs"

    for executable in oil osh; do
      makeWrapper $out/bin/oil.py $out/bin/$executable \
        --add-flags $executable \
        --prefix PATH : "$program_PATH" \
        --prefix PYTHONPATH : "$program_PYTHONPATH" \
        --set _OVM_RESOURCE_ROOT "$out/${oilPython.sitePackages}" \
        --set PYTHONNOUSERSITE true ${if glibcLocales != null then
        " --run \"export LOCALE_ARCHIVE='${glibcLocales}/lib/locale/locale-archive' LC_CTYPE='C.UTF-8'\""
        else ""}
      substituteInPlace $out/bin/$executable --replace "${bash}/bin/bash" "${bang_bash}/bin/bash"
    done
  '';

  # makeWrapper $out/bin/oil.py $out/bin/osh \
      # --add-flags osh \
      # ${if glibcLocales != null then "--set LOCALE_ARCHIVE \"${glibcLocales}/lib/locale/locale-archive\"" else ""} \
      # --run 'export PS1="xxx"'


  # can just tell the tests where the shells are since we already know
  OIL_TEST_SHELL_DASH = "${test_dash}/bin/dash";
  OIL_TEST_SHELL_BASH = "${test_bash}/bin/bash";
  OIL_TEST_SHELL_MKSH = "${test_mksh}/bin/mksh";
  OIL_TEST_SHELL_ZSH = "${test_zsh}/bin/zsh";
  OIL_TEST_SHELL_ASH = pkgs.lib.optionalString stdenv.isLinux "${test_busybox}/bin/ash";

  checkPhase = ''
    env | grep OIL_TEST_SHELL
    status=0
    if ./test.sh > test_output ; then
      mkdir -p $out/_tmp/spec/ _tmp/spec/
      cp -r _tmp/spec/ $out/_tmp/
      cp test_output $out/test_output
    else
      status=$?
    fi
    echo "---- START TEST OUTPUT (status: $status) ----"
    cat test_output
    echo "----   END TEST OUTPUT (status: $status) ----"
    exit $status
  '';

  # Not sure if this is "right" (for nix, other platforms, etc.)
  # doctools/cmark.py hardcoded /usr/local/lib/libcmark.so, and it looks
  # like Nix has as much trouble with load_library as you have. For a
  # "build" I think we'd use a patchPhase to replace the hard path
  # in cmark.py with the correct one. Since we can't patch the source here
  # I'm hacking an env in here and in cmark.py. Hopefully others will
  # weigh in if there's a better way to handle this.
  #
  # Note: Nix automatically adds identifiers declared here to the environment!
  prePatch = ''
    substituteInPlace ./doctools/cmark.py --replace "/usr/local/lib/libcmark.so" "${cmark}/lib/libcmark${stdenv.hostPlatform.extensions.sharedLibrary}"
  '';



  meta = {
    description = "A new unix shell";
    homepage = https://www.oilshell.org/;
    license = with lib.licenses; [
      psfl # Includes a portion of the python interpreter and standard library
      asl20 # Licence for Oil itself
    ];
  };

  passthru = {
    shellPath = "/bin/osh";
  };

}
