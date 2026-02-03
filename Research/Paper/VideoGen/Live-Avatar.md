---
created: 2026-01-27
type: paper
status: unread
tags: ["avatar", "audio-driven", "streaming", "diffusion", "real-time"]
aliases: ["Live Avatar: Streaming Real-time Audio-Driven Avatar Generation with Infinite Length", "Live Avatar"]
summary: "TPP+RSFM实现无限长度实时音频驱动头像"
pdf-url: "Attachments/arxiv_2512.04677.pdf"
github-url: ""
---

# Live Avatar
## 一句话摘要
通过 TPP 流水并行与滚动参考帧（RSFM），实现 14B 模型的实时、无限长度音频驱动头像生成。

## PDF
[[Attachments/arxiv_2512.04677.pdf]]

## Abstract
- 提出系统-算法协同框架，打破自回归瓶颈。
- 20 FPS 端到端生成，支持小时级连续输出。

## 1. Introduction
- 音频驱动头像需要高保真、低延迟与长时一致性。
- 现有扩散模型受限于顺序去噪与长程漂移。

## 2. Related Works
- 综述音频驱动生成、流式扩散、实时视频模型。

## 3. Preliminaries
- 基础扩散与流匹配框架；自回归 streaming 的核心瓶颈。

## 4. The Live Avatar Framework
### 4.1 Timestep-forcing Pipeline Parallelism (TPP)
- 将去噪时间步在多 GPU 上流水化，提升吞吐与降低延迟。

### 4.2 Rolling Sink Frame Mechanism (RSFM)
- 持续缓存与更新参考帧，动态校准外观与身份。

### 4.3 Distillation for Causal Streaming
- 采用 Self-Forcing DMD 使大模型适配因果流式生成。

### 关键公式（文中提取）
$$
x_t=(1-s_t)\,x_0+s_t\,x_T,\quad s_t\in[0,1]
$$
$$
v=x_T-x_0
$$
$$
L=\mathbb{E}_{x_0,x_T,t}\,\|v_\theta(x_t,t,c)-(x_T-x_0)\|^2
$$

## 5. Experiments
- 规模：14B 模型，5×H800 达到 20 FPS。
- 长时一致性、口型/表情与身份稳定性显著提升。

## 6. Conclusion
- Live Avatar 将扩散模型提升到可工业部署的实时音频驱动头像生成。

## 相关链接（双向）
- [[Audio-Driven Avatar]]
- [[Streaming Diffusion]]
- [[Pipeline Parallelism]]
