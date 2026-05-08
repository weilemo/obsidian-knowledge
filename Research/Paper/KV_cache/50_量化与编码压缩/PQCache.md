---
created: 2026-04-15
published: 2024-07-17
type: paper
status: 未读
tags: [PQCache, KVCache, ProductQuantization, LongContext, SparseAttention]
aliases: [PQCache]
summary: "使用产品量化（PQ）压缩 KV 表征，降低长上下文 KV 存储与访问成本。"
pdf: /Users/moweile/Obsidian/Knowledge/Research/Paper/KV_cache/50_量化与编码压缩/Attachments/PQCache_2407.12820.pdf
pdf-url: "Attachments/PQCache_2407.12820.pdf"
source-url:
  - https://arxiv.org/abs/2407.12820
  - https://arxiv.org/pdf/2407.12820.pdf
  - https://doi.org/10.1145/3725338
---

# PQCache: Product Quantization-based KVCache for Long Context LLM Inference

## Abstract
PQCache 采用 Product Quantization 对 KV 做向量级压缩，以减少长上下文 KV 的存储压力和带宽开销。

## 1 Introduction
论文出发点是：长上下文推理中，KV cache 的容量与 I/O 往往是首要瓶颈；量化与压缩是更直接的系统解法之一。

## 2 Method
核心是用 PQ 把高维 KV 近似映射到紧凑码本表示：
- 降低内存占用；
- 减少跨层级存储读取压力；
- 尽量保持对注意力质量的影响可控。

## 3 Experiments
论文在长上下文推理设定下评估压缩率、速度与精度折中，显示 PQ 路线在系统效率上有明显收益。

## 4 与“Sparse attention 不直接缩小 KV 存储”的关系
PQCache 更偏“存储压缩”而非“计算稀疏”。Ada-KV 把它与稀疏路线一起引用，强调长上下文优化通常需要“计算+存储”联合设计。

## 相关链接（双向）
- [[KV Cache]]
- [[Ada-KV✅]]
