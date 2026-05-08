---
created: 2026-04-09
published: 2021-04-15
type: paper
status: 未读
tags: [SR3, SuperResolution, Diffusion]
aliases: [SR3]
summary: "把扩散模型用于超分辨率，通过迭代细化显著提升高倍率细节真实性。"
pdf-url: "https://arxiv.org/pdf/2104.07636.pdf"
source-url:
  - https://arxiv.org/abs/2104.07636
  - https://arxiv.org/pdf/2104.07636.pdf
---

# Image Super-Resolution via Iterative Refinement

## Abstract
SR3 把条件扩散用于超分辨率：以低分辨率图像为条件，逐步去噪恢复高分辨率细节。论文证明了“迭代细化”在高倍率超分中的稳定性与真实感优势。

## 1 Introduction
作者将超分问题从“一次性回归”改写为“多步条件生成”，把细节恢复分配到多个去噪步中，以降低单步预测难度并提升纹理一致性。

## 2 Conditional Denoising Diffusion Model
### 2.1 Gaussian Diffusion Process
在高分辨率目标图像上定义前向噪声过程，保留标准扩散训练框架。

### 2.2 Optimizing the Denoising Model
学习条件去噪器 $\epsilon_	heta(x_t,t,y)$，其中 $y$ 为低分辨率输入。

### 2.3 Inference via Iterative Refinement
从高斯噪声开始，在条件 $y$ 约束下多步反推，逐步补足高频细节。

### 2.4 SR3 Model Architecture and Noise Schedule
论文给出用于超分的 U-Net 设计与噪声调度，强调条件注入方式与训练稳定性的关系。

## 3 Related Work
对比回归式超分、GAN 超分与感知损失路线，指出扩散式迭代细化在真实感和鲁棒性上更均衡。

## 4 Experiments
### 4.1 Qualitative Results
在人脸与自然图像上，纹理细节、边缘过渡更自然。

### 4.2 Benchmark Comparison
在多项指标和人评上取得领先，尤其高倍率场景优势明显。

### 4.3 Cascaded High-Resolution Image Synthesis
论文展示了把 SR3 用作级联超分模块的可行性，直接影响后续 Cascaded Diffusion/Imagen 设计。

## 5 Discussion and Conclusion
SR3 的关键贡献是把“扩散 + 超分”建立成通用组件，成为高分辨率生成链路中的标准模块。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
