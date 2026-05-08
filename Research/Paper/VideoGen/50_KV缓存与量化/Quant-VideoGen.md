---
created: 2026-04-30
published: 2026-02-03
type: paper
status: 已读
tags:
  - QuantVideoGen
  - VideoGeneration
  - KVCache
  - Quantization
  - LongVideo
  - TrainingFree
aliases:
  - Quant VideoGen
  - Quant VideoGen: Auto-Regressive Long Video Generation via 2-Bit KV-Cache Quantization
summary: Quant VideoGen 把自回归长视频生成中的 KV cache 量化问题重新定义成“先利用视频时空冗余把分布变平滑，再做渐进式残差量化”的问题；其 Semantic-Aware Smoothing 与 Progressive Residual Quantization 在 2-bit 下仍能保持接近无损的长时质量，并把 KV 显存压到约原来的七分之一。
pdf-url: Attachments/arxiv_2602.02958.pdf
source-url:
  - https://arxiv.org/abs/2602.02958
  - https://doi.org/10.48550/arXiv.2602.02958
  - Attachments/arxiv_2602.02958.pdf
---

# Quant VideoGen: Auto-Regressive Long Video Generation via 2-Bit KV-Cache Quantization

## PDF
- [[Attachments/arxiv_2602.02958.pdf]]

## 一句话摘要
Quant VideoGen 的关键不是简单把 LLM 的 KV quantization 迁到视频上，而是先用 `Semantic-Aware Smoothing` 把视频 KV 按语义聚类并减去组中心，让 residual 变成更适合低比特量化的分布；再用 `Progressive Residual Quantization` 分阶段逼近细节，从而在 `2-bit` 下仍保住长时一致性。

## Abstract
这篇论文抓住了自回归长视频生成里一个系统和算法强耦合的瓶颈：`KV-cache memory`。作者指出，在 auto-regressive video diffusion 中，随着生成历史变长，KV cache 很快会超过 `30 GB`，甚至比模型参数本身更占显存。更重要的是，KV 预算变小不只是推理效率问题，它还会直接缩小模型可保留的“工作记忆”，从而损害 identity、layout 和 motion 的长时一致性。论文提出 `Quant VideoGen (QVG)`，一个训练免费的视频 KV cache 量化框架。QVG 不直接照搬 LLM 中的量化方案，而是利用视频 token 的时空冗余，先通过 `Semantic-Aware Smoothing` 生成低幅值、量化友好的 residual，再通过 `Progressive Residual Quantization` 以 coarse-to-fine 的方式逐步压缩残差。最终，QVG 在 `LongCat-Video`、`HY-WorldPlay` 和 `Self-Forcing` 上建立了新的质量-显存 Pareto 前沿，在 `2-bit` 下把 KV 显存最多压到 `7.0×`，端到端额外时延小于 `4%`，同时生成质量显著优于已有量化基线。

## 1 Introduction
论文的出发点不是泛泛地追求“更省显存”，而是把长视频生成上不去的原因直接落在 KV cache 上：

- 在自回归视频扩散里，历史帧必须被保留为 KV cache，否则就要反复重算；
- 随着 rollout 历史增长，KV cache 会比模型参数更快地吃满显存；
- 一旦显存不够，系统就不得不缩小上下文窗口；
- 上下文窗口缩小后，长时 identity、场景布局和运动语义的一致性会明显变差。

论文用 `LongCat-Video` 给了一个很直观的数量级例子：
- 生成一个 `5s` 的 `480p` 视频，大约需要 `38K` latent tokens；
- 对应的 KV cache 约 `34 GB`；
- 这已经超过单张 `RTX 5090` 的容量。

因此这篇工作的核心问题可以概括成一句话：

`能不能把视频生成里的 KV cache 压到极低比特，同时不把长视频质量一起压坏？`

## 2 Related Work
作者把自己放在两条路线的交叉处：

