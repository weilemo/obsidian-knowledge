---
created: 2026-04-30
published: 2026-03-17
tags:
  - paper
  - KVCache
  - Quantization
  - VectorQuantization
  - LongContext
aliases:
  - VQKV
  - VQKV: High-Fidelity and High-Ratio Cache Compression via Vector-Quantization
status: 已读
type: paper
topic: KV cache compression
summary: VQKV 提出一种 training-free 的 KV cache 压缩方案，用残差向量量化替代逐元素量化或低秩近似，在 LLaMA3.1-8B 上实现 82.8% 压缩率，同时保留 98.6% LongBench 性能，并把相同显存预算下的可生成长度提升到 4.3 倍以上。
pdf: /Users/moweile/Obsidian/Knowledge/Research/Paper/KV_cache/50_量化与编码压缩/Attachments/arxiv_2603.16435.pdf
pdf-url: Attachments/arxiv_2603.16435.pdf
github-url: https://github.com/LUMIA-Group/VQKV
source-url:
  - https://arxiv.org/abs/2603.16435
  - https://doi.org/10.48550/arXiv.2603.16435
  - https://github.com/LUMIA-Group/VQKV
  - https://huggingface.co/LuckyOrz/vqkv_llama3.1-8B
---

# VQKV

## PDF

