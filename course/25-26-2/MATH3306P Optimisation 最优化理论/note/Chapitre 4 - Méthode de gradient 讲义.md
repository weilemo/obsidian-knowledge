# Chapitre 4：Méthode de gradient

来源：

- [[../Materials/Slides/Slides_Chp4.pdf|Slides_Chp4.pdf]]
- [[../Materials/General/Poly_Optimisation.pdf|Poly_Optimisation.pdf]]

本章讨论**无约束凸优化中的梯度法**。上一章主要回答“什么样的点可能是最优点”，本章开始回答“怎样通过算法找到这个点”。

本讲主线：

1. 无约束凸优化问题；
2. 一般下降算法；
3. 下降方向与负梯度方向；
4. 步长选择：固定步长、最优步长、Armijo 回溯；
5. 梯度下降算法；
6. 强凸条件下的线性收敛；
7. 步长对收敛/发散的影响；
8. Python 实现思路。

## 1. 问题背景

本章研究无约束优化问题：

$$
\min_{x\in\mathbb{R}^n} f(x),
$$

其中通常假设：

- $f:\mathbb{R}^n\to\mathbb{R}$；
- $f$ 是凸函数；
- $f$ 至少一阶可微；
- 为了保证存在唯一最小点和收敛性，常进一步假设 $f$ 强凸。

如果 $f$ 可微且凸，则最优点 $x^\star$ 满足：

$$
\nabla f(x^\star)=0.
$$

因此，求解优化问题可以理解为求解非线性方程组：

$$
\nabla f(x)=0.
$$

但直接解这个方程组通常很难，所以我们使用迭代算法逐步逼近 $x^\star$。

## 2. 一般下降算法

下降算法的基本思想是：从一个初始点 $x_0$ 出发，每次找一个能让函数值下降的方向 $d_k$，再沿着这个方向走一小步。

一般形式为：

$$
x_{k+1}=x_k+\delta_k d_k,
$$

其中：

- $d_k$ 是第 $k$ 步的下降方向；
- $\delta_k>0$ 是步长；
- 希望满足

$$
f(x_{k+1})<f(x_k).
$$

算法框架：

```text
给定初始点 x0 和容差 ε
while ||∇f(xk)|| ≥ ε:
    1. 选择下降方向 dk
    2. 选择步长 δk，使 f(xk + δk dk) < f(xk)
    3. 更新 xk+1 = xk + δk dk
return xk
```

这里常用停止条件是：

$$
\|\nabla f(x_k)\|<\varepsilon.
$$

因为在无约束凸优化中，最优点满足 $\nabla f(x^\star)=0$。梯度范数越小，说明越接近驻点。

## 3. 下降方向

设 $f$ 在 $x$ 处可微，若方向 $d$ 满足：

$$
\langle \nabla f(x),d\rangle <0,
$$

则 $d$ 是 $x$ 处的严格下降方向。

原因来自一阶 Taylor 展开：

$$
f(x+td)
=
f(x)+t\langle \nabla f(x),d\rangle+o(t).
$$

当 $t>0$ 足够小时，如果内积为负，则：

$$
f(x+td)<f(x).
$$

## 4. 为什么负梯度是下降方向

梯度方向 $\nabla f(x)$ 是函数增长最快的方向，因此负梯度方向是函数下降最快的局部方向。

取：

$$
d=-\nabla f(x).
$$

则：

$$
\langle \nabla f(x),d\rangle
=
\langle \nabla f(x),-\nabla f(x)\rangle
=
-\|\nabla f(x)\|^2.
$$

只要 $\nabla f(x)\ne 0$，就有：

$$
-\|\nabla f(x)\|^2<0.
$$

所以负梯度方向一定是严格下降方向。

这就是梯度下降的核心：

$$
x_{k+1}=x_k-\delta_k\nabla f(x_k).
$$

## 5. 步长为什么重要

方向只告诉我们“往哪里走”，步长告诉我们“走多远”。

如果步长太小：

- 每次下降很少；
- 收敛非常慢；
- 需要很多迭代。

如果步长太大：

- 可能跨过最小点；
- 可能震荡；
- 甚至导致发散。

所以梯度法的核心难点之一就是选取合适的 $\delta_k$。

## 6. 固定步长

最简单的做法是固定步长：

$$
\delta_k=\delta,\qquad \forall k.
$$

于是算法变成：

$$
x_{k+1}=x_k-\delta\nabla f(x_k).
$$

固定步长的优点是简单，缺点是非常依赖 $\delta$ 的选择。

