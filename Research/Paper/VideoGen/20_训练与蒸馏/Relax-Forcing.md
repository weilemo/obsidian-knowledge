---
created: 2026-04-29
published: 2026-03-22
type: paper
status: 未读
tags:
  - RelaxForcing
  - VideoGeneration
  - Streaming
  - KVCache
  - LongVideo
  - TrainingFree
aliases:
  - Relax Forcing
  - Relax Forcing: Relaxed KV-Memory for Consistent Long Video Generation
summary: 通过将历史记忆拆成 Sink、History、Tail 三种角色，并用 relaxed KV scoring 动态选取中程历史帧，在不加训练目标的前提下提升长视频动态性、一致性与推理效率
pdf-url: Attachments/arxiv_2603.21366.pdf
github-url: ""
source-url:
  - https://arxiv.org/abs/2603.21366
  - https://doi.org/10.48550/arXiv.2603.21366
---

# Relax Forcing: Relaxed KV-Memory for Consistent Long Video Generation

## PDF
- [[Attachments/arxiv_2603.21366.pdf]]

## 一句话摘要
Relax Forcing 的核心不是“多保留一点历史”，而是把历史拆成 `Sink / History / Tail` 三种功能角色，再用一个兼顾稳定性与去冗余的打分机制动态选中真正有价值的中程历史帧。

## Abstract
这篇论文的判断很鲜明：长视频生成的问题不主要是 memory 不够，而是 memory 用得太“平均”了。作者通过实验发现，单纯增加历史帧数量并不会稳定提升长程生成，反而常常压制 motion dynamics；同时，历史帧放在时间轴上的位置会显著影响运动演化，却对画质影响较小。基于这个观察，论文提出 `Relaxed KV Memory`，把时间记忆拆成负责全局锚定的 `Sink`、负责短期连续性的 `Tail`，以及负责中程运动结构的 `History`。其中 `History` 不是按时间顺序硬保留，而是按一个 relaxed score 动态挑选。最终方法在 `VBench-Long` 上提升了动态度和整体得分，并减少了 attention 开销。

## 1 Introduction
论文讨论的是自回归视频扩散在分钟级生成里的一个常见误区：大家容易把问题看成“上下文不够长”，于是倾向于保留更多历史帧。但作者指出，更多历史未必更好，尤其在 rolling rollout 场景中，密集 chronological memory 会带来两类副作用：
- 冗余历史不断累积，错误随 rollout 传播。
- 过多近期或连续历史会把运动“钉住”，导致画面稳定但动作僵硬、重复。

因此这篇论文不是继续改训练目标，而是直接追问一个更底层的问题：在 autoregressive video diffusion 中，什么样的历史才值得在推理时继续保留？

## 2 Related Work
论文把自己放在三条线之间：
- `Autoregressive Video Diffusion`：`CausVid`、`Self Forcing`、`Rolling Forcing`、`Deep Forcing` 等都在做长视频 rollout。
- `Forcing` 路线：前面的工作更多在训练上缓解 train-inference mismatch 或 exposure bias。
- `KV / Memory Selection`：本工作更关心的是推理阶段如何组织历史，而不是再对模型做新的长时蒸馏。

它与 `Deep Forcing` 很像，都是 training-free 地改 KV memory；但 `Deep Forcing` 更强调深 sink 与参与式压缩，这篇则先从分析出发，把记忆角色拆得更明确，再做结构化选择。

## 3 Methods

### 3.1 Preliminaries
在第 $i$ 个生成步，传统 sliding-window inference 使用的是一段连续的稠密历史：
$$
c^{<i}=\hat{x}^{i-L:i}
$$
其中 $L$ 是注意力窗口长度。问题在于，这种历史是“时间上连续但功能上未区分”的，模型会把所有历史都当成同质条件来读。

Relax Forcing 的目标是把这段稠密 buffer 改造成结构化记忆，让不同时间位置的历史承担不同角色。

### 3.2 Temporal Memory Analysis for Long Video Extrapolation
这篇论文最重要的部分其实是分析，而不是公式本身。作者先系统测试了不同 memory 配置，得到三个关键观察：

第一，增加 memory 数量并不单调提升效果。无论增加 `Sink`、`History` 还是 `Tail`，视觉质量大多变化不大，但 `Dynamic Degree` 往往先升后降，说明过多历史会限制运动演化。

