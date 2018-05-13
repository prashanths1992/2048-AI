#include <iostream>
#include <stdio.h>
#include <math.h>
#include <queue>
#include <sys/types.h>
#include "cuda.h"
#include "cuda_runtime.h"
#include "cuda_runtime_api.h"

using namespace std;

string reset = "\u001b[0m";

unsigned GetNumberOfDigits (int i);

string getColor(int value)
{
    switch(value%10)
    {

        case 1:
            return "\u001b[37m\u001b[43;1m";

        case 2:
            return "\u001b[37m\u001b[44;1m";

        case 3:
            return "\u001b[37m\u001b[45;1m";

        case 4:
            return "\u001b[37m\u001b[46;1m";

        case 5:
            return "\u001b[37m\u001b[40;1m";

        case 6:
            return "\u001b[37m\u001b[41m";

        case 7:
            return "\u001b[37m\u001b[41;1m";

        case 8:
            return "\u001b[37m\u001b[42;1m";

        case 9:
            return "\u001b[37m\u001b[42m";

//        case 0:
//            return "\u001b[37m\u001b[45m";

        default:
            return "\u001b[30m\u001b[47m";

    }

}

string padNumber(int digits,int n,int empty)
{

    if(empty==0) {

        string ret="";
        digits+=2;

        while (digits--) {
            ret+=" ";
        }

        return ret;
    }

    string s="";

    int padValue = digits - GetNumberOfDigits(n);


    if(n!=1)
    {
        while(n)
        {
            s = char((n%10)+48)+s;
            n/=10;
        }
    }
    else
    {
        s=".";
    }

    if(padValue!=1)
    {
        while(padValue-->0)
        {
            s=" "+s;
            if(padValue!=0)
            {
                s+=" ";
            }
            padValue--;
        }
    }
    else
    {
        s = " "+s;
    }

    return " "+s+" ";

}


unsigned GetNumberOfDigits (int i)
{
    return i > 0 ? (int) log10 ((double) i) + 1 : 1;
}


void drawMatrix(int* matrix)
{

    int pad = 1;

    for(int i=0;i<4;i++){
        int index_i = i*4;
        for(int j=0;j<4;j++){
            pad = max(pad,matrix[index_i+j]);
        }
    }
    int  val = pow(2,pad);

    int digits = GetNumberOfDigits(val);
    digits = digits%2==0?digits+1:digits;

    for(int i=0;i<4;i++)
    {
        int index_i = i*4;
        for(int j=0;j<4;j++)
        {
            printf("%s%s%s",getColor(matrix[index_i+j]).c_str(),padNumber(digits,pow(2,matrix[index_i+j]),0).c_str(),reset.c_str());
        }
        printf("\n");
        for(int j=0;j<4;j++)
        {
            printf("%s%s%s",getColor(matrix[index_i+j]).c_str(),padNumber(digits,pow(2,matrix[index_i+j]),1).c_str(),reset.c_str());
        }
        printf("\n");
        for(int j=0;j<4;j++)
        {
            printf("%s%s%s",getColor(matrix[index_i+j]).c_str(),padNumber(digits,pow(2,matrix[index_i+j]),0).c_str(),reset.c_str());
        }
        printf("\n");
    }

}

void host_moveLeft(int* matrix)
{

    int mergeCount;
    int temp[4];

    for(int j=0;j<4;j++) {

        temp[0] = temp[1] = temp[2] = temp[3] = 0;
        
        int index_j=j*4;
        while (1) {

            mergeCount = 0;

            for (int i = 1; i < 4; i++) {
                if (matrix[index_j+i] != 0 && matrix[index_j+i] == matrix[index_j+i - 1] && temp[i - 1] != 1 && temp[i] != 1) {
                    matrix[index_j+i - 1] = 1 + matrix[index_j+i];
                    matrix[index_j+i] = 0;
                    temp[i - 1] = 1;
                    mergeCount++;
                } else if (matrix[index_j+i] != 0 && matrix[index_j+i - 1] == 0) {
                    matrix[index_j+i - 1] = matrix[index_j+i];
                    matrix[index_j+i] = 0;
                    mergeCount++;
                }
            }

            if (mergeCount == 0) break;

        }
    }

}


