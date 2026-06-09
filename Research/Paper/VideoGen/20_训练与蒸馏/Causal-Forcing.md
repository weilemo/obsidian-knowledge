---
created: 2026-05-11
published: 2026-02-02
type: paper
status: 已读
tags:
  - CausalForcing
  - VideoGeneration
  - Autoregressive
  - Distillation
  - ODEDistillation
  - DMD
aliases:
  - Causal Forcing
  - "Causal Forcing: Autoregressive Diffusion Distillation Done Right for High-Quality Real-Time Interactive Video Generation"
summary: Causal Forcing 指出 Self Forcing 类方法用双向 teacher 做 AR student 的 ODE 初始化时违反 frame-level injectivity，导致学生学到条件均值而非真实 flow map；它先用 teacher forcing 训练 AR diffusion teacher，再用该 AR teacher 做 causal ODE distillation，最后接 asymmetric DMD，在相同训练预算和推理速度下显著提升动态、视觉质量和指令遵循。
pdf-url: Attachments/arxiv_2602.02214.pdf
github-url: https://github.com/thu-ml/Causal-Forcing
source-url:
  - https://arxiv.org/abs/2602.02214
  - https://doi.org/10.48550/arXiv.2602.02214
  - https://thu-ml.github.io/CausalForcing.github.io/
---

# Causal Forcing: Autoregressive Diffusion Distillation Done Right for High-Quality Real-Time Interactive Video Generation

## PDF
- [[Attachments/arxiv_2602.02214.pdf]]

## 一句话摘要
Causal Forcing 的核心是：把双向视频扩散模型蒸馏成自回归模型时，ODE 初始化阶段不能继续用双向 teacher；必须先得到一个真正的 AR diffusion teacher，再从它采样 PF-ODE 轨迹，否则 frame-level injectivity 不成立，学生会学成模糊的条件均值。

## Abstract
这篇论文直接挑战 `Self Forcing / CausVid` 这一类 asymmetric distillation pipeline。已有方法通常从一个 bidirectional video diffusion teacher 出发，把它蒸馏成 few-step autoregressive student：先做 ODE distillation 初始化，再接 DMD 提升质量。Causal Forcing 认为这里有一个被忽略的理论错误：双向 teacher 的 PF-ODE 只在整段视频层面是 injective，但 AR student 在训练每一帧/每个 chunk 时只能看过去上下文，不能访问未来帧。因此同一个 noisy frame 可能对应多个不同 clean frame，违反 `frame-level injectivity`。

违反这个条件后，MSE 型 ODE distillation 不能恢复 teacher 的真实 flow map，只会收敛到条件期望：
$$
G_\theta^*(x_t^i,x_t^{<i},t)
=
\mathbb{E}[x_0^i \mid x_t^i,x_t^{<i},t]
$$

这会把多个可能的干净帧平均掉，表现为模糊、动态弱、指令遵循差。Causal Forcing 的修法是三阶段：先用 `teacher forcing` 训练一个 AR diffusion model；再把这个 AR model 作为 teacher 采样 causal PF-ODE 轨迹，做 causal ODE distillation；最后沿用 Self Forcing 的 asymmetric DMD。实验显示，在同样训练预算、同样 `17 FPS / 0.69s` 推理延迟下，它比 Self Forcing 在 `Dynamic Degree`、`VisionReward`、`Instruction Following` 上分别提升 `19.3% / 8.7% / 16.7%`。

## 1 Introduction
实时交互视频生成需要自回归模型：模型必须能边生成边展示，并允许用户根据已生成内容继续改条件。问题是普通视频扩散模型通常是 bidirectional full-attention，一次性看完整段视频，不能天然流式输出。

现有做法是把强大的 bidirectional teacher 蒸馏成 few-step AR student。这个 pipeline 有两个 gap：
- `sampling-step gap`：多步扩散采样要压成少步生成；
- `architectural gap`：full attention teacher 要变成只能看过去帧的 causal attention student。

论文认为，Self Forcing 虽然通过训练时 self-rollout 缓解了 train-test gap，但在 ODE 初始化阶段仍没有正确处理 architectural gap。DMD 阶段也修不好这个问题，因为如果初始化时 flow map 已经被学错，后续 DMD 很难把这种结构性错误完全拉回来。

## 2 Background

