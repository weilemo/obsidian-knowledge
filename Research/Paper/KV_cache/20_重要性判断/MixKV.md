---
created: 2026-04-09
published: 2025-10-23
type: paper
status: 已读
tags:
  - MixKV
  - KVCache
  - LVLM
  - Diversity
  - LongContext
aliases:
  - MixKV
summary: 在 LVLM 的 KV 压缩中，不再只按重要性保留 token，而是联合优化 importance 与 diversity，并按 head 冗余度自适应加权，在极低预算下提升语义覆盖与下游性能。
pdf-url: Attachments/arxiv_2510.20707.pdf
source-url:
  - https://arxiv.org/abs/2510.20707
  - Attachments/arxiv_2510.20707.pdf
  - https://github.com/xuyang-liu16/MixKV
  - https://openreview.net/forum?id=B2iqbCQviR
---

# Mixing Importance with Diversity: Joint Optimization for KV Cache Compression in Large Vision-Language Models

## PDF
- [[Attachments/arxiv_2510.20707.pdf]]

## Abstract
MixKV 关注的是一个在多模态 KV 压缩里非常容易被忽视的问题：如果我们只按“重要性”保留 KV，很可能会反复保留许多“都很重要、但彼此很像”的 token，结果是预算花掉了，语义覆盖却不够广。

在纯文本场景里，这个问题已经存在；到了 LVLM 里会更严重，因为视觉 token 往往高度冗余，同一对象、同一区域、同一布局模式会在多个 patch 或多个 head 中重复出现。于是，importance-only 的 top-k 选择很容易出现：
- 选中的 token 都很“相关”；
- 但它们表达的是相近语义；
- 真正稀有、补充性的视觉证据被挤掉。

MixKV 的核心想法很直接：
- 继续保留现有方法里的重要性信号；
- 额外显式建模 diversity；
- 再根据每个 head 的冗余程度，自适应平衡 importance 和 diversity 的权重。

论文的定位也很清楚：它不是重写一整套新的 KV 压缩框架，而是做一个 `plug-and-play` 的评分增强模块，可以接到 SnapKV、AdaKV、PyramidKV 一类方法上。在极限压缩 `budget=64` 时，论文报告在五个多模态理解基准上平均提升 `5.1%`，在 GUI grounding 上对 SnapKV / AdaKV 分别带来约 `+8.0 / +9.0` 的显著增益，同时推理开销几乎不变。

## 1 Introduction

### 1.1 论文关注的现实问题
LVLM 的 KV cache 问题通常比纯文本 LLM 更重，原因很直接：
- 图像会被切成大量视觉 token；
- 视频会进一步放大 token 数量；
- 文本和视觉 token 一起进入 LLM 后，prefill 阶段生成的 KV 非常大；
- 一旦做长上下文理解、多图推理或 GUI grounding，KV cache 会迅速成为显存瓶颈。

所以，多模态场景里的 KV 压缩往往不是可选优化，而是部署前提。

### 1.2 现有方法的问题不是“不会筛”，而是“筛得太像”
现有很多方法已经会按 importance 做筛选，例如：
- 根据 observation window 的 attention 选关键位置；
- 根据 key/value 范数做 intrinsic importance；
- 根据 budget 做 top-k 保留。

但作者指出，这类方法隐含了一个默认前提：
- 只要 token 重要，就值得保留。

这在高冗余视觉场景里不一定成立。更准确地说，真正的问题是：
- 多个 token 可能都很重要；
- 但它们提供的信息高度重叠；
- 于是有限预算被“相似证据”挤占，导致整体语义覆盖不足。

### 1.3 论文的核心主张
MixKV 的主张可以概括为两句话：

1. `重要性不够，必须同时考虑多样性。`
2. `多样性的权重不能固定，而应随 head 的冗余程度自适应变化。`

这使它和很多单一打分函数方法有明显区别。它不是问：
- 哪些 token 最重要？

而是问：
- 在有限预算下，哪些 token 既重要、又能补足覆盖盲区？

## 2 Related Work
论文把相关路线大致放在三条脉络中：

### 2.1 LVLM 与长上下文压力
在 `ViT / Vision Encoder -> Projector -> LLM` 的标准 LVLM 管线下，视觉 token 数量会直接转化为更大的 KV cache。图像分辨率越高、帧数越多、拼接输入越长，问题越明显。

### 2.2 长上下文高效推理
包括：
- 高效 attention kernel；
- 模型压缩；
- token / KV 压缩；
- KV 量化。

这些方法都在不同层面减轻推理负担，但并不一定解决“保留下来的 token 是否覆盖足够语义”的问题。

