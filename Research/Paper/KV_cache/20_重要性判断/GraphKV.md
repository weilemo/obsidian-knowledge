---
created: 2026-04-09
published: 2025-08-30
type: paper
status: 已读
tags:
  - GraphKV
  - KVCache
  - LLMInference
  - GraphMethod
  - Diversity
aliases:
  - GraphKV
  - GraphKV: Breaking the Static Selection Paradigm with Graph-Based KV Cache Eviction
summary: GraphKV 不是重新设计一套新的 KV eviction score，而是在已有重要性分数之上，把 token 关系显式建成图，并通过基于相似度的 decay signal propagation 动态压低冗余 token 的分数，从而在同样预算下同时保留代表性与多样性。
pdf-url: Attachments/arxiv_2509.00388.pdf
source-url:
  - https://arxiv.org/abs/2509.00388
  - https://doi.org/10.18653/v1/2025.emnlp-main.1112
  - https://aclanthology.org/2025.emnlp-main.1112/
  - Attachments/arxiv_2509.00388.pdf
---

# GraphKV: Breaking the Static Selection Paradigm with Graph-Based KV Cache Eviction

## PDF
- [[Attachments/arxiv_2509.00388.pdf]]

## 一句话摘要
GraphKV 的核心不是发明新的 token importance，而是指出 `top-k importance` 这一步本身太静态了。它把 token 看作图上的节点、把 key 相似度看作边，然后用 `decay signal propagation` 逐轮压低和高分 token 太相似的节点分数，从而减少“选出来的都很重要、但彼此很像”的冗余问题。

## Abstract
这篇论文关注长上下文推理里一个很现实的问题：很多 KV cache eviction 方法已经能给每个 token 打一个“重要性分数”，但最终还是用静态的 `top-k` 选择来决定保留谁。作者指出，这种做法会系统性地保留一批彼此很相似的高分 token，于是预算虽然花掉了，语义覆盖却未必最好。为了解决这个问题，论文提出 `GraphKV`。它不替代现有分数函数，而是把 token 定义为图节点，把 token 间的 key cosine similarity 定义为边，再在图上做一种负向的 `decay-signal-propagation`：先选出少量高分 source nodes，然后把与它们最相近的节点分数按相似度衰减，必要时可多轮传播。最终重新按更新后的分数做选择。这样留下来的 token 不只“重要”，还更“去冗余”。实验表明，GraphKV 可以以 plug-and-play 的方式接到 `SnapKV`、`PyramidKV`、`KNorm` 等方法上，在同样 KV 预算下提升 LongBench 和 Needle-in-a-Haystack 上的表现。

## 1 Introduction
论文切入的问题非常直接：
- 长上下文推理时，KV cache 大小随序列长度线性增长，显存和解码成本都会迅速上涨。
- 训练免费的 KV eviction 路线已经很成熟，很多方法都能给 token 分配 importance score。
- 但“先打分、再一次性 top-k 保留”的静态范式，默认高分 token 之间彼此独立，这在实际中并不成立。

作者的核心观察是：高分 token 往往在语义上高度相似。如果我们只是保留多个同类高分 token，那么：
- 它们对后续 query 可能都很 relevant；
- 但携带的信息高度重复；
- 一些分数略低、但语义互补的 token 反而会被挤掉。

所以这篇论文真正要解决的问题不是“如何重新定义重要性”，而是：
- 当已有 importance score 时，如何进一步建模 token 之间的关系？
- 如何在保留代表性 token 的同时，抑制语义重复？

## 2 Related Works
论文把自己放在两条已有路线之间：

- `KV Cache Eviction`
  如 `H2O`、`SnapKV`、`PyramidKV`、`CAKE`、`KNorm` 等，都在研究如何在固定预算下保留最有用的缓存。

- `Graph-based Modeling`
  图神经网络和图传播方法擅长显式建模对象之间的关系，并通过邻域传播动态更新节点状态。

GraphKV 的位置很清楚：它不是新的 eviction baseline，而是一个图上的“分数后处理框架”，把已有方法输出的静态 importance 变成动态、关系感知的 importance。

## 3 Observation
这篇论文最关键的动机来自一个很简单但很有说服力的现象：`top-k` 高分 token 往往彼此更像。

