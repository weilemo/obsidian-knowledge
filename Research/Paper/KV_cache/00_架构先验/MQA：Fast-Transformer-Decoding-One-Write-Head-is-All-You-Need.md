---
created: 2026-04-18
published: 2019-11-06
type: paper
status: 未读
tags: [MQA, KVCache, LLMInference, Architecture]
aliases: [Fast Transformer Decoding, One Write-Head is All You Need, MQA]
summary: "提出 Multi-Query Attention（MQA），让所有 query heads 共享同一组 K/V，以显著降低解码阶段 KV cache 开销。"
pdf-url: https://arxiv.org/pdf/1911.02150
source-url:
  - https://arxiv.org/abs/1911.02150
  - https://arxiv.org/pdf/1911.02150
---

# Fast Transformer Decoding: One Write-Head is All You Need

## Abstract
论文提出 MQA（Multi-Query Attention）：保留多 query heads，但共享单组 K/V heads，从而在自回归解码时显著减少 KV cache 的内存和带宽占用。核心目标是提升长序列解码吞吐，同时尽量保持质量。

## Why It Matters
这是后续 GQA 以及大量 LLM 推理架构优化的直接前置工作，定义了“共享 K/V 头”这条主线。

## 相关链接（双向）
- [[KV Cache]]
