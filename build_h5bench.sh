#!/bin/bash

HDF5_PATH="`which h5cc |sed 's/.\{9\}$//'`"

echo "HDF5_HOME: $HDF5_PATH"

INSTALL_DIR=$HOME/install/h5bench

mkdir build
cd build

export LD_LIBRARY_PATH=/people/tang584/install/hdf5/lib/libhdf5.so.310

cmake .. \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
    -DCMAKE_C_FLAGS="-I/$HDF5_PATH/include \
    -DH5BENCH_ALL=ON \
    -L$HDF5_PATH/lib"
make 
make install

# mkdir build
# cd build

# cmake .. -DWITH_ASYNC_VOL=OFF -DCMAKE_C_FLAGS="-I/$ASYNC_VOL/src -L/$ASYNC_VOL/src"

# make
# make install