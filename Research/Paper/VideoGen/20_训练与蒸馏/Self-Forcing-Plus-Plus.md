---
created: 2026-01-27
published: 2025-10-02
type: paper
status: 已读
tags:
  - SelfForcing
  - VideoGeneration
  - Autoregressive
  - Distillation
  - LongVideo
  - KVCache
aliases:
  - Self-Forcing++
  - "Self-Forcing++: Towards Minute-Scale High-Quality Video Generation"
summary: Self-Forcing++ 把短视频 teacher 的能力用到长 rollout 上：先让 student 自己生成远超 5 秒的长视频，再从其中随机切出 5 秒窗口，通过回注噪声和 extended DMD 让 teacher 修正这些已经积累误差的片段；同时训练和推理都使用 rolling KV cache，最终在不需要长视频 teacher 或长视频数据集的情况下，把 Self-Forcing 类 AR 视频生成扩展到 100 秒乃至 255 秒。
pdf-url: Attachments/arxiv_2510.02283.pdf
github-url: ""
source-url:
  - https://arxiv.org/abs/2510.02283
  - https://doi.org/10.48550/arXiv.2510.02283
  - https://self-forcing-plus-plus.github.io/
---

# Self-Forcing++: Towards Minute-Scale High-Quality Video Generation

## PDF
- [[Attachments/arxiv_2510.02283.pdf]]

## 一句话摘要
Self-Forcing++ 的核心不是让 teacher 直接生成长视频，而是让学生先暴露在自己长 rollout 后的退化状态里，再用短视频 teacher 对随机局部窗口做分布修正，从而把“5 秒 teacher”变成“长视频错误修复器”。

## Abstract
这篇论文解决的是 `Self-Forcing / CausVid` 这类自回归视频扩散模型的长时外推问题：它们可以把双向 video diffusion 蒸馏成 few-step streaming generator，但 teacher 通常只会生成 `5-10s` 视频，所以学生训练时也只在短 horizon 内被监督。一旦推理滚到 `50s / 100s`，学生会进入训练时没见过的误差累积状态，表现为 motion collapse、过曝、变暗、闪烁或画面停滞。

Self-Forcing++ 的做法很直接：让学生训练时就滚出长视频，再从这条长 self-rollout 中随机切出一个 teacher 能处理的短窗口。为了让这个窗口仍然带有前文一致性，作者不是从纯随机噪声开始，而是对学生已经生成的 clean latent 做 backward noise initialization；然后用 teacher 和 student 的 score difference 做 `Extended DMD`。同时，训练和推理都使用 rolling KV cache，避免 Self-Forcing 中固定 cache 训练、rolling cache 推理的残余错配。结果上，方法在 `50s / 75s / 100s` 长视频上显著提升 `Dynamic Degree` 和 `Visual Stability`，并在扩大训练预算后生成最长 `255s` 视频，接近 Wan2.1-T2V-1.3B 位置编码支持上限。

## 1 Introduction
现有高质量视频扩散模型大多仍是短视频模型。双向 DiT 质量高，但不适合 streaming；自回归化以后可以用 causal attention 和 KV cache 实时生成，却会遇到更硬的长时问题：模型训练时只见短片段，推理时却要不断消费自己生成的历史。

论文把 Self-Forcing 类方法的瓶颈拆成两个错配：
- `temporal mismatch`：训练只到 teacher 的短视频 horizon，例如 `5s`，推理却要生成几十秒甚至几分钟。
- `supervision mismatch`：短视频训练里每个片段都有 teacher 充分纠偏；长 rollout 时学生会进入由自己错误累积出的状态，但训练时很少学过如何从这种状态恢复。

所以 Self-Forcing++ 的目标不是重新训练一个长视频 teacher，也不是收集长视频数据，而是反过来利用短视频 teacher 的局部修复能力：长视频可以看成许多短窗口的组合，只要任意局部窗口都能被拉回合理视频分布，整段 rollout 就更不容易一路滑向退化。

## 2 Related Work
这篇论文主要接在三条线后面：
- `CausVid`：把双向视频扩散模型蒸馏成 few-step 自回归流式生成器，但依赖 overlapping frame recomputation，容易过曝。
- `Self-Forcing`：训练时使用模型自产生上下文，缓解 train-test gap，但训练 horizon 仍受短视频 teacher 限制，长时间滚动会退化。
- `Rolling Forcing / LongLive`：同期也在解决自回归长视频的误差累积和记忆问题，常借助 rolling window、attention sink、KV recache 或未来窗口 DMD。

