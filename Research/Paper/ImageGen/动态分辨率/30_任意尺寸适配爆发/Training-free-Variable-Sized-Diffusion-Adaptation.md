---
created: 2026-04-09
published: 2023-06-14
type: paper
status: 未读
tags: [VariableSize, DynamicResolution, TuningFree]
aliases: [Training-free-Variable-Sized-Diffusion-Adaptation]
summary: "从注意力熵随分辨率变化出发，提出训练免费缩放修正以改善可变尺寸生成的构图失真。"
pdf-url: "https://arxiv.org/pdf/2306.08645.pdf"
source-url:
  - https://arxiv.org/abs/2306.08645
  - https://arxiv.org/pdf/2306.08645.pdf
---

# Training-free Diffusion Model Adaptation for Variable-Sized Text-to-Image Synthesis

## Abstract
论文从注意力熵变化解释“分辨率外推失真”现象，并提出无需训练的缩放修正策略，使固定分辨率训练的扩散模型在可变尺寸生成时更稳定。

## 1 Introduction
核心观察是：推理分辨率变化会改变 token 数，进而改变注意力分布统计，导致布局漂移与重复目标。论文目标是在不微调参数的情况下校正这一统计偏移。

## 2 Related Work
作者把工作放在 training-free 适配脉络中，与拼接式方法、感受野修正方法形成互补：本方法主要作用于注意力统计层面。

## 3 Method
### 3.1 Connection: the attention entropy and the token number
定义注意力熵：
$$
H(p)=-\sum_j p_j\log p_j
$$
当分辨率改变时，token 数变化会引起熵系统偏移，最终表现为全局构图不稳定。

### 3.2 A scaling factor for mitigating entropy fluctuations
论文给出推理期缩放因子，对注意力 logits/温度进行分辨率相关校正，使不同尺寸下的注意力统计更接近训练分布。

## 4 Experimental Results
### 4.1 Text-to-image synthesis
在人像、复杂场景和长宽比外推任务上，语义稳定性与构图完整性均有改善。

### 4.2 Analysis
分析显示该方法与多种 backbone 兼容，并在极端长宽比下仍有效。

### 4.3 Difference with other candidate methods
与简单插值或拼接策略相比，本文方法更直接针对“注意力分布漂移”这一根因。

## 5 Conclusion
论文贡献在于给出一个可解释、低成本的变量尺寸适配路径：以统计校正替代重训。

## 6 Supplementary Materials
### 6.1 Proofs
补充注意力熵与 token 数关系的推导。

### 6.2 Implementation details
给出可复现超参数与插入位置。

### 6.3 Broader impacts
讨论潜在滥用与偏见问题。

### 6.4 Additional experimental results
提供更多可视化与边界案例。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