### 2.3 重要性驱动的 KV 压缩
如 `SnapKV`、`PyramidKV`、`AdaKV`、`SparseMM`、`KNorm`、`VNorm` 等，大多依赖某种重要性评分，然后做 top-k 保留。

MixKV 的差异不在于替换 top-k，而在于替换其输入评分函数。也就是说：
- 压缩算子可以不变；
- 预算机制可以不变；
- 只把“importance-only score”换成“importance + diversity 的复合分数”。

这也是它可插拔性的来源。

## 3 Methodology

### 3.1 Preliminaries: LVLM 中的 KV 压缩问题
论文采用标准生成建模视角。给定视觉特征 $\mathbf{F}^v$ 与文本特征 $\mathbf{F}^t$，生成序列 $\mathbf{Y}$ 的概率写为：
$$
p(\mathbf{Y}\mid \mathbf{F}^{v}, \mathbf{F}^{t})
=
\prod_{j=1}^{L}
p(\mathbf{y}_j \mid \mathbf{F}^{v}, \mathbf{F}^{t}, \mathbf{Y}_{1:j-1}; \mathcal{C})
$$
其中 $\mathcal{C}$ 表示 KV cache。

KV 压缩的抽象形式是：
- 对每层每个 head 的历史 KV 对打分；
- 在给定预算 $B$ 下保留 top-$B$；
- 让压缩后推理尽量接近 full KV。

MixKV 不改变这个框架，它只改“打分”。

### 3.2 论文为什么要把问题拆成 importance 和 diversity
如果只保留高 importance token，那么最容易出现的是：
- 某一语义簇里许多 token 的分数都很高；
- top-k 会反复从同一簇里取 token；
- 其它语义簇虽然分数略低，但可能对最终理解很关键。

所以，importance 回答的是：
- `这个 token 现在看起来重要吗？`

而 diversity 回答的是：
- `这个 token 带来了新的、未被其它 token 覆盖的信息吗？`

MixKV 的价值就在于把这两个问题放到同一个优化里。

### 3.3 Importance：外在 + 内在两类信号
论文把重要性拆成两部分：

1. `外在重要性（extrinsic importance）`  
通常来自 observation window attention，对应“当前任务/指令到底在看什么”。

2. `内在重要性（intrinsic importance）`  
来自 KV 自身统计量，用来补充那些未必在当前 observation 中直接显著、但表示幅值较强或结构上重要的 token。

论文默认把两者相加：
$$
s_{\text{imp},i}=s^{\text{ex}}_{\text{imp},i}+s^{\text{in}}_{\text{imp},i}
$$

其中内在重要性默认采用 `VNorm`，也就是 value 向量的 $\ell_2$ 范数，并会先归一化到与 attention score 同量级。

可以把它理解为：
- `extrinsic` 更像“任务相关性”；
- `intrinsic` 更像“表示强度先验”。

### 3.4 Diversity：一个 token 是否远离“平均语义中心”
论文的 diversity 建模非常朴素，但挺有效。对同一层、同一 head 的 key 向量先归一化，然后看每个 key 与该 head 的“全局平均 key”之间的负余弦相似度：
$$
s^{\text{div}}_i = - \hat{\mathbf{K}}^l_{h,i}\cdot \hat{\bar{\mathbf{K}}}^l_h
$$

其中：
- $\hat{\mathbf{K}}^l_{h,i}$ 是第 $l$ 层、第 $h$ 个 head、第 $i$ 个 token 的归一化 key；
- $\hat{\bar{\mathbf{K}}}^l_h$ 是这个 head 内全部 key 的平均方向。

这个定义的直觉是：
- 如果一个 token 很接近全局中心，它更可能是“常规、重复、平均化”的；
- 如果它远离中心，它更可能携带独特或补充性的语义。

因此，分数越高，表示越值得从“多样性”角度被保留。

### 3.5 Head-wise Redundancy：不是所有 head 都一样冗余
MixKV 最重要的设计点，不是 “importance + diversity” 这个式子本身，而是：
- 它不是用全局固定权重把二者硬加起来；
- 而是先估计每个 head 的冗余程度，再决定该更看重哪一项。

head 的平均冗余度定义为：
$$
\bar{r}^l_h
=
\frac{T^2\left\|\hat{\bar{\mathbf{K}}}^l_h\right\|_2^2 - T}{T(T-1)}
$$

其中 $T$ 是该 head 中 token 数量。这个量本质上反映的是：
- 同一 head 里的 key 是否彼此相似；
- 如果大多数 key 方向相近，说明 head 更冗余；
- 如果 key 分布更分散，说明 head 本身已具备较好多样性。

