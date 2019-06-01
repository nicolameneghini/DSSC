#include <mpi.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define N 20

void print_mat(int*mat, int n_block){
 unsigned int i,j;
 for(i = 0; i < n_block; i++){
   for(j = 0; j < N; j++)
     printf("%d ", mat[i*N+j]);
  printf("\n");
 }
}

void print_mat_file(int*mat, int n_block, FILE*outfile){
 unsigned int i, j;
 for (i = 0; i < n_block; i++){
   for(j = 0; j< N; j++)
     fprintf(outfile, "%d ", mat[i*N+j]);
   fprintf(outfile, "\n");	 
 }

}


int main(int argc, char* argv[]){
 int rank = 0;
 int npes = 1; 
 MPI_Init( &argc, &argv );
 MPI_Comm_rank( MPI_COMM_WORLD, &rank );
 MPI_Comm_size( MPI_COMM_WORLD, &npes );	
 int i, j, i_global;
 
 int *mat=(int *)malloc(sizeof(int)*N*N);
 //for (i=0; i<N; i++)  mat[i]=(int *)malloc(sizeof(int)*N);
		   
 int n_block = N/npes;
 int rest = N%npes;
 FILE*outfile;
 outfile = fopen("identity_file.txt","w");
 if(rest != 0 && rank < rest)
	 n_block ++;

 for (i = 0; i < n_block; i++){
   for (j = 0; j < N ; j++){
    
    if(rank < rest) i_global = i + (rank*n_block);
    if(rank >= rest) i_global = i + (rank*n_block) + rest;

      if(i_global == j) mat[i*N + j] = 1;
      else mat[i*N + j] = 0;

   }
 }
 

 if(rank==0){

  if(N<= 10)
   print_mat(mat, n_block);
  else
    print_mat_file(mat, n_block, outfile);
  //printf("end of process %d \n", rank);
  for ( i = 1; i <npes; i++){
      MPI_Recv(&n_block,1,MPI_INT, i, 102, MPI_COMM_WORLD, MPI_STATUS_IGNORE);	  
      MPI_Recv(mat, n_block*N, MPI_INT, i, 101, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
      if(N <= 10)
       print_mat(mat, n_block);
      else
       print_mat_file(mat, n_block, outfile);
    //printf("end of process %d \n", rank);
  }
}
 
 else{
     MPI_Send(mat, n_block*N, MPI_INT, 0 , 101, MPI_COMM_WORLD);
     MPI_Send(&n_block, 1, MPI_INT, 0, 102, MPI_COMM_WORLD);
 }
 //printf("I am process number %d and i have %d lines\n", rank, n_block);
 MPI_Finalize();
 
 free(mat);


return 0;
}
