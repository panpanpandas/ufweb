#!/bin/bash

BASE_DIR=$(dirname $0)/../
PYLINT=$BASE_DIR/target/pyenv/bin/pylint
SRC_DIR=$BASE_DIR/frontendservice


if [[ ! -f $PYLINT ]]; then
    echo cannot find $PYLINT.  Try running setup.sh first
    exit 1
fi

$PYLINT --rcfile $BASE_DIR/.pylintrc `find $SRC_DIR -name "*.py" | grep -v unittests` 

TEST_STATUS=$?
OS=`uname`
if [[ $TEST_STATUS != 0 && $OS == 'Darwin' && -z $SKIP_WARNING ]]; then
    say -v "Trinoids" "Pylint failed! Fix it!  FIX IT NOW!"
fi
