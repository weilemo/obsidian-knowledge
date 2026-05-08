---
created: 2026-04-28
type: note
status: active
tags: [math, llm, month1, softmax, cross-entropy]
summary: "Month 1 的第三个任务块：softmax、cross-entropy 与基础训练推导。"
---

# 任务块 C：softmax、cross-entropy 与基础训练推导

## 目标
完成这个任务块时，希望你能做到：
- 看懂 softmax 在干什么
- 理解 cross-entropy 为什么常用作分类训练目标
- 能补出 softmax + cross-entropy 的基本梯度推导
- 能把 logit、probability、loss、gradient 串成一条线

## 建议时长
- 如果基础较弱：`7 - 10` 天
- 如果你大概率已经理解：`3 - 5` 天快速过关

## 核心内容
### 1. logit 到 probability
给定 logit 向量

$$
z = (z_1, \dots, z_K),
$$

softmax 定义为

$$
p_i = \frac{e^{z_i}}{\sum_{j=1}^K e^{z_j}}.
$$

它做的事是：
- 把任意实数分数转成非负数
- 再归一化成概率分布

### 2. cross-entropy 在做什么
若真实标签是 one-hot 向量 $y$，预测分布是 $p$，则

$$
L = - \sum_{i=1}^K y_i \log p_i.
$$

如果 $y$ 是 one-hot，这就等于“把真实类别的预测概率拉高”。  
所以 cross-entropy 本质上是在惩罚：模型没有把正确类分到足够高的概率。

### 3. 为什么这两个常一起出现
softmax 给出概率，cross-entropy 拿这个概率和真实标签比较。

于是训练目标自然变成：

$$
\text{让正确类概率更大，让错误类概率更小。}
$$

### 4. 最重要的推导结果
最常见的结论是：

$$
\frac{\partial L}{\partial z_i} = p_i - y_i.
$$

这条式子非常重要，因为它说明：
- 梯度就是“预测和真实之间的偏差”
- 训练更新本质上是在纠正这个偏差

## 在 ML / LLM 里的对应
这个任务块最直接对应：
- 多分类训练
- language modeling 的 next-token prediction
- 为什么训练代码里常常先算 logits，再算 loss

在语言模型里，虽然目标更复杂，但底层经常还是：
- 输出 logits
- 变成概率
- 用交叉熵训练

## 学习资源
### 主线资源
- Stanford CS229 课程主页与讲义入口  
  [CS229 Course Materials](https://cs229.stanford.edu/materials.html-full)

### 补基础资源
- Stanford CS229 线性代数复习  
  [CS229 Linear Algebra Review](https://cs229.stanford.edu/notes2022fall/cs229-linear_algebra_review.pdf)

### 说明
任务块 C 不一定要求你去找最“官方的 softmax 专题课”，更重要的是：
- 看一份清楚推导
- 自己补一遍
- 能把它和训练流程连起来

如果现有资源不够顺手，后续可以再补一份专门的推导型资料。

## 讲义
- [[任务块C-讲义|任务块 C：讲义]]

## 如果你大概率已经理解，怎么快速通过
那就不要重复看概念，而是直接做 `快速过关自测`。

### 快速过关标准
如果你能独立完成下面 4 件事，就可以认为任务块 C 基本通过：

1. 不查资料写出 softmax 定义
2. 解释 cross-entropy 为什么会惩罚错分
3. 补出

$$
\frac{\partial L}{\partial z_i} = p_i - y_i
$$

的主要推导
4. 说清楚 logits、probabilities、loss、gradients 四者之间的关系

### 快速过关输出
- 一页笔记：`softmax 和 cross-entropy 到底在干什么`
- 一份手推：`softmax + cross-entropy gradient`
- 一段说明：`为什么这条梯度结果在训练里这么重要`

## 最低完成标准
- 看到 softmax 和 cross-entropy 不再只会背公式
- 能用自己的话解释它们各自的角色
- 能补出基础梯度推导
- 能把它们和实际训练流程接上
