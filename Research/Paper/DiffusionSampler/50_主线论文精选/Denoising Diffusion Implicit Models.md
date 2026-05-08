---
created: 2026-04-30
published: 2021-01-12
type: paper
status: 未读
tags: [DiffusionSampler, Diffusion, Sampling, ODE]
aliases: [DDIM]
summary: "把 DDPM 的反向过程推广到 non-Markovian family，在保持训练目标不变的前提下实现更快的确定性采样。"
pdf-url: "https://openreview.net/pdf?id=St1giarCHLP"
source-url:
  - https://openreview.net/forum?id=St1giarCHLP
  - https://openreview.net/pdf?id=St1giarCHLP
---

# Denoising Diffusion Implicit Models

## Abstract

DDIM 的关键贡献不是重新训练模型，而是重新定义采样过程。它把 DDPM 的反向马尔可夫链推广到一个 non-Markovian family，其中可以选出确定性路径，从而把采样步数大幅压缩。

## Core Idea

- 训练目标仍与 DDPM 一致
- 采样时不再要求严格沿用马尔可夫反向链
- 当随机项取零时，可以得到 deterministic sampling
- 这让扩散采样第一次真正接近“可快速推理”

## Key Formulation

DDIM 可以理解为沿着一个更平滑的隐式去噪轨迹推进：

$$
x_{t-1}=\sqrt{\bar{\alpha}_{t-1}}\hat{x}_0+\sqrt{1-\bar{\alpha}_{t-1}}\hat{\epsilon}
$$

其中 $\hat{x}_0$ 与 $\hat{\epsilon}$ 由当前网络预测给出。  
当随机噪声项关闭时，采样路径变成确定性的 ODE-like 轨迹。

## Why It Matters

- 是扩散模型快速采样的第一个里程碑
- 后续很多方法都把 DDIM 当作基础一阶 solver 或比较基线
- DPM-Solver++ 论文里仍把 DDIM 作为 guided sampling 的重要对照对象

## 相关链接（双向）

- [[扩散模型采样器（ODE / SDE）研究地图与主流论文]]
- [[扩散采样器主线论文索引]]
