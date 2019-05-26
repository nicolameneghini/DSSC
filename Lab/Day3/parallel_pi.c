#include <mpi.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

double f(double x)
{
  return 1.0 / (1.0 + x * x);
}

double local_sum(double local_a, double local_b, int local_n, double h)
{
  unsigned int i;
  double local_result = 0;
  for (i = 0; i < local_n; ++i)
  {
    double x_i = local_a + i * (h / 2.0);
    local_result += f(x_i);
  }

  local_result = h * local_result;
  return local_result;
}

int main(int argc, char *argv[])
{

  int rank = 0; // store the MPI identifier of the process
  int npes = 1; // store the number of MPI processes
  double low = 0;
  double high = 1;
  long int n = 2000000000;

  double global_result;
  clock_t start, end;

  double cpu_time_used;

  start = clock();

  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &npes);
  double h = (high - low) * 1.0 / n;
  int last = npes - 1;
  int local_n = n / npes;
  double local_a = low + rank * local_n * h;
  double local_b = local_a + local_n * h;
  double local_result = local_sum(local_a, local_b, local_n, h);

  MPI_Reduce(&local_result, &global_result, 1, MPI_DOUBLE, MPI_SUM, last, MPI_COMM_WORLD);
  end = clock();
  cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
  if (rank == last)

    MPI_Send(&global_result, 1, MPI_DOUBLE, 0, 101, MPI_COMM_WORLD);

  if (rank == 0)
  {
    MPI_Recv(&global_result, 1, MPI_DOUBLE, last, 101, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    fprintf(stderr, "%d %lf\n", npes, cpu_time_used);
  }
  MPI_Finalize();
  return 0;
}
