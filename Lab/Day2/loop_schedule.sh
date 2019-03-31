#!/bin/bash

cd /home/nmeneghi/ParalleProgramming/DSSC/Lab/Day2

module load intel/14.0

export OMP_NUM_THREADS=10

./loop.x

exit
