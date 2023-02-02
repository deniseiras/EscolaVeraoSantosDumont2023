#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <mpi.h>

#define BUFFER_SIZE 100

int main(int argc, char *argv[]) {
	int r, size, myrank, offset;
	double buffer[BUFFER_SIZE];

	MPI_File fh;
	MPI_Status s;

	MPI_Init(&argc, &argv);

	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);

	// Function to Open the file - HINT: verify the access modes
        r= MPI_File_open(MPI_COMM_WORLD, "write-i-ifp-double-buffer.data", MPI_MODE_CREATE|MPI_MODE_WRONLY, MPI_INFO_NULL, &fh);

	// Fill the buffer - HINT: Rebember, it's in double value!
	int i=0;
	for (i=0; i<BUFFER_SIZE; i++) {
		buffer[i] = myrank + (double)i / BUFFER_SIZE;
	}

	// Set a displacement of the buffer size for each process based on its rank - HINT: Use the function to change the file view
	// TO-DO testar internal e internal 32 ********
	MPI_File_set_view(fh, myrank * BUFFER_SIZE * sizeof(double), MPI_DOUBLE, MPI_DOUBLE, "native", MPI_INFO_NULL);

	// Function to Write with individual file pointer the entire buffer at once
	 MPI_File_write(fh, &buffer, BUFFER_SIZE, MPI_DOUBLE, &s);


	// Function to Close the file
	MPI_File_close(&fh);

	MPI_Finalize();

	return 0;
}