void host_moveRight(int* matrix)
{

    int mergeCount;
    int temp[4];

    for(int j=0;j<4;j++) {

        temp[0] = temp[1] = temp[2] = temp[3] = 0;
        int index_j = j*4;

        while (1) {

            mergeCount = 0;

            for (int i = 2; i >= 0; i--) {
                if (matrix[index_j+i] != 0 && matrix[index_j+i] == matrix[index_j+i + 1] && temp[i + 1] != 1 && temp[i] != 1) {
                    matrix[index_j+i + 1] = 1 + matrix[index_j+i];
                    matrix[index_j+i] = 0;
                    temp[i + 1] = 1;
                    mergeCount++;
                } else if (matrix[index_j+i] != 0 && matrix[index_j+i + 1] == 0) {
                    matrix[index_j+i + 1] = matrix[index_j+i];
                    matrix[index_j+i] = 0;
                    mergeCount++;
                }
            }

            if (mergeCount == 0) break;

        }
    }

}


void host_moveUp(int* matrix)
{

    int mergeCount;
    int temp[4];

    for(int j=0;j<4;j++) {

        temp[0] = temp[1] = temp[2] = temp[3] = 0;

        while (1) {

            mergeCount = 0;

            for (int i = 1; i < 4; i++) {
                if (matrix[i*4+j] != 0 && matrix[i*4+j] == matrix[(i - 1)*4+j] && temp[i - 1] != 1 && temp[i] != 1) {
                    matrix[(i - 1)*4+j] = matrix[i*4+j] + 1;
                    matrix[i*4+j] = 0;
                    temp[i - 1] = 1;
                    mergeCount++;
                } else if (matrix[i*4+j] != 0 && matrix[(i - 1)*4+j] == 0) {
                    matrix[(i - 1)*4+j] = matrix[i*4+j];
                    matrix[i*4+j] = 0;
                    mergeCount++;
                }
//               mergeCount--;
            }

            if (mergeCount == 0) break;

        }
    }
}


void host_moveDown(int* matrix)
{

    int mergeCount;
    int temp[4];

    for(int j=0;j<4;j++) {

        temp[0] = temp[1] = temp[2] = temp[3] = 0;

        while (1) {

            mergeCount = 0;

            for (int i = 2; i >= 0 ; i--) {
                if (matrix[i*4+j] != 0 && matrix[i*4+j] == matrix[(i + 1)*4+j] && temp[i + 1] != 1 && temp[i] != 1) {
                    matrix[(i + 1)*4+j] = matrix[i*4+j] + 1;
                    matrix[i*4+j] = 0;
                    temp[i + 1] = 1;
                    mergeCount++;
                } else if (matrix[i*4+j] != 0 && matrix[(i + 1)*4+j] == 0) {
                    matrix[(i + 1)*4+j] = matrix[i*4+j];
                    matrix[i*4+j] = 0;
                    mergeCount++;
                }
//               mergeCount--;
            }

            if (mergeCount == 0) break;

        }
    }
}

