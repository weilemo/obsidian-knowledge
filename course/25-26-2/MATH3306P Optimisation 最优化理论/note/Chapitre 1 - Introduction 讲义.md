# Chapitre 1：Introduction

来源：[[PPT/Slides_Chp1.pdf|Slides_Chp1.pdf]]

## 1. 课程概览

本课程讨论如何把实际问题抽象为优化模型，并进一步研究最优性条件与求解算法。课程总学时为 32 小时，其中 16 小时课程、16 小时 TD/TP。先修知识包括线性代数、拓扑、微分学。

课程主要内容：

1. Introduction et rappels：优化建模与基础回顾
2. Condition d'optimalité sans contrainte：无约束最优性条件
3. Méthode de gradient：梯度法
4. Méthode de Newton：牛顿法
5. Condition d'optimalité avec contraintes：有约束最优性条件
6. Algorithme du simplexe：单纯形法
7. Autres méthodes primales：其他原始方法

参考资料：

- Kong Sijia, *Poly-Optimization*
- Niu Yishuai, *Optimization*
- Stephen Boyd, Lieven Vandenberghe, *Convex Optimization*

## 2. 什么是优化

优化的核心问题是：在给定条件下，从可选方案中找到使目标最好的一组变量取值。

一个优化问题通常由三部分构成：

- **目标函数**：衡量方案优劣的函数。
- **决策变量**：可以被选择或控制的变量。
- **约束条件**：变量必须满足的限制，包括等式、不等式、取值范围等。

例如博物馆参观路线规划中，可以考虑两个目标：

- 尽量减少总路线长度；
- 尽量增加参观展品的重要性或数量。

若用 $x_i$ 表示是否参观第 $i$ 个展品，用 $y_{ij}$ 表示是否从展品 $i$ 走到展品 $j$，则 $x_i,y_{ij}$ 是决策变量。路线长度、展品重要性、参观时间等都可以被写成关于这些变量的函数。

典型约束包括：

- 总时间限制；
- 总距离限制；
- 展品访问限制；
- 不重复路径；
- 变量定义域，例如 $x_i,y_{ij}\in\{0,1\}$。

## 3. 优化模型的一般形式

优化问题可以写成：

$$
\min_{x\in D} f(x)
$$

其中：

- $x$ 是决策变量；
- $f(x)$ 是目标函数；
- $D$ 是可行域，即所有满足约束的点构成的集合。

若问题是最大化问题：

$$
\max_{x\in D} f(x)
$$

通常可以转化为最小化问题：

$$
\max_{x\in D} f(x)
\quad\Longleftrightarrow\quad
\min_{x\in D} -f(x)
$$

因此，很多理论默认研究最小化形式。

## 4. 多目标优化与加权合并

实际问题中经常存在多个目标。例如路线规划同时希望：

$$
\text{minimize distance}, \qquad \text{maximize visited exhibitions}.
$$

一种常见处理方法是先把所有目标统一成最小化，再加权合并。例如若 $L(x)$ 表示路线长度，$Q(x)$ 表示参观收益，则可以构造单目标：

$$
\min_x \ \alpha L(x)-\beta Q(x)
$$

其中 $\alpha,\beta\ge 0$ 是权重，表示两个目标的重要程度。权重的选择会影响最终方案，所以它本身也是建模中的重要判断。

## 5. 建模步骤

建立优化模型时，可以按以下顺序思考：

1. **确定决策变量**：问题中真正可以选择的量是什么？
2. **写出目标函数**：什么叫“更好”？利润最大、成本最小、误差最小、风险最小等。
3. **写出显式约束**：题目直接给出的限制，例如资源上限、需求平衡、时间限制。
4. **补充隐式约束**：变量的自然限制，例如非负性、整数性、二元性、概率和为 $1$ 等。

一个好模型不只是“把式子写出来”，还要确保每个变量、目标和约束都有明确的现实含义。

## 6. 无约束优化

无约束优化没有显式约束，可写为：

$$
\min_{x\in\mathbb{R}^n} f(x)
$$

或：

$$
\max_{x\in\mathbb{R}^n} f(x)
$$

虽然没有额外约束，但变量仍然属于某个定义域。后续的梯度法、牛顿法等通常先从无约束优化开始讨论。

## 7. 有约束优化

有约束优化的一般形式为：

$$
\begin{aligned}
\min_{x\in\mathbb{R}^n}\quad & f(x) \\
\text{s.t.}\quad & g_i(x)\le 0,\quad i=1,\dots,m,\\
& h_j(x)=0,\quad j=1,\dots,p.
\end{aligned}
$$

