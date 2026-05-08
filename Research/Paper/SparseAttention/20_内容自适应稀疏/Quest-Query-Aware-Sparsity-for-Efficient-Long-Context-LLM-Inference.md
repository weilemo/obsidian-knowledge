---
created: 2026-04-28
published: 2024-06-16
type: paper
status: 未读
tags:
  - Quest
  - SparseAttention
  - KVCache
  - LongContext
  - QueryAware
aliases:
  - Quest
  - Query-Aware Sparsity for Efficient Long-Context LLM Inference
summary: 通过 query-aware 的页级关键性估计，只加载 top-k 关键 KV pages 参与注意力，从而减少长上下文推理时的 attention 访存与计算。
pdf-url: https://arxiv.org/pdf/2406.10774
source-url:
  - https://arxiv.org/abs/2406.10774
  - https://arxiv.org/pdf/2406.10774
  - https://github.com/mit-han-lab/quest
---

# Quest: Query-Aware Sparsity for Efficient Long-Context LLM Inference

## Abstract
Quest 关注的是长上下文 LLM 推理时 attention 读 KV cache 太慢的问题。论文观察到，真正关键的历史 token / page 依赖当前 query，因此不能只用静态重要性。为此，Quest 对 KV cache 做 page 级管理，记录每页 key 的最小值和最大值，并用当前 query 估计每页的潜在关键性，只把 top-k 关键 pages 加载出来做注意力。

## Why It Matters
Quest 是典型的 `query-aware sparse attention` 路线。它的目标是：
- 少读一部分 KV；
- 少算一部分 attention；
- 在不改训练的前提下提升长上下文推理速度。

但它并不等同于 KV eviction，因为它主要减少的是“当前步访问哪些页”，而不是直接把完整 KV cache 本体压小。

## Core Idea
- 按 page 管理 KV cache；
- 为每页维护 key 的轻量摘要（如 min / max）；
- 当前 query 到来后，估计各页的上界相关性；
- 只对 top-k pages 执行精确 attention。

## Relation to KV Cache
Quest 与 H2O / SnapKV / ArkVale 的区别在于：
- 它主要优化 `attention access pattern`；
- 不主要优化 `resident KV capacity`。

所以它常常能显著减轻 attention 带宽瓶颈，但不一定像真正的 KV 压缩 / eviction 方法那样直接缓解显存容量压力。

## Related Links
- [[KV Cache]]
- [[ArkVale]]
- [[MInference-1.0]]