void __global__ moveLeft(int* matrix)
{

    int mergeCount;
    int temp[4];
    
    //printf("Hello from GPU..\n");
    temp[0] = temp[1] = temp[2] = temp[3] = 0;
	int start=(4*blockIdx.x)*16+4*threadIdx.x+1;
	int end=(4*blockIdx.x)*16+4*threadIdx.x+4;
	
	//printf("Left Thread Idx: %d ,Block Idx: %d, start: %d , end: %d , gridDIM: %d \n", threadIdx.x,blockIdx.x,start,end,gridDim.x);
    while (1) {
		//printf("Running Left");
        mergeCount = 0;
		//printf("Left Merge Count before: %d \n",mergeCount);
		
        for (int i = start; i < end; i++) {
            if (matrix[i] != 0 && matrix[i] == matrix[i - 1] && temp[(i - 1)%4] != 1 && temp[i%4] != 1) {
                matrix[i - 1] = 1 + matrix[i];
                matrix[i] = 0;
                temp[(i - 1)%4] = 1;
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
	int start=(4*blockIdx.x+1)*16+4*threadIdx.x+2;
	int end=(4*blockIdx.x+1)*16+4*threadIdx.x;
	
	//printf("Right Thread Idx: %d ,Block Idx: %d, start: %d , end: %d , gridDIM: %d \n", threadIdx.x,blockIdx.x,start,end,gridDim.x);
    while (1) {
        mergeCount = 0;
        for (int i = start; i >=end; i--) {
            if (matrix[i] != 0 && matrix[i] == matrix[i + 1] && temp[(i + 1)%4] != 1 && temp[i%4] != 1) {
                matrix[i + 1] = 1 + matrix[i];
                matrix[i] = 0;
                temp[(i + 1)%4] = 1;
                mergeCount++;
            } else if (matrix[i] != 0 && matrix[i + 1] == 0) {
                matrix[i + 1] = matrix[i];
                matrix[i] = 0;
                mergeCount++;
            }
        }
		//printf("Merge Count outside for: %d \n",mergeCount);
        if (mergeCount == 0) break;

    }
}


void __global__ moveUp(int* matrix)
{

    int mergeCount;
    int temp[16];
    
    for(int i=0;i<16;i++){
        temp[i]=0;
    }
	int start=(threadIdx.x+(4*blockIdx.x+2)*16)+4;
	int end = ((4*blockIdx.x+2)+1)*16;
	//printf("Up Thread Idx: %d ,Block Idx: %d, start: %d , end: %d , gridDIM: %d \n", threadIdx.x,blockIdx.x,start,end,gridDim.x);
    while (1) {

        mergeCount = 0;

        for (int i = start; i < end; i+=4) {
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
        }

        if (mergeCount == 0) break;

    }
}


void __global__ moveDown(int* matrix)
{

    int mergeCount;
    int temp[16];

    int start=(((4*blockIdx.x+3)+1)*16)-8+threadIdx.x;
	
	for(int i=0;i<16;i++){
        temp[i]=0;
    }
		
	int end = (4*blockIdx.x+3)*16;
	
	//printf("Down Thread Idx: %d ,Block Idx: %d, start: %d , end: %d , gridDIM: %d \n", threadIdx.x,blockIdx.x,start,end,gridDim.x);
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
          int child_start = ((block_index*4)+child)*16;
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

    int max_level = 7;
	
    if(level == max_level)
    {
        int i=blockIdx.x;
		    //printf("Terminal......... level %d n %d rv %d threadId %d\n",level,n,rv[i],i);
    		if(i==0){
    			printf("Terminal State..");
    		}
        if(i<n){
            rv[i]=0;
            int index_i = i*16;
            int max_tile=0;
            int penalty = 0;
            int free_tiles=0;
            for(int j=0;j<4;j++){
                int index_j = j*4;
                for(int k=0;k<4;k++){
                    rv[i]+=(powf(2,matrix[index_i+index_j+k])*(6-(j+k)));
                    
                    /*if(max_tile < matrix[index_i+index_j+k]){
                        max_tile=matrix[index_i+index_j+k];
                    }*/
                    
                    if (j - 1 >= 0) {
                        penalty += powf(2, abs(matrix[index_i+index_j+k] - matrix[index_i+index_j+k-4]));
                    }
                    if (j + 1 <= 3) {
                        penalty += powf(2, abs(matrix[index_i+index_j+k] - matrix[index_i+index_j+k+4]));
                    }
                    if (k - 1 >= 0) {
                        penalty += powf(2, abs(matrix[index_i+index_j+k] - matrix[index_i+index_j+k-1]));
                    }
                    if (k + 1 <= 3) {
                        penalty += powf(2, abs(matrix[index_i+index_j+k] - matrix[index_i+index_j+k+1]));
                    }
                    
                    if(matrix[index_i+index_j+k]==0){
                        free_tiles++;
                    }
                }
            }
            /*if(max_tile==matrix[index_i]){
                rv[i]+=1000;
            }*/
            rv[i]-=penalty;
            rv[i]+=(free_tiles*100);
        }
    }

    else if(type == 1)//Error in move left or right.. needs to be discovered..
    {
        //LRUD configuration
        printf("Directions......... level %d n %d \n",level,n);
        int* child_matrix = (int *)malloc(n*4*16*sizeof(int));
        int* child_rv = (int *)malloc(n*4*sizeof(int));
    		if(child_matrix==NULL || child_rv==NULL){
    			printf("No enough memory to allocate for matrix.. %x %x\n",child_matrix,child_rv);
          free(child_matrix);
          free(child_rv);
    			runExpectiMaxSearch<<<n,1>>>(matrix,n,type+1,max_level,rv);
    			cudaDeviceSynchronize();
    			return;
    		}
        generate_copy_for_child_type1<<<n,16>>>((int *)matrix,child_matrix,child_rv,n);
        cudaDeviceSynchronize();
		
		    printf("n= %d \n",n);

        cudaStream_t left;
        cudaStreamCreateWithFlags(&left, cudaStreamNonBlocking);
        moveLeft<<<n,4,0,left>>>(child_matrix);//should always be called with 4 threads, each for a row and a block for a matrix
		
        cudaStream_t right;
        cudaStreamCreateWithFlags(&right, cudaStreamNonBlocking);
        moveRight<<<n,4,0,right>>>(child_matrix);
        
        cudaStream_t up;
        cudaStreamCreateWithFlags(&up, cudaStreamNonBlocking);
        moveUp<<<n,4,0,up>>>(child_matrix);
        
        cudaStream_t down;
        cudaStreamCreateWithFlags(&down, cudaStreamNonBlocking);
        moveDown<<<n,4,0,down>>>(child_matrix);
        cudaDeviceSynchronize();

    		if(level!=max_level-1){
    			runExpectiMaxSearch<<<1,1>>>(child_matrix,4*n,type+1,level+1,child_rv);
    		}
    		else{
    			runExpectiMaxSearch<<<4*n,1>>>(child_matrix,4*n,type+1,level+1,child_rv);
    		}
    		cudaDeviceSynchronize();
        consolidate_return_values<<<n,1>>>(child_rv,rv,n);
        cudaDeviceSynchronize();
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
        printf("Chances.........level %d n %d \n",level,n);
        int count = 0;
    		int *n_count;
    		n_count = (int *)malloc(sizeof(int)*n);
        int *temp;
        temp = (int *)malloc(sizeof(int)*n);
    		if(n_count==NULL || temp==NULL){
          free(n_count);
          free(temp);
          printf("No enough memory to allocate for chance nodes.. \n");
          runExpectiMaxSearch<<<n,1>>>(matrix,n,type+1,max_level,rv);
          cudaDeviceSynchronize();
          return;
    		}

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
    		if(matrix1==NULL || rv1==NULL){
         free(matrix1);
         free(rv1);
    			printf("No enough memory to allocate for chance nodes @.. \n");
    			runExpectiMaxSearch<<<n,1>>>(matrix,n,type+1,max_level,rv);
    			cudaDeviceSynchronize();
    			return;
    		}

        for (int i = 0; i < count; i++) rv1[i] = 0;

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
                            flag=1;
                        } else {
                            matrix1[index_i+index_j+k] = matrix[index_l+index_j+k];
                            if(matrix[index_l+index_j+k] == -1){
                                matrix1[index_i+index_j+k] = 0;
                            }
                        }

                    }
                }

            }

        }

    free(n_count);
		if(level!=max_level-1){
			runExpectiMaxSearch<<<1,1>>>(matrix1, count, type-1, level + 1, rv1);
		}
		else{
			runExpectiMaxSearch<<<count,1>>>(matrix1, count, type-1, level + 1, rv1);
		}

		cudaDeviceSynchronize();
		int p;
		k=p=0;
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
		free(rv1);
    }

}

