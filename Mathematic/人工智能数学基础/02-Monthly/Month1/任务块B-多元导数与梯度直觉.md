---
created: 2026-04-28
type: note
status: active
tags: [math, llm, month1, calculus, gradient]
summary: "Month 1 的第二个任务块：多元导数与梯度直觉。"
---

# 任务块 B：多元导数与梯度直觉

## 目标
完成这个任务块时，希望你能做到：
- 理解偏导数、梯度、链式法则
- 理解梯度为什么描述局部最陡上升方向
- 会对简单标量目标函数求导
- 能把“梯度”看成模型训练里的基本语言，而不是纯数学符号

## 建议时长
- 如果基础较弱：`7 - 10` 天
- 如果你大概率已经理解：`3 - 5` 天快速过关

## 核心内容
### 1. 偏导数
你需要会看懂：

$$
\frac{\partial f}{\partial x_i}
$$

它表示：固定其他变量，只看某个变量变化时，函数怎么变。

### 2. 梯度
对标量函数

$$
f(x_1, \dots, x_n),
$$

梯度写成

$$
\nabla f =
\begin{bmatrix}
\frac{\partial f}{\partial x_1} \\
\vdots \\
\frac{\partial f}{\partial x_n}
\end{bmatrix}.
$$

它可以理解成：
- 每个方向的局部变化率
- 合起来形成一个“最敏感方向”的向量

### 3. 链式法则
这是训练推导里最常见的工具。  
如果一个量通过多层函数依赖另一个量，那么导数会沿路径传递。

这就是为什么反向传播本质上是在反复使用链式法则。

### 4. 梯度下降直觉
若要最小化 $f(\theta)$，常见更新为

$$
\theta_{t+1} = \theta_t - \eta \nabla f(\theta_t).
$$

最该理解的不是公式外形，而是：
- 梯度指向局部上升最快方向
- 减去梯度，就是往局部下降方向走

## 在 ML 里的对应
这个任务块最直接对应：
- 线性回归损失的求导
- logistic / cross-entropy 的导数
- 反向传播
- 为什么参数更新长得像

$$
\theta \leftarrow \theta - \eta g
$$

## 学习资源
### 主线资源
- MIT OpenCourseWare 18.02 Multivariable Calculus  
  [MIT OCW 18.02](https://ocw.mit.edu/courses/mathematics/18-02-multivariable-calculus-fall-2007/)

### 面向 ML 的过桥材料
- Stanford CS229 线性代数与矩阵求导复习  
  [CS229 Linear Algebra Review](https://cs229.stanford.edu/notes2022fall/cs229-linear_algebra_review.pdf)

### 说明
任务块 B 不需要把 18.02 全部学完。只优先盯这些主题：
- partial derivatives
- gradient
- chain rule
- optimization 的最基本直觉

## 关键概念笔记
- [[任务块B-关键概念笔记|任务块 B：关键概念笔记]]

## 如果你大概率已经理解，怎么快速通过
不要重学整套内容，直接做 `快速过关自测`。

### 快速过关标准
如果你能独立完成下面 4 件事，就可以认为任务块 B 基本通过：

1. 不查资料写出梯度定义
2. 自己推：

$$
f(x, y) = x^2 + 3xy + y^2
$$

的梯度
3. 解释为什么梯度下降里要减梯度而不是加梯度
4. 说清楚链式法则和反向传播的关系

### 快速过关输出
- 写一页笔记：`梯度到底在描述什么`
- 手推一个简单二元函数的梯度
- 用自己的话解释反向传播为什么本质上是链式法则

## 最低完成标准
- 看见 $\nabla f$ 不再发怵
- 能对简单函数求梯度
- 能解释梯度更新式的含义
- 能把链式法则和训练联系起来
