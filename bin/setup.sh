#!/bin/bash

# setup python env path
BASE_DIR=$(dirname $0)/..
DOWNLOAD_DIR=$BASE_DIR/target/download
DIR_PY_ENV=$BASE_DIR/target/pyenv

# function definitions
download_file() {
    URL=$1
    ODIR=$2
    OFILE=$3
    hash wget
    if [[ $? == 0 ]]; then
        CMD="wget $URL -P $ODIR"
    else
        hash curl
        if [[ $? == 0 ]]; then
            CMD="curl $URL -o $ODIR/$OFILE"
        else
            echo error: missing curl or wget command
            exit 1
        fi
    fi
    
    $CMD
} # download_file

# create python virutal environment
rm -rf $DIR_PY_ENV
mkdir -p $DIR_PY_ENV
echo "===============setting up python virtual environment in $DIR_PY_ENV==================="
$BASE_DIR/bin/virtualenv.py -p python3 $DIR_PY_ENV

# install XXXX pylint -- hack it and patch it
echo "===============installing pylint========================="
PYLINT_DIR=$DOWNLOAD_DIR/pylint-0.25.1
BAD_FILE=$PYLINT_DIR/test/input/func_unknown_encoding.py
rm -rf $DOWNLOAD_DIR
mkdir -p $DOWNLOAD_DIR
echo "$DOWNLOAD_DIR, $?"
echo "Downloading pylint...."
download_file http://download.logilab.org/pub/pylint/pylint-0.25.1.tar.gz $DOWNLOAD_DIR pylint-0.25.1.tar.gz

echo "Untaring pylint...."
tar xzf $DOWNLOAD_DIR/pylint-0.25.1.tar.gz -C $DOWNLOAD_DIR
rm $BAD_FILE

echo "Pip installing pylint, it may take a while...."
$DIR_PY_ENV/bin/pip install -q $PYLINT_DIR

echo "Patching pylint...."
patch $DIR_PY_ENV/lib/python3.2/site-packages/logilab/astng/scoped_nodes.py -i $BASE_DIR/bin/pylint.patch --batch

# install pyramid project
$DIR_PY_ENV/bin/python $BASE_DIR/setup.py develop

# cleanup generated temp folders
rm -rf $BASE_DIR/__pycache__
rm -rf $BASE_DIR/*.gz
rm -rf $DOWNLOAD_DIR

