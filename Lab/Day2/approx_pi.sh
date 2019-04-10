#!/bin/bash

cd /home/nmeneghi/ParalleProgramming/DSSC/Lab/Day2


module load intel/14.0
for threads in 1 2 4 8 16 20 ; do
export OMP_NUM_THREADS=${threads} 
./appr.x >>file.out
done
exit
