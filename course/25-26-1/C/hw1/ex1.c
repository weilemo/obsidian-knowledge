#include <stdio.h>
#include <stdlib.h>
void quickSortUnique(int arr[], int left, int right);
void swap(int A[], int i, int j);
int duplicate_removal(int arr[], int size);

void swap(int A[], int i, int j)
{
    int temp = A[i];
    A[i] = A[j];
    A[j] = temp;
}
void quickSortUnique(int arr[], int left, int right)
{
    int i,j;
    int pivo = arr[ (left + right)/2 ];
    i = left; j = right;
    while (i <= j)
    {
        while (arr[i] < pivo) 
            i++;
        while (arr[j] > pivo) 
            j--;
        if (i <= j)
        {
            swap(arr, i, j);
            i++; j--;
        }
    }
    if (left < j) 
        quickSortUnique(arr, left, j);
    if (i < right) 
        quickSortUnique(arr, i, right);
}

int duplicate_removal(int arr[], int size)
{
    if (size == 0 || size == 1)
        return size;
    int j = 0;
    for (int i = 0; i < size - 1; i++)
    {
        if (arr[i] != arr[i + 1])
        {
            arr[j++] = arr[i];
        }
    }
    arr[j++] = arr[size - 1]; //应对最后一个元素
    for (int i = j; i < size; i++)
    {
        arr[i] = -1; //填补空缺的位置
    }
    return j; //返回新数组的大小
}


int main()
{
    int size0;
    int arr[]={5,2,8,2,9,1,5,5,8,3};
    printf("原数组: ");
    for(int i=0; i<10; i++)
        printf("%d ", arr[i]);
    printf("\n排序去重后 ");
    quickSortUnique(arr, 0, 9);
    size0 = duplicate_removal(arr, 10);
    for(int k=0; k< size0 ; k++)
        printf("%d ", arr[k]);
    printf("\n新数组大小: %d\n", size0);
    return 0;
}