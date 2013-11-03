#!/bin/bash

BASE_DIR=$(dirname $0)/../
SERVICE_NAME=frontend
PSERVE=pserve
CONF_DIR=$BASE_DIR/conf
LOG_DIR=$BASE_DIR/logs

if [[ $# > 0 ]]; then
    INI=$1
else
    INI=$CONF_DIR/production.ini
fi

$PSERVE --stop-daemon --pid-file=$LOG_DIR/${SERVICE_NAME}.pid $INI

exit 0
