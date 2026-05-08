---
created: 2026-01-25
published: 2025-06-09
type: paper
status: 已读
tags:
  - SelfForcing
  - Autoregressive
  - ExposureBias
  - Streaming
aliases:
  - Self-Forcing
summary: 自回归自滚动训练缓解曝光偏差
pdf-url: Attachments/arxiv_2506.08009.pdf
github-url: ""
source-url:
  - https://arxiv.org/abs/2506.08009
  - https://self-forcing.github.io/
---

# Self Forcing: Bridging the Train-Test Gap in Autoregressive Video Diffusion

## PDF
- [[Attachments/arxiv_2506.08009.pdf]]

## Abstract
Self Forcing 的核心是把“推理时自回归滚动”前移到训练中：每一帧都基于模型自己先前生成的上下文来生成，而不是基于真值上下文。这样训练目标直接对齐推理分布，显式缓解 exposure bias。论文进一步结合 few-step diffusion、随机截断反传和 rolling KV cache，使该训练范式在效率上可落地，并在实时性（吞吐+首帧延迟）和视频质量上同时取得强结果。

## 1 Introduction
论文针对当前视频生成的一个关键矛盾：
- 双向 DiT 扩散质量高，但需要整段并行去噪，不适合低延迟实时流式场景。
- 自回归方法天然低延迟，但传统 AR 训练（TF/DF）在推理时会累积误差，出现质量漂移。

作者把问题归因为 train-test gap（曝光偏差）：训练主要见“真值上下文”，推理只能见“模型自产生上下文”。Self Forcing 的思想是：训练时就让模型在这个真实推理分布下滚动生成，再用视频级分布匹配损失优化整段输出分布。

## 2 Related Work
论文将相关路线分为四类：
- GAN 视频生成：训练/推理路径一致，天然无曝光偏差。
- 纯扩散或纯 AR：前者质量高但延迟大，后者延迟低但常依赖 VQ 离散化且质量受限。
- AR-Diffusion 混合：近年来主线，但常因长链路误差累积而退化。
- Rolling diffusion 一类：能做长视频，但严格实时交互下响应仍受限。

与 CausVid 的关系最直接：二者都做 few-step AR diffusion + 分布匹配，但本文指出 CausVid 的训练输出分布与推理分布并不一致，Self Forcing 的改进点正是把这一分布错位修正掉。

## 3 Self Forcing: Bridging Train-Test Gap via Holistic Post-Training

### 3.1 Preliminaries: Autoregressive Video Diffusion
给定视频帧序列 $x^{1:N}$，AR 分解为：
$$
p(x^{1:N})=\prod_{i=1}^{N}p(x^i\mid x^{<i})
$$
每个条件项由 diffusion 近似。常规 TF/DF 训练仍以内层 denoising MSE 为主：
$$
\mathcal{L}^{\text{DM}}_\theta=\mathbb{E}\left[w_t\|\hat\epsilon_\theta-\epsilon\|_2^2\right]
$$
但它们的上下文来源与推理态不一致，是后续误差累积的根源。

### 3.2 Autoregressive Diffusion Post-Training via Self-Rollout
Self Forcing 在训练时执行真实自回归 rollout：
- 第 $i$ 帧在去噪时条件化于模型自己先前生成的 $x^{<i}_\theta$；
- 每步都写入 KV 缓存，下一帧直接读缓存；
- 用 few-step diffusion 近似条件生成，降低时间成本。

论文采用随机截断反传：每帧仅在随机采样的 denoising step $s$ 上开梯度，其余步只前向推进状态。这样既控制显存，又保证所有 denoising 步都能被采样监督到。

### 3.2.1 训练范式图（保留）
![[Pasted image 20260307155804.png]]

### 3.2.2 算法图解（Algorithm 1 vs Algorithm 2，保留）
![[Pasted image 20260307160009.png]]

这两张图对应论文算法的要点：
- `Algorithm 1`（Self Forcing Training）：训练中就做 AR rollout + KV append，最后对整段输出做分布匹配更新。
- `Algorithm 2`（AR Inference with Rolling KV Cache）：推理时缓存满了就 `pop(0)` + `append`，实现常数级缓存长度的长视频外推。

