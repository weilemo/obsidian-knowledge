---
created: 2026-01-27
published: 2025-12-04
type: paper
status: 已读
tags:
  - DeepForcing
  - VideoGeneration
  - Streaming
  - AttentionSink
  - KVCache
  - TrainingFree
aliases:
  - Deep Forcing
  - Deep Forcing: Training-Free Long Video Generation with Deep Sink and Participative Compression
summary: 训练自由地改造 Self Forcing 的 KV cache，用 Deep Sink 与 Participative Compression 抑制长视频误差累积，实现 5s 训练模型向 60s+ 视频外推
pdf-url: Attachments/arxiv_2512.05081.pdf
github-url: https://github.com/cvlab-kaist/DeepForcing
source-url:
  - https://arxiv.org/abs/2512.05081
  - https://cvlab-kaist.github.io/DeepForcing/
---

# Deep Forcing: Training-Free Long Video Generation with Deep Sink and Participative Compression

## PDF
- [[Attachments/arxiv_2512.05081.pdf]]

## 一句话摘要
Deep Forcing 不再通过再训练去修补长视频退化，而是直接在推理时重构 `Self Forcing` 的 KV cache 组织方式：一半窗口做 Deep Sink 维持长期锚点，另一半通过 Participative Compression 保留真正仍在被近期查询使用的 token。

## Abstract
这篇论文的核心判断是：长视频退化并不一定只能靠继续蒸馏或长视频训练来解决，问题很大一部分出在推理阶段的 KV cache 管理。作者先观察到，把 LLM 里的浅层 attention sink 直接照搬到视频扩散，会出现运动停滞、闪烁和画质退化；随后提出两个完全 training-free 的推理机制。`Deep Sink` 保留更深的历史锚点，并通过时间维 RoPE 重对齐减少时间错位；`Participative Compression` 则按“最近查询是否还在使用这些历史 token”来做选择性压缩。最终它在不微调的前提下，把 5 秒训练模型外推到 60 秒以上，并在动态性、整体一致性和视觉稳定性上与训练式方法竞争。

## 1 Introduction
论文讨论的是实时自回归视频扩散里的一个基本矛盾：
- `Self Forcing` 一类方法已经能把双向视频扩散改造成流式生成，但模型本身通常只在短视频上训练，长时间滚动时会累积误差。
- 这种误差会表现为颜色越来越飘、纹理模糊、主体细节丢失，以及动作越来越慢甚至停滞。
- 训练式方法如 `Rolling Forcing`、`LONGLIVE` 会通过蒸馏或长时训练缓解这个问题，但代价是额外训练成本与较强的方法绑定。

作者的切入点很明确：先不训模型，先看当前 `Self Forcing` 的注意力到底在怎么用历史。结果发现，视频扩散里的“sink”并不是只盯着最开始几帧，而是会持续关注更深、更中段的上下文。因此，视频里的有效 sink 机制应该是“深锚点 + 动态压缩”，而不是浅层保留几个起始 token。

## 2 Related Work
论文把自己放在三条线的交叉处：
- `Autoregressive Video Diffusion`：`CausVid`、`Self Forcing`、`Rolling Forcing`、`LONGLIVE` 都在探索如何把视频扩散变成实时流式生成。
- `Attention Sink`：LLM 中的 `StreamingLLM` 说明保留一小部分初始 token 能稳定长上下文推理，但视频里直接照搬并不成立。
- `KV Cache Compression`：`H2O`、`SnapKV` 一类工作说明，缓存里不是所有 token 都同等重要，关键在于如何按当前查询的需要保留真正有用的历史。

Deep Forcing 的位置可以概括成一句话：把 LLM 中的 sink 与重要性压缩思想迁到视频扩散里，但重新适配了视频的时间结构与 3D RoPE。

## 3 Preliminaries

### 3.1 Autoregressive Video Diffusion
自回归视频生成仍满足链式分解：
$$
p(x^{1:N})=\prod_{i=1}^{N}p(x^i\mid x^{<i})
$$
其中每个条件项不是离散 token 预测，而是一个 few-step diffusion 过程。生成第 $i$ 帧时，模型会读取历史帧对应的 KV cache，再对当前帧执行若干步去噪。

### 3.2 Self Forcing 的缓存机制
Deep Forcing 是直接构建在 `Self Forcing` 上的，所以论文先复述了它的两个关键点：
- 它用 rolling KV cache 做流式生成，缓存满了就按 FIFO 丢掉最早的历史。
- 它的训练长度主要来自短视频片段，因此当推理长度远超训练域时，FIFO 会把真正重要的远程锚点也一起丢掉。

论文后续所有改动，本质上都在回答一个问题：缓存满了以后，到底哪些历史该永久保留，哪些该压缩掉。

