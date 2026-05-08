---
created: 2026-02-25
type: note
status: evergreen
tags: [generative-models, vae, autoregressive, diffusion, flow-matching, video-generation]
aliases: [生成模型四路线清单, VideoGen方向地图]
---

# 生成模型四路线与 VideoGen 方向地图

## 一、四个方向的经典/高影响力论文清单

### 1) VAE 路线
- [Auto-Encoding Variational Bayes](https://arxiv.org/abs/1312.6114) (2013)
- [Stochastic Backpropagation and Approximate Inference in Deep Generative Models](https://arxiv.org/abs/1401.4082) (2014)
- [beta-VAE: Learning Basic Visual Concepts with a Constrained Variational Framework](https://openreview.net/forum?id=Sy2fzU9gl) (ICLR 2017)
- [Neural Discrete Representation Learning (VQ-VAE)](https://arxiv.org/abs/1711.00937) (2017)
- [Generating Diverse High-Fidelity Images with VQ-VAE-2](https://arxiv.org/abs/1906.00446) (2019)
- 视频相关：
  - [Stochastic Variational Video Prediction (SV2P)](https://arxiv.org/abs/1710.11252) (2017)
  - [Stochastic Video Generation with a Learned Prior (SVG-LP)](https://arxiv.org/abs/1802.07687) (2018)

### 2) Autoregressive 路线
- [Pixel Recurrent Neural Networks (PixelRNN)](https://arxiv.org/abs/1601.06759) (2016)
- [PixelCNN++](https://arxiv.org/abs/1701.05517) (2017)
- [Image Transformer](https://arxiv.org/abs/1802.05751) (2018)
- [VideoGPT](https://arxiv.org/abs/2104.10157) (2021)
- [CogVideo](https://arxiv.org/abs/2205.15868) (2022)
- [VideoPoet](https://arxiv.org/abs/2312.14125) (2023)

### 3) Diffusion 路线
- [Deep Unsupervised Learning using Nonequilibrium Thermodynamics](https://arxiv.org/abs/1503.03585) (2015)
- [Denoising Diffusion Probabilistic Models (DDPM)](https://arxiv.org/abs/2006.11239) (2020)
- [Score-Based Generative Modeling through SDEs](https://arxiv.org/abs/2011.13456) (2021)
- [Improved DDPM](https://arxiv.org/abs/2102.09672) (2021)
- [Classifier-Free Diffusion Guidance](https://arxiv.org/abs/2207.12598) (2022)
- [Latent Diffusion Models](https://arxiv.org/abs/2112.10752) (2022)
- 视频里程碑：
  - [Video Diffusion Models](https://arxiv.org/abs/2204.03458) (2022)
  - [Imagen Video](https://arxiv.org/abs/2210.02303) (2022)
  - [Make-A-Video](https://arxiv.org/abs/2209.14792) (2022)
  - [Video generation models as world simulators (Sora)](https://openai.com/research/video-generation-models-as-world-simulators) (2024-02-15)

### 4) Flow Matching / Rectified Flow 路线
- [Flow Matching for Generative Modeling](https://arxiv.org/abs/2210.02747) (ICLR 2023)
- [Rectified Flow: A Marginal Preserving Approach to Optimal Transport](https://arxiv.org/abs/2209.14577) (2022)
- [Stochastic Interpolants: A Unifying Framework for Flows and Diffusions](https://arxiv.org/abs/2303.08797) (2023)
- [Consistency Models](https://arxiv.org/abs/2303.01469) (2023)
- [Scaling Rectified Flow Transformers for High-Resolution Image Synthesis (SD3)](https://arxiv.org/abs/2403.03206) (2024)

## 二、你当前 VideoGen 文件夹的论文主要在做什么方向

总体判断：你当前这批论文以 **Diffusion/Flow + Causal Streaming + 长视频一致性工程** 为主，核心主题是“如何把高质量短视频模型扩展到实时、可交互、分钟级/无限长生成”。

### A. 流式/实时长视频（主线）
- [[Self-Forcing ✅]]
- [[Self-Forcing++]]
- [[Rolling-Forcing✅]]
- [[CausVid✅]]
- [[LONGLIVE]]
- [[MotionStream]]
- [[Reward Forcing]]
- [[Deep Forcing]]
- [[Live Avatar]]

关键词：因果注意力、KV cache、attention sink、DMD 蒸馏、rolling window、低延迟。

### B. 无限长/分钟级一致性与抗漂移
- [[FIFO-Diffusion]]
- [[Stable Video Infinity]]
- [[BlockVid]]
- [[Pack and Force Your Memory]]
- [[Memory Forcing]]
- [[StreamingT2V]]

关键词：误差累积修复、memory 检索、对角去噪队列、块级扩散、长短期记忆融合。

### D. KV 缓存与量化（新分支）
- [[Quant-VideoGen]]

关键词：KV cache memory、2-bit quantization、semantic-aware smoothing、progressive residual quantization、长视频可部署性。

### C. 方法学基底/代表性基线
- [[Video Diffusion Models]]
- [[Diffusion-Forcing ✅]]
- [[History-Guidance✅]]

关键词：时空扩散基础、逐 token 噪声建模、历史条件引导。

## 三、结构性结论（对你后续读论文有用）
- 你的收藏不是在“纯模型发明”层面分散探索，而是高度集中在“训练-推理错配 + 长程漂移 + 实时交互”这条技术主线。
- 范式上多数是“非因果教师（高质量） -> 因果学生（低延迟）”的蒸馏路径。
- 这批论文与世界模型/交互式生成的交集很强，尤其是 `Memory Forcing`、`LONGLIVE`、`MotionStream`、`Live Avatar`。

## 四、建议你在 Vault 里继续补的三个缺口
- 缺一组“早期经典基线”卡片：PredNet、SVG、SAVP、VideoGPT、Imagen Video。
- 缺一组“评测基准”卡片：VBench、LV-Bench、FVD/人偏好评测分歧。
- 缺一组“系统工程”卡片：KV 预算策略、sink 设计、KV 量化、蒸馏目标对齐（DMD/奖励加权）。
