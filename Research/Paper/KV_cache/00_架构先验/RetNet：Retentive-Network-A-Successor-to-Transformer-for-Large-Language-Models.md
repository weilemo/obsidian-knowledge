---
created: 2026-04-28
published: 2023-07-17
type: paper
status: 未读
tags:
  - RetNet
  - KVCache
  - Architecture
  - Retention
  - LongContext
aliases:
  - RetNet
  - Retentive Network
  - Retentive Network A Successor to Transformer for Large Language Models
summary: 提出 RetNet，用 retention 机制把注意力与递归联系起来，同时支持并行训练、常数成本递归推理和 chunkwise 长序列建模，从架构上缓解 KV cache 与长上下文推理开销。
pdf-url: https://arxiv.org/pdf/2307.08621
source-url:
  - https://arxiv.org/abs/2307.08621
  - https://arxiv.org/pdf/2307.08621
  - https://openreview.net/forum?id=UU9Icwbhin
---

# Retentive Network: A Successor to Transformer for Large Language Models

## Abstract
RetNet 提出 retention 机制，试图在一个统一框架里同时实现三件事：
- 训练时保留并行性；
- 推理时支持低成本递归更新；
- 长序列时支持 chunkwise recurrent 计算。

论文核心主张是：可以把 attention 与 recurrence 建立更直接的联系，从而得到比标准 Transformer 更适合长序列和低成本部署的骨干。

## Why It Matters
在 `KV cache` 语境下，RetNet 的价值在于它把“历史信息怎么存”从全量 K/V 序列，改成了 retention state。这样一来，推理阶段不再需要像标准自注意力那样不断扩张 KV cache，而是依靠递归状态总结过去。

## Three Computation Modes
论文强调 retention 机制支持三种等价或兼容的计算视角：

1. `parallel`
训练时像 Transformer 一样并行。

2. `recurrent`
推理时每步只维护状态，达到低成本增量解码。

3. `chunkwise recurrent`
长序列按 chunk 并行处理，同时在 chunk 间递归传递摘要状态。

这也是 RetNet 最重要的结构卖点。

## Relation to KV Cache
RetNet 属于“架构替换”而非“cache 管理”路线：
- 它不研究 token-level eviction；
- 不研究 recent / heavy-hitter / recall；
- 而是让历史依赖通过 retention state 持续传播。

因此，它和 H2O / SnapKV / StreamingLLM 的问题层级不同：
- 后者默认 Transformer 与 KV cache 已经存在；
- RetNet 则试图让这套显式缓存机制不再成为主角。

## Related Links
- [[KV Cache]]
- [[RWKV：Reinventing-RNNs-for-the-Transformer-Era]]
- [[Mamba：Linear-Time-Sequence-Modeling-with-Selective-State-Spaces]]
