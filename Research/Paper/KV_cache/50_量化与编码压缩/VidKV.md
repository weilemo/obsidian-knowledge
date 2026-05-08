---
created: 2026-04-30
published: 2025-03-20
type: paper
status: 未读
tags:
  - VidKV
  - VideoLLM
  - KVCache
  - Quantization
  - MixedPrecision
aliases:
  - VidKV
  - Plug-and-Play 1.x-Bit KV Cache Quantization for Video Large Language Models
summary: VidKV 面向 VideoLLM 提出低于 2-bit 的 plug-and-play KV cache 量化方案，对 key 采用 channel 维 mixed precision 量化，对 value 采用约 1.58-bit 量化并保护语义显著视觉 token，同时指出 VideoLLM 的 value cache 更适合按 channel 而非按 token 量化。
pdf: /Users/moweile/Obsidian/Knowledge/Research/Paper/KV_cache/50_量化与编码压缩/Attachments/VidKV_2503.16257.pdf
pdf-url: Attachments/VidKV_2503.16257.pdf
source-url:
  - https://arxiv.org/abs/2503.16257
  - https://arxiv.org/pdf/2503.16257.pdf
  - https://doi.org/10.48550/arXiv.2503.16257
---

# Plug-and-Play 1.x-Bit KV Cache Quantization for Video Large Language Models

## 一句话结论
VidKV 最值得记住的不只是它把 VideoLLM 的 KV cache 压到了 `1.5-bit / 1.58-bit`，而是它明确说明了一件事：

$$
\text{VideoLLM 的 KV 量化规律不应直接照搬文本 LLM。}
$$

尤其是 `value cache`，在视频场景下更适合按 `channel` 量化，而不是沿用很多文本 LLM 工作中的 `per-token` 量化。

## 论文要解决什么问题
VideoLLM 面临的 KV cache 压力通常比纯文本 LLM 更大，因为视频输入会带来成千上万的视觉 token。这会同时带来两类瓶颈：

- 显存占用迅速膨胀；
- 解码阶段 KV 读取带宽压力变大，推理吞吐下降。

已有 KV cache 量化工作已经证明 `2-bit` 在文本 LLM 中是一个很有竞争力的区间，但对 VideoLLM 来说，还有两个问题没有被回答：

- `2-bit` 以下是否仍然可行；
- 文本 LLM 中总结出的最优量化粒度，迁到视频后是否还成立。

VidKV 就是在回答这两个问题。

## 核心观察
这篇论文的关键不是先拍脑袋设计一个超低比特量化器，而是先观察视频场景里的 KV 特征。作者给出的核心判断可以概括为两点：

- `Key cache` 可以继续做非常激进的低比特量化，但需要对异常 channel 和普通 channel 区别对待；
- `Value cache` 在 VideoLLM 中的最佳量化粒度，与文本 LLM 中常见结论不同，更适合 `per-channel` 而不是 `per-token`。

这意味着：

$$
\text{视频场景中的最优量化轴会变化。}
$$

也就是说，是否按 `token`、`channel`、甚至更细的结构做分组，不是一个可以跨模态直接继承的固定答案，而是需要重新由数据分布和语义敏感性来决定。

## 方法概述
VidKV 是一个 `plug-and-play` 的超低比特 KV cache 量化方法，核心是对 `K` 和 `V` 采用不同策略。

### 1. Key：channel 维 mixed-precision 量化
作者把 `key cache` 中的 channel 分成两类：

- 对异常 channel 使用 `2-bit` 量化；
- 对普通 channel 使用 `1-bit` 量化，并结合 `FFT` 处理。

这个设计背后的直觉很像“把最危险的统计异常先保护起来，再对大多数相对平稳部分做极致压缩”。因此它不是简单地统一降到 1-bit，而是一个带异常感知的混合精度方案。

### 2. Value：约 1.58-bit 量化 + 显著 token 保护
对 `value cache`，作者采用约 `1.58-bit` 的量化，同时对语义显著的视觉 token 做选择性保留或保护，以换取更好的精度-压缩平衡。

这个设计很关键，因为在视频任务里，`V` 更直接承载被 attention 读出的内容信息。若把所有视觉 token 一视同仁地极低比特压缩，容易伤到真正承载语义的部分。

因此 VidKV 对 value 的思路可以写成：

$$
\text{aggressive quantization} + \text{salient visual token preservation}
$$

它不是单纯问“最低能压到几 bit”，而是同时问“哪些 token 值得被少压一点”。

## 方法直觉
如果把 VidKV 放进 KV 量化这条研究线里理解，它的核心思想可以概括成一句话：

$$
\text{先区分视频 KV 的结构差异，再决定压缩方式。}
$$

更具体地说：

- `K` 更像是 attention 检索时的匹配索引，因此异常 channel 需要更高精度保护；
- `V` 更像是被读出的语义内容载体，因此除了量化粒度之外，还要考虑语义显著 token 的保留问题；
- 视频 token 的时空冗余虽然很多，但“冗余”不等于“所有 token 都同样不重要”。

