---
created: 2026-04-28
published: 2023-09-12
type: paper
status: 已读
tags:
  - vLLM
  - PagedAttention
  - KVCache
  - MemoryManagement
  - LLMServing
  - HierarchicalMemory
aliases:
  - vLLM
  - PagedAttention
  - Efficient Memory Management for Large Language Model Serving with PagedAttention
summary: 提出 PagedAttention，并在其上构建 vLLM serving system：把 KV cache 按固定大小 block/page 管理，支持按需分配、近零碎片和块级共享，从系统层显著提升 LLM serving 吞吐。
pdf-url: https://arxiv.org/pdf/2309.06180
source-url:
  - https://arxiv.org/abs/2309.06180
  - https://arxiv.org/pdf/2309.06180
  - https://github.com/vllm-project/vllm
  - https://vllm.ai/blog/vllm
---

# Efficient Memory Management for Large Language Model Serving with PagedAttention

## PDF
- [arXiv PDF](https://arxiv.org/pdf/2309.06180)

## Abstract
这篇论文的核心不是提出一种新的 token 重要性评分，也不是做 KV 量化，而是把 LLM serving 中最被低估的瓶颈之一单独拎出来：`KV cache memory management`。

作者指出，高吞吐 serving 需要把很多请求同时 batch 起来，但现实里 KV cache 有三个麻烦特征：
- 很大；
- 会随着生成动态增长和收缩；
- 多个请求的长度和生命周期高度不规则。

如果沿用传统深度学习系统“为每个请求预留连续大块显存”的思路，就会产生严重的：
- `internal fragmentation`
- `external fragmentation`
- 以及无法共享公共前缀 KV 的冗余复制

论文的解决方案是 `PagedAttention`：借鉴操作系统虚拟内存分页思想，把每个请求的 KV cache 切成固定大小的 blocks/pages，用 block table 把“逻辑连续”的 token 块映射到“物理上不连续”的显存块。基于这个机制，作者构建了 `vLLM` serving system，实现：
- 近零 KV cache 浪费；
- 跨序列 / 跨请求的 block 共享；
- 更大的 batch size 与更高吞吐。

论文摘要级结论是：
- 在与 `FasterTransformer`、`Orca` 相同延迟水平下，吞吐提升约 `2x-4x`；
- 对更长序列、更大模型和更复杂解码算法，收益更明显。

## 1 Introduction

### 1.1 这篇论文真正解决的是什么问题
很多高效推理论文默认瓶颈在：
- attention FLOPs；
- 模型参数带宽；
- 或 token 选择策略。

但 vLLM 这篇论文指出，在实际 LLM serving 中，一个更基础也更硬的瓶颈是：
- `KV cache 怎么放`
- `怎么长`
- `怎么共享`
- `怎么让它别把 batch size 卡死`

尤其在 autoregressive decoding 阶段：
- 模型参数常驻显存；
- 每一步只新增很少计算；
- 但需要不断读写越来越大的历史 KV cache；
- 整个过程往往是 `memory-bound` 而不是 `compute-bound`。

因此，提高 serving 吞吐的关键不只是“每步更快”，还包括“让更多请求能同时活在显存里”。

### 1.2 论文中的量纲观察
论文以 `LLaMA-13B` 在 `A100 40GB` 上为例说明显存分布：
- 约 `65%` 显存用于模型参数；
- 接近 `30%` 用于动态的 request states，也就是 KV cache；
- 剩下很小一部分用于激活等临时张量。

这意味着，在实际 serving 时，决定 batch size 上限的关键变量往往不是参数，而是 KV cache。

### 1.3 现有系统为什么低效
论文指出，已有 serving 系统通常把每个请求的 KV cache 存成一整块连续内存。这种做法对传统深度学习张量很自然，但对 KV cache 很不合适，因为 KV cache：
- 长度不可预知；
- 生命周期不一致；
- 会边生成边增长；
- 请求之间长短差异很大。

结果会出现两类碎片：

1. `Internal Fragmentation`  
给一个请求按最大长度预留了大块空间，但真实生成长度远小于上限，块内大量槽位永远不会被用到。

2. `External Fragmentation`  
不同大小的预留块反复申请/释放后，把可用显存切得很碎，明明总剩余显存不少，却放不下新的连续大块请求。

论文实测还给出一个很有冲击力的结果：已有系统里，真正用于“存储实际 token states”的 KV cache 内存占比平均只有 `20.4% - 38.2%`。

也就是说，大量显存都浪费在：
- 预留但未使用的空间；
- 以及碎片导致的管理损耗。

### 1.4 除了碎片，还有共享机会被浪费
在并行采样、beam search、多个输出分支等场景里，很多序列共享同一个 prompt 前缀。

按常理，这部分 KV 应该复用。  
但如果每条序列的 KV 都放在自己独占的连续大块里，就很难做细粒度共享，只能重复存同样的 prompt states。

因此，作者认为一个真正高效的 LLM serving 系统应该同时解决：
- 动态增长的分配问题；
- 碎片问题；
- 前缀共享问题。

## 2 Core Idea: PagedAttention

### 2.1 从操作系统分页得到的灵感
PagedAttention 的灵感直接来自 OS 虚拟内存：
- 把连续逻辑地址切成固定大小 pages；
- 物理内存不要求连续；
- 用 page table 维护逻辑到物理的映射。

论文把这个思想搬到 KV cache 上：
- `tokens` 类比字节；
- `KV blocks/pages` 类比内存页；
- `request/sequence` 类比进程；
- `block table` 类比页表。

### 2.2 Block 化的 KV cache
PagedAttention 不再把一个请求的全部 KV 存成一整块连续 tensor，而是：
- 把每个 sequence 的 KV cache 切成固定大小 blocks；
- 每个 block 存固定数量 token 的 keys / values；
- 逻辑上这些 block 按 token 顺序排列；
- 物理上它们可以分散在任意空闲显存位置。

这样带来三个直接好处：

1. `按需分配`
- 请求生成新 token 时，只在当前 block 满了以后再申请下一个 block
- 不需要一开始就为最大长度预留整块空间

2. `消除外部碎片`
- 所有 block 大小相同
- allocator 不再面对各种不同尺寸的大块分配

3. `把内部碎片压到最小`
- 浪费只会发生在 sequence 的最后一个未填满 block
- 论文和官方博客都强调，这种浪费在实践里非常小，通常低于 `4%`

### 2.3 Block Table：逻辑连续，物理离散
PagedAttention 的关键不是“切块”本身，而是：
- 逻辑上序列仍是连续的 token 历史；
- attention kernel 通过 block table 找到这些 token 所在的物理块。

因此，虽然显存布局不连续，但模型看来仍像在读一个正常的历史 KV 序列。

这也是 `PagedAttention` 这个名字的真正含义：
- attention 运行在“分页化的 KV 存储”之上。

### 2.4 PagedAttention kernel 要解决什么
一旦 KV blocks 物理上不连续，普通 attention kernel 就不够用了，因为它默认输入张量是整齐连续排布的。

PagedAttention kernel 的作用就是：
- 根据 block table 找出当前 sequence 对应的物理 blocks；
- 正确抓取这些 blocks 中的 keys / values；
- 在非连续物理存储上仍然完成正常的自注意力计算。

所以它既是内存管理设计，也是内核执行设计。

## 3 Memory Sharing

### 3.1 为什么共享很重要
在 serving 场景里，一个请求往往不止产生一条输出：
- parallel sampling
- beam search
- 多候选解码

这些序列通常共享同一个 prompt 前缀。如果每条分支都复制整份前缀 KV，显存开销会非常夸张。

### 3.2 Block 级共享
PagedAttention 自然支持共享，因为不同 sequence 的逻辑 block 可以映射到同一个物理 block。

这意味着：
- 多个分支序列可共享同一段 prompt KV；
- 不需要真的复制这部分物理内存；
- 直到某个分支需要写入不同内容时再分裂。

### 3.3 Copy-on-Write
为了安全共享，系统需要：
- 给物理 block 维护 reference count；
- 当多个 sequence 共享同一 block 时先只读共享；
- 若某个 sequence 后续要写，就执行 `copy-on-write`。

这和操作系统的共享页机制非常像。

论文指出，这种 memory sharing 对复杂解码算法尤其有效，能显著降低其额外显存成本。官方博客里给出的量级是：
- 复杂采样方法的内存开销最高可降低约 `55%`
- 进而带来最高约 `2.2x` 吞吐提升

## 4 vLLM System Design

### 4.1 论文名、方法名、系统名三者关系
这里最容易混淆，所以单独写清楚：

- 论文标题：`Efficient Memory Management for Large Language Model Serving with PagedAttention`
- 方法名：`PagedAttention`
- 系统名：`vLLM`

也就是说，论文提出的是 `PagedAttention` 这套分页式 KV 管理与 attention 机制，并在其上构建了 `vLLM` 这个 serving engine。

### 4.2 vLLM 不只是一个 kernel
vLLM 不是单独一个 attention 算子，而是一整套 serving system。论文里强调它包含：
- block-level memory management
- 与之协同的 request scheduling
- distributed serving support

所以它的贡献是“系统 + 内核 + 内存管理”协同设计，而不是单点优化。

### 4.3 与 iteration-level scheduling 的关系
论文背景部分还专门回顾了 iteration-level scheduling：  
即 serving 系统不是等一个完整请求跑完再换下一批，而是：
- 每个 decoding iteration 后重新组织 batch；
- 已完成的请求离开；
- 新请求可以尽快进入。

vLLM 建立在这种更细粒度的 serving 思路之上，而 PagedAttention 让这种动态批处理更可行，因为：
- KV cache 分配足够灵活；
- 请求长度不一致带来的显存浪费更小；
- 系统可以容纳更多活跃请求。

### 4.4 这篇论文其实是在做“KV cache OS 化”
如果抽象地看，vLLM 做的事情几乎就是把 KV cache 管理“操作系统化”：
- fixed-size blocks
- logical-to-physical mapping
- demand allocation
- reference counting
- copy-on-write

这也是为什么它后来会成为很多后续 KV cache 论文的系统基础语境。

## 5 Experiments

### 5.1 主要对比对象
论文主要将 vLLM 与当时较强的 serving 系统对比，包括：
- `FasterTransformer`
- `Orca`

重点比较维度是：
- throughput
- latency
- memory efficiency
- 对复杂 decoding 场景的支持

### 5.2 主结果
论文摘要中的核心结论是：
- 在相同延迟水平下，vLLM 吞吐提升约 `2x-4x`
- 长序列、更大模型、更复杂解码算法时收益更明显

这个结果很关键，因为它说明：
- 即使模型本身不变；
- 即使不改训练；
- 仅通过更合理的 KV cache 管理，就能带来系统级大幅提效。

### 5.3 为什么它能更快
速度提升不是因为某一步 attention 算得“数学上更省”，而主要来自：
- 显存浪费更少；
- batch size 可以做得更大；
- prefix sharing 降低冗余；
- GPU 在更多请求并行下利用率更高。

也就是说，vLLM 的加速本质上是：
- `memory efficiency -> larger batch -> higher serving throughput`

### 5.4 论文里最值得记住的一组数字
对这篇论文，我觉得最值得记住的是三组数字：

1. `已有系统真实 token states 占 KV 内存只有 20.4% - 38.2%`
说明碎片与过度预留非常严重。

2. `PagedAttention 的实际浪费通常低于 4%`
说明分页式管理在这里几乎把碎片问题消掉了。

3. `vLLM 相比 SOTA serving system 吞吐提升 2x-4x`
说明这不是“小修小补”的工程优化，而是系统层结构性改进。

## 6 我对这篇工作的理解

### 6.1 它不属于“KV 压缩”，而属于“KV 管理”
这篇论文经常和 H2O、SnapKV、ArkVale 一起被提到，但它们解决的问题层级其实不同。

H2O / SnapKV / Ada-KV / ArkVale 在问：
- 哪些 KV 该留？
- 哪些 KV 该删？
- 有限预算如何分配？

vLLM 在问的是：
- 即便一个 KV 都不删，能不能把这些 KV 放得更合理？
- 能不能更少碎片、更好共享、更高吞吐？

所以它是 `memory management / serving system` 路线，不是 `eviction / compression` 路线。

### 6.2 它的影响力远大于论文表面看起来的“内存分配优化”
如果只看标题，可能会觉得它只是工程上的 allocator 优化。但实际上它改变了很多后续工作默认的实现语境：
- page/block 成了自然的 KV 管理粒度；
- 很多后续 block-wise eviction/offload/recall 方法都默认参考这种布局；
- “KV cache 不必物理连续” 这个假设被系统化确立了。

比如你在 `ArkVale` 里看到的 page/block 叙述，就明显继承了这一系统语境。

### 6.3 这篇论文的本质贡献是把 serving bottleneck 重新定位了
它最重要的贡献之一其实是视角：
- 把瓶颈从“模型算不动”转成“KV 放不下、放不好、共享不了”

一旦这么看，后续很多路线都会自然展开：
- page-based eviction
- GPU/CPU/disk 分层 offload
- block-wise recall
- block-level quantization
- serving-aware budget scheduling

所以 vLLM 更像很多后续 KV 系统论文的“基础设施论文”。

## 7 与相关工作的关系

### 7.1 和 ArkVale 的关系
`ArkVale` 借鉴的正是 vLLM 的 page/block 管理直觉。  
不同在于：
- vLLM 不删 KV，只高效管理；
- ArkVale 在 page-based 管理上再加入 recallable eviction。

所以可以把 ArkVale 看成：
- `vLLM-style paged KV layout`
- 再叠加 `importance estimation + recall`

### 7.2 和 RetrievalAttention / LeoAM 的关系
`RetrievalAttention`、`LeoAM` 这类方法都进一步走向：
- 不只是把 KV 放好；
- 还把 KV 分层到 CPU / disk 或索引系统中；
- 按需检索或传输少量关键部分。

而 vLLM 更像是它们之前的系统前提：
- 先解决 GPU 内的动态块管理；
- 再讨论更复杂的外存层次。

### 7.3 和 H2O / SnapKV / Ada-KV 的关系
这些方法主要解决“KV selection”问题；  
vLLM 解决“KV allocation / serving”问题。

两者不冲突，甚至非常适合组合：
- 上层方法决定留哪些 KV；
- vLLM 负责把留下来的 KV 更高效地存、共享、调度。

## 8 可以记住的三句话
- `PagedAttention` 是方法名，`vLLM` 是建立在它之上的 serving system 名。
- 这篇论文解决的不是“删哪些 KV”，而是“完整 KV cache 如何近零浪费地管理与共享”。
- 它的重要性在于把 `page/block-based KV memory management` 变成了后续长上下文系统工作的基础语境。

## 相关链接（双向）
- [[KV Cache]]
- [[ArkVale]]
- [[Breaking-the-Boundaries-of-Long-Context-LLM-Inference]]
- [[RetrievalAttention]]
