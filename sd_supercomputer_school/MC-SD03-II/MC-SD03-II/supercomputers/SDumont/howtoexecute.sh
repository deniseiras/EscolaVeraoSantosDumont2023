#!/bin/bash

usage()
{
 echo "howtoexecute.sh: wrong number of input parameters. Exiting."
 echo -e "Usage: bash howtoexecute.sh <supercomputer>"
 echo -e "  g.e: bash howtoexecute.sh sdumont"
}

sdumont()
{
 sbatch v100-MonteCarlo1GPU.sh
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
