#include <iostream>
#include<math.h>
#include<queue>

using namespace std;


void moveLeft(int** matrix)
{

    int mergeCount;
    int temp[4];

    for(int j=0;j<4;j++) {

        temp[0] = temp[1] = temp[2] = temp[3] = 0;

        while (1) {

            mergeCount = 0;

            for (int i = 1; i < 4; i++) {
                if (matrix[j][i] != 0 && matrix[j][i] == matrix[j][i - 1] && temp[i - 1] != 1 && temp[i] != 1) {
                    matrix[j][i - 1] = 1 + matrix[j][i];
                    matrix[j][i] = 0;
                    temp[i - 1] = 1;
                    mergeCount++;
                } else if (matrix[j][i] != 0 && matrix[j][i - 1] == 0) {
                    matrix[j][i - 1] = matrix[j][i];
                    matrix[j][i] = 0;
                    mergeCount++;
                }
            }

            if (mergeCount == 0) break;

        }
    }

}


void moveRight(int** matrix)
{

    int mergeCount;
    int temp[4];

    for(int j=0;j<4;j++) {

        temp[0] = temp[1] = temp[2] = temp[3] = 0;

        while (1) {

            mergeCount = 0;

            for (int i = 2; i >= 0; i--) {
                if (matrix[j][i] != 0 && matrix[j][i] == matrix[j][i + 1] && temp[i + 1] != 1 && temp[i] != 1) {
                    matrix[j][i + 1] = 1 + matrix[j][i];
                    matrix[j][i] = 0;
                    temp[i + 1] = 1;
                    mergeCount++;
                } else if (matrix[j][i] != 0 && matrix[j][i + 1] == 0) {
                    matrix[j][i + 1] = matrix[j][i];
                    matrix[j][i] = 0;
                    mergeCount++;
                }
            }

            if (mergeCount == 0) break;

        }
    }

}


void moveUp(int** matrix)
{

    int mergeCount;
    int temp[4];

    for(int j=0;j<4;j++) {

        temp[0] = temp[1] = temp[2] = temp[3] = 0;

        while (1) {

            mergeCount = 0;

            for (int i = 1; i < 4; i++) {
                if (matrix[i][j] != 0 && matrix[i][j] == matrix[i - 1][j] && temp[i - 1] != 1 && temp[i] != 1) {
                    matrix[i - 1][j] = matrix[i][j] + 1;
                    matrix[i][j] = 0;
                    temp[i - 1] = 1;
                    mergeCount++;
                } else if (matrix[i][j] != 0 && matrix[i - 1][j] == 0) {
                    matrix[i - 1][j] = matrix[i][j];
                    matrix[i][j] = 0;
                    mergeCount++;
                }
//               mergeCount--;
            }

            if (mergeCount == 0) break;

        }
    }
}


