---
created: 2026-04-09
published: 2021-12-20
type: paper
status: 未读
tags: [LDM, LatentDiffusion, ImageGeneration]
aliases: [Latent-Diffusion-Models, LDM]
summary: "将扩散过程迁移到潜空间，大幅降低训练与推理成本，成为开源文生图工程基座。"
pdf-url: "https://arxiv.org/pdf/2112.10752.pdf"
source-url:
  - https://arxiv.org/abs/2112.10752
  - https://arxiv.org/pdf/2112.10752.pdf
---

# High-Resolution Image Synthesis with Latent Diffusion Models

## Abstract
LDM 把扩散过程从像素空间迁移到感知压缩后的潜空间，在显著降低计算成本的同时保持高视觉质量，并支持文本、布局、分割等多种条件控制。

## 1 Introduction
论文核心问题是“像素空间扩散太贵”。解决方案是先训练感知自编码器，把图像映射到信息密度更高的潜空间，再在潜空间做扩散建模。

## 2 Related Work
作者把方法定位在三条线的交汇处：感知压缩、扩散建模、条件生成。LDM 的创新是把三者整合成统一可扩展框架。

## 3 Method
### 3.1 Perceptual Image Compression
第一阶段训练自编码器 $(\mathcal{E},\mathcal{D})$，将 $x$ 压缩为 $z=\mathcal{E}(x)$，并保持感知保真。

### 3.2 Latent Diffusion Models
第二阶段在 $z$ 空间训练扩散模型，目标仍是噪声预测：
$$
\mathbb{E}\left[\lVert\epsilon-\epsilon_	heta(z_t,t)Vert_2^2ight]
$$
由于潜空间维度更低，训练与采样成本显著下降。

### 3.3 Conditioning Mechanisms
论文重点采用 cross-attention 注入文本或结构条件，这一设计后来成为开源文生图系统标准做法。

## 4 Experiments
### 4.1 On Perceptual Compression Tradeoffs
分析压缩倍率与生成质量、计算成本之间的折中。

### 4.2 Image Generation with Latent Diffusion
在无条件/类条件生成上，LDM 在效率和质量之间取得优秀平衡。

### 4.3 Conditional Latent Diffusion
文本到图像任务表现强，说明潜空间扩散可承载复杂语义条件。

### 4.4 Super-Resolution with Latent Diffusion
展示潜空间扩散可扩展到超分辨率任务。

### 4.5 Inpainting with Latent Diffusion
通过掩码条件实现高质量修复与编辑。

## 5 Limitations & Societal Impact
论文讨论了数据偏见、滥用风险与高算力依赖问题。

## 6 Conclusion
LDM 的历史地位是“效率拐点”：它让高质量扩散从研究原型走向可落地平台，成为后续 SD/SDXL 体系的底座。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
