---
created: 2026-04-30
published: 2024-01-31
type: paper
status: 未读
tags:
  - KVQuant
  - KVCache
  - Quantization
  - LongContext
  - RoPE
  - OutlierAware
aliases:
  - KVQuant
  - KVQuant: Towards 10 Million Context Length LLM Inference with KV Cache Quantization
summary: KVQuant 不是只做更低 bit 的 KV 量化，而是系统分析 sub-4-bit 失真的来源，并通过 pre-RoPE key、per-channel/per-token 非对称量化、敏感度加权非均匀码本和稠密-稀疏 outlier 拆分，把超长上下文 KV cache 压缩推进到真正可部署的级别。
pdf: /Users/moweile/Obsidian/Knowledge/Research/Paper/KV_cache/50_量化与编码压缩/Attachments/KVQuant_2401.18079.pdf
pdf-url: Attachments/KVQuant_2401.18079.pdf
source-url:
  - https://arxiv.org/abs/2401.18079
  - https://arxiv.org/pdf/2401.18079.pdf
  - https://github.com/SqueezeAILab/KVQuant
---

# KVQuant: Towards 10 Million Context Length LLM Inference with KV Cache Quantization

## 一句话结论
KVQuant 的真正贡献不是“把 KV cache 压到 sub-4-bit”，而是把一个原本容易被当成单纯量化问题的任务，拆成了四个更具体的失败模式，并逐个修补：

$$
\text{分布不匹配} + \text{RoPE 扰动} + \text{码点分配失衡} + \text{outlier 拉宽范围}
$$

所以它比很多同时期方法更像一个完整系统，而不是一个孤立技巧。

## 论文要解决什么问题
这篇论文讨论的是超长上下文推理场景下，为什么 KV cache 很快会取代模型权重，成为新的主瓶颈。

- 短上下文时，显存主要花在模型参数上；
- 但上下文一长，KV cache 会线性随序列长度增长；
- 推理阶段又需要不断读取 KV cache，所以系统往往是 memory-bandwidth bound，而不是 compute-bound。

因此，问题不只是“能不能压缩 KV”，而是：

$$
\text{能不能在极低 bit 下压缩 KV，同时别把长上下文能力压坏。}
$$

作者明确指出，已有方法在 `4-bit` 还能勉强工作，但一旦进一步往 `3-bit`、`2-bit` 推，精度退化会很快变得不可接受。

## 核心观察
KVQuant 的方法不是拍脑袋设计出来的，而是先对 KV cache 分布做了解剖。最关键的观察有四个。

### 1. Key 和 Value 的统计结构不同
作者发现：

- `Key` 在一些固定 channel 上会出现明显 outlier；
- `Value` 也有 outlier，但并不像 `Key` 那样稳定地集中在某些固定 channel 上。

这意味着 `Key` 更适合按 `channel` 看，而 `Value` 更适合按 `token` 看。

### 2. RoPE 会把原本结构化的 Key 分布搅乱
在 `pre-RoPE` 空间里，某些 key channel 的大幅值模式比较稳定；但一旦做完 RoPE，不同位置会对 channel 对做不同角度的旋转，原来稳定的 outlier channel 会被打散。

所以：

$$
\text{post-RoPE 的 Key 比 pre-RoPE 的 Key 更难量化。}
$$

### 3. 非均匀量化不是“只要上 NF4 就够了”
即使不用均匀量化，现成非均匀 datatype 也未必最适合 KV cache。因为 KV cache 的问题不只是数值分布非高斯，更在于不同层、不同向量的敏感度并不相同。

### 4. outlier 不能按整层粗暴处理
如果只给整层设一个全局 outlier threshold，那么某些 channel 或 token 里“本来就正常但略大”的值会被误判，或者真正拉宽范围的值没被精准抓住。

作者因此主张：

$$
\text{应该在量化粒度对应的向量级别识别 outlier。}
$$

也就是：

