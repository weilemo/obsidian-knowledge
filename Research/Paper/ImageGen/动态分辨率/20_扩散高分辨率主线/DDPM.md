---
created: 2026-04-09
published: 2020-06-19
type: paper
status: 未读
tags: [DDPM, Diffusion, ImageGeneration]
aliases: [DDPM, Denoising Diffusion Probabilistic Models]
summary: "确立扩散模型的高质量生成范式，成为后续高分辨率与可控生成工作的基础。"
pdf-url: "https://arxiv.org/pdf/2006.11239.pdf"
source-url:
  - https://arxiv.org/abs/2006.11239
  - https://arxiv.org/pdf/2006.11239.pdf
---

# Denoising Diffusion Probabilistic Models

## Abstract
DDPM 系统化提出前向加噪、反向去噪的生成框架，并给出可稳定优化的简化训练目标。论文展示了扩散模型在样本质量与分布覆盖上的强表现，奠定了后续高分辨率扩散路线。

## 1 Introduction
核心思想是把生成过程改写成“逐步去噪”的马尔可夫链，避免 GAN 对抗训练不稳定的问题。作者强调：更多采样步换来更稳的优化和更好覆盖。

## 2 Background
论文回顾变分推断与去噪评分匹配，说明扩散模型可以从概率建模和能量梯度两个视角理解。

## 3 Diffusion models and denoising autoencoders
### 3.1 Forward process and $L_T$
前向过程逐步向数据注入高斯噪声：
$$
q(x_t\mid x_{t-1})=\mathcal{N}(\sqrt{1-\beta_t}x_{t-1},\beta_t I)
$$
当 $t$ 足够大时，$x_t$ 逼近标准高斯。

### 3.2 Reverse process and $L_{1:T-1}$
反向过程学习参数化高斯：
$$
p_\theta(x_{t-1}\mid x_t)=\mathcal{N}(\mu_\theta(x_t,t),\Sigma_\theta(x_t,t))
$$
通过变分下界逐项优化去噪质量。

### 3.3 Data scaling, reverse process decoder, and $L_0$
讨论数据尺度、离散化与末端解码项对似然与视觉质量的影响。

### 3.4 Simplified training objective
论文最关键工程化结果是简化目标：
$$
L_{\text{simple}}=\mathbb{E}_{t,x_0,\epsilon}\left[\lVert\epsilon-\epsilon_\theta(x_t,t)\rVert_2^2\right]
$$
该目标训练稳定，成为后续主流做法。

## 4 Experiments
### 4.1 Sample quality
在 CIFAR-10 等基准上，扩散样本质量达到当时强基线水平。

### 4.2 Reverse process parameterization and training objective ablation
不同参数化和损失权重会影响质量与似然，简化目标在实践中最稳。

### 4.3 Progressive coding
论文展示了扩散过程的渐进式重建特性。

### 4.4 Interpolation
潜变量插值结果平滑，体现较好的语义连续性。

## 5 Related Work
与 GAN、自回归、flow 等生成路线做了系统比较，明确扩散在稳定性上的优势。

## 6 Conclusion
DDPM 把“高质量 + 稳定训练 + 可扩展”统一起来，是后续 SR3、LDM、Imagen、SDXL 等工作的共同基础。

## Broader Impact
论文讨论了生成模型在误导信息与内容滥用方面的潜在风险。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
