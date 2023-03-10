void selection_sort(int *v, int n){
	int i, j, min, tmp, min_local;

	#pragma omp parallel private(j, min_local)
	{
		for(i = 0; i < n - 1; i++){
			min_local = i;
			min = i;

			#pragma omp for
			for(j = i + 1; j < n; j++)
				if(v[j] < v[min_local])
					min_local = j;
				
			#pragma omp critical
			if(v[min_local] < v[min])
				min = min_local;

			tmp = v[i];
			v[i] = v[min];
			v[min] = tmp;
		}
	}
}