- `Key` 用 per-channel outlier threshold；
- `Value` 用 per-token outlier threshold。

## 方法概述
KVQuant 可以理解成一个由四个模块拼起来的方案。它们不是并列堆料，而是在修补四种不同的误差来源。

### 1. Per-channel Key quantization
作者发现 `Key` 的 outlier 常常集中在少数固定 channel，所以让同一 channel 的值共享 scale / zero-point，比让同一 token 的所有 channel 共用一组量化参数更合理。

这一步的直觉很简单：

$$
\text{把幅值相近的值放在一起量化，比把幅值差异大的值硬塞进同一个范围更稳。}
$$

实验上，这一步对 `Key` 很有帮助，但对 `Value` 并不好，因此最终方案是：

- `Key`: per-channel quantization
- `Value`: per-token quantization

这和后来的 [[KIVI]] 在大方向上是一致的，只是 KVQuant 把分析和系统补丁做得更完整。

### 2. Pre-RoPE Key quantization
这篇论文最经典的点之一，就是明确提出：

$$
\text{Key 应该在 RoPE 之前量化。}
$$

原因是 RoPE 会把 channel 成对旋转，导致本来在某些 channel 上稳定存在的大幅值模式被位置相关地混合掉。这样一来，后 RoPE 空间里的 key 更难压。

KVQuant 的处理方式是：

- 缓存并量化 `pre-RoPE Key`；
- 在解码时反量化后，再在线施加 RoPE。

为了不让这件事拖慢推理，它还专门做了 fused kernel。

### 3. Sensitivity-weighted non-uniform quantization
作者没有直接套现成非均匀码本，而是用离线校准数据，为每一层的 Key / Value 导出一个敏感度加权的非均匀 datatype，文中记作 `nuqX`。

优化目标不是单纯最小化数值误差，而是近似最小化带 Fisher 权重的误差：

$$
Q(A)^* \approx \arg\min_Q \sum_{i=1}^{N} F_{ii}\left(A_i - Q(A_i)\right)^2
$$

这里 `F_{ii}` 反映的是该元素误差对模型更下游目标的敏感度。也就是说，KVQuant 在分配码点时考虑的是“错在哪里更疼”，而不只是“哪里数值更大”。

### 4. Per-vector dense-and-sparse quantization
为了避免极少量 outlier 把量化范围拉得过宽，作者把一小部分 outlier 单独取出来，用稀疏格式保存，剩余大部分值再做低比特量化。

但它不是简单整层做 sparse split，而是：

- `Key` 按 channel 单独定 outlier threshold；
- `Value` 按 token 单独定 outlier threshold。

这样做的核心收益是：真正影响这一个向量量化范围的值，才会被拿出来单独存。

### 5. Attention sink-aware quantization
作者还观察到模型对第一个 token 的量化误差特别敏感，因为很多层会把它当 attention sink。

因此 KVQuant 默认保留第一个 token 为 `fp16`。这件事在 `2-bit` 时尤其重要。

## 方法直觉
如果只用一句话总结 KVQuant，它其实是在说：

$$
\text{sub-4-bit KV 量化失败，不是一个原因造成的，而是多个误差源叠加的结果。}
$$

所以它不试图靠一个“大招”一把解决，而是把问题拆开：

- 分布不匹配：改量化粒度；
- RoPE 扰乱结构：改量化位置；
- 码点放得不对：改非均匀 datatype；
- outlier 拉宽范围：改 dense-sparse 拆分方式；
- 首 token 太敏感：单独保护 attention sink。

这也是为什么它看起来工程味很浓，但方法论上很强。

## 关键实现细节
这篇论文有几个很值得记住的工程点。

### 1. Key 和 Value 采用不同的统计策略
它没有强求统一方案，而是接受：

- `Key` 更适合离线校准的 per-channel；
- `Value` 更适合在线计算的 per-token。

### 2. Key 的 scale 用离线校准，Value 的 scale 用在线计算
对 `Key` 来说，如果在线更新 per-channel scale，每来一个 token 都可能要回头改旧缓存，代价太高；因此作者用离线 calibration 解决。

