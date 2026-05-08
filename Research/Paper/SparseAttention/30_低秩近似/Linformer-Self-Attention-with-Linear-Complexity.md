---
created: 2026-04-18
published: 2020-06-08
type: paper
status: 未读
tags: [Linformer, LowRankApproximation, EfficientAttention]
aliases: [Linformer, Self-Attention with Linear Complexity]
summary: "基于注意力矩阵低秩假设，将序列维投影到低维空间，从而把 attention 复杂度降到线性级别。"
pdf-url: https://arxiv.org/pdf/2006.04768
source-url:
  - https://arxiv.org/abs/2006.04768
  - https://arxiv.org/pdf/2006.04768
---

# Linformer: Self-Attention with Linear Complexity

## Abstract
Linformer 通过学习型投影将 K/V 在长度维压缩，近似全注意力，目标是在保持效果的前提下显著降低时间与空间复杂度。

## Why It Matters
这是低秩近似 attention 路线最常被引用的代表论文。
