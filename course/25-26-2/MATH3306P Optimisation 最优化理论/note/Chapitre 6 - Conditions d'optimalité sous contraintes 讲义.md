# Chapitre 6：Conditions d'optimalité sous contraintes

来源：

- [[../Materials/Slides/Slides_Chp6.pdf|Slides_Chp6.pdf]]
- [[../Materials/General/Poly_Optimisation-20260529.pdf|Poly_Optimisation-20260529.pdf]]
- [[../Materials/General/Poly_Optimisation.pdf|Poly_Optimisation.pdf]]

本章讨论**约束优化问题的最优性条件**。前几章主要研究无约束问题：

$$
\min_{x\in\mathbb{R}^n} f(x).
$$

此时若 $f$ 可微，局部极小点通常满足一阶条件：

$$
\nabla f(x^\star)=0.
$$

但现实问题往往不是“任意 $x$ 都可以取”，而是必须满足预算、资源、等式关系、上下界、非负性等限制。于是问题变成：

$$
\begin{aligned}
\min_{x\in C}\quad & f(x)\\
\text{s.c.}\quad & g_i(x)\le 0,\quad i=1,\dots,p,\\
& h_j(x)=0,\quad j=1,\dots,q.
\end{aligned}
$$

本章的核心问题是：

> 当最优点 $x^\star$ 落在约束集合 $C$ 上时，怎样写出类似 $\nabla f(x^\star)=0$ 的必要条件？

答案分两层：

1. 只有等式约束时，用 **Lagrange 乘子法**；
2. 有不等式约束时，用 **Kuhn-Tucker / Karush-Kuhn-Tucker 条件**。

本讲主线：

1. 约束优化问题的存在性与唯一性；
2. 等式约束下的可行方向；
3. 线性等式约束的 Lagrange 乘子；
4. 非线性等式约束、正则点与 Lagrange 定理；
5. 不等式约束、活跃约束与可行方向锥；
6. Kuhn-Tucker 条件；
7. 等式 + 不等式混合约束；
8. 约束规范；
9. Lagrangian 与 KKT 条件；
10. 凸问题中 KKT 的充分性。

## 1. 约束优化问题的形式

一般约束优化问题可写成：

$$
\begin{aligned}
\min_{x\in\mathbb{R}^n}\quad & f(x)\\
\text{s.c.}\quad & g_i(x)\le 0,\quad i=1,\dots,p,\\
& h_j(x)=0,\quad j=1,\dots,q.
\end{aligned}
$$

其中：

- $f:\mathbb{R}^n\to\mathbb{R}$ 是目标函数；
- $g_i:\mathbb{R}^n\to\mathbb{R}$ 是不等式约束；
- $h_j:\mathbb{R}^n\to\mathbb{R}$ 是等式约束；
- 可行域为

$$
C=
\left\{
x\in\mathbb{R}^n:
g_i(x)\le 0,\ i=1,\dots,p,\quad
h_j(x)=0,\ j=1,\dots,q
\right\}.
$$

因此约束优化问题就是：

$$
\min_{x\in C} f(x).
$$

这里与无约束问题最大的不同是：即使 $\nabla f(x^\star)\ne 0$，$x^\star$ 仍然可能是约束最优点。原因是下降方向可能会离开可行域。

例如在区间 $[0,+\infty)$ 上最小化：

$$
f(x)=x.
$$

最优点是 $x^\star=0$，但：

$$
f'(0)=1\ne 0.
$$

因为向左走会让函数变小，但向左走不可行。约束优化的一阶条件本质上是在说：

> 在所有可行方向上，不能再下降。

## 2. 存在性

约束优化问题首先要问：最小值是否一定存在？

设 $f:\mathbb{R}^n\to\mathbb{R}$ 连续。

若可行集 $C$ 是紧集，也就是闭且有界，则 $f$ 在 $C$ 上达到最小值：

$$
\exists x^\star\in C,\qquad
f(x^\star)=\min_{x\in C} f(x).
$$

这是 Weierstrass 定理在约束集合上的直接应用。

如果 $C$ 不是有界的，还可以用 coercive 条件保证存在性。若 $C$ 闭，且：

$$
\lim_{\|x\|\to+\infty} f(x)=+\infty,
$$

则 $f$ 在 $C$ 上也达到最小值。

