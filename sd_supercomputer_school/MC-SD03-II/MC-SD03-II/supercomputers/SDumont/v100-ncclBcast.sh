#!/bin/bash

#SBATCH --job-name=ncclBcast                   # Job name
#SBATCH --nodes=1                              # Run on 1 node  
#SBATCH --partition=sequana_gpu_dev            # Partition SDUMONT
#SBATCH --output=out_v100_%j-ncclBcast.log     # Standard output and error log
#SBATCH --ntasks-per-node=1                    # 1 job per node

module load nccl/2.13_cuda-11.2
./ncclBcast
