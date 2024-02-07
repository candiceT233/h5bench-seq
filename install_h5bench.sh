#!/bin/bash

INSTALL_PREFIX=$HOME/install/h5bench

HDF5_PATH="`which h5cc |sed 's/.\{9\}$//'`"

echo "HDF5_HOME: $HDF5_PATH"


mkdir build
cd build

export LD_LIBRARY_PATH=$HDF5_PATH/lib/libhdf5.so.310

cmake .. \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_C_FLAGS="-I/$HDF5_PATH/include \
    -DH5BENCH_ALL=ON \
    -L$HDF5_PATH/lib"
make 
make install

# Add path
echo "export PATH=$INSTALL_PREFIX/bin:$PATH" >> $HOME/.bashrc

# mkdir build
# cd build

# cmake .. -DWITH_ASYNC_VOL=OFF -DCMAKE_C_FLAGS="-I/$ASYNC_VOL/src -L/$ASYNC_VOL/src"

# make
# make install