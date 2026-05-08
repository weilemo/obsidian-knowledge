---
created: 2026-04-30
published: 2022-06-02
type: paper
status: 未读
tags: [DiffusionSampler, Diffusion, Sampling, ODE, HighOrderSolver]
aliases: [DPM-Solver]
summary: "为 diffusion ODE 设计专用高阶求解器，通过解析处理线性部分，把高质量采样压缩到大约 10 到 20 步。"
pdf-url: "https://arxiv.org/pdf/2206.00927.pdf"
source-url:
  - https://arxiv.org/abs/2206.00927
  - https://arxiv.org/pdf/2206.00927.pdf
---

# DPM-Solver: A Fast ODE Solver for Diffusion Probabilistic Model Sampling in Around 10 Steps

## Abstract

DPM-Solver 的关键不是“再套一个高阶 ODE solver”，而是专门针对 diffusion ODE 的结构推导解的形式。论文把线性部分解析掉，再对神经网络项做高阶近似，于是能在 10 到 20 步内完成高质量采样。

## Core Idea

- 直接围绕 diffusion ODE 的闭式结构设计 solver
- 不是把所有项都留给黑盒 ODE 数值器
- 支持离散时间与连续时间 diffusion model
- 用更低 NFE 达到高采样质量

## Key Formulation

它针对的是 probability flow ODE：

$$
\frac{\mathrm{d}x_t}{\mathrm{d}t}=f_{\theta}(x_t,t)
$$

其关键贡献是把解改写为“线性项可解析、神经网络项用高阶近似”的形式，因此能构造出专门的高阶 solver。

## Why It Matters

- 这是今天最核心的 ODE sampler 家族之一
- 很多现代采样器实现都会直接引用 DPM-Solver 的推导
- 后续 DPM-Solver++、多步 DPM++ 采样器都建立在这条线之上

## 相关链接（双向）

- [[扩散模型采样器（ODE / SDE）研究地图与主流论文]]
- [[扩散采样器主线论文索引]]
