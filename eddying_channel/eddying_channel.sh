#!/bin/bash
#PBS -q gpuvolta
#PBS -P x77
#PBS -l ncpus=12
#PBS -l ngpus=1
#PBS -l mem=382GB
#PBS -l jobfs=100GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -N channel-3d
#PBS -W umask=027
#PBS -l storage=gdata/v45+gdata/hh5+gdata/x77+scratch/v45+scratch/x77

# Load modules.

export JULIA_DEPOT_PATH=/g/data/v45/nc3020/.julia:$JULIA_ROOT/share/julia/site/
export JULIA_LOAD_PATH="@":"@v#.#":"@stdlib":"@site"
export JULIA_CUDA_USE_BINARYBUILDER="false"
export JULIA_NUM_THREADS=48

module load cuda/11.0.3

# Run Julia
cd /g/data/v45/nc3020/mesoscale-parametrization-OSM2022/eddying_channel

/g/data/v45/nc3020/julia/julia --color=yes --project eddying_channel.jl > $PBS_JOBID.log
