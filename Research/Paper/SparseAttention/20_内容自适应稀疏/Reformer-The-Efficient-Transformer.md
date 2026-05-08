---
created: 2026-04-18
published: 2020-01-13
type: paper
status: 未读
tags: [Reformer, SparseAttention, LSHAttention]
aliases: [Reformer, The Efficient Transformer]
summary: "通过 LSH attention 与可逆层等机制降低 Transformer 内存与计算开销，是内容自适应稀疏路线代表。"
pdf-url: https://arxiv.org/pdf/2001.04451
source-url:
  - https://arxiv.org/abs/2001.04451
  - https://arxiv.org/pdf/2001.04451
---

# Reformer: The Efficient Transformer

## Abstract
Reformer 用 LSH 将相似 token 路由到同簇内计算注意力，并结合可逆残差层减少激活存储，显著提升长序列可扩展性。

## Why It Matters
它代表了“内容自适应路由稀疏”的关键分支。
