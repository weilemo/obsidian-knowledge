# 补充 - BFGS 方法详解

相关笔记：

- [[Chapitre 5 - Méthode de Newton et quasi-Newton 讲义]]
- [[TP3 - Newton 与 Quasi-Newton 轨迹优化解题讲义]]
- [[补充 - 正定矩阵与最优化基础]]

## 1. BFGS 想解决什么问题

无约束优化问题为：

$$
\min_{x\in\mathbb{R}^n} f(x).
$$

Newton 方法的更新方向是：

$$
p_k
=
-\nabla^2 f(x_k)^{-1}\nabla f(x_k).
$$

这个方向很强，因为它使用了二阶曲率信息。但它也很贵：

1. 每一步要计算 Hessian 矩阵 $\nabla^2 f(x_k)$；
2. Hessian 是 $n\times n$ 矩阵，存储成本是 $O(n^2)$；
3. 解线性方程或求逆通常成本高；
4. 如果 Hessian 不正定，Newton 方向甚至不一定是下降方向。

BFGS 属于 quasi-Newton 方法。它的目标是：

> 不显式计算 Hessian，而是用每一步的位移和梯度变化，逐渐构造一个 Hessian 或 Hessian 逆的近似。

BFGS 的名字来自四位作者：

$$
\text{Broyden-Fletcher-Goldfarb-Shanno}.
$$

## 2. 核心记号：$s_k$ 和 $y_k$

从 $x_k$ 走到 $x_{k+1}$，定义：

$$
s_k=x_{k+1}-x_k.
$$

梯度变化为：

$$
y_k=\nabla f(x_{k+1})-\nabla f(x_k).
$$

这两个量非常重要：

- $s_k$ 表示这一步在变量空间里走了多少；
- $y_k$ 表示梯度因此改变了多少；
- 梯度变化本质上反映了函数的曲率。

为什么 $y_k$ 能反映曲率？因为对梯度做一阶 Taylor 展开：

$$
\nabla f(x_{k+1})
\approx
\nabla f(x_k)+\nabla^2 f(x_{k+1})(x_{k+1}-x_k).
$$

整理得到：

$$
y_k
\approx
\nabla^2 f(x_{k+1})s_k.
$$

这就是 quasi-Newton 方法的基本信息来源。

## 3. 割线方程

如果用 $B_k$ 近似 Hessian：

$$
B_k\approx \nabla^2 f(x_k),
$$

那么下一步的近似矩阵 $B_{k+1}$ 应该尽量满足：

$$
B_{k+1}s_k=y_k.
$$

这个式子叫割线方程，也叫 secant equation。

它的意思是：虽然我们不知道真实 Hessian，但至少希望新的近似 Hessian 能正确解释刚刚观察到的梯度变化。

如果维护的是 Hessian inverse 的近似：

$$
H_k\approx \nabla^2 f(x_k)^{-1},
$$

则割线方程写成：

$$
H_{k+1}y_k=s_k.
$$

实际算法里常维护 $H_k$，因为方向可以直接写成：

$$
p_k=-H_k\nabla f(x_k).
$$

这样不需要每一步解线性方程。

## 4. BFGS 到底近似什么

这点最容易混淆。

BFGS 有两种等价视角：

1. 维护 $B_k$，让 $B_k$ 近似 Hessian；
2. 维护 $H_k$，让 $H_k$ 近似 Hessian inverse。

如果代码里更新的是：

$$
B_{k+1}
=
B_k
-
\frac{B_ks_ks_k^\top B_k}{s_k^\top B_ks_k}
+
\frac{y_ky_k^\top}{y_k^\top s_k},
$$

那么 $B_k$ 近似的是：

$$
\nabla^2 f(x_k).
$$

如果代码里更新的是：

$$
H_{k+1}
=
(I-\rho_ks_ky_k^\top)H_k(I-\rho_ky_ks_k^\top)
+
\rho_ks_ks_k^\top,
$$

其中：

$$
\rho_k=\frac{1}{y_k^\top s_k},
$$

那么 $H_k$ 近似的是：

$$
\nabla^2 f(x_k)^{-1}.
$$

TP3 里的写法使用第二种，因此答案是：

