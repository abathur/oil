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
