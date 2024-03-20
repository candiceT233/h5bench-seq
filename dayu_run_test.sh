#!/bin/bash

HDF5_PATH="`which h5cc |sed 's/.\{9\}$//'`"
GIT_PATH="$(pwd)"
export HDF5_USE_FILE_LOCKING='TRUE' #'TRUE' 'FALSE' 'BEST_EFFORT'



source ./load_hdf5.sh

echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"

# EXEC_DIR=$HOME/install/h5bench/bin
EXEC_DIR="${GIT_PATH}/test_cases"
rm -rf $EXEC_DIR/storage/*

set -x 


TRACKER_SRC_DIR="/mnt/common/mtang11/scripts/dayu-tracker/build/src"
export HDF5_USE_FILE_LOCKING='FALSE' # TRUE FALSE BESTEFFORT
export TRACKER_VFD_PAGE_SIZE=65536 #65536

PREP_TASK_NAME () {
    TASK_NAME=$1
    export CURR_TASK=$TASK_NAME
    export WORKFLOW_NAME="h5bench-seq"
    export PATH_FOR_TASK_FILES="/tmp/$USER/$WORKFLOW_NAME"
    mkdir -p $PATH_FOR_TASK_FILES
    > $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vfd.curr_task # clear the file
    > $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vol.curr_task # clear the file

    echo -n "$TASK_NAME" > $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vfd.curr_task
    echo -n "$TASK_NAME" > $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vol.curr_task
}


EVAL_VFD_VOL_IO () {

    local task1="sync-write-read-contig-1d-small"

    TEST_CONFIG="${task1}.json"

    schema_file_path="`pwd`"/test_cases/save_log
    mkdir -p $schema_file_path
    rm -rf $schema_file_path/*vfd_data_stat.json
    rm -rf $schema_file_path/*vol_data_stat.json

    echo "TRACKER_VFD_DIR : `ls -l $TRACKER_SRC_DIR/*`"

    # export STAT_FILE_PATH=$schema_file_path
    export HDF5_VOL_CONNECTOR="tracker under_vol=0;under_info={};path=$schema_file_path;level=2;format="
    export HDF5_PLUGIN_PATH=$TRACKER_SRC_DIR/vol:$TRACKER_SRC_DIR/vfd:$HDF5_PLUGIN_PATH
    export HDF5_DRIVER=hdf5_tracker_vfd
    export HDF5_DRIVER_CONFIG="${schema_file_path};${TRACKER_VFD_PAGE_SIZE}"

    # export DYLD_LIBRARY_PATH="$TRACKER_SRC_DIR/vol"

    PREP_TASK_NAME "$task1"
    cd $EXEC_DIR
    $HOME/install/h5bench/bin/h5bench --debug $GIT_PATH/test_cases/$TEST_CONFIG
}

start_time=$(date +%s%3N)

EVAL_VFD_VOL_IO

end_time=$(date +%s%3N)
echo "Execution time: $((end_time-start_time)) ms" | tee -a $LOGFILE

# "configuration": "-env HDF5_VOL_CONNECTOR='tracker under_vol=0;under_info={};path=/home/mtang11/scripts/dayu-tracker/test/h5bench-seq/test_cases/save_log;level=2;format=' -env HDF5_PLUGIN_PATH=/mnt/common/mtang11/scripts/dayu-tracker/build/src/vol:/mnt/common/mtang11/scripts/dayu-tracker/build/src/vfd -env HDF5_DRIVER='hdf5_tracker_vfd' -env HDF5_DRIVER_CONFIG='/home/mtang11/scripts/dayu-tracker/test/h5bench-seq/test_cases/sync-write-read-contig-1d-small;65536'"

