#!/bin/bash

HDF5_PATH="`which h5cc |sed 's/.\{9\}$//'`"
GIT_PATH="$(pwd)"
export HDF5_USE_FILE_LOCKING='TRUE' #'TRUE' 'FALSE' 'BEST_EFFORT'




source ./load_hdf5.sh

echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"

# EXEC_DIR=$HOME/install/h5bench/bin
EXEC_DIR="${GIT_PATH}/test_cases"

OUTPUT_PATH=/mnt/ssd/${USER}/storage
# OUTPUT_PATH=${EXEC_DIR}/storage
mkdir -p $OUTPUT_PATH
rm -rf $OUTPUT_PATH/*

set -x 


TRACKER_SRC_DIR="/mnt/common/mtang11/scripts/dayu-tracker/build/src"
export HDF5_USE_FILE_LOCKING='FALSE' # TRUE FALSE BESTEFFORT
export TRACKER_VFD_PAGE_SIZE=65536 #65536


RUN_TEST () {

    # local task1="sync-write-2d-contig-contig-read-strided"
    data_dim="3d"
    local task1="sync-write-${data_dim}-contig-contig-read-full"

    save_test_path="`pwd`"/test_cases/save_log/$task1
    mkdir -p $save_test_path
    rm -rf $save_test_path/*

    TEST_CONFIG="${data_dim}/${task1}.json"

    PREP_TASK_NAME "$task1"
    cd $EXEC_DIR

    set -x
    $HOME/install/h5bench/bin/h5bench --debug $GIT_PATH/test_cases/$TEST_CONFIG

    mv $GIT_PATH/test_cases/${data_dim}/${task1}-h5bench.log $save_test_path/
}

start_time=$(date +%s%3N)

RUN_TEST

end_time=$(date +%s%3N)
echo "Execution time: $((end_time-start_time)) ms" | tee -a $LOGFILE

# "configuration": "-env HDF5_VOL_CONNECTOR='tracker under_vol=0;under_info={};path=/home/mtang11/scripts/dayu-tracker/test/h5bench-seq/test_cases/save_log;level=2;format=' -env HDF5_PLUGIN_PATH=/mnt/common/mtang11/scripts/dayu-tracker/build/src/vol:/mnt/common/mtang11/scripts/dayu-tracker/build/src/vfd -env HDF5_DRIVER='hdf5_tracker_vfd' -env HDF5_DRIVER_CONFIG='/home/mtang11/scripts/dayu-tracker/test/h5bench-seq/test_cases/sync-write-read-contig-1d-small;65536'"

