---
created: 2026-04-09
published: 2017-10-27
type: paper
status: 未读
tags: [ProgressiveGAN, ImageGeneration, MultiScale]
aliases: [Progressive-GAN, ProgressiveGAN]
summary: "通过逐步增加分辨率和网络容量稳定 GAN 训练，显著提升高分辨率生成质量。"
pdf-url: "https://arxiv.org/pdf/1710.10196.pdf"
source-url:
  - https://arxiv.org/abs/1710.10196
  - https://arxiv.org/pdf/1710.10196.pdf
---

# Progressive Growing of GANs for Improved Quality, Stability, and Variation

## Abstract
论文提出 progressive growing：训练从低分辨率开始，逐步向高分辨率扩展网络层并平滑过渡。该策略显著稳定了 GAN 的高分辨率训练，并提升样本多样性与清晰度。

## 1 Introduction
作者把问题定义为“高分辨率 GAN 的优化难度过高”。核心解法是课程式训练：先学全局结构，再学局部细节，避免一开始就在超高维空间对抗。

## 2 Progressive growing of GANs
生成器和判别器同步“长大”，新层通过 fade-in 与旧路径平滑融合。这个机制避免了分辨率切换时训练震荡，是整篇论文最关键的工程贡献。

## 3 Increasing variation using minibatch standard deviation
论文引入 minibatch standard deviation 特征，显式把 batch 内变化注入判别器，缓解 mode collapse，提升生成多样性。

## 4 Normalization in generator and discriminator
### 4.1 Equalized learning rate
通过运行时权重缩放统一不同层的学习速度，减少初始化敏感性。

### 4.2 Pixelwise feature vector normalization in generator
在生成器特征上做像素级归一化，抑制激活爆炸并提高训练稳定性。

## 5 Multi-scale statistical similarity for assessing GAN results
论文提出 MS-SSIM 风格的多尺度统计比较来分析质量与多样性，不只依赖单一分数，强调评测维度完整性。

## 6 Experiments
### 6.1 Importance of individual contributions in terms of statistical similarity
消融显示 progressive growing、equalized LR、minibatch stddev 都有独立增益。

### 6.2 Convergence and training speed
课程式训练更快进入可用样本区间，收敛更平滑。

### 6.3 High-resolution image generation using CelebA-HQ dataset
在人脸高分辨率生成上取得当时里程碑结果。

### 6.4 LSUN results
在复杂场景下仍保持较高稳定性。

### 6.5 CIFAR10 inception scores
在低分辨率标准基准上同样保持竞争力。

## 7 Discussion
这篇工作的历史意义在于把“高分辨率生成”从难以训练变成可工程化流程，直接影响了后来的渐进式、多阶段、级联式生成路线。

## 8 Acknowledgements
论文致谢数据与工程支持团队。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
