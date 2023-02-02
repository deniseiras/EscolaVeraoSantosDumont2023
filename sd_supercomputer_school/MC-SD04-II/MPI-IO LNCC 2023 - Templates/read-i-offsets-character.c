#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
	int r, size, myrank, offset;
	char read_my_rank;

	MPI_File fh;
	MPI_Status s;

	MPI_Init(&argc, &argv);

	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);

	// Function to Open the file - HINT: verify the access modes
	r= MPI_File_open(MPI_COMM_WORLD, "my-rank.txt", MPI_MODE_RDONLY, MPI_INFO_NULL, &fh);

	int i=0;
	for (i=0; i<10; i++) {
		// Calculates the offset - HINT: offset = Position in the file expressed as a count of etypes
		offset= (myrank + (i * size)) * sizeof(MPI_CHAR);

		// Function to Read the character at the defined offset - HINT: remember the MPI predefined or derived etypes
		MPI_File_read_at(fh, offset, &read_my_rank, 1, MPI_CHAR, &s);

		// Print the rank, offset, and value
		printf("rank: %d, offset: %03d, read: %c\n", myrank, offset, read_my_rank);
	}

	// Function to Close the file
	MPI_File_close(&fh);

	MPI_Finalize();

	return 0;
}