- `Auto-Regressive Video Generation / 长视频记忆`
  如 `CausVid`、`Self-Forcing`、`HY-WorldPlay`、`LongCat-Video` 等，都在探索用 causal attention 和 chunk-wise rollout 做长时视频生成。

- `KV Cache Quantization for LLMs`
  如 `KIVI`、`KVQuant`、`QuaRot`、`RotateKV` 等，已经在文本 LLM 上把 KV cache 量化做得很成熟。

论文的关键判断是：视频模型虽然也有 KV cache，但它的数值分布和 LLM 不一样，不能直接照搬文本方法。主要原因是：
- 视频 token 在空间和时间上都更异质；
- token 与 channel 两个维度的数值波动都更大；
- outlier 分布不像文本那样规整。

所以 Quant VideoGen 的位置不是“把现有 KV 量化方法挪到视频”，而是“给视频 KV 量化加上视频特有的时空先验”。

## 3 Motivation

### 3.1 KV Cache is Both a System Bottleneck and a Capability Bottleneck
论文特别强调，KV cache 问题有两层：

第一层是系统问题。对一个有 $L$ 层、hidden size 为 $d$ 的模型，视频 KV cache 的显存近似为：
$$
\mathrm{Mem}_{\mathrm{KV}}
=
2\cdot L \cdot (HWT)\cdot d\cdot \mathrm{Byte}_{\mathrm{BF16}}
$$

这说明它和 token 总数线性增长，而长视频的 token 总数本来就大。

第二层是能力问题。作者观察到，更长的 KV history 会显著改善长时一致性；反过来，如果为了省显存而把上下文窗口截短，就会让长视频更容易 drift。

换句话说，KV cache 不只是推理成本，它本身就是模型“记住多久”的上限。

### 3.2 Why Video KV Quantization is Hard
论文先回顾了对称按组整数量化。给定 BF16 张量 $X_{\mathrm{BF16}}$，量化与反量化写为：
$$
X_{\mathrm{INT}}, S_X = Q(X_{\mathrm{BF16}}), \qquad
\hat{X}=S_X\cdot X_{\mathrm{INT}}
$$

其中量化尺度为：
$$
X_{\mathrm{INT}}
=
\left\lfloor \frac{X_{\mathrm{BF16}}}{S_X}\right\rceil,
\qquad
S_X=\frac{\max(|X_{\mathrm{BF16}}|)}{2^b-1}
$$

对任意元素 $x\in X_{\mathrm{BF16}}$，量化误差满足：
$$
|x-\hat{x}|
=
S_X\cdot \mathrm{RoundErr}\!\left(\frac{x}{S_X}\right)
\le \frac{S_X}{2}
$$

因此在独立近似下，期望误差满足：
$$
\mathbb{E}[|x-\hat{x}|]\propto S_X
$$

这意味着：只要某个 group 里有 outlier，把 scale 拉大，所有元素的量化误差都会一起变差。

而视频模型的问题是，这种 outlier 更严重也更乱。论文实测到：
- 在 `Wan distilled Self-Forcing` 和 `LongCat-Video` 上，`max|K| \sim 10^2`
- `max|V| \sim 10^3`

并且 **outlier 在 token 间和 channel 间的分布都很不规则**。这也是为什么 LLM 量化方法在视频上直接失效。

### 3.3 Video KV Cache is Highly Redundant
尽管难量化，视频又有一个非常有利的性质：冗余强。

论文给出两个观察：

1. `Temporal redundancy`
  同一空间位置在相邻帧之间通常变化平滑，因此相邻时间的 token 往往高度相似。

2. `Spatial redundancy`
  空间上相邻的 patch，如果像素层面已经很像，它们对应的 latent token 通常也会有高 cosine similarity。

这意味着视频 token 不是彼此独立的，它天然适合先做“局部共享表示”，再量化 residual。

## 4 Methodology

### 4.1 Semantic-Aware Smoothing
这一步是整篇论文最核心的设计。目标非常明确：