直观理解：coercive 表示函数在无穷远处会变得非常大，所以最小点不可能跑到无穷远。于是可以把搜索限制在一个足够大的闭球内，再利用紧性得到最小点。

## 3. 唯一性

如果 $f$ 严格凸，且可行集 $C$ 凸，则约束优化问题至多有一个最优点。

也就是说，如果存在最优点，则它唯一。

证明思路与无约束凸优化完全一样。假设有两个不同最优点 $x_1^\star,x_2^\star\in C$，且：

$$
f(x_1^\star)=f(x_2^\star)=\min_{x\in C} f(x).
$$

由于 $C$ 凸，对任意 $\lambda\in(0,1)$：

$$
\tilde{x}
=
\lambda x_1^\star+(1-\lambda)x_2^\star
\in C.
$$

由于 $f$ 严格凸：

$$
f(\tilde{x})
<
\lambda f(x_1^\star)+(1-\lambda)f(x_2^\star)
=
\min_{x\in C} f(x),
$$

矛盾。因此最优点唯一。

## 4. 等式约束问题

先考虑只有等式约束的情形：

$$
\begin{aligned}
\min_{x\in\mathbb{R}^n}\quad & f(x)\\
\text{s.c.}\quad & h(x)=0,
\end{aligned}
$$

其中：

$$
h(x)=
\begin{pmatrix}
h_1(x)\\
\vdots\\
h_q(x)
\end{pmatrix}.
$$

可行域为：

$$
C=\{x\in\mathbb{R}^n:h(x)=0\}.
$$

等式约束的几何含义是：可行点必须落在某个曲面或流形上。最优点处不要求 $\nabla f(x^\star)=0$，而要求 $\nabla f(x^\star)$ 与可行曲面的切空间正交。

## 5. 线性等式约束

先看线性等式约束：

$$
\begin{aligned}
\min_{x\in\mathbb{R}^n}\quad & f(x)\\
\text{s.c.}\quad & Ax-b=0,
\end{aligned}
$$

其中：

$$
A\in\mathbb{R}^{q\times n},\qquad b\in\mathbb{R}^q.
$$

可行集为：

$$
C=\{x\in\mathbb{R}^n:Ax=b\}.
$$

### 5.1 可行方向

方向 $d\in\mathbb{R}^n$ 称为 $x\in C$ 处的可行方向，如果存在 $\alpha>0$，使得：

$$
x+td\in C,\qquad \forall t\in[-\alpha,\alpha].
$$

因为 $x\in C$，所以 $Ax=b$。若 $x+td$ 也要在 $C$ 中，则：

$$
A(x+td)=b.
$$

展开得：

$$
Ax+tAd=b.
$$

由于 $Ax=b$，所以：

$$
tAd=0.
$$

因此线性等式约束下的可行方向满足：

$$
Ad=0.
$$

也就是说：

$$
d\in\ker(A).
$$

### 5.2 最优点的一阶条件

若 $x^\star$ 是局部最优点，那么沿任何可行方向 $d\in\ker(A)$ 都不能下降。

于是对任意 $d\in\ker(A)$：

$$
\left\langle \nabla f(x^\star),d\right\rangle=0.
$$

这说明：

$$
\nabla f(x^\star)\in \ker(A)^\perp.
$$

线性代数中有：

$$
\ker(A)^\perp=\operatorname{Im}(A^\top).
$$

因此存在 $\lambda\in\mathbb{R}^q$，使得：

$$
\nabla f(x^\star)=-A^\top\lambda.
$$

也就是：

$$
\nabla f(x^\star)+A^\top\lambda=0.
$$

这就是线性等式约束下的 Lagrange 乘子条件。

如果 $A$ 满秩：

$$
\operatorname{rank}(A)=q,
$$

则乘子 $\lambda$ 唯一。

## 6. Lagrange 函数

对线性等式约束问题：

$$
\begin{aligned}
\min_x\quad & f(x)\\
\text{s.c.}\quad & Ax-b=0,
\end{aligned}
$$

定义 Lagrange 函数：

$$
\mathcal{L}(x,\lambda)
=
f(x)+\lambda^\top(Ax-b).
$$

对 $x$ 求梯度：

$$
\nabla_x\mathcal{L}(x,\lambda)
=
\nabla f(x)+A^\top\lambda.
$$

因此一阶必要条件可以写成：

$$
\begin{cases}
\nabla_x\mathcal{L}(x^\star,\lambda^\star)=0,\\
Ax^\star-b=0.
\end{cases}
$$

