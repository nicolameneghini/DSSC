### Exercise 1 - Identity Matrix

The program prints an identity matrix of size <a href="https://www.codecogs.com/eqnedit.php?latex=10&space;\times&space;10" target="_blank"><img src="https://latex.codecogs.com/gif.latex?10&space;\times&space;10" title="10 \times 10" /></a> in the terminal window (if the size of the matrix is > 10, the matrix is printed on a outfile)

Matrix' rows are evenly distributed between the processes since the rest <a href="https://www.codecogs.com/eqnedit.php?latex=\texttt{rest}&space;=&space;\texttt{size}&space;\%&space;\texttt{n\_processes}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\texttt{rest}&space;=&space;\texttt{size}&space;\%&space;\texttt{n\_processes}" title="\texttt{rest} = \texttt{size} \% \texttt{n\_processes}" /></a> is spread in such a way to achieve load balance.

The rows of the matrix are sent to the process with rank <a href="https://www.codecogs.com/eqnedit.php?latex=0" target="_blank"><img src="https://latex.codecogs.com/gif.latex?0" title="0" /></a>, which will eventually print them.

### Exercise 2 - Ring

A vectorial sum is performed through all the process, meaning that each process of rank <a href="https://www.codecogs.com/eqnedit.php?latex=i" target="_blank"><img src="https://latex.codecogs.com/gif.latex?i" title="i" /></a> sends a message to the one with rank <a href="https://www.codecogs.com/eqnedit.php?latex=i&plus;1" target="_blank"><img src="https://latex.codecogs.com/gif.latex?i&plus;1" title="i+1" /></a>. This is done in an overlapping fashion, that is <a href="https://www.codecogs.com/eqnedit.php?latex=\texttt{MPI\_Isend()}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\texttt{MPI\_Isend()}" title="\texttt{MPI\_Isend()}" /></a>
and <a href="https://www.codecogs.com/eqnedit.php?latex=\texttt{MPI\_Wait()}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\texttt{MPI\_Wait()}" title="\texttt{MPI\_Wait()}" /></a> are called.



