---
created: 2026-04-09
published: 2022-05-23
type: paper
status: 未读
tags: [Imagen, TextToImage, Diffusion]
aliases: [Imagen]
summary: "验证“大语言模型文本编码 + 级联扩散”路线，在文本对齐与写实性上达到里程碑表现。"
pdf-url: "https://arxiv.org/pdf/2205.11487.pdf"
source-url:
  - https://arxiv.org/abs/2205.11487
  - https://arxiv.org/pdf/2205.11487.pdf
---

# Photorealistic Text-to-Image Diffusion Models with Deep Language Understanding

## Abstract
Imagen 证明了“强文本编码器 + 级联扩散”在文本对齐与写实性上可以同时提升。论文显示语言理解能力对最终图像质量的影响，往往大于单纯增大图像模型参数。

## 1 Introduction
论文目标是提升文本可控生成的语义准确性与照片真实感。核心策略：用大规模预训练文本编码器提供更强语义先验，再用级联扩散完成高分辨率细化。

## 2 Imagen
### 2.1 Pretrained text encoders
论文发现更强文本编码器显著提升图文对齐，是系统性能的关键瓶颈。

### 2.2 Diffusion models and classifier-free guidance
使用条件/无条件联合训练与 guidance 融合，提高可控性。

### 2.3 Large guidance weight samplers
分析大 guidance 权重带来的质量-对齐收益，并讨论采样稳定性。

### 2.4 Robust cascaded diffusion models
采用基础模型 + 多级超分扩散链，实现高保真高分输出。

### 2.5 Neural network architecture
给出各级 U-Net 与条件注入设计，强调跨阶段的一致性。

## 3 Evaluating Text-to-Image Models
提出 DrawBench 等评测设置，覆盖语义关系、组合泛化、细粒度属性绑定等难点。

## 4 Experiments
### 4.1 Training details
说明数据规模、训练策略与计算预算。

### 4.2 Results on COCO
在自动指标上表现强，展示了较高保真与对齐。

### 4.3 Results on DrawBench
在人评与复杂提示词场景中表现突出。

### 4.4 Analysis of Imagen
分析文本编码器规模、guidance 权重和级联结构的贡献分解。

## 5 Related Work
与 VQ/VAE、GAN、自回归与扩散路线比较，强调语义编码与级联扩散的协同。

## 6 Conclusions, Limitations and Societal Impact
结论是“语言理解能力是文本生成质量上限的重要决定因素”；同时讨论了偏见、滥用与数据来源问题。

## 7 Acknowledgements
论文致谢了数据、基础设施与评测支持。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
