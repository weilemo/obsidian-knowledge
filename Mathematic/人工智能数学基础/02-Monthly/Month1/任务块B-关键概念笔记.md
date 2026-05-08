---
created: 2026-04-28
type: note
status: active
tags: [math, llm, month1, gradient, backprop, notes]
summary: "任务块 B 的关键概念笔记：为什么梯度下降要减梯度，以及链式法则和反向传播的关系。"
---

# 任务块 B：关键概念笔记

这篇笔记只回答两个核心问题：
- 为什么梯度下降里要减梯度而不是加梯度？
- 链式法则和反向传播到底是什么关系？
- optimization 的最基本直觉是什么？

## 1. 为什么梯度下降里要减梯度而不是加梯度

### 先说结论
如果目标是最小化函数

$$
f(\theta),
$$

那么常见更新写成

$$
\theta_{t+1} = \theta_t - \eta \nabla f(\theta_t),
$$

因为：

$$
\nabla f(\theta)
$$

指向函数在当前位置局部上升最快的方向。

所以：
- `加梯度` 是往更快上升的方向走
- `减梯度` 才是往更快下降的方向走

### 为什么梯度表示“最陡上升方向”
设当前位置是 $\theta$，考虑一个很小的移动 $\Delta$。  
一阶近似告诉我们：

$$
f(\theta + \Delta)
\approx
f(\theta) + \nabla f(\theta)^\top \Delta.
$$

这里真正决定函数值变化的，是后面这一项：

$$
\nabla f(\theta)^\top \Delta.
$$

如果我们把步长固定住，比如要求

$$
\|\Delta\| = c,
$$

那么要让函数增大得最快，就要让

$$
\nabla f(\theta)^\top \Delta
$$

尽可能大。

根据内积公式：

$$
\nabla f(\theta)^\top \Delta
=
\|\nabla f(\theta)\| \, \|\Delta\| \cos \phi,
$$

其中 $\phi$ 是梯度方向和移动方向的夹角。

因为 $\|\Delta\|$ 已经固定，所以这项最大时一定满足

$$
\cos \phi = 1,
$$

也就是 $\Delta$ 和梯度方向一致。

因此梯度就是局部最陡上升方向。

### 为什么减梯度会下降
如果取

$$
\Delta = - \eta \nabla f(\theta),
$$

其中 $\eta > 0$ 很小，那么代回一阶近似：

$$
f(\theta - \eta \nabla f(\theta))
\approx
f(\theta) - \eta \|\nabla f(\theta)\|^2.
$$

因为

$$
\|\nabla f(\theta)\|^2 \ge 0,
$$

所以只要梯度不为 0，并且步长够小，就有

$$
f(\theta - \eta \nabla f(\theta)) < f(\theta).
$$

这说明：减梯度会让目标函数在局部下降。

### 加梯度会发生什么
如果反过来取

$$
\Delta = + \eta \nabla f(\theta),
$$

那么

$$
f(\theta + \eta \nabla f(\theta))
\approx
f(\theta) + \eta \|\nabla f(\theta)\|^2,
$$

也就是局部会上升。

所以：
- 最小化问题用 `减梯度`
- 最大化问题才用 `加梯度`

### 在模型训练里的意义
训练通常是在最小化 loss：

$$
L(\theta).
$$

所以更新自然写成

$$
\theta \leftarrow \theta - \eta \nabla_\theta L(\theta).
$$

这背后的意思不是“公式规定要减”，而是：

$$
\text{我们希望参数沿着让 loss 下降的局部最快方向前进。}
$$

## 2. 链式法则和反向传播到底是什么关系

### 先说最短答案
反向传播本质上就是：

$$
\text{把链式法则系统化地应用到多层复合函数上。}
$$

### 先看单变量版本
如果

$$
y = f(u), \qquad u = g(x),
$$

那么复合函数

$$
y = f(g(x))
$$

的导数是

$$
\frac{dy}{dx}
=
\frac{dy}{du} \cdot \frac{du}{dx}.
$$

这就是链式法则。

它表达的意思是：
- $x$ 先影响 $u$
- $u$ 再影响 $y$
- 所以 $x$ 对 $y$ 的总影响，要沿路径乘起来

