---
created: 2026-04-30
published: 2023-02-09
type: paper
status: 未读
tags: [DiffusionSampler, Diffusion, Sampling, ODE, PredictorCorrector]
aliases: [UniPC]
summary: "统一 predictor 与 corrector 的解析形式，在不增加额外模型评估的情况下提升采样阶数，尤其适合极少步数采样。"
pdf-url: "https://arxiv.org/pdf/2302.04867.pdf"
source-url:
  - https://arxiv.org/abs/2302.04867
  - https://arxiv.org/pdf/2302.04867.pdf
---

# UniPC: A Unified Predictor-Corrector Framework for Fast Sampling of Diffusion Models

## Abstract

UniPC 把 fast sampler 里常见的 predictor-corrector 思路统一起来：先给出统一 predictor，再给出不用额外 NFE 的 corrector，从而在极少步数下进一步提升采样质量。

## Core Idea

- 统一不同阶数的 predictor-corrector 写法
- corrector 不额外消耗模型评估次数
- 可以接在已有 sampler 后面进一步提阶
- 在小于 10 步时往往比之前方法更有优势

## Key Formulation

UniPC 的核心不是某个单独公式，而是给出统一的解析族：

$$
x_{t_{i+1}}=\text{Predictor}(x_{t_i})+\text{Corrector}(x_{t_i}, x_{t_{i+1}})
$$

其中 corrector 被设计成不增加新的网络前向次数。

## Why It Matters

- 它像是对前面一批 ODE sampler 的“统一升级接口”
- 在极低步数推理里常被视作很强的 practical choice
- 如果你关心“能不能在不增加 NFE 的前提下再提一点质量”，这篇很关键

## 相关链接（双向）

- [[扩散模型采样器（ODE / SDE）研究地图与主流论文]]
- [[扩散采样器主线论文索引]]
