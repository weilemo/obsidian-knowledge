---
created: 2026-04-09
published: 1989-06-01
type: paper
status: 已读
tags: [TeacherForcing, RNN, SequenceModeling, Autoregressive]
aliases: [Teacher Forcing, Williams-Zipser-1989]
summary: "提出 Teacher Forcing 范式：训练循环网络时使用真实历史作为下一步输入监督。"
pdf-url: ""
source-url:
  - https://doi.org/10.1162/neco.1989.1.2.270
---

# A Learning Algorithm for Continually Running Fully Recurrent Neural Networks
## 一句话摘要
这篇论文提出了训练全循环 RNN 的核心范式之一 `Teacher Forcing`：训练时把真实上一步输出喂给模型来预测下一步，从而稳定并加速优化。

## 提出的范式（你关心的结论）
- `Teacher Forcing` 范式：训练阶段使用真实历史（ground-truth previous token/frame）作为当前步输入，最小化一步预测误差。
- 这是经典 `Next-token Prediction` 的训练范式基础，后续大量 AR 序列建模都沿用它。
- 在 `Diffusion Forcing` 的对比图里，`Teacher Forcing` 侧指的就是这类逐步监督训练范式，而不是某一篇扩散论文。

## 方法/模型（实现细节）
- 针对 continuously running fully recurrent neural networks，论文给出 BPTT 风格训练算法。
- 关键做法是“clamp 真实历史输入”，避免模型在训练时被自身历史误差持续污染。
- 训练目标本质上是逐时间步监督误差最小化（连续值常用 MSE，离散值在后续工作中常用 CE）。

## 局限与注意事项
- 训练和推理分布不一致：训练看见真实历史，推理看见模型自己的历史输出。
- 该失配会导致长序列误差累积（后来通常称 `exposure bias` / compounding error）。
- 这正是后续很多工作（scheduled sampling、diffusion forcing、self-forcing 等）试图缓解的问题。

## 与 Diffusion Forcing 的关系
- `Diffusion Forcing` 的核心之一就是把“时间轴上的 teacher forcing 掩码”推广为“噪声轴上的可变掩码”，从而兼顾可变长度生成与扩散式引导。

## 相关链接（双向）
- [[Diffusion-Forcing ✅]]
- [[Video-Diffusion-Models✅]]
- [[自回归生成]]
- [[序列建模]]
