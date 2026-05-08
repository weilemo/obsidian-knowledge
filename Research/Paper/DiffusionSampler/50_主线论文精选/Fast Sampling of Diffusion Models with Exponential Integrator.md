---
created: 2026-04-30
published: 2022-04-29
type: paper
status: 未读
tags: [DiffusionSampler, Diffusion, Sampling, ODE, ExponentialIntegrator]
aliases: [DEIS]
summary: "提出 DEIS，把 diffusion ODE 写成适合指数积分器处理的半线性结构，在少步数场景下显著减少离散化误差。"
pdf-url: "https://arxiv.org/pdf/2204.13902.pdf"
source-url:
  - https://arxiv.org/abs/2204.13902
  - https://arxiv.org/pdf/2204.13902.pdf
---

# Fast Sampling of Diffusion Models with Exponential Integrator

## Abstract

这篇论文提出 DEIS，核心思路是利用 diffusion ODE 的半线性结构，把线性部分解析处理、把非线性部分交给指数积分器近似，从而在极少步数下保持更好的采样精度。

## Core Idea

- 关注采样误差里最关键的离散化误差
- 把 diffusion ODE 改写成半线性形式
- 使用 exponential integrator 降低少步数采样时的误差累积
- 在 10 到 15 步附近取得很强的质量速度比

## Key Formulation

其核心是把动力系统写成：

$$
\frac{\mathrm{d}x}{\mathrm{d}t}=A(t)x+b_\theta(x,t)
$$

然后解析处理线性项 $A(t)x$，只对其余部分做数值近似。

## Why It Matters

- 是 DPM-Solver 之外另一条重要 ODE sampler 主线
- 说明“利用方程结构”比直接套通用黑盒 ODE solver 更有效
- 在少步数 regime 下，经常被作为强基线或对照方法

## 相关链接（双向）

- [[扩散模型采样器（ODE / SDE）研究地图与主流论文]]
- [[扩散采样器主线论文索引]]
