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
 
 if(rank == 0)
   message = 1;
 else
   message = 0;

 if(rank == 0){
 MPI_Send(&message,1,MPI_INT, last , 101,MPI_COMM_WORLD);
 }
 
 if(rank == last){
  MPI_Recv(&message,1,MPI_INT, 0, 101, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
  fprintf( stderr, "\nI am process %d and my message is %d \n", rank, message );
  message += rank;
 }

 if(rank != 0){
   MPI_Send(&message,1,MPI_INT, rank -1 , 101,MPI_COMM_WORLD);
 }
 if(rank != last){
   MPI_Recv(&message,1,MPI_INT, rank +1, 101, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
   fprintf( stderr, "\nI am process %d and my message is %d \n", rank, message );
   message += rank;
 }

 // MPI_Recv(&message,1,MPI_INT, 0, 101, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
 // message += rank;
 // MPI_Send(&message,1,MPI_INT, rank -1 , 101,MPI_COMM_WORLD);//, &send_request);
 // MPI_Recv(&message,1,MPI_INT, rank +1, 101, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
 // fprintf( stderr, "\nI am process %d and my message is %d \n", rank, message );

  MPI_Finalize();


 return 0;
}
