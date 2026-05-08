---
created: 2026-04-30
published: 2020-11-26
type: paper
status: 未读
tags: [DiffusionSampler, Diffusion, Sampling, SDE, ODE]
aliases: [Score SDE]
summary: "把 score model 与 diffusion model 统一到 reverse-time SDE 和 probability flow ODE 视角，是后续 ODE/SDE 采样器的理论总源头。"
pdf-url: "https://arxiv.org/pdf/2011.13456.pdf"
source-url:
  - https://arxiv.org/abs/2011.13456
  - https://arxiv.org/pdf/2011.13456.pdf
---

# Score-Based Generative Modeling through Stochastic Differential Equations

## Abstract

这篇论文把 score-based model 与 diffusion model 统一起来：前向过程可以写成一个连续时间 SDE，而生成过程则对应其 reverse-time SDE。更重要的是，作者同时推出与之等价的 probability flow ODE，为后续 ODE 采样器提供了共同理论起点。

## Core Idea

- 用连续时间 SDE 统一不同扩散过程
- 用 reverse-time SDE 定义随机采样路径
- 用 probability flow ODE 定义确定性采样路径
- 提出 predictor-corrector sampler，系统处理离散化误差

## Key Formulation

前向扰动过程写成：

$$
\mathrm{d}x=f(x,t)\mathrm{d}t+g(t)\mathrm{d}w
$$

对应的反向 SDE 为：

$$
\mathrm{d}x=\left[f(x,t)-g(t)^2\nabla_x \log p_t(x)\right]\mathrm{d}t+g(t)\mathrm{d}\bar{w}
$$

与之对应的 probability flow ODE 为：

$$
\mathrm{d}x=\left[f(x,t)-\frac{1}{2}g(t)^2\nabla_x \log p_t(x)\right]\mathrm{d}t
$$

## Why It Matters

- `SDE sampler` 的正统来源基本都在这篇里
- `ODE sampler` 的理论母体也是这篇里的 probability flow ODE
- 后来的 DDIM、DPM-Solver、UniPC 都可以看作是在更高效地解这条 ODE 或近似其轨迹

## 相关链接（双向）

- [[扩散模型采样器（ODE / SDE）研究地图与主流论文]]
- [[扩散采样器主线论文索引]]
