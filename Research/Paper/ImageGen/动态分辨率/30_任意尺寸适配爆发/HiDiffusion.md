---
created: 2026-04-09
published: 2023-11-29
type: paper
status: 未读
tags: [HiDiffusion, DynamicResolution, TuningFree]
aliases: [HiDiffusion]
summary: "提出 RAU-Net 与改造窗口注意力，在不微调模型下同时改善高分重复问题与推理效率。"
pdf-url: "https://arxiv.org/pdf/2311.17528.pdf"
source-url:
  - https://arxiv.org/abs/2311.17528
  - https://arxiv.org/pdf/2311.17528.pdf
---

# HiDiffusion: Unlocking Higher-Resolution Creativity and Efficiency in Pretrained Diffusion Models

## Abstract
HiDiffusion 提出 RAU-Net 与多尺度窗口注意力（MSW-MSA）等推理改造，在不训练模型的情况下同时提升高分辨率生成质量与速度。

## 1 Introduction
论文提出双目标：
- 质量侧解决高分辨率重复、结构失真；
- 效率侧降低高分推理计算开销。

## 2 Related Work
将方法放在两类工作之间：高分辨率质量修正与扩散推理加速。HiDiffusion 尝试把两者统一。

## 3 Method
### 3.1 Preliminaries
回顾预训练扩散模型在高分推理时的计算瓶颈和失真模式。

### 3.2 HiDiffusion
核心模块包括：
- RAU-Net：在推理路径中做分辨率自适应的 U-Net 结构重排；
- MSW-MSA：用多尺度窗口注意力平衡全局一致性与局部细节；
- 配套阈值切换策略，在不同尺度阶段动态启用模块。

## 4 Experiments
### 4.1 Experiment Settings
覆盖 SDXL 等主流预训练模型与多分辨率评测设置。

### 4.2 Main results
在高分图像生成上相比基线质量更好，且推理效率提升。

### 4.3 Ablation study
消融确认 RAU-Net 与 MSW-MSA 均有独立贡献，组合效果最佳。

## 5 Conclusion
HiDiffusion 证明了“推理路径结构化改造”能够同时推动质量和效率，是高分辨率适配中较完整的一体化方案。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
