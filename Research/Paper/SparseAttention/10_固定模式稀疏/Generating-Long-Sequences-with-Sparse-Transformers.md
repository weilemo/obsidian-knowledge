---
created: 2026-04-18
published: 2019-04-23
type: paper
status: 未读
tags: [SparseTransformer, SparseAttention, LongContext]
aliases: [Sparse Transformer, Generating Long Sequences with Sparse Transformers]
summary: "提出分解式稀疏注意力模式，将标准注意力的二次复杂度降为次二次，是固定稀疏模式的重要里程碑。"
pdf-url: https://arxiv.org/pdf/1904.10509
source-url:
  - https://arxiv.org/abs/1904.10509
  - https://arxiv.org/pdf/1904.10509
---

# Generating Long Sequences with Sparse Transformers

## Abstract
论文通过结构化稀疏连接替代全连接 attention，在保持长距离建模能力的同时显著降低计算与内存开销，并展示了超长序列生成能力。

## Why It Matters
这是稀疏注意力研究最经典的起点之一，后续 Longformer/BigBird 等固定稀疏路线都可追溯到这条脉络。
