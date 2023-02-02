#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
	int r, size, myrank, offset;
	char myrank_formatted;

	MPI_File fh;
	MPI_Status s;

	MPI_Init(&argc, &argv);

	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);

	// Function to Open the file - HINT: verify the access modes
	// TO-DO
	r = MPI_File_open( MPI_COMM_WORLD, "my-rank.txt", MPI_MODE_CREATE|MPI_MODE_WRONLY, MPI_INFO_NULL, &fh);

	int i=0;
	for (i=0; i<10; i++) {
		// Calculates the offset - HINT: offset = Position in the file expressed as a count of etypes
		// TO-DO
		offset= (myrank + (i * size)) * sizeof(MPI_CHAR);
		// Define the character rank - HINT: Write it as character
		// TO-DO
		myrank_formatted = '1' + myrank;

		// Function to Write the character at the defined offset - HINT: remember the MPI predefined or derived etypes
		// TO-DO
		MPI_File_write_at(fh, offset, &myrank_formatted, 1, MPI_CHAR, &s);
	}

	// Function to Close the file
	// TO-DO
	MPI_File_close(&fh);

	MPI_Finalize();

	return 0;
}
