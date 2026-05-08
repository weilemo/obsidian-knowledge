---
created: 2026-01-27
published: 2025-12-04
type: paper
status: 已读
tags:
  - RewardForcing
  - VideoGeneration
  - Streaming
  - Distillation
  - RewardModel
  - AttentionSink
aliases:
  - Reward Forcing
  - Reward Forcing: Efficient Streaming Video Generation with Rewarded Distribution Matching Distillation
summary: Reward Forcing 同时从记忆机制和蒸馏目标两侧修补流式视频生成的“又稳又僵”问题：EMA-Sink 用指数滑动方式压缩长时历史，Re-DMD 用奖励加权的分布匹配把学生分布推向更有运动感的高奖励区域，在单卡 H100 上实现 23.1 FPS 的实时生成。
pdf-url: Attachments/arxiv_2512.04678.pdf
github-url: ""
source-url:
  - https://arxiv.org/abs/2512.04678
  - https://doi.org/10.48550/arXiv.2512.04678
  - https://reward-forcing.github.io/
---

# Reward Forcing: Efficient Streaming Video Generation with Rewarded Distribution Matching Distillation

## PDF
- [[Attachments/arxiv_2512.04678.pdf]]

## 一句话摘要
Reward Forcing 的关键不是单纯“让流式生成更长”，而是同时解决两个互相耦合的问题：一边用 `EMA-Sink` 避免模型死盯第一帧，一边用 `Re-DMD` 让蒸馏目标显式偏向更有运动感的样本，于是长视频既更稳，也不容易越生成越僵。

## Abstract
这篇论文抓住了 streaming video generation 里一个很典型的退化模式：为了缓解 sliding window attention 的误差累积，很多方法会长期保留起始帧 token 作为 attention sink，但这样虽然稳定，却会让后续视频越来越依赖第一帧，最终表现成动作变弱、画面反复“闪回”到初始状态。作者提出 `Reward Forcing` 来同时修这两个问题。第一部分 `EMA-Sink` 不再把 sink token 固定死在初帧，而是在窗口滑动时用被驱逐历史 token 的指数滑动平均去持续更新 sink，使它既保留长程上下文，又不断吸收近期动态。第二部分 `Rewarded Distribution Matching Distillation (Re-DMD)` 则不再像普通 DMD 一样对所有样本一视同仁，而是利用视觉语言模型给视频动态性打分，把蒸馏梯度加权到高奖励区域，显式提升运动质量。最终方法在短视频和长视频基准上都取得了更好的结果，并在单张 H100 上达到 `23.1 FPS` 的实时生成速度。

## 1 Introduction
论文讨论的是高质量视频扩散模型走向实时交互应用时的一个核心矛盾：
- 双向视频扩散模型质量高，但全序列去噪太慢，不适合 streaming 场景。
- 自回归 few-step 蒸馏模型可以用 sliding window attention 和 KV cache 实现实时生成，但随着 rollout 变长，误差会不断累积。
- 为了减小 drift，已有方法会保留初始帧作为 sink token；但这种策略又会造成另一类问题：模型越来越偏向第一帧，导致动作衰减、过度重复和视觉 flashback。

作者认为，现有方法的问题不只是“历史记忆不够”，而是“历史被保留得过于静态”；同时，标准 DMD 又缺少对动态质量的偏好，无法把这些“看起来质量不错但运动已变弱”的坏样本有效推开。

因此论文的出发点很明确：
- 在注意力层面，如何保住长时上下文，又不把模型锁死在第一帧？
- 在蒸馏目标层面，如何让学生模型更偏向运动更强的输出分布？

## 2 Related Work
这篇论文位于三条路线的交叉点：
- `Autoregressive / Streaming Video Diffusion`：`CausVid`、`Self Forcing`、`LongLive`、`Rolling Forcing` 等方法都在把双向视频扩散改造成实时流式生成。
- `Attention Sink / 长上下文外推`：LLM 里的 attention sink 机制被迁移到视频生成，用来缓解 sliding window 丢失远程上下文的问题。
- `Reward / Preference / RL for Video Generation`：奖励模型、偏好优化和 RL 开始被用于图像或视频生成质量对齐，但大多用于后训练或单独的 reward finetuning。

Reward Forcing 的位置可以概括成一句话：它不是单纯改推理缓存，也不是单纯做 reward alignment，而是把“长时记忆压缩”和“奖励感知蒸馏”直接合到 streaming few-step distillation 里。

## 3 Method

### 3.1 Preliminaries
在自回归视频扩散里，长度为 $N$ 的视频序列满足：
$$
p(x_{1:N})=\prod_{i=1}^{N} p(x_i \mid x_{<i})
$$

