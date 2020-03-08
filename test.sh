# test/spec.sh smoke
# test/lint.sh travis
# types/oil-slice.sh travis
# test/unit.sh all
# test/spec.sh oil-json
# test/spec.sh interactive

# test/spec.sh oil-all-serial -v --format=sane
# test/spec.sh osh-all-serial -v --format=sane
# test/spec.sh builtin-completion -v

# DOING: you went through all the work of making an interactive bash, but it seems like maybe it broke more than it fixed; maybe the test just needed to use -i -c? (NO, THIS DOESN'T SEEM TO HELP)
# OR WAIT; maybe this is just exposing a break that was already there?

# test/spec.sh arith -v --format=sane
# test/spec.sh array -v --format=sane
# test/spec.sh brace-expansion -v --format=sane
# test/spec.sh builtin-bash -v --format=sane
# test/spec.sh builtin-completion -v --format=sane
# test/spec.sh builtin-dirs -v --format=sane
# test/spec.sh builtin-printf -v --format=sane
# test/spec.sh builtins -v --format=sane
# test/spec.sh case_ -v --format=sane
# test/spec.sh command_ -v --format=sane
# test/spec.sh dbracket -v --format=sane
# test/spec.sh extglob-match -v --format=sane
# test/spec.sh glob -v --format=sane
# test/spec.sh loop -v --format=sane
# test/spec.sh pipeline -v --format=sane
# test/spec.sh prompt -v --format=sane
# test/spec.sh quote -v --format=sane
# test/spec.sh regex -v --format=sane
# test/spec.sh sh-options -v --format=sane
# test/spec.sh tilde -v --format=sane
# test/spec.sh var-op-bash -v --format=sane
# test/spec.sh var-op-len -v --format=sane
# test/spec.sh var-op-patsub -v --format=sane
# test/spec.sh var-op-strip -v --format=sane
# test/spec.sh var-sub -v --format=sane
# test/spec.sh word-eval -v --format=sane
# test/spec.sh word-split -v --format=sane

# test/spec.sh builtin-dirs -v --format=sane -r 6
# test/spec.sh builtin-dirs -v -r 6
# test/spec.sh glob -v
# test/spec.sh brace-expansion -v -r 29

# test/spec.sh oil-array --format=diffable
# test/spec.sh oil-assign --format=diffable
# test/spec.sh oil-bin --format=diffable
# test/spec.sh oil-blocks --format=diffable
# test/spec.sh oil-builtin-funcs --format=diffable
# test/spec.sh oil-builtins --format=diffable
# test/spec.sh oil-demo --format=diffable
# test/spec.sh oil-expr-sub --format=diffable
# test/spec.sh oil-expr --format=diffable
# test/spec.sh oil-func-proc --format=diffable
# test/spec.sh oil-interactive --format=diffable
# test/spec.sh oil-json --format=diffable
# test/spec.sh oil-keywords --format=diffable
# test/spec.sh oil-options -v --format=ansi
# test/spec.sh oil-regex --format=diffable
# test/spec.sh oil-slice-range --format=diffable
# test/spec.sh oil-tuple --format=diffable
# test/spec.sh alias --format=diffable
# test/spec.sh append --format=diffable
# test/spec.sh arith-context --format=diffable
# test/spec.sh arith --format=diffable
# test/spec.sh array-compat --format=diffable
# test/spec.sh array --format=diffable
# test/spec.sh assign-deferred --format=diffable
# test/spec.sh assign-dialects --format=diffable
# test/spec.sh assign-extended --format=diffable
# test/spec.sh assign --format=diffable
# test/spec.sh assoc-zsh --format=diffable
# test/spec.sh assoc --format=diffable
# test/spec.sh background --format=diffable
# test/spec.sh blog1 --format=diffable
# test/spec.sh blog2 --format=diffable
test/spec.sh brace-expansion -v --format=ansi -r 29
# test/spec.sh bugs --format=diffable
# test/spec.sh builtin-bash --format=diffable
# test/spec.sh builtin-bracket --format=diffable
# test/spec.sh builtin-completion --format=ansi
# test/spec.sh builtin-dirs -v --format=diffable
# test/spec.sh builtin-eval-source --format=diffable
# test/spec.sh builtin-getopts --format=diffable
# test/spec.sh builtin-io --format=diffable
# test/spec.sh builtin-printf --format=diffable
# test/spec.sh builtin-special --format=diffable
# test/spec.sh builtin-times --format=diffable
# test/spec.sh builtin-trap --format=diffable
# test/spec.sh builtin-vars --format=diffable
# test/spec.sh builtins --format=diffable
# test/spec.sh builtins2 --format=diffable
# test/spec.sh case_ --format=diffable
# test/spec.sh command-parsing --format=diffable
# test/spec.sh command-sub --format=diffable
# test/spec.sh command_ --format=diffable
# test/spec.sh comments --format=diffable
# test/spec.sh dbracket --format=diffable
# test/spec.sh dparen --format=diffable
# test/spec.sh empty-bodies --format=diffable
# test/spec.sh errexit-oil --format=diffable
# test/spec.sh errexit --format=diffable
# test/spec.sh exit-status --format=diffable
# test/spec.sh explore-parsing --format=diffable
# test/spec.sh extglob-match --format=diffable
# test/spec.sh for-expr --format=diffable
# test/spec.sh func-parsing --format=diffable
# test/spec.sh glob --format=diffable
# test/spec.sh here-doc --format=diffable
# test/spec.sh if_ --format=diffable
# test/spec.sh interactive --format=diffable
# test/spec.sh introspect --format=diffable
# test/spec.sh let --format=diffable
# test/spec.sh loop --format=diffable
# test/spec.sh nameref --format=diffable
# test/spec.sh osh-only --format=diffable
# test/spec.sh parse-errors --format=diffable
# test/spec.sh pipeline --format=diffable
# test/spec.sh posix --format=diffable
# test/spec.sh process-sub --format=diffable
# test/spec.sh prompt --format=diffable
# test/spec.sh quote --format=diffable
# test/spec.sh redirect --format=diffable
# test/spec.sh regex --format=diffable
# test/spec.sh sh-func --format=diffable
# test/spec.sh sh-options --format=diffable
# test/spec.sh sh-usage --format=diffable
# test/spec.sh smoke --format=diffable
# test/spec.sh special-vars --format=diffable
# test/spec.sh strict-options --format=diffable
# test/spec.sh subshell --format=diffable
# test/spec.sh tilde --format=diffable
# test/spec.sh type-compat --format=diffable
# test/spec.sh var-num --format=diffable
# test/spec.sh var-op-bash --format=diffable
# test/spec.sh var-op-len --format=diffable
# test/spec.sh var-op-other --format=diffable
# test/spec.sh var-op-patsub --format=diffable
# test/spec.sh var-op-strip --format=diffable
# test/spec.sh var-op-test --format=diffable
# test/spec.sh var-ref --format=diffable
# test/spec.sh var-sub-quote --format=diffable
# test/spec.sh var-sub --format=diffable
# test/spec.sh word-eval --format=diffable
# test/spec.sh word-split --format=diffable
# test/spec.sh xtrace --format=diffable
