---
created: 2026-01-27
type: paper
status: unread
tags: ["video-generation", "streaming", "kv-cache", "training-free"]
aliases: ["Deep Forcing: Training-Free Long Video Generation with Deep Sink and Participative Compression", "Deep Forcing"]
summary: "Deep Sink+参与式压缩实现免训练长视频"
pdf-url: "Attachments/arxiv_2512.05081.pdf"
github-url: ""
---

# Deep Forcing
## 一句话摘要
无需再训练，通过 Deep Sink 与 Participative Compression 管理 KV cache，实现长视频高质量与动态。

## PDF
[[Attachments/arxiv_2512.05081.pdf]]

## Abstract
- 发现简单套用 attention sink 会导致运动停滞与质量退化。
- 提出训练自由（training-free）策略以稳定长程生成。

## 1. Introduction
- AR 视频扩散依赖 KV cache，长程误差不可避免。
- 目标：不再训练，仅通过缓存策略提升长程质量。

## 2. Related Work
- Self-Forcing/Rolling Forcing 等训练法，以及 StreamingLLM 类 sink 机制。

## 3. Preliminaries
- AR 生成：
$$
p(x_{1:N})=\prod_{i=1}^N p(x_i\mid x_{<i})
$$

## 4. Method
### 4.1 Deep Sink
- 将滑窗一半作为 sink tokens，并重对齐 RoPE 相位。
- 关键结构：
$$
K=[K_{sink}\,\Vert\,K_{tail}],\quad V=[V_{sink}\,\Vert\,V_{tail}]
$$
- 通过 $\Delta_{sink}$ 对齐时间相位，稳定全局上下文。

### 4.2 Participative Compression
- 重要性得分：
$$
\phi_j=\sum_{r=1}^R q^\top k_r
$$
- Top-C 选择并压缩：
$$
K_{top}=\mathrm{Top}	ext{-}C(\phi),\quad
K_{compressed}=[K_{sink}\,\Vert\,K_{top}\,\Vert\,K_{rct}]
$$
- 仅保留参与最近注意力的 token，丢弃退化历史。

## 5. Experiments
- 5s 训练模型可外推到 60s+；动态与一致性优于 Rolling/LongLive。
- 保持实时生成能力。

## 6. Conclusion
- 通过训练自由的 KV 管理策略实现长程一致性与动态改善。

## 相关链接（双向）
- [[KV Cache]]
- [[Attention Sink]]
- [[Training-Free]]
