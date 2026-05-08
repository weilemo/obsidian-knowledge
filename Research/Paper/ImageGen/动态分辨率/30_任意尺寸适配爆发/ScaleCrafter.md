---
created: 2026-04-09
published: 2023-10-11
type: paper
status: 未读
tags: [ScaleCrafter, DynamicResolution, TuningFree]
aliases: [ScaleCrafter]
summary: "从感受野不足解释高分辨率重复问题，提出推理期卷积重膨胀等策略进行无训练修正。"
pdf-url: "https://arxiv.org/pdf/2310.07702.pdf"
source-url:
  - https://arxiv.org/abs/2310.07702
  - https://arxiv.org/pdf/2310.07702.pdf
---

# ScaleCrafter: Tuning-free Higher-Resolution Visual Generation with Diffusion Models

## Abstract
ScaleCrafter 从“感受野与分辨率失配”解释高分辨率重复伪影，提出 re-dilation、convolution dispersion 与 noise-damped guidance，在不训练的前提下提升高分辨率生成质量。

## 1 Introduction
论文聚焦一个典型现象：直接把采样分辨率调高会出现重复物体、结构断裂。作者认为根因是训练时与推理时感受野覆盖比例不一致。

## 2 Related work
### 2.1 Text-to-Image Synthesis
回顾主流文生图扩散模型的能力边界。

### 2.2 High-resolution synthesis and adaptation
对比级联超分、拼接式推理与其他 training-free 适配方法。

## 3 Method
### 3.1 Problem Formulation and Motivation
形式化描述高分辨率外推下的统计偏移与感受野不足问题。

### 3.2 Re-dilation
通过推理期卷积重膨胀扩大有效感受野，增强全局结构一致性。

### 3.3 Convolution Dispersion
对卷积采样分布做修正，缓解高分下纹理重复和周期伪影。

### 3.4 Noise-damped Classifier-free Guidance
在高分阶段抑制过强 guidance 引发的伪细节放大，提升稳定性。

## 4 Experiments
### 4.1 Evaluation
在多个分辨率与长宽比设定中，视觉一致性与细节质量均改善。

### 4.2 Ablation Study
消融表明三项模块互补：re-dilation 管全局，dispersion 管局部，noise-damped CFG 管稳定性。

### 4.3 Apply on Video Diffusion Models
方法可迁移到视频扩散，说明其本质是分辨率外推层面的通用修正。

## 5 Conclusions
ScaleCrafter 的关键贡献是把“感受野失配”变成可操作的推理期修正方案，推动了 tuning-free 高分辨率适配研究。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
