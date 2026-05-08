---
created: 2026-04-09
published: 2023-02-16
type: paper
status: 未读
tags: [MultiDiffusion, DynamicResolution, TuningFree]
aliases: [MultiDiffusion]
summary: "提出无需重训的多路径融合推理框架，支持全景、长宽比和空间约束等可控生成。"
pdf-url: "https://arxiv.org/pdf/2302.08113.pdf"
source-url:
  - https://arxiv.org/abs/2302.08113
  - https://arxiv.org/pdf/2302.08113.pdf
---

# MultiDiffusion: Fusing Diffusion Paths for Controlled Image Generation

## Abstract
MultiDiffusion 提出 training-free 推理框架：把同一全局潜变量拆成多个重叠视窗路径并联合优化，在不重训模型的前提下实现全景、任意宽高比与区域可控生成。

## 1 Introduction
问题定义是“预训练扩散通常绑定固定分辨率和默认构图”。论文主张在推理阶段重写采样约束，而非重新训练大模型。

## 2 Related Work
作者对比了两类路线：
- 训练期改模/微调（成本高）；
- 推理期控制（灵活但易出现拼接缝）。
MultiDiffusion 的目标是保留推理期灵活性，同时提升全局一致性。

## 3 Method
核心形式是共享全局变量的多路径一致优化。可写为：
$$
\min_x \sum_i \lVert M_i x - x_i^{	ext{denoise}} Vert_2^2
$$
其中 $M_i$ 表示第 $i$ 个视窗投影，$x_i^{	ext{denoise}}$ 是该路径的去噪估计。重叠区域通过联合最小化自动对齐，减少边界伪影。

## 4 Applications
### 4.1 Panorama
通过滑窗覆盖超宽画布，实现文本一致的全景生成。

### 4.2 Region-based text-to-image-generation
不同区域绑定不同文本条件，实现空间可控合成。

## 5 Results
### 5.1 Panorama Generation
在全景任务上相比直接拉伸分辨率，构图更稳定、重复伪影更少。

### 5.2 Region-based Text-to-Image Generation
区域语义绑定更准确，边界过渡更自然。

## 6 Discussion and Conclusions
论文证明了“推理期多路径融合”可以显著扩展预训练扩散模型能力，是 2023 年任意尺寸适配路线的关键起点。

## 7 Acknowledgments
作者感谢社区模型与评测资源支持。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
