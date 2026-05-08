---
created: 2026-04-15
published: 2024-12-01
type: paper
status: 未读
tags:
  - ArkVale
  - SparseAttention
  - KVCache
  - RecallableEviction
  - LongContext
  - PageBased
aliases:
  - ARKVALE
  - ArkVale
summary: 提出 page-based、可召回的 KV 管理框架：把 KV 按页组织，异步备份到外存，并用 key 的 bounding-volume 生成轻量 digest，在每步解码前动态估计页重要性、召回关键页、淘汰非关键页，以更稳地应对“重要性会反转”的长上下文推理。
pdf-url: https://proceedings.neurips.cc/paper_files/paper/2024/file/cd4b49379efac6e84186a3ffce108c37-Paper-Conference.pdf
source-url:
  - https://proceedings.neurips.cc/paper_files/paper/2024/file/cd4b49379efac6e84186a3ffce108c37-Paper-Conference.pdf
  - https://nips.cc/virtual/2024/poster/96635
  - https://github.com/pku-liang/ArkVale
---

# ARKVALE: Efficient Generative LLM Inference with Recallable Key-Value Eviction

## PDF
- [NeurIPS 2024 PDF](https://proceedings.neurips.cc/paper_files/paper/2024/file/cd4b49379efac6e84186a3ffce108c37-Paper-Conference.pdf)

## Abstract
ArkVale 讨论的不是“如何更激进地删 KV”，而是“删掉以后还能不能低成本找回来”。作者认为，很多 KV eviction 工作默认 token 的重要性满足 locality 或 persistence，也就是最近 token 往往更重要、过去重要的 token 往往会持续重要。但论文观察到一个更麻烦的现象：某些 token 在当前步看似不重要，被淘汰后，可能在若干步之后重新变得关键。若采用不可逆淘汰，这类信息一旦删错就无法补救。

ArkVale 的核心设计是 recallable eviction：
- 把 KV cache 按 page 组织，而不是按单 token 零散管理；
- 每个 page 填满后，异步备份到外部内存（如 CPU memory）；
- 同时把这一页的 keys 压缩成一个极小的 digest；
- 每步解码前，利用当前 query 与各页 digest 的关系来估计“哪些页可能重新重要”；
- 把重要页召回到 GPU，把不重要页换出，并仅对 top-ranked pages 做注意力计算。

论文报告：在 `2k~4k` cache budget 下，长上下文任务精度损失很小；解码延迟最高可提升 `2.2x`，平均约 `1.7x`；batch throughput 最高可提升 `4.6x`，平均约 `3.5x`。

## 1 Introduction

### 1.1 问题背景
随着上下文长度从 `16k` 扩展到 `32k`、`128k` 乃至更长，KV cache 已成为推理阶段最直接的瓶颈之一。对每个新生成 token，query 都要访问全部历史 KV：
- 历史越长，attention 的 memory access 越大，延迟越高；
- KV 越大，占用显存越多，能容纳的 batch size 越小，吞吐越低。

因此，长上下文推理的瓶颈不是只在算力上，也在于“是否还装得下、搬得动、读得快”。

### 1.2 现有方法的默认假设
已有 KV cache eviction 方法大致依赖两类经验：
- `locality`：最近 token 更可能重要；
- `persistence`：曾经重要的 token 未来仍可能继续重要。

于是方法通常会选择：
- 保 recent tokens；
- 保历史 attention 分数高的重要 token；
- 或两者结合。

这类方法的共同点是：一旦某些 token 被认定为“不重要”，就会永久删掉，后续无法恢复。

### 1.3 ArkVale 的关键观察
论文进一步指出，token 重要性并不是单调变化的，而是可能随解码过程动态反转：
- 某些 token 在当前步对 query 没什么贡献；
- 但随着后续生成展开，新 query 语义变化，它们又会重新变得关键。

这意味着：
- “当前不重要”不等于“永远不重要”；
- 不可召回的 eviction 在长上下文、多跳依赖、检索式生成中风险很高。

因此，ArkVale 不是简单优化“删谁”，而是把问题改写成：
- 现在 GPU 上该保留哪些页；
- 被换出的页如何低成本备份；
- 后续如何根据当前 query 判断是否应该把它们召回。

## 2 Related Work
论文把相关路线大致放成三类：

### 2.1 训练期改造方法
如 `MQA`、`GQA`、`RWKV`、`RetNet`、`Mamba`、稀疏注意力架构等。这类方法会改变模型结构或训练过程，能够从根源上减少 KV 开销，但代价是需要训练或微调。

ArkVale 的定位不同：它是 `training-free` 的推理期方案，直接作用于已有模型。

### 2.2 推理期 KV eviction 方法
如 `StreamingLLM`、`LM-Infinite`、`H2O`、`Scissorhands`、`TOVA`、`FastGen`、`Keyformer`、`Q-Hitter` 等。

这些方法大都属于：
- 保最近；
- 保高重要度；
- 用历史统计来估计未来重要度。

ArkVale 对它们的批评很明确：
- 它们默认“过去不重要的，以后也不重要”；
- 但如果未来 query 改变依赖方向，已删 token 无法恢复。

### 2.3 稀疏注意力但不缩 KV 容量的方法
如 [[Quest-Query-Aware-Sparsity-for-Efficient-Long-Context-LLM-Inference]]、[[SparQ-Attention-Bandwidth-Efficient-LLM-Inference]]、[[IceFormer-Accelerated-Inference-with-Long-Sequence-Transformers-on-CPUs]] 等。它们能减少部分 attention 计算，但往往仍要求全量 KV 驻留在内存中，因此不一定缓解容量瓶颈。

ArkVale 的差异在于，它既想减少 attention 访问，也想真正控制 GPU 上驻留的 KV 体量。

## 3 Background

### 3.1 注意力与生成阶段
设
$$
Q \in \mathbb{R}^{s_q \times d}, \quad
K \in \mathbb{R}^{s_{kv} \times d}, \quad
V \in \mathbb{R}^{s_{kv} \times d}
$$
则标准注意力计算为
$$
S = \frac{QK^\top}{\sqrt{d}}, \quad
P = \operatorname{softmax}(S), \quad
O = PV
$$

其中 $P_{i,j}$ 可以理解为第 $i$ 个 query 对第 $j$ 个 key/value token 的依赖强度。

在生成阶段，每一步通常有：
$$
s_q = 1, \quad s_{kv} = \text{历史 token 数} + 1
$$
因此历史越长，每一步都要访问更多 KV。

### 3.2 长上下文带来的显存与访问开销
论文给出一个很直接的量纲估计：对 batch size 为 $b$、层数为 $l$、历史长度为 $s$、hidden size 为 $h$ 的解码步，KV cache 大致带来：
$$
\text{memory access} \propto 4bsh
$$
$$
\text{memory footprint} \propto 4blsh
$$

这里默认数据类型是 `float16`。重点不在常数，而在于它们都随历史长度 $s$ 线性增长。

论文展示：对 LongChat-7B 一类模型，在较长上下文下，KV 读取本身就会显著拖慢单步 latency，而显存占用也会很快限制 batch size。

## 4 Key Observation: Token Importance Is Dynamic
ArkVale 最关键的不是某个工程技巧，而是这条经验事实：

- token 的重要性并非严格持久；
- “重要”与“不重要”可以在不同 decoding steps 之间切换。

这和很多历史分数驱动的方法形成对照：
- 如果只根据过去 attention 得分决定永久保留集合，那么一旦早期判断错误，后续无法修正；
- 对长文档问答、长链路推理、多段代码生成这类任务，模型可能在某一阶段暂时不看某段上下文，但在后面重新回到那里。

因此，作者认为理想策略应该满足：
- GPU 上只保留当前最值得计算的 KV；
- 但被换出的历史页不能彻底消失，而要保留“召回路径”。

这也是 ArkVale 名称里 `Recallable Eviction` 的核心含义。

## 5 ARKVALE

### 5.1 Page-based KV 管理
ArkVale 借鉴 [[Efficient-Memory-Management-for-Large-Language-Model-Serving-with-PagedAttention|vLLM]] 的 page/block 思路，把连续 token 的 KV 组织成固定大小的 pages，而不是逐 token 管理。

这么做有几个好处：
- 管理粒度更适合系统实现；
- evict / recall 可以以 page 为单位进行，降低碎片化与调度复杂度；
- CPU 备份与 GPU 驻留之间可以自然形成两级存储。

于是，系统中每个 page 会处于某种状态：
- 驻留在 GPU，可直接参与 attention；
- 已备份到 CPU，但当前不在 GPU；
- 通过 digest 仍保留一个很小的近似表示，供后续估计重要性。

### 5.2 异步备份：被换出的页不是真删
当一个 KV page 被填满后，ArkVale 会做两件事：
- 异步把该页复制到 CPU memory，作为完整备份；
- 同时为该页构造一个非常小的 digest。

这里“异步”很重要，因为作者不希望把备份过程放到每步解码的关键路径上。理想情况是：
- 页一旦形成，就在后台完成备份；
- 前台解码继续进行；
- 到未来真的需要召回时，CPU 里已经有完整原始页。

这让 ArkVale 和普通 eviction 的根本区别变得清晰：
- 普通 eviction：删掉即丢失；
- ArkVale：GPU 侧换出，但外存中仍保留完整可恢复版本。

### 5.3 Digest：用 bounding-volume 压缩整页 key
如果每步都拿当前 query 去和 CPU 中所有 token 的完整 keys 比较，那成本依然太高。ArkVale 的解决办法是：不给每个被换出 token 保留完整比较对象，而是给每一页保留一个很小的摘要 `digest`。

论文使用的是基于 key 向量的 `bounding-volume` 思路。直观理解：
- 一页里有很多 key 向量；
- 用一个包围这些 key 的紧凑几何体来近似这整页的分布；
- 当当前 query 到来时，可以快速估计“它是否有可能与这一页中的某些 key 高相关”。

这相当于用页级近似替代 token 级精确比较，把代价从“扫描所有历史 token”降到“先筛选少量可能重要的页”。

### 5.4 Importance Estimation：先判页，再决定召回
每步解码前，系统会拿当前 query 与每个 page 的 digest 进行比较，估计该页的重要性分数。

这里的逻辑可以理解为两层：
- `粗筛`：当前 query 是否有理由去关注这一页；
- `决策`：如果有，就把它召回或继续保留；如果没有，就不让它占 GPU 预算。

于是，ArkVale 每步会动态做三件事：
- 估计各页重要性；
- 召回重要但当前不在 GPU 的页；
- 换出不再重要的页。

最后，仅选择 top-ranked pages 参与真正的 attention 计算。

这一步很关键，因为 ArkVale 不是“把所有备份页都召回”，而是：
- 召回只是候选恢复机制；
- 真正参与计算的仍是预算内最有价值的一小部分页。

### 5.5 与传统 important-token eviction 的本质差异
很多重要性方法的对象是 `token`，ArkVale 的对象首先是 `page`。这带来两层意义：

第一层是系统意义：
- 页是更适合内存管理、异步搬运、批量 recall 的粒度。

第二层是建模意义：
- ArkVale 不要求在每一步精确知道“哪个 token 最重要”；
- 它只需要先知道“哪一页值得重新拿回来”。

这种 page-level recall 机制比 token-level 永久删除要宽松得多，更像一种两级缓存系统，而不只是启发式裁剪。

### 5.6 可以把 ArkVale 看成什么
从抽象上看，ArkVale 很像把 KV cache 分成三层：
- `GPU resident KV`：当前真正参与 attention 的工作集；
- `CPU backup KV`：已经换出但仍可恢复的完整历史；
- `digest index`：极小的页级摘要，用于决定是否恢复。

因此它并不是单纯的 “keep recent” 或 “keep important”，而是：
- `keep active working set on GPU`
- `keep recoverable history on CPU`
- `keep cheap searchable summary for all pages`

这个视角很有帮助，因为 ArkVale 更像“页式存储管理 + query-aware recall”，而不只是一个注意力分数启发式。

## 6 为什么 Bounding-Volume 这个设计重要
ArkVale 里最值得记住的技术点不是“CPU 备份”，而是“如何在不访问完整页的情况下判断其是否值得召回”。

如果没有 digest：
- 所有被换出页都必须重新读取才能判断价值；
- recall 判定本身就会变成巨大的 I/O 开销；
- 那么 recallable eviction 会在工程上失去意义。

而有了 bounding-volume digest 后：
- 页的重要性评估可以先在摘要上完成；
- 只有高分页才需要进入真正召回流程；
- 大量不相关页可在摘要阶段被过滤掉。

这使 ArkVale 的召回机制从“理论可恢复”变成“实践可用”。

## 7 Experiments

### 7.1 评测设置
论文在多种长上下文任务上比较 ArkVale 与多种基线方法，并关注两类指标：
- 质量：长上下文任务精度 / 成功率 / 生成表现；
- 效率：解码 latency 与 batching throughput。

作者主要测试不同 cache budget，如 `512`、`1024`、`2048`、`4096`，并在不同上下文长度下观察表现。

### 7.2 整体质量结论
论文的主结论是：在 `2k~4k` 的 cache budget 下，ArkVale 在多类长上下文任务上都能保持很小的精度损失。

这说明 recall 机制确实缓解了“删错后不可恢复”的问题。也就是说，ArkVale 不只是把 budget 做小，而是在小 budget 下尽量保持与 full-cache 接近的效果。

从研究意义上，这一点比单纯速度提升更重要，因为它证明：
- 未来依赖的 token 不一定需要一直驻留在 GPU；
- 但它们最好保留在可恢复层，而不是被永久丢弃。

### 7.3 Passkey Retrieval 一类任务上的表现
论文特别强调，在 passkey retrieval 这类强依赖远距召回的任务上，ArkVale 在多个上下文长度与预算配置下都能保持很高成功率，文中提到可维持 `95%+` 的 retrieval accuracy。

这类任务很适合体现 ArkVale 的价值，因为它正好要求模型在很长历史中重新找到之前出现的关键信息。

### 7.4 延迟与吞吐
效率方面，ArkVale 的结论比较强：
- 解码延迟最高提升 `2.2x`；
- 平均延迟提升约 `1.7x`；
- batch throughput 最高提升 `4.6x`；
- 平均 throughput 提升约 `3.5x`。

这里的收益来自两方面：
- GPU 上真正参与 attention 的 KV pages 更少，因此计算与内存访问减少；
- 显存占用下降后，可承载更大的 batch。

### 7.5 Latency Breakdown：额外开销值不值得
ArkVale 相比纯 eviction 多了三项额外工作：
- importance estimation；
- page selection / eviction decision；
- page recall from CPU memory。

论文专门做了 latency breakdown，说明虽然这些步骤增加了额外路径，但总体仍显著优于 full-cache 推理。换句话说：
- recall 不是免费的；
- 但只要 digest 足够轻量、召回足够克制，总收益仍是正的。

这也侧面说明 ArkVale 的工程重点不是“有没有 recall”，而是“recall 的判定和执行是否足够省”。

## 8 我对这篇方法的理解

### 8.1 它解决的是 H2O / SnapKV 之前没正面处理的问题
像 `H2O` 这类方法擅长回答：
- 哪些 token 长期重要；
- 如何在固定预算里在线保留 heavy-hitter + recent。

像 `SnapKV` 这类方法擅长回答：
- 对 prompt KV，能否在生成前先压缩；
- 哪些 prefix 位置大概率会在后续持续被关注。

而 ArkVale 处理的是一个更“反直觉”的问题：
- 如果 token 重要性会回潮，那之前删掉的信息怎么办？

所以它的新增视角不是“更准地删”，而是“删了也能找回来”。

### 8.2 它不像纯算法论文，更像系统论文
ArkVale 的关键词很多都很系统化：
- page；
- asynchronous copy；
- external memory backup；
- digest；
- recall。

这说明它和单纯用 attention score 做 top-k 不一样。它实际上是在把 KV cache 做成一个分层存储系统，而不是只做一个打分规则。

如果用操作系统类比，它有点像：
- GPU KV 是主存工作集；
- CPU 备份是换出区；
- digest 是轻量页表索引；
- 当前 query 则像访问模式的动态信号。

### 8.3 这篇工作的 trade-off 很清楚
ArkVale 也不是没有代价。它引入了新的复杂性：
- 要维护 GPU/CPU 双份生命周期；
- 要为每页构造 digest；
- 要承担 recall 的额外传输与调度开销；
- page 级管理可能不如 token 级方法细粒度。

因此，它适合的不是“任何场景都替代简单 eviction”，而是：
- 长上下文足够长；
- 远距依赖确实存在；
- 永久删错的风险高；
- CPU 外存与异步拷贝机制可用。

换句话说，ArkVale 更像高质量长上下文服务场景下的稳健方案，而不是最简单的轻量启发式。

## 9 与 Ada-KV / Sparse Attention 语境的关系
如果把 KV 优化方法按思想分层，可以粗略分成：
- `压缩 / 淘汰`：减少驻留的 KV；
- `稀疏访问`：不是所有驻留 KV 都参与每步注意力；
- `分层存储 / 可召回`：当前不驻留的 KV 也保留恢复路径。

ArkVale 主要属于第三类，但和前两类并不冲突。

它和 Ada-KV / 稀疏注意力路线的关系可以理解为：
- Ada-KV 更关注“有限预算下该留哪些 token”；
- 稀疏注意力更关注“attention 时该算哪些位置”；
- ArkVale 更关注“当前不在 GPU 的历史，如何在未来需要时重新进入工作集”。

所以 ArkVale 补的是“历史被误删之后怎么办”这一层，而不是直接替代所有 top-k / sparse attention 方法。

## 10 可以记住的三句话
- ArkVale 的核心不是 eviction，而是 `recallable eviction`。
- 它不是直接给 token 打分，而是先把 KV 做成 `page + backup + digest` 的分层系统。
- 它解决的核心问题是：`token importance is dynamic, so eviction should be reversible when possible`。

## 11 Appendix Notes
附录主要补充了更多实验、实现细节与 latency breakdown，帮助说明 recall / estimate / select 的额外开销在整体上是可控的。

## 相关链接（双向）
- [[KV Cache]]
- [[H2O✅]]
- [[SnapKV✅]]
- [[Transformers-are-Multi-State-RNNs-TOVA]]
- [[Ada-KV✅]]