int placerandomtile(int* matrix){
    int place=0;
    int random_pos[16];
    for(int i=0;i<4;i++){
        int index_i=i*4;
        for(int j=0;j<4;j++){
            if(matrix[index_i+j]==0){
                random_pos[place]=i*4+j;
                place++;
            }
        }
    }
    if(place==0){
        return 1;
    }
    int random = rand()%place;
    place = random_pos[random];
    int x = place/4;
    int y = place%4;
    //int tiles[10] = {1,1,1,1,1,1,1,1,2,2};
    random = rand()%10;
    matrix[4*x+y]=1;//tiles[random];
    return 0;
}

int main() {

    int* matrix = (int *)malloc(sizeof(int)*16);
  	int* d_matrix;
      int* rv = (int *)malloc(sizeof(int));
  	int *d_rv;
  
  	int matrix_size = sizeof(int)*16;
  	int rv_size = sizeof(int)*1;
	
    rv[0]=0;

    matrix[0] = 0;
    matrix[1] = 0;
    matrix[2] = 2;
    matrix[3] = 1;

    matrix[4] = 0;
    matrix[5] = 0;
    matrix[6] = 0;
    matrix[7] = 0;

    matrix[8] = 0;
    matrix[9] = 0;
    matrix[10] = 0;
    matrix[11] = 0;

    matrix[12] = 0;
    matrix[13] = 0;
    matrix[14] = 0;
    matrix[15] = 0;
	
    cout<<"Boooooom"<<endl;
    
    cudaMalloc(&d_matrix,matrix_size);
 	  cudaMalloc(&d_rv,rv_size);
    
    int times=1000;
    while(times--) {

        cout<<times<<endl;
        drawMatrix(matrix);

        cudaMemcpy(d_matrix,matrix,matrix_size,cudaMemcpyHostToDevice);
      	cudaMemcpy(d_rv,rv,rv_size,cudaMemcpyHostToDevice);
      	
      	cudaDeviceSetLimit(cudaLimitDevRuntimeSyncDepth, 8);
      	runExpectiMaxSearch<<<1,1>>>(d_matrix,1,1,0,d_rv);
      	
      	cudaDeviceSynchronize();
      	cudaError_t err;
      	err = cudaGetLastError();
      	if(err!=cudaSuccess){
      		printf("Error %s \n",cudaGetErrorString(err));
         exit(1);
      	}
      	//cudaMemcpy(matrix,d_matrix,matrix_size,cudaMemcpyDeviceToHost);
      	cudaMemcpy(rv,d_rv,rv_size,cudaMemcpyDeviceToHost);
      	cudaDeviceSynchronize();

        printf("%d ",rv[0]);
        if (rv[0] == 0) {
            cout << "Left" << endl;
            host_moveLeft(matrix);
            drawMatrix(matrix);
            cout << endl;

        }
        if (rv[0] == 1) {
            cout << "Right" << endl;
            host_moveRight(matrix);
            drawMatrix(matrix);
            cout << endl;
        }
        if (rv[0] == 2) {
            cout << "Up" << endl;
            host_moveUp(matrix);
            drawMatrix(matrix);
            cout << endl;
        }
        if (rv[0] == 3) {
            cout << "Down" << endl;
            host_moveDown(matrix);
            drawMatrix(matrix);
            cout << endl;
        }

        if(placerandomtile(matrix)==1)
            break;
    }

    cudaFree(d_matrix);
    cudaFree(d_rv);
    free(matrix);
    free(rv);
    return 0;
}
