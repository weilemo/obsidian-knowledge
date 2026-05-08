---
created: 2026-04-15
published: 2024-07-02
type: paper
status: 未读
tags: [MInference, SparseAttention, KVCache, LongContext]
aliases: [MInference 1.0]
summary: "通过动态稀疏注意力加速长上下文 prefill：推理时只计算关键稀疏模式，不直接缩小 KV 存储体量。"
pdf-url: "https://arxiv.org/pdf/2407.02490"
source-url:
  - https://arxiv.org/abs/2407.02490
  - https://arxiv.org/pdf/2407.02490
---

# MInference 1.0: Accelerating Pre-filling for Long-Context LLMs via Dynamic Sparse Attention

## Abstract
MInference 1.0 面向长上下文 prefill 阶段的计算瓶颈，核心思路是在注意力计算时按头动态选择稀疏模式（如 A-shape、Vertical-Slash、Block-Sparse），并用专门 GPU kernel 执行稀疏计算。它强调的是“算得更少更快”，而不是直接删除 KV 缓存本体。

## 1 Introduction
论文指出，长上下文的 prefill 主要受二次复杂度注意力计算限制。MInference 通过离线为每个 head 搜索最优稀疏模式、在线动态构建稀疏索引，实现训练免费加速。

## 2 Method
方法分两层：
- 头级模式分配：离线确定每个头用哪种稀疏模式；
- 运行时稀疏执行：依据输入长度与模式构建索引，并调用优化 kernel 计算注意力。

## 3 Experiments
论文报告在多模型和多长上下文任务上可显著降低 prefill 延迟（文中给到最高约 10x 量级），同时保持接近 full attention 的质量。

## 4 与 KV Eviction 的关系
这类方法在计算时稀疏，但通常保留全部 KV 条目（或依赖外存管理），因此和“直接删 KV”的 eviction 路线正交，可组合。

## 相关链接（双向）
- [[KV Cache]]
- [[Ada-KV✅]]
