# Chapitre 2：Rappels

来源：[[PPT/Slides_Chp2.pdf|Slides_Chp2.pdf]]

本讲是最优化理论所需的基础回顾，内容分为四块：

1. 线性代数；
2. 拓扑；
3. 微分学；
4. 凸分析。

这些内容不是孤立的预备知识，而是后续讨论最优性条件、梯度法、牛顿法和凸优化时会反复使用的语言。

## 1. 线性代数：正定矩阵

设 $M\in\mathbb{R}^{n\times n}$ 是实对称矩阵。若 $M$ 满足：

$$
\forall x\in\mathbb{R}^n,\ x\ne 0,\qquad x^\top Mx>0,
$$

则称 $M$ 为**正定矩阵**，记作：

$$
M\succ 0.
$$

对于实对称矩阵，以下条件等价：

1. $M$ 正定；
2. $M$ 的所有特征值均为正：

$$
\lambda_i(M)>0,\qquad i=1,\dots,n;
$$

3. 双线性型

$$
(x,y)\mapsto x^\top My
$$

是 $\mathbb{R}^n$ 上的内积；

4. 存在可逆矩阵 $N\in\mathbb{R}^{n\times n}$，使得

$$
M=N^\top N.
$$

正定矩阵在优化中非常重要。二次函数

$$
f(x)=\frac12 x^\top Mx
$$

若 $M\succ 0$，则 $f$ 是严格凸函数，并且有唯一极小点。

## 2. 拓扑基础

本节默认工作在欧氏空间 $\mathbb{R}^n$ 中，使用欧氏范数：

$$
\|x\|=\sqrt{x_1^2+\cdots+x_n^2}
$$

以及欧氏内积：

$$
\langle x,y\rangle=x^\top y.
$$

### 2.1 开球与闭球

对 $x\in\mathbb{R}^n$ 和 $r>0$，以 $x$ 为中心、$r$ 为半径的开球定义为：

$$
B_O(x,r)=\{y\in\mathbb{R}^n:\|y-x\|<r\}.
$$

闭球定义为：

$$
B_F(x,r)=\{y\in\mathbb{R}^n:\|y-x\|\le r\}.
$$

直观上，开球不包含边界，闭球包含边界。

### 2.2 开集与闭集

集合 $O\subset\mathbb{R}^n$ 称为开集，如果：

$$
\forall x\in O,\ \exists r_x>0,\quad B_O(x,r_x)\subset O.
$$

也就是说，$O$ 中每一点附近都能放进一个足够小的开球。

集合 $F\subset\mathbb{R}^n$ 称为闭集，如果它的补集是开集：

$$
\mathbb{R}^n\setminus F \text{ is open}.
$$

开集的基本性质：

- $\varnothing$ 和 $\mathbb{R}^n$ 都是开集；
- 任意多个开集的并仍然是开集；
- 有限多个开集的交仍然是开集。

注意：无限多个开集的交不一定是开集。例如在 $\mathbb{R}$ 中：

$$
\bigcap_{n\in\mathbb{N}^*}\left(-\frac1n,1+\frac1n\right)=[0,1],
$$

而 $[0,1]$ 不是开集。

### 2.3 邻域

设 $a\in\mathbb{R}^n$。如果集合 $V$ 包含 $a$ 附近的某个开球，即：

$$
\exists \varepsilon>0,\quad B_O(a,\varepsilon)\subset V,
$$

则称 $V$ 是 $a$ 的一个邻域，记作 $V\in\mathcal{V}(a)$。

邻域有两个基本性质：

1. 有限交稳定：若 $V_1,\dots,V_k\in\mathcal{V}(a)$，则

$$
V_1\cap\cdots\cap V_k\in\mathcal{V}(a).
$$

2. 向上包含稳定：若 $V\in\mathcal{V}(a)$ 且 $V\subset W$，则

$$
W\in\mathcal{V}(a).
$$

邻域语言常用于定义局部极小值、连续性和可微性。

