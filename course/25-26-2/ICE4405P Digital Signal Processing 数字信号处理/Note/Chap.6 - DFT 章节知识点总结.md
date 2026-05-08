# Chap.6 The Discrete Fourier Transform 章节知识点总结（按 PPT 章节顺序重写）

> 课程：ICE4405P Digital Signal Processing  
> 讲义：`PPT/Chap.6-DFT.pdf`（46 页）  
> 目录顺序：`6.1 -> 6.2 -> 6.3 -> 6.4 -> 6.5`

---

## 0. 本章主线（先抓核心）

本章核心是把“有限长序列的频谱分析与卷积计算”落地为可计算形式：

1. DFT 是对 DTFT 在等间隔频率点上的采样。  
2. IDFT 隐含序列的周期延拓（mod-$N$ 语义）。  
3. DFT 域乘法对应时域循环卷积，不是线性卷积。  
4. 通过零填充（$N\ge L+P-1$）可让循环卷积等价于线性卷积。  

---

## 1. 6.1 Sampling the Fourier Transform

设有限长序列 $x[n]$ 仅在 $n=0,1,\dots,N-1$ 可能非零，则其 DTFT：

$$
X(e^{j\omega})=\sum_{n=0}^{N-1}x[n]e^{-j\omega n}
$$

在频率网格

$$
\omega_k=\frac{2\pi k}{N},\quad k=0,1,\dots,N-1
$$

采样得到 DFT：

$$
X[k]=X(e^{j\omega_k})=\sum_{n=0}^{N-1}x[n]W_N^{kn},\quad W_N\triangleq e^{-j2\pi/N}
$$

### 要点

- DFT 本质：有限长序列的 DTFT 等间隔采样。  
- 采样点数越少，频谱细节越粗；零填充可提高频率采样密度（只提高“显示分辨率”，不增加新信息）。

---

## 2. 6.2 The DFT-IDFT Pair

## 2.1 变换对

分析式（DFT）：

$$
X[k]=\sum_{n=0}^{N-1}x[n]W_N^{kn}
$$

合成式（IDFT）：

$$
x[n]=\frac{1}{N}\sum_{k=0}^{N-1}X[k]W_N^{-kn}
$$

## 2.2 正交关系与“可逆性”

证明 IDFT 还原 DFT 依赖离散正交关系：

$$
\sum_{k=0}^{N-1}W_N^{k(m-n)}=
\begin{cases}
N,& m=n\\
0,& m\ne n
\end{cases}
$$

等价于

$$
\frac{1}{N}\sum_{k=0}^{N-1}W_N^{k(m-n)}=\delta[m-n]
$$

因此 DFT/IDFT 是一一对应的。

## 2.3 周期延拓（最重要语义）

IDFT 默认序列按 $N$ 周期重复：

$$
\tilde{x}[n]=x[n\bmod N]
$$

$$
\tilde{X}[k]=X[k\bmod N]
$$

后续所有“循环移位/循环卷积/时域混叠”都来自这个 mod-$N$ 周期语义。

## 2.4 矩阵形式

定义向量 $\mathbf{x}_N,\mathbf{X}_N$ 与 DFT 矩阵 $\mathbf{W}_N$，则

$$
\mathbf{X}_N=\mathbf{W}_N\mathbf{x}_N,
\quad
\mathbf{x}_N=\mathbf{W}_N^{-1}\mathbf{X}_N=\frac{1}{N}\mathbf{W}_N^*\mathbf{X}_N
$$

并有

$$
\mathbf{W}_N\mathbf{W}_N^*=N\mathbf{I}_N
$$

即 DFT 基底“正交到一个比例因子 $N$”。
![[Pasted image 20260503163416.png]]

---

## 3. 6.3 Summary of Fourier Representations

## 3.1 连续时间总结

- 连续非周期：CTFT。  
- 连续周期：CTFS。  
![[Pasted image 20260503165901.png]]
## 3.2 离散时间总结

- 离散非周期：DTFT。  
- 离散周期：DTFS。  
- 有限长（隐含周期延拓）：DFT。  
- ![[Pasted image 20260503170149.png]]
### 一句话

DFT 可看成“有限长序列 + 周期延拓”框架下的傅里叶表示。

---

## 4. 6.4 DFT Properties（高频考点）

## 4.1 线性

对补零到同一长度 $N$ 后的序列：

$$
a x_1[n]+b x_2[n]
\xleftrightarrow{\text{DFT}}
 aX_1[k]+bX_2[k]
$$

## 4.2 循环移位（不是线性移位）

$$
x[(n-m)_N]
\xleftrightarrow{\text{DFT}}
W_N^{km}X[k]
$$

