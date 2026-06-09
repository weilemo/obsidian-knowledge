---
created: 2026-05-17
published: 2026-05-07
type: paper
status: 未读
tags: ["video-generation", "autoregressive", "kv-cache", "attention", "long-form", "training-free"]
aliases: ["Focused Forcing: Content-Aware Per-Frame KV Selection for Efficient Autoregressive Video Diffusion", "Focused Forcing"]
summary: "训练免费的细粒度 KV 选择：按生成帧选历史、用注意力+多样性打分、按 head 重要性分配预算，加速 AR 视频扩散"
pdf-url: "Attachments/2040_Focused_Forcing_Content_A.pdf"
source-url: ""
github-url: ""
---

# Focused Forcing
## 一句话摘要
Focused Forcing 把长视频自回归扩散里的 KV cache 压缩从“整段共享一个历史窗口”改成“每个生成帧、每个 attention head 单独决定该看哪些历史帧”，并用注意力相关性、多样性和 head 重要性共同分配 KV 预算；它不训练新模型，只在推理时替换 KV 选择策略，在 Self Forcing、LongLive、Rolling Forcing、Causal Forcing 上都能获得约 $1.31\times$ 到 $1.48\times$ 端到端加速，同时保持甚至提升 VBench-Long 质量指标。

## PDF
[[Attachments/2040_Focused_Forcing_Content_A.pdf]]

## 核心问题
自回归视频扩散会按帧或按 chunk 逐步生成长视频。越往后生成，可用历史越长，KV cache 也越大；如果每一步都对完整历史做 attention，显存和计算会随 rollout 长度持续增长。

已有长视频方法通常用 sliding window、rolling KV、attention sink 或按 attention score 选择历史帧来压缩 KV。但论文指出这些设计仍然太粗：

- **chunk-level shared selection**：同一个生成 chunk 内的所有帧共用一组选中的历史帧。
- **attention-only ranking**：主要按 attention score 排序历史帧，容易把 attention 中的时间位置偏置误当成内容重要性。
- **coarse head budget**：不同 attention head 使用统一预算或启发式预算，没有显式估计 head 对生成质量的影响。

这篇论文的关键观察是：长视频 AR 生成里的“该保留哪些历史”不是一个全局问题，而是细粒度的上下文分配问题。不同生成帧可能需要不同历史帧；不同 head 对生成质量的影响也不同。

## 背景设定
把视频拆成自回归单元：

$$
p(x_{1:N})=\prod_{i=1}^{N}p(x_i\mid x_{<i})
$$

其中 $x_i$ 可以是一帧，也可以是一个 chunk。在 chunk-wise 生成中，当前 chunk 有 $F_q$ 个 query frames，历史 KV cache 中有 $F_h$ 个 historical frames：

$$
Q=[Q^{(1)},\ldots,Q^{(F_q)}],\qquad K=[K^{(1)},\ldots,K^{(F_h)}]
$$

$Q^{(f)}$ 表示第 $f$ 个生成帧的 query tokens，$K^{(t)}$ 表示第 $t$ 个历史帧的 key tokens。普通压缩方法往往先把 query 维度聚合掉，再为整个 chunk 选择一套历史帧；Focused Forcing 则保留 query-frame 维度，为每个 query frame 单独选择历史。

## 方法总览
Focused Forcing 由三部分组成：

1. **Head-wise budget allocation**：先离线估计每个 layer-head 的重要性，重要 head 保留更多历史帧，不重要 head 保留更少。
2. **Query-frame-wise history selection**：对每个生成帧、每个 head 分别选择历史帧，而不是整个 chunk 共用同一历史集合。
3. **Content-aware scoring + VarLen attention**：历史帧分数由 attention relevance 和 diversity 共同决定；选出来的不规则 KV 序列用 variable-length FlashAttention 打包计算。

它是 training-free 方法：不改变模型权重，不额外训练，只需要一次离线 head importance 评估和推理时的 KV 选择/打包。

## 1. Head 重要性与 KV 预算
论文认为，不同 attention head 对生成质量的影响不一样。如果所有 head 都用同样 KV budget，就会出现两类浪费：

- 重要 head 被过度压缩，破坏长期一致性或运动质量；
- 不重要 head 保留太多历史，浪费 attention 计算。

