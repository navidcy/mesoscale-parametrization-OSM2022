#!/bin/bash
#PBS -q normal
#PBS -P x77
#PBS -l ncpus=12
#PBS -l mem=192GB
#PBS -l jobfs=100GB
#PBS -l walltime=4:00:00
#PBS -l wd
#PBS -N channel-gm-m
#PBS -W umask=027
#PBS -l storage=gdata/v45+gdata/hh5+gdata/x77+scratch/v45+scratch/x77

# Load modules.

export JULIA_DEPOT_PATH=/g/data/v45/nc3020/.julia:$JULIA_ROOT/share/julia/site/
export JULIA_LOAD_PATH="@":"@v#.#":"@stdlib":"@site"
export JULIA_CUDA_USE_BINARYBUILDER="false"
export JULIA_NUM_THREADS=48

module load cuda/11.0.3

# Run Julia
cd /g/data/v45/nc3020/mesoscale_parametrizations/zonally_averaged_channel-gm-larger

/g/data/v45/nc3020/julia/julia --color=yes --project make_small_movie_zonally_averaged_channel.jl  > $PBS_JOBID.log