Self-Forcing++ 的区别是设计更“朴素”：不依赖 attention sink frame，也不重算 overlapping frames，而是把训练分布扩展到学生自己的长 rollout，再用 windowed DMD 修正。

## 3 Method

### 3.1 Background
方法沿用 CausVid / Self-Forcing 的基础 recipe：
1. 用 `Wan2.1-T2V-1.3B` 这样的双向 teacher。
2. 先通过 ODE trajectory imitation 把模型初始化成 autoregressive student。
3. 再用 `Distribution Matching Distillation (DMD)` 做 few-step post-training。

普通 DMD 可以理解为用 teacher score 和 student score 的差异来更新 generator：
$$
\nabla_{\theta}\mathcal{L}_{\mathrm{DMD}}
\propto
-
\mathbb{E}_{t,z}
\left[
\left(
s^{T}(x_t,t)-s^{S}_{\theta}(x_t,t)
\right)
\frac{dG_{\theta}(z)}{d\theta}
\right]
$$

Self-Forcing 已经把训练时的上下文换成学生自己 rollout 的历史，但它的问题是：这个 rollout 仍然只覆盖 teacher 能监督的短 horizon。因此模型并没有真正学会处理 `50s / 100s` 时的错误累积状态。

### 3.2 Extend Training Beyond Teacher's Limit

#### Motivation
作者有一个关键观察：Self-Forcing 在长视频中虽然质量会退化，但经常仍保持某种结构一致性，比如主体还在、场景还没完全散掉，只是开始停滞、变暗或失真。

这说明 AR 机制和 KV cache 并没有完全失效；真正的问题是误差在连续 latent space 里逐步积累，模型缺少“从已退化状态恢复”的训练。

#### Backward Noise Initialization
如果直接从纯随机噪声生成长视频片段，这个片段和前文历史没有一致关系；teacher 对它做短视频监督，也不能教会 student 如何修复“带历史的长 rollout 退化状态”。

Self-Forcing++ 先让学生滚出长度为 $N$ 的 clean latent 序列，其中 $N \gg T$，$T$ 是 teacher 原本可靠的短视频 horizon。然后对学生生成的 clean latent 重新加噪：
$$
x_t = (1-\sigma_t)x_0 + \sigma_t \epsilon
$$

其中：
$$
x_0 = x_{t-1} - \sigma_{t-1}\hat{\epsilon}_{\theta}(x_{t-1}, t-1)
$$

直觉上，这一步是在“沿着学生已经生成的长视频轨迹回到某个噪声时间步”，而不是新开一段无关噪声。这样 teacher / student 的分布差异是在一个保留长程上下文结构的退化窗口上计算的。

#### Extended DMD
teacher 只能可靠处理短窗口，所以 Self-Forcing++ 不要求 teacher 监督整段长视频。它做的是：
1. student rollout 出长度 $N$ 的长视频；
2. 从中均匀采样一个长度 $K$ 的连续窗口，通常 $K$ 等于 teacher 的 `5s` horizon；
3. 对这个窗口做 backward noise initialization；
4. 用 teacher 和 student 的 score difference 做 DMD。

论文里的 extended DMD 可概括为：
$$
\nabla_{\theta}\mathcal{L}_{\mathrm{DMD}}^{\mathrm{extended}}
=
\mathbb{E}_{t}
\mathbb{E}_{i\sim \mathrm{Unif}\{1,\ldots,N-K+1\}}
\left[
\nabla_{\theta}
\operatorname{KL}
\left(
p^{S}_{\theta,t}(z_i)
\Vert
p^{T}_{t}(z_i)
\right)
\right]
$$

这里最重要的是采样位置 $i$。普通 Self-Forcing 只在开头短窗口里学；Self-Forcing++ 会在长 rollout 的任意位置切窗口，所以模型会反复看到“已经积累错误之后的局部状态”，并学习把它拉回 teacher 认为合理的视频分布。

