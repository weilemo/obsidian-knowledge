# 09_P1-Ch5 大数定律、中心极限定理与 Markov 链（2026-05-19 主讲总结）

## 1. 内容定位

- 这一讲前半部分继续巩固大数定律和中心极限定理，重点是应用场景：误差、保险、二项分布正态近似。
- 后半部分开始引入 Markov 链，是从“独立重复试验”走向“有状态依赖的随机过程”的入口。
- 这一讲和 TD12 关系很强：Chebyshev、大数定律、CLT、二项正态近似、Markov 条件都是高频方法。

## 2. 关键公式

### 2.1 大数定律

Bernoulli 频率形式：

$$
\frac{N_A}{n}\xrightarrow{P}p.
$$

Khintchine 形式：

$$
\frac1n\sum_{k=1}^{n}X_k\xrightarrow{P}\mu,
$$

其中 $X_k$ 独立同分布，且 $\mathbb E[X_k]=\mu$。

### 2.2 中心极限定理

若 $X_1,\dots,X_n$ 独立同分布，且

$$
\mathbb E[X_i]=\mu,\qquad \mathrm{Var}(X_i)=\sigma^2,
$$

则

$$
\frac{\sum_{i=1}^{n}X_i-n\mu}{\sigma\sqrt n}\xrightarrow{L}N(0,1).
$$

### 2.3 二项分布的正态近似

若

$$
S_n\sim \mathrm{Bin}(n,p),
$$

则

$$
\frac{S_n-np}{\sqrt{np(1-p)}}\approx N(0,1).
$$

使用连续性修正：

$$
P(a\le S_n\le b)
\approx
\Phi\left(\frac{b+0.5-np}{\sqrt{np(1-p)}}\right)
-
\Phi\left(\frac{a-0.5-np}{\sqrt{np(1-p)}}\right).
$$

### 2.4 Markov 链转移矩阵

本课采用“列和为 $1$”的记号：

$$
\sum_i T_{i,j}=1,
$$

其中

$$
T_{i,j}=P(j\to i).
$$

若 $\alpha_n$ 是第 $n$ 步状态分布列向量，则

$$
\alpha_{n+1}=T\alpha_n,
$$

因此

$$
\alpha_n=T^n\alpha_0.
$$

### 2.5 Markov 性质

$$
P(X_{n+1}=i_{n+1}\mid X_0=i_0,\dots,X_n=i_n)
=P(X_{n+1}=i_{n+1}\mid X_n=i_n).
$$

意思是：给定现在，未来与过去无关。

## 3. 关键证明与推导

### 3.1 为什么 CLT 要标准化

令

$$
S_n=\sum_{i=1}^{n}X_i.
$$

独立同分布时，

$$
\mathbb E[S_n]=n\mu,\qquad \mathrm{Var}(S_n)=n\sigma^2.
$$

所以标准差为

$$
\sigma\sqrt n.
$$

因此标准化量自然是

$$
\frac{S_n-n\mu}{\sigma\sqrt n}.
$$

### 3.2 为什么二项分布可以用正态近似

若 $S_n\sim \mathrm{Bin}(n,p)$，可写成

$$
S_n=X_1+\cdots+X_n,
$$

其中 $X_i\sim \mathrm{Bernoulli}(p)$ 独立同分布。

因为

$$
\mathbb E[X_i]=p,\qquad \mathrm{Var}(X_i)=p(1-p),
$$

CLT 给出

$$
\frac{S_n-np}{\sqrt{np(1-p)}}\xrightarrow{L}N(0,1).
$$

### 3.3 Markov 链联合路径概率

若初始分布为 $\alpha_0$，转移矩阵为 $T$，则一条路径

$$
i_0\to i_1\to\cdots\to i_n
$$

的概率是

$$
P(X_0=i_0,\dots,X_n=i_n)
=T_{i_n,i_{n-1}}\cdots T_{i_1,i_0}\alpha_0(i_0).
$$

这就是“初始概率乘每一步转移概率”。

## 4. 做题提醒

- 问“平均值稳定到期望”时，用大数定律。
- 问“和或平均值的概率近似”时，用 CLT。
- 二项分布大样本概率，优先考虑 de Moivre-Laplace 正态近似，并注意连续性修正。
- Markov 链题先列状态，再写转移矩阵，最后用 $\alpha_{n+1}=T\alpha_n$ 推分布。

