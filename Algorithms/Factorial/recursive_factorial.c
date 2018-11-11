/*
 * * C Program to print factorial of a number 
 * * using recursion
 * */
#include <stdio.h>
#include <ncurses.h>
 
int getFactorial(int N);
int main(){
    int N, nFactorial, counter;
    printf("Enter a number \n");
    scanf("%d",&N);
 
    printf("Factorial of %d is %d", N, getFactorial(N));
     
    //getch();
    return 0;
}
 
/*
 *  * Recursive function to find factorial of a number
 *   */
int getFactorial(int N){
    /* Exit condition to break recursion */
    if(N <= 1){
         return 1;
    }
    /*  N! = N*(N-1)*(N-2)*(N-3)*.....*3*2*1  */ 
    return N * getFactorial(N - 1);
}
