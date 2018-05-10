#include <iostream>
#include<math.h>
#include<queue>
#include "cuda.h"
#include "cuda_runtime.h"
//#include<cuda_runtime_api.h>

using namespace std;


void __global__ moveLeft(int* matrix)
{

    int mergeCount;
    int temp[4];
    
    //printf("Hello from GPU..\n");
    temp[0] = temp[1] = temp[2] = temp[3] = 0;
	
    while (1) {
		//printf("Running Left");
        mergeCount = 0;
		printf("Left Merge Count before: %d \n",mergeCount);
		
        for (int i = 4*(threadIdx.x+blockIdx.x*blockDim.x)+1; i < 4*(threadIdx.x+blockIdx.x*blockDim.x)+4; i++) {
            if (matrix[i] != 0 && matrix[i] == matrix[i - 1] && temp[i - 1] != 1 && temp[i] != 1) {
                matrix[i - 1] = 1 + matrix[i];
                matrix[i] = 0;
                temp[i - 1] = 1;
                mergeCount++;
            } else if (matrix[i] != 0 && matrix[i - 1] == 0) {
                matrix[i - 1] = matrix[i];
                matrix[i] = 0;
                mergeCount++;
            }
        }
        if (mergeCount == 0) break;

    }

}


void __global__ moveRight(int* matrix)
{

    int mergeCount;
    int temp[4];

    temp[0] = temp[1] = temp[2] = temp[3] = 0;
	int start=4*(threadIdx.x+blockIdx.x*blockDim.x)+2;
	int end=4*(threadIdx.x+blockIdx.x*blockDim.x);
	
	//printf("Thread Idx: %d , start: %d , end: %d", threadIdx.x,4*(threadIdx.x+blockIdx.x*blockDim.x)+2,4*(threadIdx.x+blockIdx.x*blockDim.x));
    while (1) {
		printf("Running Right");
        mergeCount = 0;
		//printf("Merge Count before: %d \n",mergeCount);
        for (int i = start; i >=end; i--) {
			//printf("Running Right for loop %d  %d  %d %d",i,(threadIdx.x+blockIdx.x*blockDim.x),blockIdx.x,blockDim.x);
            if (matrix[i] != 0 && matrix[i] == matrix[i + 1] && temp[i + 1] != 1 && temp[i] != 1) {
                matrix[i + 1] = 1 + matrix[i];
                matrix[i] = 0;
                temp[i + 1] = 1;
                mergeCount++;
            } else if (matrix[i] != 0 && matrix[i + 1] == 0) {
                matrix[i + 1] = matrix[i];
                matrix[i] = 0;
                mergeCount++;
            }
        }
		//printf("Merge Count outside for: %d \n",mergeCount);
        if (mergeCount == 0) break;
		break;

    }
}


void __global__ moveUp(int* matrix)
{

    int mergeCount;
    int temp[16];
    
    for(int i=0;i<16;i++){
        temp[i]=0;
    }

    while (1) {

        mergeCount = 0;

        for (int i = (threadIdx.x+blockIdx.x*16)+4; i < (blockIdx.x+1)*16; i+=4) {
            if (matrix[i] != 0 && matrix[i] == matrix[i - 4] && temp[(i - 4)%16] != 1 && temp[i%16] != 1) {
                matrix[i - 4] = matrix[i] + 1;
                matrix[i] = 0;
                temp[(i - 4)%16] = 1;
                mergeCount++;
            } else if (matrix[i] != 0 && matrix[i - 4] == 0) {
                matrix[i - 4] = matrix[i];
                matrix[i] = 0;
                mergeCount++;
            }
//               mergeCount--;
        }

        if (mergeCount == 0) break;

    }
}


void __global__ moveDown(int* matrix)
{

    int mergeCount;
    int temp[16];

    int start=((blockIdx.x+1)*16)-8+threadIdx.x;
	int end = (blockIdx.x)*16;
	//printf("STrt: %d End: %d",start,end);
    while (1) {

        mergeCount = 0;

        for (int i = start; i >= end ; i-=4) {
            if (matrix[i] != 0 && matrix[i] == matrix[i + 4] && temp[(i + 4)%16] != 1 && temp[i%16] != 1) {
                matrix[i + 4] = matrix[i] + 1;
                matrix[i] = 0;
                temp[(i + 4)%16] = 1;
                mergeCount++;
            } else if (matrix[i] != 0 && matrix[i + 4] == 0) {
                matrix[i + 4] = matrix[i];
                matrix[i] = 0;
                mergeCount++;
            }
//               mergeCount--;
        }

        if (mergeCount == 0) break;

    }
}


