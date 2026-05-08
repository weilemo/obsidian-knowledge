---
created: 2026-04-28
published: 2023-05-22
type: paper
status: 未读
tags:
  - RWKV
  - KVCache
  - Architecture
  - RNN
  - LinearAttention
aliases:
  - RWKV
  - Reinventing RNNs for the Transformer Era
summary: 提出 RWKV（Receptance Weighted Key Value），把 Transformer 风格的并行训练与 RNN 风格的常数状态推理结合起来，在推理时不再依赖显式随长度增长的 KV cache。
pdf-url: https://arxiv.org/pdf/2305.13048
source-url:
  - https://arxiv.org/abs/2305.13048
  - https://arxiv.org/pdf/2305.13048
  - https://aclanthology.org/2023.findings-emnlp.936/
---

# RWKV: Reinventing RNNs for the Transformer Era

## Abstract
RWKV 提出一种介于 Transformer 与 RNN 之间的序列建模架构。它在训练时可以像 Transformer 一样并行计算，而在推理时又可以像 RNN 一样只维护常数大小的递归状态，从而避免标准自注意力中随序列长度线性增长的 KV cache 开销。

## Why It Matters
在 `KV cache` 语境下，RWKV 的意义非常直接：它不是想办法“压缩或淘汰已有 KV”，而是从架构层面把“每个 token 都要把 K/V 留下来”这个前提改掉。也因此，它和 MQA / GQA 一样都属于“从根上减少 KV 负担”的路线，但比它们更进一步，因为推理时核心对象变成了递归状态而不是显式缓存。

## Core Idea
- 用线性化的 key-value 累积与门控机制替代标准多头自注意力。
- 训练时可展开为适合并行的形式。
- 推理时可写成递归更新：
  - 读入当前 token；
  - 更新有限状态；
  - 直接输出下一步结果。

因此，RWKV 的推理复杂度更接近：
$$
O(1)\ \text{state per step}
$$
而不是标准 Transformer 的：
$$
O(T)\ \text{KV cache growth with sequence length}
$$

## Relation to KV Cache
- 标准 Transformer：历史越长，KV cache 越大。
- RWKV：历史信息被压缩进递归状态，不保留显式全历史 KV。

所以它回答的不是“如何留最重要的 KV”，而是“能否根本不维护这种随长度膨胀的 KV 结构”。

## Related Links
- [[KV Cache]]
- [[Fast-Transformer-Decoding-One-Write-Head-is-All-You-Need]]
- [[GQA-Training-Generalized-Multi-Query-Transformer-Models-from-Multi-Head-Checkpoints]]