### 3.6 Adaptive Mixing：冗余高就多看 diversity，冗余低就多看 importance
最终复合分数写为：
$$
s^{\text{comp}}_i
=
(1-\bar{r}^l_h)\cdot s_{\text{imp},i}
+
\bar{r}^l_h\cdot s^{\text{div}}_{\text{scaled},i}
$$

这条公式非常直观：
- 当某个 head 冗余高，$\bar{r}^l_h \to 1$  
  说明“相似 token 太多”，此时应提高 diversity 权重，避免预算被同质 token 占满。

- 当某个 head 冗余低，$\bar{r}^l_h \to 0$  
  说明这个 head 本来就比较分散，此时再过度强调 diversity 反而可能把任务关键证据稀释掉，因此更应相信 importance。

最后，MixKV 仍然执行熟悉的 top-$B$ 选择。也就是说，它改的是 ranking，不改 selection operator。

### 3.7 这篇方法的真正优点是什么
MixKV 的优点不是算法特别复杂，而是它插得很对：
- 不重写底层 cache 管理；
- 不引入召回；
- 不改模型训练；
- 不改变主干预算机制；
- 只在“谁排前面”这个位置上，把“重要性”升级成“重要性 + 覆盖性”。

这让它特别适合作为已有 KV 压缩方法的增益模块。

## 4 Experiments

### 4.1 实验设置
论文覆盖了多种模型和任务：

- 多模态模型：
  `LLaVA-NeXT-Mistral-7B`、`InternVL3-8B`、`Qwen2-VL-7B`

- GUI grounding：
  `Qwen2.5-VL-7B`

- 纯文本长上下文：
  `Mistral-7B`、`Llama-3.1-8B`，评测 `LongBench`

基线包括：
- `SnapKV`
- `PyramidKV`
- `AdaKV`
- `SparseMM`

预算通常测试 `256 / 128 / 64` 等多档，重点看极限压缩下的表现。

### 4.2 多模态理解主结果
在 `DocVQA`、`OCRBench`、`TextVQA`、`ChartQA`、`TextCaps` 等基准上，MixKV 基本都能为不同 backbone / baseline 带来正向收益。

论文的摘要级主结论是：
- 在 `budget=64` 这种很激进的压缩条件下；
- 五个多模态理解基准平均提升约 `5.1%`。

这个结果支持了论文最核心的论点：
- 问题不只是“选不选得准”；
- 更是“选出来的东西是否覆盖得开”。

### 4.3 GUI Grounding 上为什么提升尤其大
`ScreenSpot-v2` 是论文里最亮眼的一组结果之一。  
作者报告：
- `SnapKV` 在 `budget=128` 下平均从 `75.3` 提升到 `83.3`，约 `+7.9`
- `AdaKV` 在 `budget=64` 下平均从 `53.7` 提升到 `62.7`，约 `+9.0`
- `PyramidKV` 也有明显正增益

这类任务特别能放大 MixKV 的优势，因为 GUI grounding 经常需要：
- 保留多个局部线索；
- 同时区分许多视觉上相似但语义功能不同的区域；
- 若只保“最重要的一簇”，很容易错过补充证据。

从这个角度看，MixKV 对 GUI 任务的提升其实很合理：GUI 场景比一般图文问答更依赖覆盖性，而不仅是局部显著性。

### 4.4 LongBench 上的文本结果
论文也测了纯文本长上下文，结果依然有提升，但没有多模态那么稳定和显著。

作者的解释也很合理：
- LLM 的 head 冗余度整体往往低于 LVLM；
- 纯文本里局部关键证据有时更集中；
- 若过度强调 diversity，反而可能把预算从真正关键证据上分走。

因此，在纯文本任务中，MixKV 的收益更任务相关：
- 信息聚合、摘要类任务更可能受益；
- 精确信息定位类任务可能收益小，个别甚至会轻微回落。

这恰好说明 MixKV 不是“永远优于 importance-only”，而是特别适合高冗余场景。

### 4.5 消融实验
论文做了几组很关键的消融：

1. `importance 的构成`
- `extrinsic + intrinsic(VNorm)` 通常优于 `extrinsic + intrinsic(KNorm)`

2. `是否真的需要 diversity`
- 只用 diversity 会退化；
- 只用 importance 也不够；
- 二者联合明显更稳

3. `固定混合 vs. 自适应混合`
- 固定权重相加不如 head-wise adaptive mixing；
- 按样本在线估计冗余度的版本通常最好

这些消融说明 MixKV 的贡献不是“多加一个分数”这么简单，而是：
- `diversity` 本身有价值；
- 但更关键的是 `diversity 该在什么 head 上、用多大权重`。

