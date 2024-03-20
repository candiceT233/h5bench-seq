#!/bin/bash

HDF5_PATH="`which h5cc |sed 's/.\{9\}$//'`"
GIT_PATH="$(pwd)"
export HDF5_USE_FILE_LOCKING='TRUE' #'TRUE' 'FALSE' 'BEST_EFFORT'


TEST_CONFIG="sync-write-read-contig-1d-small.json"

source ./load_hdf5.sh

echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"

# EXEC_DIR=$HOME/install/h5bench/bin
EXEC_DIR="${GIT_PATH}/build"

rm -rf $EXEC_DIR/storage/*

set -x 
cd $EXEC_DIR
$HOME/install/h5bench/bin/h5bench --debug $GIT_PATH/test_cases/$TEST_CONFIG
