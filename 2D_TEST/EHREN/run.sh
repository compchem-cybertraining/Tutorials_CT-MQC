#!/bin/bash
#SBATCH --partition=valhalla  --qos=valhalla
#SBATCH --clusters=faculty
#SBATCH --nodes=1
#SBATCH --requeue
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1

if [ -d "coeff" ]; then
   if [ ! -z "$(ls -A coeff)" ]; then
      rm coeff/*.dat
   fi
else
   mkdir coeff
fi

if [ -d "trajectories" ]; then
   if [ ! -z "$(ls -A trajectories)" ]; then
      rm trajectories/*.dat
   fi
else
   mkdir trajectories
fi

if [ -d "BO_*" ]; then
   rm BO_*
fi
if [ -d "initial_conditions.dat" ]; then
   rm BO_*
fi

here=`pwd`
echo $here

#echo "Enter the path to the executable:"
#read path_to_exec

#exec=$here'/'$path_to_exec'/main.x'

exec='/projects/academic/cyberwksp21/Software/g-ctmqc/src/main.x'

srun $exec < input.in > output.dat 

