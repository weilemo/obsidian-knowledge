# TP2 - Optimisation sans contrainte 解题思路

相关文件：

- [[../Materials/Notebooks/Td-Tp 2_énoncé.ipynb]]
- [[../Materials/Notebooks/Td-Tp 2-sup_énoncé.ipynb]]

## 这个 TP 在做什么

这个 TP 的主题是 **无约束优化与梯度下降**。题目用一个三维无人机轨迹规划问题，把抽象的优化问题具体化：

给定一串轨迹点

$$
\mathbf{x} = (\mathbf{x}_1,\mathbf{x}_2,\dots,\mathbf{x}_N),
\qquad
\mathbf{x}_i=(x_i,y_i,z_i)\in \mathbb{R}^3,
$$

希望通过优化这些点的位置，让轨迹同时满足三件事：

1. 路径尽量短；
2. 路径尽量平滑；
3. 尽量避开球形障碍物。

所以这不是在求某个简单函数的最小值，而是在把一个实际问题写成一个目标函数 $J(\mathbf{x})$，然后用梯度下降去最小化它。

## 核心建模

目标函数由三部分组成：

$$
J(\mathbf{x})
=
\alpha J_{\mathrm{length}}(\mathbf{x})
+
\beta J_{\mathrm{smooth}}(\mathbf{x})
+
\gamma J_{\mathrm{collision}}(\mathbf{x}).
$$

其中 $\alpha,\beta,\gamma$ 是权重，用来控制三类需求的重要性。

### 1. 路径长度

相邻点之间的距离之和：

$$
J_{\mathrm{length}}(\mathbf{x})
=
\sum_{i=1}^{N-1}\|\mathbf{x}_{i+1}-\mathbf{x}_i\|.
$$

这一项越小，轨迹越短。

代码里对应：

```python
path_length += np.linalg.norm(x[i+1] - x[i])
```

### 2. 平滑项

用二阶差分衡量轨迹弯折程度：

$$
J_{\mathrm{smooth}}(\mathbf{x})
=
\sum_{i=2}^{N-1}
\|\mathbf{x}_{i+1}-2\mathbf{x}_i+\mathbf{x}_{i-1}\|^2.
$$

如果连续三个点接近共线且间距变化平缓，那么

$$
\mathbf{x}_{i+1}-2\mathbf{x}_i+\mathbf{x}_{i-1}
$$

会比较小。这个量可以理解为离散版本的“加速度”或“曲率”。

代码里对应：

```python
curvature += np.linalg.norm(x[i+1] - 2*x[i] + x[i-1])**2
```

### 3. 避障惩罚

每个障碍物是一个球：

$$
B(c_j,r_j)=\{x:\|x-c_j\|\le r_j\}.
$$

如果轨迹点 $\mathbf{x}_i$ 离障碍物中心的距离小于半径，就说明进入障碍物，需要罚：

$$
\max(0,r_j-\|\mathbf{x}_i-c_j\|)^2.
$$

所以碰撞惩罚为：

$$
J_{\mathrm{collision}}(\mathbf{x})
=
\sum_i\sum_j
\max(0,r_j-\|\mathbf{x}_i-c_j\|)^2.
$$

代码里对应：

```python
distance = np.linalg.norm(x[i] - obstacle["center"])
violation = max(0.0, obstacle["radius"] - distance)
collision_penalty += violation**2
```

如果点在障碍物外，$r_j-\|\mathbf{x}_i-c_j\|<0$，惩罚为 $0$；如果点在障碍物内，惩罚随进入深度二次增长。

## 理论题思路

### 连续性

要证明 $J$ 连续，只需要逐项看：

- 欧氏范数 $\|x\|$ 连续；
- 线性组合 $x_{i+1}-x_i$、$x_{i+1}-2x_i+x_{i-1}$ 连续；
- 平方函数连续；
- $\max(0,t)$ 连续；
- 有限个连续函数相加仍然连续。

所以 $J$ 是连续函数。

### 极小值存在性

如果我们把所有点限制在一个闭有界区域里，例如：

$$
\mathbf{x}_i\in [0,3]^3,
$$

那么可行域是紧集，$J$ 又连续。由 Weierstrass 定理，$J$ 一定能取到全局最小值。

注意：如果完全没有边界约束，严格地说就不能只靠这几项直接保证全局 minimizer 一定存在。TP 的数值实验默认点都在有限区域内活动，所以从实验角度可以讨论存在性。

### 唯一性

不能保证唯一。

原因是障碍物惩罚项让问题通常不是凸的。比如一条路径可以从障碍物左边绕，也可以从右边绕，两个方案可能成本接近甚至相同。所以梯度下降可能收敛到不同的局部最优点。

