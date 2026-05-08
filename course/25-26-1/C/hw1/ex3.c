#include <stdio.h>

int reverseNumberRecursive(int num, int* power);
int reverseNumber(int num);

int reverseNumberRecursive(int num, int* power)
{
    if (num < 0)
    {
        return -reverseNumberRecursive(-num, power);
    }
    if (num < 10)
    {
        return num;
    }
    int digit = num % 10;
    int reversed = reverseNumberRecursive(num / 10, power);
    *power *= 10;
    int result = digit * (*power) + reversed;
    return result;
}


//用来包装函数
int reverseNumber(int num)
{
    int power = 1;
    return reverseNumberRecursive(num, &power);
}

int main() 
{
    printf("12345 -> %d\n", reverseNumber(12345));
    printf("-6789 -> %d\n", reverseNumber(-6789));
    printf("1200 -> %d\n", reverseNumber(1200));
    printf("5 -> %d\n", reverseNumber(5));
    printf("100 -> %d\n", reverseNumber(100));
    
    return 0;
}
   