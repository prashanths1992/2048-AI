#include <stdio.h>
#include <string>
#include<map>
#include <math.h>
#include<iostream>
#include <algorithm>

using namespace std;

int matrix[4][4] = {0};

string reset = "\u001b[0m";

unsigned GetNumberOfDigits (uint64_t i);

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


void drawMatrix()
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

void moveLeft()
{

    int mergeCount;
    int temp[4];

//    int j = ThreadID;   

    temp[0] = temp[1] = temp[2] = temp[3] = 0;

    while (1) 
    {

        mergeCount = 0;
        
        for (int i = 1; i < 4; i++) 
        {
            if (matrix[j][i] != 0&&matrix[j][i] == matrix[j][i - 1] && temp[i-1]!=1 && temp[i]!=1) 
            {
                matrix[j][i-1] = 1+matrix[j][i];
                matrix[j][i]=0;
                temp[i-1] = 1;
                mergeCount++;
            } 
            else if (matrix[j][i] != 0 && matrix[j][i - 1] == 0) 
            {
                matrix[j][i - 1] = matrix[j][i];
                matrix[j][i] = 0;
                mergeCount++;
            }
        }

        if (mergeCount == 0) break;

    }
    
}

void rotatematrix() {
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


void moveUp()
{

    int mergeCount;
    int temp[4];

//    for(int j=0;j<4;j++) {

    temp[0] = temp[1] = temp[2] = temp[3] = 0;

    while (1) {
        
        mergeCount = 0;
        
        for (int i = 1; i < 4; i++) {
            if (matrix[i][j] != 0&&matrix[i][j] == matrix[i - 1][j] && temp[i-1]!=1&&temp[i]!=1) {
                matrix[i-1][j] = matrix[i][j]+1;
                matrix[i][j]=0;
                temp[i-1] = 1;
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
//    }
}


void printM()
{

    for(int i=0;i<4;i++)
    {
        for(int j=0;j<4;j++)
        {
            printf("%d",matrix[i][j]);
        }
        printf("\n");
    }

}

void moveDown()
{
    rotatematrix();
    rotatematrix();
    moveUp();
    rotatematrix();
    rotatematrix();
}

void moveRight()
{
    rotatematrix();
    rotatematrix();
//    drawMatrix();
    moveLeft();
//    drawMatrix();
    rotatematrix();
    rotatematrix();
}
 
int main()
{
    int k=1;

    matrix[0][0] = 2;
    matrix[0][1] = 2;
    matrix[0][2] = 3;
    matrix[0][3] = 4;

    matrix[1][0] = 2;
    matrix[1][1] = 2;
    matrix[1][2] = 0;
    matrix[1][3] = 0;

    matrix[2][0] = 2;
    matrix[2][1] = 0;
    matrix[2][2] = 0;
    matrix[2][3] = 0;

    matrix[3][0] = 3;
    matrix[3][1] = 4;
    matrix[3][2] = 4;
    matrix[3][3] = 5;




    moveLeft();
//    //printM();

    drawMatrix();

    printf("\n");

//
    moveDown();
//
    drawMatrix();



}