对 `Value` 来说，per-token scale 可以在新 token 到来时单独计算，不需要重写旧缓存，所以更适合在线处理。

### 3. 在线 outlier threshold 也被做进系统设计里
作者测过 top-k 开销，发现它可以放到 CPU 并和 GPU 上后续计算并行，因此动态抽取 value outlier 不一定真的造成额外延迟。

### 4. 它不是只讲算法，也讲 kernel
KVQuant 专门实现了 CUDA kernel 来做：

- 在线量化；
- 稀疏 outlier 提取；
- 低比特 lookup-table 反量化；
- pre-RoPE key 的 on-the-fly RoPE 施加。

所以它是很典型的“算法与系统一起交付”的工作。

## 实验结论
这篇论文的数据很强，而且覆盖了从普通 perplexity 到长上下文 retrieval 再到系统吞吐的多个层面。

### 1. 3-bit 已经非常接近无损
摘要主结论是：在 LLaMA、Llama-2、Llama-3、Mistral 上，`3-bit` KVQuant 在 `Wikitext-2` 和 `C4` 上都能做到 `< 0.1` 的 perplexity degradation。

以 Table 1 / Table 18 为例，在 LLaMA 系列上：

- `LLaMA-7B`: baseline `5.68`，`KVQuant-3bit-1%` 为 `5.75`
- `LLaMA-13B`: baseline `5.09`，`KVQuant-3bit-1%` 为 `5.14`
- `LLaMA-30B`: baseline `4.10`，`KVQuant-3bit-1%` 为 `4.15`
- `LLaMA-65B`: baseline `3.53`，`KVQuant-3bit-1%` 为 `3.57`

也就是说，`3-bit` 这档基本已经到了“能认真拿来用”的程度。

### 2. 2-bit 也明显强于同时代 baseline
`2-bit` 仍然会有可见退化，但已经比同时代方法稳定很多。

例如在 LLaMA-7B 上：

- `FlexGen-2bit`: `11.09`
- `KVQuant-2bit`: `7.23`
- `KVQuant-2bit-1%`: `6.01`
- baseline: `5.68`

这个差距说明，sub-4-bit 失真不是“2-bit 天生不行”，而是如果你不把前面那几类误差分别处理掉，2-bit 才会看起来完全不可用。

### 3. 压缩收益非常可观
论文总结的内存收益是：

- `4-bit` 约 `3.7x` memory saving
- `3-bit` 约 `4.8x`
- `2-bit` 约 `6.9x`

从序列长度角度看，这几乎可以直接理解成可支持上下文长度的倍增。

### 4. 长上下文能力没有被明显破坏
这篇论文不是只看短序列 perplexity。它还测了：

- passkey retrieval；
- LongBench；
- RULER。

在 `LLaMA-2-7B-32K` 上，`KVQuant-3bit-1%` 的 LongBench 平均分是 `31.21`，而 fp16 baseline 是 `31.96`；同一表里 KIVI 约 `30.04`。

在 RULER 上，论文直接给出结论：`3-bit KVQuant` 在相近平均 bit-width 下比 KIVI 高约 `14%`，而 `2-bit KVQuant` 能以更低 bit-width 达到和 KIVI 接近的准确率。

### 5. 系统侧收益也成立
论文声称：

- 单张 `A100-80GB` 可支持 LLaMA-7B 到 `1M` context；
- `8` 卡系统可到 `10M` context；
- 自定义 CUDA kernel 下，LLaMA-7B 的 Key/Value matvec 最多可达约 `1.7x` speedup。

这意味着它不是那种“指标好看但部署不现实”的论文，而是真的在向 serving 能力推进。

## 这篇论文的价值
KVQuant 在 KV cache 压缩路线里的地位很高，因为它第一次把很多零散 intuition 系统化了。它的重要性至少有三层。

