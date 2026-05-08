---
created: 2026-04-30
published: 2022-11-02
type: paper
status: 未读
tags: [DiffusionSampler, Diffusion, Sampling, ODE, Guidance]
aliases: [DPM-Solver++, DPM++]
summary: "把 DPM-Solver 推进到 guided sampling 场景，通过 data prediction 与多步稳定化设计，在大 guidance scale 下仍能保持高速高质。"
pdf-url: "https://arxiv.org/pdf/2211.01095.pdf"
source-url:
  - https://arxiv.org/abs/2211.01095
  - https://arxiv.org/pdf/2211.01095.pdf
---

# DPM-Solver++: Fast Solver for Guided Sampling of Diffusion Probabilistic Models

## Abstract

原始 DPM-Solver 在线性无引导场景很强，但在高 guidance scale 下不够稳。DPM-Solver++ 的贡献就是把这条高阶 ODE 路线推进到 guided sampling，并给出更实用的多步版本。

## Core Idea

- 聚焦 classifier-free guidance 等引导场景
- 使用 data prediction model 替代更不稳定的直接形式
- 用 thresholding 和 multistep 设计提升稳定性
- 保持 15 到 20 步级别的高质量生成

## Key Formulation

这篇的关键转变不是新写一个完全不同的 ODE，而是改用更适合 guided sampling 的预测变量与离散化方式。  
多步设计可以理解为通过减小有效步长来抑制 guidance 放大的不稳定性。

## Why It Matters

- 这是现在很多 `DPM++` 工程采样器名字的直接源头
- 面向 text-to-image 实用系统时，它比只看 DDIM 或原始 DPM-Solver 更贴近真实场景
- 如果关心大 CFG scale 下的采样稳定性，这篇很重要

## 相关链接（双向）

- [[扩散模型采样器（ODE / SDE）研究地图与主流论文]]
- [[扩散采样器主线论文索引]]