第一行是 stationarity，第二行是 primal feasibility。

### 6.1 例子：点到仿射平面的投影

考虑问题：

$$
\begin{aligned}
\min_{x\in\mathbb{R}^n}\quad
& \frac12\|x-x_0\|^2\\
\text{s.c.}\quad
& Ax=b.
\end{aligned}
$$

这里 $x_0$ 是给定点，要求 $x_0$ 到平面 $Ax=b$ 的投影。

目标函数梯度为：

$$
\nabla f(x)=x-x_0.
$$

Lagrange 条件为：

$$
\begin{cases}
x^\star-x_0+A^\top\lambda^\star=0,\\
Ax^\star=b.
\end{cases}
$$

由第一式：

$$
x^\star=x_0-A^\top\lambda^\star.
$$

代入约束：

$$
A(x_0-A^\top\lambda^\star)=b.
$$

于是：

$$
AA^\top\lambda^\star=Ax_0-b.
$$

若 $A$ 满行秩，则 $AA^\top$ 可逆：

$$
\lambda^\star=(AA^\top)^{-1}(Ax_0-b).
$$

所以：

$$
x^\star
=
x_0-A^\top(AA^\top)^{-1}(Ax_0-b).
$$

也可写为：

$$
x^\star
=
\left(I-A^\top(AA^\top)^{-1}A\right)x_0
+A^\top(AA^\top)^{-1}b.
$$

这个公式说明：Lagrange 乘子法不仅给出必要条件，还能在二次目标 + 线性约束中直接算出解。

## 7. 非线性等式约束

现在考虑：

$$
\begin{aligned}
\min_{x\in\mathbb{R}^n}\quad & f(x)\\
\text{s.c.}\quad & h(x)=0,
\end{aligned}
$$

其中 $h:\mathbb{R}^n\to\mathbb{R}^q$ 可微。

约束集合为：

$$
C=\{x\in\mathbb{R}^n:h(x)=0\}.
$$

非线性等式约束下，不能简单用 $x+td\in C$ 描述所有可行方向，因为曲面可能是弯的。更自然的定义是通过可行曲线。

### 7.1 可行曲线与切方向

设 $x^\star\in C$。若存在一条曲线 $x(t)$，满足：

$$
\begin{cases}
x(t)\in C,\qquad t\in[-\alpha,\alpha],\\
x(0)=x^\star,\\
x'(0)=d,
\end{cases}
$$

则称 $d$ 是 $x^\star$ 处的可行方向。

因为 $x(t)\in C$，所以：

$$
h_j(x(t))=0,\qquad j=1,\dots,q.
$$

对 $t$ 求导，在 $t=0$ 处得到：

$$
\left\langle \nabla h_j(x^\star),d\right\rangle=0,
\qquad j=1,\dots,q.
$$

因此所有可行方向都满足：

$$
J_h(x^\star)^\top d=0.
$$

这里 $J_h(x^\star)$ 的列向量为各个约束梯度：

$$
J_h(x^\star)=
\begin{bmatrix}
\nabla h_1(x^\star)&\cdots&\nabla h_q(x^\star)
\end{bmatrix}.
$$

### 7.2 正则点

点 $x^\star$ 称为等式约束 $h(x)=0$ 的正则点，如果：

1. $h(x^\star)=0$；
2. 约束梯度 $\nabla h_1(x^\star),\dots,\nabla h_q(x^\star)$ 线性无关。

等价地：

$$
\operatorname{rank}J_h(x^\star)=q.
$$

正则性的重要性在于：它保证线性化约束给出的切空间是正确的。

在正则点处：

$$
d\text{ 是可行切方向}
\quad\Longleftrightarrow\quad
J_h(x^\star)^\top d=0.
$$

如果没有正则性，线性化约束可能给出太大的方向集合，从而让 Lagrange 条件失效。

## 8. Lagrange 定理：非线性等式约束

设 $x^\star$ 是正则点，并且是等式约束问题的局部最优点：

$$
f(x^\star)\le f(x),\qquad \forall x\in C
$$

在 $x^\star$ 附近成立。

则存在唯一的乘子 $\lambda\in\mathbb{R}^q$，使得：

$$
\nabla f(x^\star)+J_h(x^\star)\lambda=0.
$$

等价地：

