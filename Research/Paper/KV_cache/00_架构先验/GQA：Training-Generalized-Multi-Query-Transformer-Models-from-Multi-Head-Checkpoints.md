---
created: 2026-04-18
published: 2023-05-22
type: paper
status: 未读
tags: [GQA, KVCache, LLMInference, Architecture]
aliases: [GQA, Grouped-Query Attention]
summary: "提出 GQA：在 MHA 与 MQA 之间引入分组共享 K/V 头，并给出从 MHA checkpoint uptraining 到 GQA/MQA 的实用流程。"
pdf-url: https://arxiv.org/pdf/2305.13245
source-url:
  - https://arxiv.org/abs/2305.13245
  - https://arxiv.org/pdf/2305.13245
---

# GQA: Training Generalized Multi-Query Transformer Models from Multi-Head Checkpoints

## Abstract
GQA 用“中间数量”的 KV heads 替代 MHA 的一一对应和 MQA 的单 KV 头极端共享，形成质量与效率折中。论文同时给出从现有 MHA checkpoint 低成本 uptraining 到 GQA/MQA 的方法，减少重新预训练成本。

## Why It Matters
GQA 已成为主流大模型的重要推理友好架构选择之一，是理解 KV cache 架构优化的基础论文。

## 相关链接（双向）
- [[KV Cache]]
- [[MQA：Fast-Transformer-Decoding-One-Write-Head-is-All-You-Need]]
