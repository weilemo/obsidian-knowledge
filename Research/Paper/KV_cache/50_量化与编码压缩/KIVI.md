---
created: 2026-04-30
published: 2024-02-05
type: paper
status: 未读
tags:
  - KIVI
  - KVCache
  - Quantization
  - LLMInference
  - AsymmetricQuantization
aliases:
  - KIVI
  - KIVI: A Tuning-Free Asymmetric 2bit Quantization for KV Cache
summary: KIVI 通过分析 KV cache 的分布差异，提出 key 按 channel、value 按 token 的非对称 2-bit 量化，并配合 recent residual fp16 window，在无需微调的前提下显著压缩显存且基本维持模型质量。
pdf: /Users/moweile/Obsidian/Knowledge/Research/Paper/KV_cache/50_量化与编码压缩/Attachments/KIVI_2402.02750.pdf
pdf-url: Attachments/KIVI_2402.02750.pdf
source-url:
  - https://arxiv.org/abs/2402.02750
  - https://arxiv.org/pdf/2402.02750.pdf
  - https://github.com/jy-yuan/KIVI
---

# KIVI: A Tuning-Free Asymmetric 2bit Quantization for KV Cache

## 一句话结论
这篇论文的重要性不只是“把 KV cache 压到 2-bit”，而是明确提出一个后来被大量工作沿用的判断：`Key` 和 `Value` 的分布特性不同，因此不应该使用同一种量化粒度。

## 论文要解决什么问题
在大 batch、长上下文的 LLM 推理里，KV cache 会快速成为新的瓶颈：

- 显存占用高；
- 解码阶段频繁读取 KV cache，导致带宽受限；
- 计算核会因为等待 KV 读写而空转，吞吐受影响。

如果把 KV cache 从 FP16 压到 2-bit，理论上可以把缓存大小压到原来的约 $\frac{1}{8}$。但难点在于，直接统一量化很容易明显掉点，尤其在推理任务和长上下文任务上更明显。

## 核心观察
作者先做了 KV cache 元素分布分析，而不是直接设计量化器。核心发现有两个：

- `Key cache` 在不同 channel 上存在更明显的幅值差异，因此更适合按 `channel` 分组量化；
- `Value cache` 更适合按 `token` 量化，也就是每个时间步分别做量化。

这就是 KIVI 的方法起点，也是它和很多“统一粒度量化”方法的根本差异。

## 方法细讲
KIVI 是一个 `tuning-free`、`plug-and-play` 的 2-bit KV cache 量化方法。它的核心不是发明一种复杂的新量化器，而是把三个问题拆开处理：

- 用什么量化形式去压缩 KV；
- `K` 和 `V` 各自该沿哪一维分组；
- 最近、最敏感的一小段缓存要不要暂时不压。

### 1. 基本量化形式
KIVI 本质上采用的是按组的仿射量化。对某个待量化分组中的浮点向量 $x$，先计算该组的最小值和最大值：

$$
x_{\min} = \min(x), \qquad x_{\max} = \max(x)
$$

若量化到 $b$ bit，则整数取值范围可写成：

$$
q \in \{0, 1, \dots, 2^b - 1\}
$$

对应的 scale 和 zero-point 可写成：

$$
s = \frac{x_{\max} - x_{\min}}{2^b - 1},
\qquad
z = \operatorname{round}\left(-\frac{x_{\min}}{s}\right)
$$

量化与反量化形式可写成：

$$
\hat{x} = \operatorname{clip}\left(
\operatorname{round}\left(\frac{x}{s}\right) + z,\;
0,\;
2^b - 1
\right)
$$

$$
\tilde{x} = s(\hat{x} - z)
$$

这里最关键的不是这套公式本身，而是：

$$
\text{同样的公式，用在不同分组轴上，误差行为会完全不同。}
$$

KIVI 的真正贡献正是在“分组轴”的选择上。

### 2. 为什么 key 要按 channel 量化
对 attention 来说，key 会直接参与打分：

$$
\operatorname{Attn}(Q, K, V) = \operatorname{softmax}\left(\frac{QK^\top}{\sqrt{d}}\right)V
$$

所以 key 的量化误差会先进入：

$$
QK^\top
$$

再经过 softmax 被非线性放大。作者观察到，key cache 在不同 channel 上的数值范围差异更明显，也就是说，如果把多个 channel 混在一起共用一组 scale，少数大幅值 channel 会把量化区间拉宽，导致其余 channel 的有效分辨率下降。

因此 KIVI 对 key 使用 `per-channel` 分组。可以把某个 channel 上、跨 token 的值看成一组：

$$
K^{(c)} = \{K_{t,h,c}\}_{t,h}
$$

