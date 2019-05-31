#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define N 10
#define N_THREADS 1
#define MAX_ELEM_VALUE 10
#define CACHE_BLOCK 32
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

 __shared__ float in_cache[CACHE_BLOCK*CACHE_BLOCK + 1];

 int x = blockIdx.x * CACHE_BLOCK + threadIdx.x;
 int y = blockIdx.y * CACHE_BLOCK + threadIdx.y;
 int width = gridDim.x * CACHE_BLOCK;

 for(unsigned int i = 0; i < CACHE_BLOCK; i+= ROWS)
        in_cache[(threadIdx.y+i)*CACHE_BLOCK + threadIdx.x] = mat[x + (y+i)*width];

 __syncthreads();

 x = blockIdx.x * CACHE_BLOCK + threadIdx.x;
 y = blockIdx.y * CACHE_BLOCK + threadIdx.y;

 for(unsigned int j = 0; j < CACHE_BLOCK; j+= ROWS)
         transp[x + (y+j)*width] = in_cache[threadIdx.x + CACHE_BLOCK*(threadIdx.y+j)];
}

v


void print_mat(int* mat){

 int i, j;

 for(i = 0; i < N; i++){
    for(j = 0; j < N; j++)
     printf("%d ",mat[i*N + j]);

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
 block.x = CACHE_BLOCK;
 block.y = ROWS;
 grid.x = N/CACHE_BLOCK;
 grid.y = N/CACHE_BLOCK;

 cudaMalloc( (void**)&dev_mat, size );
 cudaMalloc( (void**)&dev_transp1, size );
 cudaMalloc( (void**)&dev_transp2, size );
 mat = (float*)malloc(size);
 transp1 = (float*)malloc(size);
 transp2 = (float*)malloc(size);
 test_mat = (float*)malloc(size);



 randomly_fill_matrix(mat);
 print_mat(mat);

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
 float time_naive = 0;
 cudaEventElapsedTime(&time_naive, start, stop);

 cudaMemcpy(transp1, dev_transp1, size, cudaMemcpyDeviceToHost);

 if(test(transp1, test_mat)) printf("correct1\n");
 else printf("not correct1\n");

 free(transp1); cudaFree(dev_transp1);

 //-------------//

 cudaEventRecord(start);
 shared_transpose<<< grid,block >>>(dev_mat, dev_transp2);
 cudaEventRecord(stop);


 cudaEventSynchronize(stop);
 float time_shared = 0;
 cudaEventElapsedTime(&time_shared, start, stop);

 cudaMemcpy(transp2, dev_transp2, size, cudaMemcpyDeviceToHost);

 if(test(transp2, test_mat)) printf("correct2\n");
 else printf("not correct2\n");

 free(transp2); cudaFree(dev_transp2);
 //-------------//


 print_mat(transp2);
 int n_threads = N_THREADS;
 printf("with %d threads time for a naive transpose is %fms while in shared memory is %fms\n", n_threads, time_naive, time_shared);

 free(mat); cudaFree(dev_mat);

return 0;
}