void printMatrix(int*** matrix)
{
    for(int i=0;i<4;i++) {
        for (int j = 0; j < 4; j++) {

            if(matrix[i][j]!=0)
                cout<<pow(2,matrix[0][i][j])<<" ";
            else
                cout<<0<<" ";

        }
        cout<<endl;
    }
}

void __global__ generate_copy_for_child_type1(int* input_matrix,int* output_matrix, int* output_rv, int n){
	  int thread_index = threadIdx.x;
	  int block_index = blockIdx.x;
	  int start=((block_index)*16);
      for(int child=0;child<4;child++){
          int child_start = ((blockIdx.x*4)+child)*16;
          output_matrix[child_start+thread_index]=input_matrix[start+thread_index];
      }
      output_rv[block_index]=0;
}

void __global__ consolidate_return_values(int* input_rv,int* output_rv,int n){
		int block_index = blockIdx.x;
      int i = 4*block_index;
      output_rv[block_index] = max(max(input_rv[i],input_rv[i+1]),max(input_rv[i+2],input_rv[i+3]));
}

__global__ void runExpectiMaxSearch(int* matrix,int n,int type,int level,int* rv)
{

    int max_level = 5;
    if(level == max_level)
    {
        printf("Terminal.........\n");
        int i=threadIdx.x+(blockDim.x*blockIdx.x);
        if(i<n){
            rv[i]=0;
            int index_i = i*16;
            for(int j=0;j<4;j++){
                int index_j = j*4;
                for(int k=0;k<4;k++){
                    if(matrix[index_i+index_j+k]==0){
                        rv[i]++;
                    }
                }
            }
        }
    }

    else if(type == 1)
    {
        //LRUD configuration
        printf("Directions.........\n");
        int* child_matrix = (int *)malloc(n*4*16*sizeof(int));
        int* child_rv = (int *)malloc(n*4*sizeof(int));
        generate_copy_for_child_type1<<<n,16>>>((int *)matrix,child_matrix,child_rv,n);
        cudaDeviceSynchronize();

		printf("1.........\n");
        cudaStream_t left;
        cudaStreamCreateWithFlags(&left, cudaStreamNonBlocking);
        moveLeft<<<n,4,0,left>>>(child_matrix);
        
		cudaDeviceSynchronize();
		printf("1.1.........\n");
		
        cudaStream_t right;
        cudaStreamCreateWithFlags(&right, cudaStreamNonBlocking);
        moveRight<<<n,4,0,right>>>(child_matrix);
        
		cudaDeviceSynchronize();
		printf("1.2.........\n");
        cudaStream_t up;
        cudaStreamCreateWithFlags(&up, cudaStreamNonBlocking);
        moveUp<<<n,4,0,up>>>(child_matrix);
        
		cudaDeviceSynchronize();
		printf("1.3.........\n");
        cudaStream_t down;
        cudaStreamCreateWithFlags(&down, cudaStreamNonBlocking);
        moveDown<<<n,4,0,down>>>(child_matrix);
        cudaDeviceSynchronize();
		printf("2.........\n");

		if(level!=max_level-1){
			runExpectiMaxSearch<<<1,1>>>(child_matrix,4*n,type+1,level+1,child_rv);
		}
		else if(level==max_level-1){
			runExpectiMaxSearch<<<1,1>>>(child_matrix,4*n,type+1,level+1,child_rv);
		}
        cudaDeviceSynchronize();

		printf("3.........\n");
        consolidate_return_values<<<n,1>>>(child_rv,rv,n);
        cudaDeviceSynchronize();
        printf("4.........\n");
        if(level==0){
            if(child_rv[0]>child_rv[1]){
                if(child_rv[0]>child_rv[2]){
                    if(child_rv[0]>child_rv[3]){
                        rv[0]=0;
                    }
                    else{
                        rv[0]=3;
                    }
                }
                else{
                    if(child_rv[2]>child_rv[3]){
                        rv[0]=2;
                    }
                    else{
                        rv[0]=3;
                    }
                }
            }
            else{
                if(child_rv[1]>child_rv[2]){
                    if(child_rv[1]>child_rv[3]){
                        rv[0]=1;
                    }
                    else{
                        rv[0]=3;
                    }
                }
                else{
                    if(child_rv[2]>child_rv[3]){
                        rv[0]=2;
                    }
                    else{
                        rv[0]=3;
                    }
                }
            }
        }
        free(child_rv);
		free(child_matrix);
		printf("5.........\n");
    }
    else {
        printf("Chances.........\n");
        int count = 0;
		int *n_count;
		n_count = (int *)malloc(sizeof(int)*n);
        int *temp;
        temp = (int *)malloc(sizeof(int)*n);

        for (int i = 0; i < n; i++) {
			int index_i = i*16;
			int num=0;
			temp[i]=0;
			n_count[i]=0;
            for (int j = 0; j < 4; j++) {
				int index_j = j*4;
                for (int k = 0; k < 4; k++) {
                    if (matrix[index_i+index_j+k] == 0){
                        count++;
						num++;
					}
                }
            }

            if (i == 0){
                temp[0] = count;
				n_count[0] = count;
			}
            else{
                temp[i] = num;
				n_count[i] = count;
			}

        }

        int *matrix1 = (int *)malloc(count*16*(sizeof(int)));

        int *rv1 = (int *)malloc(count*sizeof(int));

        for (int i = 0; i < count; i++) rv1[i] = 0;

		int i=0;
		int k=0;
		
        for (int l = 0; l < n; l++) {
            int flag=0;
			int index_l = l*16;
            for (int i = 0; i < temp[l]; i++) {
                int index = i;
                if (l != 0) {
                    index += n_count[l - 1];
                }
                flag=0;
				int index_i = index*16;
                for (int j = 0; j < 4; j++) {
					int index_j = j*4;
                    for (int k = 0; k < 4; k++) {
                        if (matrix[index_l+index_j+k] == 0 && flag==0) {
                            matrix1[index_i+index_j+k] = 1;
                            matrix[index_l+index_j+k] = -1;
                            flag==1;
                        } else {
                            matrix1[index_i+index_j+k] = matrix[index_l+index_j+k];
                            if(matrix[index_l+index_j+k] == -1){
                                matrix1[index_i+index_j+k] == 0;
                            }
                        }

                    }
                }

            }

        }

		if(level!=max_level-1){
			runExpectiMaxSearch<<<1,1>>>(matrix1, count, type-1, level + 1, rv1);
		}
		else if(level==max_level-1){
			runExpectiMaxSearch<<<1,count>>>(matrix1, count, type-1, level + 1, rv1);
		}

		cudaDeviceSynchronize();
		int l,p;
		l=k=p=0;
        for (int l = 0; l < n; l++) {
            int q= temp[l];
			if(q==0){
				rv[k]=0;
				k++;
				continue;
			}
			while(q--){
				rv[k]+=rv1[p++];
			}
			rv[k]/=temp[l];
			k++;
        }
		free(matrix1);
		free(temp);
		free(n_count);
		free(rv1);
    }

}

