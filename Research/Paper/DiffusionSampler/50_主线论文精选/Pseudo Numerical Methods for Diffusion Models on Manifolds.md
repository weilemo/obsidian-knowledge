---
created: 2026-04-30
published: 2022-01-28
type: paper
status: 未读
tags: [DiffusionSampler, Diffusion, Sampling, ODE, NumericalMethod]
aliases: [PNDM, PLMS]
summary: "把扩散采样明确看成流形上的数值求解问题，是早期最有代表性的高阶快速采样方法之一。"
pdf-url: "https://openreview.net/pdf?id=PlKWVd2yBkY"
source-url:
  - https://openreview.net/forum?id=PlKWVd2yBkY
  - https://openreview.net/pdf?id=PlKWVd2yBkY
---

# Pseudo Numerical Methods for Diffusion Models on Manifolds

## Abstract

PNDM 试图回答一个直接问题：既然扩散采样本质上是在解微分方程，那为什么不把经典数值方法系统搬进来？它把 DDIM 解释成更一般 pseudo numerical methods 的一个特殊情形，并提出了更强的 pseudo linear multistep 采样器。

## Core Idea

- 把扩散采样视作求解微分方程
- 强调“数据位于流形附近”，不能直接生搬硬套传统数值积分
- 设计 pseudo numerical method，使离散步进更贴近数据流形
- 在工程上带火了 `PLMS` 这类多步快速采样器

## Key Formulation

这篇论文的重要性更多在于“数值方法视角”而非某个单一公式。  
它的核心思想是把一步更新拆成：

$$
\text{gradient part} + \text{transfer part}
$$

然后把传统多步法改写成更适合扩散数据流形的 pseudo 版本。

## Why It Matters

- 是从“DDIM 风格一阶方法”走向“高阶 / 多步方法”的关键桥梁
- 早期很多实际系统都使用过 PLMS / PNDM sampler
- 它帮助后续工作自然过渡到 DPM-Solver、UniPC 等更系统的高阶路线

## 相关链接（双向）

- [[扩散模型采样器（ODE / SDE）研究地图与主流论文]]
- [[扩散采样器主线论文索引]]