- [本地 PDF](/Users/moweile/Obsidian/Knowledge/Research/Paper/KV_cache/50_量化与编码压缩/Attachments/arxiv_2603.16435.pdf)
- [arXiv](https://arxiv.org/abs/2603.16435)
- [GitHub](https://github.com/LUMIA-Group/VQKV)
- [Hugging Face](https://huggingface.co/LuckyOrz/vqkv_llama3.1-8B)

## 一句话摘要

这篇工作认为，现有 KV cache 压缩大多在“压得狠”和“保真度高”之间二选一；VQKV 的核心思路是把整段 key/value 向量映射成少量离散 code，而不是逐元素量化，从而用更高的信息密度完成 cache 压缩。

## Abstract

作者想解决的是一个很现实的问题：长上下文推理里，KV cache 已经成了显存瓶颈，但现有方法要么是 token eviction，直接删上下文；要么是低秩近似或逐元素量化，虽然压缩了数值表示，但在高压缩比下往往明显伤害精度。VQKV 的出发点是，KV cache 本身具有结构性，可以用向量量化而不是标量量化来编码。

具体做法上，它使用残差式向量量化，把一个高维 key/value 向量拆成多个 codebook 的离散索引，只存整数 code，在需要注意力计算时再按需重构。这样做的结果是：在 LLaMA3.1-8B 上做到 `82.8%` 压缩率时，LongBench 仍保留原模型 `98.6%` 的性能，而且在相同显存预算下可支持 `4.3×` 以上的生成长度。

## 1 Introduction

作者的判断很清楚：KV cache 压缩并不是普通的激活压缩问题，因为它要同时满足两件事：

1. 压缩率要足够高，不然长上下文场景里根本省不出多少显存。
2. 重构误差要足够小，不然解码阶段的注意力会持续积累偏差。

现有路线各有明显短板：

- token 级裁剪方法如 SnapKV、H2O，本质上是在丢信息，适合“重要性筛选”，但不适合需要完整上下文的任务。
- 低秩近似方法如 ASVD、Palu，更像把 KV 映射到低维子空间，高压缩比下容易损失细粒度语义。
- 标量量化方法如 KIVI、KVQuant，虽然实现直接，但逐元素编码的信息密度不够高，在极端压缩下重构质量会掉得比较明显。

所以这篇 paper 的核心切口是：既然 KV 是向量结构，那就应该把“整段向量”当作编码基本单位，而不是把每个浮点数独立压缩。

## 2 Related Work

作者实际在对比三类方法：

- **Token eviction / selection**：通过分数或启发式规则删除一部分历史 token，优点是快，缺点是信息不可恢复。
- **Dimension reduction / low-rank approximation**：通过子空间投影减少表示维度，优点是结构简单，缺点是高压缩比下保真性一般。
- **Scalar quantization**：按元素做 2bit/4bit 等量化，优点是工程成熟，缺点是编码粒度太细，难以充分利用向量内部的相关性。

VQKV 属于第四类思路：**vector quantization for KV cache**。它不删 token，不把表示投到更低维，而是学习一组离散原型向量，用索引替代原始浮点向量。

## 3 Methodology

### 3.1 Core Idea

VQKV 的基本想法是：把每个 key/value 向量表示为多个 codebook 条目的和，只保存这些条目的索引。推理时需要用到对应缓存，再把它们从 code 重构出来。

相比标量量化，这样的好处是单个索引携带的是“一个向量模式”的信息，而不是单个数值等级，因此单位比特能表示更多结构信息。

### 3.2 Residual Simple Vector Quantization

作者采用的是残差向量量化（RSimVQ）。对输入向量 $x \in \mathbb{R}^D$，第 $i$ 个 codebook 中寻找最接近的原型向量，并用残差继续交给后续 codebook 拟合。

对应写法可以概括成：

$$
\hat{x} = \arg\min_{q \in \{q_1, \dots, q_S\}} \|x - Wq\| \equiv W q_z
$$

其中 $W$ 是投影矩阵，$q_z$ 是被选中的 codeword。选完之后更新残差：

$$
x \leftarrow x - \hat{x}, \quad z_i \leftarrow z
$$

最终的重构向量由多个 codebook 的结果相加得到：

$$
\hat{x} = \sum_i Q_i[z_i]
$$

训练时优化的是重构误差加上 codebook 对齐项：

$$
\mathcal{L}
= \|x - \hat{x}\|^2
+ \beta \|q_z - \operatorname{sg}(x)\|^2
+ \gamma \|x - \operatorname{sg}(q_z)\|
$$

这里的直觉是：第一个项保证重构质量，后两个项让 codebook 学得更稳定。

### 3.3 Why Residual VQ Matters for KV Cache

这篇文章不是简单把现成 VQ 套进来，而是强调了它对 KV cache 的特殊适配性。

作者指出，RoPE 会让 key 向量随着位置发生系统性变化，如果只靠单个 codebook，很难覆盖这种随位置漂移的分布；残差式设计则可以把这种变化拆散到多个 codebook 中去表示，因此 key cache 的重构会更稳。

这点其实很关键，因为长上下文里最容易出问题的往往不是“平均误差”，而是位置相关误差不断累积，最后体现在检索或长链推理性能上。

### 3.4 Prefill Compression

在 prefill 阶段，VQKV 不会粗暴压缩所有缓存，而是保留两段：

- 最前面的 initial tokens，长度为 $L_{\text{init}}$
- 最近的一段 local cache，长度为 $L_{\text{local}}$

中间那段历史缓存才被压缩为离散 code。这样做是为了兼顾两个事实：

- 前缀 token 往往包含系统提示或全局任务定义，删或压坏都很危险。
- 最近 token 对当前解码最敏感，保留原始浮点表示最稳。

对 key 的量化过程可写为：

$$
q_i^k = \arg\min_{q \in Q_i^k} \|k_i - W_i^k q\|
$$

$$
k_1 = k,\quad k_{i+1} = k_i - q_i^k,\quad i = 1, \dots, N_k
$$

最终离散表示为：

$$
q^k = VQ^k(k) = \left(q_1^k, q_2^k, \dots, q_{N_k}^k\right)
$$

对应重构为：

$$
\hat{k} = VQ^k[q^k] = \sum_{i=1}^{N_k} Q_i^k[q_i^k]
$$

value 端也是同样逻辑。

### 3.5 Decoding-Time Reconstruction

解码阶段的关键不是“能不能重构”，而是“能不能别太慢”。

VQKV 的做法是：

- 每当 local window 滑动，就把滑出去的那部分 KV 批量量化，而不是每个 token 单独量化。
- 当前步做注意力时，只按需重构中间那段被压缩的 KV。
- 这部分重构被嵌进自定义 FlashAttention / Triton kernel 里，避免额外的数据搬运。

也就是说，它在系统层面上尽量把 VQ 的额外开销摊平，而不是只在算法层面讲压缩率。

### 3.6 Compression Ratio

如果 key 端使用 $N_k$ 个 codebook、每个 codebook 大小为 $S_k$，value 端使用 $N_v$ 个 codebook、大小为 $S_v$，则压缩率写作：

$$
r = \left(
1 - \frac{N_k \log S_k + N_v \log S_v}{16 (D_k + D_v)}
\right) \times 100\%
$$

这里分母里的 16 对应原始 KV 使用 FP16 存储。这个公式也说明了方法的本质：它是用多个小整数索引去替代整段浮点向量。

## 4 Experiments

### 4.1 Setup

实验主要在两个模型上进行：

- `LLaMA3.1-8B`
- `LLaMA3.2-3B`

默认配置里：

- $L_{\text{init}} = 4$
- $L_{\text{local}} = 1024$

RSimVQ 的训练只用了 `0.1%` OpenWebText，学习率 `0.001`，batch size `65536`。这也呼应了作者“training-free for the target LLM”的定位：不需要重新训练大模型本体，只需离线训练量化器。

两组核心压缩配置是：

- `LLaMA3.1-8B`：$(N_k, N_v) = (56, 16)$，$(S_k, S_v) = (1024, 512)$，压缩率 `82.8%`
- `LLaMA3.2-3B`：$(N_k, N_v) = (56, 10)$，$(S_k, S_v) = (1024, 65536)$，压缩率 `82.4%`

### 4.2 LongBench

这是论文里最有说服力的一张主表。

在 `LLaMA3.1-8B` 上：

- 原始模型平均分 `33.5`
- `VQKV (82.8%)` 平均分 `33.1`
- 也就是保留了基线 `98.6%` 的性能

而其他方法在相近压缩强度下：

- `KIVI (75.0%)`：`30.7`
- `ASVD (80.0%)`：`21.2`
- `Palu (80.0%)`：`28.6`
- `SnapKV`：`31.7`

在 `LLaMA3.2-3B` 上：

- 原始模型 `32.3`
- `VQKV (82.4%)`：`32.2`

这说明它真正强的地方不是“能压”，而是在高压缩比下依然几乎不掉点。

### 4.3 Needle-In-A-Haystack

NIAH 更偏向长上下文精确检索，这对 KV 重构误差非常敏感。

结果非常亮眼：

- `LLaMA3.1-8B` 上，VQKV 得分 `100.00`，与 full cache 持平
- `LLaMA3.2-3B` 上，VQKV 也是 `100.00`

对比方法明显更差：

- `KIVI` 分别为 `99.71` 和 `98.69`
- `SnapKV` 分别为 `88.35` 和 `90.29`
- `ASVD` 分别为 `85.67` 和 `36.42`
- `Palu` 分别为 `68.99` 和 `35.99`

这基本说明 VQKV 对“把针从长草堆里找出来”这类任务影响极小。

### 4.4 RULER

RULER 更综合地考察长上下文理解和推理。

在 `LLaMA3.1-8B` 上：

- baseline：`92.78`
- `VQKV`：`87.31`
- `SnapKV`：`74.16`
- `Palu`：`63.24`
- `KIVI`：`52.01`
- `ASVD`：`29.31`

在 `LLaMA3.2-3B` 上：

- baseline：`84.38`
- `VQKV`：`77.11`
- `SnapKV`：`68.84`
- `Palu`：`62.98`
- `KIVI`：`41.25`
- `ASVD`：`18.36`

这里 VQKV 虽然不是完全无损，但相比其他高压缩基线依旧明显领先。

### 4.5 Memory Efficiency

这部分很工程化，也很重要。

作者在单张 `RTX 4090 (48GB)` 上测试，prompt 长度设为 `65536`。结果是：

- 原始 full KV cache 大约在 `190k` 生成长度附近 OOM
- VQKV 可以支持超过 `824k` 的生成长度

也就是相同显存预算下，生成长度提升超过 `4.3×`。

这意味着 VQKV 不只是 benchmark 上好看，而是真的把“原本跑不动的超长生成”推进到了可运行区间。

### 4.6 Ablation

消融结果主要告诉我们三件事：

1. codebook 数量越多，性能越好，但压缩率会下降。
2. codebook 大小越大，也通常更好，但收益会逐渐递减。
3. value 端比 key 端更敏感，value codebook 配得太少会更明显地掉性能。

从图里的趋势看：

- key codebook 数量增加时，性能是比较平滑地饱和。
- value codebook 在较小数量区间提升很快，之后趋于平台。

这说明 value cache 的量化预算不能配得太抠，不然整体效果会先掉在 value 上。

### 4.7 Limitations

作者也承认，这个方法在 decoding latency 上仍有优化空间。虽然他们已经把重构过程塞进定制 kernel 里，但向量量化毕竟比直接读 FP16 cache 多了一层索引和重建，因此算子效率仍然是后续优化重点。

## 我的理解

我觉得这篇 paper 的价值，不只是“提出了一个新压缩器”，而是把 KV cache 压缩的问题重新表述了一遍。

以前很多方法默认把 KV cache 看成“很多浮点数”，于是自然会想到逐元素量化；VQKV 则把它看成“很多有结构的向量模式”，于是更适合用离散原型来编码。这个视角变化很重要，因为它决定了压缩上限。

如果把几条路线放在一起看：

- SnapKV / H2O 这类方法是在做“删什么”
- KIVI / KVQuant 这类方法是在做“每个数怎么压”
- ASVD / Palu 这类方法是在做“把向量投到哪里”
- VQKV 则是在做“这个向量属于哪个模式组合”

所以它和传统量化不是一个层面的改动，反而更像是把 cache 表示从连续空间换到了离散词表空间。

我还挺认同它的一点是：作者没有追求“全 cache 一刀切压缩”，而是保留 initial tokens 和 local tokens，只处理中间历史段。这种设计很符合实际推理中的注意力分布，也说明它不是只追求 paper 上的压缩比，而是在认真考虑部署落地。

如果后面继续做这条线，我觉得有几个自然方向：

- 把 codebook 设计成 layer-aware 或 head-aware，而不是统一共享配置。
- 把 VQ 和 token importance 结合，形成“重要 token 保留原值，不重要 token 做 VQ”的混合方案。
- 继续优化 decode kernel，让重构开销更接近标量量化方法。

## 相关链接（双向）

- [[KVQuant]]
- [[PQCache]]
- [[Quant-VideoGen]]
