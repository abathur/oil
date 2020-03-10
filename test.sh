# canonical test script; should probably be renamed
# along with references in .travis.yml

test/lint.sh travis
# Type checking with MyPy.  Problem: mypy requires Python 3, but Oil
# requires Python 2.  The Travis environment doesn't like that.
types/run.sh travis
types/oil-slice.sh travis
# Unit tests
test/unit.sh all-for-minimal
# Spec tests
test/spec.sh smoke
# Make sure dev build of yajl works
test/spec.sh oil-json
test/spec.sh interactive
echo "I don't really understand why these interactive tests aren't working. I thought the only conditions here were when the osh wrapper was using a /bin/sh that is bash. I don't think this should be true on Linux (I think it's dash), unless maybe Nix is doing something magical to shim bash in?"
cat bin/osh
ls -la /bin/*sh*
/bin/sh -c 'echo $BASH_VERSION'