void moveDown(int** matrix)
{

    int mergeCount;
    int temp[4];

    for(int j=0;j<4;j++) {

        temp[0] = temp[1] = temp[2] = temp[3] = 0;

        while (1) {

            mergeCount = 0;

            for (int i = 2; i >= 0 ; i--) {
                if (matrix[i][j] != 0 && matrix[i][j] == matrix[i + 1][j] && temp[i + 1] != 1 && temp[i] != 1) {
                    matrix[i + 1][j] = matrix[i][j] + 1;
                    matrix[i][j] = 0;
                    temp[i + 1] = 1;
                    mergeCount++;
                } else if (matrix[i][j] != 0 && matrix[i + 1][j] == 0) {
                    matrix[i + 1][j] = matrix[i][j];
                    matrix[i][j] = 0;
                    mergeCount++;
                }
//               mergeCount--;
            }

            if (mergeCount == 0) break;

        }
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

void runExpectiMaxSearch(int*** matrix,int n,int type,int level,int* rv)
{


    if(level == 10)
    {
        //terminal state
        cout<<"Terminal........."<<endl;
        for(int i=0;i<n;i++)
            for(int j=0;j<4;j++)
                for(int k=0;k<4;k++)
                    rv[i]+=matrix[i][j][k];

    }

    else if(type == 1)
    {
        //LRUD configuration
        cout<<"Directions........."<<endl;
        int*** matrix1 = new int**[n*4];
        int* rv1 = new int[n*4];

        for(int i=0;i<4*n;i++) rv1[i]=0;

        for(int i=0;i<4*n;i+=4)
        {

            matrix1[i] = new int*[4];

            for (int j=0;j<4;j++)
            {
                matrix1[i][j] = new int[4];

                for(int k=0;k<4;k++)
                {
                    matrix1[i][j][k] = matrix[i/4][j][k];
                    matrix1[i+1][j][k] = matrix[i/4][j][k];
                    matrix1[i+2][j][k] = matrix[i/4][j][k];
                    matrix1[i+3][j][k] = matrix[i/4][j][k];
                }
            }

            moveLeft(matrix1[i]);
            moveRight(matrix1[i+1]);
            moveUp(matrix1[i+2]);
            moveDown(matrix1[i+3]);

        }

        runExpectiMaxSearch(matrix1,4*n,2,level+1,rv1);


        for(int i=0;i<n;i+=4)
        {
            rv[i/4] = max(max(rv1[i],rv1[i+1]),max(rv1[i+2],rv1[i+3]));
        }
        if(level==0){
            if(rv1[0]>rv[1]){
                if(rv1[0]>rv1[2]){
                    if(rv1[0]>rv1[3]){
                        rv[0]=0;
                    }
                    else{
                        rv[0]=3;
                    }
                }
                else{
                    if(rv1[2]>rv1[3]){
                        rv[0]=2;
                    }
                    else{
                        rv[0]=3;
                    }
                }
            }
            else{
                if(rv1[1]>rv1[2]){
                    if(rv1[1]>rv1[3]){
                        rv[0]=1;
                    }
                    else{
                        rv[0]=3;
                    }
                }
                else{
                    if(rv1[2]>rv1[3]){
                        rv[0]=2;
                    }
                    else{
                        rv[0]=3;
                    }
                }
            }
        }

    }
    else {
        cout<<"Chances........."<<endl;
        int count = 0;
        int temp[n];

        for (int i = 0; i < n; i++) {
            for (int j = 0; j < 4; j++) {
                for (int k = 0; k < 4; k++) {
                    if (matrix[i][j][k] == 0)
                        count++;

                }
            }

            if (i == 0)
                temp[0] = count;
            else
                temp[i] = count - temp[i - 1];

        }

        int ***matrix1 = new int **[count];

        int *rv1 = new int[count];

        for (int i = 0; i < count; i++) rv1[i] = 0;


        int i = 0, k = 0;

        for (int l = 0; l < n; l++) {
            for (int i = 0; i < temp[l]; i++) {
                int index = i;
                if (l != 0) {
                    index += temp[l - 1];
                }
                matrix1[index] = new int *[4];
                for (int j = 0; j < 4; j++) {

                    matrix1[index][j] = new int[4];

                    for (int k = 0; k < 4; k++) {

                        if (matrix[i][j][k] == 0) {
                            matrix1[index][j][k] = 1;
                            matrix[l][j][k] = -1;
                        } else {
                            matrix1[index][j][k] = matrix[l][j][k];
                        }

                    }
                }

            }

        }


//        for(int i=0;i<n;i++) {
//
//            matrix1[i] = new int*[4];
//
//
//            for (int j=0;j<4;j++)
//            {
//                matrix1[i][j] = new int[4];
//
//                for(int k=0;k<4;k++)
//                {
//
//                    matrix1[i][j][k] = ( setSoFar==count && matrix[i][j][k] == 0) ? 1 : matrix[i][j][k];
//
//                }
//            }
//
//        }


        runExpectiMaxSearch(matrix1, count, 1, level + 1, rv1);

        for (int l = 0; l < n; l++) {
            for (int i = 0; i < temp[l]; i++) {
                int index = i;
                if (l != 0) {
                    index += temp[l - 1];
                }
                rv[l] += rv1[index];

            }

            rv[l] /= temp[l];

        }
    }



}

int main() {

    int*** matrix = new int**[1];

    int* rv = new int[1];

    rv[0]=0;


    int level = 0;

    for(int i=0;i<1;i++)
    {
        matrix[i] = new int*[4];

        for (int j=0;j<4;j++)
        {
            matrix[i][j] = new int[4];

            for(int k=0;k<4;k++)
            {
                matrix[i][j][k] = 1;
            }
        }
    }

    matrix[0][0][0] = 2;
    matrix[0][0][1] = 2;
    matrix[0][0][2] = 3;
    matrix[0][0][3] = 4;

    matrix[0][1][0] = 2;
    matrix[0][1][1] = 2;
    matrix[0][1][2] = 0;
    matrix[0][1][3] = 0;

    matrix[0][2][0] = 2;
    matrix[0][2][1] = 0;
    matrix[0][2][2] = 0;
    matrix[0][2][3] = 0;

    matrix[0][3][0] = 3;
    matrix[0][3][1] = 4;
    matrix[0][3][2] = 4;
    matrix[0][3][3] = 5;
    
    cout<<"Boooooom"<<endl;
    runExpectiMaxSearch(matrix,1,1,0,rv);
    
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
