---
created: 2026-04-28
type: note
status: active
tags: [math, llm, month1, lecture, softmax, cross-entropy]
summary: "任务块 C 的讲义：从 logits 到 softmax、cross-entropy，再到梯度 p-y 与语言模型训练。"
---

# 任务块 C：讲义

这份讲义的目标很明确：

$$
\text{把 logits、softmax、cross-entropy、gradient 串成一条完整的训练链。}
$$

如果你能顺着这份讲义读完并自己补一遍推导，那么任务块 C 就不只是“知道公式”，而是真的打通了。

## 1. 我们到底在解决什么问题

先看最简单的多分类问题。

设输入是 $x$，模型输出一个长度为 $K$ 的分数向量：

$$
z = (z_1, z_2, \dots, z_K).
$$

这里的 $z_i$ 叫 `logit`。  
logit 不是概率，它只是模型对每个类别打出来的“原始分数”。

训练时，我们想回答的问题是：

$$
\text{怎么把这组分数变成概率，并且据此定义一个合理的损失函数？}
$$

这就引出了：
- softmax
- cross-entropy

## 2. softmax 在做什么

### 2.1 定义
给定 logits $z$，softmax 定义为：

$$
p_i = \frac{e^{z_i}}{\sum_{j=1}^K e^{z_j}}.
$$

于是得到一个向量

$$
p = (p_1, \dots, p_K),
$$

满足：

$$
p_i \ge 0, \qquad \sum_{i=1}^K p_i = 1.
$$

也就是说，softmax 把任意实数分数转成一个概率分布。

### 2.2 为什么要先取指数
如果只做简单归一化，比如

$$
\frac{z_i}{\sum_j z_j},
$$

会出问题：
- 如果某些 $z_i$ 是负数，就不再像概率
- 分母可能为 0
- 大小关系的解释不稳定

指数函数有几个好处：
- 永远为正
- 保持单调
- 分数差距会自然影响概率差距

所以 softmax 的作用不是“神奇变换”，而是：

$$
\text{用一套稳定的方式，把模型分数转成可训练的概率分布。}
$$

### 2.3 一个重要性质：平移不变性
如果所有 logits 同时加上同一个常数 $c$，softmax 不变：

$$
\frac{e^{z_i + c}}{\sum_j e^{z_j + c}}
=
\frac{e^c e^{z_i}}{e^c \sum_j e^{z_j}}
=
\frac{e^{z_i}}{\sum_j e^{z_j}}.
$$

所以：

$$
\operatorname{softmax}(z) = \operatorname{softmax}(z + c\mathbf{1}).
$$

这条性质非常重要，因为它带来数值稳定技巧：

$$
\operatorname{softmax}(z)
=
\operatorname{softmax}(z - \max_i z_i).
$$

实践里常这么做，避免 $e^{z_i}$ 爆掉。

## 3. cross-entropy 在做什么

### 3.1 定义
设真实标签是 one-hot 向量 $y$：

$$
y = (y_1, \dots, y_K),
\qquad
y_i \in \{0,1\},
\qquad
\sum_i y_i = 1.
$$

预测分布是 $p$，交叉熵定义为：

$$
L = - \sum_{i=1}^K y_i \log p_i.
$$

### 3.2 one-hot 情况下它到底是什么意思
如果真实类别是第 $t$ 类，那么：

$$
y_t = 1, \qquad y_i = 0 \; (i \ne t).
$$

于是损失会简化成：

$$
L = - \log p_t.
$$

这句话非常重要。它说明：

$$
\text{cross-entropy 本质上就是在惩罚模型没有把正确类别的概率给高。}
$$

如果正确类概率 $p_t$ 很大，那么 $-\log p_t$ 很小；  
如果正确类概率 $p_t$ 很小，那么 $-\log p_t$ 很大。

### 3.3 为什么它是合理的训练目标
它的合理性来自两个层面：

#### 1. 概率层面
你希望模型把真实标签看成更可能的事件。

#### 2. 优化层面
它平滑、可导，而且和 softmax 搭配后梯度非常干净。

所以 cross-entropy 在训练里常见，不只是因为“大家都这么用”，而是因为：

$$
\text{它既有概率解释，又有很好的优化性质。}
$$

## 4. 把 softmax 和 cross-entropy 接起来

现在把两步连起来。

先有 logits：

$$
z_1, \dots, z_K
$$

通过 softmax 得到：

$$
p_i = \frac{e^{z_i}}{\sum_j e^{z_j}}
$$

再通过 cross-entropy 定义损失：

$$
L = - \sum_{i=1}^K y_i \log p_i.
$$

把 softmax 代进去：

$$
L
=
- \sum_{i=1}^K y_i \log
\left(
\frac{e^{z_i}}{\sum_j e^{z_j}}
\right).
$$

展开对数：

$$
L
=
- \sum_{i=1}^K y_i
\left(
z_i - \log \sum_j e^{z_j}
\right).
$$

因为

$$
\sum_i y_i = 1,
$$

所以可以整理成：

$$
L
=
- \sum_{i=1}^K y_i z_i
+
\log \sum_{j=1}^K e^{z_j}.
$$

