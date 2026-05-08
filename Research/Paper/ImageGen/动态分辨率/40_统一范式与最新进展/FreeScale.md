---
created: 2026-04-09
published: 2024-12-12
type: paper
status: 未读
tags: [FreeScale, DynamicResolution, ScaleFusion]
aliases: [FreeScale]
summary: "提出 tuning-free 多尺度频域融合，缓解高分辨率高频误差累积并提升预训练模型分辨率上限。"
pdf-url: "https://arxiv.org/pdf/2412.09626.pdf"
source-url:
  - https://arxiv.org/abs/2412.09626
  - https://arxiv.org/pdf/2412.09626.pdf
---

# FreeScale: Unleashing the Resolution of Diffusion Models via Tuning-Free Scale Fusion

## Abstract
FreeScale 提出 tuning-free 的多尺度融合范式，通过自级联上采样、受约束空洞卷积与尺度融合机制，提升预训练扩散模型在高分辨率生成中的细节质量与稳定性。

## 1 Introduction
论文目标是让现有扩散模型在不训练情况下突破原生分辨率上限，重点解决高分阶段常见的高频误差累积和结构重复。

## 2 Related Work
将方法定位为 training-free 高分辨率适配，与 tiled、感受野修正、频域增强方法进行比较。

## 3 Methodology
### 3.1 Preliminaries
分析高分辨率外推中噪声预测偏差的来源。

### 3.2 Tailored Self-Cascade Upscaling
设计自级联上采样路径，逐层放大并校正误差。

### 3.3 Restrained Dilated Convolution
使用受约束空洞卷积扩大感受野，同时抑制周期伪影。

### 3.4 Scale Fusion
在多尺度结果间进行融合，平衡全局布局与局部高频细节。

## 4 Experiments
### 4.1 Higher-Resolution Image Generation
在图像任务上显著改善高分细节与构图稳定性。

### 4.2 Higher-Resolution Video Generation
方法可迁移到视频生成，说明其跨模态扩展潜力。

### 4.3 Ablation Study
消融验证了 cascade、dilated conv、fusion 三模块的互补作用。

## 5 Conclusion
FreeScale 强化了“推理期多尺度融合”这条路线，并把可用分辨率上限推进到更高区间。

## 6 Acknowledgements
论文致谢了开源社区与算力支持。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