$$
\nabla f(x^\star)
+
\sum_{j=1}^q
\lambda_j\nabla h_j(x^\star)
=0.
$$

这就是等式约束的 Lagrange 条件。

### 8.1 几何理解

在约束曲面 $C$ 上，最优点处沿任何切方向都不能下降。因此：

$$
\left\langle \nabla f(x^\star),d\right\rangle=0
$$

对所有切方向 $d$ 成立。

也就是说，$\nabla f(x^\star)$ 垂直于切空间。

而切空间的法向空间由约束梯度张成：

$$
\operatorname{span}\{\nabla h_1(x^\star),\dots,\nabla h_q(x^\star)\}.
$$

所以 $\nabla f(x^\star)$ 必须是这些约束梯度的线性组合：

$$
\nabla f(x^\star)
=
-
\sum_{j=1}^q
\lambda_j\nabla h_j(x^\star).
$$

## 9. 不等式约束问题

现在考虑只有不等式约束：

$$
\begin{aligned}
\min_{x\in\mathbb{R}^n}\quad & f(x)\\
\text{s.c.}\quad & g_i(x)\le 0,\qquad i=1,\dots,p.
\end{aligned}
$$

可行集为：

$$
C=\{x\in\mathbb{R}^n:g_i(x)\le 0,\ i=1,\dots,p\}.
$$

不等式约束与等式约束的关键区别是：在最优点处，有些约束可能不起作用。

## 10. 活跃约束

对不等式约束：

$$
g_i(x)\le 0,
$$

若在点 $x^\star$ 处：

$$
g_i(x^\star)<0,
$$

则该约束是 inactive，即非活跃约束。

若：

$$
g_i(x^\star)=0,
$$

则该约束是 active，即活跃约束或饱和约束。

记活跃约束指标集为：

$$
A(x^\star)=
\{i\in\{1,\dots,p\}:g_i(x^\star)=0\}.
$$

非活跃约束在局部不影响可行方向，因为它还有余量；真正限制移动方向的是活跃约束。

## 11. 不等式约束下的可行方向

若 $d$ 是 $x^\star$ 处的可行方向，则对所有活跃约束 $i\in A(x^\star)$，必须有：

$$
\left\langle \nabla g_i(x^\star),d\right\rangle\le 0.
$$

原因来自一阶展开。对活跃约束有：

$$
g_i(x^\star)=0.
$$

若 $x^\star+td$ 可行，则：

$$
g_i(x^\star+td)\le 0.
$$

Taylor 展开：

$$
g_i(x^\star+td)
=
g_i(x^\star)
+t\left\langle \nabla g_i(x^\star),d\right\rangle
+o(t).
$$

由于 $g_i(x^\star)=0$，若 $t>0$ 很小还要保持 $g_i(x^\star+td)\le 0$，就必须有：

$$
\left\langle \nabla g_i(x^\star),d\right\rangle\le 0.
$$

## 12. 可行方向锥

不等式约束下，可行方向通常不是一个线性空间，而是一个锥。

定义可行方向锥：

