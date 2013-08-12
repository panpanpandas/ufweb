#!/bin/bash

BASE_DIR=$(dirname $0)/../
SERVICE_NAME=frontend
PSERVE=$BASE_DIR/target/pyenv/bin/pserve
CONF_DIR=$BASE_DIR/conf
LOG_DIR=$BASE_DIR/logs

if [[ ! -f $PSERVE ]]; then
    echo cannot find $PSERVE.  Try running setup.sh first
    exit 1
fi

if [[ $# > 0 ]]; then
    INI=$1
else
    INI=$CONF_DIR/development.ini
fi

$PSERVE --stop-daemon --pid-file=$LOG_DIR/${SERVICE_NAME}.pid $INI

exit 0