`不要直接量化原始 KV，而是先把相似 token 聚成组，减去组中心，把原本又大又乱的分布变成低幅值 residual。`

#### 4.1.1 Semantic-based Grouping
QVG 以 chunk 为单位处理 KV cache。设某个 chunk 含有 $N$ 个 token，其 KV 张量记为：
$$
X\in \mathbb{R}^{N\times d}
$$

其中 $d$ 是单头维度。

作者沿序列维度对 token 做 `k-means` 聚类，把它们分成 $C$ 个组：
$$
G=\{G_1,G_2,\dots,G_C\}
$$

每个组 $G_i$ 中的 token 在 hidden representation 上相似，对应的组中心为：
$$
C_i\in \mathbb{R}^{d}
$$

#### 4.1.2 Residual via Centroid Subtraction
对每个组，减去组中心，得到 residual：
$$
R_i = X_{G_i} - C_i,
\qquad
R_i\in \mathbb{R}^{|G_i|\times d}
$$

这一步的直觉很强：
- 原始 KV 中，大量大数值其实是组内共享的“公共结构”；
- 先减去 centroid，这些大值被吸收掉；
- 剩下的 residual 幅值明显变小，更集中在 0 附近；
- 于是量化尺度 $S_X$ 也更小，误差自然下降。

整步操作可以写成：
$$
R,C,\pi = \mathrm{SA\text{-}Smoothing}(X, C)
$$

其中：
- $R\in\mathbb{R}^{N\times d}$ 是 residual tensor；
- $C\in\mathbb{R}^{C\times d}$ 是所有 centroids；
- $\pi\in\{1,\dots,C\}^N$ 是每个 token 的组指派。

#### 4.1.3 为什么有效
论文在 Figure 6 中给出直接证据：加上 `SAS` 后，量化误差显著下降。

- Key cache 的 MSE 可下降约 `6.93×` 到 `7.08×`
- Value cache 的 MSE 可下降约 `2.62×` 到 `2.65×`

作者还指出，key 比 value 更容易通过 SAS 获得收益，因为 value cache 本身的分布更不规则。

### 4.2 Progressive Residual Quantization
只做一轮 residual 化还不够，于是作者进一步利用视频的 progressive structure，提出多阶段残差量化。

设初始输入为：
$$
R^{(0)}=X
$$

总共有 $T$ 个阶段，每阶段都对 residual 再做一次 semantic-aware smoothing：
$$
R^{(t)}, C^{(t)}, \pi^{(t)}
=
\mathrm{SA\text{-}Smoothing}(R^{(t-1)}, C)
$$

经过 $T$ 个阶段后，对最终 residual 做低比特量化：
$$
X_{\mathrm{INT}}, S_X = Q(R^{(T)})
$$

与此同时，所有阶段的 centroid 和 assignment 都要存下来：
- 存 $C^{(t)}$
- 存 $\pi^{(t)}$
- 中间 residual $R^{(t)}$ 则可以丢弃

这个设计的核心思想是：
- 第一阶段先吸收粗粒度的公共结构；
- 后续阶段再继续吸收更细粒度的剩余模式；
- 最终留下的 residual 会越来越小，越来越适合 2-bit / 4-bit 量化。

可以把它理解成一种“视频版的 coarse-to-fine 残差编码”。

#### 4.2.1 Reconstruction
对单阶段 SAS，重建公式是：
$$
\hat{X}_{G_i}=R_i + C_{\pi_i}
$$

对 Progressive Residual Quantization，则从最后一级 residual 开始，逐级把 centroid 加回去，恢复到原始张量。这本质上就是对压缩过程的 replay。

### 4.3 Efficient Algorithm-System Co-design
论文除了算法，也做了几件很实用的系统优化：

#### 4.3.1 Fast k-means with Streaming Centroid Caching
`k-means` 本来会引入明显开销，尤其是 `k-means++` 初始化。作者利用视频流式生成的连续性：
- 对新 chunk，不从头初始化 centroids；
- 直接复用前一个 chunk 的 assignment 策略来 warm start