因此它对每个 layer-head pair $m=(\ell,h)$ 做 masking：在 denoising rollout 中屏蔽这个 head 的输出，得到扰动后的 latent trajectory $\tilde z^{(m)}$。然后用 distribution matching loss 衡量生成分布偏离程度：

$$
L_{\mathrm{DM}}(x)
=
\frac{1}{2}
\left\|
x-\mathrm{sg}\left(x-g_{\mathrm{DM}}(x_t,t)\right)
\right\|_2^2
$$

其中

$$
g_{\mathrm{DM}}(x_t,t)
=
w_t\alpha_t
\left(
s_{\mathrm{fake}}(x_t,t)-s_{\mathrm{real}}(x_t,t)
\right)
$$

$s_{\mathrm{fake}}$ 和 $s_{\mathrm{real}}$ 分别表示生成分布与目标分布的 score function，$w_t$ 是时间步权重，$\alpha_t$ 是 signal scaling coefficient，$\mathrm{sg}(\cdot)$ 表示 stop-gradient。直觉上，mask 某个 head 后 $L_{\mathrm{DM}}$ 越大，说明这个 head 对生成质量越关键。

对 prompt 集合 $\mathcal P$ 和采样 temporal windows $\mathcal W$ 求平均，得到 head 重要性：

$$
I_m
=
\frac{1}{|\mathcal P||\mathcal W|}
\sum_{p\in \mathcal P}
\sum_{w\in \mathcal W}
L_{\mathrm{DM}}\left(\tilde z^{(m)}_{p,w}\right)
$$

再把 $I_m$ 归一化：

$$
\hat I_m
=
\frac{I_m-I_{\min}}{I_{\max}-I_{\min}+\epsilon}
$$

最后映射到离散 KV budget：

$$
b_m
=
\mathrm{round}
\left(
b_{\min}
+
\hat I_m^{\gamma}(b_{\max}-b_{\min})
\right)
$$

$b_{\min}$ 和 $b_{\max}$ 控制每个 head 至少/至多保留多少历史帧，$\gamma$ 控制预算曲线。这样更重要的 head 会拥有更大历史窗口。

## 2. 按生成帧选择历史帧
论文的一个关键实证观察是：同一个 chunk 内不同 query frame 的历史依赖并不相同。比如生成第 $22$ 帧和第 $24$ 帧时，它们最需要参考的历史帧可能不同；而且同一个历史帧因为相对时间距离变化，attention score 也会变化。

因此 Focused Forcing 不再做：

$$
\text{one selected history set for the whole chunk}
$$

而是做：

$$
\text{one selected history set for each }(q_f,h)
$$

也就是每个 query frame $q_f$、每个 head $h$ 都有自己的历史帧集合。这样可以保留对特定生成帧重要的历史，而不是被 chunk 平均分数淹没。

## 3. Attention + Diversity 的内容感知打分
只看 attention score 不够，因为 attention 会受相对时间距离影响。为此论文加入 historical frame diversity，让“和历史平均状态差异更大”的帧更容易被保留。

### Attention score
为了降低打分成本，论文先把每帧 token 分成 $P$ 组，得到 pooled query/key：

$$
\bar Q\in \mathbb R^{B\times QF\times P\times H\times D},
\qquad
\bar K\in \mathbb R^{B\times KF\times P\times H\times D}
$$

对 batch $b$、query frame $q_f$、historical frame $k_f$、head $h$，帧级 attention score 为：

$$
A_{b,q_f,h,k_f}
=
\frac{1}{P^2}
\sum_{u=1}^{P}
\sum_{v=1}^{P}
\frac{
\left\langle
\bar Q_{b,q_f,u,h},
\bar K_{b,k_f,v,h}
\right\rangle
}{\sqrt D}
$$

然后在 historical-frame 维度标准化，得到 $\tilde A_{b,q_f,h,k_f}$。

### Diversity score
对第 $k_f$ 个历史帧的 key：

$$
K^{(k_f)}\in \mathbb R^{B\times L\times H\times D}
$$

先计算历史帧平均 key：

$$
\bar K^{\mathrm{mean}}_{b,l,h}
=
\frac{1}{F_h}
\sum_{k_f=1}^{F_h}
K^{(k_f)}_{b,l,h}
$$

再用 cosine similarity 衡量某个历史帧和平均历史表示的接近程度：

