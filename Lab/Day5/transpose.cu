#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define N 8192
#define N_THREADS 1024
#define MAX_ELEM_VALUE 10
#define BLOCK 32
#define ROWS 8

__global__ void transpose(float* mat, float *transp){


 //int y = blockIdx.x;
 //int x = threadIdx.x;

 //while(x < N){
  //transp[y*N + x] = mat[x*N + y];
  //x += blockDim.x;
 //}


  //transp[y*N + x] = mat[x*N + y];
  //x += blockDim.x;
 //}
 int index = threadIdx.x + blockIdx.x*blockDim.x;
 int x = index%N;
 int y = index/N;
 transp[y*N+x] = mat[x*N+y];
}

__global__ void shared_transpose(float* mat, float *transp){

    __shared__ double in_cache[BLOCK][BLOCK+1];
    
    int index_x = blockIdx.x * blockDim.x + threadIdx.x;
    int index_y = blockIdx.y * blockDim.y + threadIdx.y;
    
    in_cache[threadIdx.x][threadIdx.y] = mat[index_y * N + index_x];
    
    __syncthreads();
    
    transp[index_x * N + index_y] = in_cache[threadIdx.x][threadIdx.y];

}


void print_mat(float* mat){

 int i, j;

 for(i = 0; i < N; i++){
    for(j = 0; j < N; j++)
     printf("%f ",mat[i*N + j]);

    printf("\n");
  }
}

void randomly_fill_matrix(float *A)
{
  for (unsigned int i = 0; i < N; i++)
  {
    for (unsigned int j = 0; j < N; j++)
    {
      A[i*N + j] = rand() % (2 * MAX_ELEM_VALUE) - MAX_ELEM_VALUE;
    }
  }
}

void normal_transpose(float *mat, float *transp)
{
  for (unsigned int i = 0; i < N; i++)
          for (unsigned int j = 0; j < N; j++)
                  transp[i +j*N] = mat[i*N + j];
}


int test(float *a, float *b)
{

   for (unsigned int i = 0; i < N; i++){
      for (unsigned int j = 0; j < N; j++){
              if(b[i*N + j] != a[i*N + j])
                      return 0;
        }
   }

   return 1;
}

int main(void){

 float *mat, *transp1, *transp2, *test_mat;
 float *dev_mat, *dev_transp1, *dev_transp2;
 int size = N*N*sizeof(double);
 cudaEvent_t start, stop;
 dim3 grid, block;
 block.x = BLOCK;
 block.y = BLOCK;
 grid.x = N/BLOCK;
 grid.y = N/BLOCK;

 cudaMalloc( (void**)&dev_mat, size );
 cudaMalloc( (void**)&dev_transp1, size );
 cudaMalloc( (void**)&dev_transp2, size );
 mat = (float*)malloc(size);
 transp1 = (float*)malloc(size);
 transp2 = (float*)malloc(size);
 test_mat = (float*)malloc(size);



 randomly_fill_matrix(mat);
 //print_mat(mat);

 normal_transpose(mat, test_mat);


 //----------//
 cudaEventCreate(&start);
 cudaEventCreate(&stop);

 cudaMemcpy(dev_mat, mat, size, cudaMemcpyHostToDevice );

 //-------------//
 cudaEventRecord(start);
 transpose<<< (N*N)/N_THREADS, N_THREADS >>>(dev_mat, dev_transp1);
 cudaEventRecord(stop);



 cudaEventSynchronize(stop);
 float time = 0;
 cudaEventElapsedTime(&time, start, stop);

 cudaMemcpy(transp1, dev_transp1, size, cudaMemcpyDeviceToHost);

 if(test(transp1, test_mat)) printf("correct1\n");
 else printf("not correct1\n");
 int n_threads = N_THREADS; 
 printf("With %d threads time for naive transpose is %fms\n", n_threads, time);

 free(transp1); cudaFree(dev_transp1);

 //-------------//

 cudaEventRecord(start);
 shared_transpose<<< grid , block >>>(dev_mat, dev_transp2);
 cudaEventRecord(stop);


 cudaEventSynchronize(stop);
 time = 0;
 cudaEventElapsedTime(&time, start, stop);

 cudaMemcpy(transp2, dev_transp2, size, cudaMemcpyDeviceToHost);

 if(test(transp2, test_mat)) printf("correct2\n");
 else printf("not correct2\n");

 free(transp2); cudaFree(dev_transp2);
 //-------------//


 //print_mat(transp2);
 printf("time in shared memory is %fms\n", n_threads, time);

 free(mat); cudaFree(dev_mat);

return 0;
}
