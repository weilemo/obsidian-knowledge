---
created: 2026-03-04
tags:
  - machine-learning
  - feature-scaling
  - course-note
source-course: Machine Learning Specialization (Course 1, Week 2)
---

# Feature Scaling 详解

## 这两节在讲什么
- `Feature scaling part 1`：解释为什么要做特征缩放，以及不缩放会导致梯度下降收敛很慢。
- `Feature scaling part 2`：介绍常见缩放方法（尤其是 Z-score 标准化）和实操注意事项。

## 为什么特征缩放是必要的
当不同特征量级差异很大时（例如 `size=2000`，`bedrooms=3`），代价函数会变得很“狭长”，梯度下降会来回震荡，导致：
- 收敛慢
- 学习率难调
- 训练不稳定

做完缩放后，各维度尺度接近，梯度下降路径更直接，收敛更快。

## 常见缩放方式
1. Mean normalization
```text
x_scaled = (x - mean) / (max - min)
```

2. Z-score standardization（最常用）
```text
x_scaled = (x - μ) / σ
```
其中 `μ` 是均值，`σ` 是标准差。

3. 简单按最大值缩放
```text
x_scaled = x / max
```

## 实操原则（很重要）
- 只对输入特征 `X` 缩放。
- 训练集先算 `μ, σ`，验证集/测试集必须用同一组 `μ, σ`。
- 不要对不同数据集分别重新拟合缩放参数（会造成数据泄漏或分布不一致）。

## 小例子（手算）
原始特征 `size = [1000, 1500, 2000]`
- 均值 `μ = 1500`
- 标准差 `σ ≈ 408.25`

Z-score 后：
- `(1000-1500)/408.25 ≈ -1.225`
- `(1500-1500)/408.25 = 0`
- `(2000-1500)/408.25 ≈ 1.225`

可以看到缩放后数据落在接近 `[-1.5, 1.5]` 范围，更利于优化。

## NumPy 实现
```python
import numpy as np

# X: (m, n) m个样本, n个特征
X = np.array([
    [1000, 3],
    [1500, 4],
    [2000, 3],
], dtype=float)

mu = X.mean(axis=0)
sigma = X.std(axis=0)

X_scaled = (X - mu) / sigma

print("mu:", mu)
print("sigma:", sigma)
print("X_scaled:\n", X_scaled)
```

## 一句话总结
Feature scaling 的本质是把不同量纲的特征拉到相近尺度，让梯度下降更快、更稳、更容易调参。

## Feature engineering（这节在讲什么）
`Feature engineering` 的核心是：把原始输入特征变换成对模型更“友好”的表达，让模型更容易学到真实规律。

在线性模型场景下，常见构造方式有：
- 组合特征：`x1 * x2`（例如 面积 * 卧室数）
- 比例特征：`x1 / x2`（例如 人口密度 = 人口 / 面积）
- 幂次特征：`x^2`, `x^3`
- 其他变换：`sqrt(x)`, `log(x)`（当数据分布偏斜时常用）

### 这一节想传达的重点
- 线性回归“线性”指的是对参数线性，不代表只能学直线关系。
- 通过合适的特征变换，线性模型也能拟合更复杂的非线性模式。
- 好的特征工程通常能显著提升效果，且比盲目加复杂模型更稳。

### 和 Polynomial regression 的关系
- `Feature engineering`：偏手工、偏经验，按任务去设计特征。
- `Polynomial regression`：系统化加入多项式特征，是特征工程的一种标准形式。

### 实操注意
- 先做缩放，再训练（尤其新增了幂次特征后，量级可能更不平衡）。
- 新增特征会增加过拟合风险，必要时配合正则化。
- 特征不是越多越好，优先保留有明确业务含义或验证有效的特征。


## 相关笔记
- [[Overfitting 与 Regularization 详解]]