$$
\boxed{H_k\text{ 近似 Hessian inverse，即 } \nabla^2 f(x_k)^{-1}.}
$$

## 5. BFGS 更新公式

维护 inverse Hessian 近似时，BFGS 更新为：

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

搜索方向为：

$$
p_k=-H_k g_k,
\qquad
g_k=\nabla f(x_k).
$$

然后用步长 $\alpha_k$ 更新：

$$
x_{k+1}=x_k+\alpha_kp_k.
$$

通常 $\alpha_k$ 由线搜索给出，而不是随便固定。常见选择是 Wolfe 条件或 Armijo 回溯。

## 6. 为什么需要 $y_k^\top s_k>0$

BFGS 更新里有分母：

$$
y_k^\top s_k.
$$

所以至少需要：

$$
y_k^\top s_k\neq 0.
$$

更强、更重要的条件是：

$$
y_k^\top s_k>0.
$$

这个条件叫 curvature condition。它的直觉是：沿着这一步 $s_k$，梯度变化 $y_k$ 应该体现出正曲率。

如果 $f$ 是严格凸二次函数：

$$
f(x)=\frac12x^\top Ax-b^\top x,
\qquad
A\succ 0,
$$

则：

$$
y_k
=
\nabla f(x_{k+1})-\nabla f(x_k)
=
A(x_{k+1}-x_k)
=
As_k.
$$

于是：

$$
y_k^\top s_k
=
s_k^\top As_k.
$$

因为 $A\succ 0$，只要 $s_k\neq 0$，就有：

$$
s_k^\top As_k>0.
$$

所以在严格凸二次情形下，$y_k^\top s_k>0$ 自动成立。

一般非线性函数中，若使用满足 Wolfe 条件的线搜索，也可以保证这个曲率条件，从而让 BFGS 更新保持稳定。

## 7. 正定性为什么重要

如果初始矩阵满足：

$$
H_0\succ 0,
$$

并且每一步满足：

$$
y_k^\top s_k>0,
$$

那么 BFGS 更新会保持：

$$
H_{k+1}\succ 0.
$$

这很关键。因为搜索方向是：

$$
p_k=-H_kg_k.
$$

如果 $H_k\succ 0$ 且 $g_k\neq 0$，则：

$$
g_k^\top p_k
=
-g_k^\top H_kg_k
<0.
$$

这说明 $p_k$ 是下降方向。

所以 BFGS 的一个漂亮性质是：在合适线搜索下，它既能学习曲率，又能保持下降方向。

## 8. BFGS 和 Newton 的关系

Newton 使用真实 Hessian inverse：

$$
p_k^{\mathrm{Newton}}
=
-\nabla^2 f(x_k)^{-1}g_k.
$$

BFGS 使用近似 Hessian inverse：

$$
p_k^{\mathrm{BFGS}}
=
-H_kg_k,
\qquad
H_k\approx \nabla^2 f(x_k)^{-1}.
$$

所以可以把 BFGS 理解成：

> 用历史梯度变化逐步学出一个“像 Newton 一样缩放梯度”的矩阵。

梯度下降是：

$$
p_k^{\mathrm{GD}}=-g_k.
$$

BFGS 是：

$$
p_k^{\mathrm{BFGS}}=-H_kg_k.
$$

这里的 $H_k$ 会根据不同方向的曲率自动缩放梯度。因此在狭长谷底问题中，BFGS 通常比普通梯度下降少很多震荡。

## 9. BFGS 算法流程

标准流程：

```text
给定 x0，取 H0 = I
for k = 0, 1, 2, ...
    gk = ∇f(xk)
    若 ||gk|| 足够小，停止
    pk = -Hk gk
    用线搜索选择 αk
    xk+1 = xk + αk pk
    sk = xk+1 - xk
    yk = ∇f(xk+1) - ∇f(xk)
    若 yk^T sk > 0:
        用 BFGS 公式更新 Hk+1
    否则:
        跳过更新或重置 Hk+1
```

对应 Python 骨架：