$$
C_{\mathrm{ad}}(x^\star)
=
\{d:\exists\text{ 可行曲线 }x(t),\ x(0)=x^\star,\ x'(0)=d\}.
$$

线性化得到的方向集合为：

$$
L(x^\star)
=
\left\{
d\in\mathbb{R}^n:
\left\langle \nabla g_i(x^\star),d\right\rangle\le 0,\quad
i\in A(x^\star)
\right\}.
$$

一般有：

$$
C_{\mathrm{ad}}(x^\star)\subseteq L(x^\star).
$$

但反过来不一定成立。要让线性化方向真正代表可行方向，需要正则性或约束规范。

## 13. 不等式约束的正则点

课件中给出的正则性思想是：在 $x^\star$ 处，活跃约束的梯度应该线性无关。

即：

$$
\{\nabla g_i(x^\star):i\in A(x^\star)\}
$$

线性无关。

在这种正则性下，线性化条件：

$$
\left\langle \nabla g_i(x^\star),d\right\rangle\le 0,\qquad i\in A(x^\star)
$$

可以正确描述局部可行方向，从而可以推出 Kuhn-Tucker 条件。

## 14. Kuhn-Tucker 条件：只有不等式约束

设 $x^\star$ 是正则点，并且是问题：

$$
\begin{aligned}
\min_x\quad & f(x)\\
\text{s.c.}\quad & g_i(x)\le 0,\quad i=1,\dots,p
\end{aligned}
$$

的局部最优点。

则存在乘子 $\mu_i$，使得：

$$
\nabla f(x^\star)
+
\sum_{i=1}^p
\mu_i\nabla g_i(x^\star)
=0,
$$

并且：

$$
\mu_i\ge 0,\qquad i=1,\dots,p,
$$

以及：

$$
\mu_i g_i(x^\star)=0,\qquad i=1,\dots,p.
$$

这三类条件分别称为：

1. stationarity：驻点条件；
2. dual feasibility：对偶可行性；
3. complementarity：互补松弛。

再加上原约束：

$$
g_i(x^\star)\le 0,
$$

就是完整的不等式约束一阶必要条件。

### 14.1 为什么乘子非负

考虑约束 $g_i(x)\le 0$。若 $g_i$ 活跃，则可行方向必须满足：

$$
\left\langle \nabla g_i(x^\star),d\right\rangle\le 0.
$$

如果乘子 $\mu_i<0$，则 stationarity 中的项 $\mu_i\nabla g_i(x^\star)$ 会把目标梯度推向错误的一侧，从而存在可行方向让目标下降，这与局部最优矛盾。

因此不等式约束的乘子必须满足：

$$
\mu_i\ge 0.
$$

这与等式约束不同。等式约束的乘子 $\lambda_j$ 没有符号限制，因为等式约束两侧都不能违反。

### 14.2 互补松弛的含义

互补松弛条件是：

$$
\mu_i g_i(x^\star)=0.
$$

因为：

$$
\mu_i\ge 0,\qquad g_i(x^\star)\le 0.
$$

该条件意味着：

- 若 $g_i(x^\star)<0$，约束非活跃，则必须有 $\mu_i=0$；
- 若 $\mu_i>0$，则必须有 $g_i(x^\star)=0$，约束活跃。

直观理解：只有真正卡住最优点的约束，才可能拥有非零乘子。

## 15. 用松弛变量理解不等式约束

对约束：

$$
g_i(x)\le 0,
$$

可以引入松弛变量 $s_i\ge 0$，写成：

$$
g_i(x)+s_i=0.
$$

如果 $g_i(x)<0$，则 $s_i>0$，说明约束有余量；如果 $g_i(x)=0$，则 $s_i=0$，说明约束被压紧。

课件中用松弛变量说明：不等式约束问题可以转化为等式约束问题，但真正难点在于判断哪些约束最终是活跃的。

KKT 条件正是把“判断活跃约束”的逻辑编码进：

$$
\mu_i g_i(x^\star)=0.
$$

## 16. 混合约束问题

最一般的情形同时有等式约束和不等式约束：

$$
\begin{aligned}
\min_{x\in\mathbb{R}^n}\quad & f(x)\\
\text{s.c.}\quad & g_i(x)\le 0,\quad i=1,\dots,p,\\
& h_j(x)=0,\quad j=1,\dots,q.
\end{aligned}
$$

可行集为：

$$
C=
\left\{
x\in\mathbb{R}^n:
g_i(x)\le 0,\ i=1,\dots,p,\quad
h_j(x)=0,\ j=1,\dots,q
\right\}.
$$

这时 Lagrange 函数定义为：

$$
\mathcal{L}(x,\mu,\lambda)
=
f(x)
+
\sum_{i=1}^p\mu_i g_i(x)
+
\sum_{j=1}^q\lambda_j h_j(x).
$$

其中：

- $\mu_i$ 对应不等式约束，要求 $\mu_i\ge 0$；
- $\lambda_j$ 对应等式约束，没有符号限制。

## 17. 约束规范

KKT 条件不是无条件成立的。需要某种 constraint qualification，中文可称为**约束规范**。

约束规范的作用是：

> 保证约束的线性化能够正确描述局部可行方向，从而让乘子条件成立。

定义线性化锥：

$$
L(x)
=
\left\{
d\in\mathbb{R}^n:
\left\langle \nabla g_i(x),d\right\rangle\le 0,\ i\in A(x),
\quad
\left\langle \nabla h_j(x),d\right\rangle=0,\ j=1,\dots,q
\right\}.
$$

这里：

$$
A(x)=\{i:g_i(x)=0\}.
$$

课件中列出的常见约束规范包括：

1. **Affine qualification**：若 $g,h$ 都是仿射约束，则可行方向锥与线性化锥一致；
2. **Slater condition**：凸问题中，如果存在严格可行点，即所有不等式严格满足且等式满足，则约束规范成立；
3. **LICQ**：活跃不等式约束梯度与等式约束梯度线性无关；
4. **Mangasarian-Fromovitz qualification**：一种比 LICQ 更一般的正则条件。

本课程中最常用、最容易检查的是 LICQ：

$$
\{\nabla g_i(x^\star):i\in A(x^\star)\}
\cup
\{\nabla h_j(x^\star):j=1,\dots,q\}
$$

线性无关。

如果约束不满足规范，可能出现这样的情况：$x^\star$ 明明是局部最优点，但找不到满足 KKT 的乘子。

## 18. KKT 条件

假设 $x^\star$ 满足约束规范，并且是局部最优点。若 $f,g_i,h_j$ 在 $x^\star$ 可微，则存在：

$$
\mu^\star\in\mathbb{R}_+^p,\qquad
\lambda^\star\in\mathbb{R}^q,
$$

使得以下条件成立。

### 18.1 原始可行性

$$
g_i(x^\star)\le 0,\qquad i=1,\dots,p,
$$

$$
h_j(x^\star)=0,\qquad j=1,\dots,q.
$$

这只是说 $x^\star$ 必须是可行点。

### 18.2 对偶可行性

$$
\mu_i^\star\ge 0,\qquad i=1,\dots,p.
$$

不等式约束的乘子必须非负。

### 18.3 驻点条件

$$
\nabla_x\mathcal{L}(x^\star,\mu^\star,\lambda^\star)=0.
$$

展开为：

$$
\nabla f(x^\star)
+
\sum_{i=1}^p
\mu_i^\star\nabla g_i(x^\star)
+
\sum_{j=1}^q
\lambda_j^\star\nabla h_j(x^\star)
=0.
$$

这表示目标函数梯度可以被约束梯度线性抵消。

### 18.4 互补松弛

$$
\mu_i^\star g_i(x^\star)=0,\qquad i=1,\dots,p.
$$

这表示每个不等式约束满足二选一：

- 约束不活跃：$g_i(x^\star)<0$，于是 $\mu_i^\star=0$；
- 乘子非零：$\mu_i^\star>0$，于是 $g_i(x^\star)=0$。

### 18.5 KKT 系统汇总

完整 KKT 条件可写成：

$$
\begin{cases}
g_i(x^\star)\le 0,\quad i=1,\dots,p,\\
h_j(x^\star)=0,\quad j=1,\dots,q,\\
\mu_i^\star\ge 0,\quad i=1,\dots,p,\\
\nabla f(x^\star)
+\displaystyle\sum_{i=1}^p\mu_i^\star\nabla g_i(x^\star)
+\displaystyle\sum_{j=1}^q\lambda_j^\star\nabla h_j(x^\star)=0,\\
\mu_i^\star g_i(x^\star)=0,\quad i=1,\dots,p.
\end{cases}
$$

满足 KKT 条件的点称为 KKT 点或约束优化问题的驻点。

注意：在一般非凸问题中，KKT 点不一定是最小点，只是候选点。

## 19. 二阶必要条件

若 $f,g_i,h_j$ 在 $x^\star$ 二阶可微，则在满足 KKT 的基础上，还可以写二阶必要条件。

定义 Lagrangian 对 $x$ 的 Hessian：

$$
H_{\mathcal{L}}(x^\star,\mu^\star,\lambda^\star)
=
\nabla_{xx}^2\mathcal{L}(x^\star,\mu^\star,\lambda^\star).
$$

在临界切空间中，对所有方向 $d$，需要：

$$
d^\top H_{\mathcal{L}}(x^\star,\mu^\star,\lambda^\star)d\ge 0.
$$

课件中给出的切空间可写为：

$$
T(x^\star)
=
\left\{
d\in\mathbb{R}^n:
\left\langle \nabla g_i(x^\star),d\right\rangle=0,\ i\in A(x^\star),
\quad
\left\langle \nabla h_j(x^\star),d\right\rangle=0,\ j=1,\dots,q
\right\}.
$$

这与无约束问题中的二阶必要条件类似：

$$
H_f(x^\star)\succeq 0.
$$

只不过现在 Hessian 要看 Lagrangian，并且只需要在可行切方向上半正定。

## 20. 凸问题中的充分性

如果问题是凸优化问题：

- $f$ 是凸函数；
- 每个 $g_i$ 是凸函数；
- 每个等式约束 $h_j$ 是仿射函数；
- 可行域满足适当约束规范。

那么 KKT 条件不仅是必要条件，也是充分条件。

也就是说，如果存在 $x^\star,\mu^\star,\lambda^\star$ 满足 KKT 条件，则：

$$
x^\star\in\arg\min_{x\in C} f(x).
$$

证明思路如下。

由凸性：

$$
f(x)-f(x^\star)
\ge
\left\langle \nabla f(x^\star),x-x^\star\right\rangle.
$$

由 stationarity：

$$
\nabla f(x^\star)
=
-
\sum_{i=1}^p\mu_i^\star\nabla g_i(x^\star)
-
\sum_{j=1}^q\lambda_j^\star\nabla h_j(x^\star).
$$

代入得：

$$
f(x)-f(x^\star)
\ge
-
\sum_{i=1}^p
\mu_i^\star
\left\langle \nabla g_i(x^\star),x-x^\star\right\rangle
-
\sum_{j=1}^q
\lambda_j^\star
\left\langle \nabla h_j(x^\star),x-x^\star\right\rangle.
$$

由于 $h_j$ 仿射且 $x,x^\star$ 都满足等式约束：

$$
\left\langle \nabla h_j(x^\star),x-x^\star\right\rangle=0.
$$

由于 $g_i$ 凸：

$$
g_i(x)\ge
g_i(x^\star)
+
\left\langle \nabla g_i(x^\star),x-x^\star\right\rangle.
$$

所以：

$$
-
\left\langle \nabla g_i(x^\star),x-x^\star\right\rangle
\ge
g_i(x^\star)-g_i(x).
$$

结合 $\mu_i^\star\ge 0$：

$$
f(x)-f(x^\star)
\ge
\sum_{i=1}^p\mu_i^\star(g_i(x^\star)-g_i(x)).
$$

又因为互补松弛：

$$
\mu_i^\star g_i(x^\star)=0,
$$

且 $x$ 可行，所以：

$$
g_i(x)\le 0.
$$

因此：

$$
-\mu_i^\star g_i(x)\ge 0.
$$

从而：

$$
f(x)-f(x^\star)\ge 0.
$$

所以：

$$
f(x)\ge f(x^\star),\qquad \forall x\in C.
$$

这说明 $x^\star$ 是全局最优点。

## 21. 解约束优化题的一般流程

对于课程中的计算题，可以按以下流程做。

### 21.1 第一步：写标准形式

把问题统一写成：

$$
g_i(x)\le 0,\qquad h_j(x)=0.
$$

注意符号方向很重要。例如：

$$
x_1\ge 0
$$

应写成：

$$
-x_1\le 0.
$$

如果写反，乘子符号和 KKT 条件都会错。

### 21.2 第二步：判断存在性

常用方法：

- 可行集闭且有界；
- 目标函数 coercive 且可行集闭；
- 题目本身给出紧约束，例如球、盒子、单纯形。

### 21.3 第三步：列 KKT 条件

写出 Lagrangian：

$$
\mathcal{L}(x,\mu,\lambda)
=
f(x)
+
\sum_i\mu_i g_i(x)
+
\sum_j\lambda_j h_j(x).
$$

然后列：

$$
\nabla_x\mathcal{L}=0,
$$

$$
g_i(x)\le 0,\qquad h_j(x)=0,
$$

$$
\mu_i\ge 0,
$$

$$
\mu_i g_i(x)=0.
$$

### 21.4 第四步：按活跃集分类

互补松弛意味着每个不等式约束有两种情况：

1. $g_i(x)<0$，则 $\mu_i=0$；
2. $g_i(x)=0$，则 $\mu_i$ 可以非零。

如果不等式约束少，可以枚举活跃集。

例如两个不等式约束时，可能活跃集为：

$$
\varnothing,\quad \{1\},\quad \{2\},\quad \{1,2\}.
$$

每种情况解 stationarity，然后检查：

- 原始可行性；
- 乘子非负；
- 活跃/非活跃假设是否一致。

### 21.5 第五步：判断是否全局最优

如果问题是凸问题，并且找到的点满足 KKT，则它是全局最优点。

如果问题非凸，KKT 只给候选点，还需要比较函数值、检查边界、或使用二阶条件。

## 22. 简单例子：二次目标 + 三角形约束

考虑：

$$
\begin{aligned}
\min_{x\in\mathbb{R}^2}\quad
& \frac12\|x-x_0\|^2\\
\text{s.c.}\quad
& x_1\ge 0,\\
& x_2\ge 0,\\
& x_1+x_2\le 1,
\end{aligned}
$$

其中：

$$
x_0=\left(1,\frac12\right).
$$

标准形式为：

$$
g_1(x)=-x_1\le 0,
$$

$$
g_2(x)=-x_2\le 0,
$$

$$
g_3(x)=x_1+x_2-1\le 0.
$$

目标函数梯度为：

$$
\nabla f(x)=x-x_0.
$$

从图形上看，最优点应落在边界：

$$
x_1+x_2=1,
$$

且 $x_1>0,x_2>0$，所以猜测活跃集：

$$
A(x^\star)=\{3\}.
$$

于是只保留 $\mu_3$：

$$
x-x_0+\mu_3
\begin{pmatrix}
1\\
1
\end{pmatrix}
=0.
$$

也就是：

$$
\begin{cases}
x_1-1+\mu_3=0,\\
x_2-\frac12+\mu_3=0,\\
x_1+x_2=1.
\end{cases}
$$

由前两式：

$$
x_1=1-\mu_3,
$$

$$
x_2=\frac12-\mu_3.
$$

代入 $x_1+x_2=1$：

$$
\frac32-2\mu_3=1.
$$

所以：

$$
\mu_3=\frac14.
$$

从而：

$$
x_1^\star=\frac34,\qquad
x_2^\star=\frac14.
$$

检查：

$$
x_1^\star>0,\qquad x_2^\star>0,
$$

所以 $g_1,g_2$ 确实不活跃。

并且：

$$
\mu_3=\frac14\ge 0.
$$

因此该点满足 KKT。由于这是凸二次目标 + 线性约束问题，所以它是全局最优解。

## 23. 常见错误

### 23.1 忘记把约束写成 $g_i(x)\le 0$

KKT 里 $\mu_i\ge 0$ 是和 $g_i(x)\le 0$ 配套的。

如果原题是：

$$
x_i\ge 0,
$$

必须改写为：

$$
-x_i\le 0.
$$

否则乘子符号会反。

### 23.2 把所有不等式都当成等式

只有活跃约束满足：

$$
g_i(x^\star)=0.
$$

非活跃约束满足：

$$
g_i(x^\star)<0,
$$

其乘子为：

$$
\mu_i=0.
$$

### 23.3 以为 KKT 一定充分

一般非凸问题中，KKT 只是必要条件。它给出候选点，不保证全局最优。

只有在凸优化问题中，配合约束规范，KKT 才通常成为充分条件。

### 23.4 忽略约束规范

若约束不正则，最优点可能不满足 KKT。

所以严格说，使用 KKT 作为必要条件之前，要说明约束规范成立，例如 LICQ 或 Slater 条件。

## 24. 本章总结

无约束优化的一阶条件是：

$$
\nabla f(x^\star)=0.
$$

等式约束下，它变成：

$$
\nabla f(x^\star)
+
\sum_{j=1}^q
\lambda_j^\star\nabla h_j(x^\star)
=0.
$$

不等式约束下，它进一步变成 KKT 条件：

$$
\begin{cases}
g_i(x^\star)\le 0,\quad h_j(x^\star)=0,\\
\mu_i^\star\ge 0,\\
\nabla f(x^\star)
+\sum_i\mu_i^\star\nabla g_i(x^\star)
+\sum_j\lambda_j^\star\nabla h_j(x^\star)=0,\\
\mu_i^\star g_i(x^\star)=0.
\end{cases}
$$

本章最重要的直觉是：

> 在约束最优点处，目标函数的下降趋势会被活跃约束的法向量抵消。

等式约束的法向量用 $\lambda_j$ 线性组合；不等式约束只有活跃约束有作用，并且对应乘子 $\mu_i$ 必须非负。

因此，求解约束优化题时要始终围绕三个问题：

1. 哪些点可行？
2. 哪些约束活跃？
3. 目标梯度能否由活跃约束梯度抵消？

如果问题是凸的，那么满足 KKT 的点就是全局最优点；如果问题非凸，则 KKT 点只是需要进一步筛选的候选点。