作者在 LongBench 的 HotpotQA 样本上，用 `Llama3-8B` 分析了 key 向量的 cosine similarity，发现：
- 全体 token 的相似度分布相对分散；
- 但单纯按 importance 选出的 top-10 token，在相似度热力图里明显更“亮”，说明它们之间更相似；
- 也就是说，静态高分选择很容易选出一组冗余 token。

这带来一个重要 insight：
- `importance` 反映的是“这个 token 对当前 query 可能有用”；
- 但 `similarity` 决定了“这个 token 是否在重复别人已经提供的信息”。

因此，KV eviction 不该只问“谁重要”，还应问“谁和已选 token 太像了”。

## 4 Methodology

### 4.1 Problem Formulation
设输入序列为：
$$
X_{\mathrm{input}}=[x_1,\dots,x_n]
$$

对第 $l$ 层，完整的 key/value 矩阵分别为：
$$
K^l, V^l \in \mathbb{R}^{n\times d}
$$

token eviction 的目标是在预算 $k_l<n$ 下，找到压缩后的：
$$
K_s^l, V_s^l \in \mathbb{R}^{k_l\times d}
$$
使得压缩模型的性能尽量接近全量缓存：
$$
\mathrm{Score}(K_s^l, V_s^l, D) \approx \mathrm{Score}(K^l, V^l, D)
$$

GraphKV 不改变这个目标，也不直接定义新的主打分函数。它假设我们已经有每个 token 的初始重要性分数 $s_i$，然后在此基础上做图上的动态更新。

### 4.2 Sparse Graph Building
GraphKV 先把 KV cache 建成一个加权图：
$$
G=(O,E)
$$

其中：
- 每个 token 对应一个节点 $o_i \in O$；
- 每个节点带有一个初始 importance score $s_i$；
- 边权由 token key 向量之间的 cosine similarity 给出。

对 token $x_i$ 和 $x_j$，边权定义为：
$$
e_{ij}=\frac{\langle k_i, k_j\rangle}{\|k_i\|\,\|k_j\|}
$$

这里有个实际问题：如果所有 token 两两连边，计算量会太大。于是作者做了一个很实用的稀疏化：
- 只保留少量分数最高的 token 作为 `source nodes`；
- 只计算这些 source nodes 与其它所有节点之间的相似度。

source nodes 定义为：
$$
O_{\mathrm{source}}
=
\{o_i \mid s_i \text{ ranks in top-}k,\ i\in\{1,\dots,n\}\}
$$

这一步的含义是：
- 先相信已有 eviction 方法给出的高分 token 确实“值得关注”；
- 再围绕这些高分 token 去判断，谁和它们过于相似。

因此，GraphKV 的额外开销不是 $O(n^2)$，而是接近：
$$
O(N\times K)\approx O(N)
$$
因为这里 $K\ll N$。

### 4.3 Decay Signal Propagation
图建好之后，GraphKV 不会直接保留 source nodes，而是进一步做相似度驱动的负向传播。

#### 4.3.1 邻域定义
对每个 source node $o_i$，只在与其最相近的 top-$m$ 个邻居上施加衰减：
$$
N(o_i)=\{o_j \mid e_{ij}\ge e_{i(m)},\ j\ne i\}
$$

其中 $e_{i(m)}$ 是从 $o_i$ 出发的第 $m$ 大边权。

这个设计的直觉很自然：
- 只压低那些和高分 token 很像的节点；
- 不去影响大多数无关节点；
- 这样能更精准地做“去冗余”，而不是粗暴扰动全局分数。

#### 4.3.2 一轮传播
对邻居 $o_j\in N(o_i)$，论文先给出一轮传播时的分数更新：
$$
s'_j = s_j - \gamma e_{ij} s_j
$$

这里我把文中衰减系数记作 $\gamma$。它表达的是：
- 边越强，说明两个 token 越像；
- token 原始分数越高，被压低的绝对值也越大；
- 所以高分且高度重复的 token 会被重点抑制。

#### 4.3.3 多轮传播
作者进一步把这个过程推广到 $T$ 轮传播。第 $t$ 轮后，节点 $o_j$ 的分数为：
$$
s_j^{(t)}
=
s_j^{(t-1)}
\prod_{o_i\in O_{\mathrm{source}},\,o_j\in N(o_i)}
(1-e_{ij})
$$

并以：
$$
s_j^{(0)}=s_j
$$
为初值。

