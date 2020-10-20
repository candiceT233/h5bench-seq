# H5bench: a Parallel I/O Benchmark suite for HDF5
H5bench benchmark suite contains a list of applications that are used to measure the I/O performance from various aspects.
  
# Build
## Build with local CMake
#### Dependency and environment variable settings
H5bench depends on MPI and HDF5. Assume you have installed MPI and HDF5. Several environment variables to set:

- **HDF5_HOME**: the location you installed HDF5. It should point to a path that look like below and contains include/, lib/ and bin/ subdirectories: /path_to_my_hdf5_build/hdf5

### Compile with CMake
Assume the repo is cloned and now you are in the source directory h5bench, run several simple steps:

- `mkdir build`

- `cd build`

- `cmake ..`

- `make`

And all the binaries will be built to the build/ directory.

## Build with Spack
Assuming you have installed Spack, and it will try to find and install dependencies for you.

- Create a spack package:
	- `spack create --force https://bitbucket.org/berkeleylab/h5bench/downloads/h5bench-0.1.tar`

- Then you will be put in an opend python document (for details see here https://spack-tutorial.readthedocs.io/en/latest/tutorial_packaging.html) and you only need to add 2 dependencies:
	- `depends_on(mpi)`
	- `depends_on(hdf5)`

- And you are good to install:
	- `spack install h5bench`

- Binaries will be added to your $PATH environment variable after you load them by
	- `spack load h5bench`

And now you can call the benchmark apps in your scripts directly. 
  
# Benchmark suite usage
## Basic I/O benchmark
This benchmark contains two applications that are developed based on particle physics simulation software VPICIO (for write) and BDCATSIO (for read).
 
## Basic write benchmark - h5bench_vpicio

**To set parameters for the h5bench_vpicio:**

The h5bench_vpicio takes all parameters in a plain text config file. The content format is strict.
Take `basic_io/sample_cfg.cfg` as an example, it looks like below, and we will discus them one by one:
```
# this is a comment
# Benchmark mode can only be one of these: CC/CI/IC/II/CC2D/CI2D/IC2D/II2D/CC2D/CC3D
PATTERN=CC3D
PARTICLE_CNT_M=128
TIME_STEPS_CNT=1
SLEEP_TIME=1
DIM_1=1024
DIM_2=2048
DIM_3=64
```
- To enable parallel compression feature for VPIC, add following section to the config file, and make sure chunk dimension settings are compatible with the data dimensions: they must have the same rank of dimensions (eg,. 2D array dataset needs 2D chunk dimensions), and chunk dimension size cannot be greater than data dimension size.
```
COMPRESS=YES # to enable parallel compression(chunking)
CHUNK_DIM_1=512 # chunk dimensions
CHUNK_DIM_2=256
CHUNK_DIM_3=1
```

- For 2D/3D benchmarks (such as CI2D or CC3D), make sure the dimensions are set correctly and matches the per rank particle number. For example, when your PATTERN is CC3D, and PARTICLE_CNT_M is 1, means 1M particles per rank, setting DIM_1~3 to 64, 64, and 256 is valid, because 64*64*256 = 1,048,576 (1M); and 10*20*30 is an invalid setting.
- For 1D benchmarks (CC/CI/IC/II), DIM_1 must be set to the total particle number, and the rest two dimensions must be set to 1.

- No blank line and blank space are allowed.


#### Parameter PATTERN: the write pattern
This defines the write access pattern, including CC/CI/IC/II/CC2D/CI2D/IC2D/II2D/CC2D/CC3D where C strands for “contiguous” and I stands for “interleaved” for the source (the data layout in the memory) and the destination (the data layout in the resulting file). For example, CI2D is a write pattern where the in-memory data layout is contiguous (see the implementation of prepare_data_contig_2D() for details) and file data layout is interleaved by due to its’ compound data structure (see the implementation of data_write_contig_to_interleaved () for details).
  
#### Parameter PARTICLE_CNT_M: the number of particles that each rank needs to process, in M (1024*1024)
This number and the three dimension parameters (DIM_1, DIM_2, and DIM_3) must be set such that the formula holds: PARTICLE_CNT_M*(1024*1024) == DIM_1 * DIM_2 * DIM_3
  
#### Parameters TIME_STEPS_CNT and SLEEP_TIME: the number of iterations
In each iteration, the same amount of data will be written and the file size will increase correspondingly. After each iteration, the program sleeps for $SLEEP_TIME seconds to emulate the application computation.

#### Parameters DIM_1, DIM_2, and DIM_3: the dimensionality of the source data
Always set these parameters in ascending order, and set unused dimensions to 1, and remember that PARTICLE_CNT_M*(1024*1024) == DIM_1 * DIM_2 * DIM_3 must hold. For example, DIM_1=1024, DIM_2=256, DIM_3=1 is a valid setting for a 2D array.

**To run the vpicio_h5bench:**

- Single process test:
	- `./h5bench_vpicio your_config_file output_file`

- Parallel run:
	- `mpirun -n 2 ./h5bench_vpicio your_config_file output_file`

  
## Basic read benchmark - h5bench_bdcatsio

BDCATSIO takes an h5 file generated by VPICIO as an input, and performs a series of parallel read operations. The parameters are taken from the command line:
`./h5bench_bdcatsio $data_file_path $cnt_time_steps $sleep_time $pattern $dimension_parameters`

The definitions of **time_steps** and **sleep_time** are same as those for h5bench_vpicio.
Following read patterns are supported: Contiguous reading on1D/2D/3D, Partial reading on 1D, Strided reading on 1D.
Parameter $pattern can only be one of 5 below. The examples used below assume the file has 8M particles in total, and we use 4 MPI processes.

-   **SEQ**: contiguously read through the whole 1D data file.
    - Followed by $cnt_element_to_read per rank in 1024*1024.
    - Example: `mpirun -n 4 ./h5bench_bdcatsio my_file SEQ 2`

-   **PART**: contiguously read the first K elements.
	- Followed by $cnt_element_to_read.
    - Example: `mpirun -n 4 ./h5bench_bdcatsio my_file PART 1`

-   **STRIDED**: strided reading.
    - Followed by $cnt_element_to_read $stride_length $block_size
    - Example: `mpirun -n 4 ./h5bench_bdcatsio my_file STRIDED 1 64 16` reads top 16 elements every 64 elements.

-   **2D**: contiguously read through the whole 2D data file.
    - Followed by $cnt_element_to_read $dim_1 $dim_2
    - Example: `mpirun -n 4 ./h5bench_bdcatsio my_file 2D 2 1024 2048` reads a 2D array with dimensionality of 1024*2048, total 2M particles per rank.

-   **3D**: contiguously read through the whole 3D data file.
    - Followed by $cnt_element_to_read $dim_1 $dim_2 $dim_3
    - Example: `mpirun -n 4 ./h5bench_bdcatsio my_file 3D 2 64 128 256` reads a 3D array with dimensionality of 64*128*256, total 2M particles per rank.  

## h5bench_exerciser
We modified this benchmark slightly so to be able to specify a file location that is writable. Except for the first argument $write_file_prefix, it's identical to the original one. Original README can be found here https://xgitlab.cels.anl.gov/ExaHDF5/BuildAndTest/-/blob/master/Exerciser/README.md

Example run:
	`mpirun -n 8 ./h5bench_exerciser $write_file_prefix -numdims 2 --minels 8 8 --nsizes 3 --bufmult 2 --dimranks 8 4`


## The metadata stress test: h5bench_hdf5_iotest
This is the same benchmark as it's originally found at https://github.com/HDFGroup/hdf5-iotest. We modified this benchmark slightly so to be able to specify the config file location, everything else remains untouched.

Example run:	`mpirun -n 4 ./h5bench_hdf5_iotest hdf5_iotest.ini`


## Streaming operation benchmark: h5bench_vl_stream_hl
This benchmark tests the performance of append operation. It supports two types of appends, FIXED and VLEN, represents fixed length data and variable length data respectively.
Note: This benchmark doesn't run in parallel mode.
#### To run the benchmark

`./h5bench_vl_stream_hl write_file_path FIXED/VLEN num_ops`

Example runs:
    - ` ./h5bench_vl_stream_hl here.dat FIXED 1000`
    - ` ./h5bench_vl_stream_hl here.dat VLEN 1000`
