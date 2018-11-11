/*
 * * C Program to check given string is palindrome or not 
 * * using recursion
 * */
#include <stdio.h>
//#include <ncurses.h>
#include <string.h>
 
int isPalindrome(char *inputString, int leftIndex, int rightIndex);
 
int main(){
    char inputString[100];
    printf("Enter a string for palindrome check\n");
    scanf("%s", inputString);
         
    if(isPalindrome(inputString, 0, strlen(inputString) - 1)){
        printf("%s is a Palindrome \n", inputString);
    } else {
        printf("%s is not a Palindrome \n", inputString);
    }
     
    //getch();
    return 0;
}
 
/*
 *  * Function to check whether a string is palindrome or not
 *   */
 int isPalindrome(char *inputString, int leftIndex, int rightIndex){
     /* Input Validation */
     if(NULL == inputString || leftIndex < 0 || rightIndex < 0){
         printf("Invalid Input");
         return 0;
     }
     /* Recursion termination condition */
     if(leftIndex >= rightIndex)
         return 1;
     if(inputString[leftIndex] == inputString[rightIndex]){
         return isPalindrome(inputString, leftIndex + 1, rightIndex - 1);
     }
     return 0;
 }