```python
def bfgs(f, grad_f, x0, max_iter=200, tol=1e-6):
    x = x0.copy()
    n = len(x)
    H = np.eye(n)
    history = []

    for k in range(max_iter):
        g = grad_f(x)
        value = f(x)
        history.append(value)

        if np.linalg.norm(g) < tol:
            break

        p = -H @ g
        alpha = backtracking_line_search(f, x, p, g)

        x_new = x + alpha * p
        g_new = grad_f(x_new)

        s = x_new - x
        y = g_new - g
        ys = y @ s

        if ys > 1e-12:
            rho = 1.0 / ys
            I = np.eye(n)
            V = I - rho * np.outer(s, y)
            H = V @ H @ V.T + rho * np.outer(s, s)

        x = x_new

    return x, history
```

## 10. DFP 和 BFGS 的区别

DFP 也是 quasi-Newton 方法，也可以维护 inverse Hessian 近似：

$$
H_{k+1}^{\mathrm{DFP}}
=
H_k
+
\frac{s_ks_k^\top}{s_k^\top y_k}
-
\frac{H_ky_ky_k^\top H_k}{y_k^\top H_ky_k}.
$$

BFGS 为：

$$
H_{k+1}^{\mathrm{BFGS}}
=
(I-\rho_ks_ky_k^\top)H_k(I-\rho_ky_ks_k^\top)
+
\rho_ks_ks_k^\top.
$$

二者都满足割线方程：

$$
H_{k+1}y_k=s_k.
$$

但实践中 BFGS 通常更稳定，对数值误差和线搜索更友好，因此成为最常用的 quasi-Newton 方法之一。

## 11. BFGS 的收敛性质

粗略记忆：

1. 梯度下降通常线性收敛；
2. Newton 在局部通常二次收敛；
3. BFGS 在合适条件下通常超线性收敛。

超线性收敛可以理解为比普通线性收敛快，但一般不承诺达到 Newton 的二次收敛：

$$
\frac{\|x_{k+1}-x^\star\|}{\|x_k-x^\star\|}
\to
0.
$$

常见条件包括：

1. $f$ 足够光滑；
2. 最优点附近 Hessian 正定；
3. 线搜索满足适当 Wolfe 条件；
4. 初始点进入了合适的局部区域。

## 12. BFGS 的优缺点

优点：

1. 不需要显式计算 Hessian；
2. 通常比梯度下降快得多；
3. 在中小规模光滑优化中非常强；
4. 若维护 $H_k$，每步方向计算简单；
5. 在合适条件下能保持下降方向。

缺点：

1. 需要存储 $n\times n$ 矩阵，内存为 $O(n^2)$；
2. 每步矩阵更新和矩阵向量乘法成本不低；
3. 对非光滑目标函数不太适合；
4. 若线搜索不好，可能破坏曲率条件；
5. 在超大规模机器学习问题中通常要改用 L-BFGS。

## 13. 大规模版本：L-BFGS

普通 BFGS 存储：

$$
H_k\in\mathbb{R}^{n\times n}.
$$

内存成本是：

$$
O(n^2).
$$

当 $n$ 很大时不可接受。

L-BFGS 的思想是：不存完整矩阵 $H_k$，只保存最近 $m$ 步的：

$$
(s_i,y_i).
$$

然后用 two-loop recursion 隐式计算：

$$
H_kg_k.
$$

内存成本从：

$$
O(n^2)
$$

降为：

$$
O(mn),
$$

其中 $m$ 通常取 $5$ 到 $20$。

所以对大规模问题，常用选择是：

$$
\boxed{\text{L-BFGS，而不是 full BFGS。}}
$$

## 14. 一句话总结

BFGS 是一种 quasi-Newton 方法。它通过：

$$
s_k=x_{k+1}-x_k,
\qquad
y_k=\nabla f(x_{k+1})-\nabla f(x_k)
$$

学习函数的局部曲率，并维护一个 Hessian inverse 近似：

$$
H_k\approx \nabla^2 f(x_k)^{-1}.
$$

因此它的方向：

$$
p_k=-H_k\nabla f(x_k)
$$

可以看成“被曲率校正过的梯度方向”。它比梯度下降更聪明，比 Newton 更省 Hessian 计算，是中小规模光滑无约束优化里的经典强方法。

