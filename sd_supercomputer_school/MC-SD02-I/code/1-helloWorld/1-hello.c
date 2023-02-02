#include <stdio.h>
#include <omp.h>

int main(){
	int myid, nthreads;
	//omp_set_num_threads(4); -> sobrescreve OMP_NUM_THREADS
	
	#pragma omp parallel private(myid, nthreads)
	{
	myid = omp_get_thread_num();
	nthreads = omp_get_num_threads();

	printf("%d of %d - hello world!\n", myid, nthreads);
	}

	return 0;
}
