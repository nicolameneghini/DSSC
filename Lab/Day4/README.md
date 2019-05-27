### Exercise 1 - Identity Matrix

The program prints an identity matrix of size $10 \times 10$ in the terminal window. 

Matrix' rows are evenly distributed between the processes since the rest $\texttt{rest} = \texttt{size} % \texttt{n\_processes}$ is spread in such a way to achieve load balance.

The rows of the matrix are sent to the process with rank 0, which will eventually print them.

### Exercise 2 - Ring

A vectorial sum is performed through all the process, meaning that each process of rank $i$ send a message to the one with rank $i+1$. This is done in an overlapping fashion, that is $\texttt{MPI\_Isend()}$ and $\texttt{MPI\_Wait()}$ are called.