### 1. 它把 RoPE 与量化的耦合问题正式讲清楚了
这件事后来几乎成了长上下文 KV 量化里绕不开的问题。很多后续工作，其实都默认接受了 KVQuant 的判断：

$$
\text{RoPE 不只是位置编码，也是量化难度来源。}
$$

### 2. 它证明了 sub-4-bit 不是幻想
在它之前，很多结果会让人觉得 3-bit 以下几乎注定掉坏；KVQuant 说明，只要把误差源拆开处理，`3-bit` 可以非常稳，`2-bit` 也不是完全不可用。

### 3. 它把“量化”推进成了“量化系统设计”
这篇论文最像样的地方，在于它不把问题只看成数值压缩，而是把：

- 数据分布；
- 位置编码；
- 层敏感度；
- outlier 结构；
- 在线/离线校准；
- kernel 实现

放到一起考虑。

## 局限与后续问题
从今天回看，KVQuant 也有一些清晰边界。

- 方法相当复杂，是多模块耦合的系统，不如 [[KIVI]] 那样轻量；
- 它仍然主要依赖静态校准与固定规则，还不算真正动态自适应的 bit allocation；
- 它的实验重点是文本 LLM，结论迁移到视频 / 多模态时未必原样成立；
- 即使它把 `2-bit` 做到了相对可用，但和更后来的“预测后压残差”路线相比，仍然是在直接压原始 KV，而不是先利用结构冗余。

这也是为什么后来像 [[Cache-Me-If-You-Must✅]] 这样的工作，会进一步把问题推进到“先预测可恢复信息，再量化残差”。

## 对你当前研究的启发
如果把 KVQuant 放到“长视频生成 / 视频模型 KV cache 压缩”这个方向，它至少有三点非常值得继承。

### 1. 先拆失败模式，再设计压缩方案
不要一上来就问“用哪种量化器”，而要先问：

- 是分布不匹配导致误差大？
- 是位置编码或时空编码让量化更难？
- 是少量 outlier 拉宽了动态范围？
- 是不同层或不同 token 的敏感度不一样？

KVQuant 最可贵的地方，就是它把这些问题拆开了。

### 2. 视频里的时空位置编码可能比文本 RoPE 更脆
这篇论文已经说明文本 RoPE 会扰乱 key 分布。迁到视频后，如果模型使用更复杂的时空位置编码，那么：

$$
\text{位置编码} \rightarrow \text{量化难度上升}
$$

这条链只会更值得检查。

### 3. outlier-aware 方案在视频里可能更重要
视频 token 的内容分布往往比文本更不均匀，运动区域、边界区域、纹理复杂区域都可能形成更强 outlier。KVQuant 这种“按真正量化粒度定义 outlier”的思路，很可能比统一阈值更适合迁移过去。

## 可以继续追的对比阅读
- [[KIVI]]：看更轻量、tuning-free 的不对称 K/V 量化路线。
- [[GEAR]]：看量化误差如何通过低秩与稀疏重建补偿。
- [[Cache-Me-If-You-Must✅]]：看从“直接量化原始 KV”进一步走向“先预测可恢复部分、再压残差”的路线。
- [[PQCache]]：如果你更想看编码式压缩而不是纯量化，可以和 KVQuant 对照。
- [[VQKV]]：如果你想继续追向量量化与码本式 KV 压缩，这篇是另一条分支。

## 我的评注
KVQuant 是那种非常典型的“工程论文，但方法论价值被低估”的工作。它真正厉害的不是某个单点技巧，而是它把一个看似只是低比特压缩的问题，改写成了下面这个更准确的视角：

$$
\text{KV cache 量化精度取决于分布、编码、敏感度和 outlier 结构的共同匹配。}
$$

如果只记一句话，我会记这个。因为它解释了为什么后续很多工作，无论是继续做 outlier-aware、pre-RoPE、非均匀量化，还是继续走向残差编码，本质上都还在 KVQuant 搭好的框架里继续深化。