可以把这个过程理解为：短视频 teacher 不会生成长视频，但它会判断和修复任意短片段是否像真实视频。Self-Forcing++ 把这种局部修复能力蒸馏回 student 的长 rollout 过程里。

#### Training with Rolling KV Cache
Self-Forcing++ 还修掉了一个工程层面的错配：Self-Forcing 训练时使用 fixed cache，推理时使用 rolling cache，中间靠 mask first latent frame 等技巧缓解，但长视频里仍会引入 flickering 和 error accumulation。

Self-Forcing++ 在训练和推理中都使用 rolling KV cache：
- 训练时用 rolling cache 生成长 self-rollout；
- extended DMD 也基于这个真实 rolling cache 状态；
- 推理时不需要 overlapping frame recomputation；
- 也不需要额外的 latent frame masking。

这点让方法的训练分布更接近真实长视频推理分布。

### 3.3 Improving Long-Term Smoothness via GRPO
论文还加入了一个可选增强：用 `GRPO` 改善长时平滑性。问题背景是 rolling window / sparse attention 类方法可能丢失长期记忆，导致物体突然出现/消失，或镜头切换过快。

GRPO 里每一步的重要性权重写成：
$$
\rho_{t,i}
=
\frac{
\pi_{\theta}(a_{t,i}\mid s_{t,i})
}{
\pi_{\theta_{\mathrm{old}}}(a_{t,i}\mid s_{t,i})
}
$$

奖励信号使用相邻帧 optical flow magnitude 的相对变化作为 motion continuity proxy。直觉是惩罚突然的大幅光流尖峰，让长视频的运动过渡更连续。

不过这张卡里要记住：GRPO 不是 Self-Forcing++ 的主干。论文补充材料明确说，在 GRPO 之前，模型已经可以生成 `4min 15s` 的一致高质量视频；GRPO 更像是进一步平滑长程 transition 的后处理式训练增强。

### 3.4 New Metrics for Long Videos Evaluation
作者指出传统 `VBench` 在长视频上会误判：
- 过曝视频可能拿到不错的 image / aesthetic score；
- 已经退化的后段帧可能仍被 framewise metric 高估；
- 静止或停滞视频可能获得较高 temporal quality。

因此论文提出 `Visual Stability`，用 `Gemini-2.5-Pro` 按 over-exposure、error accumulation 等长视频退化维度打分，再映射到 `0-100`。作者还做了人工校验：随机抽样 `20` 个 MovieGen 视频，两位作者标注后与 Gemini 分数比较，50 秒视频 top-3 方法 Spearman rank correlation 达到 `100%`，所有 6 个基线达到 `94.2%`。

这个指标本身也值得谨慎看待：它更像 MLLM-as-judge 长视频退化评估，而不是一个完全客观的物理指标。但它确实补上了 VBench 容易奖励“静止但稳定”视频的缺口。

## 4 Experiments

### 4.1 Settings
主要设置：
- base / teacher：`Wan2.1-T2V-1.3B`
- student：`1.3B` autoregressive few-step generator
- 初始化：`16K` ODE training trajectories
- 训练 prompts：和 Self-Forcing 相同的 filtered + LLM-extended `VidProM`
- batch size：`8`
- denoising steps：`1000, 750, 500, 250`
- generator LR：$2\times 10^{-6}$
- critic LR：$4\times 10^{-7}$
- generator / critic update ratio：`5`
- rolling KV cache window：`21` latent frames
- optimizer：AdamW，$\beta_1=0$，$\beta_2=0.999$
- EMA：从 `200` epochs 开始
- throughput：单 H100 上约 `17.0 FPS`，与 CausVid / Self-Forcing 持平

评测分两类：
- `5s`：按 VBench 标准 `946` prompts、`16` dimensions。
- `50s / 75s / 100s`：使用 CausVid 的 `128` 个 MovieGen prompts，报告 VBench Long 和 Visual Stability。

### 4.2 Short-Horizon Results
Self-Forcing++ 虽然重点不是短视频，但在 `5s` 上没有明显牺牲质量：
- `Total = 83.11`
- `Quality = 83.79`
- `Semantic = 80.37`
- `FPS = 17.0`

