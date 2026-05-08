---
created: 2026-04-18
published: 2020-04-10
type: paper
status: 未读
tags: [Longformer, SparseAttention, LongDocument]
aliases: [Longformer, The Long-Document Transformer]
summary: "提出滑动窗口注意力与少量全局 token 结合的稀疏结构，成为长文档 NLP 的经典高效 Transformer 基线。"
pdf-url: https://arxiv.org/pdf/2004.05150
source-url:
  - https://arxiv.org/abs/2004.05150
  - https://arxiv.org/pdf/2004.05150
---

# Longformer: The Long-Document Transformer

## Abstract
Longformer 使用局部滑窗注意力处理大多数 token，并给关键位置赋予全局注意力通道，显著降低复杂度，同时在长文档任务上保持或提升效果。

## Why It Matters
这是“固定稀疏 + 全局锚点”范式的代表工作。
