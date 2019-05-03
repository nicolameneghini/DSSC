#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <mpi.h>


int main(int argc, char* argv[]){

 int rank = 0; // store the MPI identifier of the process
 int npes = 1; // store the number of MPI processes
 MPI_Request send_request, recv_request; 
 
 MPI_Init( &argc, &argv );
 MPI_Comm_rank( MPI_COMM_WORLD, &rank );
 MPI_Comm_size( MPI_COMM_WORLD, &npes );
 unsigned int i;
 int last = npes-1;
 int message;
 int sum = 0;
 
 //I initialize the message
 if (rank == 0)
	 message = 1;
 else 
	 message = 0;

 //I send the message from 0 to 3
 if(rank == 0){
   MPI_Send(&message,1,MPI_DOUBLE, last, 101,MPI_COMM_WORLD);
   fprintf( stderr, "\nI am process %d and my message is %d \n", rank, message );
 }
 if( rank == last){
   MPI_Recv(&message,1,MPI_DOUBLE, 0, 101, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

 fprintf( stderr, "\nI am process %d and my message is %d \n", rank, message );
 }

 //In this for loop I am sending the message, say, from 3 to 2, from 2 to 1 and from 1 to 0.
 for(i = last; i > 0; i --)
 {
  if(rank == i)
    MPI_Send(&message, 1,MPI_DOUBLE,i-1,101*i,MPI_COMM_WORLD);//, &send_request);
  
  if(rank == i-1){
    MPI_Recv(&message, 1,MPI_DOUBLE,i,101*i,MPI_COMM_WORLD, MPI_STATUS_IGNORE);//, &recv_request);
    fprintf( stderr, "\nI am process %d and my message is %d \n", rank, message);
    MPI_Reduce(&message, &sum, 1,MPI_DOUBLE,MPI_SUM, i-1, MPI_COMM_WORLD);
        
  }
 }
 
  MPI_Finalize();


 return 0;
}