以函数：

$$
f(x,y)=x^2+100y^2
$$

为例，其 Hessian 为：

$$
H_f=
\begin{pmatrix}
2 & 0\\
0 & 200
\end{pmatrix}.
$$

这个函数在 $y$ 方向非常陡，在 $x$ 方向相对平缓。如果步长略大，沿 $y$ 方向就容易来回震荡甚至发散。讲义中指出，当步长大于约 $0.01$ 时，算法会发散。

## 7. 最优步长

一种理想选择是每一步都在当前下降方向上找到使函数值最小的步长：

$$
\delta_k^\star
=
\arg\min_{\delta>0} f(x_k+\delta d_k).
$$

这叫**最优步长**或**精确线搜索**。

如果 $d_k$ 是下降方向，最优步长满足一阶条件：

$$
\left\langle
\nabla f(x_k+\delta_k^\star d_k),
d_k
\right\rangle
=0.
$$

直观理解：沿着直线 $x_k+\delta d_k$ 看函数值，最优步长就是这条一维曲线的最低点；在最低点处，该一维函数对 $\delta$ 的导数为 $0$。

优点：

- 每一步都尽可能降低目标函数；
- 对某些问题收敛很快。

缺点：

- 每一步都要额外解一个一维优化问题；
- 对复杂函数不一定容易算。

## 8. Armijo 条件

当精确线搜索太难时，可以使用非精确线搜索。最常见的是 Armijo 条件。

给定当前位置 $x$、下降方向 $d$、步长 $t>0$，若：

$$
f(x+td)
\le
f(x)+\alpha t\langle \nabla f(x),d\rangle,
\qquad 0<\alpha<1,
$$

则称 $t$ 满足 Armijo 条件。

因为 $d$ 是下降方向，所以：

$$
\langle \nabla f(x),d\rangle<0.
$$

因此右边严格小于 $f(x)$。Armijo 条件不仅要求函数下降，还要求它下降得“足够多”。

它不是要求下降到最优，只是要求当前步长不能太差。

## 9. 回溯法

回溯法用于寻找满足 Armijo 条件的步长。

给定参数：

$$
0<\alpha<1,\qquad 0<\beta<1.
$$

通常从 $t=1$ 开始，如果不满足 Armijo 条件，就缩小步长：

$$
t\leftarrow \beta t.
$$

于是候选步长为：

$$
1,\ \beta,\ \beta^2,\ \beta^3,\dots
$$

直到某个步长满足：

$$
f(x+\beta^n d)
\le
f(x)+\alpha \beta^n\langle \nabla f(x),d\rangle.
$$

最终取：

$$
\delta_k=\beta^N.
$$

伪代码：

```text
t = 1
while f(x + t d) > f(x) + α t <∇f(x), d>:
    t = β t
return t
```

回溯法的直觉是：先尝试大胆走一步；如果发现走太远，就不断缩短步长，直到函数值下降得足够。

## 10. 为什么“不满足 Armijo”通常说明步长太大

设 $d$ 是下降方向：

$$
\langle \nabla f(x),d\rangle<0.
$$

当 $t$ 很小时，由 Taylor 展开：

$$
f(x+td)
=
f(x)+t\langle \nabla f(x),d\rangle+o(t).
$$

Armijo 右边是：

$$
f(x)+\alpha t\langle \nabla f(x),d\rangle.
$$

由于 $0<\alpha<1$ 且 $\langle \nabla f(x),d\rangle<0$，真实一阶下降量：

$$
t\langle \nabla f(x),d\rangle
$$

比 Armijo 要求的下降量更负。因此当 $t$ 足够小时，Armijo 条件一定会满足。

所以如果当前 $t$ 不满足 Armijo，通常不是因为步长太短，而是因为步长太长，导致实际函数值没有下降够，甚至上升。

## 11. 梯度下降算法

梯度下降是一般下降算法的特例，取：

$$
d_k=-\nabla f(x_k).
$$

于是：

$$
x_{k+1}=x_k+\delta_k d_k
=
x_k-\delta_k\nabla f(x_k).
$$

其中 $\delta_k$ 可以通过：

- 固定步长；
- 最优步长；
- Armijo 回溯法；

来选择。

完整算法：

```text
给定 x0, ε
while ||∇f(xk)|| ≥ ε:
    dk = -∇f(xk)
    用最优步长或回溯法选择 δk
    xk+1 = xk + δk dk
return xk
```

## 12. 强凸条件下的收敛