## 梯度下降在这里怎么用

目标是最小化：

$$
\min_x J(x).
$$

梯度下降的基本迭代公式是：

$$
x^{(k+1)}
=
x^{(k)}-\eta \nabla J(x^{(k)}),
$$

其中 $\eta>0$ 是 learning rate，也叫步长。

这道 TP 没有手推解析梯度，而是用有限差分近似：

$$
\frac{\partial J}{\partial x_i}
\approx
\frac{J(x+\varepsilon e_i)-J(x)}{\varepsilon}.
$$

代码思路是：

1. 先算当前函数值 $J(x)$；
2. 对每个坐标 $x_i$ 加一个很小扰动 $\varepsilon$；
3. 再算扰动后的函数值；
4. 用差商近似偏导数。

这就是 `gradient` 函数在做的事情。

## BGD 和 SGD 的区别

### BGD

BGD 是 batch gradient descent。它每次计算完整梯度：

$$
x^{(k+1)}
=
x^{(k)}-\eta \nabla J(x^{(k)}).
$$

优点：

- 方向稳定；
- 函数下降更平滑；
- 轨迹结果通常更可靠。

缺点：

- 每轮都要对所有坐标估计梯度；
- 计算更慢。

### SGD

这个 TP 里的 SGD 是简化版本：每次只随机选一个坐标，估计这个坐标方向上的偏导数，然后只更新这一维：

$$
x_i^{(k+1)}
=
x_i^{(k)}-\eta \frac{\partial J}{\partial x_i}(x^{(k)}).
$$

优点：

- 单次迭代便宜；
- 有时能较快移动。

缺点：

- 更新方向随机，波动更大；
- 轨迹可能不如 BGD 平滑；
- 对 learning rate 更敏感。

## 参数怎么理解

目标函数是：

$$
J
=
\alpha J_{\mathrm{length}}
+
\beta J_{\mathrm{smooth}}
+
\gamma J_{\mathrm{collision}}.
$$

- $\alpha$ 大：更重视路径短；
- $\beta$ 大：更重视路径平滑；
- $\gamma$ 大：更重视避开障碍物。

如果 $\gamma$ 太小，轨迹可能穿过障碍物，因为碰撞代价不够高。  
如果 $\gamma$ 太大，函数在障碍物附近会很陡，梯度下降可能更不稳定。

learning rate $\eta$ 的影响：

- $\eta$ 太小：收敛慢；
- $\eta$ 合适：稳定下降；
- $\eta$ 太大：震荡甚至发散。

## 补充 TP：Armijo 和回溯法在做什么

补充 TP 研究的是 **步长选择**。

固定步长的问题是：我们事先很难知道 $\eta$ 该取多大。太小慢，太大炸。

### Armijo 条件

给定当前位置 $x$ 和下降方向 $d$，Armijo 条件要求：

$$
f(x+td)
\le
f(x)+\alpha t\langle \nabla f(x),d\rangle,
$$

其中 $0<\alpha<1$。

如果 $d$ 是下降方向，那么：

$$
\langle \nabla f(x),d\rangle < 0.
$$

所以右边比 $f(x)$ 小。Armijo 条件的意思是：新点不只是下降一点点，而是要达到足够下降。

### 回溯法

回溯法从 $t=1$ 开始试。如果不满足 Armijo 条件，就缩小步长：

$$
t \leftarrow \beta t,
\qquad 0<\beta<1.
$$

直到满足 Armijo 条件为止。

代码思路：

```python
t = 1.0
while not armijo_condition(f, grad_f, x, d, t, alpha):
    t = beta * t
```

然后更新：

$$
x^{(k+1)}=x^{(k)}+t d.
$$

在梯度下降里，通常取：

$$
d=-\nabla f(x).
$$

## 这份 TP 的完成路线

完成时按这个顺序想：

1. 先理解变量：优化变量不是一个点，而是一整条轨迹的所有坐标。
2. 写出目标函数三项：长度、平滑、避障。
3. 证明目标函数连续，并讨论存在性和非唯一性。
4. 用有限差分写数值梯度。
5. 用完整梯度写 BGD 更新：

$$
x_{\text{new}}=x-\eta \nabla J(x).
$$

6. 用随机单坐标更新写 SGD。
7. 比较 BGD 和 SGD 的稳定性、速度、轨迹质量。
8. 在补充 TP 中，用 Armijo + backtracking 替代固定步长。

## 一句话总结

主 TP2 是：把三维轨迹规划建模成无约束优化问题，然后用 BGD/SGD 最小化目标函数。  
补充 TP2 是：研究梯度下降里步长怎么选，为什么 Armijo 和 backtracking 比固定步长更稳。

