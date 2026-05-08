# TD6 习题详解（Probability, 2026-04-09）

题目来源：`/Users/moweile/Obsidian/Knowledge/Course/25-26-2/MATH3307P Probability & Statistics 概率论与统计/TD/TD6.pdf`

说明：本笔记遵循 `agent.md` 规范。每个关键公式都给出来源、成立条件与推导。

## 目录
- [Ex1 指数型联合密度：归一化与区域概率](#ex1-指数型联合密度归一化与区域概率)
- [Ex2 三角区域密度：常数、概率与边缘分布](#ex2-三角区域密度常数概率与边缘分布)
- [Ex3 圆盘型密度：半径事件与边缘分布](#ex3-圆盘型密度半径事件与边缘分布)
- [Ex4 二维均匀分布在非矩形区域上的边缘](#ex4-二维均匀分布在非矩形区域上的边缘)
- [Ex5 电商 A/B/不买：联合分布](#ex5-电商-ab不买联合分布)
- [Ex6 二元正态中 $f_{X,Y}=f_Xf_Y \iff \rho=0$](#ex6-二元正态中-f_xyf_xf_y-iff-rho0)

---

## Ex1 指数型联合密度：归一化与区域概率
给定

$$
f_{X,Y}(x,y)=
\begin{cases}
ke^{-2x-4y}, & x>0,\ y>0,\\
0, & \text{其它}.
\end{cases}
$$

### (1) 求 $k$
联合密度必须满足

$$
\iint_{\mathbb R^2}f_{X,Y}(x,y)\,dx\,dy=1.
$$

故

$$
k\int_0^\infty e^{-2x}dx\int_0^\infty e^{-4y}dy
=k\cdot\frac12\cdot\frac14
=\frac{k}{8}=1.
$$

所以

$$
\boxed{k=8}.
$$

### (2) 计算 $P(0\le X\le2,\ 0\le Y\le1)$

$$
P=\int_0^2\int_0^1 8e^{-2x-4y}\,dy\,dx
=8\left(\int_0^2e^{-2x}dx\right)\left(\int_0^1e^{-4y}dy\right)
$$

$$
=8\cdot\frac{1-e^{-4}}{2}\cdot\frac{1-e^{-4}}{4}
=\boxed{(1-e^{-4})^2}.
$$

### (3) 计算 $P(X+Y<1)$
区域是第一象限内三角形：$0<x<1,\ 0<y<1-x$。

$$
P=\int_0^1\int_0^{1-x}8e^{-2x-4y}\,dy\,dx
$$

$$
=8\int_0^1 e^{-2x}\cdot\frac{1-e^{-4(1-x)}}{4}\,dx
=2\int_0^1\left(e^{-2x}-e^{-4}e^{2x}\right)dx
$$

$$
=\left(1-e^{-2}\right)-\left(e^{-2}-e^{-4}\right)
=\boxed{(1-e^{-2})^2}.
$$

---

## Ex2 三角区域密度：常数、概率与边缘分布
给定

$$
f(x,y)=
\begin{cases}
cy(1-x), & 0\le x<1,\ 0\le y<x,\\
0, & \text{其它}.
\end{cases}
$$

### (1) 求 $c$
归一化：

$$
1=\int_0^1\int_0^x cy(1-x)\,dy\,dx
=c\int_0^1(1-x)\frac{x^2}{2}\,dx
$$

$$
=\frac{c}{2}\int_0^1(x^2-x^3)\,dx
=\frac{c}{2}\left(\frac13-\frac14\right)
=\frac{c}{24}.
$$

所以

$$
\boxed{c=24}.
$$

### (2) 计算 $P(X+Y<1)$
条件 $y<x$ 与 $y<1-x$ 同时成立。按 $x=1/2$ 分段：

- $0\le x\le1/2$: $0\le y\le x$
- $1/2\le x<1$: $0\le y\le1-x$

$$
P=24\int_0^{1/2}\int_0^x y(1-x)\,dy\,dx
+24\int_{1/2}^{1}\int_0^{1-x}y(1-x)\,dy\,dx.
$$

第一段：

$$
24\int_0^{1/2}(1-x)\frac{x^2}{2}\,dx
=12\int_0^{1/2}(x^2-x^3)\,dx
=\frac{5}{16}.
$$

第二段：

$$
24\int_{1/2}^{1}(1-x)\frac{(1-x)^2}{2}\,dx
=12\int_{1/2}^{1}(1-x)^3\,dx
=\frac{3}{16}.
$$

合计：

$$
\boxed{P(X+Y<1)=\frac{1}{2}}.
$$

### (3) 求边缘分布
#### $X$ 的边缘密度

$$
f_X(x)=\int_0^x 24y(1-x)\,dy
=12x^2(1-x),\quad 0\le x<1.
$$

其它处为 0。

#### $Y$ 的边缘密度
由区域 $0\le y<x<1$ 得固定 $y$ 时 $x\in[y,1)$：

$$
f_Y(y)=\int_y^1 24y(1-x)\,dx
=12y(1-y)^2,\quad 0\le y<1.
$$

其它处为 0。

---

## Ex3 圆盘型密度：半径事件与边缘分布
给定

$$
f(x,y)=
\begin{cases}
\dfrac{2}{\pi}\left(1-(x^2+y^2)\right), & x^2+y^2\le1,\\
0, & \text{其它}.
\end{cases}
$$

### (1) $B=\{x^2+y^2\le r^2\},\ 0<r<1$，求 $P((X,Y)\in B)$
使用极坐标 $x=\rho\cos\theta,\ y=\rho\sin\theta,\ dxdy=\rho\,d\rho d\theta$：

$$
P(B)=\int_0^{2\pi}\int_0^r \frac{2}{\pi}(1-\rho^2)\rho\,d\rho d\theta
=4\int_0^r(\rho-\rho^3)\,d\rho
$$

$$
=4\left(\frac{r^2}{2}-\frac{r^4}{4}\right)
=\boxed{2r^2-r^4}.
$$

### (2) 边缘分布
对固定 $x$，有 $y\in[-\sqrt{1-x^2},\sqrt{1-x^2}]$（当 $|x|\le1$）。

令 $a=\sqrt{1-x^2}$，则

$$
f_X(x)=\int_{-a}^{a}\frac{2}{\pi}(1-x^2-y^2)\,dy
=\frac{4}{\pi}\left((1-x^2)a-\frac{a^3}{3}\right)
$$

$$
=\frac{8}{3\pi}(1-x^2)^{3/2},\quad |x|\le1.
$$

否则为 0。由于对称性，

$$
f_Y(y)=\frac{8}{3\pi}(1-y^2)^{3/2},\quad |y|\le1,
$$

否则为 0。

---

## Ex4 二维均匀分布在非矩形区域上的边缘
区域

$$
G=\{(x,y)\mid 0\le x\le1,\ x^2/2\le y\le x^2\}.
$$

### (1) 联合密度
二维均匀分布定义：$f_{X,Y}=1/\text{Area}(G)$（在区域内常数）。

先算面积：

$$
\text{Area}(G)=\int_0^1\left(x^2-\frac{x^2}{2}\right)dx
=\int_0^1\frac{x^2}{2}\,dx
=\frac16.
$$

故

$$
f_{X,Y}(x,y)=
\begin{cases}
6, & (x,y)\in G,\\
0, & \text{其它}.
\end{cases}
$$

### (2) 边缘密度
#### $X$ 的边缘

$$
f_X(x)=\int_{x^2/2}^{x^2}6\,dy
=3x^2,\quad 0\le x\le1.
$$

其它处为 0。

#### $Y$ 的边缘
对固定 $y$，由

$$
x^2/2\le y\le x^2
$$

等价于

$$
\sqrt y\le x\le \min(\sqrt{2y},1).
$$

因此分段：

- $0\le y\le1/2$: $x\in[\sqrt y,\sqrt{2y}]$
- $1/2<y\le1$: $x\in[\sqrt y,1]$

故

$$
f_Y(y)=
\begin{cases}
6(\sqrt{2y}-\sqrt y), & 0\le y\le \frac12,\\
6(1-\sqrt y), & \frac12< y\le1,\\
0, & \text{其它}.
\end{cases}
$$

这也解释了题中备注：二维“区域均匀”并不意味着边缘一定均匀。

---

## Ex5 电商 A/B/不买：联合分布
每位访问者有三种互斥结果：
- 选 A，概率 $p$
- 选 B，概率 $q$
- 都不选，概率 $1-p-q$

共 $n$ 人独立。设
- $X$：选 A 的人数
- $Y$：选 B 的人数

则 $(X,Y)$ 服从三项分布（multinomial 的二维计数）：

$$
P(X=x,Y=y)
=\frac{n!}{x!\,y!\,(n-x-y)!}\,
p^x q^y(1-p-q)^{n-x-y},
$$

其中

$$
x,y\in\{0,1,\dots,n\},\quad x+y\le n.
$$

其它情况概率为 0。

公式来源：多项分布计数（组合数）$\times$ 每种序列概率。

---

## Ex6 二元正态中 $f_{X,Y}=f_Xf_Y \iff \rho=0$
给定二元正态密度

$$
f(x,y)=\frac{1}{2\pi\sigma_1\sigma_2\sqrt{1-\rho^2}}
\exp\!\left\{-\frac{1}{2(1-\rho^2)}
\left[u^2-2\rho uv+v^2\right]\right\},
$$

其中

$$
u=\frac{x-\mu_1}{\sigma_1},\qquad
v=\frac{y-\mu_2}{\sigma_2}.
$$

边缘密度给定为

$$
f_X(x)=\frac{1}{\sqrt{2\pi}\sigma_1}e^{-u^2/2},\qquad
f_Y(y)=\frac{1}{\sqrt{2\pi}\sigma_2}e^{-v^2/2}.
$$

要证

$$
f(x,y)=f_X(x)f_Y(y)\iff \rho=0.
$$

### (⇒) 若 $f=f_Xf_Y$，则 $\rho=0$
考察比值：

$$
\frac{f(x,y)}{f_X(x)f_Y(y)}
=\frac{1}{\sqrt{1-\rho^2}}
\exp\!\left\{-\frac{\rho^2(u^2+v^2)-2\rho uv}{2(1-\rho^2)}\right\}.
$$

若该比值对所有 $u,v$ 恒等于 1，则指数中的 $uv$ 项系数必须为 0，即

$$
\frac{\rho}{1-\rho^2}=0\Rightarrow \rho=0.
$$

### (⇐) 若 $\rho=0$，则 $f=f_Xf_Y$
把 $\rho=0$ 代回联合密度：

$$
f(x,y)=\frac{1}{2\pi\sigma_1\sigma_2}
\exp\!\left(-\frac{u^2+v^2}{2}\right)
$$

$$
=\left(\frac{1}{\sqrt{2\pi}\sigma_1}e^{-u^2/2}\right)
\left(\frac{1}{\sqrt{2\pi}\sigma_2}e^{-v^2/2}\right)
=f_X(x)f_Y(y).
$$

故命题成立。