讲义中给出如下假设：存在常数 $0<m\le M$，使得对任意 $x,h$：

$$
m\|h\|^2
\le
\langle H_f(x)h,h\rangle
\le
M\|h\|^2.
$$

这个条件表示：

- Hessian 的最小特征值至少为 $m$；
- Hessian 的最大特征值至多为 $M$；
- 函数既强凸，又有 Lipschitz 梯度。

在这个条件下，梯度下降收敛到唯一最小点 $x^\star$，并且具有线性收敛速度：

$$
f(x_k)-f(x^\star)
\le
c^k\bigl(f(x_0)-f(x^\star)\bigr),
\qquad 0<c<1.
$$

线性收敛的意思是：每迭代一步，误差大约乘上一个小于 $1$ 的常数。

如果使用最优步长，讲义给出的收敛因子形式为：

$$
c=1-\frac{m}{M}.
$$

这里的比值：

$$
\kappa=\frac{M}{m}
$$

可以看作条件数。$\kappa$ 越大，函数越“狭长”，梯度法越慢。

## 13. 例子：二次最小二乘

讲义中的例子是最小化：

$$
f(x,y)
=
\frac12\left[
(x+y-4)^2
+
(2x+3y-7)^2
+
(4x+y-9)^2
\right].
$$

这是一个二次函数，也可以理解为最小二乘问题：

$$
\min_{x,y}
\frac12\|A z-b\|^2,
\qquad
z=
\begin{pmatrix}
x\\
y
\end{pmatrix}.
$$

其中：

$$
A=
\begin{pmatrix}
1 & 1\\
2 & 3\\
4 & 1
\end{pmatrix},
\qquad
b=
\begin{pmatrix}
4\\
7\\
9
\end{pmatrix}.
$$

梯度是：

$$
\nabla f(z)=A^\top(Az-b).
$$

课程代码中用 `sympy.diff` 计算偏导，再用：

$$
x\leftarrow x-\delta \frac{\partial f}{\partial x},
\qquad
y\leftarrow y-\delta \frac{\partial f}{\partial y}.
$$

固定步长 $\delta=0.01$ 时，迭代较多；用最优步长时，收敛更快。

## 14. 与机器学习的联系

Slides 中用机器学习引入梯度下降：训练模型本质上是在最小化误差函数。

例如监督学习中有：

- 输入特征；
- 模型预测；
- 真实标签；
- 损失函数。

训练过程就是求：

$$
\min_\theta L(\theta),
$$

其中 $\theta$ 是模型参数，$L(\theta)$ 是损失函数。

梯度下降更新为：

$$
\theta_{k+1}
=
\theta_k-\eta\nabla L(\theta_k).
$$

深度学习中的 SGD、Adam、RMSProp 等优化器，本质上都是梯度下降思想的变体。

## 15. 易错点

### 15.1 下降方向不是任意让函数下降的方向

在可微情形下，常用判断是：

$$
\langle \nabla f(x),d\rangle<0.
$$

只要这个内积为负，就保证足够小的步长会下降。

### 15.2 负梯度方向不等于直接到最优点的方向

负梯度只是局部最陡下降方向，不一定指向全局最小点。

在狭长椭圆形等高线中，负梯度方向可能导致“之”字形震荡。

### 15.3 步长大不一定更快

大步长可能：

- 快速接近最优点；
- 也可能跨过最优点；
- 更严重时会发散。

所以必须控制步长。

### 15.4 Armijo 不是找最优步长

Armijo 只是找一个“足够好”的步长，不保证这个步长在当前方向上最优。

## 16. 本章总结

本章最重要的公式是：

$$
x_{k+1}=x_k-\delta_k\nabla f(x_k).
$$

它由三部分组成：

1. 当前点 $x_k$；
2. 下降方向 $-\nabla f(x_k)$；
3. 步长 $\delta_k$。

梯度法的核心逻辑：

$$
\nabla f(x_k)\ne 0
\quad\Longrightarrow\quad
-\nabla f(x_k)\ \text{是下降方向}
\quad\Longrightarrow\quad
\text{沿该方向找合适步长}.
$$

若 $f$ 强凸且 Hessian 满足：

$$
mI\preceq H_f(x)\preceq MI,
$$

则梯度下降收敛到唯一最小点，并具有线性收敛速度。

实际使用时，最关键的是步长选择：

- 固定步长简单但敏感；
- 最优步长效果好但计算贵；
- Armijo 回溯法稳健，实践中常用。