从直觉上理解，这个过程是在做一件很明确的事：
- 如果某个 token 和多个高分 source nodes 都很相似；
- 那它会累计受到更多衰减；
- 最终更可能被排到预算外。

传播结束后，再按更新后的 $s_j^{(T)}$ 重新选出预算 $k_l$ 内的 token。

### 4.4 这个机制的真正含义
我觉得可以把 GraphKV 概括成一句话：

`先相信已有方法找到“重要 token”，再用图传播排除其中“太像的重要 token”。`

所以它本质上是在优化一个平衡：
- 代表性：先保留高 importance token；
- 多样性：通过 similarity-based decay 把重复 token 往下压。

这也是它能 plug-and-play 的原因，因为它没有推翻已有 score，而是在其后补上一层关系建模。

## 5 Experiments

### 5.1 Baselines and Setup
论文把 GraphKV 接到五种代表性方法上：
- `CAKE`
- `SnapKV`
- `PyramidKV`
- `H2O`
- `KNorm`

评测模型包括：
- `Llama2-7B-Chat`
- `Llama3-8B-Instruct`
- `Mistral-7B-Instruct-v0.2`

所有 LongBench 实验都固定 `KV cache size = 512`，并在单张 `NVIDIA H20` 上进行。

### 5.2 LongBench Main Results
LongBench 的主结果很清楚：GraphKV 作为后处理框架，几乎总能提升已有 eviction 方法。

#### Llama2-7B-Chat
- `KNorm`: `13.03 -> 25.20`
- `SnapKV`: `31.95 -> 32.35`
- `PyramidKV`: `32.04 -> 32.25`

这里最夸张的是 `KNorm`，平均分几乎翻倍，说明“只按 norm 排序”的静态选择在冗余问题上受伤很重，而 GraphKV 的去冗余能明显补回来。

#### Llama3-8B-Instruct
- `KNorm`: `20.64 -> 29.76`
- `SnapKV`: `39.97 -> 40.35`
- `PyramidKV`: `39.58 -> 40.09`

作者在正文里特别强调，在 LongBench QA 任务上，GraphKV 相比次优的 `KNorm` 可带来 `45.88%` 的提升；同时，在 `Llama3-8B`、KV budget 为 `512` 时，相比 `SnapKV` 和 `PyramidKV` 也有大约 `3%` 的增益。

#### Mistral-7B-Instruct-v0.2
- `KNorm`: `14.91 -> 16.50`
- `SnapKV`: `40.24 -> 40.60`
- `PyramidKV`: `40.16 -> 40.50`

这一组说明：即便基线已经很强，GraphKV 仍然经常能给出稳定但不激进的改善。

总体上，这篇论文最重要的实验结论不是“GraphKV 单独最好”，而是：
- 它能稳定增强多种不同来源的 importance score；
- 尤其对较粗糙的静态 top-k 基线增益更大；
- 对已经很成熟的 `SnapKV / PyramidKV` 也仍然有收益。

### 5.3 Needle In a Haystack
在 `Llama3-8B`、上下文长度 `8K`、KV budget `128` 的设置下，GraphKV 在 Needle in a Haystack 上的提升非常亮眼：

- `PyramidKV`: `90.3% -> 96.9%`，提升 `+6.6%`
- `SnapKV`: `87.7% -> 95.9%`，提升 `+8.2%`

这个结果很关键，因为 Needle 任务本身就特别依赖在超长上下文里保住“真正关键但很稀疏”的信息。GraphKV 能明显提升这类 retrieval 成功率，说明它保住的不只是“平均意义上高分”的 token，而更像是“更少冗余、更有覆盖”的 token 集合。

## 6 Ablation

### 6.1 Effect of Adaptive Source Nodes
作者把 source nodes 数量设为 KV budget 的不同比例，发现：
- 最优点大约在 `0.3 × B`
- source nodes 太少，去冗余作用不够；
- source nodes 太多，则会让太多节点受到传播影响，开始把噪声也带进来。

这个结论很符合直觉：GraphKV 不是要把所有高分 token 都当成图传播中心，而是只挑一部分“最值得信任的高分 token”作为 source。

### 6.2 Effect of Adjacent Nodes
对每个 source node，邻居数若采用自适应策略，通常优于固定邻居数。并且：
- 邻居数增大后，性能往往下降；
- 说明受传播影响的节点越多，越容易引入噪声。

