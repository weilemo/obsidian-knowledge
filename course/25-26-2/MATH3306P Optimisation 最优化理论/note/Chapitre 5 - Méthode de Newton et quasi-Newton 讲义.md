# Chapitre 5：Méthode de Newton et quasi-Newton

来源：

- [[../Materials/Slides/Slides_Chp5.pdf|Slides_Chp5.pdf]]
- [[../Materials/General/Poly_Optimisation.pdf|Poly_Optimisation.pdf]]

本章讨论**Newton 方法与 quasi-Newton 方法**。第 4 章的梯度下降只使用一阶信息 $\nabla f(x)$，本章的方法开始使用二阶信息，也就是 Hessian 矩阵 $H_f(x)$，从而获得更快的局部收敛速度。

本讲主线：

1. Newton 方法的来源；
2. 二阶 Taylor 近似；
3. Newton 方向与 Newton 迭代；
4. Newton 与梯度下降的区别；
5. Newton 的局部/全局收敛；
6. Newton 方法的风险；
7. quasi-Newton 方法；
8. 割线方程；
9. SR1、DFP、BFGS 更新；
10. Gauss-Newton 与 Levenberg-Marquardt 背景。

## 1. Newton 方法想解决什么

无约束优化问题为：

$$
\min_{x\in\mathbb{R}^n} f(x).
$$

在可微情形下，局部极小点的必要条件是：

$$
\nabla f(x^\star)=0.
$$

所以，优化问题可以转化为求解非线性方程：

$$
F(x)=0,
\qquad
F(x)=\nabla f(x).
$$

Newton 方法本质上不是专门的优化方法，而是求非线性方程零点的方法。把它用于优化，就是把 Newton 方法应用到：

$$
\nabla f(x)=0.
$$

## 2. 二阶 Taylor 近似

设 $f:\mathbb{R}^n\to\mathbb{R}$ 二次可微。在当前点 $x_k$ 附近，对 $f$ 做二阶 Taylor 展开：

$$
f(x_k+d)
\approx
f(x_k)
+
\langle \nabla f(x_k),d\rangle
+
\frac12 \langle H_f(x_k)d,d\rangle.
$$

记这个二次近似模型为：

$$
m_k(d)
=
f(x_k)
+
\langle \nabla f(x_k),d\rangle
+
\frac12 d^\top H_f(x_k)d.
$$

Newton 方法的想法是：不直接最小化原函数 $f$，而是在当前点附近最小化这个二次模型 $m_k(d)$。

对 $d$ 求梯度：

$$
\nabla m_k(d)
=
\nabla f(x_k)+H_f(x_k)d.
$$

令其为零：

$$
\nabla f(x_k)+H_f(x_k)d=0.
$$

若 $H_f(x_k)$ 可逆，则：

$$
d_k
=
-H_f(x_k)^{-1}\nabla f(x_k).
$$

这就是 Newton 方向。

## 3. Newton 迭代公式

最基本的 Newton 方法取完整步长：

$$
x_{k+1}
=
x_k+d_k
=
x_k-H_f(x_k)^{-1}\nabla f(x_k).
$$

算法形式：

```text
给定 x0 和容差 ε
while ||∇f(xk)|| ≥ ε:
    dk = - Hf(xk)^(-1) ∇f(xk)
    xk+1 = xk + dk
return xk
```

实际计算中通常不直接求逆，而是解线性方程组：

$$
H_f(x_k)d_k=-\nabla f(x_k).
$$

这样比显式计算 $H_f(x_k)^{-1}$ 更稳定。

## 4. Newton 方向什么时候是下降方向

若 Hessian 正定：

$$
H_f(x_k)\succ 0,
$$

则 Newton 方向是下降方向。

证明：

$$
d_k=-H_f(x_k)^{-1}\nabla f(x_k).
$$

于是：

$$
\langle \nabla f(x_k),d_k\rangle
=
-\nabla f(x_k)^\top H_f(x_k)^{-1}\nabla f(x_k).
$$

如果 $H_f(x_k)\succ 0$，则 $H_f(x_k)^{-1}\succ 0$，因此只要 $\nabla f(x_k)\ne 0$：

$$
\nabla f(x_k)^\top H_f(x_k)^{-1}\nabla f(x_k)>0.
$$

所以：

$$
\langle \nabla f(x_k),d_k\rangle<0.
$$

这说明 Newton 方向确实是下降方向。

## 5. Newton 与梯度下降的区别

梯度下降：

$$
x_{k+1}=x_k-\delta_k\nabla f(x_k).
$$

Newton 方法：

$$
x_{k+1}=x_k-H_f(x_k)^{-1}\nabla f(x_k).
$$

