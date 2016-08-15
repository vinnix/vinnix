#include <stdio.h>
int main()
{
    int n, reversedInteger = 0, remainder, originalInteger;

    printf("Enter an integer: ");
    scanf("%d", &n);

    originalInteger = n;

    // reversed integer is stored in variable 
    while( n!=0 )
    {
        remainder = n%10;
        reversedInteger = reversedInteger*10 + remainder;
        n /= 10;
        printf("[n] %d \n", n);
        printf("[reversedInteger] %d \n", reversedInteger);
        printf("[remainder] %d \n", remainder);
	printf("--------------------------------------------------------\n");
    }

    // palindrome if orignalInteger and reversedInteger is equal
    if(originalInteger == reversedInteger)
        printf("%d is a palindrome.\n", originalInteger);
    else
        printf("%d is not a palindrome.\n", originalInteger);
    
    return 0;
}
