#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define N 10
#define N_BLOCKS 10
#define N_THREADS 2

__global__ void transpose(int* mat, int *trasp){
 
// int index = threadIdx.x + blockIdx.x*blockDim.x;
 
 int y = blockIdx.x;
 int x = threadIdx.x;
 
 while(x < N){
  trasp[y*N + x] = mat[x*N + y];
  x += blockDim.x;
 }
 
 //int x = index_x%N
 //int y = index_x/N
 //transp[y*N+x] = mat[x*N+y];

}


void print_mat(int* mat){

 int i, j;
 
 for(i = 0; i < N; i++){
    for(j = 0; j < N; j++)
     printf("%d ",mat[i*N + j]);	 
    
    printf("\n");
  }	
}



int main(void){

 int *mat, *transp;
 int *dev_mat, *dev_transp;	
 int size = N*N*sizeof(int);
 int i,j;

 cudaMalloc( (void**)&dev_mat, size );
 cudaMalloc( (void**)&dev_transp, size );
 
  	 

 mat = (int*)malloc(size);
 transp = (int*)malloc(size);
 
 
 for(i = 0; i < N; i++)
    for(j = 0; j < N; j++)
	    mat[i*N + j] = i;
 	   
 print_mat(mat);
 
 cudaMemcpy(dev_mat, mat, size, cudaMemcpyHostToDevice );
  
 transpose<<< N, N_THREADS >>>(dev_mat, dev_transp);
 
 cudaMemcpy(transp, dev_transp, size, cudaMemcpyDeviceToHost);
 
 print_mat(transp);

 free(mat); free(transp);

 cudaFree(dev_mat);
 cudaFree(dev_transp);


return 0;
}