因此 GraphKV 的经验策略是：
- 传播范围要局部；
- 只针对最相似的一小部分 token 做抑制。

### 6.3 Effect of Propagation Round
传播轮数实验非常有启发性。作者比较了：
- `T=0`：不传播
- `T=1,2,3`：传播 1 到 3 轮

主要结论是：
- 从 `T=0` 到 `T=1`，提升最大；
- 继续增加传播轮数，收益会变小，甚至轻微回落；
- 但总体上仍普遍优于不传播。

论文举的一个典型例子是：
- `PyramidKV` 从 `42.51` 提升到 `44.48`
- 在第一轮传播后就超过了 `FullKV`

这说明 GraphKV 的最重要作用其实是一轮“去掉最明显冗余”的修正，后续再传播更多轮，边际收益已经没那么大了。

## 7 Discussion

### 7.1 Different Similarity Choices
作者不仅测试了 key-to-key cosine similarity，还试了：
- query-to-key
- query-to-query
- key-to-value
- value-to-value

结果表明，这些相似度定义也能带来收益。说明 GraphKV 的核心并不依赖某一种极其特殊的边定义，而是更一般地依赖：

`在重要性排序之外，再显式建模 token 间的相似关系。`

### 7.2 Different Graph Signals
论文还比较了三种传播信号：
- `Decay (-)`
- `Enhanced (+)`
- `Evicted (-\infty)`

在 128 KV budget 下，平均分分别为：
- `Decay`: `39.84`
- `Enhanced`: `38.67`
- `Evicted`: `18.80`
- `Baseline`: `38.61`

这组结果特别说明问题：
- 适度的负向衰减最好；
- 直接“增强相似 token”没什么用；
- 粗暴地把与 source 相连的节点全删掉会严重伤害性能。

也就是说，GraphKV 的关键不是“识别相似就删除”，而是：
- 用相似度做软抑制；
- 在 importance 和 diversity 之间保持平衡。

### 7.3 Efficiency
GraphKV 的额外计算看起来像是“又建图又传播”，但实际延迟并不高。QMSum 上、KV budget 为 `512` 时：

- `PyramidKV`: `5.133s`
- `PyramidKV + GraphKV`: `5.265s`，约 `+2.5%`
- `SnapKV`: `5.474s`
- `SnapKV + GraphKV`: `4.912s`，约 `-10.2%`
- `KNorm`: `6.031s`
- `KNorm + GraphKV`: `5.095s`，约 `-15.5%`

这个结果很有意思：GraphKV 不仅没有显著增大解码延迟，在某些组合里反而更快。作者的解释是，精度提高后模型可能减少了无效或过长的生成，从而让端到端耗时下降。

## 8 Conclusion
GraphKV 最值得记住的点不是“图方法本身”，而是它对 KV eviction 范式的修正：

- 现有方法大多已经能估计 token importance；
- 真正的问题在于，importance-only 的静态 top-k 很容易保留一堆相似 token；
- GraphKV 通过图上的 decay propagation，把“关系感知”这一层补了进来。

因此，这篇论文提供的不是一个新的单点启发式，而是一种更通用的视角：

`KV eviction 不该只保留高分 token，还该主动压低与高分 token 过于相似的候选。`

## 我的理解
我觉得这篇论文最有价值的地方，是它把 `importance` 和 `diversity` 的矛盾讲得非常清楚。

很多 KV cache 方法默认认为：
- 只要 score 高，就值得保留。

但 GraphKV 其实是在说：
- 高分不等于高边际收益；
- 如果两个 token 都很高分，但表达的内容几乎一样，那么第二个 token 的边际价值可能很低。

从这个角度看，GraphKV 和 `MixKV` 这类“importance + diversity”路线其实有很强的共通性，只不过：
- `MixKV` 是直接在复合打分里显式联合优化 importance 和 diversity；
- `GraphKV` 则是把已有 importance 当输入，再用图传播做一个关系感知的重排。

如果把它放回整个 KV cache 研究脉络里，我会把它理解成：
- 对 `SnapKV / PyramidKV / KNorm` 一类静态选择方法的补丁；
- 一个非常自然的“从排序到关系排序”的升级；
- 一种低侵入、易插拔、但很有启发性的后处理框架。

## 相关链接（双向）
- [[KV Cache]]
- [[H2O✅]]
- [[SnapKV✅]]
- [[MixKV]]
