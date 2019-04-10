#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

double f(double x)
{       
  return 1.0/(1+x*x);
}


double local_sum(double local_a, double local_b, int local_n, double h)
{	
  unsigned int i;
  double local_result = 0;
  for( i = 0 ; i< local_n; ++i)
    {
      double x_i = local_a + i*(h/2.0);
      local_result += f(x_i);
    }	

  local_result = h* local_result;
  return local_result;

}


int main(){

  double global_result = 0.0;
  unsigned int i;
  int b = 1;
  int a = 0;
  int n = 1000000000;
  int global_nthreads = 0;
  double time;
  double tstart = omp_get_wtime();
#pragma omp parallel reduction(+:global_result)
  {
    double h = (b-a)*1.0/n;
    int tid = omp_get_thread_num();
    int nthreads = omp_get_num_threads();
    global_nthreads = nthreads;
    int local_n = n/nthreads;
    double local_a = a+ tid*local_n*h;
    double local_b = local_a + local_n*h;
    double local_result = local_sum(local_a, local_b, local_n, h);
	

//#pragma omp critical
    //global_result +=local_result;
    global_reuslt += local_sum(local_a, local_b, local_n, h);	
  }

  time = omp_get_wtime() -tstart;

  global_result = global_result*4;

  printf("With %d approximated pi is %lf in %lf\n", global_nthreads, global_result, time);
  return 0;
}