int main() {

    int* matrix = (int *)malloc(sizeof(int)*16);
	int* d_matrix;
    int* rv = (int *)malloc(sizeof(int));
	int *d_rv;

	int matrix_size = sizeof(int)*16;
	int rv_size = sizeof(int)*1;
	cudaMalloc(&d_matrix,matrix_size);
	cudaMalloc(&d_rv,rv_size);
	
    rv[0]=0;


    matrix[0] = 2;
    matrix[1] = 2;
    matrix[2] = 3;
    matrix[3] = 4;

    matrix[4] = 2;
    matrix[5] = 2;
    matrix[6] = 0;
    matrix[7] = 0;

    matrix[8] = 2;
    matrix[9] = 0;
    matrix[10] = 0;
    matrix[11] = 0;

    matrix[12] = 3;
    matrix[13] = 4;
    matrix[14] = 4;
    matrix[15] = 5;
	
	
    cout<<"Boooooom"<<endl;
    
	for(int i=0;i<16;i++){
		cout<<matrix[i]<<" ";
	}
	cout<<endl;
	cudaMemcpy(d_matrix,matrix,matrix_size,cudaMemcpyHostToDevice);
	cudaMemcpy(d_rv,rv,rv_size,cudaMemcpyHostToDevice);
	
	runExpectiMaxSearch<<<1,1>>>(d_matrix,1,1,0,d_rv);
	
	cudaDeviceSynchronize();
	cudaError_t err;
	err = cudaGetLastError();
	if(err!=cudaSuccess){
		printf("Error %s \n",cudaGetErrorString(err));
	}
	//cudaMemcpy(matrix,d_matrix,matrix_size,cudaMemcpyDeviceToHost);
	cudaMemcpy(rv,d_rv,rv_size,cudaMemcpyDeviceToHost);
	cudaDeviceSynchronize();
	for(int i=0;i<16;i++){
		cout<<matrix[i]<<" ";
	}
	cout<<endl;

    if(rv[0]==0){
        cout<<"Left"<<endl;
    }
    if(rv[0]==1){
        cout<<"Right"<<endl;
    }
    if(rv[0]==2){
        cout<<"Up"<<endl;
    }
    if(rv[0]==3){
        cout<<"Down"<<endl;
    }

    return 0;
}