### Autoregressive Video Diffusion
AR video diffusion 把视频分布写成：
$$
p_\theta(x_0^{1:N})
=
\prod_{i=1}^{N} p_\theta(x_0^i \mid x_0^{<i})
$$

每个条件分布仍由扩散模型建模。常见训练方式有两种：
- `Teacher Forcing (TF)`：训练第 $i$ 帧时，条件是干净历史 $x_0^{<i}$。
- `Diffusion Forcing (DF)`：训练第 $i$ 帧时，条件是带噪历史 $x_t^{<i}$。

Causal Forcing 的结论有点反直觉：在 AR diffusion training 中，`teacher forcing` 比 `diffusion forcing` 更合适。因为推理时条件通常是已经生成的 clean prefix，而 DF 训练时却让模型看 noisy prefix，这会引入新的训练-推理分布错配。

### ODE Distillation
ODE distillation 训练一个 few-step student $G_\theta$，让它从 teacher PF-ODE 的中间 noisy state $x_t$ 回归 clean endpoint $x_0$：
$$
\theta^*
=
\arg\min_\theta
\mathbb{E}_{t,x_t}
\left[
\left\|G_\theta(x_t,t)-x_0\right\|^2
\right]
$$

这个回归目标成立的前提是 paired data 是 injective：同一个 $x_t$ 只能对应一个 $x_0$。

### DMD
DMD 用 teacher score 和 fake score 的差来做分布匹配：
$$
\nabla_\theta
\mathbb{E}_{t}
\left[
\mathrm{KL}(p_{\theta,t}\|p_{\mathrm{data},t})
\right]
=
-
\mathbb{E}
\left[
\left(s_{\mathrm{real}}-s_{\mathrm{fake}}\right)
\frac{\partial \tilde{x}}{\partial \theta}
\right]
$$

Causal Forcing 并不否定 DMD；它认为 DMD 应该接在正确的 causal ODE initialization 后面。

## 3 Method

### 3.1 Self Forcing 的问题：Frame-Level Injectivity
在 bidirectional teacher 里，整段 noisy video $x_t^{1:N}$ 沿 PF-ODE 可以唯一恢复到 clean video $x_0^{1:N}$。这个叫 video-level injectivity。

但 AR student 不是一次处理整段视频，它训练第 $i$ 帧/第 $i$ 个 chunk 时只能用：
$$
G_\theta(x_t^i, x_t^{<i}, t)
$$

因此 ODE paired data 必须满足 frame-level injectivity：
$$
x_t^i = y_t^i
\Rightarrow
\phi^{\mathrm{AR}}(x_t^i,t)
=
\phi^{\mathrm{AR}}(y_t^i,t)
$$

问题在于 bidirectional teacher denoise 第 $i$ 帧时会看未来帧 $x_t^{>i}$。所以即使两个样本的当前 noisy frame 一样，只要未来帧不同，teacher 给出的 clean frame 就可能不同：
$$
x_t^i = y_t^i
\quad \text{but} \quad
x_0^i \neq y_0^i
$$

这就违反 frame-level injectivity。对于 MSE 回归，最优解会变成条件均值：
$$
G_\theta^*(x_t^i,t)
=
\mathbb{E}[x_0^i \mid x_t^i,t]
\nsim
p_{\mathrm{data}}(x_0^i)
$$

直观理解：多个不同干净帧被同一个 noisy frame 监督，模型只能平均它们，于是生成会变糊、动态变弱、时序一致性也差。

### 3.2 Causal Forcing 三阶段

#### Stage 1: Teacher-Forcing AR Diffusion Training
先训练一个真正的 AR diffusion model，训练时条件是 clean prefix：
$$
p_{\mathrm{data}}(x_0^i \mid x_0^{<i})
$$

论文强调：DF 会让当前帧条件在 noisy prefix 上，而推理使用 clean/generated prefix，因此会产生分布错配；TF 更贴近 AR 推理。

#### Stage 2: Causal ODE Distillation
有了 AR diffusion teacher 后，再从它采样 PF-ODE trajectories。对于第 $i$ 帧：
1. 从真实数据取 clean history $x_{\mathrm{gt}}^{<i}$；
2. AR teacher 从 Gaussian noise 开始，条件在 clean history 上生成当前帧的 ODE trajectory；
3. student 回归 noisy intermediate 到 clean endpoint：

$$
\theta^*
=
\arg\min_\theta
\mathbb{E}_{x_{\mathrm{gt}}^{<i},t,i}
\left[
\left\|
G_\theta(x_t^i,x_{\mathrm{gt}}^{<i},t)-x_0^i
\right\|^2
\right]
$$

