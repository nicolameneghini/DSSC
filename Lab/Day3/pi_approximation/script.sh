
#!/bin/bash
#enter in the right directory
  
cd ParalleProgramming/DSSC/Lab/Day3

module load openmpi

for i in 1 2 4 8 16 20 40; do
	mpirun -np ${i} ./a.out >>file.txt
done


exit
	
