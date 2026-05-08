---
created: 2026-04-30
published: 2022-06-01
type: paper
status: 未读
tags: [DiffusionSampler, Diffusion, Sampling, ODE, Engineering]
aliases: [EDM, Karras Sampler]
summary: "系统梳理扩散模型训练与采样设计空间，把 Euler、Heun、sigma schedule 等工程实践推到主流。"
pdf-url: "https://arxiv.org/pdf/2206.00364.pdf"
source-url:
  - https://arxiv.org/abs/2206.00364
  - https://arxiv.org/pdf/2206.00364.pdf
---

# Elucidating the Design Space of Diffusion-Based Generative Models

## Abstract

EDM 的核心价值是“把一团混乱的扩散工程技巧拆开讲清楚”。它没有单独发明 Euler 或 Heun 这些经典数值法，但它把 sigma schedule、网络预条件化、采样器离散化等因素系统化，直接塑造了后续工程界最常见的 sampler 配方。

## Core Idea

- 明确区分训练设计、预条件化、噪声参数化与采样设计
- 把 sampler 的行为放回连续噪声尺度 $\sigma$ 空间分析
- 证明很多性能提升来自一套更合适的设计组合，而不是单个 trick
- 推广了 Euler、Heun、ancestral 变体在扩散推理中的使用方式

## Key Formulation

EDM 常把采样视为在噪声尺度网格上推进状态：

$$
x_{i+1}=x_i+h_i f(x_i,\sigma_i)
$$

当采用 Heun 校正时，会进一步利用下一点评估来降低局部截断误差。

## Why It Matters

- WebUI 与 `k-diffusion` 生态里很多常见采样器命名都能追到这篇
- `Euler`、`Heun`、`Euler a` 这类工程实战采样器在这篇之后真正系统化
- 如果要理解今天为什么这些 sampler 好用，EDM 是必读论文

## 相关链接（双向）

- [[扩散模型采样器（ODE / SDE）研究地图与主流论文]]
- [[扩散采样器主线论文索引]]