其中 $(\cdot)_N$ 表示 mod-$N$。这说明超出边界的样本会从另一侧“绕回”。

## 4.3 对偶性

若

$$
x[n]\xleftrightarrow{\text{DFT}}X[k]
$$

则

$$
X[n]\xleftrightarrow{\text{DFT}}N\,x[(-k)_N]=N\,x[N-k]
$$

## 4.4 对称性与实序列约束

基础恒等式：

$$
x^*[n]\xleftrightarrow{\text{DFT}}X^*[(-k)_N]
$$

$$
h x
$$

![[Pasted image 20260503184920.png]]
若 $x[n]$ 为实序列：

$$
X[k]=X^*[N-k]
$$

因此

$$
|X[k]|=|X[N-k]|,
\quad
\angle X[k]= -\angle X[N-k]
$$

故实序列 DFT 仅前半段频点独立（共轭对称）。

## 4.5 循环卷积定理

若

$$
X_3[k]=X_1[k]X_2[k]
$$

则

$$
x_3[n]=x_1[n]\circledast_N x_2[n]
=\sum_{m=0}^{N-1}x_1[m]x_2[(n-m)_N]
$$

并满足交换律。
![[Pasted image 20260503190920.png]]

## 4.6 时域混叠（time aliasing）

循环卷积结果是线性卷积的周期叠加：

$$
x_{3p}[n]=\sum_{r=-\infty}^{\infty}x_3[n+rN]
$$

这就是“时域混叠”的严格表达。

避免时域混叠条件：

$$
N\ge L+P-1
$$

其中 $L,P$ 分别为两序列有效长度。

## 4.7 乘法定理（与循环卷积对偶）

$$
x_1[n]x_2[n]
\xleftrightarrow{\text{DFT}}
\frac{1}{N}\sum_{m=0}^{N-1}X_1[m]X_2[(k-m)_N]
$$

## 4.8 Parseval 定理

$$
\sum_{n=0}^{N-1}|x[n]|^2
=
\frac{1}{N}\sum_{k=0}^{N-1}|X[k]|^2
$$

表示时域能量与频域能量（按 DFT 归一化）一致。

---

## 5. 6.5 用 DFT 实现 LTI 系统（工程流程）

目标：计算线性卷积

$$
y[n]=x[n]*h[n]
$$

设输入长度 $L$、冲激响应长度 $P$。

### 5.1 标准步骤

1. 选变换长度

$$
N\ge L+P-1
$$

2. 将 $x[n],h[n]$ 零填充到长度 $N$。  
3. 分别做 $N$ 点 DFT，得 $X[k],H[k]$。  
4. 频域逐点相乘

$$
Y[k]=X[k]H[k]
$$

5. 做 $N$ 点 IDFT，得到时域结果 $y[n]$（即线性卷积）。

### 5.2 为什么零填充是关键

- DFT 乘法天然对应循环卷积；
- 只有满足 $N\ge L+P-1$ 时，循环卷积在一个 $N$ 点区间内与线性卷积一致。

---

## 6. 例 6.1~6.3 的考试视角提炼

1. **例 6.1（矩形脉冲）**  
   DFT 是 sampled-sinc 采样；$N$ 变大（零填充）只会让频谱采样更密，不改变底层 DTFT。

2. **例 6.2（4 点循环卷积）**  
   用“时域旋转叠加”或“DFT 乘积再 IDFT”都可得到同一结果，验证循环卷积定理。

3. **例 6.3（时域混叠）**  
   $N$ 过小时混叠严重；当 $N=L+P-1$ 时线性卷积可被完整恢复。

---

## 7. 本章速记（解题模板）

1. 有限长序列 DFT：

$$
X[k]=\sum_{n=0}^{N-1}x[n]W_N^{kn}
$$

2. IDFT：

$$
x[n]=\frac{1}{N}\sum_{k=0}^{N-1}X[k]W_N^{-kn}
$$

3. 循环移位：

$$
x[(n-m)_N]\leftrightarrow W_N^{km}X[k]
$$

4. 循环卷积：

$$
x_1\circledast_N x_2\leftrightarrow X_1X_2
$$

5. 时域混叠消除条件：

$$
N\ge L+P-1
$$

6. Parseval：

$$
\sum |x[n]|^2=\frac{1}{N}\sum |X[k]|^2
$$

---

## 8. 与前后章节衔接

- 本章把 Chapter 4/5 的系统分析结果转成可计算的离散频谱工具。  
- 下一步通常进入 FFT：在不改变 DFT 定义的前提下降低计算复杂度。  
- 实践中“DFT 卷积 = 先补零再频域乘法”是最常用模板。

