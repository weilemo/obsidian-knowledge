---
created: 2026-04-15
published: 2024-09-16
type: paper
status: 未读
tags: [RetrievalAttention, SparseAttention, KVCache, VectorRetrieval, LongContext]
aliases: [RetrievalAttention]
summary: "将长上下文注意力转化为向量检索问题：仅检索少量相关 KV 参与计算，以降低显存与时延。"
pdf-url: "https://arxiv.org/pdf/2409.10516"
source-url:
  - https://arxiv.org/abs/2409.10516
  - https://arxiv.org/pdf/2409.10516
---

# RetrievalAttention: Accelerating Long-Context LLM Inference via Vector Retrieval

## Abstract
RetrievalAttention 将长上下文注意力中的“找相关历史 KV”显式做成向量检索：把 KV 索引放在 CPU 侧，通过检索返回少量相关候选参与计算。论文还指出 query/key 分布存在 OOD 问题，并提出 attention-aware 检索策略缓解。

## 1 Introduction
主要痛点是长上下文下 attention 计算与 KV 显存压力。论文目标是同时降低计算量和 GPU KV 占用。

## 2 Method
方法由三部分构成：
- CPU 侧 ANNS 索引构建；
- 查询时检索 Top 相关 KV；
- 针对 attention query-key 分布偏移的检索校正。

## 3 Experiments
论文报告在接近 full attention 精度下，仅访问约 1%–3% 数据；并给出 8B/128K 在单张 RTX4090(24GB) 上可运行的结果。

## 4 与 KV Eviction 的关系
它不是直接永久淘汰 KV，而是“按需检索少量 KV 计算”，属于稀疏计算 + 外存检索范式。

## 相关链接（双向）
- [[KV Cache]]
- [[Ada-KV✅]]