然后对每个 channel 单独计算：

$$
s^{K}_{c}, \; z^{K}_{c}
$$

于是 key 的量化可以理解成：

$$
\hat{K}_{t,h,c}
=
\operatorname{Quant}\left(K_{t,h,c}; s^{K}_{c}, z^{K}_{c}\right)
$$

它的好处是：

- 每个 channel 单独适配自己的动态范围；
- 不会因为少数异常 channel 拖累整组分辨率；
- 更有利于保护 attention score 对尺度变化的敏感性。

### 3. 为什么 value 要按 token 量化
与 key 不同，value 不直接进入 softmax 打分，而是在 attention 权重算完之后参与加权求和：

$$
o_t = \sum_{i=1}^{t} \alpha_{t,i} V_i
$$

其中：

$$
\alpha_{t,i} = \operatorname{softmax}\left(\frac{q_t k_i^\top}{\sqrt{d}}\right)
$$

作者发现 value 的统计模式更适合按 token 处理。直觉上看，单个 token 的 value 向量内部相关性更强，而不同 token 之间的数值范围可能变化更明显。所以 KIVI 为每个 token 单独给一组量化参数。若把第 $t$ 个 token 的 value 向量记作：

$$
V_t = \{V_{t,h,c}\}_{h,c}
$$

则对每个 token 分别计算：

$$
s^{V}_{t}, \; z^{V}_{t}
$$

并进行：

$$
\hat{V}_{t,h,c}
=
\operatorname{Quant}\left(V_{t,h,c}; s^{V}_{t}, z^{V}_{t}\right)
$$

这背后的判断是：

- `K` 更像“用于匹配的索引”；
- `V` 更像“被读出的内容”；
- 两者在 attention 链路中的误差传播位置不同，因此最优量化粒度也不同。

### 4. 非对称设计的本质
所以 KIVI 的非对称，不只是说一个是 `per-channel`、一个是 `per-token`，而是在说：

$$
\text{对 } K \text{，优先保护 score 计算；对 } V \text{，优先保护内容重构。}
$$

这是一个非常重要的建模转变。它不再把 KV cache 看成“一大块待压缩浮点数”，而是把它们放回 attention 计算图里，问每一类张量的误差最终会在哪里被放大。

### 5. residual cache 机制
KIVI 并不是把所有历史 KV 一写入缓存就立刻量化。它额外保留一个最近窗口的全精度 residual cache。设窗口长度为 $R$，则可以把历史缓存拆成两部分：

$$
\text{KV cache}
=
\text{quantized old cache}
\;\cup\;
\text{full-precision recent cache}
$$

更具体地说，若当前总长度为 $T$，那么：

$$
\{1, \dots, T-R\}
$$

这部分较早的 token 会被量化存储，而：

$$
\{T-R+1, \dots, T\}
$$

这部分最近 token 仍保留为 FP16。

这一步的重要性在于：

- 最近 token 往往对当前生成最敏感；
- 如果把刚生成的新 token 立即压到 2-bit，误差会更快进入下一步解码；
- 保留一个短小的高精度窗口，可以显著缓和误差累积。

所以 KIVI 实际上不是“纯 2-bit 全缓存”，而是：

$$
\text{2-bit compressed history} + \text{FP16 recent window}
$$

### 6. 流式更新方式
KIVI 面向的是实际推理系统，因此缓存管理是在线进行的。随着 token 不断生成：

- 新产生的 KV 先进入 recent residual cache；
- 当 recent window 超过预设长度时，最旧的一部分再被量化并迁移到 compressed cache；
- 解码时同时读取“旧的量化缓存”和“新的全精度缓存”。

这意味着它不是一次性离线压缩整个矩阵，而是一个随生成过程滚动更新的机制，更贴近真实 serving 场景。

## 方法直觉
可以把 KIVI 总结成下面两句话：

$$
\text{不同张量用不同分组轴，最近上下文暂时别急着压。}
$$

以及：

$$
\text{量化误差的影响取决于它进入 attention 计算图的位置。}
$$

更具体地说：

- `Key` 的误差会污染 attention score，因此更需要控制 channel 级尺度失真；
- `Value` 的误差更多影响最终读出内容，因此 token 级局部自适应更划算；
- recent residual window 则是在系统层面给误差传播加了一道缓冲区。

## 实验结论
根据论文摘要和项目说明，KIVI 在 Llama、Falcon、Mistral 等模型上表现出如下结果：

- 在多个任务上与原始模型质量接近；
- 峰值显存占用可降低约 `2.6x`，这里统计包含模型权重；
- 更低显存占用允许 batch size 提高到最多约 `4x`；
- 在真实 LLM 推理负载下，吞吐可提升约 `2.35x ~ 3.47x`。

