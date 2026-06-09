# 08_P1-Ch5 收敛、特征函数、大数定律与中心极限定理（教材章节补充总结）

## 1. 内容定位

- 这份 `chapter 5.pdf` 是 Chapter 5 的教材补充，不是新的主线课件。
- 它系统补充第 8、9 讲：收敛、特征函数、大数定律、中心极限定理。
- 比课件更细的地方是：特征函数反演公式、Lévy 连续性定理、Chebyshev/Markov/Khinchine 大数定律、Lindeberg 与 Lyapunov 条件。

## 2. 关键公式

### 2.1 依概率收敛

$$
X_n\xrightarrow{P}X
\Longleftrightarrow
\forall \varepsilon>0,\ P(|X_n-X|\ge \varepsilon)\to 0.
$$

若 $X_n\xrightarrow{P}a$，$Y_n\xrightarrow{P}b$，则

$$
X_n\pm Y_n\xrightarrow{P}a\pm b,\qquad
X_nY_n\xrightarrow{P}ab.
$$

若 $b\ne 0$，则

$$
\frac{X_n}{Y_n}\xrightarrow{P}\frac{a}{b}.
$$

### 2.2 依分布收敛

$$
X_n\xrightarrow{L}X
\Longleftrightarrow
F_{X_n}(x)\to F_X(x)
$$

对所有 $F_X$ 的连续点 $x$ 成立。

关系：

$$
X_n\xrightarrow{P}X\Longrightarrow X_n\xrightarrow{L}X.
$$

若极限是常数 $c$，则

$$
X_n\xrightarrow{P}c
\Longleftrightarrow
X_n\xrightarrow{L}c.
$$

### 2.3 特征函数

$$
\varphi_X(t)=\mathbb E[e^{itX}].
$$

若 $X,Y$ 独立，

$$
\varphi_{X+Y}(t)=\varphi_X(t)\varphi_Y(t).
$$

若 $Y=aX+b$，

$$
\varphi_Y(t)=e^{ibt}\varphi_X(at).
$$

若矩存在，

$$
\varphi_X^{(k)}(0)=i^k\mathbb E[X^k].
$$

### 2.4 反演与唯一性

特征函数唯一决定分布。若 $x_1,x_2$ 是 $F$ 的连续点，则

$$
F(x_2)-F(x_1)
=
\lim_{T\to\infty}\frac{1}{2\pi}
\int_{-T}^{T}
\frac{e^{-itx_1}-e^{-itx_2}}{it}\varphi(t)\,dt.
$$

若 $X$ 有密度 $p$，且 $\varphi$ 可积，则

$$
p(x)=\frac{1}{2\pi}\int_{-\infty}^{+\infty}e^{-itx}\varphi(t)\,dt.
$$

### 2.5 Lévy 连续性定理

$$
X_n\xrightarrow{L}X
$$

等价于

$$
\varphi_{X_n}(t)\to \varphi_X(t),\qquad \forall t.
$$

这是用特征函数证明极限定理的核心工具。

### 2.6 大数定律

Bernoulli 大数定律：

$$
\frac{S_n}{n}\xrightarrow{P}p.
$$

Chebyshev 大数定律：

若 $X_i$ 两两不相关，且方差一致有界，则

$$
\frac1n\sum_{i=1}^{n}X_i
-
\frac1n\sum_{i=1}^{n}\mathbb E[X_i]
\xrightarrow{P}0.
$$

Markov 条件：

$$
\frac{1}{n^2}\mathrm{Var}\left(\sum_{i=1}^{n}X_i\right)\to 0.
$$

满足该条件即可得到大数定律。

Khintchine 大数定律：

若 $X_i$ 独立同分布，且 $\mathbb E[X_i]=\mu$ 存在，则

$$
\frac1n\sum_{i=1}^{n}X_i\xrightarrow{P}\mu.
$$

### 2.7 中心极限定理

Lindeberg-Lévy CLT：

$$
\frac{\sum_{i=1}^{n}X_i-n\mu}{\sigma\sqrt n}
\xrightarrow{L}
N(0,1).
$$

de Moivre-Laplace：

若 $S_n\sim \mathrm{Bin}(n,p)$，则

$$
\frac{S_n-np}{\sqrt{np(1-p)}}\xrightarrow{L}N(0,1).
$$

## 3. 教材补充的重点

- 依概率收敛的四则运算证明，尤其三角不等式和坏事件包含关系。
- 为什么依分布收敛只要求在极限分布函数连续点收敛。
- 特征函数不只是计算工具，还能通过反演公式唯一确定分布。
- 大数定律有多个版本，条件强弱不同。
- CLT 的核心是“中心化 + 标准化 + 正态极限”。
- 二项分布正态近似要注意连续性修正。

## 4. 复习建议

- TD11 对应特征函数和收敛。
- TD12 对应大数定律、Chebyshev、CLT 应用。
- 如果只准备做题，优先掌握 Chebyshev、Markov 条件、CLT 标准化和二项正态近似。
- 如果要理解证明，重点看特征函数如何把“分布收敛”变成“函数收敛”。

