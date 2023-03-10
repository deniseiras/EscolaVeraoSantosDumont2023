#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define OUTFILE "out_julia.bmp"

int compute_julia_pixel(int x, int y, int width, int height, float tint_bias, unsigned char *rgb);
int write_bmp_header(FILE *f, int width, int height);

int main(int argc, char *argv[])
{
    int N= 0, AREA= 0, subAREA, WIDTH= 0, HEIGHT= 0, subHEIGHT= 0, range[3], remainder= 0, offset=0, local_i= 0;
    int size, myrank;
    FILE *output_file;
    unsigned char *local_pixel_array, *rgb;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);

    if (argc <= 1){
        fprintf(stderr,"Should pass 'N' as a positive integer. Exiting!\n");
        MPI_Finalize();
        return -1;
    }
    N= atoi(argv[1]);
    if (N < 1){
        fprintf(stderr,"hould pass 'N' as a positive integer. Exiting\n");
        MPI_Finalize();
        return -1;
    }

    HEIGHT= N;
    WIDTH= 2*N;
    AREA= HEIGHT*WIDTH*3;
    subHEIGHT= HEIGHT/size;
    remainder= HEIGHT%size;
    if (remainder != 0)
    {
        if (remainder < size){
            if (myrank < remainder){
                subHEIGHT++;
            } else {
                offset= remainder;
            }
        }
    }

    range[0]= myrank*(subHEIGHT)+offset;
    range[1]= range[0]+subHEIGHT-1;

    subAREA= subHEIGHT*WIDTH*3;

    //Allocate mem for the pixels array
    local_pixel_array= calloc(subAREA, sizeof(unsigned char));
    rgb= calloc(3, sizeof(unsigned char));

    printf("[Process %d out of %d]: I should compute pixel rows %d to %d, for a total of %d rows - subAREA %d of total AREA %d\n", myrank, size, range[0], range[1], subHEIGHT, subAREA, AREA);


    for (int i= range[0]; i <= range[1]; i++){
        for (int j= 0; j < WIDTH*3; j+=3){
            compute_julia_pixel(j/3, i, WIDTH, HEIGHT, 1.0, rgb);
            local_pixel_array[local_i]= rgb[0];
            local_i++;
            local_pixel_array[local_i]= rgb[1];
            local_i++;
            local_pixel_array[local_i]= rgb[2];
            local_i++;
        }
    }
    //Release mem for the pixels array
    free(rgb);


    //WRITE THE OUTPUT FILE



    if (myrank == 0) {
        // the first rank writes the header of the file
        char done[1]= {1};
        //write the file header
        output_file= fopen(OUTFILE, "w");
        write_bmp_header(output_file, WIDTH, HEIGHT);

        //write the local array in the file
        fwrite(local_pixel_array, sizeof(unsigned char), subAREA, output_file);
        fclose(output_file);
        free(local_pixel_array);

        //send the token to the next rank to write the output file
        MPI_Send(&done, 1, MPI_CHAR, myrank+1, 1, MPI_COMM_WORLD);

    } else {
        char done[1]= {1};
        //every other rank enters in a "wait" state, wating for its turn to write the data
       	MPI_Recv(&done, 1, MPI_CHAR, myrank-1, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
       	//only write if the rank actually processed some data
       	if (subAREA > 0){

            //write the local array in the file
            output_file= fopen(OUTFILE, "a");
            fwrite(local_pixel_array, sizeof(unsigned char), subAREA, output_file);
            fclose(output_file);
            free(local_pixel_array);
       	}
        if (myrank < size-1){
            //send the token to the next rank to write the output file
            MPI_Send(&done, 1, MPI_CHAR, myrank+1, 1, MPI_COMM_WORLD);
        }
    }

    //wait for all ranks to finish
    MPI_Barrier(MPI_COMM_WORLD);

    MPI_Finalize();


    return 0;
}




/*
 * compute_julia_pixel(): compute RBG values of a pixel in a
 *                        particular Julia set image.
 *
 *  In:
 *      (x,y):            pixel coordinates
 *      (width, height):  image dimensions
 *      tint_bias:        a float to "tweak" the tint (1.0 is "no tint")
 *  Out:
 *      rgb: an already-allocated 3-byte array into which R, G, and B
 *           values are written.
 *
 *  Return:
 *      0 in success, -1 on failure
 *
 */