## 4 Method

### 4.1 Overview
Deep Forcing 由两个组件组成：
- `Deep Sink`：把滑动窗口中大约一半的历史作为长期锚点保留下来，并对这些 sink token 的时间位置做 RoPE 重对齐。
- `Participative Compression`：对剩余历史不再简单 FIFO，而是按最近查询对它们的注意力强度做 Top-$C$ 选择。

整体目标不是压缩得越狠越好，而是在固定缓存预算下，把“长期全局锚点”“被近期查询反复调用的重要中间历史”“最新局部上下文”三者同时保住。

### 4.2 Deep Sink

#### 4.2.1 为什么需要更深的 sink
作者先分析了 `Self Forcing` 的注意力分布，发现新生成帧并不只是强烈关注最前面的少数帧，而是会对整个前半段上下文维持明显注意力。也就是说，视频里的长期一致性依赖的不只是“最开始几帧”，还依赖不少中段上下文。

这直接推翻了“只保留极少初始 sink token 就够了”的直觉。论文随后的消融也支持这一点：当 sink 深度增加时，50 秒视频的 `Overall Consistency` 提升，而 `Aesthetic Drift` 下降，说明更深的锚点确实在帮助维持时序和画质。

#### 4.2.2 Sink 与 Tail 的划分
在实现上，当前窗口里的 key/value 会被分成 sink 与 tail 两部分：
$$
K=[K_{\text{sink}}\;\Vert\;K_{\text{tail}}],
\qquad
V=[V_{\text{sink}}\;\Vert\;V_{\text{tail}}]
$$
其中 `sink` 是永久保留的深历史，`tail` 是后续仍可滚动和压缩的部分。

#### 4.2.3 Temporal RoPE Adjustment
视频模型常用 3D RoPE 分别编码时间、高度和宽度。但如果让很早之前的 sink 帧直接去和当前帧做注意力，而时间索引完全不做处理，就会出现巨大的时间错位，进而导致闪烁、画质恶化甚至“回滚式再生成”。

作者只调整时间维 RoPE，不动空间维。它的核心形式可以写成：
$$
k_{\text{sink}}^{\text{temp}}
\leftarrow
k_{\text{sink}}^{\text{temp}}\odot e^{i\omega\Delta_{\text{sink}}}
$$
这里 $\Delta_{\text{sink}}$ 表示 sink 与当前 tail 之间的时间偏移，$\omega$ 是时间维的 RoPE 频率。直观上，这一步是在把老的 sink token 重新“搬到”更接近当前时间线的位置，使模型看到的是连续时间，而不是时间上断裂的拼接片段。

### 4.3 Participative Compression

#### 4.3.1 为什么 Deep Sink 还不够
只保留深 sink 可以缓解早期锚点丢失，但对分钟级生成仍然不够。原因是：当生成长度超出训练分布十几倍时，缓存里会积累大量已经退化、重复、或与当前生成几乎无关的旧 token。它们继续留在 cache 中，只会稀释注意力并放大误差累积。

因此论文不采用“窗口满了就丢最早帧”的策略，而是改成“哪些 token 仍然被近期查询真正使用，就留下来”。

#### 4.3.2 Sink / Candidate / Recent 三段式缓存
Participative Compression 把缓存分成三段：
- `Sink`：前半段深锚点，始终保留。
- `Recent`：最近若干帧，始终保留，用于保证局部运动连续性。
- `Candidate`：介于两者之间的中间历史，真正接受压缩。

压缩只在两个条件下触发：
- 滑动窗口已经满了；
- 只在第一个 diffusion step 做，避免每步都重复承担高开销。

#### 4.3.3 Top-$C$ 重要性选择
作者用最近查询对候选 key 的注意力总量作为重要性分数。若最近查询为 $\{q_r\}_{r=1}^{R}$，候选 key 为 $\{k_j\}$，则第 $j$ 个候选 token 的分数为：
$$
\phi_j=\sum_{r=1}^{R} q_r^\top k_j
$$
分数越高，说明这个历史 token 仍在被当前生成显著调用。随后保留得分最高的 Top-$C$ 候选 token，并按时间顺序重新拼接缓存：
$$
K_{\text{final}}
=
[K_{\text{sink}}\;\Vert\;K_{\text{top-}C}\;\Vert\;K_{\text{recent}}]
$$
对应的 value 也做同样处理。

这个名字叫 `Participative` 很贴切，因为它保留的是“仍在参与当前生成”的历史，而不是“曾经出现过的最早历史”。

#### 4.3.4 Temporal RoPE Unification
Top-$C$ 选出的中间 token 也会做同样的时间维 RoPE 重对齐。否则虽然 token 被保住了，但它们会在时间轴上形成新的断裂带。论文把这一步看作让 `Sink`、`Top-C`、`Recent` 三段缓存重新接成一条连续时间线。

