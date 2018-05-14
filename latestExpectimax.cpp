#include <iostream>
#include<math.h>
#include<random>

using namespace std;

string reset = "\u001b[0m";

unsigned GetNumberOfDigits (uint64_t i);

void printMatrix(int** matrix)
{
    for(int i=0;i<4;i++) {
        for (int j = 0; j < 4; j++) {

            if(matrix[i][j]!=0)
                cout<<pow(2,matrix[i][j])<<" ";
            else
                cout<<0<<" ";

        }
        cout<<endl;
    }
}

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

string padNumber(int digits,uint64_t n,int empty)
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


unsigned GetNumberOfDigits (uint64_t i)
{
    return i > 0 ? (int) log10 ((double) i) + 1 : 1;
}


void drawMatrix(int** matrix)
{

    int pad = 1;

    for(int i=0;i<4;i++)
        for(int j=0;j<4;j++)
            pad = max(pad,matrix[i][j]);
    uint64_t  val = pow(2,pad);

    int digits = GetNumberOfDigits(val);
    digits = digits%2==0?digits+1:digits;

    for(int i=0;i<4;i++)
    {
        for(int j=0;j<4;j++)
        {
            printf("%s%s%s",getColor(matrix[i][j]).c_str(),padNumber(digits,pow(2,matrix[i][j]),0).c_str(),reset.c_str());
        }
        printf("\n");
        for(int j=0;j<4;j++)
        {
            printf("%s%s%s",getColor(matrix[i][j]).c_str(),padNumber(digits,pow(2,matrix[i][j]),1).c_str(),reset.c_str());
        }
        printf("\n");
        for(int j=0;j<4;j++)
        {
            printf("%s%s%s",getColor(matrix[i][j]).c_str(),padNumber(digits,pow(2,matrix[i][j]),0).c_str(),reset.c_str());
        }
        printf("\n");
    }

}

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




void rotatematrix(int **matrix) {
    uint8_t i,j,n=4;
    uint8_t tmp;
    for (i=0; i<n/2; i++) {
        for (j=i; j<n-i-1; j++) {
            tmp = matrix[i][j];
            matrix[i][j] = matrix[j][n-i-1];
            matrix[j][n-i-1] = matrix[n-i-1][n-j-1];
            matrix[n-i-1][n-j-1] = matrix[n-j-1][i];
            matrix[n-j-1][i] = tmp;
        }
    }
}

int heur_score_value(int** matrix)
{
    int heur_score=0;

    for (int j = 0; j < 4; j++) {

        int maxi = 0;

        for (int k = 1; k < 4; ++k) {
            if (matrix[j][k] > matrix[j][maxi]) maxi = k;
        }

        if (maxi == 0 || maxi == 3) heur_score += 20000.0f;

        // Check if maxi's are close to each other, and of diff ranks (eg 128 256)
        for (int k = 1; k < 4; ++k) {
            if ((matrix[j][k] == matrix[j][k - 1] + 1) || (matrix[j][k] == matrix[j][k - 1] - 1)) heur_score += 1000.0f;
        }

        // Check if the values are ordered:
        if ((matrix[j][0] < matrix[j][1]) && (matrix[j][1] < matrix[j][2]) && (matrix[j][2] < matrix[j][3])) heur_score += 10000.0f;

        if ((matrix[j][0] > matrix[j][1]) && (matrix[j][1] > matrix[j][2]) && (matrix[j][2] > matrix[j][3])) heur_score += 10000.0f;


    }

    rotatematrix(matrix);

    for (int j = 0; j < 4; j++) {

        int maxi = 0;

        for (int k = 1; k < 4; ++k) {
            if (matrix[j][k] > matrix[j][maxi]) maxi = k;
        }

        if (maxi == 0 || maxi == 3) heur_score += 2000.0f;

        // Check if maxi's are close to each other, and of diff ranks (eg 128 256)
        for (int k = 1; k < 4; ++k) {
            if ((matrix[j][k] == matrix[j][k - 1] + 1) || (matrix[j][k] == matrix[j][k - 1] - 1)) heur_score += 1000.0f;
        }

        // Check if the values are ordered:
        if ((matrix[j][0] < matrix[j][1]) && (matrix[j][1] < matrix[j][2]) && (matrix[j][2] < matrix[j][3])) heur_score += 1000.0f;
        if ((matrix[j][0] > matrix[j][1]) && (matrix[j][1] > matrix[j][2]) && (matrix[j][2] > matrix[j][3])) heur_score += 1000.0f;


    }

    rotatematrix(matrix);
    rotatematrix(matrix);
    rotatematrix(matrix);

    return heur_score+100000;

}

