---
created: 2026-04-28
published: 2023-12-01
type: paper
status: 未读
tags:
  - Mamba
  - KVCache
  - Architecture
  - SSM
  - LongContext
aliases:
  - Mamba
  - Mamba Linear-Time Sequence Modeling with Selective State Spaces
summary: 提出 Mamba，把 selective state spaces 做成通用序列建模骨干，以线性时间和递归状态替代标准注意力，在长序列推理中不再依赖随长度增长的 KV cache。
pdf-url: https://arxiv.org/pdf/2312.00752
source-url:
  - https://arxiv.org/abs/2312.00752
  - https://arxiv.org/pdf/2312.00752
---

# Mamba: Linear-Time Sequence Modeling with Selective State Spaces

## Abstract
Mamba 提出一种基于 selective state space model 的通用序列建模架构。核心思想是让状态空间参数随输入内容变化，从而弥补传统线性状态空间模型在内容选择与离散 token 建模上的弱点。论文进一步给出硬件友好的并行算法，使模型兼具线性扩展性与高吞吐推理能力。

## Why It Matters
对 `KV cache` 来说，Mamba 的重要性不在于它提供了新的淘汰策略，而在于它代表了另一条更彻底的路径：
- 不再用 attention 存整段历史；
- 不再让 KV cache 随序列长度增长；
- 而是把历史压缩进可选择更新的状态。

因此，Mamba 常被拿来和 Transformer 系列做“长序列效率”对照，也经常出现在 KV cache 论文的 related work 里。

## Core Idea
Mamba 的关键改动是 `selective`：
- 状态更新不再是固定参数的线性系统；
- 参数会依赖当前输入；
- 模型可以选择性地保留、传播或遗忘信息。

这使它比传统 SSM 更适合语言这类离散、内容驱动很强的序列。

## Relation to KV Cache
标准 Transformer 的增长模式是：
$$
\text{memory} \propto T
$$
因为要保留长度为 $T$ 的历史 K/V。

Mamba 的推理更接近：
$$
\text{memory} \approx \text{constant state size}
$$
历史不会以显式 token-wise KV 的方式保存下来，而是进入状态递推。

所以从 KV cache 的角度看，Mamba 属于“从源头取消 KV 膨胀”的代表架构。

## Related Links
- [[KV Cache]]
- [[RWKV：Reinventing-RNNs-for-the-Transformer-Era]]
- [[RetNet：Retentive-Network-A-Successor-to-Transformer-for-Large-Language-Models]]
