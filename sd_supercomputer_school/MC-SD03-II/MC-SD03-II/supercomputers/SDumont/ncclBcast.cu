#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <nccl.h>
 
__global__ void kernel(int *a) 
{
  int index = threadIdx.x;
  a[index] *= 2;
  printf("%d\t", a[index]);
}
 
void printVector(int *in, int n)
{
 printf("\nThis is the host\n");
 for(int i = 0; i < n; i++)
  printf("%d\t", in[i]);
 printf("\n");
}

int main(int argc, char* argv[]) 
{
  /*Variables*/
  int dataSize = 8;
  int nGPUs = 0;
  cudaGetDeviceCount(&nGPUs); 
  printf("nGPUs = %d\n",nGPUs);
    
  int *h_data       = (int*)  malloc (dataSize  * sizeof(int));
  int **d_data      = (int**) malloc (nGPUs     * sizeof(int*));
  
  int *DeviceList   = (int *) malloc (nGPUs     * sizeof(int));
  for(int i = 0; i < nGPUs; i++)
      DeviceList[i] = i;
  
  /*Initializing NCCL with Multiples Devices per Thread*/
  ncclComm_t* comms      = (ncclComm_t*)  malloc(sizeof(ncclComm_t)  * nGPUs);  
  cudaStream_t* stream   = (cudaStream_t*)malloc(sizeof(cudaStream_t)* nGPUs);
  ncclCommInitAll(comms, nGPUs, DeviceList);
  
  /*Population the data vector*/
  for(int i = 0; i < dataSize; i++)
      h_data[i] = rand()%(10-2)*2;
 
  printVector(h_data, dataSize);
      
  for(int g = 0; g < nGPUs; g++) 
  {
      cudaSetDevice(g);
      cudaStreamCreate(&stream[g]);
      cudaMalloc(&d_data[g], dataSize * sizeof(int));
     
      if(g == 0)  /*Copy from Host to Device*/
         cudaMemcpy(d_data[g], h_data, dataSize * sizeof(int), cudaMemcpyHostToDevice);
  }
        
  ncclGroupStart();
  for(int g = 0; g < nGPUs; g++) 
  {
    cudaSetDevice(DeviceList[g]);
    ncclBcast(d_data[g], dataSize, ncclInt, 0, comms[g], stream[g]); /*Broadcasting it to all*/
  }
  ncclGroupEnd();       

  for(int g = 0; g < nGPUs; g++) 
  {
    cudaSetDevice(DeviceList[g]);
    printf("\nThis is the device [%d]\n", g);
    kernel <<< 1 , dataSize >>> (d_data[g]); /*Call the CUDA Kernel*/
    cudaDeviceSynchronize();             
  }

  printf("\n");
    
  for(int g = 0; g < nGPUs; g++)  /*Synchronizing CUDA Streams*/
  {                                
    cudaSetDevice(DeviceList[g]);
    cudaStreamSynchronize(stream[g]);
  }
 
  for(int g = 0; g < nGPUs; g++)   /*Destroy CUDA Streams*/
  {                                
    cudaSetDevice(DeviceList[g]);
    cudaStreamDestroy(stream[g]);
  }

  for(int g = 0; g < nGPUs; g++)   /*Finalizing NCCL*/
     ncclCommDestroy(comms[g]);
  
  /*Freeing memory*/
  free(h_data); 
  free(DeviceList);
  cudaFree(stream);
  cudaFree(d_data);

  return 0;
}
