---
created: 2026-04-09
published: 2025-09-12
type: paper
status: 未读
tags: [InfGen, ResolutionAgnostic, ImageGeneration]
aliases: [InfGen]
summary: "提出分辨率无关范式：固定内容 latent + 一步解码任意分辨率，显著降低超高分辨率生成时延。"
pdf-url: "https://arxiv.org/pdf/2509.10441.pdf"
source-url:
  - https://arxiv.org/abs/2509.10441
  - https://arxiv.org/pdf/2509.10441.pdf
---

# InfGen: A Resolution-Agnostic Paradigm for Scalable Image Synthesis

## Abstract
InfGen 提出分辨率无关生成范式：先在固定潜空间表示内容，再由一步生成器解码任意分辨率图像，目标是在保持质量的同时显著降低超高分辨率生成时延。

## 1 Introduction
论文指出传统扩散的复杂度随分辨率急剧上升，难以直接扩展到超高分辨率。InfGen 的核心是把“内容建模”和“分辨率解码”解耦。

## 2 Related Work
### 2.1 Latent diffusion image generation
回顾潜空间扩散在效率上的优势与分辨率受限问题。

### 2.2 High-resolution image generation
对比级联、分块、training-free 修正等路线，说明它们仍受多步采样成本限制。

## 3 Method
### 3.1 Preliminary Background
定义固定分辨率潜变量表示与解码目标。

### 3.2 InfGen: Fixed Latent in, Arbitrary Image Out
使用分辨率无关解码器将同一 latent 映射到任意输出尺度，核心思想是“latent 内容不变，解码网格可变”。

### 3.3 Training-free Resolution Extrapolation
在推理阶段进一步做外推策略，提升超训练尺度下的可用性。

## 4 Experiment
### 4.1 Comparison with Alternative Image Tokenizers
比较不同 tokenizer/表示方式对分辨率泛化的影响。

### 4.2 Improving Performance for Diffusion Models
展示 InfGen 作为插件式组件可增强扩散系统效率。

### 4.3 Comparison to other State-of-the-Art Methods
在高分辨率生成质量与速度上相对现有 SOTA 具有竞争力。

## 5 Conclusion
InfGen 的意义在于把动态分辨率问题提升为“分辨率无关表示学习”问题，是从工程技巧走向统一范式的重要一步。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
