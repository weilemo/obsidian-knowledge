# TD5 习题详解（Probability, 2026-04-02）

题目来源：`/Users/moweile/Obsidian/Knowledge/Course/25-26-2/MATH3307P Probability & Statistics 概率论与统计/TD/TD5.pdf`

说明：本笔记遵循 `agent.md` 规范，凡用到公式均说明来源与条件，并给出推导或直观解释。

## 目录
- [Ex1 随机变量函数变换：分布函数与密度](#ex1-随机变量函数变换分布函数与密度)
- [Ex2 $X=-\ln\frac{2U}{1+U}$ 的分布](#ex2-x-lnfrac2u1u-的分布)
- [Ex3 指数分布的两种变换](#ex3-指数分布的两种变换)
- [Ex4 对数正态与正态尾概率上界](#ex4-对数正态与正态尾概率上界)
- [Ex5 给定二维分布函数求参数与边缘分布](#ex5-给定二维分布函数求参数与边缘分布)
- [Ex6 两枚骰子的 $(X,Y)$ 联合分布](#ex6-两枚骰子的-xy-联合分布)
- [Ex7 泊松产卵-孵化模型的联合与边缘分布](#ex7-泊松产卵-孵化模型的联合与边缘分布)

---

## Ex1 随机变量函数变换：分布函数与密度
设 $X$ 的分布函数为 $F$。

### A. 分布函数 $F_Y$

### (1) $Y=X^2$
由事件等价

$$
\{X^2\le y\}=
\begin{cases}
\varnothing, & y<0,\\
\{-\sqrt y\le X\le \sqrt y\}, & y\ge 0,
\end{cases}
$$

得

$$
F_Y(y)=
\begin{cases}
0, & y<0,\\
F(\sqrt y)-F(-\sqrt y-), & y\ge 0.
\end{cases}
$$

若 $F\in C^1$（连续型，无原子），可写成

$$
F_Y(y)=F(\sqrt y)-F(-\sqrt y),\quad y\ge 0.
$$

### (2) $Y=\lfloor X\rfloor$
$\lfloor X\rfloor\le y \iff X<\lfloor y\rfloor+1$，故

$$
F_Y(y)=P(\lfloor X\rfloor\le y)=F(\lfloor y\rfloor+1-).
$$

这是离散型随机变量，其质量函数为

$$
P(Y=k)=P(k\le X<k+1)=F(k+1)-F(k).
$$

### (3) $Y=X-\lfloor X\rfloor$（小数部分）
$Y\in[0,1)$。对 $0\le y<1$：

$$
\{Y\le y\}=\bigcup_{k\in\mathbb Z}\{k\le X<k+y\},
$$

并且这些区间两两不交，因此

$$
F_Y(y)=\sum_{k\in\mathbb Z}\bigl(F(k+y)-F(k)\bigr),\quad 0\le y<1.
$$

再补上边界：

$$
F_Y(y)=
\begin{cases}
0, & y<0,\\
\sum_{k\in\mathbb Z}\!\left(F(k+y)-F(k)\right), & 0\le y<1,\\
1, & y\ge 1.
\end{cases}
$$

### (4) $Y=1/X$，且 $P(X=0)=0$
注意 $1/x$ 在 $(-\infty,0)$、$(0,\infty)$ 上都严格单调递减，分段讨论：

- $y>0$：

$$
\{1/X\le y\}=\{X<0\}\cup\{X\ge 1/y\},
$$

故

$$
F_Y(y)=F(0-)+1-F(1/y-).
$$

- $y<0$：

$$
\{1/X\le y\}=\{1/y\le X<0\},
$$

故

$$
F_Y(y)=F(0-)-F(1/y-).
$$

- $y=0$：$F_Y(0)=P(X<0)=F(0-)$。

若 $F\in C^1$，简写为

$$
F_Y(y)=
\begin{cases}
F(0)-F(1/y), & y<0,\\
F(0), & y=0,\\
F(0)+1-F(1/y), & y>0.
\end{cases}
$$

### (5) $Y=e^X$
因为指数函数严格递增：

$$
F_Y(y)=P(e^X\le y)=
\begin{cases}
0, & y\le 0,\\
F(\ln y), & y>0.
\end{cases}
$$

### B. 密度 $f_Y$（若 $F\in C^1$，$f_X=F'$）

公式来源（单调变换定理）：若 $Y=g(X)$ 且 $g$ 可逆可微，

$$
f_Y(y)=f_X(g^{-1}(y))\left|\frac{d}{dy}g^{-1}(y)\right|.
$$

#### (1) $Y=X^2$
$y>0$ 时有两根 $x=\pm\sqrt y$（“多根求和公式”）：

$$
f_Y(y)=\frac{f_X(\sqrt y)+f_X(-\sqrt y)}{2\sqrt y},\quad y>0;\qquad f_Y(y)=0,\ y<0.
$$

#### (2) $Y=\lfloor X\rfloor$
离散型，无连续密度。质量函数：

$$
P(Y=k)=\int_k^{k+1}f_X(x)\,dx.
$$

#### (3) $Y=X-\lfloor X\rfloor$
$0<y<1$ 时：

$$
f_Y(y)=\sum_{k\in\mathbb Z}f_X(k+y),\quad 0<y<1.
$$

#### (4) $Y=1/X$
$x=1/y$，$\left|\frac{dx}{dy}\right|=\frac1{y^2}$，故

$$
f_Y(y)=\frac{1}{y^2}f_X(1/y),\quad y\ne 0.
$$

#### (5) $Y=e^X$
$x=\ln y$，$\left|\frac{dx}{dy}\right|=\frac1y$，故

$$
f_Y(y)=\frac1y f_X(\ln y),\quad y>0;\qquad f_Y(y)=0,\ y\le0.
$$

---

## Ex2 $X=-\ln\frac{2U}{1+U}$ 的分布
给定 $U\sim U(0,1)$。

设

$$
X=-\ln\!\left(\frac{2U}{1+U}\right).
$$

先看取值：$\frac{2U}{1+U}\in(0,1)$，故 $X>0$。

对 $x>0$：

$$
F_X(x)=P(X\le x)
=P\!\left(-\ln\frac{2U}{1+U}\le x\right)
=P\!\left(\frac{2U}{1+U}\ge e^{-x}\right).
$$

由单调性解不等式：

$$
\frac{2U}{1+U}\ge e^{-x}
\iff
U\ge \frac{e^{-x}}{2-e^{-x}}.
$$

因此

$$
F_X(x)=
\begin{cases}
0, & x\le0,\\
1-\dfrac{e^{-x}}{2-e^{-x}}
=\dfrac{2(e^x-1)}{2e^x-1}, & x>0.
\end{cases}
$$

对 $x>0$ 求导：

$$
f_X(x)=\frac{d}{dx}\frac{2(e^x-1)}{2e^x-1}
=\frac{2e^x}{(2e^x-1)^2},\quad x>0.
$$

所以 $X$ 是绝对连续型随机变量。

---

## Ex3 指数分布的两种变换
设 $X\sim \mathrm{Exp}(\lambda)$，即

$$
F_X(x)=1-e^{-\lambda x},\ x\ge0;\qquad f_X(x)=\lambda e^{-\lambda x},\ x\ge0.
$$

### (1) $Y=X^2$
因 $X\ge0$，$y\ge0$ 时

$$
F_Y(y)=P(X^2\le y)=P(X\le \sqrt y)=1-e^{-\lambda\sqrt y}.
$$

所以

$$
F_Y(y)=
\begin{cases}
0, & y<0,\\
1-e^{-\lambda\sqrt y}, & y\ge0,
\end{cases}
$$

并且

$$
f_Y(y)=\frac{\lambda}{2\sqrt y}e^{-\lambda\sqrt y},\quad y>0.
$$

### (2) $Z=\begin{cases}X,&0<X<1,\\2X,&X\ge1.\end{cases}$
分段讨论 $F_Z(z)=P(Z\le z)$：

$$
F_Z(z)=
\begin{cases}
0, & z<0,\\
1-e^{-\lambda z}, & 0\le z<1,\\
1-e^{-\lambda}, & 1\le z<2,\\
1-e^{-\lambda z/2}, & z\ge2.
\end{cases}
$$

故密度为

$$
f_Z(z)=
\begin{cases}
\lambda e^{-\lambda z}, & 0<z<1,\\
0, & 1<z<2,\\
\dfrac{\lambda}{2}e^{-\lambda z/2}, & z>2,\\
0, & \text{其它}.
\end{cases}
$$

---

## Ex4 对数正态与正态尾概率上界

### (1) 若 $X\sim N(\mu,\sigma^2)$，求 $Y=e^X$ 的分布
由单调变换公式（Ex1 已给出处）：

$$
f_Y(y)=\frac{1}{y}f_X(\ln y),\quad y>0.
$$

代入正态密度得

$$
f_Y(y)=\frac{1}{y\sigma\sqrt{2\pi}}
\exp\!\left(-\frac{(\ln y-\mu)^2}{2\sigma^2}\right),\quad y>0.
$$

即 $Y\sim \mathrm{Lognormal}(\mu,\sigma^2)$。

### (2) 证明正态尾概率上界（$x>0$）
记标准正态密度

$$
\varphi(t)=\frac{1}{\sqrt{2\pi}}e^{-t^2/2}.
$$

有

$$
P(X\ge x)=\int_x^\infty \varphi(t)\,dt.
$$

因 $t\ge x>0\Rightarrow 1\le t/x$，故

$$
\int_x^\infty \varphi(t)\,dt
\le \frac1x\int_x^\infty t\varphi(t)\,dt.
$$

又因为 $\varphi'(t)=-t\varphi(t)$，所以

$$
\int_x^\infty t\varphi(t)\,dt
=\left[-\varphi(t)\right]_x^\infty
=\varphi(x).
$$

因此

$$
P(X\ge x)\le \frac{\varphi(x)}{x}
=\frac{e^{-x^2/2}}{x\sqrt{2\pi}}.
$$

再由对称性 $P(|X|\ge x)=2P(X\ge x)$，得

$$
P(|X|\ge x)\le \frac{2e^{-x^2/2}}{x\sqrt{2\pi}}.
$$

---

## Ex5 给定二维分布函数求参数与边缘分布
给定

$$
F(x,y)=A\left(\arctan\frac{x}{2}+B\right)\left(\arctan\frac{y}{3}+C\right).
$$

### (1) 求 $A,B,C$
二维分布函数边界条件：

$$
\lim_{x\to-\infty}F(x,y)=0,\quad
\lim_{y\to-\infty}F(x,y)=0,\quad
\lim_{x,y\to+\infty}F(x,y)=1.
$$

利用 $\arctan(-\infty)=-\pi/2$, $\arctan(+\infty)=\pi/2$：

$$
B=\frac{\pi}{2},\quad C=\frac{\pi}{2}.
$$

再由极限到 $+\infty,+\infty$：

$$
1=A\cdot \pi\cdot\pi \Rightarrow A=\frac1{\pi^2}.
$$

### (2) 边缘分布
由定义

$$
F_X(x)=\lim_{y\to+\infty}F(x,y)
=\frac{1}{\pi}\left(\arctan\frac{x}{2}+\frac{\pi}{2}\right),
$$

$$
F_Y(y)=\lim_{x\to+\infty}F(x,y)
=\frac{1}{\pi}\left(\arctan\frac{y}{3}+\frac{\pi}{2}\right).
$$

对应边缘密度：

$$
f_X(x)=\frac{2}{\pi(x^2+4)},\qquad
f_Y(y)=\frac{3}{\pi(y^2+9)}.
$$

---

## Ex6 两枚骰子的 $(X,Y)$ 联合分布
两枚骰子点数 $(i,j)\in\{1,\dots,6\}^2$ 等概率，$P(i,j)=1/36$。

定义

$$
X=i+j,\qquad Y=|i-j|.
$$

### (1) 联合分布规律
- 若 $y=0$，则 $i=j$，每个可行和 $x\in\{2,4,6,8,10,12\}$ 仅 1 个有序对。
- 若 $y>0$，可行时有 2 个有序对（交换 $i,j$）。

故

$$
P(X=x,Y=y)=
\begin{cases}
\dfrac{1}{36}, & y=0,\ x\in\{2,4,6,8,10,12\},\\[6pt]
\dfrac{2}{36}, & y>0,\ \frac{x\pm y}{2}\in\{1,\dots,6\},\\
0, & \text{其它}.
\end{cases}
$$

（其中 $\frac{x\pm y}{2}\in\mathbb Z$ 自动要求 $x,y$ 同奇偶。）

### (2) 边缘分布
#### $X$ 的边缘
和点分布（经典三角形）：

$$
P(X=x)=\frac{6-|x-7|}{36},\quad x=2,3,\dots,12.
$$

#### $Y$ 的边缘
差值为 $d$ 时：
- $d=0$：$(1,1),\dots,(6,6)$ 共 6 个；
- $d\in\{1,\dots,5\}$：有 $2(6-d)$ 个有序对。

所以

$$
P(Y=0)=\frac{6}{36}=\frac16,
$$

$$
P(Y=d)=\frac{2(6-d)}{36}=\frac{6-d}{18},\quad d=1,2,3,4,5.
$$

---

## Ex7 泊松产卵-孵化模型的联合与边缘分布
设
- $X\sim \mathrm{Pois}(\lambda)$：产卵数；
- 每个卵独立孵化，概率为 $p$；
- $Y$：孵化数。

### (1) 联合分布 $P(X=n,Y=k)$
给定 $X=n$ 时，$Y\mid X=n\sim \mathrm{Bin}(n,p)$，故

$$
P(Y=k\mid X=n)=\binom{n}{k}p^k(1-p)^{n-k},\quad 0\le k\le n.
$$

乘上 $P(X=n)=e^{-\lambda}\frac{\lambda^n}{n!}$：

$$
P(X=n,Y=k)=
\binom{n}{k}p^k(1-p)^{n-k}\,e^{-\lambda}\frac{\lambda^n}{n!},
\quad 0\le k\le n.
$$

等价写法：

$$
P(X=n,Y=k)=e^{-\lambda}\frac{(\lambda p)^k}{k!}\frac{(\lambda(1-p))^{n-k}}{(n-k)!}.
$$

### (2) 边缘分布
#### $X$ 的边缘
显然仍是

$$
X\sim\mathrm{Pois}(\lambda).
$$

#### $Y$ 的边缘（抽稀结论的推导）

$$
P(Y=k)=\sum_{n=k}^{\infty}P(X=n,Y=k)
$$

代入并令 $j=n-k$：

$$
P(Y=k)=e^{-\lambda}\frac{(\lambda p)^k}{k!}
\sum_{j=0}^{\infty}\frac{(\lambda(1-p))^j}{j!}
=e^{-\lambda p}\frac{(\lambda p)^k}{k!}.
$$

因此

$$
Y\sim\mathrm{Pois}(\lambda p).
$$