其中：

- $f(x)$ 是目标函数；
- $g_i(x)\le 0$ 是不等式约束；
- $h_j(x)=0$ 是等式约束；
- 所有满足约束的 $x$ 构成可行域。

若原问题是最大化：

$$
\begin{aligned}
\max_x\quad & f(x)\\
\text{s.t.}\quad & g_i(x)\le 0,\\
& h_j(x)=0,
\end{aligned}
$$

可以转化为：

$$
\begin{aligned}
\min_x\quad & -f(x)\\
\text{s.t.}\quad & g_i(x)\le 0,\\
& h_j(x)=0.
\end{aligned}
$$

## 8. 线性规划

线性规划（Linear Programming, LP / Optimisation linéaire）是目标函数和约束均为线性的优化问题。标准形式常写为：

$$
\begin{aligned}
\min_{x\in\mathbb{R}^n}\quad & c^\top x\\
\text{s.t.}\quad & Ax=b,\\
& x\ge 0.
\end{aligned}
$$

其中：

- $c^\top x$ 是线性目标函数；
- $Ax=b$ 是线性等式约束；
- $x\ge 0$ 是非负约束。

线性规划也可以写成不等式形式，例如：

$$
\begin{aligned}
\min_x\quad & c^\top x\\
\text{s.t.}\quad & Ax\le b.
\end{aligned}
$$

不同形式之间通常可以通过引入松弛变量、改变符号、拆分自由变量等方式转换。

## 9. 非线性规划

非线性规划（Nonlinear Programming, NLP / Optimisation non linéaire）至少包含一个非线性的目标函数或约束。一般形式为：

$$
\begin{aligned}
\min_{x\in\mathbb{R}^n}\quad & f(x)\\
\text{s.t.}\quad & g_i(x)\le 0,\quad i=1,\dots,m,\\
& h_j(x)=0,\quad j=1,\dots,p.
\end{aligned}
$$

其中 $f,g_i,h_j$ 可以是非线性函数。

博物馆路线规划虽然目标可以写成线性组合，但由于“是否访问”“是否经过路径”“不能重复”等约束可能带来乘积、逻辑或整数条件，因此整体通常不是简单线性规划，而更接近有约束的非线性或整数优化模型。

## 10. 例 1：玻璃厂生产问题

工厂生产两类产品：

- 啤酒杯箱数 $x$；
- 香槟杯箱数 $y$。

利润：

- 每箱啤酒杯利润 25 欧元；
- 每箱香槟杯利润 20 欧元。

资源限制：

- 每箱啤酒杯需要 10 kg 沙；
- 每箱香槟杯需要 6 kg 沙；
- 每日沙子最多 900 kg；
- 机器每小时可生产 15 箱任一产品；
- 每天最多工作 8 小时，因此总产量最多 $15\times 8=120$ 箱。

最大化利润模型：

$$
\begin{aligned}
\max_{x,y}\quad & 25x+20y\\
\text{s.t.}\quad & 10x+6y\le 900,\\
& x+y\le 120,\\
& x\ge 0,\quad y\ge 0.
\end{aligned}
$$

若采用最小化标准形式，可写为：

$$
\begin{aligned}
\min_{x,y}\quad & -25x-20y\\
\text{s.t.}\quad & 10x+6y\le 900,\\
& x+y\le 120,\\
& x\ge 0,\quad y\ge 0.
\end{aligned}
$$

这是一个线性规划问题，因为目标函数和所有约束都是线性的。

## 11. 例 2：运输问题

设有 $m$ 个仓库和 $n$ 个目的地：

- 仓库 $i$ 的供给量为 $d_i$；
- 目的地 $j$ 的需求量为 $b_j$；
- 从仓库 $i$ 运到目的地 $j$ 的单位运输成本为 $c_{ij}$；
- 决策变量 $x_{ij}$ 表示从 $i$ 运到 $j$ 的数量。

若总供给等于总需求：

$$
\sum_{i=1}^m d_i=\sum_{j=1}^n b_j
$$

则运输问题可建模为：

$$
\begin{aligned}
\min_{x_{ij}}\quad & \sum_{i=1}^m\sum_{j=1}^n c_{ij}x_{ij}\\
\text{s.t.}\quad & \sum_{j=1}^n x_{ij}=d_i,\quad i=1,\dots,m,\\
& \sum_{i=1}^m x_{ij}=b_j,\quad j=1,\dots,n,\\
& x_{ij}\ge 0,\quad i=1,\dots,m,\ j=1,\dots,n.
\end{aligned}
$$

该模型的目标是最小化总运输成本。