因为 teacher 本身就是 AR，所以这个 PF-ODE map 天然满足 frame-level injectivity。

#### Stage 3: Asymmetric DMD
最后接和 Self Forcing 类似的 asymmetric DMD，用 causal ODE 初始化后的 AR student 继续做 few-step distribution matching。论文的重点是：DMD 不是问题本身，问题是 DMD 前的初始化必须先把 architectural gap 修好。

### 3.3 Extension to Causal Consistency Models
论文还把同样原则推广到 consistency distillation。传统 asymmetric CD 若仍然用 bidirectional teacher，也会违反 frame-level injectivity。Causal CD 则使用 AR teacher，并在 clean prefix 条件下训练 consistency model：
$$
\theta^*
=
\arg\min_\theta
\mathbb{E}
\left[
w(t)d
\left(
G_\theta(x_t^i,x_{\mathrm{gt}}^{<i},t),
G_{\theta^-}(\hat{x}_{t-\Delta t}^i,x_{\mathrm{gt}}^{<i},t-\Delta t)
\right)
\right]
$$

当前实现只是 vanilla LCM 风格，最终质量不如 DMD，但已经显著优于 asymmetric CD。

## 4 Experiments

### 4.1 Settings
主要设置：
- base model：`Wan2.1-T2V-1.3B`
- 视频：`81` frames，`832 × 480`
- 先用 bidirectional base model 合成约 `3K` 数据 $\mathcal{D}_{\mathrm{Bi}}$
- 用 teacher forcing 训练 AR diffusion model：`2K` steps
- 用 AR teacher 采样约 `3K` causal ODE trajectories $\mathcal{D}_{\mathrm{Causal}}$
- causal ODE distillation：`1K` steps
- asymmetric DMD：在 `VidProM` 上训练 `750` steps
- chunk-wise 实现：每个 chunk `3` latent frames
- 推理：`4-step` sampling，timesteps 为 `1, 0.9375, 0.8333, 0.625`
- batch size：`64`
- optimizer：Adam，learning rate $2\times 10^{-6}$，$\beta_1=0$，$\beta_2=0.999$

评测：
- VBench 的 Total / Quality / Semantic
- 额外构造 `100` 个高动态 prompts，评估 `Dynamic Degree`
- 用 VisionReward 评估视觉质量，并用其 prompt-alignment sub-score 评估 instruction following
- 用户研究：`10` 位参与者、`10` 个 prompts
- H100 单卡报告 FPS 和 latency

### 4.2 Main Results
主表结果：
- `Causal Forcing`: `17.0 FPS`, `0.69s latency`, `Total = 84.04`, `Quality = 84.59`, `Semantic = 81.84`, `Dynamic = 68`, `VisionReward = 6.326`, `Instruction = 56`, `User Rating = 1.64`
- `Self Forcing`: `17.0 FPS`, `0.69s`, `Total = 83.74`, `Quality = 84.48`, `Semantic = 80.77`, `Dynamic = 57`, `VisionReward = 5.820`, `Instruction = 48`, `Rating = 2.87`
- `CausVid`: `17.0 FPS`, `0.69s`, `Total = 81.33`, `Quality = 83.98`, `Semantic = 70.72`, `Dynamic = 62`, `VisionReward = 5.741`, `Instruction = 12`, `Rating = 4.27`
- `Wan2.1-1.3B`: `0.78 FPS`, `103s`, `Total = 83.37`, `Dynamic = 61`, `VisionReward = 5.275`, `Instruction = 42`

论文强调：
- 相比 Self Forcing：`Dynamic Degree +19.3%`，`VisionReward +8.7%`，`Instruction Following +16.7%`
- 相比类似规模 bidirectional Wan2.1：吞吐提升 `2079%`
- 相比已有 AR diffusion best baseline：`Dynamic +47.8%`，`VisionReward +56.0%`，`Instruction +75.0%`

### 4.3 Ablation

#### AR Diffusion Training
- `Diffusion Forcing`: `Total = 81.76`, `Dynamic = 60`, `VisionReward = 1.583`, `Instruction = 30`
- `Teacher Forcing`: `Total = 82.12`, `Dynamic = 50`, `VisionReward = 3.343`, `Instruction = 32`