核心区别：

| 方法 | 使用信息 | 方向 | 每步成本 | 收敛速度 |
|---|---|---|---|---|
| 梯度下降 | 一阶梯度 | $-\nabla f(x_k)$ | 低 | 通常线性 |
| Newton | 梯度 + Hessian | $-H_f(x_k)^{-1}\nabla f(x_k)$ | 高 | 局部二次 |

Newton 方法不仅知道“哪里下降最快”，还知道函数在不同方向上的弯曲程度。它会根据 Hessian 自动缩放不同方向，因此在狭长谷底问题中通常比梯度下降快很多。

## 6. Newton 方法为什么快

如果 $f$ 本身就是二次函数：

$$
f(x)=\frac12 x^\top A x-b^\top x+c,
\qquad A\succ 0,
$$

则：

$$
\nabla f(x)=Ax-b,
\qquad
H_f(x)=A.
$$

Newton 一步：

$$
x_{k+1}
=
x_k-A^{-1}(Ax_k-b)
=
A^{-1}b.
$$

这正是全局最小点。因此对严格凸二次函数，Newton 方法理论上一部到位。

对一般非二次函数，Newton 方法在最优点附近用二次模型近似原函数，所以局部收敛速度非常快。

## 7. Newton 的收敛结论

讲义中假设存在 $0<m\le M$，使得：

$$
m\|h\|^2
\le
\langle H_f(x)h,h\rangle
\le
M\|h\|^2,
$$

并且 Hessian 满足 Lipschitz 条件：

$$
\|H_f(x)-H_f(y)\|
\le
L\|x-y\|.
$$

在这些条件下，Newton 方法会收敛，并在靠近最优点时具有**二次收敛**：

$$
\|x_{k+1}-x^\star\|
\le
C\|x_k-x^\star\|^2.
$$

二次收敛的意思是：误差会近似平方级下降。若当前误差约为 $10^{-3}$，下一步可能降到 $10^{-6}$ 量级，再下一步到 $10^{-12}$ 量级。

这也是为什么讲义中说 Newton 进入二次收敛阶段后，通常只需要很少几步就能达到很高精度。

## 8. Newton 方法的局部性

基本 Newton 方法的缺点是：它通常只保证**局部收敛**。

也就是说，如果初始点 $x_0$ 足够靠近最优点，Newton 会很快收敛；但如果初始点太远，则可能：

- 不下降；
- 震荡；
- 跑到很远；
- Hessian 不可逆；
- 分母接近零导致巨大步长；
- 直接发散。

讲义中给了求零点的反例：

$$
F(x)=x^3-\frac12x+1.
$$

当初始点选在某些位置时，切线斜率非常小，Newton 更新：