## 3.3 Holistic Distribution Matching Loss
Self Forcing 的关键不是只改采样流程，还改了监督对象：从“逐帧条件分布拟合”转成“整段视频分布拟合”。

论文在 noisy 分布上做对齐，可接多种目标：
- DMD（反向 KL）；
- SiD（Fisher divergence 视角）；
- GAN（JS 视角，判别器对抗）。

核心差异是：上下文来自模型分布 $p_\theta$，而不是数据分布 $p_{\text{data}}$（无论 clean 还是 noisy），这正是缓解曝光偏差的机制来源。

## 3.4 Long Video Generation with Rolling KV Cache
论文比较了三种外推方式：
- 双向模型：无 KV cache，重复计算重；
- 以往 causal diffusion：窗口平移时仍需重算重叠 KV；
- Self Forcing rolling KV：固定长度缓存滚动更新，不重算历史 KV。

复杂度上，rolling KV 将外推代价降到与窗口长度线性相关（文中给出 $O(TL)$ 级别）。

作者还指出一个工程细节：若训练中总让末端帧可见首帧 latent，推理时 rolling 后会出现统计失配与闪烁。因此训练时要显式模拟“末端看不到首帧 latent”的局部注意力窗口设置。

## 4 Experiments

### 4.1 Setup
- Backbone：Wan2.1-T2V-1.3B（Flow Matching 体系），4-step diffusion。
- 训练：以 Wan 初始化，做 causal ODE init + Self Forcing post-training。
- 目标：主文报告 DMD，消融中给出 SiD/GAN（性能接近）。
- 评测：VBench（total/quality/semantic）、用户偏好、吞吐 FPS、首帧延迟。

### 4.2 Main Results
在 1.3B 同级别公开模型对比里：
- `Self Forcing (chunk-wise)`：VBench total 84.31，semantic 81.28，吞吐 17.0 FPS，首帧延迟 0.69s。
- `Self Forcing (frame-wise)`：VBench total 84.26，首帧延迟 0.45s（最低）。

与 Wan2.1（many-step bidirectional）相比，本文强调其在保持/提升质量的同时把延迟降到两个数量级量级（文中称约 150x latency advantage 对比）。

用户偏好实验中，Self Forcing 也稳定优于关键基线（图见论文主文）。

### 4.3 Ablation
文中在 chunk-wise 与 frame-wise 两种 AR 设置下做了统一消融：
- many-step TF/DF；
- few-step + TF/DF + DMD（等价复现 CausVid 设定）；
- Self Forcing + DMD/SiD/GAN。

结论：
- Self Forcing 在三种分布匹配目标下都稳健领先；
- 基线从 chunk-wise 转 frame-wise 时退化明显（误差累积更严重），Self Forcing 退化显著更小。

### 4.4 Efficiency
论文给出两类效率结论：
- 推理效率：rolling KV 下 10s 外推可维持高吞吐（文中对比重算 KV 情况约 4.6 FPS vs rolling 16.1 FPS）。
- 训练效率：尽管 Self Forcing 含序列 rollout，但在 few-step + 截断策略下每迭代成本与 TF/DF 可比，并在同等 wall-clock 下更快达到更高质量。

## 5 Discussion
论文提出一个更一般的观点：
- 并行预训练很重要；
- 但对序列生成，后训练阶段引入“顺序化、推理态对齐”的优化是必要的。

作者将 Self Forcing 放在“parallel pre-training + sequential post-training”的范式中，认为这对视频以及其他连续序列生成任务都有推广潜力。

## 6 Limitations
文中明确了两点局限：
- 当外推长度远超训练上下文时，质量仍会下降；
- 为省显存采用的梯度截断可能限制超长依赖学习能力。

## 相关链接（双向）
- [[自回归视频]]
- [[曝光偏差]]
- [[流式视频生成]]
- [[CausVid✅]]