### 2.4 有界集

设 $A$ 是度量空间 $(\mathbb{R}^n,d)$ 的子集。若存在 $x\in\mathbb{R}^n$ 和 $r>0$，使得：

$$
A\subset B_O(x,r),
$$

则称 $A$ 是有界集。

等价地，非空集合 $A$ 有界当且仅当它的直径有限：

$$
\operatorname{diam}(A)
=\sup\{d(x,y):(x,y)\in A^2\}<+\infty.
$$

函数 $f:\Omega\to\mathbb{R}^n$ 称为有界函数，如果它的值域 $f(\Omega)$ 是有界集。

### 2.5 强制函数

设 $A\subset\mathbb{R}^n$ 是闭但无界的集合，$f:A\to\mathbb{R}$ 是连续函数。若：

$$
\lim_{\substack{\|x\|\to+\infty\\x\in A}} f(x)=+\infty,
$$

则称 $f$ 是**强制函数**，也称 coercive function。

等价地：

$$
\forall M>0,\ \exists N>0,\quad
\|x\|>N,\ x\in A\Longrightarrow f(x)>M.
$$

直观上，强制函数在无穷远处会趋向 $+\infty$。这在证明最小值存在时很有用：如果函数往远处走会变得很大，那么最小值不会“逃到无穷远”。

## 3. 微分学基础

设 $O\subset\mathbb{R}^n$ 是非空开集。

### 3.1 偏导数

设 $f:O\to\mathbb{R}^p$。如果固定除第 $j$ 个变量以外的其他变量后，一元函数

$$
t\mapsto f(x_1,\dots,x_{j-1},t,x_{j+1},\dots,x_n)
$$

在 $t=x_j$ 处可导，则称 $f$ 在 $x$ 处关于第 $j$ 个变量存在偏导数，记为：

$$
\frac{\partial f}{\partial x_j}(x)
\quad\text{or}\quad
\partial_j f(x).
$$

偏导数只观察坐标轴方向上的变化。

### 3.2 方向导数

给定非零方向 $v\in\mathbb{R}^n$。若极限存在，则 $f$ 在 $x$ 沿方向 $v$ 的方向导数定义为：

$$
\partial_v f(x)
=\lim_{t\to 0}\frac{f(x+tv)-f(x)}{t}.
$$

偏导数是方向导数的特例。若 $e_j$ 是第 $j$ 个标准基向量，则：

$$
\partial_j f(x)
=\partial_{e_j}f(x)
=\lim_{t\to 0}\frac{f(x+te_j)-f(x)}{t}.
$$

### 3.3 可微与微分

设 $x_0\in O$，函数 $f:O\to\mathbb{R}^p$。若存在一个线性映射：

$$
df_{x_0}\in\mathcal{L}(\mathbb{R}^n,\mathbb{R}^p),
$$

使得当 $h\to 0$ 且 $x_0+h\in O$ 时：

$$
f(x_0+h)
=f(x_0)+df_{x_0}(h)+o(\|h\|),
$$

则称 $f$ 在 $x_0$ 可微，$df_{x_0}$ 称为 $f$ 在 $x_0$ 的微分。

这个定义的含义是：在 $x_0$ 附近，$f$ 可以被一个线性函数一阶近似。

### 3.4 梯度

若 $f:O\to\mathbb{R}$ 在 $a\in O$ 可微，则 $f$ 在 $a$ 处的梯度定义为：

$$
\nabla f(a)
=
\begin{pmatrix}
\dfrac{\partial f}{\partial x_1}(a)\\
\vdots\\
\dfrac{\partial f}{\partial x_n}(a)
\end{pmatrix}
\in\mathbb{R}^n.
$$

对标量函数，微分可写成：

$$
df_a(h)=\langle \nabla f(a),h\rangle.
$$

梯度的方向是函数局部增长最快的方向，$-\nabla f(a)$ 是局部下降最快的方向。这正是梯度法的直觉来源。

