---
created: 2026-03-04
tags:
  - machine-learning
  - overfitting
  - regularization
  - course-note
source-course: Machine Learning Specialization (Course 1, Week 3)
---

# Overfitting 与 Regularization 详解

## Overfitting + Regularization 详细解释（Course 1 Week 3）

### 1) The problem of overfitting：过拟合到底是什么
过拟合（high variance）指的是：模型把训练集里的真实规律和“噪声”一起学进去了。

典型现象：
- 在训练集上表现很好（误差很低）。
- 在验证集/测试集上表现明显变差（误差高）。

直觉图像：
- 欠拟合：曲线太简单，抓不住趋势（high bias）。
- 合适拟合：能抓住主趋势且对新数据稳定。
- 过拟合：曲线弯弯绕绕“穿过”很多训练点，但泛化差。

为什么会发生：
- 特征太多、模型太灵活。
- 数据量不够，或数据噪声较大。
- 训练时只盯训练误差，没有用验证集约束泛化能力。

如何识别（课程里非常重要）：
- 看 $J_{\text{train}}$ 和 $J_{\text{cv}}$：
  - $J_{\text{train}}$ 低、$J_{\text{cv}}$ 高，通常是过拟合信号。
- 看学习曲线：
  - 训练误差一直低，验证误差居高不下，且两者间隔较大。

---

### 2) Addressing overfitting：如何缓解过拟合
课程给出三大路线，实战里通常组合使用：

1. 增加数据（More data）
- 让模型更难“记住”个别样本噪声。
- 对高方差问题通常有效，尤其在数据偏少时。

2. 减少特征/简化模型（Feature selection / simpler model）
- 去掉明显无关或噪声大的特征。
- 降低多项式阶数、减少复杂变换。

3. 正则化（Regularization）
- 不直接删特征，而是惩罚参数过大。
- 让模型保留所有特征但“更克制”，通常比硬删特征更稳。

这门课重点放在第 3 条：正则化。

---

### 3) Cost function with regularization：为什么要在损失函数里加惩罚

#### 3.1 核心思想
如果某些权重 $w_j$ 很大，模型往往会变得非常“陡峭/复杂”，容易对训练噪声过敏。
所以在目标函数里加入惩罚项，鼓励参数不要太大。

#### 3.2 线性回归（L2 正则）
原始目标：

$$
J(w,b) = \frac{1}{2m} \sum_{i=1}^{m} \left(f_{w,b}(x^{(i)}) - y^{(i)}\right)^2
$$

加正则后：

$$
J(w,b) = \frac{1}{2m} \sum_{i=1}^{m} \left(f_{w,b}(x^{(i)}) - y^{(i)}\right)^2 + \frac{\lambda}{2m} \sum_{j=1}^{n} w_j^2
$$

说明：
- $\lambda$（lambda）控制惩罚强度。
- 通常不惩罚 $b$（偏置项）。
- 当 $\lambda = 0$ 时，退化成无正则。
- 当 $\lambda$ 过大时，权重几乎被压到 0，模型会欠拟合。

#### 3.3 逻辑回归（L2 正则）
同样是在 log loss 后加 L2 惩罚项：

$$
J(w,b) = \text{LogisticLoss}(w,b) + \frac{\lambda}{2m} \sum_{j=1}^{n} w_j^2
$$

本质不变：
- 前半部分保证“拟合数据”。
- 后半部分限制“模型复杂度”。

---

### 4) Regularized linear regression：正则化如何改变训练

#### 4.1 梯度更新变化（重点）
对 $j \ge 1$ 的参数，梯度下降更新可写成：

$$
w_j \leftarrow w_j - \alpha \left[ \frac{1}{m} \sum_{i=1}^{m} \left(f_{w,b}(x^{(i)}) - y^{(i)}\right)x_j^{(i)} + \frac{\lambda}{m} w_j \right]
$$

可理解为两部分：
- 第一部分：来自数据误差，推动模型拟合数据。
- 第二部分：来自正则惩罚，把 $w_j$ 往 0 拉（weight decay 直觉）。

对 $b$：

$$
b \leftarrow b - \alpha \cdot \frac{1}{m} \sum_{i=1}^{m} \left(f_{w,b}(x^{(i)}) - y^{(i)}\right)
$$

通常不含正则项。

#### 4.2 为什么能缓解过拟合
- 权重被抑制后，预测函数变化更平滑。
- 模型不容易“为迎合少数训练点”产生大幅弯折。
- 泛化误差（验证集误差）通常会下降。

---

### 5) Regularized logistic regression：分类里的同一套思想
逻辑回归里，更新形式几乎一致，只是误差项来自分类损失。

对 $j \ge 1$：

$$
w_j \leftarrow w_j - \alpha \left[ \frac{1}{m} \sum_{i=1}^{m} \left(h_{w,b}(x^{(i)}) - y^{(i)}\right)x_j^{(i)} + \frac{\lambda}{m} w_j \right]
$$

其中：

$$
h_{w,b}(x) = \sigma(w^T x + b)
$$

直觉：
- 如果某个特征权重异常大，模型边界会对该特征过度敏感。
- L2 正则把这种过度敏感压下来，使决策边界更稳。

---

### 6) $\lambda$（正则强度）怎么选：课程里的实战流程
1. 固定数据切分：train / cv / test。
2. 设定候选 $\lambda$ 列表（例如：$0, 0.001, 0.01, 0.1, 1, 10$）。
3. 每个 $\lambda$ 训练一次模型，记录 $J_{\text{train}}$ 和 $J_{\text{cv}}$。
4. 选 $J_{\text{cv}}$ 最小的 $\lambda$。
5. 最后仅一次在 test 上报告泛化结果。

诊断经验：
- $\lambda$ 太小，仍过拟合（高方差）。
- $\lambda$ 太大，欠拟合（高偏差）。
- 目标是让 $J_{\text{cv}}$ 最低，而不是让 $J_{\text{train}}$ 最低。

---

### 7) 常见误区
- 误区 1：$\lambda$ 越大越好。
  - 错，太大会把模型压坏，出现欠拟合。

- 误区 2：正则化后就不需要特征工程。
  - 错，好的特征工程仍然关键；正则化是防过拟合，不是替代特征设计。

- 误区 3：训练集、验证集分别独立做不同缩放参数。
  - 错，应使用训练集拟合的缩放参数去变换验证/测试集。

- 误区 4：只看训练准确率。
  - 错，判断过拟合必须看验证集表现。

---

### 8) 一页总结
- 过拟合 = 训练好、泛化差（高方差）。
- 缓解路线：更多数据 / 简化模型 / 正则化。
- 这 5 节最核心的是 L2 正则：
  - 在线性回归和逻辑回归里都加

$$
\frac{\lambda}{2m}\sum_{j=1}^{n}w_j^2
$$

  - 训练时额外把权重往 0 拉，减少模型复杂度。
- $\lambda$ 通过验证集调，目标是最低 $J_{\text{cv}}$。