对比：
- `Self Forcing`: `Total = 83.00`, `Quality = 83.71`, `Semantic = 80.14`, `FPS = 17.0`
- `CausVid`: `Total = 82.46`, `Quality = 83.61`, `Semantic = 77.84`, `FPS = 17.0`
- `Wan2.1`: `Total = 84.67`, 但 `FPS = 0.78`

结论是：它不是用短视频质量换长视频，而是在维持 Self-Forcing 级别短视频性能的基础上扩展 horizon。

### 4.3 Long-Horizon Results
长视频优势非常明显。

`50s`：
- `Text Alignment = 26.37`
- `Temporal Quality = 91.03`
- `Dynamic Degree = 55.36`
- `Visual Stability = 90.94`

关键对比：
- `Self Forcing`: `Dynamic = 34.35`, `Visual Stability = 40.12`
- `CausVid`: `Dynamic = 37.35`, `Visual Stability = 40.47`
- `SkyReels-V2`: `Dynamic = 39.15`, `Visual Stability = 60.41`

`75s`：
- Self-Forcing++: `Text = 26.31`, `Temporal = 91.00`, `Dynamic = 55.62`, `Visual Stability = 86.10`
- Self Forcing: `Text = 23.39`, `Temporal = 87.79`, `Dynamic = 29.15`, `Visual Stability = 35.00`
- CausVid: `Text = 24.76`, `Temporal = 89.14`, `Dynamic = 35.82`, `Visual Stability = 39.84`

`100s`：
- Self-Forcing++: `Text = 26.04`, `Temporal = 90.87`, `Dynamic = 54.12`, `Visual Stability = 84.22`
- Self Forcing: `Text = 22.00`, `Temporal = 87.39`, `Dynamic = 26.41`, `Visual Stability = 32.03`
- CausVid: `Text = 24.41`, `Temporal = 89.06`, `Dynamic = 34.60`, `Visual Stability = 39.21`

论文特别强调，`100s` 时 Self-Forcing++ 的 `Dynamic Degree = 54.12`，相比 CausVid 提升约 `56.4%`，相比 Self-Forcing 提升约 `104.9%`。这说明它主要解决的不是单帧清晰度，而是长时间滚动后“还能不能继续动、还能不能保持视觉稳定”。

### 4.4 Failure Modes of Baselines
论文对几个 baseline 的退化描述很有用：
- `CausVid`：常见过曝，并且随着时间推进更加严重，最后 motion collapse。
- `Self-Forcing`：误差积累后整体变暗、停滞，动态度明显下降。
- `MAGI-1`：早期可避免过曝，但长时间后会结构崩坏或过曝。
- `SkyReels-V2`：结构相对保留，但中到重度过曝，长时动态和稳定性仍不够。
- `NOVA`：长时间下 dynamic degree 和 visual stability 都偏低。

这也解释了为什么只看 framewise quality 会有问题：一些 baseline 的后段已经僵住或退化，但单帧分数并不一定足够低。

### 4.5 Ablation
作者测试了一个朴素修法：缩短训练 attention window，让模型在 5 秒短片内也多经历几次 window sliding。结果有帮助但不够：
- `Self-Forcing`: `Visual Stability = 40.12`
- `Attn-15`: `44.69`
- `Attn-12`: `42.19`
- `Attn-9`: `52.50`
- `Ours`: `90.94`

这说明单纯模拟 rolling window 状态不够。真正关键的是让 student 在远超 teacher horizon 的自生成长序列中积累错误，再对这些错误状态做 teacher 修复。

论文还测试了给 KV cache 注入高斯噪声来模拟误差累积，结论是只能略微改善，不能防止长 horizon 退化。

### 4.6 Training Budget Scaling
这部分是论文很重要的 scaling 观察：
- `1x` budget：能生成连贯 `5s`，但往长了滚会闪烁和误差积累，类似 Self-Forcing。
- `4x` budget：语义一致性开始延长，例如能保持同一个 elephant subject。
- `8x` budget：背景细节和语义准确性更好，但 motion dynamics 仍有限。
- `20x` budget：能在 `50s+` 维持高保真和稳定。
- `25x` budget：可生成 `255s` 视频，质量损失很小。

`255s` 这个数字来自 Wan2.1-T2V-1.3B 的 latent position embedding 上限：最大支持 `1024` latent frames，论文每个 trunk size 为 `3`，所以实际能到 `1023` latent frames，即 `99.9%` 的位置编码跨度。

