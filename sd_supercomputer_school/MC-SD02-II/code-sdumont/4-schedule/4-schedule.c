#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <unistd.h>

void schedule(int *v, int N){
  int i = 0;

  #pragma omp parallel for schedule(guided, 1)
  for(i = 0; i < N; i++){
     v[i] = omp_get_thread_num();

     // PARA TESTAR O DESBALANCEAMENTO DE CARGA COM DYNAMIC
     if (v[i] < 3 && i>10) sleep(1);

     // SENAO sleep(1)
  }

}

int main(){
	int i, j, n;

	omp_set_num_threads(4);
	n = 24;
	
	printf("number of elements: %d\n", n);
	
	int *vector = (int *) calloc(n, sizeof(int));
	if(vector == NULL){
		fprintf(stderr, "Out of memory!\n");
		exit(EXIT_FAILURE);
	}

	schedule(vector, n);

	for(j = 0; j < 4; j++){
		printf("\nT%d: ", j);
		for(i = 0; i < n; i++)
			if(vector[i] == j)
				printf("%2d ", i);
	}
	printf("\n");
	
	return 0;
}
