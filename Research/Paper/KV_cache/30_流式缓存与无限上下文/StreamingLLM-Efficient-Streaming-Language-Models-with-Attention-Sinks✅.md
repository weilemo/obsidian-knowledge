---
created: 2026-04-18
published: 2023-09-29
type: paper
status: 已读
tags:
  - StreamingLLM
  - KVCache
  - LongContext
  - AttentionSinks
  - StreamingInference
aliases:
  - StreamingLLM
  - Efficient Streaming Language Models with Attention Sinks
summary: 提出 attention sink + rolling window 的流式 KV 缓存机制：持续保留少量起始 sink tokens 与最近窗口 tokens，使有限窗口训练的 LLM 在无需微调时即可稳定处理超长甚至近乎无限长度输入。
pdf-url: https://arxiv.org/pdf/2309.17453
source-url:
  - https://arxiv.org/abs/2309.17453
  - https://arxiv.org/pdf/2309.17453
  - https://openreview.net/forum?id=NG7sS51zVF
  - https://github.com/mit-han-lab/streaming-llm
---

# Efficient Streaming Language Models with Attention Sinks

## PDF
- [arXiv PDF](https://arxiv.org/pdf/2309.17453)

## Abstract
StreamingLLM 解决的是一个非常具体但很关键的问题：如果输入不是一段固定长度文本，而是持续不断到来的“流”，能不能让标准 Transformer LLM 以固定内存、固定单步开销稳定运行下去？

最自然的想法是 sliding window，只保留最近一段 KV。但论文发现，这个方案一旦把最开始的几个 token 逐出缓存，模型就会突然崩溃，perplexity 急剧恶化。作者进一步分析发现，许多 LLM 会在大多数层/头上持续给起始 token 很高注意力，即便这些 token 并不重要。这些 token 扮演的是 `attention sinks`：它们像“注意力垃圾桶”一样吸收 Softmax 中那些无处可去的概率质量。

基于这个观察，StreamingLLM 的方案非常简单：
- 永远保留极少数起始 sink tokens 的 KV；
- 再加上一个滚动的 recent window；
- 其余历史 KV 全部丢弃。

结果是，模型虽然只看到了“起始少数 token + 最近窗口”，却能在超长序列上保持稳定，并在 streaming 设置下相对 sliding-window recomputation baseline 获得最高 `22.2x` 的加速。

## 1 Introduction

### 1.1 论文要回答的问题
这篇论文的核心问题不是“如何把上下文窗口做大”，而是：

> 对一个只在有限长度窗口上训练过的 LLM，能否让它在推理时持续处理无限长输入流，同时保持稳定和高效？

这和一般长上下文论文有点不同。很多工作关注的是：
- 把 context window 从 `4k` 扩到 `32k/128k`；
- 或让模型更会利用长上下文。

而 StreamingLLM 关心的是更部署导向的问题：
- 多轮对话一直继续怎么办？
- 实时语音/日志/消息流持续输入怎么办？
- 如果永远不清空历史，KV cache 会无限增长，如何让它变成常数级内存？

### 1.2 两个核心困难
作者指出，流式部署有两个主要障碍：

1. `KV cache 不断增长`  
自回归解码时，每个新 token 都要依赖全部历史 KV。若输入持续到来，显存占用和每步 attention 开销都不断上升。

2. `长度外推会失稳`  
很多模型只在有限长度上训练，例如 Llama-2 的训练窗口约 `4K`。即使你技术上可以继续喂更长序列，性能往往也会在超出训练长度后下降。

### 1.3 为什么简单滑窗不够
一个看起来最合理的想法是 `window attention`：
- 只缓存最近 $W$ 个 token 的 KV；
- 更老的 token 全部淘汰。

这样做的好处很明显：
- 内存恒定；
- 单步解码复杂度恒定；
- 工程实现简单。

但论文发现，问题恰恰在于：`一旦最前面的 token 被移除，模型会突然崩`。

也就是说，滑窗不是平滑退化，而是存在明显断点：
- 在长度还没超过缓存窗口前，性能还可以；
- 一旦起始 token 被赶出缓存，perplexity 会骤升。

这说明起始 token 在标准 LLM 中起着某种比语义内容更底层的作用。

## 2 Related Work
论文把相关方向分为三类：

### 2.1 Length Extrapolation
目标是让模型在比训练窗口更长的序列上仍能工作，例如：
- `RoPE` 外推；
- `ALiBi`；
- 各类 position interpolation / scaling 方法。

这些方法试图缓解“长度超训练窗口”问题，但并不直接解决 streaming 场景下 KV 持续增长的问题。

### 2.2 Context Window Extension
这类方法尝试把模型一次性能处理的窗口做大，例如：
- 更高效的 attention kernel；
- 稀疏注意力；
- 针对长上下文的微调与扩窗训练。

它们能延长“单次可处理长度”，但不等于“可持续无限流式运行”。窗口再大，仍是有限的。

### 2.3 Improving Utilization of Long Text
这类工作关心模型是否真正会用长上下文信息，而不只是“形式上能接收更长输入”。

StreamingLLM 与这些方向是正交的。它并不声称：
- 模型更会理解长文档；
- 模型记忆更强；
- 模型真正拥有无限上下文能力。

它只是解决一个更基础的问题：`如何让模型在流式环境中稳定地继续跑下去`。

## 3 StreamingLLM 的核心观察

### 3.1 Window Attention 为什么会崩
论文在长文本上测 perplexity，发现：
- dense attention 在超过训练长度后会变差；
- pure window attention 在超过缓存大小后会更剧烈地崩；
- 崩点几乎就发生在“第一个 token 的 KV 被移除”时。

这说明问题不只是“远处信息丢了”，而是“某些非常早的 token 具有特殊稳定作用”。

### 3.2 什么是 Attention Sink
作者可视化注意力图后发现，在除最底两层外的大多数层/头里，模型会持续对最开始的 token 分配很高注意力，即便这些 token 在语义上并不重要。

这些 token 被称为 `attention sinks`。

直觉上，它们像一个“吸收槽”：
- 当前 query 并不一定真的需要所有历史 token；
- 但 Softmax 要求所有注意力权重加起来等于 1；
- 当很多 token 都不特别匹配时，模型还是得把一部分概率质量分配出去；
- 起始 token 因为几乎对后续所有位置都可见，训练中就更容易学成这种稳定“汇点”。

因此，sink token 的价值不在语义，而在于它稳定了注意力分布。

### 3.3 这不是语义效应，而更像位置/训练偏置
论文做了一个很有说服力的实验：
- 把前几个原始起始 token 替换成简单的换行 token；
- 结果模型仍然给这些位置很高注意力；
- 把这些起始位置重新放回缓存后，perplexity 也能恢复。

这说明起始 token 之所以重要，更多不是因为“它们说了什么”，而是因为：
- 它们位于开头；
- 它们在训练中长期扮演了特殊注意力锚点。

这也是 StreamingLLM 最反直觉的点：
- 需要保留的不是“最有信息量的开头 token”；
- 而是“最容易成为 attention sink 的那几个开头位置”。

## 4 StreamingLLM

### 4.1 方法本身非常简单
StreamingLLM 保留两部分 KV：

1. `attention sinks`  
固定保留最开始的少量 token，论文主结果里通常只需 `4` 个。

2. `recent window`  
再保留最近的滑动窗口 token。

于是当前缓存可写成：
$$
\mathcal{C}_t = \mathcal{S}_{\text{sink}} \cup \mathcal{W}_t
$$
其中：
- $\mathcal{S}_{\text{sink}}$ 表示固定保留的起始 sink tokens；
- $\mathcal{W}_t$ 表示时刻 $t$ 的最近窗口。

这和普通滑窗的差异极小，但效果差异很大。

### 4.2 它保留了什么，不保留什么
StreamingLLM 的设计非常克制：
- 不保存完整历史；
- 不做复杂重要性打分；
- 不需要回看所有过去 token；
- 不需要微调；
- 不需要外存召回。

它假设：
- 真正对稳定性至关重要的是极少数起始 sink；
- 真实语义依赖主要集中在最近局部上下文。

换句话说，它不是 trying to remember everything，而是：
- 用少量 sink 维持注意力分布正常；
- 用 recent window 维持局部语义连贯。

### 4.3 为什么这招有效
标准注意力可写为
$$
S = \frac{QK^\top}{\sqrt{d}}, \qquad
P = \operatorname{softmax}(S)
$$

如果把早期 sink token 的 key 全删掉，那么：
- Softmax 分母结构会被显著改变；
- 原本大量会分配给 sink 的概率质量被迫流向其他 token；
- 于是整体注意力分布发生分布外偏移，导致模型不稳定。

StreamingLLM 的本质，就是尽量让推理时的注意力分布更接近训练时习惯的形态。

所以它不是在“恢复全部历史信息”，而是在“恢复模型熟悉的注意力几何结构”。

### 4.4 与 recomputation baseline 的差别
还有一个可行基线是：
- 每步都只拿最近窗口；
- 但不是直接缓存，而是每次从窗口文本重新前向计算出这段窗口的 KV。

这通常能获得较好性能，因为模型始终在“合法前缀”上工作，不会出现前几个 token 直接蒸发的问题。

但问题是它很慢：
- 每一步都要对窗口重新计算；
- 窗口内部存在二次 attention 成本；
- 不适合真正高吞吐的流式部署。

StreamingLLM 的优势就是：
- 性能接近 recomputation；
- 但代价接近普通滑窗。

## 5 Experiments

### 5.1 支持的模型与整体结论
论文在多类主流 decoder-only 模型上测试，包括：
- `Llama-2`
- `MPT`
- `Falcon`
- `Pythia`

主结论很清晰：
- 普通滑窗会在起始 token 被淘汰后崩溃；
- StreamingLLM 只保留极少数 sink tokens，就能显著恢复稳定性；
- 在多个模型上都可以稳定处理超长序列，论文中提到可到 `4 million` tokens 及以上。

### 5.2 Perplexity 曲线的含义
这篇论文最经典的实验图，是对比：
- Dense attention
- Window attention
- Sliding window with recomputation
- StreamingLLM

从结果上看：
- dense attention 不是无限稳定的，超过训练长度也会退化；
- pure window attention 则会在缓存越界时出现断崖式恶化；
- recomputation 很稳，但太慢；
- StreamingLLM 的 perplexity 基本贴近 recomputation。

这个结论很重要，因为它说明：
- 问题核心并不是“模型必须看完整历史”；
- 而是“不能把 sink tokens 一并删掉”。

### 5.3 Sink token 数量消融
论文对“要保留多少个起始 token”做了消融。

结论大致是：
- `1` 或 `2` 个通常不够；
- `4` 个已经足够稳定；
- 再继续增加收益很小。

因此，StreamingLLM 的额外缓存开销其实非常小。相对于一个几千 token 的 recent window，多留 `4` 个 token 几乎可以忽略。

### 5.4 Cache Size 消融
一个挺有意思的观察是：缓存更大不一定单调带来更低 perplexity。

这说明：
- 模型并不总能充分利用更长上下文；
- “能接收更多 token”不代表“能更好使用更多 token”。

这也提醒我们不要把 StreamingLLM 误解成“万能长上下文增强法”。它主要解决稳定 streaming，不直接解决长上下文理解能力不足。

### 5.5 速度收益
和 sliding-window recomputation 相比，StreamingLLM 在 streaming 场景下最高可获得约 `22.2x` 加速。

这正是它最有工程吸引力的地方：
- 普通滑窗：快，但不稳；
- recomputation：稳，但太慢；
- StreamingLLM：既稳，又接近滑窗的效率。

## 6 预训练阶段的 Sink Token
论文还有一个很值得注意的延伸：如果 attention sink 如此关键，那能不能在预训练阶段就显式给模型一个专门的 sink token？

作者尝试的方法是：
- 在每个训练样本最前面插入一个可学习 placeholder token；
- 让它在训练中自然学成专用 sink。

实验表明，这样做之后：
- streaming 部署时可能只需要保留 `1` 个 sink token；
- 而不再需要 vanilla 模型那样保留多个原始起始 token。

这个结果说明：
- attention sink 不只是偶然现象；
- 它是可以被训练过程显式塑形的。

从方法论上，这也很有启发性：推理时的 KV 管理策略，未必只能靠后处理，训练阶段也可以主动为它预埋结构。

## 7 这篇论文真正贡献了什么

### 7.1 它提出了“流式 KV 缓存”的代表范式
StreamingLLM 的历史意义很强，因为它几乎定义了后续很多工作中的一个基础 baseline：

- 保固定的起始 tokens；
- 保最近窗口；
- 丢掉其它历史。

后面很多 KV 压缩或 budget 分配论文，都会把它当成最朴素也最有代表性的 streaming 路线来比较。

### 7.2 它把“起始 token 的特殊性”从现象变成了机制
在这篇论文之前，很多人可能会把开头 token 的高注意力当成一个可视化现象。StreamingLLM 把它上升成了一个可部署的机制解释：

- 这不是偶然；
- 这会决定滑窗是否崩溃；
- 这可以直接指导 KV cache 的保留规则。

### 7.3 它是极少数“简单到几乎像规则工程，但又非常有效”的论文
StreamingLLM 的方案复杂度很低，甚至低到容易让人低估它：
- 没有复杂打分；
- 没有训练；
- 没有召回；
- 没有页式管理；
- 没有 head/layer 自适应。

但它之所以经典，正因为它抓住了一个真正决定成败的机制变量。

## 8 局限与我对它的理解

### 8.1 它保证的是“流式稳定”，不是“全历史可检索”
StreamingLLM 非常适合：
- 多轮对话；
- 持续输入日志；
- 实时流式生成。

但它并不适合那些需要经常回头精确检索很早信息的任务，因为：
- 除了起始几个 sink token，其余远程历史都被丢掉了；
- 它没有 H2O 那种 important token 保留机制；
- 也没有 ArkVale 那种 recall 机制。

所以它更像“稳定运行骨架”，而不是“高保真长期记忆系统”。

### 8.2 它依赖于模型天然存在 attention sink 现象
StreamingLLM 的成功建立在一个经验事实上：
- 许多现成 LLM 的确会强烈注意开头 token。

如果模型架构、训练方式、位置编码或归一化设计发生变化，这个现象的强弱可能不同。后续一些工作也正是基于此进一步做 head-level、layer-level 或 retrieval/streaming 分工。

### 8.3 它没有真正让模型“拥有无限上下文理解力”
论文标题里说的是让模型 generalize to infinite sequence length，但这里更准确地理解应是：

- `infinite-length deployment stability`

而不是：
- `infinite-length semantic memory`

也就是说，模型可以一直跑，但不等于它会一直准确记住很久以前的具体信息。

## 9 与后续 KV Cache 方法的关系

### 9.1 和 H2O 的关系
`H2O` 认为除了 recent tokens，还应保留历史中的 heavy-hitters。  
StreamingLLM 则更极端、更简单：
- 只保起始 sink；
- 再保 recent window。

因此可以粗略理解为：
- StreamingLLM 解决“滑窗为什么会立刻崩”；
- H2O 解决“有限预算下哪些历史 token 更值得长期保留”。

### 9.2 和 SnapKV 的关系
`SnapKV` 更关注长 prompt 在生成前的压缩；
StreamingLLM 更关注持续解码中的常数内存运行。

一个偏 prompt pre-compression，一个偏 online streaming。

### 9.3 和 ArkVale 的关系
`ArkVale` 认为被淘汰的信息未来可能重新重要，因此要可召回。  
StreamingLLM 则不处理召回，它采用的是最简单的不可逆策略，只是特殊照顾了起始 sink。

因此：
- StreamingLLM 是最轻量的 streaming baseline；
- ArkVale 是更稳健但更复杂的分层存储/召回路线。

### 9.4 和 DuoAttention 的关系
`DuoAttention` 进一步把不同 head 分成 retrieval heads 与 streaming heads。  
从这个角度看，StreamingLLM 可以理解为：
- 假设大多数需要稳定流式行为的头，都可由“sink + recent”满足。

而 DuoAttention 则把这一点做得更精细，允许只有部分头走 streaming 模式。

## 10 可以记住的三句话
- StreamingLLM 的关键发现是：`window attention 崩溃的核心原因之一，是 attention sink 被删掉了。`
- 它的方法极其简单：`保留少量起始 sink tokens + 最近窗口 tokens。`
- 它带来的不是“更强长期记忆”，而是 `constant-memory, stable streaming inference`。

## 相关链接（双向）
- [[KV Cache]]
- [[H2O✅]]
- [[SnapKV✅]]
- [[ArkVale]]
- [[PyramidKV✅]]
- [[DuoAttention✅]]
