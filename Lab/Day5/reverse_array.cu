#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define N (2048*2048)
#define THREAD_PER_BLOCK 512

__global__ void reverse(int* a, int* b){
 
 int index_in  = threadIdx.x + blockIdx.x * blockDim.x;	
 int index_out = gridDim.x * blockDim.x - index_in - 1;

 b[index_out] = a[index_in];
 
}

void random_ints(int *p, int n) {
	int i;
	for(i=0; i<n; i++) {
		p[i]=i;
	}
}


int main(void) {
 
 int *in, *out, *test;
 int *dev_in, *dev_out;
 int size = N*sizeof(int);
 int i;


 cudaMalloc( (void**)&dev_in, size );
 cudaMalloc( (void**)&dev_out, size );

 in  = (int*)malloc( size );
 out = (int*)malloc( size );
 test = (int*)malloc( size );

 random_ints(in, N );
 
 cudaMemcpy( dev_in, in, size, cudaMemcpyHostToDevice );
 
 reverse<<< N/THREAD_PER_BLOCK, THREAD_PER_BLOCK >>>(dev_in, dev_out);

 cudaMemcpy(out, dev_out, size, cudaMemcpyDeviceToHost);
 
 for(i = 0; i < N; i++){
	test[N-i-1] = in[i];
 }
 for(i = 0; i < N; i++){
	if(test[i]!= out[i]){
		printf("error: expected %d, got %d!\n",test[i], out[i]);
		break;
	}
 }
 
 if(i==N) {
   printf("correct!\n");
 }  


 free(in); free(out);

 cudaFree(dev_in);
 cudaFree(dev_out);


return 0;
}
