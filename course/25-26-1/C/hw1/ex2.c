#include <stdio.h>
#include <stdlib.h>

void spiralTraverse(int *matrix, int rows, int cols);

void spiralTraverse(int *matrix, int rows, int cols)
{
    int top = 0, bottom = rows - 1;
    int left = 0, right = cols - 1;

    while (top <= bottom && left <= right)
    {
        for (int i = left; i <= right; i++)
            printf("%d ", *(matrix + top * cols + i));
        top++;

        for (int i = top; i <= bottom; i++)
            printf("%d ", *(matrix + i * cols + right));
        right--;

        if (top <= bottom)
        {
            for (int i = right; i >= left; i--)
                printf("%d ", *(matrix + bottom * cols + i));
            bottom--;
        }

        if (left <= right)
        {
            for (int i = bottom; i >= top; i--)
                printf("%d ", *(matrix + i * cols + left));
            left++;
        }
    }
}
int main() {
    int matrix[4][4] = {
        {1, 2, 3, 4},
        {5, 6, 7, 8},
        {9, 10, 11, 12},
        {13, 14, 15, 16}
    };
    
    printf("矩阵：\n");
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            printf("%d\t", matrix[i][j]);
        }
        printf("\n");
    }
    
    printf("螺旋遍历：");
    spiralTraverse((int *)matrix, 4, 4);
}