第二，历史的时间位置非常重要。在固定 memory budget 下，从不同 temporal position 选择 history frame，会显著改变 motion dynamics，但对 image quality 和 visual consistency 影响较小。这说明历史并不是可互换的，尤其是中程历史更像“运动结构信号”而不是“外观稳定信号”。

第三，不同 memory 组件对应不同 failure mode：
- 没有 `Sink`：容易 temporal drift。
- 没有 `History`：运动演化变弱，视频更容易重复。
- 没有 `Tail`：短期连续性变差，动作变僵。

因此论文的核心结论是：temporal memory 本身是 heterogeneous 的，不能继续当成单一 chronological buffer 对待。

### 3.3 Relaxed KV Memory

#### 3.3.1 三段式记忆拆分
在第 $i$ 个 rollout step，历史帧被拆成三部分：
$$
\hat{x}^{<i}=\mathcal{S}\cup\mathcal{M}_{i}^{cand}\cup\mathcal{T}_{i}
$$
其中：
- $\mathcal{S}$ 是固定 `Sink`，负责长期全局锚定。
- $\mathcal{T}_{i}$ 是 step-dependent `Tail`，负责最近的短期连续性。
- $\mathcal{M}_{i}^{cand}$ 是中间候选区域，从中再选择真正进入 `History` 的帧。

作者进一步只从候选区域的后半段挑选中程历史：
$$
\tilde{\mathcal{M}}_{i}
=
\left\{
h\in\mathcal{M}_{i}^{cand}
\mid
\mathrm{idx}(h)\geq \tfrac{1}{2}\lvert\mathcal{M}_{i}^{cand}\rvert
\right\}
$$
这个设计对应论文的经验观察：真正有帮助的中程历史往往更靠近 middle region 的后半段。

#### 3.3.2 Relaxation Score
对每个候选 history frame $h$，先用其 token 的平均 key 构造 prototype：
$$
\tilde{K}_{h}
=
\mathrm{norm}
\left(
\frac{1}{\lvert\Omega(h)\rvert}
\sum_{k\in\Omega(h)} K_k
\right)
$$
同时定义 `Sink` 与 `Tail` 的聚合 prototype $\tilde{K}_{\mathcal{S}}$ 和 $\tilde{K}_{\mathcal{T}_i}$。

然后分别计算：
$$
S(h)=\tilde{K}_{h}^{\top}\tilde{K}_{\mathcal{S}},
\qquad
R(h)=\tilde{K}_{h}^{\top}\tilde{K}_{\mathcal{T}_{i}}
$$
其中：
- $S(h)$ 衡量它与全局锚点的一致性，代表稳定性价值。
- $R(h)$ 衡量它与近期上下文的相似性，代表冗余程度。

最终 relaxed score 定义为：
$$
r(h)=S(h)-\lambda R(h)
$$
这里 $\lambda$ 控制“保全局稳定”与“去近期冗余”之间的权衡。也就是说，好的 history frame 既要和 sink 对齐，能提供全局稳定；又不能和 tail 太像，否则只是重复最近信息。

#### 3.3.3 Top-K History Selection
选出的 `History` 为：
$$
\mathcal{H}_{i}
=
\mathrm{TopK}\big(\{r(h)\}_{h\in\tilde{\mathcal{M}}_{i}}\big)
$$
最终真正参与当前生成的结构化记忆为：
$$
\mathcal{M}_{i}
=
\mathcal{S}\cup\mathcal{H}_{i}\cup\mathcal{T}_{i}
$$

和传统 dense chronological buffer 相比，这里保留的是“功能互补的少量历史”，不是“时间上连续的一长串历史”。

## 4 Experiments

### 4.1 Experimental Settings
- 评测基准：`VBench-Long`
- Prompt 集：128 个 `MovieGen` prompts
- 对比方法：`CausVid`、`Self Forcing`、`Rolling Forcing`、`LongLive`、`Deep Forcing`
- 额外评测：human preference 和 latency profiling

论文还给出了一组很关键的默认配置：
- `Sink = 2`
- `History = 1`
- `Tail = 1`

配合当前 3-frame block，这使有效 self-attention 长度从 baseline 的 21 帧降到 7 帧。

### 4.2 Comparisons to State of the Art
主结果里，论文最强调的是“整体得分第一 + 动态度提升明显”。

在 30 秒设置下，Relax Forcing 的结果为：
- `FPS = 16.33`
- `Subject Consistency = 96.99`
- `Background Consistency = 96.12`
- `Aesthetic Quality = 60.13`
- `Imaging Quality = 68.50`
- `Motion Smoothness = 97.80`
- `Dynamic Degree = 65.67`
- `Average = 80.87`