`Self Forcing` 的核心是训练时就按自回归 rollout 的方式生成后续 chunk，从而缩小 train-test gap。对于当前 chunk $x_i$，few-step 生成器 $G_\theta$ 会在噪声时间步集合 $\{t_0,t_1,\ldots,t_T\}$ 上逐步去噪，条件是前面已经生成的 clean chunk。

论文还回顾了 `Distribution Matching Distillation (DMD)`：它通过最小化真实分布与生成分布的反向 KL，把多步 diffusion teacher 蒸馏成少步 student。它的问题在于，DMD 只要求“分布接近”，并不会偏好“更有动态”的样本。

### 3.2 EMA-Sink

#### 3.2.1 问题
传统 sliding window attention 在窗口前移时，会直接丢弃最老的历史帧；而 attention sink 方案虽然保留了早期 token，却把“长期记忆”固定在初始帧附近。这样做确实能稳定长程一致性，但副作用是模型越来越过度关注第一帧，后续内容更难自然演化。

作者的判断是：真正有用的长期状态，不应该只是“最开始那几帧”，而应该是整个历史在一个压缩表示中的持续累计。

#### 3.2.2 核心机制
当第 $i-w$ 帧离开窗口时，EMA-Sink 不会直接把它丢掉，而是把它对应的 key/value 融合到压缩全局状态中：
$$
S^i_K = \alpha S^{i-1}_K + (1-\alpha) K^{i-w}
$$
$$
S^i_V = \alpha S^{i-1}_V + (1-\alpha) V^{i-w}
$$

其中：
- $S^i_K, S^i_V$ 是第 $i$ 步时压缩后的全局 sink 状态；
- $\alpha \in (0,1)$ 是 EMA 系数；
- $K^{i-w}, V^{i-w}$ 是刚被滑动窗口驱逐出去的历史 token。

在注意力计算时，模型不只看当前局部窗口，还把压缩后的全局 sink 拼到前面：
$$
K^i_{\mathrm{global}} = [S^i_K; K^{i-w+1:i}]
$$
$$
V^i_{\mathrm{global}} = [S^i_V; V^{i-w+1:i}]
$$

这样一来，每个 query 同时能访问：
- 局部的细粒度近期上下文；
- 由 EMA 累积而来的粗粒度全局历史。

相比固定初始 sink，这种做法的好处是：
- 不增加额外 attention window；
- 不再把长期锚点僵硬绑定在第一帧；
- 让近期动态可以持续渗透进长期记忆，从而减少 frame copying 和 motion stagnation。

### 3.3 Rewarded Distribution Matching Distillation

#### 3.3.1 为什么普通 DMD 不够
普通 DMD 的目标可以写成：
$$
J_{\mathrm{DMD}}
=
\mathbb{E}_{p(c)\,p_{\mathrm{fake}}(x_0 \mid c)}
\left[
\log \frac{p_{\mathrm{fake}}(x_0 \mid c)}{p_{\mathrm{real}}(x_0 \mid c)}
\right]
$$

问题在于，这个目标把所有样本区域等权对待。对于视频生成来说，一些输出虽然动态变弱，但静态画质依然不错，因此它们在分布上仍可能离 teacher 很近，不容易被普通 DMD 明显惩罚。

#### 3.3.2 Re-DMD 的想法
作者借用了 reward-weighted regression / RL-as-inference 的思路：如果某个样本的 reward 更高，就应该让学生分布更偏向它。于是他们把最优目标分布写成：
$$
p(x_0 \mid c)
=
\frac{1}{Z(c)}
q(x_0 \mid c)
\exp\left(\frac{r(x_0,c)}{\beta}\right)
$$

其中：
- $r(x_0,c)$ 是 reward function；
- $\beta$ 控制奖励权重；
- $q$ 是当前 fake distribution；
- $Z(c)$ 是归一化常数。