## 5 关键洞察
我觉得这篇最值得记住的不是 “Self-Forcing++ 可以生成 4 分钟视频”，而是它把长视频训练问题重新表述成了一个局部修复问题：

> 短视频 teacher 不需要会生成长视频；只要它能判断任意短窗口是否像真实视频，就可以被用来修复 student 长 rollout 中任意位置的局部退化。

这个视角很强，因为它绕开了长视频 teacher 和长视频数据的稀缺性。训练时真正新增的是“学生自己滚到长程退化状态”的数据分布，而监督仍然来自短窗口 teacher。

另一个关键点是：Self-Forcing++ 的 `rolling KV cache` 不是单纯推理优化，而是训练分布的一部分。只有训练时也用同样的 rolling cache，extended DMD 才是在真实 inference state 上纠偏。

## 6 和相邻方法的关系

### vs Self-Forcing
Self-Forcing 解决的是 exposure bias：训练时就用模型自产生历史，而不是 ground-truth history。

Self-Forcing++ 解决的是 horizon extrapolation：训练时不仅用自产生历史，还要让模型滚到远超 teacher horizon 的长度，并学习从长程误差累积中恢复。

一句话：
- `Self-Forcing`：让训练上下文像推理。
- `Self-Forcing++`：让训练时间长度也像长视频推理。

### vs CausVid
CausVid 需要 overlapping frame recomputation 来维持一致性，且容易过曝。Self-Forcing++ 不重算重叠帧，而是在长 self-rollout 上做 windowed DMD，并保持 `17 FPS` 的流式速度。

### vs LongLive
LongLive 也把 DMD 用到 teacher horizon 之外，并使用 KV recache、clean context 和 attention sink 来处理 prompt switching 与长期一致性。

Self-Forcing++ 和 LongLive 最接近，但它更强调一个简化设计：不依赖 attention sink frame，而是通过 backward noise initialization、extended DMD 和 rolling KV cache 的组合让 student 学会自修复。

### vs Rolling Forcing
Rolling Forcing 更像是在推理单元上做升级：用 rolling-window joint denoising、attention sink 和不同噪声层级，让多个帧在窗口内联合去噪。

Self-Forcing++ 更像是在训练目标上升级：推理仍保持简单 AR rolling cache，但训练时把 DMD 扩展到长 self-rollout 的任意窗口。

## 7 Limitations
论文承认几个限制：
- 训练速度比 teacher-forcing 慢，因为需要 self-rollout。
- 仍受 Wan2.1-T2V-1.3B 基座能力限制。
- 长期记忆仍不完美，长时间被遮挡的内容可能发生 divergence。
- 超长视频仍需要更好的 latent fidelity 控制、KV cache 归一化或长期记忆机制。
- `Visual Stability` 依赖 Gemini-2.5-Pro 评估，虽然做了人工相关性验证，但仍是 MLLM judge，不是完全可复现的传统指标。

## 8 我的评价
Self-Forcing++ 是一篇很“工程直觉正确”的论文。它没有发明复杂的新架构，而是把 Self-Forcing 的核心原则继续推进了一步：既然推理会长时间消费自己的错误，那训练时就必须真的进入这种错误状态。

它的强点在于：
- 不需要长视频 teacher；
- 不需要真实长视频数据集；
- 不增加推理重算；
- 保持 Self-Forcing 级别实时吞吐；
- 结果提升主要体现在长时动态和稳定性，而不是只刷短视频分数。

它的潜在问题也很清楚：长时一致性被转化成“局部窗口持续修复”，但这不等于真正拥有长期记忆。对于多事件叙事、被遮挡物体回归、复杂因果场景，单靠短窗口 teacher 的局部分布约束可能仍然不够。后续更可能和 `LongLive / Deep Forcing / Memory Forcing / KV cache compression` 这类长期记忆机制结合。

## 相关链接（双向）
- [[Self-Forcing ✅]]
- [[CausVid✅]]
- [[Rolling-Forcing✅]]
- [[LONGLIVE]]
- [[Deep-Forcing✅]]
- [[Reward-Forcing]]
- [[Distribution Matching Distillation]]
- [[Rolling KV Cache]]