这个形式很重要，因为后面求梯度会更容易。

## 5. 最重要的推导：为什么梯度是 \(p_i - y_i\)

这是整个任务块 C 的核心。

目标是求：

$$
\frac{\partial L}{\partial z_i}.
$$

从上面已经整理好的式子开始：

$$
L
=
- \sum_{k=1}^K y_k z_k
+
\log \sum_{j=1}^K e^{z_j}.
$$

对 $z_i$ 求导。

### 5.1 第一项的导数

$$
\frac{\partial}{\partial z_i}
\left(
- \sum_{k=1}^K y_k z_k
\right)
= -y_i.
$$

因为只有第 $i$ 项和 $z_i$ 有关。

### 5.2 第二项的导数

$$
\frac{\partial}{\partial z_i}
\log \sum_{j=1}^K e^{z_j}
=
\frac{1}{\sum_j e^{z_j}}
\cdot
\frac{\partial}{\partial z_i}
\sum_j e^{z_j}.
$$

继续求导：

$$
\frac{\partial}{\partial z_i}
\sum_j e^{z_j}
= e^{z_i}.
$$

所以：

$$
\frac{\partial}{\partial z_i}
\log \sum_j e^{z_j}
=
\frac{e^{z_i}}{\sum_j e^{z_j}}
= p_i.
$$

### 5.3 合起来

$$
\frac{\partial L}{\partial z_i}
=
-y_i + p_i
=
p_i - y_i.
$$

这就是最关键的结论：

$$
\boxed{
\frac{\partial L}{\partial z_i} = p_i - y_i
}
$$

## 6. 这条梯度结果到底说明了什么

这条式子强得有点惊人，因为它非常干净。

### 6.1 直觉解释
梯度就是：

$$
\text{预测} - \text{真实}
$$

如果某一类预测太高，而真实标签不是它，那么这一维梯度就偏正，更新时会把它往下压。  
如果真实类预测太低，那么对应梯度就偏负，更新时会把它往上推。

也就是说，训练过程本质上就是在不断纠正：

$$
\text{模型分布和真实标签分布之间的偏差。}
$$

### 6.2 为什么它对优化友好
因为梯度不需要复杂结构，只和：
- softmax 输出的概率
- 真实标签

有关。

所以这套组合在工程上特别顺滑。

## 7. 在语言模型里，这条链怎么出现

语言模型虽然不只是“普通分类”，但每个 token prediction 本质上都是一个大规模多分类。

给定上下文 $x_{<t}$，模型输出下一个 token 的 logits：

$$
z^{(t)} \in \mathbb R^{|V|},
$$

其中 $|V|$ 是词表大小。

然后：

1. 用 softmax 得到下一个 token 的预测分布

$$
p^{(t)} = \operatorname{softmax}(z^{(t)}).
$$

2. 用真实 token 的 one-hot 标签算交叉熵

$$
L_t = - \log p^{(t)}_{x_t}.
$$

3. 对所有位置求和或平均：

$$
L = \sum_t L_t
\quad \text{或} \quad
L = \frac{1}{T}\sum_t L_t.
$$

所以语言模型训练底层仍然是：

$$
\text{logits} \to \text{softmax} \to \text{cross-entropy} \to \text{gradient}.
$$

## 8. 常见误区

### 误区 1：softmax 是分类器
不是。  
softmax 只是把 logits 变成概率分布。真正的分类决策往往还要再取：

$$
\arg\max_i p_i.
$$

### 误区 2：cross-entropy 只是一个公式
不是。  
它本质上在说：让真实标签对应的概率尽可能大。

### 误区 3：梯度 \(p-y\) 是巧合
不是。  
这是 softmax 和 cross-entropy 组合之后非常自然的结果，也是它们搭配如此常用的重要原因。

### 误区 4：语言模型和分类问题完全不同
不完全对。  
语言模型当然更复杂，但 token 级训练的底层数学骨架，本质上就是一个超大词表上的分类问题。

## 9. 学习资源

### 主线资源
- Stanford CS229 课程材料页  
  [CS229 Course Materials](https://cs229.stanford.edu/materials.html-full)

### 补基础资源
- Stanford CS229 线性代数复习  
  [CS229 Linear Algebra Review](https://cs229.stanford.edu/notes2022fall/cs229-linear_algebra_review.pdf)

### 使用建议
这份讲义本身就可以作为任务块 C 的主线阅读材料。  
如果你后面觉得还想补更系统的推导，再继续补一份专门的交叉熵 / softmax 讲义即可。

## 10. 你现在最该做什么

如果你已经“大概率理解”任务块 C，那最值得做的不是再泛泛看概念，而是完成下面三件事：

1. 不看资料，自己写出 softmax 定义
2. 不看资料，自己推一遍

$$
\frac{\partial L}{\partial z_i} = p_i - y_i
$$

3. 用自己的话解释：为什么这条梯度结果会让正确类概率上升、错误类概率下降

如果你能流畅做完这三件事，任务块 C 就基本不是“知道”，而是“掌握”了。
