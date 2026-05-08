---
created: 2026-04-18
published: 2024-05-07
type: paper
status: 未读
tags: [TOVA, KVCache, TokenEviction, LongContext]
aliases: [TOVA, Transformers are Multi-State RNNs]
summary: "将 decoder-only Transformer 解释为多状态 RNN，并提出训练免费的 TOVA（Token Omission Via Attention）缓存压缩策略。"
pdf-url: https://arxiv.org/pdf/2405.04517
source-url:
  - https://arxiv.org/abs/2405.04517
  - https://arxiv.org/pdf/2405.04517
---

# Transformers are Multi-State RNNs

## Abstract
论文给出 Transformer 与 RNN 的统一视角，并据此提出 TOVA：基于注意力信号进行 token omission 的训练免费 KV 压缩策略，在多种长程任务上实现较高压缩比与吞吐提升。

## Why It Matters
这是 KV 淘汰路线中“理论解释 + 训练免费策略”的代表文章，适合作为 H2O/SnapKV 对照阅读。

## 相关链接（双向）
- [[KV Cache]]
- [[H2O✅]]
- [[SnapKV✅]]
