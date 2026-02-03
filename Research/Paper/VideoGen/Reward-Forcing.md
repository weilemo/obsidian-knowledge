---
created: 2026-01-27
type: paper
status: unread
tags: ["video-generation", "streaming", "distillation", "reward", "real-time"]
aliases: ["Reward Forcing: Efficient Streaming Video Generation with Rewarded Distribution Matching Distillation", "Reward Forcing"]
summary: "EMA-Sink+Re-DMD提升实时流式视频质量"
pdf-url: "Attachments/arxiv_2512.04678.pdf"
github-url: ""
---

# Reward Forcing
## 一句话摘要
通过 EMA-Sink 与 Rewarded DMD 在实时流式生成中提升动态与一致性。

## PDF
[[Attachments/arxiv_2512.04678.pdf]]

## Abstract
- 기존 DMD 对所有样本等权，难以强化运动动态。
- EMA-Sink 保持长期上下文且避免初帧复制。
- Re-DMD 将分布匹配偏向高奖励区域。

## 1. Introduction
- 目标：实时、长时流式生成；挑战为漂移与运动衰减。

## 2. Related Works
- 对比 Self-Forcing、LongLive、CausVid 等长程方案。

## 3. Method
### 3.1 EMA-Sink
- 固定大小的 sink tokens 由初帧初始化并 EMA 更新。
- 既保留全局上下文又保留近期动态。

### 3.2 Rewarded DMD (Re-DMD)
- 通过奖励加权的分布匹配提升动态内容：
$$
J_{\mathrm{Re-DMD}} = \mathbb{E}_{p(c)p'_{fake}}[\cdot]
$$
- 梯度：
$$
\nabla_\theta J_{\mathrm{Re-DMD}}=\mathbb{E}_t[\cdot]
$$

### 3.3 时间步平移与采样
- 时间步平移：
$$
t'(k,t)=\frac{k t/1000}{1+(k-1)(t/1000)}\cdot 1000
$$
- 4-step 采样日程（$t_1,t_2,t_3,t_4$）。

## 4. Experiments
- 单 H100 达到 23.1 FPS；动态与一致性优于基线。
- 奖励权重影响运动质量与场景导航动态。

## 5. Conclusion
- EMA-Sink+Re-DMD 为流式生成提供更稳的长程动态。

## 相关链接（双向）
- [[Distribution Matching Distillation]]
- [[Attention Sink]]
- [[Streaming Video Generation]]