int compute_julia_pixel(int x, int y, int width, int height, float tint_bias, unsigned char *rgb) {

  // Check coordinates
  if ((x < 0) || (x >= width) || (y < 0) || (y >= height)) {
    fprintf(stderr,"Invalid (%d,%d) pixel coordinates in a %d x %d image\n", x, y, width, height);
    return -1;
  }

  // "Zoom in" to a pleasing view of the Julia set
  float X_MIN = -1.6, X_MAX = 1.6, Y_MIN = -0.9, Y_MAX = +0.9;
  float float_y = (Y_MAX - Y_MIN) * (float)y / height + Y_MIN ;
  float float_x = (X_MAX - X_MIN) * (float)x / width  + X_MIN ;

  // Point that defines the Julia set
  float julia_real = -.79;
  float julia_img = .15;

  // Maximum number of iteration
  int max_iter = 300;

  // Compute the complex series convergence
  float real=float_y, img=float_x;
  int num_iter = max_iter;
  while (( img * img + real * real < 2 * 2 ) && ( num_iter > 0 )) {
    float xtemp = img * img - real * real + julia_real;
    real = 2 * img * real + julia_img;
    img = xtemp;
    num_iter--;
  }

  // Paint pixel based on how many iterations were used, using some funky colors
  float color_bias = (float) num_iter / max_iter;
  rgb[0] = (num_iter == 0 ? 200 : - 500.0 * pow(tint_bias, 1.2) *  pow(color_bias, 1.6));
  rgb[1] = (num_iter == 0 ? 100 : -255.0 *  pow(color_bias, 0.3));
  rgb[2] = (num_iter == 0 ? 100 : 255 - 255.0 * pow(tint_bias, 1.2) * pow(color_bias, 3.0));

  return 0;
}


/* write_bmp_header():
 *
 *   In:
 *      f: A file open for writing ('w')
 *      (width, height): image dimensions
 *
 *   Return:
 *      0 on success, -1 on failure
 *
 */

int write_bmp_header(FILE *f, int width, int height) {

  unsigned int row_size_in_bytes = width * 3 +
	  ((width * 3) % 4 == 0 ? 0 : (4 - (width * 3) % 4));

  // Define all fields in the bmp header
  char id[2] = "BM";
  unsigned int filesize = 54 + (int)(row_size_in_bytes * height * sizeof(char));
  short reserved[2] = {0,0};
  unsigned int offset = 54;

  unsigned int size = 40;
  unsigned short planes = 1;
  unsigned short bits = 24;
  unsigned int compression = 0;
  unsigned int image_size = width * height * 3 * sizeof(char);
  int x_res = 0;
  int y_res = 0;
  unsigned int ncolors = 0;
  unsigned int importantcolors = 0;

  // Write the bytes to the file, keeping track of the
  // number of written "objects"
  size_t ret = 0;
  ret += fwrite(id, sizeof(char), 2, f);
  ret += fwrite(&filesize, sizeof(int), 1, f);
  ret += fwrite(reserved, sizeof(short), 2, f);
  ret += fwrite(&offset, sizeof(int), 1, f);
  ret += fwrite(&size, sizeof(int), 1, f);
  ret += fwrite(&width, sizeof(int), 1, f);
  ret += fwrite(&height, sizeof(int), 1, f);
  ret += fwrite(&planes, sizeof(short), 1, f);
  ret += fwrite(&bits, sizeof(short), 1, f);
  ret += fwrite(&compression, sizeof(int), 1, f);
  ret += fwrite(&image_size, sizeof(int), 1, f);
  ret += fwrite(&x_res, sizeof(int), 1, f);
  ret += fwrite(&y_res, sizeof(int), 1, f);
  ret += fwrite(&ncolors, sizeof(int), 1, f);
  ret += fwrite(&importantcolors, sizeof(int), 1, f);

  // Success means that we wrote 17 "objects" successfully
  return (ret != 17);
}