### 放到神经网络里
神经网络本质上就是层层复合。

比如最简单的两层结构：

$$
z^{(1)} = W^{(1)} x + b^{(1)},
$$

$$
a^{(1)} = \sigma(z^{(1)}),
$$

$$
z^{(2)} = W^{(2)} a^{(1)} + b^{(2)},
$$

$$
L = \ell(z^{(2)}, y).
$$

现在如果要算

$$
\frac{\partial L}{\partial W^{(1)}},
$$

就不能直接一下子看出来，因为 $W^{(1)}$ 并不直接出现在最终 loss 的最外层，而是通过一连串中间量影响它。

所以只能沿着这条依赖链往回传：

$$
W^{(1)}
\to z^{(1)}
\to a^{(1)}
\to z^{(2)}
\to L.
$$

链式法则告诉我们：

$$
\frac{\partial L}{\partial W^{(1)}}
=
\frac{\partial L}{\partial z^{(2)}}
\frac{\partial z^{(2)}}{\partial a^{(1)}}
\frac{\partial a^{(1)}}{\partial z^{(1)}}
\frac{\partial z^{(1)}}{\partial W^{(1)}}.
$$

这就是反向传播的核心结构。

### 为什么叫“反向”
前向计算时，顺序是：

$$
x \to z^{(1)} \to a^{(1)} \to z^{(2)} \to L.
$$

而求梯度时，信息传播方向反过来了：

$$
L \to z^{(2)} \to a^{(1)} \to z^{(1)} \to W^{(1)}.
$$

也就是说：
- 前向传播负责算值
- 反向传播负责算导数

所以“反向传播”这个名字，说的是导数信息沿计算图反方向传播。

### 为什么反向传播高效
如果没有反向传播，你可以想象一种很笨的方式：
- 对每个参数都单独重新推一次导数

这样会有大量重复计算。

反向传播高效的关键在于：
- 先算出后面层的梯度
- 再复用这些中间结果继续往前传

例如，如果已经算出

$$
\frac{\partial L}{\partial z^{(2)}},
$$

那么它既可以用来求

$$
\frac{\partial L}{\partial W^{(2)}},
$$

也可以继续往前传去求

$$
\frac{\partial L}{\partial a^{(1)}}.
$$

这就避免了重复工作。

### 一句话理解
链式法则告诉你：

$$
\text{复合函数的导数应该怎么拆。}
$$

反向传播则告诉你：

$$
\text{在一个很深的复合结构里，怎样按计算图高效地把这件事做完。}
$$

所以两者的关系不是“有点像”，而是：

$$
\text{反向传播 = 链式法则在神经网络计算图上的工程化实现。}
$$

## 3. 这两个问题之间的联系
这两个概念连在一起，就是训练最核心的一条链：

1. 用反向传播算出梯度
2. 用梯度下降更新参数

也就是：

$$
\text{链式法则} \Rightarrow \text{反向传播得到梯度}
\Rightarrow \text{减梯度让 loss 下降}
$$

如果把训练看成一个完整过程，那么：
- 链式法则解决“梯度怎么算”
- 梯度下降解决“梯度算出来以后怎么更新”

## 4. 学习资源
### 主线资源
- MIT OpenCourseWare 18.02 Multivariable Calculus  
  [MIT OCW 18.02](https://ocw.mit.edu/courses/mathematics/18-02-multivariable-calculus-fall-2007/)

### 面向 ML 的过桥材料
- Stanford CS229 线性代数与矩阵求导复习  
  [CS229 Linear Algebra Review](https://cs229.stanford.edu/notes2022fall/cs229-linear_algebra_review.pdf)

## 5. 你现在最该做什么
如果你觉得任务块 B 的内容大概率已经理解，那最值得做的不是重复看课，而是：
- 不看资料，自己解释一遍为什么最小化要减梯度
- 不看资料，自己写出链式法则和反向传播的关系
- 手推一个两层网络里某个参数对 loss 的导数链

如果你能流畅做到这三件事，任务块 B 就基本真的通过了。

## 6. optimization 的最基本直觉

这一部分已经独立成单独笔记：

- [[Optimization-最基本直觉|Optimization：最基本直觉]]

建议单独阅读，因为它会长期反复用到，不只是任务块 B 才会用。