### 3.5 Jacobian 矩阵

设 $f:O\to\mathbb{R}^p$ 在 $x_0$ 可微。微分 $df_{x_0}$ 在标准基下的矩阵称为 Jacobian 矩阵，记为：

$$
J_f(x_0)
=
\begin{pmatrix}
\dfrac{\partial f_1}{\partial x_1}(x_0)&\cdots&\dfrac{\partial f_1}{\partial x_n}(x_0)\\
\vdots&\ddots&\vdots\\
\dfrac{\partial f_p}{\partial x_1}(x_0)&\cdots&\dfrac{\partial f_p}{\partial x_n}(x_0)
\end{pmatrix}.
$$

如果 $p=1$，Jacobian 是一行向量，而梯度通常写成列向量。

### 3.6 Hessian 矩阵

设 $f:\mathbb{R}^n\to\mathbb{R}$ 在 $x_0$ 处所有二阶偏导数存在。$f$ 在 $x_0$ 处的 Hessian 矩阵定义为：

$$
H_f(x_0)
=
\left(
\frac{\partial^2 f}{\partial x_i\partial x_j}(x_0)
\right)_{1\le i,j\le n}.
$$

如果二阶偏导连续，则 Hessian 矩阵是对称的：

$$
H_f(x_0)=H_f(x_0)^\top.
$$

Hessian 描述函数的二阶曲率，是判断极值和凸性的关键工具。

### 3.7 Taylor 展开

一阶 Taylor 展开：若 $f:\mathbb{R}^n\to\mathbb{R}$ 在 $x$ 可微，则：

$$
f(x+h)
=f(x)+df_x(h)+o(\|h\|).
$$

用梯度写成：

$$
f(x+h)
=f(x)+\langle \nabla f(x),h\rangle+o(\|h\|).
$$

二阶 Taylor 展开：若 $f$ 在 $x$ 二次可微，则：

$$
f(x+h)
=f(x)+df_x(h)+\frac12 d^2f_x(h,h)+o(\|h\|^2).
$$

用 Hessian 写成：

$$
f(x+h)
=f(x)+\langle \nabla f(x),h\rangle
+\frac12\langle H_f(x)h,h\rangle
+o(\|h\|^2).
$$

后续无约束最优性条件会直接来自这个公式：在局部极小点，一阶项不能产生下降方向；二阶项需要非负。

## 4. 凸分析基础

凸性是优化中最重要的结构之一。凸优化之所以好，是因为局部最优通常就是全局最优，并且有强大的理论与算法支持。

### 4.1 凸集

设 $S\subset\mathbb{R}^n$。若对任意 $x,y\in S$ 和任意 $\lambda\in[0,1]$，都有：

$$
\lambda x+(1-\lambda)y\in S,
$$

则称 $S$ 是凸集。

直观上，集合中任意两点连成的线段都完全留在集合内部。

### 4.2 凸函数

设 $S\subset\mathbb{R}^n$ 是非空凸集，$f:S\to\mathbb{R}$。若对任意 $x,y\in S$ 和任意 $\theta\in[0,1]$，都有：

$$
f(\theta x+(1-\theta)y)
\le
\theta f(x)+(1-\theta)f(y),
$$

则称 $f$ 是凸函数。

几何上，函数图像上任意两点之间的割线位于函数图像上方。

### 4.3 严格凸函数

若对任意 $x\ne y$ 和 $\theta\in(0,1)$，都有：

$$
f(\theta x+(1-\theta)y)
<
\theta f(x)+(1-\theta)f(y),
$$

则称 $f$ 是严格凸函数。

严格凸函数至多有一个全局最小点。注意是“至多”：是否存在最小点还需要连续性、紧性或强制性等条件。

### 4.4 强凸函数

设 $m>0$。若对任意 $x,y$ 和 $\theta\in(0,1)$，都有：

$$
f(\theta x+(1-\theta)y)
\le
\theta f(x)+(1-\theta)f(y)
-\frac{m}{2}\theta(1-\theta)\|x-y\|^2,
$$

