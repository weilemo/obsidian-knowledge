---
created: 2026-01-27
type: paper
status: unread
tags: ["video-generation", "diffusion", "text-to-video", "prediction", "unconditional"]
aliases: ["Video Diffusion Models"]
summary: "扩散模型首次系统化视频生成"
pdf-url: "Attachments/arxiv_2204.03458.pdf"
github-url: ""
---

# Video Diffusion Models
## 一句话摘要
将标准扩散模型扩展到视频，提出重建引导采样以实现长视频扩展与条件生成。

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
- 3D U-Net：将 2D 卷积改为空间卷积（如 $1\times3\times3$）。
- 在空间注意力后加入时间注意力块（使用相对位置编码）。
- 通过掩码可退化为独立图像建模，用于图像+视频联合训练。

### 3.1 Reconstruction-guided sampling for improved conditional generation
**问题**：替换法（replacement）对条件 $x_a$ 的一致性不足。

**重建引导**：近似条件分布并加入重建梯度项：
$$
q(x_a\mid z_t)\approx \mathcal{N}(\hat x_{a,\theta}(z_t),\sigma_t^2 I)
$$
$$
\tilde x_{b,\theta}(z_t)=\hat x_{b,\theta}(z_t)-\frac{w_r\alpha_t}{2}\,\nabla_{z_t}\|x_a-\hat x_{a,\theta}(z_t)\|^2\quad (7)
$$

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