void runExpectiMaxSearch(int*** matrix,int n,int type,int level,int* rv)
{

    //cout<<n<<" "<<level<<" <- n and level"<<endl;
    if(level == 6) {
        //terminal state
        //cout<<"Terminal........."<<endl;

       // cout<<"Terminal........."<<endl;

        for (int i = 0; i < n; i++) {

            //rv[i] = heur_score_value(matrix[i]);
            int penalty = 0;
            int free_tiles=0;
            int max_val=0;
            for (int j = 0; j < 4; j++) {
                for (int k = 0; k < 4; k++) {
                    if(matrix[i][j][k]!=0) {
                        if (j - 1 >= 0) {
                            penalty += pow(2, abs(matrix[i][j][k] - matrix[i][j - 1][k]));
                        }
                        if (j + 1 <= 3) {
                            penalty += pow(2, abs(matrix[i][j][k] - matrix[i][j + 1][k]));
                        }
                        if (k - 1 >= 0) {
                            penalty += pow(2, abs(matrix[i][j][k] - matrix[i][j][k - 1]));
                        }
                        if (k + 1 <= 3) {
                            penalty += pow(2, abs(matrix[i][j][k] - matrix[i][j][k + 1]));
                        }
                        rv[i] += pow(2, matrix[i][j][k]) * (8 - (k + j));
                    }
                    if(matrix[i][j][k]==0){
                        free_tiles++;
                    }
                    max_val = max(max_val,matrix[i][j][k]);
                }

            }


//
//            if(pow(2,matrix[i][0][0])==max_val)
//
//                rv[i]+=pow(2,matrix[i][0][0]);

            rv[i]-=penalty;
            rv[i]+=(free_tiles*256);


        }
        cout<<"Terminal........."<<endl;

    }

    else if(type == 1)
    {
        //LRUD configuration
        //cout<<"Directions........."<<endl;
        int*** matrix1 = new int**[n*4];
        int* rv1 = new int[n*4];

        for(int i=0;i<4*n;i++) rv1[i]=0;

        for(int i=0;i<4*n;i+=4)
        {

            matrix1[i] = new int*[4];
            matrix1[i+1] = new int*[4];
            matrix1[i+2] = new int*[4];
            matrix1[i+3] = new int*[4];

            for (int j=0;j<4;j++)
            {
                matrix1[i][j] = new int[4];
                matrix1[i+1][j] = new int[4];
                matrix1[i+2][j] = new int[4];
                matrix1[i+3][j] = new int[4];

                for(int k=0;k<4;k++)
                {
                    matrix1[i][j][k] = matrix[i/4][j][k];
                    matrix1[i+1][j][k] = matrix[i/4][j][k];
                    matrix1[i+2][j][k] = matrix[i/4][j][k];
                    matrix1[i+3][j][k] = matrix[i/4][j][k];
                }
            }

            //cout<<"Boom"<<endl;
            moveLeft(matrix1[i]);
            moveRight(matrix1[i+1]);
            moveUp(matrix1[i+2]);
            moveDown(matrix1[i+3]);

        }

        runExpectiMaxSearch(matrix1,4*n,2,level+1,rv1);


        for(int i=0;i<4*n;i+=4)
        {
            rv[i/4] = max(max(rv1[i],rv1[i+1]),max(rv1[i+2],rv1[i+3]));
        }
        //cout<<level<<"........."<<endl;
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
        //cout<<"Chances........."<<endl;
        int n_count[n];
        int count=0;
        int temp[n];

        for (int i = 0; i < n; i++) {
            int num=0;
            temp[i]=0;
            n_count[i]=0;
            for (int j = 0; j < 4; j++) {
                for (int k = 0; k < 4; k++) {
                    if (matrix[i][j][k] == 0) {
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


        //cout<<count<<"count"<<endl;
        int ***matrix1 = new int **[count];

        int *rv1 = new int[count];

        for (int i = 0; i < count; i++) rv1[i] = 0;


        int i = 0, k = 0;

        for (int l = 0; l < n; l++) {
            int flag=0;
            for (int i = 0; i < temp[l]; i++) {
                int index = i;
                if (l != 0) {
                    index += n_count[l - 1];
                }
                //cout<<index<<" "<<endl;
                matrix1[index] = new int *[4];
                if(matrix1[index]==NULL){
                    cout<<"Memory Allocation Failure"<<endl;
                }
                flag=0;
                for (int j = 0; j < 4; j++) {

                    matrix1[index][j] = new int[4];

                    for (int k = 0; k < 4; k++) {

                        if (matrix[l][j][k] == 0 and flag==0) {
                            matrix1[index][j][k] = 1;
                            matrix[l][j][k] = -1;
                            flag=1;
                        } else {
                            matrix1[index][j][k] = matrix[l][j][k];
                            if(matrix[l][j][k] == -1){
                                matrix1[index][j][k] = 0;
                            }
                        }

                    }

                }
                //printMatrix(matrix1[index]);
                //cout<<" "<<endl;
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

//        for(int i=0;i<count;i++)
//            for(int j=0;j<4;j++)
//                for(int k=0;k<4;k++)
//                    printMatrix(matrix1[i]);
//
//        exit(1);


        runExpectiMaxSearch(matrix1, count, 1, level + 1, rv1);

        //cout<<level<<"dfg........."<<endl;

//        for (int l = 0; l < n; l++) {
//            for (int i = 0; i < temp[l]; i++) {
//                int index = i;
//                cout<<i<<" "<<l<<endl;
//                if (l != 0) {
//                    index += temp[l - 1];
//                }
//                rv[l] += rv1[index];
//
//            }
//
//            rv[l] /= temp[l];
//
//        }
        int l,p;
        l=k=p=0;


        for(l=0;l<n;l++)
        {
            int q=temp[l];
            if(q==0){
                rv[k]=0;
                k++;
                continue;
            }
            while(q--)
            {
                rv[k]+=rv1[p++];
            }
            rv[k]/=temp[l];
            //cout<<rv[k]<<" ";
            k++;
        }


        //cout<<level<<"asgnh........."<<endl;
    }



}

int placerandomtile(int** matrix){


    std::random_device rd;
    std::mt19937 mt(rd());


    int place=0;
    int random_pos[16];
    for(int i=0;i<4;i++){
        for(int j=0;j<4;j++){
            if(matrix[i][j]==0){
                random_pos[place]=i*4+j;
                place++;
            }
        }
    }

    std::uniform_real_distribution<double> dist(0.0, place);

    if(place==0){
        return 1;
    }
    int random = ((int)dist(mt))%place;
    place = random_pos[random];
    int x = place/4;
    int y = place%4;
    int tiles[10] = {1,1,1,1,1,1,1,1,2,2};
    //random = distribution(generator)%10;
    matrix[x][y]=1;//tiles[random];
    return 0;
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

    matrix[0][0][0] = 10;
    matrix[0][0][1] = 10;
    matrix[0][0][2] = 10;
    matrix[0][0][3] = 0;

    matrix[0][1][0] = 10;
    matrix[0][1][1] = 10;
    matrix[0][1][2] = 10;
    matrix[0][1][3] = 10;

    matrix[0][2][0] = 10;
    matrix[0][2][1] = 10;
    matrix[0][2][2] = 10;
    matrix[0][2][3] = 10;

    matrix[0][3][0] = 10;
    matrix[0][3][1] = 10;
    matrix[0][3][2] = 10;
    matrix[0][3][3] = 10;


//    drawMatrix(matrix[0]);
//
//    exit(1);

    //cout<<"Boooooom"<<endl;
    cout<<endl;

    int times=2000;
    while(times--) {

        cout<<times<<endl;
        drawMatrix(matrix[0]);

        runExpectiMaxSearch(matrix, 1, 1, 0, rv);

        if (rv[0] == 0) {
            cout << "Left" << endl;
            moveLeft(matrix[0]);
            drawMatrix(matrix[0]);
            cout << endl;

        }
        if (rv[0] == 1) {
            cout << "Right" << endl;
            moveRight(matrix[0]);
            drawMatrix(matrix[0]);
            cout << endl;
        }
        if (rv[0] == 2) {
            cout << "Up" << endl;
            moveUp(matrix[0]);
            drawMatrix(matrix[0]);
            cout << endl;
        }
        if (rv[0] == 3) {
            cout << "Down" << endl;
            moveDown(matrix[0]);
            drawMatrix(matrix[0]);
            cout << endl;
        }

        if(placerandomtile(matrix[0])==1)
            break;
    }

    return 0;
}
