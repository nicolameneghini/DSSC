#include <stdio.h>
#include <math.h>
#include <stdlib.h>


#define MAX_ELEM_VALUE 10

#define N 8192
#define BLOCK_X 32
#define BLOCK_Y 32

int n_threads = 1024;


__global__ void transpose(float* mat, float *transp){

 int index = threadIdx.x + blockIdx.x*blockDim.x;
 int x = index%N;
 int y = index/N;
 transp[y*N+x] = mat[x*N+y];

}

__global__ void shared_transpose(float* mat, float *transp){

    __shared__ double in_cache[BLOCK_X][BLOCK_Y+1];

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
 block.x = BLOCK_X;
 block.y = BLOCK_Y;
 grid.x = N/BLOCK_X;
 grid.y = N/BLOCK_Y;

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
 transpose<<< (N*N)/n_threads, n_threads  >>>(dev_mat, dev_transp1);
 cudaEventRecord(stop);

 cudaEventSynchronize(stop);
 float time = 0;
 cudaEventElapsedTime(&time, start, stop);

 cudaMemcpy(transp1, dev_transp1, size, cudaMemcpyDeviceToHost);

 printf("%d %f ", n_threads, time);

 //-------------//

 cudaEventRecord(start);
 shared_transpose<<< grid , block >>>(dev_mat, dev_transp2);
 cudaEventRecord(stop);


 cudaEventSynchronize(stop);
 time = 0;
 cudaEventElapsedTime(&time, start, stop);

 cudaMemcpy(transp2, dev_transp2, size, cudaMemcpyDeviceToHost);

 printf("%f ", n_threads, time);

 if(test(transp1, test_mat)) printf("correct naive ");
 else printf("not correct naive ");

 if(test(transp2, test_mat)) printf("correct shared\n");
 else printf("not correct shared\n");

 //-------------//

 free(transp1); cudaFree(dev_transp1);
 free(transp2); cudaFree(dev_transp2);
 free(mat); cudaFree(dev_mat);

return 0;
}