则称 $f$ 是 $m$-强凸函数。

强凸比严格凸更强。它要求函数不仅“弯”，而且至少有二次函数级别的弯曲程度。

常见等价理解：

$$
f(x)-\frac{m}{2}\|x\|^2
\quad\text{is convex}.
$$

## 5. 凸性的判别

### 5.1 一阶判别：梯度刻画

设 $C\subset\mathbb{R}^n$ 是开凸集，$f:C\to\mathbb{R}$ 可微。则 $f$ 是凸函数当且仅当：

$$
f(y)\ge f(x)+\langle \nabla f(x),y-x\rangle,
\qquad \forall x,y\in C.
$$

这表示：凸函数的图像总在任意一点的切平面之上。

若 $f$ 严格凸，则对 $x\ne y$ 有更强的不等式：

$$
f(y)> f(x)+\langle \nabla f(x),y-x\rangle.
$$

在优化中，这个不等式非常关键。若 $\nabla f(x^\star)=0$ 且 $f$ 凸，则：

$$
f(y)\ge f(x^\star)+\langle \nabla f(x^\star),y-x^\star\rangle=f(x^\star),
$$

因此 $x^\star$ 是全局最小点。

### 5.2 二阶判别：Hessian 刻画

设 $C\subset\mathbb{R}^n$ 是开凸集，$f:C\to\mathbb{R}$ 二次可微。

$f$ 凸当且仅当：

$$
H_f(x)\succeq 0,\qquad \forall x\in C.
$$

也就是说，对任意方向 $d\in\mathbb{R}^n$：

$$
d^\top H_f(x)d\ge 0.
$$

如果：

$$
H_f(x)\succ 0,\qquad \forall x\in C,
$$

则 $f$ 严格凸。不过反过来不一定成立：严格凸函数的 Hessian 不一定处处正定。

对于 $m$-强凸函数，常用二阶判别是：

$$
H_f(x)\succeq mI,\qquad \forall x\in C.
$$

这等价于：

$$
d^\top H_f(x)d\ge m\|d\|^2,\qquad \forall d\in\mathbb{R}^n.
$$

## 6. 强凸函数的重要性质

设 $m>0$，$f:\mathbb{R}^n\to\mathbb{R}$ 是 $m$-强凸函数。则：

1. $f$ 是严格凸函数；
2. 对任意 $x,y\in\mathbb{R}^n$，有：

$$
f(y)
\ge
f(x)+\langle \nabla f(x),y-x\rangle
+\frac{m}{2}\|y-x\|^2;
$$

3. $f$ 是强制函数；
4. $f$ 存在唯一全局最小点 $x^\star$；
5. 梯度可以控制函数值误差与点误差。常用估计包括：

$$
f(x)-f(x^\star)
\le
\frac{1}{2m}\|\nabla f(x)\|^2,
$$

以及：

$$
\|x-x^\star\|
\le
\frac{1}{m}\|\nabla f(x)\|.
$$

直观上，强凸函数有唯一的“碗底”。离最优点越远，函数值和梯度都会给出可量化的信号。

## 7. 本讲总结

本讲的作用是把后续优化理论需要的数学工具整理出来：

- 正定矩阵用于刻画二次型、Hessian 和局部曲率；
- 开集、闭集、邻域、有界性、强制性用于讨论极值存在性；
- 偏导、方向导数、微分、梯度、Jacobian、Hessian 用于建立最优性条件；
- Taylor 展开连接“函数局部形状”和“一阶/二阶条件”；
- 凸集、凸函数、严格凸、强凸决定问题是否容易得到全局最优。

后续学习时可以记住一条主线：

$$
\text{Taylor 展开}
\Longrightarrow
\text{最优性条件}
\Longrightarrow
\text{算法设计}.
$$

而凸性提供了另一条主线：

$$
\text{局部信息}
\Longrightarrow
\text{全局结论}.
$$
