#!/bin/bash -l
#SBATCH --job-name="weak_scaling_test"                                                           
#SBATCH --time=00:02:00
#SBATCH --nodes=8
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=normal
#SBATCH --constraint=mc
#SBATCH --hint=multithread
#SBATCH --wait

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun ../Bin/hydro