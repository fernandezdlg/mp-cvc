#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --partition=debug
#SBATCH -C gpu
#SBATCH --job-name=build-cvc
#SBATCH -A s1197

cd ${SCRATCH}/software/mp_cvc/build-daint-cuda/
. ${PROJECT}/software/modules.gcc
srun make clean
srun make -j12