这样把 `k-means` 的开销降低了约 `3×`。

#### 4.3.2 Fused Dequantization Kernel
作者实现了 fused kernel，把：
- dequantization
- 多阶段 centroid add-back

合到同一个 kernel 中间执行，并尽量把中间结果放在寄存器里，减少 global memory 读写。

## 5 Experiments

### 5.1 Setup
评测模型包括：
- `LongCat-Video-13B`
- `HY-WorldPlay-8B`
- `Self-Forcing-Wan-1.3B`

都在 `480p` 分辨率下评测。

不同模型的 rollout 方式不同：
- `LongCat-Video-13B`：固定 `73` 帧上下文，每次续写 `20` 帧
- `HY-WorldPlay-8B`：全历史条件，每个 chunk `12` 帧
- `Self-Forcing-Wan-1.3B`：全历史条件，每个 chunk `16` 帧

评价指标包括：
- fidelity：`PSNR`、`SSIM`、`LPIPS`
- 感知质量：`VBench` 中的 `Background Consistency`、`Image Quality`、`Subject Consistency`、`Aesthetic Quality`
- efficiency：KV compression ratio 和 end-to-end latency overhead

对比基线是：
- `RTN`
- `KIVI`
- `QuaRot`

实现细节也很重要：
- 在 `H100` 上评测
- 使用 chunk-wise compression，避免反复重压缩导致 drift
- 使用 `pre-RoPE key caching`
- scale 因子用 `FP8 E4M3`
- `QVG` 默认 `S=1, B=64`
- `QVG-Pro` 默认 `S=4, B=16`
- centroid 数量 `K=256`，assignment 向量可用 `uint8` 存储

### 5.2 Main Quality Results
论文主表最值得记的，是在 `INT2` 下 QVG 仍能接近无损，而基线会明显崩。

#### LongCat-Video-13B, INT2
BF16 参考：
- `PSNR = 96.22?` 不，这里主表的 BF16 行后四列是 VBench；真正 PSNR/SSIM/LPIPS 是只对量化方法报告。更重要的是相对结果。

关键数字：
- `RTN`: `20.872 PSNR`, `6.40×`
- `KIVI`: `20.317 PSNR`, `6.40×`
- `QuaRot`: `21.573 PSNR`, `6.40×`
- `QVG-Pro`: `30.376 PSNR`, `4.97×`
- `QVG`: `28.716 PSNR`, `6.94×`

这说明：
- 如果追求最强 fidelity，`QVG-Pro` 最好；
- 如果追求极致压缩，`QVG` 用接近 `7×` 的压缩率仍能保持远好于基线的质量。

#### HY-WorldPlay-8B, INT2
- `RTN`: `24.199 PSNR`, `6.40×`
- `KIVI`: `24.272 PSNR`, `6.40×`
- `QuaRot`: `25.207 PSNR`, `6.40×`
- `QVG-Pro`: `31.562 PSNR`, `5.20×`
- `QVG`: `29.174 PSNR`, `7.05×`

这里同样能看到：
- `QVG-Pro` fidelity 最强
- `QVG` 在 `7.05×` 压缩下仍明显优于所有基线

#### INT4
在 `INT4` 下差距缩小，但 QVG 仍保持领先。比如：
- `LongCat-Video-13B`
  - `QVG-Pro`: `37.095 PSNR`
  - `QVG`: `37.141 PSNR`
- `HY-WorldPlay-8B`
  - `QVG-Pro`: `35.109 PSNR`
  - `QVG`: `34.454 PSNR`

更关键的是，QVG 在 VBench 四个指标上也几乎接近 BF16，而基线尤其在 `INT2` 时退化明显。

### 5.3 Long-Horizon Drift on Self-Forcing
论文在 `Self-Forcing` 上测了更有价值的长程指标：沿着视频长度，每 `50` 帧统计一次 `Image Quality`。

