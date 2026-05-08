---
created: 2026-01-27
published: 2022-04-07
type: paper
status: 已读
tags:
  - video-generation
  - diffusion
  - text-to-video
  - prediction
  - unconditional
aliases:
  - Video Diffusion Models
summary: 扩散模型首次系统化视频生成
pdf-url: Attachments/arxiv_2204.03458.pdf
github-url: ""
---

# Video Diffusion Models
## 一句话摘要
将标准扩散模型扩展到视频，提出重建引导采样以实现长视频扩展与条件生成。

## 提出的范式（你关心的结论）
- 在视频生成里系统化了 `Full-Seq Diffusion` 范式：把一个固定长度视频片段作为整体联合变量，在同一扩散步对所有帧使用同级噪声，并用非因果时空去噪网络联合复原整段视频。
- 该范式区别于 `Teacher Forcing`/纯 AR：不是逐步喂真实历史做下一帧预测，而是对整段序列做联合扩散与联合去噪。
- 在 `Diffusion Forcing` 论文图里，`Full-Seq Diffusion` 侧主要对应这一类工作（视频代表作就是本篇）。

## PDF
[[Attachments/arxiv_2204.03458.pdf]]

## Abstract
- 提出视频扩散模型（3D U-Net + 空间/时间注意力）。
- 联合图像与视频训练降低梯度方差，加速优化。
- 提出重建引导采样用于时空扩展与条件生成。
- 在无条件生成、视频预测与文本生成上达到 SOTA。

## 1 Introduction
- 目标：高保真、时间一致的视频生成。
- 基于标准高斯扩散模型，主要改动是适配视频的 3D 架构与注意力。
- 通过条件采样方法实现长视频扩展与分辨率提升。

## 2 Background
### 扩散前向过程
$$
q(z_t\mid x)=\mathcal{N}(z_t;\alpha_t x,\sigma_t^2 I)
$$
$$
q(z_t\mid z_s)=\mathcal{N}\bigl(z_t; (\alpha_t/\alpha_s) z_s,\sigma_{t\mid s}^2 I\bigr)
$$
$$
\sigma_{t\mid s}^2=(1-e^{\lambda_t-\lambda_s})\,\sigma_t^2/\sigma_s^2\quad (1)
$$

### 训练目标
$$
\mathbb{E}_{\epsilon,t}\bigl[w(\lambda_t)\,\|\hat x_\theta(z_t)-x\|^2\bigr]\quad (2)
$$
- 使用 $\epsilon$-prediction 与 $v$-prediction 变体。

### 采样（祖先采样 + 预测-校正）
$$
q(z_s\mid z_t,x)=\mathcal{N}(z_s;\tilde\mu_{s\mid t}(z_t,x),\tilde\sigma_{s\mid t}^2 I)\quad (3)
$$
$$
z_s=\tilde\mu_{s\mid t}(z_t,\hat x_\theta(z_t))+
\sqrt{(\tilde\sigma_{s\mid t}^2)^{1-\gamma}(\sigma_{t\mid s}^2)^\gamma}\,\epsilon\quad (4)
$$
$$
z_s\leftarrow z_s-\delta\sigma_s\epsilon_\theta(z_s)+\sqrt{\delta\sigma_s}\,\epsilon'\quad (5)
$$

### 条件生成（classifier-free guidance）
$$
\tilde\epsilon_\theta(z_t,c)=(1+w)\epsilon_\theta(z_t,c)-w\epsilon_\theta(z_t)\quad (6)
$$

## 3 Video diffusion models
### 架构
![[Video-Diffusion-Models 架构.excalidraw]]

- 3D U-Net：将 2D 卷积改为空间卷积（如 $1\times3\times3$）。
- 在空间注意力后加入时间注意力块（使用相对位置编码）。
- 通过掩码可退化为独立图像建模，用于图像+视频联合训练。

### 3.1 Reconstruction-guided sampling for improved conditional generation
**问题**：替换法（replacement）对条件 $x_a$ 的一致性不足。数学解释及其严谨！

**重建引导**：近似条件分布并加入重建梯度项：
$$
q(x_a\mid z_t)\approx \mathcal{N}(\hat x_{a,\theta}(z_t),\sigma_t^2 I)
$$
$$
\tilde x_{b,\theta}(z_t)=\hat x_{b,\theta}(z_t)-\frac{w_r\alpha_t}{2}\,\nabla_{z_t}\|x_a-\hat x_{a,\theta}(z_t)\|^2\quad (7)
$$
**怎么理解这里的重建引导**

- 我们把样本分成已知部分 xaxa 和未知部分 xbxb，目标是采样 pθ(xb∣xa)pθ​(xb∣xa)。
- 在反向扩散每一步，未知部分 ztbztb​ 按常规反向 SDE / PC 更新（不改公式）。
- 已知部分 ztazta​ 不让模型“自由生成”，而是**替换**成前向噪声过程下的条件样本：q(zta∣xa)q(zta​∣xa)。
- 所以每一步都把“条件信息”强行写回去，确保已知区域始终满足观测约束。

**为什么这样做**

- 替换后，zta 的边缘分布是正确的（和前向过程一致）。
- ztb 虽然是按标准反向更新，但会通过去噪网络的耦合（输入是 [zta,ztb][zta​,ztb​]）被条件 xa 影响。
- 文中还提到更严格版本：从 q(zta∣xa,ztb) 采样，会同时满足条件分布与边缘分布。

**空间超分辨率扩展**：
$$
\tilde x_\theta(z_t)=\hat x_\theta(z_t)-\frac{w_r\alpha_t}{2}\,\nabla_{z_t}\|x_a-\hat x_{a,\theta}(z_t)\|^2\quad (8)
$$
- 可用于时间外推与时空超分辨率的联合条件生成。

## 4 Experiments
### 4.1 Unconditional video modeling
- 数据：UCF101，16 帧、$64\times64$。
- 指标：FID、IS；在对比中显著提升。

### 4.2 Video prediction
- BAIR Robot Pushing：条件 1 帧生成后 15 帧，FVD 显著改善。
- Kinetics-600：条件 5 帧生成 11 帧，FVD/IS 提升；评估细节控制采样偏差。

### 4.3 Text-conditioned video generation
- 使用 1000 万字幕视频（BERT-large embedding）。
#### 4.3.1 Joint training on video and image modeling
- 追加独立图像帧降低梯度方差，提升质量。
#### 4.3.2 Effect of classifier-free guidance
- 指导权重提升 IS，FID 存在权衡最优区间。
#### 4.3.3 Autoregressive video extension for longer sequences
- 重建引导优于替换法，长序列更一致。

## 5 Related work
- 与 AR、VAE、GAN、Flow 视频生成对比。
- 与帧级扩散+RNN 类方法差异：本文直接在视频块上建模。

## 6 Conclusion
- 标准扩散模型可扩展到视频并达到 SOTA。
- 重建引导采样可实现长序列扩展与时空超分。
- 讨论了模型发布的潜在安全与偏见风险。

## 相关链接（双向）
- [[Diffusion Models]]
- [[Video Generation]]
- [[Classifier-Free Guidance]]
