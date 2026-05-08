---
created: 2026-04-09
published: 2021-05-30
type: paper
status: 未读
tags: [CascadedDiffusion, ImageGeneration, Diffusion]
aliases: [Cascaded-Diffusion-Models, CDM]
summary: "通过“基础扩散 + 多级超分扩散”实现高保真高分辨率生成，奠定级联扩散主线。"
pdf-url: "https://arxiv.org/pdf/2106.15282.pdf"
source-url:
  - https://arxiv.org/abs/2106.15282
  - https://arxiv.org/pdf/2106.15282.pdf
---

# Cascaded Diffusion Models for High Fidelity Image Generation

## Abstract
论文提出级联扩散（CDM）：先生成低分辨率图像，再由多级条件扩散逐步上采样到高分辨率，并通过 conditioning augmentation 缓解误差累积。

## 1 Introduction
作者指出直接在高分辨率训练扩散模型成本高、稳定性差。级联分解把任务拆成基础生成与超分子任务，兼顾质量与可训练性。

## 2 Background
### 2.1 Diffusion Models
回顾标准扩散训练和采样。

### 2.2 Conditional Diffusion Models
上采样模型写作 $p(x^{hi}\mid x^{lo})$，把低分输出作为条件。

### 2.3 Architectures
说明不同分辨率阶段采用不同容量网络，保持计算可控。

## 3 Conditioning Augmentation in Cascaded Diffusion Models
### 3.1 Blurring Augmentation
对条件低分图像加模糊，提升上采样器对条件偏差的鲁棒性。

### 3.2 Truncated Conditioning Augmentation
采用截断式噪声/模糊增强，在保留语义的同时提升泛化。

### 3.3 Non-truncated Conditioning Augmentation
进一步分析非截断设置下的效果与稳定性权衡。

## 4 Experiments
### 4.1 Main Cascading Pipeline Results
在 ImageNet 上验证了 64→128→256 级联路线的高保真优势。

### 4.2 Baseline Model Improvements
展示基础扩散器与上采样器各自改进对整体效果的贡献。

### 4.3 Conditioning Augmentation Experiments up to $64	imes64$
证明条件增强能显著降低级联误差传播。

### 4.4 Experiments at $128	imes128$ and $256	imes256$
高分辨率阶段质量提升更明显，说明该策略在大尺寸上收益更高。

### 4.5 Experiments on LSUN
在场景数据上同样保持稳定改进。

## 5 Related Work
对比 GAN 级联与单模型高分辨率生成，强调扩散级联在稳定性和质量上的综合优势。

## 6 Conclusion
CDM 把“级联 + 条件增强”做成高分辨率扩散主线，为 Imagen 等后续系统提供直接模板。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
