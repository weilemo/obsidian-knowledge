---
created: 2026-04-15
published: 2025-06-25
type: paper
status: 未读
tags: [LeoAM, KVCache, HierarchicalMemory, LongContext, SparseAttention]
aliases: [Breaking the Boundaries of Long-Context LLM Inference, LeoAM]
summary: "面向单消费级 GPU 的长上下文推理系统：自适应 GPU-CPU-Disk 分层 KV 管理与轻量摘要传输。"
pdf-url: "https://arxiv.org/pdf/2506.20187"
source-url:
  - https://arxiv.org/abs/2506.20187
  - https://arxiv.org/pdf/2506.20187
---

# Breaking the Boundaries of Long-Context LLM Inference: Adaptive KV Management on a Single Commodity GPU

## Abstract
论文提出 LeoAM：针对消费级单卡场景的长上下文推理系统。核心是自适应分层 KV 管理（GPU/CPU/Disk）与 KV abstract 机制，降低磁盘带宽瓶颈与重要性评估开销。

## 1 Introduction
问题背景是：当上下文足够长时，GPU 显存无法容纳全部 KV，必须外存分层管理；但传统 offload 方案常因评估和传输开销过高而失效。

## 2 Method
LeoAM 的几个关键设计：
- 基于层间注意力分布的可变粒度 KV chunk 管理；
- 仅在磁盘存储/传输 KV 摘要（abstract）以降时延；
- 动态压缩与 pipeline 协同执行。

## 3 Experiments
论文报告在保持可比输出质量下，可显著降低推理延迟（文中给出平均约 3.46x、大 batch 最高约 5.47x 加速）。

## 4 与 Ada-KV 中 Sparse Attention 语境的关系
这篇工作的重点是“分层存储与按需访问”，说明在不直接删光 KV 的前提下，也能通过计算/访问稀疏化与外存管理获得大幅加速。

## 相关链接（双向）
- [[KV Cache]]
- [[Ada-KV✅]]
