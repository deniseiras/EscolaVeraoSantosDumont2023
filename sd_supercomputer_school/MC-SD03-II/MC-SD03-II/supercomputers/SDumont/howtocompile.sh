#!/bin/bash

usage()
{
 echo "howtocompile.sh: wrong number of input parameters. Exiting."
 echo -e "Usage: bash howtocompile.sh <supercomputer>"
 echo -e "  g.e: bash howtocompile.sh sdumont"
}

sdumont()
{
 module load openmpi/gnu/4.1.4+cuda-11.2
 nvcc monte_carlo_pi_cuda.cu -o monte_carlo_pi_cuda $CPPFLAGS $LDFLAGS
}

#args in comand line
if [ "$#" ==  0 ]; then
 usage
 exit
fi

#sdumont
if [[ $1 == "sdumont" ]];then
 sdumont
fi
