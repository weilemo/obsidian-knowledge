---
created: 2026-04-15
published: 2025-04-22
type: paper
status: 未读
tags: [MMInference, SparseAttention, VLM, KVCache, LongContext]
aliases: [MMInference]
summary: "把 MInference 扩展到多模态长上下文，通过模态感知排列与稀疏注意力加速 VLM prefill。"
pdf-url: "https://arxiv.org/pdf/2504.16083"
source-url:
  - https://arxiv.org/abs/2504.16083
  - https://arxiv.org/pdf/2504.16083
---

# MMInference: Accelerating Pre-filling for Long-Context VLMs via Modality-Aware Permutation Sparse Attention

## Abstract
MMInference 把稀疏 prefill 思路从 LLM 推到 VLM。论文认为视频/图文输入具有明显时空与模态结构，可用模态感知重排后再做稀疏注意力计算，从而在长多模态输入下获得高加速。

## 1 Introduction
目标是降低多模态长上下文 prefill 延迟。和 KV eviction 不同，它主要优化注意力计算路径，而不是先裁掉 KV 存储。

## 2 Method
核心包括：
- 模态感知排列（permutation）来暴露更规则的稀疏结构；
- 头级稀疏模式分配与动态索引；
- 稀疏 GPU kernel 执行。

## 3 Experiments
论文在 Video QA、Captioning、Vision-NIAH 等基准上报告了显著 prefill 加速（文中最高约 8.3x 量级）并保持精度。

## 4 与 KV Eviction 的关系
MMInference 属于“计算稀疏化”路线：减少注意力计算量，不等价于减少 KV 总存储规模。

## 相关链接（双向）
- [[KV Cache]]
- [[Ada-KV✅]]