$$
x_{k+1}=x_k-\frac{F(x_k)}{F'(x_k)}
$$

会产生很大的跳跃，导致迭代远离零点。

## 9. 全局 Newton 方法

为了改善局部 Newton 的不稳定性，可以给 Newton 方向加步长：

$$
x_{k+1}=x_k+\delta_k d_k,
\qquad
d_k=-H_f(x_k)^{-1}\nabla f(x_k).
$$

其中 $\delta_k>0$ 可以通过：

- 最优线搜索；
- Armijo 回溯法；

来选择。

这称为全局 Newton 方法。

算法形式：

```text
while ||∇f(xk)|| ≥ ε:
    dk = -Hf(xk)^(-1) ∇f(xk)
    用线搜索选择 δk
    xk+1 = xk + δk dk
```

直观理解：

- 离最优点远时，用较小步长保证稳定下降；
- 离最优点近时，通常接受完整 Newton 步 $\delta_k=1$；
- 进入局部区域后恢复 Newton 的二次收敛速度。

## 10. Newton 方法的计算代价

Newton 每步需要：

1. 计算梯度 $\nabla f(x_k)$；
2. 计算 Hessian $H_f(x_k)$；
3. 解线性系统 $H_f(x_k)d_k=-\nabla f(x_k)$。

如果变量维度很大，Hessian 是 $n\times n$ 矩阵：

- 存储成本约为 $O(n^2)$；
- 直接求解线性系统通常约为 $O(n^3)$；
- 若 Hessian 不可逆或不正定，Newton 方向可能不存在或不是下降方向。

这就是 quasi-Newton 方法出现的原因。

## 11. Quasi-Newton 方法的想法

Quasi-Newton 方法希望保留 Newton 方法“利用曲率”的优点，但避免每一步都显式计算 Hessian。

基本想法：

- 用矩阵 $B_k$ 近似 Hessian：

$$
B_k\approx H_f(x_k).
$$

- 或用矩阵 $G_k$ 近似 Hessian 的逆：

$$
G_k\approx H_f(x_k)^{-1}.
$$

于是方向为：

$$
d_k=-B_k^{-1}\nabla f(x_k),
$$

或：

$$
d_k=-G_k\nabla f(x_k).
$$

然后更新：

$$
x_{k+1}=x_k+\delta_k d_k.
$$

## 12. 割线方程

定义：

$$
\Delta_k=x_{k+1}-x_k,
$$

$$
\gamma_k=\nabla f(x_{k+1})-\nabla f(x_k).
$$

由梯度的一阶 Taylor 展开：

$$
\nabla f(x_{k+1})
\approx
\nabla f(x_k)+H_f(x_{k+1})(x_{k+1}-x_k).
$$

因此希望 Hessian 近似矩阵满足：

$$
B_{k+1}\Delta_k=\gamma_k.
$$

这叫 quasi-Newton 条件或割线方程。

若使用逆 Hessian 近似 $G_{k+1}$，则对应条件为：

$$
G_{k+1}\gamma_k=\Delta_k.
$$

这些条件来自“用梯度变化估计曲率”。

## 13. 为什么更新矩阵不唯一

在 $n$ 维情形中，$B_{k+1}$ 是 $n\times n$ 矩阵，有很多未知数；而方程：

$$
B_{k+1}\Delta_k=\gamma_k
$$

只提供 $n$ 个线性约束。

所以满足割线方程的矩阵有无穷多个。

为了选一个好矩阵，通常还要求：

- 对称性；
- 正定性；
- 更新尽量简单；
- 尽量接近上一轮矩阵；
- 计算成本低。

于是产生了 SR1、DFP、BFGS 等更新公式。

## 14. SR1：秩一修正

SR1 的想法是：

$$
B_{k+1}=B_k+C_k,
$$

其中 $C_k$ 是秩一矩阵。

讲义给出的 Hessian 近似更新为：

$$
B_{k+1}
=
B_k
+
\frac{
(\gamma_k-B_k\Delta_k)(\gamma_k-B_k\Delta_k)^\top
}{
(\gamma_k-B_k\Delta_k)^\top\Delta_k
}.
$$

如果更新逆 Hessian 近似，则：

$$
G_{k+1}
=
G_k
+
\frac{
(\Delta_k-G_k\gamma_k)(\Delta_k-G_k\gamma_k)^\top
}{
(\Delta_k-G_k\gamma_k)^\top\gamma_k
}.
$$

SR1 形式简单，但不一定保持正定性，因此实际使用时要小心。

## 15. DFP 方法

DFP 使用 $G_k$ 近似 Hessian 的逆：

$$
G_k\approx H_f(x_k)^{-1}.
$$

更新目标是满足：

$$
G_{k+1}\gamma_k=\Delta_k.
$$

DFP 更新公式为：

$$
G_{k+1}
=
G_k
+
\frac{\Delta_k\Delta_k^\top}{\Delta_k^\top\gamma_k}
-
\frac{G_k\gamma_k\gamma_k^\top G_k}
{\gamma_k^\top G_k\gamma_k}.
$$

如果 $G_0$ 正定，并且满足曲率条件：

$$
\Delta_k^\top\gamma_k>0,
$$

则 $G_k$ 可以保持正定。

方向为：

$$
d_k=-G_k\nabla f(x_k).
$$

## 16. BFGS 方法

BFGS 是最常用的 quasi-Newton 方法之一。

它通常更新 Hessian 近似 $B_k$：

$$
B_k\approx H_f(x_k).
$$

要求：

$$
B_{k+1}\Delta_k=\gamma_k.
$$

讲义中的 BFGS 更新公式为：

$$
B_{k+1}
=
B_k
+
\frac{\gamma_k\gamma_k^\top}{\gamma_k^\top\Delta_k}
-
\frac{B_k\Delta_k\Delta_k^\top B_k}
{\Delta_k^\top B_k\Delta_k}.
$$

如果用逆 Hessian 近似 $G_k=B_k^{-1}$，可写成：

$$
G_{k+1}
=
\left(I-\frac{\Delta_k\gamma_k^\top}{\Delta_k^\top\gamma_k}\right)
G_k
\left(I-\frac{\Delta_k\gamma_k^\top}{\Delta_k^\top\gamma_k}\right)^\top
+
\frac{\Delta_k\Delta_k^\top}{\Delta_k^\top\gamma_k}.
$$

BFGS 的优点：

- 不需要显式 Hessian；
- 通常保持正定性；
- 收敛快；
- 在中等规模无约束优化中非常常用。

## 17. DFP 和 BFGS 的关系

DFP 和 BFGS 都利用同样的信息：

$$
\Delta_k=x_{k+1}-x_k,
\qquad
\gamma_k=\nabla f(x_{k+1})-\nabla f(x_k).
$$

区别在于：

- DFP 主要更新逆 Hessian 近似 $G_k$；
- BFGS 主要更新 Hessian 近似 $B_k$，也可转写成逆形式；
- 实践中 BFGS 通常比 DFP 更稳定、更常用。

可以把它们都理解为：通过每一步观察到的“位置变化”和“梯度变化”，不断学习函数的局部曲率。

## 18. Gauss-Newton 方法

Slides 中提到 Gauss-Newton，它主要用于非线性最小二乘问题：

$$
\min_x \frac12\|r(x)\|^2
=
\frac12\sum_{i=1}^m r_i(x)^2.
$$

设 $J(x)$ 是残差向量 $r(x)$ 的 Jacobian，则：

$$
\nabla f(x)=J(x)^\top r(x).
$$

Newton Hessian 含有二阶导项；Gauss-Newton 用近似：

$$
H_f(x)\approx J(x)^\top J(x).
$$

于是方向通过解：

$$
J(x_k)^\top J(x_k)d_k
=
-J(x_k)^\top r(x_k)
$$

得到。

Gauss-Newton 避免了一部分二阶导计算，特别适合残差较小的最小二乘问题。

## 19. Levenberg-Marquardt 方法

Levenberg-Marquardt 方法常用于非线性最小二乘，它可以看作 Gauss-Newton 和梯度下降之间的折中。

典型形式为：

$$
\left(J^\top J+\lambda I\right)d
=
-J^\top r.
$$

当 $\lambda$ 很小时，它接近 Gauss-Newton；当 $\lambda$ 很大时，它更像梯度下降。

优点：

- 缓解 $J^\top J$ 奇异或病态的问题；
- 比纯 Newton/Gauss-Newton 更稳；
- 在图像配准、相机标定、曲线拟合等问题中常见。

Slides 中用图像防抖/去模糊作为动机：需要在很短时间里估计平移、旋转等参数，最小化新图像和参考图像之间的像素差异平方和。这类问题天然适合最小二乘、Gauss-Newton 和 LM。

## 20. 本章例子：求 $\sqrt{3}$

讲义用 Newton 方法求：

$$
F(x)=x^2-3=0.
$$

Newton 公式为：

$$
x_{k+1}
=
x_k-\frac{F(x_k)}{F'(x_k)}
=
x_k-\frac{x_k^2-3}{2x_k}.
$$

整理得：

$$
x_{k+1}
=
\frac12\left(x_k+\frac{3}{x_k}\right).
$$

从 $x_0=1$ 出发，几步就能逼近：

$$
\sqrt{3}\approx 1.7320508.
$$

这说明 Newton 方法在合适初值附近非常快。

## 21. 易错点

### 21.1 Newton 方向不总是下降方向

只有当 Hessian 正定时，Newton 方向才一定是下降方向。若 Hessian 不定或负定，方向可能不是下降方向。

### 21.2 Newton 不是一定比梯度下降好

Newton 迭代次数通常少，但每步成本高。高维问题中 Hessian 的计算和线性系统求解可能非常昂贵。

### 21.3 不要直接求逆

公式写作：

$$
d_k=-H_f(x_k)^{-1}\nabla f(x_k),
$$

但实际计算应解：

$$
H_f(x_k)d_k=-\nabla f(x_k).
$$

直接求逆通常更慢且数值上更不稳定。

### 21.4 Quasi-Newton 不是随便造矩阵

近似矩阵必须尽量满足割线方程，并最好保持对称正定。否则方向可能不再是下降方向。

## 22. 本章总结

第 4 章梯度下降使用一阶模型：

$$
f(x_k+d)\approx f(x_k)+\langle \nabla f(x_k),d\rangle.
$$

第 5 章 Newton 使用二阶模型：

$$
f(x_k+d)
\approx
f(x_k)+\langle \nabla f(x_k),d\rangle
+
\frac12 d^\top H_f(x_k)d.
$$

由此得到 Newton 方向：

$$
d_k=-H_f(x_k)^{-1}\nabla f(x_k).
$$

Newton 方法局部很快，通常具有二次收敛；但它依赖 Hessian，计算成本高，且对初值和 Hessian 性质敏感。

Quasi-Newton 方法用 $B_k$ 或 $G_k$ 近似 Hessian 或其逆，通过：

$$
B_{k+1}\Delta_k=\gamma_k,
\qquad
G_{k+1}\gamma_k=\Delta_k
$$

逐步学习曲率信息。DFP 和 BFGS 是典型代表，其中 BFGS 在实践中尤其常用。