在 60 秒设置下，结果为：
- `FPS = 16.33`
- `Subject Consistency = 96.81`
- `Background Consistency = 95.97`
- `Aesthetic Quality = 59.58`
- `Imaging Quality = 68.66`
- `Motion Smoothness = 97.74`
- `Dynamic Degree = 66.49`
- `Average = 80.88`

这两个数字很有代表性：
- 30 秒时它比 training-free 基线 `Deep Forcing` 的平均分 `79.94` 更高。
- 60 秒时它仍保持 `80.88`，而很多基线会出现更明显退化。

论文把最核心的提升归因于 `Dynamic Degree`。也就是说，它的优势不是单纯更锐利或更稳，而是更能在长时 rollout 中维持“持续演化的运动”。

### 4.3 Ablation Analysis
这篇消融的重点不是“有无模块”，而是“不同 memory 设计到底怎么影响运动与稳定性”。

几个关键结论：

1. 最优 memory 组合是 `Sink=2, History=1, Tail=1`。
- 作者明确写到，最佳配置来自 `Sink=2, History=1, Tail=1`，兼顾最高 overall score 和强 dynamic degree。

2. `Sink` 太少会 drift，太多会 over-constrain。
- 当 `Sink` 从 0 增到 2 时，整体分数显著上升；
- 但再继续加，会让 `Dynamic Degree` 下滑，因为全局锚点太多会限制运动自由度。

3. `History` 的价值主要体现在 motion progression。
- 加入 1 个 `History` frame，就能把 `Dynamic Degree` 从 `61.15` 提到 `65.62`；
- 再继续增加 history 数量，收益开始消失，甚至会因为冗余而回落。

4. `Tail` 也不能太多。
- 单个 `Tail` frame 在短期连续性与运动自由度之间平衡最好；
- 当 `Tail` 从 1 增到 3，`Dynamic Degree` 会明显下降，说明过度依赖 recent context 会把动作钉死。

5. 候选池不宜过大。
- 论文发现 candidate pool 在 2 到 4 帧时表现稳定；
- 超过这个范围后，采样到的候选帧在时间内容上越来越冗余，反而削弱 sparse selection 的收益。

6. $\lambda$ 不敏感。
- 冗余权重 $\lambda$ 在较宽区间内都能稳定工作，说明这个 relaxed scoring 机制不是特别依赖精细调参。

### 4.4 Human Evaluation
用户偏好实验比较的是 `Relax Forcing`、`Self Forcing`、`Attention Sink`、`Rolling Forcing`。论文报告的偏好占比如下：

- `Relax Forcing`
  - `VQ = 44.6`
  - `MQ = 65.4`
  - `TA = 51.5`
  - `AVG = 53.8`
- `Rolling Forcing`
  - `VQ = 43.1`
  - `MQ = 21.5`
  - `TA = 32.3`
  - `AVG = 32.3`

这组结果说明它最明显的优势在 `Motion Quality`，和论文主张完全一致：结构化 memory 的主要收益是让长视频既稳又不僵。

### 4.5 Efficiency
Relax Forcing 不只是质量更好，速度也更快。论文的 latency profiling 给了几组关键数字：
- effective attention length：`21 -> 7`
- flash attention：`444.2 ms -> 168.1 ms`，约 `2.64\times`
- total self-attention：`678.5 ms -> 430.8 ms`，约 `1.58\times`
- diffusion generation：约 `1.37\times`
- end-to-end：约 `1.26\times`

虽然它多了一个 candidate scoring 步骤，但这部分只有 `3.4 ms`，大约占 diffusion runtime 的 `0.8%`，远小于 attention 缩短带来的收益。

## 5 Conclusion
Relax Forcing 的真正贡献，不只是又设计了一个 KV selection trick，而是把长视频 rollout 里的 memory 问题重新拆开了：
- `Sink` 解决长期稳定；
- `History` 负责中程运动结构；
- `Tail` 保住最近连续性。

这篇论文最值得记住的点是：历史越多不代表越好，关键是历史在时间轴上承担什么功能。如果把所有历史都塞进同一个 dense chronological buffer，模型反而更容易 drift、重复或 motion collapse。

## 相关链接（双向）
- [[Self-Forcing ✅]]
- [[Deep-Forcing✅]]
- [[Reward-Forcing]]
- [[Rolling-Forcing✅]]
- [[Self-Forcing++]]
- [[长视频生成]]
- [[流式视频生成]]