$$
R_{b,h,k_f}
=
\frac{1}{L}
\sum_{l=1}^{L}
\left\langle
\frac{K^{(k_f)}_{b,l,h}}{\left\|K^{(k_f)}_{b,l,h}\right\|_2+\epsilon},
\frac{\bar K^{\mathrm{mean}}_{b,l,h}}{\left\|\bar K^{\mathrm{mean}}_{b,l,h}\right\|_2+\epsilon}
\right\rangle
$$

如果某帧和平均历史很像，说明它冗余；如果差异大，说明它可能包含新内容、动作变化或场景变化。论文把 diversity 定义为负冗余：

$$
D_{b,h,k_f}=-R_{b,h,k_f}
$$

标准化后得到 $\tilde D_{b,q_f,h,k_f}$，并广播到每个 query frame。

### 最终选择分数
最终分数是 attention 和 diversity 的加权和：

$$
S_{b,q_f,h,k_f}
=
\lambda \tilde A_{b,q_f,h,k_f}
+
(1-\lambda)\tilde D_{b,q_f,h,k_f}
$$

然后按当前 layer-head 的 budget $b_{\ell,h}$ 选 Top-K：

$$
\mathcal S_{b,q_f,h}
=
\mathrm{TopK}_{k_f}
\left(
S_{b,q_f,h,k_f},\,b_{\ell,h}
\right)
$$

$\lambda$ 控制 attention relevance 和 content diversity 的权衡。论文实验显示，纯 attention 或过高 attention weight 都不是最佳；中等 $\lambda$ 能更好兼顾质量和文本对齐。

## 4. 用 Variable-Length FlashAttention 执行不规则 KV
因为每个 query frame、每个 head 选出的历史帧可能不同，KV 长度不再整齐。如果直接转成 dense mask，会浪费大量计算。Focused Forcing 采用 packed variable-length attention：

$$
O_{\mathrm{pack}}
=
\mathrm{VarLenFlashAttn}
\left(
Q_{\mathrm{pack}},
K_{\mathrm{pack}},
V_{\mathrm{pack}},
\mathrm{cu}_q,
\mathrm{cu}_k
\right)
$$

$\mathrm{cu}_q$ 和 $\mathrm{cu}_k$ 记录 packed query 与 key/value 的 cumulative boundaries。attention 只在被选中的历史帧上计算，输出再 scatter 回原始 query layout。

这个实现细节很重要：Focused Forcing 的收益不只是“理论上少看一些帧”，而是通过 VarLen FlashAttention 让不规则选择真的转化为 attention latency 降低。

## 实验设置
论文在两个维度评估：

- **跨 AR 生成范式兼容性**：把 Focused Forcing 插入 Self Forcing、LongLive、Rolling Forcing、Causal Forcing，并和原始 baseline 比较。
- **和加速方法比较**：以 chunk-wise Self Forcing 为 base，对比 Attention Sink、MonarchRT、TaylorSeer、Dummy Forcing。

评测使用 VBench-Long，取 MovieGen prompts 中前 $128$ 个，并用 Qwen2.5-7B-Instruct refine。指标包括生成延迟、self-attention 延迟、Subject Consistency、Background Consistency、Motion Smoothness、Dynamic Degree、Aesthetic Quality、Imaging Quality、Visual Quality、Text Alignment 等。

## 主要结果
### 跨生成范式
Focused Forcing 在多个 AR 视频扩散范式上都能加速：

| Backbone | Gen. Latency | Speedup | Visual Quality | Text Alignment |
|---|---:|---:|---:|---:|
| Self Forcing | 78.06s | $1.00\times$ | 76.58 | 28.03 |
| Self Forcing + Ours | 53.90s | $1.45\times$ | 80.00 | 28.75 |
| LongLive | 90.06s | $1.00\times$ | 76.18 | 29.06 |
| LongLive + Ours | 68.60s | $1.31\times$ | 77.91 | 29.40 |
| Rolling Forcing | 83.35s | $1.00\times$ | 75.71 | 28.85 |
| Rolling Forcing + Ours | 58.20s | $1.43\times$ | 77.97 | 28.99 |
| Causal Forcing | 77.99s | $1.00\times$ | 84.40 | 26.80 |
| Causal Forcing + Ours | 52.68s | $1.48\times$ | 84.81 | 28.27 |

最明显的是 Self Forcing：端到端从 $78.06$s 降到 $53.90$s，同时 Visual Quality 从 $76.58$ 提升到 $80.00$，Dynamic Degree 从 $41.55$ 提升到 $61.39$。这说明它不是单纯牺牲质量换速度，而是通过更合理的历史选择减少了一部分冗余/干扰上下文。

