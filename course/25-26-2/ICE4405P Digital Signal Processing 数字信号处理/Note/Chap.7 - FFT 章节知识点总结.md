# Chap.7 Fast Fourier Transform (FFT) 章节知识点总结（按 PPT 章节顺序重写）

> 课程：ICE4405P Digital Signal Processing  
> 讲义：`PPT/Chap.7-FFT.pdf`（40 页）  
> 目录顺序：`7.1 -> 7.2 -> 7.3 -> 7.4 -> 7.5 -> 7.6`

---

## 0. 本章主线（先抓核心）

本章的核心目标：把 DFT 从 $O(N^2)$ 降到 $O(N\log_2N)$。

关键思想是“分治 + 蝶形复用”：

1. DIT：按时间索引奇偶拆分输入。  
2. DIF：按频率索引奇偶拆分输出。  
3. 两者都在 $N=2^\gamma$ 时递归 $\log_2N$ 层，最终化成 2 点 DFT。  
4. 通过 bit-reversal 与 in-place 实现进一步节省存储与搬移开销。  

---

## 1. 7.1 DFT 回顾与直接实现代价

## 1.1 DFT 定义

$$
X[k]=\sum_{n=0}^{N-1}x[n]e^{-j\frac{2\pi}{N}kn},\quad k=0,1,\dots,N-1
$$

记

$$
W_N=e^{-j\frac{2\pi}{N}}
$$

则

$$
X[k]=\sum_{n=0}^{N-1}x[n]W_N^{kn}
$$

矩阵形式：

$$
\mathbf{X}=\mathbf{W}\mathbf{x}
$$

## 1.2 运算量（直接法）

- 复乘次数：

$$
(N-1)^2\approx N^2
$$

- 复加次数：

$$
N(N-1)\approx N^2
$$

所以直接法复杂度是 $O(N^2)$，中等长度就很慢。

---

## 2. 7.2 DIT-FFT（Decimation in Time）

## 2.1 奇偶抽取推导

把输入分成偶样本与奇样本：

$$
g[r]=x[2r],\quad h[r]=x[2r+1],\quad r=0,1,\dots,\frac{N}{2}-1
$$

代入 DFT：

$$
X[k]=\sum_{r=0}^{N/2-1}g[r]W_N^{(2r)k}+W_N^k\sum_{r=0}^{N/2-1}h[r]W_N^{(2r)k}
$$

利用

$$
W_N^{2rk}=W_{N/2}^{rk}
$$

得

$$
X[k]=G[k]+W_N^kH[k]
$$

其中 $G,H$ 是两个 $N/2$ 点 DFT。

## 2.2 周期性进一步化简

由于 $G[k],H[k]$ 都以 $N/2$ 为周期，且

$$
W_N^{k+N/2}=-W_N^k
$$

因此对 $k=0,1,\dots,\frac{N}{2}-1$：

$$
\begin{aligned}
X[k] &= G[k]+W_N^kH[k]\\
X\left[k+\frac{N}{2}\right] &= G[k]-W_N^kH[k]
\end{aligned}
$$

这就是 DIT 蝶形。

## 2.3 蝶形结构（本章最重要结构）

$$
\begin{cases}
\text{上支路输出} = A + W\,B\\
\text{下支路输出} = A - W\,B
\end{cases}
$$

其中 $W$ 即 twiddle factor（旋转因子）。

---

## 3. 7.3 复杂度、bit-reversal 与 in-place

## 3.1 递归复杂度

每层有 $N/2$ 个 twiddle 乘法，共 $\log_2N$ 层：

$$
\text{复乘} \sim \frac{N}{2}\log_2N
$$

复加同量级：

$$
\text{复加} \sim N\log_2N
$$

与直接法 $N^2$ 对比，节省巨大。

例如 $N=1024$：

$$
N^2=1,048,576,\quad N\log_2N=10,240
$$

数量级可降约两位。

## 3.2 bit-reversed 顺序

以 $N=8$ 为例，索引二进制反转：

$$
0(000)\to0(000),\ 1(001)\to4(100),\ 2(010)\to2(010),\dots
$$

DIT 常见特点：输入按 bit-reversed 排，输出自然顺序。

## 3.3 in-place 计算

第 $m$ 级蝶形可写：

$$
\begin{aligned}
X^{(m)}[p]&=X^{(m-1)}[p]+W_N^rX^{(m-1)}[q]\\
X^{(m)}[q]&=X^{(m-1)}[p]-W_N^rX^{(m-1)}[q]
\end{aligned}
$$

