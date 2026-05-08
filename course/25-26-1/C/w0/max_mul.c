// 性能对比示例：矩阵乘法
// Performance comparison example: Matrix multiplication
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 5000  // 矩阵维度 / Matrix dimension

// 朴素矩阵乘法 / Naive matrix multiplication
void matrix_multiply_naive(double* A, double* B, double* C, int n) {
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            C[i*n + j] = 0.0;
            for(int k = 0; k < n; k++) {
                C[i*n + j] += A[i*n + k] * B[k*n + j];
            }
        }
    }
}

// 缓存优化版本（循环交换）/ Cache-optimized version (loop interchange)
void matrix_multiply_optimized(double* A, double* B, double* C, int n) {
    // 初始化C矩阵 / Initialize C matrix
    for(int i = 0; i < n*n; i++) C[i] = 0.0;
    
    // ikj顺序，提高缓存命中率 / ikj order for better cache hit rate
    for(int i = 0; i < n; i++) {
        for(int k = 0; k < n; k++) {
            double a_ik = A[i*n + k];
            for(int j = 0; j < n; j++) {
                C[i*n + j] += a_ik * B[k*n + j];
            }
        }
    }
}

int main() {
    // 分配内存 / Allocate memory
    double* A = (double*)malloc(N * N * sizeof(double));
    double* B = (double*)malloc(N * N * sizeof(double));
    double* C = (double*)malloc(N * N * sizeof(double));
    
    // 初始化矩阵 / Initialize matrices
    for(int i = 0; i < N*N; i++) {
        A[i] = (double)rand() / RAND_MAX;
        B[i] = (double)rand() / RAND_MAX;
    }
    
    clock_t start, end;
    
    // 测试朴素版本 / Test naive version
    start = clock();
    matrix_multiply_naive(A, B, C, N);
    end = clock();
    double time_naive = (double)(end - start) / CLOCKS_PER_SEC;
    printf("Naive version: %.3f seconds\n", time_naive);
    
    // 测试优化版本 / Test optimized version  
    start = clock();
    matrix_multiply_optimized(A, B, C, N);
    end = clock();
    double time_optimized = (double)(end - start) / CLOCKS_PER_SEC;
    printf("Optimized version: %.3f seconds\n", time_optimized);
    printf("Speedup: %.2fx\n", time_naive / time_optimized);
    
    // 释放内存 / Free memory
    free(A);
    free(B);
    free(C);
    
    return 0;
}