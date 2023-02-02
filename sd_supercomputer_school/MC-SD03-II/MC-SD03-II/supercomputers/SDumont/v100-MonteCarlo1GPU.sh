#!/bin/bash

#SBATCH --job-name=MonteCarlo1GPU               # Job name
#SBATCH --nodes=1                               # Run on 1 node  
#SBATCH --partition=sd_gpu             # Partition SDUMONT
#SBATCH --output=out_v100_%j-MonteCarlo1GPU.log # Standard output and error log
#SBATCH --ntasks-per-node=1                     # 1 job per node

module load openmpi/gnu/4.1.4+cuda-11.2
./monte_carlo_pi_cuda
