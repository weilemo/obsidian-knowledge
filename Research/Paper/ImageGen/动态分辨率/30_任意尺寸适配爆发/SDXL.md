---
created: 2026-04-09
published: 2023-07-04
type: paper
status: 未读
tags: [SDXL, TextToImage, HighResolution]
aliases: [SDXL]
summary: "通过更大骨干、双文本编码器和多长宽比训练，显著提升开源文生图高分辨率质量。"
pdf-url: "https://arxiv.org/pdf/2307.01952.pdf"
source-url:
  - https://arxiv.org/abs/2307.01952
  - https://arxiv.org/pdf/2307.01952.pdf
---

# SDXL: Improving Latent Diffusion Models for High-Resolution Image Synthesis

## Abstract
SDXL 在 LDM 基础上通过更大容量 U-Net、双文本编码器、多长宽比训练与改进 VAE，系统提升了开源文生图在高分辨率场景的质量与可控性。

## 1 Introduction
论文目标不是单点改进，而是给出“可工业化落地”的高分辨率 LDM 升级路径，强调架构、条件设计、训练分布三者协同。

## 2 Improving Stable Diffusion
### 2.1 Architecture & Scale
增大主干容量并重配模块比例，提升高分辨率细节表达能力。

### 2.2 Micro-Conditioning
把尺寸、裁剪等元信息显式作为条件，降低分辨率与构图漂移。

### 2.3 Multi-Aspect Training
在训练中引入多长宽比数据分布，提升非方图生成稳定性。

### 2.4 Improved Autoencoder
改进 VAE 重建质量，减少高频细节损失和纹理糊化。

### 2.5 Putting Everything Together
论文将以上模块组合成两阶段 pipeline（base + refiner），在质量与速度之间取得平衡。

## 3 Future Work
提出后续方向：更高分辨率、视频扩展、更鲁棒的复杂文本对齐与更低推理成本。

## Appendix B Limitations
论文明确局限：
- 仍可能出现文本细粒度绑定失败；
- 极端尺寸/复杂提示下稳定性仍非完美；
- 训练与部署资源成本较高。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