DF 的 dynamic 更高，但论文认为这是 collapse 病态抬高 motion metric，不代表真正质量好。

#### Score Distillation: Chunk-Wise
- `Self Forcing's ODE + DMD`: `Total = 82.00`, `Dynamic = 24`, `VisionReward = 3.330`, `Instruction = 38`
- `Causal ODE + DMD`: `Total = 84.04`, `Dynamic = 68`, `VisionReward = 6.326`, `Instruction = 56`

这组最关键：同样是 DMD，换成 causal ODE 初始化后，dynamic 提升 `183.3%`，VisionReward 提升 `90.0%`。

#### Score Distillation: Frame-Wise
- `Self Forcing's ODE + DMD`: `Dynamic = 2`, `VisionReward = 1.951`, `Instruction = -4`
- `Causal ODE + DMD`: `Dynamic = 64`, `VisionReward = 6.204`, `Instruction = 42`

frame-wise 下差距更夸张，说明非因果 ODE paired data 对 AR student 的伤害在更细粒度生成时尤其严重。

#### Consistency Distillation
- `Asymmetric CD`: `Total = 79.07`, `Dynamic = 59`, `VisionReward = -7.983`, `Instruction = -42`
- `Causal CD`: `Total = 81.48`, `Dynamic = 51`, `VisionReward = 1.798`, `Instruction = 18`

Causal CD 还不如 DMD，但已经证明同样的 causal teacher 原则适用于 CD。

## 5 关键洞察
这篇论文最有价值的点是把 “AR distillation 为什么糊” 说成了一个非常清楚的数学条件：`frame-level injectivity`。

Self Forcing 的训练思路并不是错在 self-rollout 或 DMD，而是更早的 ODE initialization 阶段把 bidirectional teacher 的整段 flow map 拆给 AR student 学。bidirectional teacher 在 denoise 当前帧时看了未来帧，但 AR student 没有未来帧，于是监督信息本身就不可逆。

这也解释了为什么后续 DMD 很难完全救回来：DMD 可以调分布，但它不是用来修一个错误的 ODE flow map 初始化的。

## 6 和相邻方法的关系

### vs Self Forcing
Self Forcing 解决的是训练时用自产生历史，缓解 exposure bias。Causal Forcing 认为这还不够，ODE 初始化时 teacher 也必须是 causal/AR 的，否则初始 flow map 已经错了。

### vs CausVid
CausVid 和 Self Forcing 都属于 bidirectional teacher 到 AR student 的 asymmetric distillation 路线。Causal Forcing 不是主要改推理，而是修 distillation teacher 的因果性。

### vs Self-Forcing++
Self-Forcing++ 关注长 horizon error accumulation，把短视频 teacher 用作长 rollout 局部修复器。Causal Forcing 关注短视频/实时 AR distillation 的初始化正确性。二者可以互补：先用 Causal Forcing 得到更好的 AR base，再做 Self-Forcing++ 式长 horizon extended DMD。

### vs Rolling / Deep Forcing
Rolling Forcing 和 Deep Forcing 更偏长视频推理单元或 KV cache 记忆机制。Causal Forcing 更底层：它给这些 AR student 一个更正确的蒸馏初始化。

## 7 Limitations
- 需要先训练 AR diffusion teacher，再采样 causal ODE trajectories，pipeline 比直接从 bidirectional teacher 做 ODE distillation 更复杂。
- 主要实验是 `5s / 81 frames` 的实时交互生成，不是直接解决分钟级长视频 drift。
- Causal CD 只是初步实现，仍明显弱于 causal ODE + DMD。
- 论文使用内部合成数据和 VidProM 训练，复现成本仍不低。

## 8 我的评价
Causal Forcing 是 Self Forcing 系列里很重要的“补理论地基”的工作。它不是再加一个 trick，而是指出原 pipeline 的 paired-data 构造本身不满足可学习条件。

我觉得它适合记成一句话：`AR student 的 ODE teacher 必须也是 AR teacher`。如果这个原则成立，那么后续很多 streaming / long-video forcing 方法都应该考虑把 Causal Forcing 作为更干净的 base initialization，而不是继续从 bidirectional ODE paired data 起步。

## 相关链接（双向）
- [[Self-Forcing ✅]]
- [[Self-Forcing++]]
- [[CausVid✅]]
- [[Rolling-Forcing✅]]
- [[Deep-Forcing✅]]
- [[Distribution Matching Distillation]]
