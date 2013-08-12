#!/bin/bash

BASE_DIR=$(dirname $0)/..
PYTHON=$BASE_DIR/target/pyenv/bin/python
NOSE=$BASE_DIR/target/pyenv/bin/nosetests
INI_PATH=$(dirname $0)/../conf

if [[ ! -f $PYTHON ]]; then
    echo cannot find $PYTHON.  Try running setup.sh first
    exit 1
fi

if [[ $1 == 'production.ini' || $1 == 'test.ini' ]]; then
    INI_FILE=$1
    shift
else
    INI_FILE='development.ini'
fi

export INI_FILE
export INI_PATH
$NOSE --with-coverage --with-xunit $@

TEST_STATUS=$?
OS=`uname`
if [[ $TEST_STATUS != 0 && $OS == 'Darwin' && -z $SKIP_WARNING ]]; then
    say -v "Trinoids" "Test failed! Fix it!  FIX IT NOW!"
fi
exit $TEST_STATUS