同一对输入仅服务当前蝶形，因此可直接覆盖写回，节省内存。

---

## 4. 7.4 DIF-FFT（Decimation in Frequency）

## 4.1 推导起点

从 DFT 按时间索引前后半段分裂：

$$
X[k]=\sum_{n=0}^{N/2-1}x[n]W_N^{kn}+\sum_{n=N/2}^{N-1}x[n]W_N^{kn}
$$

令 $r=n-N/2$，并用

$$
W_N^{kN/2}=(-1)^k
$$

得

$$
X[k]=\sum_{n=0}^{N/2-1}\left[x[n]+(-1)^kx\left[n+\frac{N}{2}\right]\right]W_N^{nk}
$$

## 4.2 偶频与奇频分离

- 偶频（$k=2r$）：

$$
X[2r]=\sum_{n=0}^{N/2-1}g[n]W_{N/2}^{nr},\quad g[n]=x[n]+x[n+N/2]
$$

- 奇频（$k=2r+1$）：

$$
X[2r+1]=\sum_{n=0}^{N/2-1}h[n]W_N^nW_{N/2}^{nr},\quad h[n]=x[n]-x[n+N/2]
$$

即两个 $N/2$ 点 DFT 生成偶频与奇频。

## 4.3 DIF 蝶形

$$
\begin{aligned}
\text{上支路} &= A+B\\
\text{下支路} &= (A-B)W
\end{aligned}
$$

和 DIT 区别：twiddle 乘法在“减法分支之后”。

## 4.4 DIF 与 DIT 对照

- DIT：输入 bit-reversed，输出自然序。  
- DIF：输入自然序，输出 bit-reversed。  
- 复杂度同阶，网络互为转置关系。

---

## 5. 7.5 用 FFT 计算 IDFT

IDFT：

$$
x[n]=\frac{1}{N}\sum_{k=0}^{N-1}X[k]W_N^{-kn}
$$

注意

$$
W_N^{-kn}=(W_N^{kn})^*
$$

可写成

$$
x[n]=\frac{1}{N}\left[\sum_{k=0}^{N-1}X^*[k]W_N^{kn}\right]^*
$$

因此

$$
\boxed{x[n]=\frac{1}{N}\left(\mathrm{DFT}\{X^*[k]\}[n]\right)^*}
$$

### 实用步骤

1. 对输入频谱取共轭 $X^*[k]$。  
2. 调一次普通 FFT。  
3. 输出再取共轭并乘 $1/N$。  

即同一 FFT 引擎即可计算 DFT 和 IDFT。

---

## 6. 7.6 FFT 应用：一次复 FFT 计算两个实序列 DFT

设两路实信号 $x_1[n],x_2[n]$，打包成

$$
x[n]=x_1[n]+j x_2[n]
$$

做一次 $N$ 点 FFT 得

$$
X[k]=X_1[k]+jX_2[k]
$$

利用共轭对称性质可分离出两路频谱：

$$
\boxed{X_1[k]=\frac{1}{2}\left(X[k]+X^*[N-k]\right)}
$$

$$
\boxed{X_2[k]=\frac{1}{2j}\left(X[k]-X^*[N-k]\right)}
$$

（索引按 mod-$N$ 解释。）

### 工程意义

两路实序列本来要两次 FFT，现在只需一次复 FFT + 少量后处理。

---

## 7. 本章速记（考试/实现高频结论）

1. 直接 DFT：

$$
X[k]=\sum_{n=0}^{N-1}x[n]W_N^{kn},\quad O(N^2)
$$

2. FFT（radix-2）：

$$
O(N\log_2N)
$$

3. DIT 蝶形：

$$
(A,B)\to(A+WB,\ A-WB)
$$

4. DIF 蝶形：

$$
(A,B)\to(A+B,\ (A-B)W)
$$

5. IDFT via FFT：

$$
x=\frac{1}{N}\big(\mathrm{FFT}(X^*)\big)^*
$$

6. 线性卷积配合 FFT 必须补零：

$$
N\ge L+P-1
$$

7. 两实序列一复 FFT 分离公式：

$$
X_1[k]=\frac{X[k]+X^*[N-k]}{2},\quad
X_2[k]=\frac{X[k]-X^*[N-k]}{2j}
$$

---

## 8. 与前后章节衔接

- 本章是 Chapter 6（DFT）的快速计算实现层。  
- 后续滤波、频谱估计、实时处理几乎都依赖 FFT。  
- 学习顺序建议：先熟 DIT/DIF 蝶形，再做 bit-reversal 和 in-place 编程实现。

