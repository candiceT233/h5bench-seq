#!/bin/bash

HDF5_PATH="`which h5cc |sed 's/.\{9\}$//'`"
GIT_PATH="$(pwd)"
export HDF5_USE_FILE_LOCKING='TRUE' #'TRUE' 'FALSE' 'BEST_EFFORT'


TEST_CONFIG="sync-write-1d-contig-contig-read-full-1p.json"

source ./load_hdf5.sh

echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"

# EXEC_DIR=$HOME/install/h5bench/bin
EXEC_DIR="${GIT_PATH}/build"

rm -rf $EXEC_DIR/storage/*

set -x 
cd $EXEC_DIR
./h5bench --debug $GIT_PATH/samples/$TEST_CONFIG
