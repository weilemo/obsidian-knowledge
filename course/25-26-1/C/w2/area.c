#include <stdio.h>

float area(int radius) {
    return 3.14 * radius * radius;
}

int main() {
    int r = 5;
    printf("Area of circle with radius %d is %.2f\n", r, area(r));
    return 0;
}