这组结果说明 KIVI 不只是“能压”，而是确实形成了工程上的性能收益闭环：

$$
\text{更小的 KV cache} \Rightarrow \text{更高可用 batch} \Rightarrow \text{更高吞吐}
$$

## 这篇方法为什么有效
如果把 KIVI 的有效性再压缩成一个更技术化的解释，大概是下面这条链：

### 1. 量化误差主要受分组动态范围控制
当一个 group 里的：

$$
x_{\max} - x_{\min}
$$

越大，固定 bit-width 下的量化步长：

$$
s = \frac{x_{\max} - x_{\min}}{2^b - 1}
$$

就越大，误差上界也越大。

### 2. key 和 value 的“合适 group”不同
如果 key 的跨 channel 差异大，那就应缩小每个 group 在 channel 维上的跨度；如果 value 的跨 token 差异大，那就应缩小每个 group 在 token 维上的跨度。

### 3. recent window 延缓误差反馈
在自回归解码里，当前步误差会影响下一步 hidden state，再影响下一步 KV。recent residual cache 的作用，就是把这条反馈链最前端的一小段先保留高精度，避免误差过早闭环。

所以 KIVI 不是靠一个单点技巧成功，而是三件事一起起作用：

- 正确的分组轴；
- 极低 bit-width 下的简单仿射量化；
- recent FP16 residual window 对误差传播的缓冲。

## 这篇论文的价值
KIVI 在 KV cache 压缩路线里的地位很高，原因主要有三点：

- 它较早系统性论证了 `K` 和 `V` 应采用不同量化策略；
- 它把 `2-bit` 这个极低精度设定做到了接近可用；
- 它强调的是无需微调、可直接接入推理系统的工程可部署性。

后续很多工作，无论是继续做更低 bit、分层混合精度，还是引入 outlier-aware / pre-RoPE / low-rank correction，本质上都在沿着 KIVI 提出的“先分析 KV 分布，再决定压缩方式”的思路继续推进。

## 局限与后续问题
从今天回看，KIVI 也有比较清楚的边界：

- 它主要是静态规则设计，还不是层级敏感、头敏感或 token 敏感的自适应方案；
- 它没有系统处理 RoPE 带来的量化困难，后续 [[KVQuant]] 在这点上做得更深入；
- 它虽然已经很低比特，但误差补偿机制相对简单，没有像 [[GEAR]] 那样显式引入低秩或稀疏修复通道；
- 它的核心结论来自文本 LLM，迁到视频或多模态 attention 时，分布假设未必完全成立。

## 对你当前研究的启发
如果把 KIVI 放到“长视频生成 / 视频模型 KV cache 压缩”这个方向，它最值得继承的不是具体的 2-bit 实现，而是下面这个研究框架：

### 1. 先问分布，再问量化
不要先决定统一用某种量化器，而是先检查：

- 视频模型里的 `K` 和 `V` 是否也呈现不同统计模式；
- 时间维、空间维、head 维、channel 维里，哪一维更适合作为量化分组轴；
- 不同层、不同阶段的 KV 是否敏感度不同。

### 2. recent window 可能在视频里更重要
KIVI 保留最近 token 的全精度窗口。在视频生成里，这可能对应：

- 最近若干帧；
- 最近 motion token；
- 当前局部块附近的高相关上下文。

也就是说，`residual fp window` 这件事在时序生成问题里可能不是工程小技巧，而是决定质量上限的关键变量。

### 3. K/V 不对称思想值得直接迁移
如果视频 attention 中的 `K` 更偏“索引/匹配”，`V` 更偏“内容承载”，那么 KIVI 的不对称量化思想大概率仍然成立，只是最优粒度未必还是 `per-channel` 和 `per-token`。

## 可以继续追的对比阅读
- [[KVQuant]]：继续往 sub-4-bit 和超长上下文推进，并显式处理 pre-RoPE 与 outlier 问题。
- [[GEAR]]：在量化之外加入低秩与稀疏误差修复，适合对“近无损压缩”感兴趣时对读。
- [[PQCache]]：如果你更关心编码式压缩而不只是纯量化，可以和 KIVI 对照看。
- [[VQKV]]：如果你要思考码本式或向量量化方向，也可以把它作为另一条路线的参照。

## 我的评注
KIVI 是那种“看起来很工程，但其实很有方法论价值”的论文。它最值得记住的不是 `2-bit` 本身，而是：

$$
\text{量化策略应当匹配 KV cache 的结构性统计差异。}
$$

这也是它能成为后来很多 KV 量化工作的起点的原因。
