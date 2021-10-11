#include<stdio.h>
#include <sys/time.h>

float timedifference_msec(struct timeval t0, struct timeval t1)
{
    return (t1.tv_sec - t0.tv_sec) * 1000.0f + (t1.tv_usec - t0.tv_usec) / 1000.0f;
}

__global__ void addArray(long long n,float* ga,float *gb){
    int id = blockIdx.x*blockDim.x+threadIdx.x;
    if(id < n)
        ga[id] += gb[id];
}
int main(void)
{
    struct timeval t0;
    struct timeval t1;
    struct timeval t2;
    struct timeval t3;
    float elapsed,processing_time;
    
    gettimeofday(&t0, 0);

    unsigned long long int n = 1000000000;
    float *a,*b,*ga,*gb;
    a = (float*)malloc(n*sizeof(float));
    b = (float*)malloc(n*sizeof(float));

    for (unsigned long long int i = 0; i < n; i++)
    {
        b[i] = 1.1f;
        a[i] = 2.2f;
    }

    
    cudaMalloc(&ga,n*sizeof(float));
    cudaMalloc(&gb,n*sizeof(float));
    
    cudaMemcpy(ga,a,n*sizeof(float),cudaMemcpyHostToDevice);
    cudaMemcpy(gb,b,n*sizeof(float),cudaMemcpyHostToDevice);
    int blockSize = 2;
    int gridSize = (int)ceil((float)n/blockSize);
    
    gettimeofday(&t1, 0);
    addArray<<<gridSize,blockSize>>>(n,ga,gb);
    gettimeofday(&t2, 0);
    
    cudaMemcpy(a,ga,n*sizeof(float),cudaMemcpyDeviceToHost);
    
    free(a);
    free(b);
    cudaFree(ga);
    cudaFree(gb);

    gettimeofday(&t3, 0);
    elapsed = timedifference_msec(t0, t3);
    processing_time = timedifference_msec(t1, t2);

    printf("\nTotal Time Elasped:%f \nProcessing Time:%f \n\n",elapsed,processing_time);
    return 0;
}