进一步，Re-DMD 的目标被写成：
$$
J_{\mathrm{Re\text{-}DMD}}
=
\mathbb{E}_{p(c)\,p'_{\mathrm{fake}}(x_0 \mid c)}
\left[
\frac{\exp(r(x_0,c)/\beta)}{Z(c)}
\log \frac{p_{\mathrm{fake}}(x_0 \mid c)}{p_{\mathrm{real}}(x_0 \mid c)}
\right]
$$

直观理解就是：
- 样本 reward 越高，它对分布匹配梯度的权重越大；
- 学生模型会更积极地向“更有运动感、更高动态”的区域靠拢；
- 同时又没有完全脱离 distribution matching 的 fidelity 约束。

论文最终使用的梯度形式可以理解为“给 DMD 的 teacher-fake score difference 乘上一个奖励权重”：
$$
\nabla_\theta J_{\mathrm{Re\text{-}DMD}}
\propto
-
\mathbb{E}_t
\left[
\exp(r_c(x_t)/\beta)\,
\bigl(
s_{\mathrm{real}} - s_{\mathrm{fake}}
\bigr)
\frac{dG_\theta}{d\theta}
\right]
$$

这里最关键的工程点是：
- reward 只作为静态权重使用；
- 不需要对 reward model 反向传播；
- 训练更稳，也避免了典型 RL 里高方差 reward gradient 的问题。

#### 3.3.3 Reward 函数
论文使用 `VideoAlign` 的 motion quality 作为 reward function，并设置 $\beta=\frac{1}{2}$。这意味着它优化的重点非常明确：不是泛化地“让视频更讨喜”，而是专门让蒸馏过程更偏向运动质量。

### 3.4 效率分析
EMA-Sink 的优点不仅是质量，还在于它几乎不增加推理开销：
- token eviction 仍是 $O(1)$；
- attention 复杂度依旧只和窗口大小 $w$ 有关，而不和总序列长度增长；
- 历史被压缩成固定大小的 sink，因此内存开销相对视频长度近似常数。

Re-DMD 也没有把训练变成完整 RL：
- reward 不参与反向传播；
- 只是在分布匹配梯度上做加权；
- 因而保留了蒸馏训练的稳定性和效率。

## 4 Experiments

### 4.1 Experimental Settings
- 基座模型：`Wan2.1-T2V-1.3B`
- 目标分辨率：`832 × 480`
- 初始化：先基于 `CausVid` 路线训练 `16k` 个 ODE solution pairs
- 训练数据：LLM 改写和过滤后的 `VidProM`
- reward model：`VideoAlign` 的 motion quality
- 注意力窗口：`9`
- chunk 粒度：每个 chunk `3` 个 latent frames
- few-step 时间步：`[1000, 750, 500, 250]`
- 训练资源：`64 × H200`，总 batch size `64`，约 `3` 小时
- 推理速度：单张 `H100` 上达到 `23.1 FPS`

补充实现细节里，论文还使用了 time shift：
$$
t'(k,t)=\frac{(kt/1000)}{1+(k-1)(t/1000)}\cdot 1000
$$
其中 shift factor $k=5$。

### 4.2 Short Video Results
在 5 秒视频的 VBench 评测中，Reward Forcing 达到：
- `FPS = 23.1`
- `Total = 84.13`
- `Quality = 84.84`
- `Semantic = 81.32`

对比几个关键基线：
- `Self Forcing`：`17.0 FPS`，`Total = 83.80`
- `LongLive`：`20.7 FPS`，`Total = 83.22`
- `CausVid`：`17.0 FPS`，`Total = 82.88`
- `SkyReels-V2`：`0.49 FPS`，`Total = 82.67`

这组结果说明它的短视频优势不只是更快，而是同时做到了：
- overall score 第一；
- 同尺度方法里最快的推理速度；
- 在更小 attention window 下仍保持更高质量。

论文特别强调，相比 `SkyReels-V2` 它有约 `47.14\times` 的速度优势；相比 `Self Forcing` 也有约 `1.36\times` 的加速。

### 4.3 Long Video Results
在 60 秒长视频评测中，Reward Forcing 的 `VBench Long` 结果为：
- `Total = 81.41`
- `Subject = 97.26`
- `Background = 96.05`
- `Smoothness = 98.88`
- `Dynamic = 66.95`
- `Aesthetic = 57.47`
- `Imaging Quality = 70.06`
- `Drift = 2.505`

与主要基线对比：
- `LongLive`：`Total = 79.53`，`Dynamic = 35.54`，`Drift = 2.531`
- `Self Forcing`：`Total = 79.34`，`Dynamic = 54.94`，`Drift = 5.075`
- `CausVid`：`Total = 77.78`，`Dynamic = 27.55`，`Drift = 2.906`

这组数字很值得记：
- 它在 `Dynamic` 上相对 `LongLive` 提升非常大，从 `35.54` 到 `66.95`；
- 同时 `Drift` 仍维持在极低水平，没有像很多“更动态”的方法那样牺牲稳定性；
- 这说明它真正解决的是“稳定和动态相互打架”的问题，而不是单点堆指标。

论文还用 `Qwen3-VL-235B-A22B-Instruct` 对 55 到 60 秒视频做打分，分别从 visual quality、motion dynamics、text alignment 三个维度评价，Reward Forcing 也取得最好结果：
- `Visual = 4.82`
- `Dynamic = 4.18`
- `Text = 4.04`

### 4.4 Ablation
这篇论文的消融非常清楚地说明了两个组件各自负责什么。

#### 4.4.1 去掉 Re-DMD
去掉 `Re-DMD` 后：
- `Dynamic` 从 `64.06` 降到 `43.75`
- `Quality` 反而略高，从 `70.57` 到 `71.42`
- `Drift` 更低，从 `2.51` 到 `1.77`

这说明 `Re-DMD` 的核心贡献就是把运动幅度显著拉起来，但它也会轻微增加整体变化和漂移风险。换句话说，Reward Forcing 并不是“免费变强”，而是在 reward 引导下主动把模型推向更动态的区域。

#### 4.4.2 去掉 EMA-Sink
去掉 `EMA-Sink` 后：
- `Dynamic = 35.15`
- `Smooth = 98.64`
- `Quality = 70.50`
- `Drift = 2.65`

如果连 sink 都去掉：
- `Dynamic = 51.56`
- `Quality = 69.92`
- `Drift = 5.08`

这里能看出三个层次：
- 静态 sink 能保稳定，但动态性仍不够；
- 完全没 sink 会严重 drift；
- `EMA-Sink` 才真正兼顾长期稳定和持续演化。

#### 4.4.3 $\alpha$ 与 $\beta$
EMA 系数和 reward 权重也体现了一个很直观的 trade-off。

关于 $\alpha$：
- $\alpha=0.99$ 时，`Dynamic = 63.15`，`Drift = 3.23`
- $\alpha=0.9$ 时，`Dynamic = 64.37`，`Drift = 3.78`
- 默认设置最平衡的是接近 `0.999`

关于 $\beta$：
- $\beta$ 太大，例如 `1`，奖励太弱，`Dynamic = 54.68`
- $\beta$ 太小，例如 $\frac{1}{5}$，奖励太强，`Dynamic = 94.53`，但背景一致性和画质明显崩掉
- 最终选择 $\beta=\frac{1}{2}$，是在动态与保真之间的折中

这一节最重要的启发是：Reward Forcing 的提升不是来自某个“魔法超参”，而是因为作者确实把长期记忆和奖励偏好这两个方向拆开建模了。

### 4.5 Analysis
论文还给了两点很有价值的分析：

第一，`Re-DMD` 的动态分数会随训练稳定上升，而且总训练量不到 `200 GPU hours`。这说明奖励加权蒸馏是有效且相对高效的，并不需要昂贵的长期 RL。

第二，attention window 越大，FPS 越低，因此他们能做到 `23.1 FPS` 的一个重要原因就是：`EMA-Sink` 允许模型用更小的局部窗口，同时不丢失全局历史。

此外，论文展示了一个交互式视频生成例子：在生成过程中切换 prompt，只需清空旧 cross-attention cache 并重算新 prompt 的 cross-attention，EMA-Sink 能帮助平滑衔接新旧语义。

## 5 Conclusion
Reward Forcing 最值得记住的不是某个单独模块，而是它把 streaming video generation 的退化问题拆成了两个层面来治：
- `EMA-Sink` 解决的是“长期记忆该如何保留”，避免模型一直盯着初始帧；
- `Re-DMD` 解决的是“蒸馏目标该偏向什么样的样本”，让学生模型更愿意生成真正有动态的内容。

因此它取得的效果不是简单的“更快”或者“更稳”，而是更难得的组合：在实时速度下同时维持长时一致性与运动演化。

## 我的理解
我觉得这篇论文最强的 insight 有两个。

第一，它指出 attention sink 在视频里会带来一种很隐蔽的 failure mode：模型并不是彻底崩，而是会变得越来越像“高质量动态壁纸”而不是持续演化的视频。这个判断很准确，也解释了为什么很多 baseline 在画质看着还不错时，动态指标已经掉得很厉害。

第二，它把 reward model 用在了一个很克制的位置。它没有把整个训练改成高成本 RL，而只是把 reward 变成 distribution matching 的权重，这让方法既保留了蒸馏的稳定性，又获得了“偏向动态”的优化方向。这个设计很像在 DMD 里注入一个 preference prior，而不是另起一套训练范式。

如果把它放回整个流式视频生成脉络里看，这篇论文可以理解成：
- 对 `LongLive` 一类静态 sink 路线的修正；
- 对 `DMD / Self Forcing` 一类纯分布匹配蒸馏路线的补强；
- 一种把记忆机制和 reward alignment 同时引入 streaming generation 的中间范式。

## 相关链接（双向）
- [[DMD✅]]
- [[DMD2]]
- [[Self-Forcing ✅]]
- [[LONGLIVE]]
- [[Deep-Forcing✅]]
- [[Relax-Forcing]]
- [[流式视频生成]]
