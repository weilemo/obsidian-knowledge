---
created: 2026-04-28
published: 2024-05-05
type: paper
status: 未读
tags:
  - IceFormer
  - SparseAttention
  - CPUInference
  - LongContext
aliases:
  - IceFormer
  - IceFormer Accelerated Inference with Long-Sequence Transformers on CPUs
summary: 面向 CPU 上的长序列 Transformer 推理，通过利用 attention 稀疏性只对最关键的 key/value 做选择性计算，在无需重训的前提下加速长上下文推理。
pdf-url: https://arxiv.org/pdf/2405.02842
source-url:
  - https://arxiv.org/abs/2405.02842
  - https://arxiv.org/pdf/2405.02842
  - https://openreview.net/forum?id=6RR3wU4mSZ
---

# IceFormer: Accelerated Inference with Long-Sequence Transformers on CPUs

## Abstract
IceFormer 研究的是 CPU 场景下长序列 Transformer 推理过慢的问题。论文利用 attention matrix 的稀疏性，只对每个 query 最关键的一小部分 key/value 做选择性计算，以此减少长序列推理的 attention 开销，并保持较高精度。

## Why It Matters
IceFormer 说明 sparse attention 不只是 GPU 长上下文 LLM 的话题，在 CPU 部署下同样关键。它的重点不是训练新架构，而是在 `pretrained Transformer` 上直接做 inference-time 稀疏化。

## Core Idea
- 基于 attention 稀疏性做关键 key 的近似筛选；
- 只对高价值候选执行更完整的 attention 计算；
- 面向 CPU 推理路径做实现优化。

## Relation to KV Cache
IceFormer 与 KV cache 压缩方法不同：
- 它主要减少 attention 计算与访问；
- 不以缩小缓存容量本身为首要目标；
- 因此更适合放在 sparse attention 路线，而不是 eviction / quantization 路线。

## Related Links
- [[KV Cache]]
- [[ArkVale]]
- [[Quest-Query-Aware-Sparsity-for-Efficient-Long-Context-LLM-Inference]]
