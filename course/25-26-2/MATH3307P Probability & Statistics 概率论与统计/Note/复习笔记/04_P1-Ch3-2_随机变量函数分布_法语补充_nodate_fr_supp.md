# 04_P1-Ch3-2 随机变量函数分布（法语补充笔记）

## 1. 内容定位
- 主题：已知 $X$ 的分布，求 $Y=g(X)$ 的分布。
- 本讲覆盖离散情形、连续情形（单调与非单调）及经典分布变换。

## 2. 关键公式

### 2.1 离散型变换
若 $X$ 离散且 $Y=g(X)$，则

$$
P(Y=y)=\sum_{x:g(x)=y}P(X=x)
$$

### 2.2 分布函数法（通用）

$$
F_Y(y)=P(Y\le y)=P(g(X)\le y)
$$

此方法适用于单调与非单调情形。

### 2.3 单调可逆连续变换
若 $g$ 严格单调且可逆，$Y=g(X)$，则

$$
f_Y(y)=f_X\big(g^{-1}(y)\big)\left|\frac{d}{dy}g^{-1}(y)\right|
$$

### 2.4 非单调连续变换（多根求和）
若方程 $g(x)=y$ 有多个根 $x_i$，则

$$
f_Y(y)=\sum_i f_X(x_i)\left|\frac{dx_i}{dy}\right|
$$

### 2.5 典型变换
- 线性变换：若 $Y=aX+b$（$a\ne0$），则

$$
f_Y(y)=\frac1{|a|}f_X\!\left(\frac{y-b}{a}\right)
$$

- 若 $X\sim N(\mu,\sigma^2)$，则

$$
aX+b\sim N(a\mu+b,a^2\sigma^2)
$$

- 若 $X\sim N(\mu,\sigma^2)$ 且 $Y=e^X$，则 $Y$ 服从对数正态分布。

- 概率积分变换：若 $F_X$ 连续严格递增，令 $U=F_X(X)$，则

$$
U\sim U(0,1)
$$

## 3. 关键性质
- 同一个变换问题可优先用 $F_Y$ 法，最稳健。
- 非单调变换不能直接套单根公式，必须分支求和。
- 变换后的支持区间（取值范围）要先确定，再写密度。

## 4. 重要证明

### 证明 1：单调可逆变换密度公式
以 $g$ 严格递增为例：

$$
F_Y(y)=P(Y\le y)=P(g(X)\le y)=P\big(X\le g^{-1}(y)\big)=F_X\big(g^{-1}(y)\big)
$$

两边对 $y$ 求导：

$$
f_Y(y)=f_X\big(g^{-1}(y)\big)\frac{d}{dy}g^{-1}(y)
$$

若 $g$ 递减，则导数为负，统一写成绝对值形式：

$$
f_Y(y)=f_X\big(g^{-1}(y)\big)\left|\frac{d}{dy}g^{-1}(y)\right|
$$

### 证明 2：概率积分变换
设 $U=F_X(X)$，对 $u\in(0,1)$：

$$
P(U\le u)=P\big(F_X(X)\le u\big)
$$

因 $F_X$ 连续严格递增，存在反函数 $F_X^{-1}$，故

$$
P(U\le u)=P\big(X\le F_X^{-1}(u)\big)=F_X\big(F_X^{-1}(u)\big)=u
$$

所以

$$
F_U(u)=u,\quad 0<u<1
$$

即 $U\sim U(0,1)$。

### 证明 3：正态线性变换结论
设 $X\sim N(\mu,\sigma^2)$，$Y=aX+b$。由标准化

$$
\frac{Y-(a\mu+b)}{|a|\sigma}=\frac{aX+b-(a\mu+b)}{|a|\sigma}=\operatorname{sgn}(a)\frac{X-\mu}{\sigma}
$$

右侧仍为标准正态分布，故

$$
Y\sim N(a\mu+b,a^2\sigma^2)
$$

## 5. 学习提示
- 先画出 $g(x)$ 的单调区间，再决定用几根公式。
- 做题习惯：支持区间 → 公式 → 归一化检查。