### 4.6 效率开销
MixKV 的另一个优点是代价很小。论文报告：
- 延迟增加通常小于 `1%`
- 峰值显存基本不变

这是因为它并没有改变压缩主流程，只是在已有分数上做轻量 mixing。换句话说，它更像一个评分插件，而不是一套新系统。

## 5 我对这篇工作的理解

### 5.1 它把“重要性判断”从单目标变成了双目标
很多 KV 压缩方法默认只优化一个目标：
- 尽量保留最重要 token。

MixKV 则明确指出，这个目标在高冗余场景里是不够的，因为你还需要：
- 尽量扩大被保留 token 的语义覆盖面。

所以它本质上是把问题从：
- `importance maximization`

改成了：
- `importance + coverage/diversity joint optimization`

这在多模态里尤其自然，因为视觉信息的冗余性远高于纯文本。

### 5.2 它最像“重排器”，而不是“压缩器”
我觉得最合适的理解是：MixKV 并不是独立的 KV 压缩器，而是一个 `re-ranker`。

它不负责：
- 怎么分预算；
- 怎么做分页；
- 怎么做召回；
- 怎么做层间调度。

它负责的是：
- 现有候选分数已经有了；
- 现在重新排一下序，让留下来的集合既重要又不太重复。

所以它可以自然接在 SnapKV / AdaKV / PyramidKV 后面。

### 5.3 它对多模态场景有效，是因为抓住了“视觉冗余税”
如果只用一句话概括 MixKV 的洞察，我会写：

> 多模态 KV 压缩的真正隐性成本，不只是信息丢失，而是预算被视觉冗余悄悄吃掉了。

视觉 token 非常容易出现：
- 邻近 patch 表达相似区域；
- 同一对象的多个局部都高响应；
- 不同 head 在类似视觉结构上重复聚焦。

MixKV 的价值就在于，它不是继续问“谁最亮”，而是问“你们是不是亮得太像了”。

### 5.4 它也有边界
MixKV 不是没有适用边界：

- 它更适合 `高冗余` 场景；
- 对本来就不太冗余的文本 head，过强 diversity 可能有副作用；
- 它提升的是 selection quality，不直接解决：
  - 外存管理；
  - recall；
  - layer budget allocation；
  - 在线动态重要性漂移。

所以它更像是“重要性判断层面的一次升级”，而不是完整系统方案。

## 6 与相关工作的关系

### 6.1 和 SnapKV 的关系
`SnapKV` 的重点是：
- 用 observation window 预测后续会关注哪些 prefix token。

MixKV 可以接在它后面做的事是：
- 这些 token 虽然都重要，但是否过于相似？
- 是否该用 diversity 把保留集合拉得更开？

因此，MixKV 可以看成对 SnapKV 打分阶段的增强。

### 6.2 和 AdaKV 的关系
`AdaKV` 更关注：
- 在总预算固定时，如何按 head / layer 自适应分配 KV 容量。

MixKV 则关注：
- 在某个 head 已经拿到预算后，具体该选哪些 token。

所以两者并不冲突，一个偏预算分配，一个偏集合质量。

### 6.3 和 PyramidKV 的关系
`PyramidKV` 重点在跨层预算分配：
- 低层多留，高层少留。

MixKV 不处理跨层预算，而是处理层内 / head 内的排名问题，因此可以视为正交增强。

### 6.4 和 H2O / StreamingLLM 的关系
`H2O`、`StreamingLLM` 这类方法更多是：
- 在纯文本 LLM 中定义“该留哪些历史 token”的简单范式。

MixKV 则更偏向：
- 多模态；
- 高冗余；
- importance-only 不够的场景。

它不以“最近 token”或“heavy hitter”范式为核心，而是直接从保留集合的覆盖性出发。

## 7 可以记住的三句话
- MixKV 的核心观点是：`高 importance 不等于高价值，因为保留集合还需要语义多样性。`
- 它最关键的技术点是：`按 head 冗余度自适应平衡 importance 和 diversity。`
- 它最适合的场景是：`视觉 token 冗余高、预算极小、覆盖性比单点显著性更重要的 LVLM 推理。`

## Appendix Notes
附录补充了：
- 更细的冗余可视化与 t-SNE 分析；
- 与 SnapKV 集成的伪代码；
- 详细实验设置与效率曲线；
- 当前主要验证集中在 8B 规模模型上的限制讨论。

## 相关链接（双向）
- [[KV Cache]]
- [[H2O✅]]
- [[SnapKV✅]]
- [[Ada-KV✅]]
- [[PyramidKV✅]]
