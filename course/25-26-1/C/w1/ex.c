#include <stdio.h>
#include <stdlib.h>

int main()
{
    printf("input foot and inch:\n");
    int foot, inch;
    scanf("%d %d", &foot, &inch);
    double meter = (foot + inch/12.0) * 0.3048;
    printf("meter: %.2f\n", meter);    
    return 0;
}