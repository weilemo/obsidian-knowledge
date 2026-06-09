# TP3 - Newton 与 Quasi-Newton 轨迹优化解题讲义

相关文件：

- [[../Materials/Notebooks/Td-Tp 3_énoncé.ipynb]]
- [[../Materials/Notebooks/Chapitre 5 II_énoncé.ipynb]]
- [[../Materials/Notebooks/Chapitre 5 II_corrigé.ipynb]]
- [[Chapitre 5 - Méthode de Newton et quasi-Newton 讲义]]
- [[Chapitre 6 - Conditions d'optimalité sous contraintes 讲义]]

## 这个 TP 在做什么

这个 TP 分成两部分。

第一部分是 Newton 方法的理论练习，重点不是写代码，而是理解：

1. Newton 迭代什么时候有定义；
2. 为什么 Newton 方法不一定有限步收敛；
3. Newton 方法在根附近为什么可以有二次甚至三次收敛；
4. 多维非线性方程里 Newton 迭代可能出现怎样的收敛行为。

第二部分是无人机轨迹优化实验。它沿用前面 TP 的轨迹建模，把一条三维路径写成变量，然后比较：

1. 梯度下降；.
2. Momentum；
3. Newton 方法；
4. DFP；
5. BFGS；
6. 大规模问题中的 L-BFGS 思路。

本 TP 的核心理解是：梯度下降只用一阶信息，Newton 用 Hessian 的二阶信息，quasi-Newton 则试图在不显式求 Hessian 或 Hessian 逆的情况下，逐步学习一个近似二阶信息。

## 预备知识 1：Newton 方法求根

Newton 方法最初用于求解非线性方程：

$$
g(x)=0.
$$

设当前点为 $x_k$。在 $x_k$ 附近对 $g$ 做一阶 Taylor 展开：

$$
g(x_k+p)
\approx
g(x_k)+g'(x_k)p.
$$

如果希望新点满足 $g(x_k+p)\approx 0$，就令：

$$
g(x_k)+g'(x_k)p=0.
$$

当 $g'(x_k)\neq 0$ 时，有：

$$
p
=
-\frac{g(x_k)}{g'(x_k)}.
$$

因此 Newton 迭代为：

$$
x_{k+1}
=
x_k-\frac{g(x_k)}{g'(x_k)}.
$$

这个公式成立的条件是：每一步的导数 $g'(x_k)$ 不能为 $0$。否则分母为 $0$，迭代没有定义。

## 预备知识 2：Newton 方法做优化

无约束优化问题是：

$$
\min_{x\in\mathbb{R}^n} f(x).
$$

若 $x^\star$ 是内点局部极小点，且 $f$ 可微，则必要条件是：

$$
\nabla f(x^\star)=0.
$$

所以优化问题可以看成求解方程：

$$
F(x)=0,
\qquad
F(x)=\nabla f(x).
$$

对 $\nabla f$ 做一阶 Taylor 展开：

$$
\nabla f(x_k+p)
\approx
\nabla f(x_k)+H_f(x_k)p.
$$

令右边为 $0$：

$$
\nabla f(x_k)+H_f(x_k)p=0.
$$

如果 Hessian $H_f(x_k)$ 可逆，则：

$$
p_k
=
-H_f(x_k)^{-1}\nabla f(x_k).
$$

于是 Newton 优化迭代为：

$$
x_{k+1}
=
x_k-H_f(x_k)^{-1}\nabla f(x_k).
$$

实际写代码时，不应该真的先求逆，而应该解线性方程：

$$
H_f(x_k)p_k
=
-\nabla f(x_k).
$$

对应代码是：

```python
p = np.linalg.solve(H, -g)
x = x + p
```

这样通常比 `np.linalg.inv(H) @ g` 更稳定。

## 预备知识 3：收敛阶

设 $x^\star$ 是极限点，误差为：

$$
e_k=x_k-x^\star.
$$

若存在常数 $C>0$，使得：

$$
\|e_{k+1}\|
\le
C\|e_k\|^p,
$$

则称算法至少 $p$ 阶收敛。

常见情况：

| 收敛阶 | 形式 | 直觉 |
|---|---|---|
| 线性收敛 | $\|e_{k+1}\|\le \rho\|e_k\|$，$0<\rho<1$ | 每次误差乘一个固定比例 |
| 二次收敛 | $\|e_{k+1}\|\le C\|e_k\|^2$ | 进入局部区间后精度位数快速翻倍 |
| 三次收敛 | $\|e_{k+1}\|\le C\|e_k\|^3$ | 比二次收敛还快 |

Newton 方法在根附近通常有二次收敛，但前提包括：

1. 根 $\bar{x}$ 附近函数足够光滑；
2. $g'(\bar{x})\neq 0$；
3. 初始点已经足够接近根。

## 理论练习 1

题目给：

$$
f(x)=e^x-1.
$$

要求用 Newton 方法求 $f(x)=0$。

### 1.1 迭代公式与良定义

因为：

$$
f'(x)=e^x.
$$

对任意 $x\in\mathbb{R}$，都有：

$$
e^x>0.
$$

所以 Newton 迭代对所有初始点 $x_0\in\mathbb{R}$ 都有定义。

Newton 公式为：

$$
x_{k+1}
=
x_k-\frac{e^{x_k}-1}{e^{x_k}}.
$$

化简：

$$
x_{k+1}
=
x_k-1+e^{-x_k}.
$$

### 1.2 有限步收敛当且仅当一开始就在根上

若某一步不动，即 $x_{k+1}=x_k$，由 Newton 公式得：

$$
x_k-\frac{f(x_k)}{f'(x_k)}=x_k.
$$

因为 $f'(x_k)=e^{x_k}\neq 0$，所以：

$$
f(x_k)=0.
$$

也就是：

$$
e^{x_k}-1=0
\quad\Longleftrightarrow\quad
x_k=0.
$$

反过来，如果 $x_k=0$，则 $f(x_k)=0$，Newton 更新给出：

$$
x_{k+1}=x_k=0.
$$

所以 Newton 方法有限步停止，当且仅当某一步已经等于 $0$。

对这个例子还能进一步说明：若 $x_0\neq 0$，则每一步只会逐渐趋近 $0$，不会在有限步突然等于 $0$。因此有限步收敛当且仅当：

$$
f(x_0)=0
\quad\Longleftrightarrow\quad
x_0=0.
$$

### 1.3 初始点符号对第一步的影响

迭代函数为：

$$
\phi(x)=x-1+e^{-x}.
$$

如果 $x_0<0$，令 $t=-x_0>0$，则：

$$
x_1
=
-t-1+e^t.
$$

由于指数函数满足：

$$
e^t>1+t,
\qquad t>0,
$$

所以：

$$
x_1>-t-1+(1+t)=0.
$$

因此：

$$
x_0<0
\quad\Longrightarrow\quad
x_1>0.
$$

如果 $x_0>0$，则：

$$
x_1=x_0-1+e^{-x_0}.
$$

一方面，因为 $e^{-x_0}<1$，有：

$$
x_1<x_0.
$$

另一方面，由凸性不等式 $e^{-x}>1-x$，当 $x>0$ 时严格成立：

$$
e^{-x_0}>1-x_0.
$$

因此：

$$
x_1=x_0-1+e^{-x_0}>0.
$$

所以：

$$
x_0>0
\quad\Longrightarrow\quad
0<x_1<x_0.
$$

### 1.4 收敛性与极限

如果 $x_0<0$，上一问说明 $x_1>0$。从 $x_1$ 开始就进入正半轴。

如果 $x_k>0$，则：

$$
0<x_{k+1}<x_k.
$$

所以正半轴上的迭代序列单调递减且有下界 $0$，必然收敛。设极限为 $\ell\ge 0$。对迭代公式取极限：

$$
\ell
=
\ell-1+e^{-\ell}.
$$

于是：

$$
e^{-\ell}=1.
$$

所以：

$$
\ell=0.
$$

结论：

$$
x_k\to 0.
$$

这说明 Newton 方法对这个例子从任意初值都会收敛到根 $0$，但除了 $x_0=0$ 以外，不会有限步结束。

## 理论练习 2

题目给：

$$
F(x,y)=
\begin{bmatrix}
x^2-y\\
y^2
\end{bmatrix}.
$$

要求求解：

$$
F(x,y)=
\begin{bmatrix}
0\\
0
\end{bmatrix}.
$$

### 2.1 解集

方程组为：

$$
\begin{cases}
x^2-y=0,\\
y^2=0.
\end{cases}
$$

由第二个方程：

$$
y=0.
$$

代入第一个方程：

$$
x^2=0.
$$

所以：

$$
x=0.
$$

解集为：

$$
\{(0,0)\}.
$$

### 2.2 Newton 迭代公式

Jacobian 矩阵为：

$$
J_F(x,y)
=
\begin{bmatrix}
2x & -1\\
0 & 2y
\end{bmatrix}.
$$

Newton 方法求解非线性方程 $F(x,y)=0$ 时，先解：

$$
J_F(x_k,y_k)
\begin{bmatrix}
\Delta x_k\\
\Delta y_k
\end{bmatrix}
=
-
F(x_k,y_k),
$$

再更新：

$$
\begin{bmatrix}
x_{k+1}\\
y_{k+1}
\end{bmatrix}
=
\begin{bmatrix}
x_k\\
y_k
\end{bmatrix}
+
\begin{bmatrix}
\Delta x_k\\
\Delta y_k
\end{bmatrix}.
$$

Jacobian 行列式为：

$$
\det J_F(x,y)=4xy.
$$

所以当：

$$
x\neq 0,
\qquad
y\neq 0
$$

时，Newton 线性方程有唯一解。题目给 $x_0\neq 0$ 且 $y_0>0$，第一步有定义。下面会看到 $y_k$ 始终为正，且 $x_k$ 在题目讨论的初值下保持正，因此迭代一直有定义。

### 2.3 显式计算迭代

线性方程为：

$$
\begin{bmatrix}
2x_k & -1\\
0 & 2y_k
\end{bmatrix}
\begin{bmatrix}
\Delta x_k\\
\Delta y_k
\end{bmatrix}
=
-
\begin{bmatrix}
x_k^2-y_k\\
y_k^2
\end{bmatrix}.
$$

第二行给出：

$$
2y_k\Delta y_k=-y_k^2.
$$

因为 $y_k>0$，所以：

$$
\Delta y_k=-\frac{y_k}{2}.
$$

于是：

$$
y_{k+1}
=
y_k+\Delta y_k
=
\frac{y_k}{2}.
$$

当 $y_0=1$ 时：

$$
y_k=2^{-k}.
$$

第一行给出：

$$
2x_k\Delta x_k-\Delta y_k
=
-x_k^2+y_k.
$$

代入 $\Delta y_k=-y_k/2$：

$$
2x_k\Delta x_k+\frac{y_k}{2}
=
-x_k^2+y_k.
$$

所以：

$$
2x_k\Delta x_k
=
-x_k^2+\frac{y_k}{2}.
$$

即：

$$
\Delta x_k
=
-\frac{x_k}{2}+\frac{y_k}{4x_k}.
$$

因此：

$$
x_{k+1}
=
x_k+\Delta x_k
=
\frac{x_k}{2}+\frac{y_k}{4x_k}.
$$

当 $y_k=2^{-k}$ 时：

$$
x_{k+1}
=
\frac{x_k}{2}+\frac{2^{-k}}{4x_k}.
$$

### 2.4 证明 $x_k\ge 2^{-k/2}$

对任意 $a>0,b>0$，均值不等式给出：

$$
\frac{a+b}{2}\ge \sqrt{ab}.
$$

这里把：

$$
x_{k+1}
=
\frac{x_k}{2}+\frac{2^{-k}}{4x_k}
=
\frac{1}{2}
\left(
x_k+\frac{2^{-k}}{2x_k}
\right).
$$

于是：

$$
x_{k+1}
\ge
\sqrt{x_k\cdot \frac{2^{-k}}{2x_k}}
=
\sqrt{2^{-(k+1)}}.
$$

所以：

$$
x_{k+1}\ge 2^{-(k+1)/2}.
$$

从 $x_0=1=2^0$ 出发，归纳得到：

$$
x_k\ge 2^{-k/2}.
$$

### 2.5 单调性与收敛

由迭代公式：

$$
x_{k+1}
=
\frac{x_k}{2}+\frac{2^{-k}}{4x_k}.
$$

要证明 $x_{k+1}\le x_k$，等价于：

$$
\frac{2^{-k}}{4x_k}
\le
\frac{x_k}{2}.
$$

也就是：

$$
2^{-k}
\le
2x_k^2.
$$

由上一问 $x_k^2\ge 2^{-k}$，可得：

$$
2x_k^2\ge 2^{1-k}\ge 2^{-k}.
$$

因此：

$$
x_{k+1}\le x_k.
$$

序列 $(x_k)$ 非负、单调递减，因此收敛。设极限为 $a\ge 0$。又因为：

$$
y_k=2^{-k}\to 0.
$$

若 $a>0$，对迭代公式取极限得：

$$
a=\frac{a}{2},
$$

这推出 $a=0$，矛盾。所以只能：

$$
a=0.
$$

于是：

$$
(x_k,y_k)\to(0,0).
$$

Newton 方法收敛到唯一解。

## 理论练习 3

题目定义：

$$
h(x)
=
x-\frac{g(x)}{g'(f(x))},
$$

并考虑不动点迭代：

$$
x_{n+1}=h(x_n).
$$

其中：

$$
g(\bar{x})=0,
\qquad
g'(\bar{x})\neq 0,
\qquad
f(\bar{x})=\bar{x}.
$$

这个算法可以看成 Newton 方法的变形：标准 Newton 是：

$$
x_{n+1}
=
x_n-\frac{g(x_n)}{g'(x_n)}.
$$

这里把分母中的 $x_n$ 改成了 $f(x_n)$。

### 3.1 局部收敛

首先：

$$
h(\bar{x})
=
\bar{x}-\frac{g(\bar{x})}{g'(f(\bar{x}))}
=
\bar{x}.
$$

所以 $\bar{x}$ 是 $h$ 的不动点。

因为 $g'(\bar{x})\neq 0$，且 $g'$ 连续，所以存在一个足够小的区间：

$$
I_\alpha=[\bar{x}-\alpha,\bar{x}+\alpha],
$$

使得对所有 $x\in I_\alpha$，都有：

$$
g'(f(x))\neq 0.
$$

因此迭代在这个区间内有定义。

对 $h$ 求导。记：

$$
q(x)=g'(f(x)).
$$

则：

$$
h(x)=x-\frac{g(x)}{q(x)}.
$$

由商法则：

$$
h'(x)
=
1-\frac{g'(x)q(x)-g(x)q'(x)}{q(x)^2}.
$$

在 $x=\bar{x}$ 处，由 $g(\bar{x})=0$、$f(\bar{x})=\bar{x}$ 得：

$$
q(\bar{x})=g'(\bar{x}).
$$

所以：

$$
h'(\bar{x})
=
1-\frac{g'(\bar{x})g'(\bar{x})}{g'(\bar{x})^2}
=
0.
$$

由于 $h'$ 连续，可以选取足够小的 $\alpha$，使得：

$$
|h'(x)|<1,
\qquad x\in I_\alpha.
$$

这时 $h$ 是局部压缩映射，所以若 $x_0$ 足够接近 $\bar{x}$，则：

$$
x_n\to\bar{x}.
$$

### 3.2 至少二次收敛

令误差：

$$
e=x-\bar{x}.
$$

因为：

$$
h(\bar{x})=\bar{x},
\qquad
h'(\bar{x})=0,
$$

对 $h$ 在 $\bar{x}$ 附近做 Taylor 展开：

$$
h(x)-\bar{x}
=
\frac12 h''(\xi)(x-\bar{x})^2
$$

其中 $\xi$ 位于 $x$ 和 $\bar{x}$ 之间。

如果 $h''$ 在局部区间有界，即存在 $M>0$ 使得：

$$
|h''(\xi)|\le M,
$$

则：

$$
|x_{n+1}-\bar{x}|
=
|h(x_n)-\bar{x}|
\le
\frac{M}{2}|x_n-\bar{x}|^2.
$$

所以至少二次收敛。

### 3.3 三次收敛条件

如果还满足：

$$
f'(\bar{x})=\frac12,
$$

则可以进一步证明：

$$
h''(\bar{x})=0.
$$

直觉是：标准 Newton 的二次误差项来自分母 $g'(x)$ 对真实导数变化的近似误差；现在选择 $f$，相当于把导数评估点放在一个更合适的位置。若 $f'(\bar{x})=1/2$，二阶误差项被抵消，剩下的主导项变成三阶。

于是 Taylor 展开从三阶开始：

$$
h(x)-\bar{x}
=
\frac{1}{6}h'''(\xi)(x-\bar{x})^3.
$$

若 $h'''$ 局部有界，则存在 $C>0$，使得：

$$
|x_{n+1}-\bar{x}|
\le
C|x_n-\bar{x}|^3.
$$

因此算法至少三次收敛。

### 3.4 构造三次收敛的 $f$

题目最后给：

$$
f(x)
=
x-\frac{g(x)}{2g'(x)}.
$$

这是“半步 Newton”映射。因为：

$$
g(\bar{x})=0,
$$

所以：

$$
f(\bar{x})=\bar{x}.
$$

对 $f$ 求导：

$$
f'(x)
=
1-\frac12
\frac{g(x)g''(x)}{2(g'(x))^2}.
$$

在 $x=\bar{x}$ 处，$g(\bar{x})=0$，因此：

$$
f'(\bar{x})=\frac12.
$$

由上一问可知，对这种 $f$，迭代至少三次收敛。

## 实验部分：无人机轨迹优化

### 1. 变量如何表示

起点和终点固定：

$$
\mathbf{x}_0=(0,0,0),
\qquad
\mathbf{x}_{N+1}=(3,3,3).
$$

中间点有 $N$ 个，题目代码中：

```python
N_INTERMEDIATE = 8
```

每个中间点在三维空间中：

$$
\mathbf{x}_i=(x_i,y_i,z_i)\in\mathbb{R}^3.
$$

所以真正要优化的变量维度是：

$$
n=3N.
$$

如果把所有中间点拉平成一个向量：

$$
u
=
(x_1,y_1,z_1,\dots,x_N,y_N,z_N)
\in\mathbb{R}^{3N}.
$$

完整路径由：

$$
\mathbf{x}_0,\mathbf{x}_1,\dots,\mathbf{x}_N,\mathbf{x}_{N+1}
$$

组成。

### 2. 目标函数建模

题目要求最小化路径长度和曲率。因此一个自然目标函数是：

$$
J(\mathbf{x})
=
\alpha J_{\mathrm{length}}(\mathbf{x})
+
\beta J_{\mathrm{smooth}}(\mathbf{x}).
$$

其中：

$$
J_{\mathrm{length}}(\mathbf{x})
=
\sum_{i=0}^{N}
\|\mathbf{x}_{i+1}-\mathbf{x}_i\|.
$$

这一项来自路径长度的离散定义：连续曲线长度是速度范数积分，离散路径则用相邻点距离之和近似。

平滑项可以用二阶差分：

$$
J_{\mathrm{smooth}}(\mathbf{x})
=
\sum_{i=1}^{N}
\|\mathbf{x}_{i+1}-2\mathbf{x}_i+\mathbf{x}_{i-1}\|^2.
$$

二阶差分：

$$
\mathbf{x}_{i+1}-2\mathbf{x}_i+\mathbf{x}_{i-1}
$$

是离散版“加速度”。如果三个相邻点接近一条直线且变化均匀，这个量接近 $0$；如果路径突然拐弯，它会变大。

所以目标函数可写为：

$$
J(\mathbf{x})
=
\alpha
\sum_{i=0}^{N}
\|\mathbf{x}_{i+1}-\mathbf{x}_i\|
+
\beta
\sum_{i=1}^{N}
\|\mathbf{x}_{i+1}-2\mathbf{x}_i+\mathbf{x}_{i-1}\|^2.
$$

在题目给定参数下：

$$
\alpha=1,
\qquad
\beta=0.5.
$$

### 3. 初始化路径

起点和终点固定，中间点随机生成：

```python
def initialize_path():
    middle = np.random.rand(N_INTERMEDIATE, 3) * 3.0
    path = np.vstack([START, middle, END])
    return path
```

为了让优化变量只包含中间点，可以定义两个辅助函数：

```python
def pack(path):
    return path[1:-1].reshape(-1)

def unpack(u):
    middle = u.reshape(N_INTERMEDIATE, 3)
    return np.vstack([START, middle, END])
```

这样算法内部优化的是一维向量 $u$，而目标函数内部再转回路径矩阵。

### 4. 目标函数代码

```python
def objective_path(path):
    length = 0.0
    smooth = 0.0

    for i in range(len(path) - 1):
        length += np.linalg.norm(path[i + 1] - path[i])

    for i in range(1, len(path) - 1):
        second_diff = path[i + 1] - 2 * path[i] + path[i - 1]
        smooth += np.linalg.norm(second_diff) ** 2

    return alpha * length + beta * smooth

def objective(u):
    return objective_path(unpack(u))
```

注意：路径长度项含有欧氏范数，在相邻点完全重合时不可微。数值实验里通常不会恰好重合；如果担心不可微，可以把长度项改成平滑近似：

$$
\sqrt{\|d_i\|^2+\varepsilon}.
$$

### 5. 数值梯度

因为题目没有要求手推解析梯度，最直接做法是用有限差分。

对第 $j$ 个变量，偏导近似为：

$$
\frac{\partial J}{\partial u_j}(u)
\approx
\frac{J(u+\varepsilon e_j)-J(u-\varepsilon e_j)}{2\varepsilon}.
$$

这是中心差分，精度通常比前向差分更好。

代码：

```python
def numerical_gradient(f, u, eps=1e-6):
    grad = np.zeros_like(u)
    for j in range(len(u)):
        e = np.zeros_like(u)
        e[j] = eps
        grad[j] = (f(u + e) - f(u - e)) / (2 * eps)
    return grad
```

### 6. 数值 Hessian

Newton 方法需要 Hessian。可以继续用有限差分近似梯度的变化：

$$
H_{:,j}(u)
\approx
\frac{\nabla J(u+\varepsilon e_j)-\nabla J(u-\varepsilon e_j)}{2\varepsilon}.
$$

代码：

```python
def numerical_hessian(f, u, eps=1e-4):
    n = len(u)
    H = np.zeros((n, n))
    for j in range(n):
        e = np.zeros(n)
        e[j] = eps
        gp = numerical_gradient(f, u + e)
        gm = numerical_gradient(f, u - e)
        H[:, j] = (gp - gm) / (2 * eps)
    return 0.5 * (H + H.T)
```

最后一行对称化，是因为真实 Hessian 在足够光滑时应当对称；数值误差会让它略微不对称。

## 算法 1：固定步长梯度下降

梯度下降来自一阶 Taylor 展开：

$$
J(u+p)
\approx
J(u)+\nabla J(u)^\top p.
$$

为了让一阶近似下降，取：

$$
p=-\eta\nabla J(u).
$$

于是：

$$
u_{k+1}
=
u_k-\eta\nabla J(u_k).
$$

代码：

```python
def gradient_descent(u0, lr=0.01, max_iter=300, tol=1e-6):
    u = u0.copy()
    history = []

    for k in range(max_iter):
        value = objective(u)
        grad = numerical_gradient(objective, u)
        history.append(value)

        if np.linalg.norm(grad) < tol:
            break

        u = u - lr * grad

    return u, history
```

固定步长的问题是：$\eta$ 太大可能震荡甚至发散，$\eta$ 太小则收敛很慢。题目中 $\eta=0.01$ 是一个可用基准，但可以尝试：

$$
\eta\in\{0.001,0.005,0.01,0.02,0.05,0.1\}.
$$

## 算法 2：Momentum

Momentum 的想法是给更新方向加入“惯性”：

$$
v_{k+1}
=
\mu v_k-\eta\nabla J(u_k),
$$

$$
u_{k+1}
=
u_k+v_{k+1}.
$$

其中 $\mu$ 是 momentum 参数，题目中取：

$$
\mu=0.9.
$$

代码：

```python
def momentum_descent(u0, lr=0.01, momentum=0.9, max_iter=300, tol=1e-6):
    u = u0.copy()
    v = np.zeros_like(u)
    history = []

    for k in range(max_iter):
        value = objective(u)
        grad = numerical_gradient(objective, u)
        history.append(value)

        if np.linalg.norm(grad) < tol:
            break

        v = momentum * v - lr * grad
        u = u + v

    return u, history
```

### Momentum 为什么更快

对病态二次函数：

$$
f(x)=\frac12 x^\top A x,
$$

条件数为：

$$
\kappa=\frac{\lambda_{\max}(A)}{\lambda_{\min}(A)}.
$$

题目给出：

$$
\rho_{\mathrm{GD}}
=
\frac{\kappa-1}{\kappa+1},
$$

$$
\rho_{\mathrm{Mom}}
=
\frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}.
$$

当 $\kappa$ 很大时：

$$
\frac{\kappa-1}{\kappa+1}
=
1-\frac{2}{\kappa+1}
\approx
1-\frac{2}{\kappa}.
$$

同理：

$$
\frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}
=
1-\frac{2}{\sqrt{\kappa}+1}
\approx
1-\frac{2}{\sqrt{\kappa}}.
$$

因为：

$$
\frac{2}{\sqrt{\kappa}}
\gg
\frac{2}{\kappa}
\qquad
(\kappa\gg 1),
$$

所以 $\rho_{\mathrm{Mom}}$ 离 $1$ 更远，收敛更快。

## 算法 3：Newton 方法

Newton 方向为：

$$
p_k
=
-H_k^{-1}g_k,
$$

其中：

$$
g_k=\nabla J(u_k),
\qquad
H_k=\nabla^2J(u_k).
$$

代码：

```python
def newton_method(u0, max_iter=50, tol=1e-6, damping=1e-4):
    u = u0.copy()
    history = []

    for k in range(max_iter):
        value = objective(u)
        grad = numerical_gradient(objective, u)
        history.append(value)

        if np.linalg.norm(grad) < tol:
            break

        H = numerical_hessian(objective, u)
        H_reg = H + damping * np.eye(len(u))

        try:
            p = np.linalg.solve(H_reg, -grad)
        except np.linalg.LinAlgError:
            p = -grad

        u_new = u + p

        if objective(u_new) > value:
            p = -grad
            u_new = u + 0.01 * p

        u = u_new

    return u, history
```

这里加入：

$$
H_{\mathrm{reg}}=H+\lambda I
$$

是为了避免 Hessian 不可逆或不正定。这和 Levenberg-Marquardt 的思想接近：当二阶信息不可靠时，用阻尼项把方向拉回更稳定的下降方向。

## 算法 4：DFP

Quasi-Newton 方法不直接计算 Hessian，而是维护一个矩阵 $B_k$ 或 $H_k$ 来近似二阶信息。

常见记号：

$$
s_k=u_{k+1}-u_k,
\qquad
y_k=\nabla J(u_{k+1})-\nabla J(u_k).
$$

割线方程来自梯度的一阶 Taylor 展开：

$$
\nabla J(u_{k+1})
\approx
\nabla J(u_k)+\nabla^2J(u_{k+1})(u_{k+1}-u_k).
$$

所以希望近似 Hessian $B_{k+1}$ 满足：

$$
B_{k+1}s_k=y_k.
$$

如果维护的是 inverse Hessian 近似 $H_k\approx B_k^{-1}$，则希望：

$$
H_{k+1}y_k=s_k.
$$

DFP 的 inverse Hessian 更新为：

$$
H_{k+1}
=
H_k
+
\frac{s_ks_k^\top}{s_k^\top y_k}
-
\frac{H_ky_ky_k^\top H_k}{y_k^\top H_ky_k}.
$$

搜索方向为：

$$
p_k=-H_k g_k.
$$

代码：

```python
def dfp_method(u0, lr=1.0, max_iter=100, tol=1e-6):
    u = u0.copy()
    n = len(u)
    H = np.eye(n)
    history = []

    g = numerical_gradient(objective, u)

    for k in range(max_iter):
        value = objective(u)
        history.append(value)

        if np.linalg.norm(g) < tol:
            break

        p = -H @ g
        u_new = u + lr * p
        g_new = numerical_gradient(objective, u_new)

        s = u_new - u
        y = g_new - g

        sy = s @ y
        yHy = y @ H @ y

        if sy > 1e-12 and yHy > 1e-12:
            H = H + np.outer(s, s) / sy - (H @ np.outer(y, y) @ H) / yHy

        u = u_new
        g = g_new

    return u, history
```

DFP 的收敛一般是超线性的，但实践中 BFGS 通常更稳定、更常用。

## 算法 5：BFGS

BFGS 也维护 inverse Hessian 近似 $H_k$，常用公式为：

$$
H_{k+1}
=
(I-\rho_ks_ky_k^\top)H_k(I-\rho_ky_ks_k^\top)
+
\rho_ks_ks_k^\top,
$$

其中：

$$
\rho_k=\frac{1}{y_k^\top s_k}.
$$

这个公式满足割线方程：

$$
H_{k+1}y_k=s_k.
$$

题目问 BFGS 近似什么。若使用上面的公式，答案是：

$$
\boxed{\text{BFGS 近似 Hessian inverse，即 }(\nabla^2J(u))^{-1}.}
$$

代码：

```python
def bfgs_method(u0, lr=1.0, max_iter=100, tol=1e-6):
    u = u0.copy()
    n = len(u)
    H = np.eye(n)
    history = []

    g = numerical_gradient(objective, u)

    for k in range(max_iter):
        value = objective(u)
        history.append(value)

        if np.linalg.norm(g) < tol:
            break

        p = -H @ g
        u_new = u + lr * p
        g_new = numerical_gradient(objective, u_new)

        s = u_new - u
        y = g_new - g
        ys = y @ s

        if ys > 1e-12:
            rho = 1.0 / ys
            I = np.eye(n)
            V = I - rho * np.outer(s, y)
            H = V @ H @ V.T + rho * np.outer(s, s)

        u = u_new
        g = g_new

    return u, history
```

实际实验中，DFP/BFGS 最好配合 line search。若直接用 `lr=1.0` 导致目标函数上升，可以把 `lr` 改小，或者使用回溯线搜索。

## 回溯线搜索

固定步长可能导致发散。回溯线搜索使用 Armijo 条件：

$$
J(u+\eta p)
\le
J(u)+c\eta\nabla J(u)^\top p,
$$

其中：

$$
c\in(0,1).
$$

如果条件不成立，就缩小步长：

$$
\eta\leftarrow \tau\eta,
\qquad
0<\tau<1.
$$

代码：

```python
def backtracking_line_search(f, u, p, g, eta0=1.0, c=1e-4, tau=0.5):
    eta = eta0
    value = f(u)

    while f(u + eta * p) > value + c * eta * (g @ p):
        eta *= tau
        if eta < 1e-8:
            break

    return eta
```

在 BFGS 中可以替换：

```python
eta = backtracking_line_search(objective, u, p, g)
u_new = u + eta * p
```

这样通常比固定 `lr=1.0` 稳。

## 大规模问题：BFGS 是否还合适

BFGS 需要存储一个 $n\times n$ 的矩阵：

$$
H_k\in\mathbb{R}^{n\times n}.
$$

内存复杂度是：

$$
O(n^2).
$$

如果：

$$
n=10^6,
$$

则矩阵元素数量为：

$$
10^{12}.
$$

即使用双精度浮点数，每个数 $8$ bytes，也需要：

$$
8\times 10^{12}\text{ bytes}
\approx
8\text{ TB}.
$$

所以普通 BFGS 不适合超大规模问题。

更适合的方法：

1. L-BFGS：只保存最近 $m$ 组 $(s_k,y_k)$，内存从 $O(n^2)$ 降到 $O(mn)$；
2. nonlinear conjugate gradient：不存 Hessian 矩阵，只维护少量向量；
3. stochastic quasi-Newton：在机器学习中用小批量梯度近似 quasi-Newton 信息。

如果 TP 要写“approfondissement”的回答，可以写：

> BFGS 在中小维问题上非常有效，但不适合百万维问题，因为它需要存储稠密的 $n\times n$ inverse Hessian 近似。大规模问题中可以使用 L-BFGS，它只保存最近若干步的曲率对 $(s_k,y_k)$，通过 two-loop recursion 隐式计算 $H_kg_k$，从而保留 quasi-Newton 的曲率校正优势，同时显著降低内存需求。

## 实验比较表怎么填

建议统一使用同一个初始路径：

```python
path0 = initialize_path()
u0 = pack(path0)
```

然后运行：

```python
methods = {
    "BGD": lambda: gradient_descent(u0, lr=0.01, max_iter=300),
    "Momentum": lambda: momentum_descent(u0, lr=0.01, momentum=0.9, max_iter=300),
    "Newton": lambda: newton_method(u0, max_iter=50),
    "DFP": lambda: dfp_method(u0, lr=0.1, max_iter=100),
    "BFGS": lambda: bfgs_method(u0, lr=0.1, max_iter=100),
}

results = {}
for name, run in methods.items():
    u_star, hist = run()
    results[name] = {
        "iterations": len(hist),
        "final_value": hist[-1],
        "history": hist,
    }
```

比较时不要只看迭代次数，还要看：

1. 最终目标函数值；
2. 每次迭代的耗时；
3. 是否稳定下降；
4. 是否需要调步长；
5. 是否出现 Hessian 不正定或数值奇异。

表格可以这样填：

| Méthode | Itérations | Ordre / comportement attendu |
|---|---:|---|
| BGD | 实验记录 | 通常线性收敛，单步便宜但慢 |
| Momentum | 实验记录 | 通常比 BGD 快，仍属一阶法 |
| Newton | 实验记录 | 局部二次收敛，单步昂贵 |
| DFP | 实验记录 | 通常超线性，稳定性弱于 BFGS |
| BFGS | 实验记录 | 通常超线性，中小规模常用 |

画图：

```python
plt.figure(figsize=(8, 5))
for name, info in results.items():
    plt.semilogy(info["history"], label=name)

plt.xlabel("Iteration")
plt.ylabel("Objective value")
plt.legend()
plt.grid(True)
plt.show()
```

如果用 `semilogy`，下降速度差异会更清楚。

## 最终答题策略

这份 TP 最重要的不是把所有代码堆满，而是说明每种方法为什么这样更新。

写答案时可以按下面逻辑：

1. 先写目标函数 $J$，解释长度项和平滑项的来源；
2. 说明变量只优化中间点，起点终点固定；
3. 给出梯度下降和 Momentum 的公式；
4. 给出 Newton 方向来自二阶 Taylor 模型；
5. 给出 DFP/BFGS 的割线方程和更新公式；
6. 说明 BFGS 近似 inverse Hessian；
7. 对大规模问题指出普通 BFGS 的 $O(n^2)$ 内存瓶颈，并提出 L-BFGS；
8. 最后用统一初始点和统一指标比较收敛曲线。