#### 4.3.5 效率
作者强调这个压缩并不显著拖慢推理，因为它不是每一步都做，而是在窗口满且仅首个 diffusion step 时稀疏触发。所以整套方法基本维持了 `Self Forcing` 的实时吞吐。

## 5 Experiments

### 5.1 Experimental Settings
- 基座模型：chunk-wise `Self Forcing`
- 评测数据：`VBench-Long`，使用 128 个 `MovieGen` prompts
- 对比方法：`CausVid`、`Self Forcing`、`Rolling Forcing`、`LONGLIVE`
- 额外评测：24 人用户偏好实验，以及 `Gemini 2.5-Pro` 的视觉稳定性打分

论文的实验目标很集中：验证一个完全 training-free 的缓存管理方法，能不能在长视频上追平甚至超过 training-based 方法。

### 5.2 Main Results
最重要的结果有三层：

第一，长度外推非常激进。论文明确声称可实现超过 $12\times$ 的时长外推，也就是从 5 秒训练域扩展到 60 秒以上生成。

第二，它在 `Dynamic Degree` 上非常强。以 `VBench-Long` 为例：
- 30 秒视频：Deep Forcing 为 `57.56`，高于 `LongLive` 的 `45.55`、`CausVid` 的 `47.21`、`Self Forcing` 的 `36.62`、`Rolling Forcing` 的 `30.71`。
- 60 秒视频：Deep Forcing 为 `57.19`，同样明显高于 `LongLive` 的 `43.49`、`Self Forcing` 的 `31.98`、`Rolling Forcing` 的 `31.35`。

这点很关键，因为许多长视频稳定化方法本质上会把运动“钉死”；Deep Forcing 反而在稳定的同时保住了动态性。

第三，它在整体质量上是“竞争性更强，而不是单点碾压”：
- 30 秒时，`Overall Consistency = 20.54`，`Imaging Quality = 69.31`，`Aesthetic Quality = 60.68`。
- 60 秒时，`Overall Consistency = 20.38`，优于 `LongLive` 的 `20.29` 和 `Self Forcing` 的 `18.63`，接近 `Rolling Forcing` 的 `20.64`；`Imaging Quality = 69.27` 也明显高于 `Self Forcing` 与 `CausVid`。

作者还补了两类更贴近感知的评估：
- 用户偏好里，Deep Forcing 对 `Self Forcing` 在整体质量上获得 `87.9%` 偏好，对 `LongLive` 为 `72.2%`，对 `Rolling Forcing` 为 `78.9%`。
- `Gemini 2.5-Pro` 的视觉稳定性分数为 `75.44`，高于 `Rolling Forcing` 的 `72.6`，接近 `LongLive` 的 `78.58`。

综合来看，论文的结论不是“它在每项指标都是第一”，而是“在不训练的前提下，它已经接近甚至超过训练式方法，而且特别擅长保住动态性”。

### 5.3 Ablation
消融最能说明两部分组件各自做了什么：
- `Self Forcing` 基线的 `Dynamic Degree` 是 `36.62`。
- 加上 `Deep Sink` 后升到 `48.58`，说明长期锚点本身就能明显改善动态与稳定性。
- 再加上 `Participative Compression` 后进一步升到 `57.56`，同时 `Imaging Quality` 从 `68.58` 提升到 `69.31`。

也就是说：
- `Deep Sink` 主要负责“别把长期一致性的骨架弄丢”；
- `Participative Compression` 主要负责“别让无关旧历史继续污染当前生成”。

论文还给了 Top-$C$ 可视化，显示被保留下来的 token 往往对应主体、关键物体边界和重要背景结构，而不是平均撒在整帧上。这说明压缩并不是纯粹启发式裁剪，而是和语义关注区域对齐的。

## 6 Conclusion
Deep Forcing 的真正价值不只是提出了两个推理技巧，而是把长视频退化问题重新解释成“缓存组织问题”而不是“必须继续训练的问题”。它证明了：
- 视频扩散里的有效 sink 需要足够“深”，而不是只保留最开始几帧；
- 长视频历史不该用 FIFO 粗暴淘汰，而该按是否仍在参与当前注意力来选择；
- 只要把这两件事做好，training-free 的方法也能逼近甚至超过 training-based 长视频方法。

这篇论文最值得记住的 insight 是：`Self Forcing` 不是不够强，而是它原本的滚动缓存策略太粗了；Deep Forcing 本质上是在帮它把“该记住什么”这件事做对。

## 相关链接（双向）
- [[Self-Forcing ✅]]
- [[Self-Forcing++]]
- [[Rolling-Forcing✅]]
- [[LONGLIVE]]
- [[流式视频生成]]
