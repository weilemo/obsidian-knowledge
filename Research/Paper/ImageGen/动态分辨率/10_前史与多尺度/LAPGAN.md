---
created: 2026-04-09
published: 2015-06-18
type: paper
status: 未读
tags: [LAPGAN, ImageGeneration, MultiScale]
aliases: [LAPGAN]
summary: "以拉普拉斯金字塔逐层生成图像，奠定“先粗后细”的多尺度生成思路。"
pdf-url: "https://arxiv.org/pdf/1506.05751.pdf"
source-url:
  - https://arxiv.org/abs/1506.05751
  - https://arxiv.org/pdf/1506.05751.pdf
---

# Deep Generative Image Models using a Laplacian Pyramid of Adversarial Networks

## Abstract
论文把生成过程拆成拉普拉斯金字塔的多尺度残差建模：先生成低分辨率“粗图”，再逐层补高频细节。核心价值是把高分辨率生成分解为多个更稳定的小问题，每层都由条件 GAN 建模。

## 1 Introduction
作者关注的核心矛盾是：单尺度生成器在高分辨率上训练不稳定、细节不真实。为此论文提出 coarse-to-fine 生成路线，在更低维空间先锁定全局结构，再在高层残差中学习纹理。

## 1.1 Related Work
这一节把工作放在三条脉络下：
- GAN 生成高质量样本但在高分辨率下不稳定；
- 多尺度表示（如拉普拉斯金字塔）在视觉重建中有效；
- 论文把“多尺度表示”与“对抗生成”结合成统一框架。

## 2 Approach
### 2.1 Generative Adversarial Networks
每一层都采用标准条件 GAN，对应一个生成器 $G_k$ 和判别器 $D_k$，目标是让该层生成的细节残差与真实残差分布一致。

### 2.2 Laplacian Pyramid
图像分解为低频基底与多层高频残差：
$$
I_k = u(I_{k+1}) + h_k
$$
其中 $u(\cdot)$ 为上采样算子，$h_k$ 是第 $k$ 层高频残差。该分解天然适合“逐层补细节”的生成过程。

### 2.3 Laplacian Generative Adversarial Networks (LAPGAN)
采样时先生成最粗尺度图像，再条件生成各层残差并逐层重建。训练时各层相对独立，推理时串联，形成可控的层级生成链。

## 3 Model Architecture & Training
### 3.1 CIFAR10 and STL
在小图像数据上采用较轻量卷积网络，验证“分层残差生成”对清晰度和结构稳定性的提升。

### 3.2 LSUN
在更高分辨率场景中，论文展示了 LAPGAN 的可扩展性：与单一生成器相比，层级生成在大场景纹理上更自然。

## 4 Experiments
### 4.1 Evaluation of Log-Likelihood
论文用 Parzen 窗近似比较样本似然，结果支持该方法优于同时期基线。

### 4.2 Model Samples
可视化显示：低频结构先成形，高频细节逐层增强，符合方法设计直觉。

### 4.3 Human Evaluation of Samples
人评结果显示 LAPGAN 生成样本的真实性显著提升，是早期高分辨率生成的重要证据。

## 5 Discussion
论文的长期贡献不在“最终 SOTA 指标”，而在提出了被后续广泛复用的范式：
- 多尺度分解降低高分辨率生成难度；
- 先布局、后补纹理的生成顺序更稳定。

## Appendix A
附录补充了实现细节与额外可视化。对今天复现而言，重点是理解“分层残差建模”思想，而不是原始网络配置。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
