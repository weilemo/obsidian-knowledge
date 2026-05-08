---
created: 2026-04-09
published: 2024-03-15
type: paper
status: 未读
tags: [ArbitraryScale, ImplicitNeuralDecoder, DynamicResolution]
aliases: [Arbitrary-Scale-LDM-INR]
summary: "结合 LDM 与隐式神经解码器，把离散尺度生成推进到更连续的任意尺度图像生成与上采样。"
pdf-url: "https://arxiv.org/pdf/2403.10255.pdf"
source-url:
  - https://arxiv.org/abs/2403.10255
  - https://arxiv.org/pdf/2403.10255.pdf
---

# Arbitrary-Scale Image Generation and Upsampling using Latent Diffusion Model and Implicit Neural Decoder

## Abstract
论文将潜空间扩散（LDM）与隐式神经解码器（INR）结合，把图像生成从离散分辨率点扩展到连续尺度函数，实现任意尺度生成与上采样。

## 1 Introduction
作者关注的问题是：传统扩散模型通常在固定输出网格上工作，不适合连续尺度控制。为此提出“潜空间生成 + 连续坐标解码”的统一思路。

## 2 Related Work
相关工作覆盖三线：latent diffusion、超分辨率、隐式表示。本文创新点在于把三者串成单一任意尺度框架。

## 3 Preliminary
### 3.1 Latent Diffusion Models
在潜空间进行扩散建模，保证语义表达与计算效率。

### 3.2 Local Implicit Image Function
通过坐标条件隐式函数解码像素，使输出分辨率不再固定。

## 4 Method
### 4.1 Overview
框架分为 latent 生成器与 implicit decoder 两部分，前者负责内容，后者负责尺度连续化输出。

### 4.2 Encoder-Decoder
训练编码器/解码器将图像映射到稳定潜空间并保持感知保真。

### 4.3 Conditioning for Upsampling
在上采样任务中引入条件信号，使解码器在任意尺度仍保持结构一致。

### 4.4 Two-Stage Alignment Process
通过两阶段对齐，分别处理语义一致性与细节保真，降低跨尺度失真。

## 5 Experiment
### 5.1 Implementation
给出训练配置与数据设置。

### 5.2 Evaluation
覆盖任意尺度生成与超分两类任务。

### 5.3 Comparisons on Image-Generation
与固定分辨率生成基线相比，本文在灵活性与质量上更均衡。

### 5.4 Comparisons on Arbitrary SR
在连续尺度超分上展现了较好细节恢复能力。

### 5.5 Ablation Studies
验证了 implicit decoder 与两阶段对齐各自贡献。

## 6 Conclusions
这篇论文代表“连续尺度解码”路线，为后续分辨率无关生成范式（如 InfGen）提供了直接先验。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
