---
created: 2026-04-18
published: 2020-06-29
type: paper
status: 未读
tags: [LinearAttention, KernelAttention, EfficientAttention]
aliases: [Transformers are RNNs, Fast Autoregressive Transformers with Linear Attention]
summary: "通过核函数分解将 attention 写成可递推形式，把复杂度降为线性，并揭示 Transformer 与 RNN 的联系。"
pdf-url: https://arxiv.org/pdf/2006.16236
source-url:
  - https://arxiv.org/abs/2006.16236
  - https://arxiv.org/pdf/2006.16236
---

# Transformers are RNNs: Fast Autoregressive Transformers with Linear Attention

## Abstract
论文将注意力重写为核特征映射下的线性形式，使自回归推理可递推执行，从而显著降低长序列推理成本。

## Why It Matters
这是线性注意力核方法的奠基性论文之一。