### 和其他加速方法比较
在 Self Forcing 上，Focused Forcing 的 attention speedup 和 Dummy Forcing 接近，但质量更高：

| Method | Attn. Speedup | Gen. Speedup | Visual Quality | Text Alignment |
|---|---:|---:|---:|---:|
| Self Forcing | $1.00\times$ | $1.00\times$ | 76.58 | 28.03 |
| Attention Sink | $1.00\times$ | $1.00\times$ | 79.20 | 28.42 |
| MonarchRT | $1.13\times$ | $1.08\times$ | 78.65 | 29.24 |
| TaylorSeer | $1.25\times$ | $1.13\times$ | 78.57 | 28.85 |
| Dummy Forcing | $2.79\times$ | $1.46\times$ | 78.38 | 28.57 |
| Focused Forcing | $2.77\times$ | $1.45\times$ | 80.00 | 28.75 |

这组结果显示它的定位很清楚：不是 fastest attention compression，而是更好的 speed-quality trade-off。Dummy Forcing 稍微快一点点，但 Focused Forcing 的视觉质量更高。

## 消融实验结论
### KV budget
预算不能越小越好。适中的 $b_{\min}$ / $b_{\max}$ 能显著提升 attention speedup 且维持高视觉质量；过度压缩会带来质量下降。这符合方法直觉：长视频中确实存在大量冗余历史，但运动相关、身份相关、背景一致性相关的历史不能被全部砍掉。

### Attention weight
所有 $\lambda$ 设置都优于 Self Forcing，但 visual quality 在中等 attention weight 附近最好；$\lambda$ 过高时，方法退化为更接近 attention-only selection，质量和文本对齐会略降。这支持论文的核心判断：attention relevance 需要 diversity 纠偏。

## 和同目录方法的关系
- **Self Forcing / Causal Forcing**：主要解决训练-推理错配或 AR distillation 问题；Focused Forcing 不改训练目标，而是在推理时压缩 KV cache。
- **LongLive / Rolling Forcing**：更关注实时/流式长视频生成的 rollout 组织；Focused Forcing 可以作为插入式 attention/KV 选择模块。
- **MemoryPack / Memory Forcing**：更像“设计新的长短期记忆结构或空间记忆”；Focused Forcing 更像“在已有历史 KV 中做细粒度选择”。
- **Dummy Forcing**：同样强调 head-wise KV cache，但 Focused Forcing额外加入 query-frame-wise selection 和 diversity-aware scoring，因此选择粒度更细。

## 局限
- 论文主要在 VBench-Long 和几个代表性 AR 视频扩散范式上验证，尚未覆盖更高分辨率、更多模型架构和真实部署硬件。
- 当前使用固定 $b_{\min}$、$b_{\max}$ 和固定 $\lambda$，不同模型、分辨率、延迟目标下可能需要自适应预算。
- 加速收益依赖具体硬件和 attention kernel；如果 VarLen FlashAttention 或 packing/scatter 开销不理想，实际 speedup 可能打折。
- head importance 需要离线 masking rollout 估计，虽然不训练模型，但并非完全零成本。
- PDF 是匿名 NeurIPS 2026 submission，当前未看到公开 arXiv/OpenReview 页面；作者、代码与最终版本信息可能后续变化。

## 复现抓手
如果要复现/改造这篇方法，核心实现点不是公式本身，而是四个工程接口：

1. 从 causal DiT attention 中拿到按 frame 分组的 $Q,K,V$。
2. 离线构建 layer-head budget table $\Pi_{\mathrm{KV}}=\{b_{\ell,h}\}$。
3. 在线为每个 $(q_f,h)$ 计算 attention score、diversity score，并选出 Top-K historical frames。
4. 把不规则选出的 QKV 打包进 VarLen FlashAttention，再 scatter 回原 layout。

其中最容易出错的是维度对应关系：selection 的粒度是 query frame $\times$ head，而不是 chunk $\times$ layer；budget 的粒度是 layer $\times$ head，而不是全局常数。

## 相关链接（双向）
- [[Autoregressive Video Generation]]
- [[KV Cache]]
- [[Self-Forcing]]
- [[Causal Forcing]]
- [[Rolling-Forcing]]
- [[LongLive]]
- [[MemoryPack]]