结论很明确：
- BF16 baseline 自己也会随长度略微退化；
- `QVG` 和 `QVG-Pro` 能在延长到 `700` 帧时仍保持接近无损；
- `RTN`、`KIVI`、`QuaRot` 大约在 `100` 帧后就开始明显恶化。

这组结果很重要，因为它说明 QVG 不是只在短视频 PSNR 上好看，而是真的更能抵抗 long-horizon drift。

### 5.4 Efficiency
#### Compression Ratio
论文主张的压缩率大致分两档：
- `QVG-Pro`: `4.97×` 到 `5.20×`
- `QVG`: `6.94×` 到 `7.05×`

#### End-to-End Latency Overhead
端到端额外开销非常小：
- `LongCat`: `+2.1%`
- `HY-World`: `+1.5%`
- `Self-Forcing`: `+4.3%`

这意味着它不是一个“实验室里能压但跑不动”的方案，而是真正接近可部署。

#### Memory Breakdown
论文把压缩后的内存拆成四部分：
- quantized values
- assignment vector
- centroids
- scaling factors

结果显示，无论 `INT2` 还是 `INT4`，`quantized values` 都占总内存的大头（`>=65%`）。这也说明：
- QVG 的开销主要还是在真正存储数值；
- 额外存 centroid / assignment 虽然有成本，但没有吞掉主要压缩收益。

### 5.5 Sensitivity
#### Number of Stages
Progressive Residual Quantization 的阶段数很有规律：
- 第一阶段带来的 MSE 下降最大，约 `5.83×`
- 后续阶段还能继续下降，但边际收益递减
- 每多一阶段，至少还能带来约 `1.10×` 的 MSE 改善

这说明 progressive 设计确实有用，但并不是阶段越多越值。

#### Group Size
论文测试了 block size 从 `16` 到 `64`：
- `B=64`：压缩率最好
- `B=16`：质量最好

所以：
- `QVG` 用 `B=64`，偏向更高压缩率
- `QVG-Pro` 用 `B=16` 且更多阶段，偏向更高 fidelity

## 6 Conclusion
Quant VideoGen 最重要的贡献，不是单纯把 KV cache 量化到 `2-bit`，而是证明了：

- 视频 KV cache 的难点不是“bit 太低”，而是原始分布太乱；
- 只要先利用视频时空冗余，把分布改造成小幅值 residual；
- 再用 progressive residual quantization 逐步压缩，就可以在极低比特下保住长时质量。

因此，这篇论文提供的是一条很清晰的视频专用 KV 量化路线：

`先做语义分组和平滑，再做多阶段残差量化，而不是直接对原始 KV 生硬下刀。`

## 我的理解
我觉得这篇论文最强的地方是，它没有把问题理解成“如何找更强的量化器”，而是理解成“如何把输入分布先改造成适合量化的形式”。

这和很多文本 LLM 量化工作不太一样。LLM 路线经常围绕：
- outlier handling
- rotation
- per-channel / per-token scaling
- codebook design

来优化量化器本身。而 QVG 的 insight 更像是：
- 视频 token 本来就在时空上高度冗余；
- 不利用这点去做 grouping 和 residual 化，直接量化就等于放弃最重要的结构先验。

所以从研究线角度看，这篇论文的真正价值是两点：

1. 它证明了 `KV cache quantization` 对 autoregressive video generation 是可行的，而且不是只能做 4-bit，2-bit 也能做得很好。

2. 它给出了一种很视频专用的方法论：  
   `先结构化 redundancy，再做低比特压缩。`

如果你之后要继续做 `longvideo-kvcache-quant`，这篇应该是一个非常核心的视频强基线。

## 相关链接（双向）
- [[Self-Forcing ✅]]
- [[Deep-Forcing]]
- [[Relax-Forcing]]
- [[流式视频生成]]
