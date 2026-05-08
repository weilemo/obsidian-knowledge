---
created: 2026-04-28
published: 2023-12-08
type: paper
status: 未读
tags:
  - SparQ
  - SparseAttention
  - KVCache
  - Bandwidth
  - LongContext
aliases:
  - SparQ
  - SparQ Attention
  - SparQ Attention Bandwidth-Efficient LLM Inference
summary: 通过少量 query/key 特征先粗筛候选历史位置，再选择性抓取缓存历史做精确注意力，重点优化 attention 层的数据搬运与带宽开销。
pdf-url: https://arxiv.org/pdf/2312.04985
source-url:
  - https://arxiv.org/abs/2312.04985
  - https://arxiv.org/pdf/2312.04985
---

# SparQ Attention: Bandwidth-Efficient LLM Inference

## Abstract
SparQ Attention 的出发点是：长上下文推理里，attention 往往不是被算力卡住，而是被数据传输卡住。论文提出先用 query 与 key 的少量特征维度做快速粗筛，找出最可能重要的一小批历史位置，然后只对这些候选位置抓取完整 KV 并执行更精确的注意力计算。

## Why It Matters
SparQ 的关键词是 `bandwidth-efficient`。它代表了一类非常实用的 sparse attention 思路：
- 不是先删缓存；
- 而是先尽量少搬运缓存。

因此它特别适合被放在“内容自适应稀疏”而不是“KV 压缩”主线里理解。

## Core Idea
- 先选取 query / key 的少量特征维度；
- 用这些低成本特征快速估计哪些历史位置值得看；
- 再只对少量候选位置抓取完整 KV；
- 最后在候选集上算更接近原始 attention 的结果。

## Relation to KV Cache
SparQ 改善的是：
- attention 层的数据传输；
- 历史 KV 的选择性抓取；
- 长序列下的推理吞吐。

但它不一定减少完整 KV cache 的驻留需求，因为被筛掉的位置往往只是“这一步不读取”，不是“从缓存中永久删除”。

## Related Links
- [[KV Cache]]
- [[ArkVale]]
- [[Quest-Query-Aware-Sparsity-for-Efficient-Long-Context-LLM-Inference]]
