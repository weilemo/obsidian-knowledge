#include <stdio.h>
#define PI 3.14159
// 外部函数声明 / External function declaration
double calculate_area(double radius);
int main() {
double r = 5.0;
printf("Area of circle with radius %.2f: %.2f\n", r, calculate_area(r));
return 0;
}
double calculate_area(double radius) {
return PI * radius * radius;
}