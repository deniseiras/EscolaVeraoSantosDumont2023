#!/bin/bash
#SBATCH --nodes=1                      # here the number of nodes
#SBATCH --ntasks=1                     # here total number of mpi tasks
#SBATCH --ntasks-per-node=1            # here ppn = number of process per nodes
#SBATCH -p cpu_shared             # target partition
#SBATCH -J NPB-BTIO-B-1                # job name
#SBATCH --exclusive                    # to have exclusvie use of your nodes


echo $SLURM_JOB_NODELIST
cd $SLURM_SUBMIT_DIR

echo ""
echo "**********"
echo ""
echo ""
echo ""


###################################
#           COMPILER              #
###################################
module load openmpi/gnu/4.1.4

#Configure BTIO executable
EXEC=/scratch/app/NPB3.3.1-MZ/bin/bt.B.1.mpi_io_full.ompi414+gnu

#Start the benchmark
srun $EXEC