所以 VidKV 的价值不只是更低 bit，而是把“视频模态下的结构感知量化”说得更清楚了。

## 实验结论
根据论文摘要，VidKV 在 `LLaVA-OV-7B` 和 `Qwen2.5-VL-7B` 上、六个 benchmark 中验证了以下几点：

- 能把 KV cache 压到 `1.5-bit` 和 `1.58-bit`；
- 与 FP16 相比几乎没有性能下降；
- 说明 VideoLLM 的 KV cache 在视频场景下仍然存在显著的超低比特压缩空间。

这组结果的意义不只是“又把 bit 降了一点”，而是说明：

$$
\text{VideoLLM 的 KV cache 量化下限可能比预想更低。}
$$

前提是量化策略需要与视频模态下的统计结构和语义结构匹配。

## 这篇论文的价值
VidKV 在这条路线里的价值主要体现在三点：

- 它把 KV cache 量化从文本 LLM 明确推进到了 VideoLLM；
- 它证明 `sub-2-bit` 在视频场景中是可以做的，而不只是理论想法；
- 它提出了一个很重要的反例：`value cache` 在 VideoLLM 中未必应该沿用文本 LLM 的 `per-token` 量化结论。

如果说 [[KIVI]] 代表“先区分 `K/V` 分布，再决定量化粒度”，那 VidKV 更进一步说明：

$$
\text{连同一个 } V \text{，在不同模态里最优量化粒度也可能不同。}
$$

这个结论对多模态 KV 压缩研究很有方法论价值。

## 局限与后续问题
从研究延展角度看，这篇论文也留下了几个很值得继续追的问题：

- 它说明了 `per-channel value quantization` 在 VideoLLM 中更优，但背后的统计机理还可以分析得更系统；
- “语义显著视觉 token” 如何定义、如何高效筛选，后续还有很大优化空间；
- 目前主要还是量化与选择性保护，尚未像 [[GEAR]] 那样显式建模量化误差恢复；
- 它验证了 VideoLLM，但更长视频生成模型、扩散式视频模型、时空生成 Transformer 是否也遵循相同规律，还需要单独验证。

## 对你当前研究的启发
如果把 VidKV 放到“长视频生成 / VideoGen KV cache 压缩”这个方向，它最重要的启发不在具体 bit 数，而在研究框架。

### 1. 不要默认文本 LLM 的结论可以直接迁移
很多 KV 压缩工作默认：

- `K` 和 `V` 的量化粒度有固定经验答案；
- `per-token` 或 `per-channel` 的优劣是跨任务稳定的。

VidKV 提醒我们，视频里这些结论都可能失效。你后面如果做长视频压缩，第一步更应该是重新画出 `K/V` 在时间、空间、head、channel 维度上的统计差异图谱。

### 2. value 可能比想象中更值得做结构化保护
VidKV 说明 `V` 不只是“压缩对象”，它还与视觉语义显著性直接耦合。因此视频生成里很可能也需要：

- 关键帧 token 保护；
- motion-sensitive token 保护；
- 高语义密度区域的差异化精度分配。

这和单纯做统一量化的思路是不同的，更接近“预算分配”问题。

### 3. 可以把量化与重要性判断结合起来
VidKV 已经隐含了一个方向：

$$
\text{quantization} + \text{token saliency}
$$

这对你很重要，因为你现在的研究本来就关心“哪些缓存更重要”。VidKV 相当于提供了一个视频版证据，说明显著性判断完全可以作为量化策略的一部分，而不只是 pruning 的一部分。

### 4. K/V 不对称思想仍然成立，但最优轴可能变化
VidKV 不是否定 [[KIVI]]，而是把 KIVI 的思路推进到了更细一层：

- `K/V` 仍然应该分开看；
- 但视频里的最优分组轴、异常模式、保护对象可能都会变。

这很适合你后面发展成“模态感知的 K/V 异构压缩策略”。

## 可以继续追的对比阅读
- [[KIVI]]：文本 LLM 中 `K/V` 非对称量化的经典起点，适合和 VidKV 对照看“哪些结论被继承，哪些被推翻”。
- [[GEAR]]：如果你关心高压缩率下如何显式恢复量化误差，可以作为 VidKV 的补偿式对照路线。
- [[KVQuant]]：如果你更关心极长上下文与更激进量化，可以和 VidKV 对照它在多模态场景中的适用边界。
- [[Quant-VideoGen]]：适合把 VidKV 放进你的视频生成主线里，作为“视频模态特化 KV 量化”的代表工作。

## 我的评注
VidKV 是一篇很值得记在“视频特化 KV 压缩”节点上的论文。它真正有价值的不是 `1.5-bit` 这个数字本身，而是它把一个原本默认继承自文本 LLM 的前提打破了：

$$
\text{最优 KV 量化策略是模态相关的。}
$$

对于后续做长视频生成的人来说，这个结论比具体实现细节更重要。因为它意味着研究起点不该是“找一个现成量化器迁过去”，而应该是“重新识别视频缓存里什么结构最值得保留”。
