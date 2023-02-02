#!/bin/bash
#SBATCH --nodes=2                      # here the number of nodes
#SBATCH --ntasks=48                    # here total number of mpi tasks
#SBATCH --ntasks-per-node=24           # here ppn = number of process per nodes
#SBATCH -p sequana_cpu_dev             # target partition
#SBATCH -J IOR                         # job name
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

#Configure to use the ROMIO MPI-IO implementation
export OMPI_MCA_io=romio321

#Configure to use the $SCRATCH/intro_ES_SD/hints.txt file hints
#TO-DO

#Configure to show the used hints 
#TO-DO

#Configure IOR executable
EXEC=/scratch/app/ior/openmpi_4.1.4/bin/ior

#Start the benchmark
srun $EXEC -f ../ior_config.txt
