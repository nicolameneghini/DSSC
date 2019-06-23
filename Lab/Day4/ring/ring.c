#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <mpi.h>

#define N 4

void swap(int**a, int**b)
{ 
  int*tmp = *a;
  *a = *b;
  *b = tmp;
}

int main(int argc, char* argv[]){

 int rank = 0; // store the MPI identifier of the process
 int npes = 1; // store the number of MPI processes
 
 MPI_Init( &argc, &argv );
 MPI_Comm_rank( MPI_COMM_WORLD, &rank );
 MPI_Comm_size( MPI_COMM_WORLD, &npes );

 MPI_Request request;
 MPI_Status status;

 unsigned int i, j;
 int last = npes-1;

 int *message = (int*)malloc(sizeof(int)*N);
 int *receive = (int*)calloc(sizeof(int),N);
 int *sum = (int*)calloc(sizeof(int),N);
 
 for(i = 0; i < N; i++) {
    message[i] = rank;
    sum[i] = message[i];
 }

 for(i = 0; i <last; i++){
  
   if(rank!=0){

    MPI_Recv(receive,N,MPI_INT, (rank-1+npes)%npes, 101, MPI_COMM_WORLD,MPI_STATUS_IGNORE);
    MPI_Send(message,N,MPI_INT, (rank+1)%npes, 101,MPI_COMM_WORLD);
    
    for(i = 0; i < N; i++)
       sum[i]+=receive[i];
   
    swap(&receive, &message);
    }
    else{
     
     MPI_Send(message,N,MPI_INT, (rank+1)%npes, 101,MPI_COMM_WORLD);
     MPI_Recv(receive,N,MPI_INT, (rank-1+npes)%npes, 101, MPI_COMM_WORLD,  MPI_STATUS_IGNORE);

     for(i = 0; i < N; i++)
        sum[i]+=receive[i];
    
     swap(&receive, &message);

    }

  }

  fprintf( stderr, "I am process %d and my message is %d \n", rank, sum[0]);

  MPI_Barrier(MPI_COMM_WORLD);


 free(message);
 free(receive);
 free(sum); 

 MPI_Finalize();


 return 0;
}