## 12. 例 3：股票投资组合

设投资组合包含三只资产 $A,B,C$，其平均收益率分别为 $r_A,r_B,r_C$，波动率分别为 $\sigma_A,\sigma_B,\sigma_C$。令 $x,y,z$ 为投资在三只资产上的权重。

基本约束为：

$$
x+y+z=1,\qquad x,y,z\ge 0.
$$

若要求平均收益率不低于 $\alpha$：

$$
r_Ax+r_By+r_Cz\ge \alpha.
$$

若暂时忽略资产之间的协方差，风险可以近似写为：

$$
\sigma_A^2x^2+\sigma_B^2y^2+\sigma_C^2z^2.
$$

于是投资组合模型可写为：

$$
\begin{aligned}
\min_{x,y,z}\quad & \sigma_A^2x^2+\sigma_B^2y^2+\sigma_C^2z^2\\
\text{s.t.}\quad & r_Ax+r_By+r_Cz\ge \alpha,\\
& x+y+z=1,\\
& x,y,z\ge 0.
\end{aligned}
$$

更一般地，若用权重向量 $w$ 和协方差矩阵 $\Sigma$，方差风险可写为：

$$
w^\top \Sigma w.
$$

这类模型通常是二次规划或非线性规划。

## 13. 整数变量与连续变量

变量类型会显著影响问题难度。

连续变量：

$$
x\in\mathbb{R}^n
$$

整数变量：

$$
x\in\mathbb{Z}^n
$$

自然数变量：

$$
x\in\mathbb{N}^n
$$

二元变量：

$$
x_i\in\{0,1\}
$$

连续性很重要：连续优化可以使用微分、梯度、凸性等工具；整数优化则通常需要组合搜索、分支定界、割平面等方法，计算上往往更困难。

## 14. 机器学习中的优化

机器学习可以理解为：根据由未知规律 $g$ 产生的数据，寻找一个模型函数 $f$ 来逼近它。训练过程通常就是优化问题。

### 14.1 回归

给定样本 $(x_i,y_i)$，回归常用平方损失：

$$
\min_f \sum_i \left(f(x_i)-y_i\right)^2.
$$

平方损失的优点是连续、可微，便于使用梯度类算法；但它对异常值也较敏感。

### 14.2 分类

分类的直接目标可以写成 0-1 损失：

$$
\sum_i \mathbf{1}\{f(x_i)\ne y_i\}.
$$

但 0-1 损失不连续、不可微，难以直接优化。二分类中常用 hinge loss 作为替代：

$$
\sum_i \max\{0,1-y_i f(x_i)\},\qquad y_i\in\{+1,-1\}.
$$

这体现了优化中的一个重要思想：为了可计算性，常用连续或凸的代理损失替代原始目标。

### 14.3 降维

降维希望把高维数据投影到较低维空间，同时尽量保留信息。若把中心化后的数据投影到方向 $w$ 上，投影为：

$$
w^\top x.
$$

在主成分分析（PCA）思想中，希望最大化投影后的方差。若数据矩阵为 $X$，可写成：

$$
\max_{\|w\|=1} w^\top X^\top X w.
$$

也可以等价写成最小化：

$$
\min_{\|w\|=1} -w^\top X^\top X w.
$$

## 15. 本章总结

本章的关键词是：**模型、标准形式、分类**。

建模三要素：

- 目标函数；
- 决策变量；
- 约束条件。

标准化思想：

- 最大化可以转化为最小化；
- 不等式可以通过松弛变量转化；
- 自由变量可以拆成两个非负变量；
- 复杂问题要先明确可行域。

常见分类：

- 无约束优化 vs 有约束优化；
- 线性规划 vs 非线性规划；
- 连续优化 vs 整数优化。

本章的核心训练不是求解，而是把现实语言转化成数学模型。只要能准确写出变量、目标函数和约束，就已经完成了优化问题最关键的第一步。

## 16. 课后练习提示

选择一个实际问题，例如家庭预算、健康饮食、学习时间规划等，构建优化模型。报告中应包括：

1. 问题描述；
2. 决策变量；
3. 目标函数；
4. 约束条件；
5. 如何转化为标准形式；
6. 可选：思考该问题可能用什么算法求解。

例如健康饮食规划可以令 $x_i$ 表示第 $i$ 种食物的摄入量，目标为最小化成本：

$$
\min_x \sum_i c_i x_i
$$

约束为营养摄入要求：

$$
\sum_i a_{ki}x_i\ge b_k,\quad k=1,\dots,K,
$$

以及非负约束：

$$
x_i\ge 0.
$$
