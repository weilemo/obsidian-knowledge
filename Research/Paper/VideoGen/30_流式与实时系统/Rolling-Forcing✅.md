---
created: 2026-01-25
published: 2025-09-29
type: paper
status: 已读
tags:
  - RollingForcing
  - Autoregressive
  - Streaming
  - AttentionSink
  - DMD
  - RollingWindow
aliases:
  - Rolling-Forcing
summary: 在 Self Forcing 式流式视频扩散上，引入滚动窗口联合去噪、attention sink 与扩展窗口蒸馏，显著降低长时 rollout 的误差累积，并在单卡上实现接近 16 FPS 的多分钟实时生成
pdf-url: Attachments/arxiv_2509.25161.pdf
github-url: https://github.com/TencentARC/RollingForcing
source-url:
  - https://arxiv.org/abs/2509.25161
  - https://kunhao-liu.github.io/Rolling_Forcing_Webpage/
  - https://github.com/TencentARC/RollingForcing
---

# Rolling Forcing: Autoregressive Long Video Diffusion in Real Time

## PDF
- [[Attachments/arxiv_2509.25161.pdf]]

## 一句话摘要
Rolling Forcing 的核心不是再去破坏历史或提前规划未来，而是在严格流式生成顺序不变的前提下，把“逐帧因果去噪”改成“滚动窗口联合去噪”，再配上 `attention sink` 和面向长窗口的蒸馏训练，从而把长视频里的误差累积压到非常低。

## Abstract
这篇论文要解决的是实时流式视频生成里的老问题：一旦模型按自回归方式一帧一帧往前滚，早期的小误差就会不断传到后面，最终出现颜色漂移、主体变形、运动异常和整体质量塌缩。`Rolling Forcing` 的判断是，问题不一定非要靠打乱历史或先生成远未来来解决，而可以直接在局部去噪机制上动手。它让多个相邻帧在一个滚动窗口里一起去噪，并给这些帧分配递增噪声级别，使窗口内部能互相纠错；同时把最初几帧的 KV 缓存长期保留为全局锚点，并通过动态 `RoPE` 防止时间位置错位；训练时再用非重叠扩展窗口做 few-step distillation，并始终基于模型自生成历史来减轻 exposure bias。最终它在单张 GPU 上实现了接近实时的多分钟视频流式生成，并把长时误差累积显著压低。

## 1 Introduction
论文讨论的核心矛盾很明确：
- 双向视频扩散模型质量高，但需要整段视频一起去噪，不适合低延迟流式生成。
- 自回归视频扩散天然适合在线逐步输出，但严格逐帧因果会让误差在长 rollout 中不断放大。

作者把已有长视频稳态化路线分成两类：
- `history corruption`：训练或推理时故意污染历史，降低模型对历史真值的依赖，但代价是时序一致性被削弱。
- `planning generation`：先生成远处关键帧再补中间帧，能缓解漂移，但不符合实时系统必须“按顺序立即吐帧”的约束。

`Rolling Forcing` 的位置可以概括成一句话：既不破坏严格顺序，也不牺牲局部一致性，而是在每一步生成时放宽局部帧间的严格因果，让相邻帧在小窗口里先互相修正，再把结果流式吐出来。

## 2 方法直觉
自回归视频扩散仍遵循链式分解：
$$
p(x^{1:N}) = \prod_{i=1}^{N} p(x^i \mid x^{<i})
$$
问题不在这个分解本身，而在于如果每次只独立去噪当前一帧，那么任何局部错误都会直接写入未来上下文。`Rolling Forcing` 的想法是：不要让每一帧都孤立定稿，而是让一个小窗口中的多帧先共同去噪、共同对齐，再从中顺序输出结果。

## 3 Method

### 3.1 Rolling Diffusion Window
这是整篇论文最关键的设计。

不同于 `Self Forcing` / `CausVid` 式的逐帧去噪，`Rolling Forcing` 在每个时间步都维护一个滚动窗口，并对窗口内多个连续帧同时去噪。窗口中的帧会被赋予逐步升高的噪声级别，因此：
- 越靠前的帧更接近最终输出；
- 越靠后的帧更像是“为未来预热的粗草稿”；
- 窗口内帧之间可以通过双向注意力互相修正，避免单帧错误立刻固化。

这相当于一种“局部双向、全局自回归”的折中：
- 从全局看，它仍然按顺序流式输出，满足实时要求；
- 从局部看，它允许相邻帧在最终定稿前彼此协商，减弱逐帧 strict causal 带来的误差放大。

论文强调，这种设计还有一个很重要的工程收益：虽然一次 forward 看了更多帧，但每次 forward 仍能稳定产出一个可输出的干净帧，因此整体吞吐仍能维持实时。

### 3.2 Attention Sink 作为全局锚点
只靠最近历史做 KV cache 虽然能保持局部连贯，但长时间滚动后，颜色、曝光、主体形态这类全局属性还是会慢慢漂。

为此，论文把 `StreamingLLM` 里的 `attention sink` 思想迁到视频扩散里：
- 最近历史帧保留作短时 temporal context；
- 最开始的一小段帧额外永久保留作 global context anchor。

这样模型在生成很后面的帧时，仍能一直“看见”最初建立世界观的那几帧，从而维持主体、场景和色调的长时稳定性。

### 3.3 Dynamic RoPE
视频 DiT 通常使用 `RoPE` 编码相对位置。如果简单把很早的初始帧 KV 永久缓存下来，那么随着生成长度增长，这些最早帧和当前帧之间的相对位置会越来越大，最终超过训练时见过的范围，带来严重错位。

论文的处理方式是：
- 缓存时先保留还没施加 `RoPE` 的全局 key；
- 推理时再按当前窗口位置动态施加时间维 `RoPE`；
- 等价于把最初锚点重新放到“紧挨着当前 temporal context 的位置”。

直觉上，这一步是在冻结“全局锚点相对当前窗口的位置关系”，避免出现论文附录里提到的那种视频突然跳回开头画面的 `jumping artifacts`。

### 3.4 Rolling Forcing Post-Training
训练部分本质上仍是把双向视频扩散模型蒸馏成 few-step 自回归生成器，底层依赖 `DMD`（Distribution Matching Distillation）。

但这里有两个关键难点：
- 滚动窗口比逐帧去噪的 query 更大，直接全量反传会非常吃显存；
- 不同窗口位置的帧对应不同噪声级别，若训练处理不好，会造成不自然的运动和镜头变化。

对应地，论文做了两件事：
- 只对一部分非重叠窗口做梯度回传，用这些窗口拼出训练所需的预测视频，显著降低内存开销；
- 用 `Self Forcing` 训练目标和 `Rolling Forcing` 训练目标各占一半概率交替训练，让前者充当 regularizer，抑制不自然镜头运动。

这点很重要：`Rolling Forcing` 不是把 `Self Forcing` 全盘推翻，而是把它保留成训练正则器，再把真正的推理范式换成 rolling-window。

## 4 Experiments

### 4.1 Setup
- 基座模型：`Wan2.1-T2V-1.3B`
- 路线：先做 causal ODE initialization，再做 `Rolling Forcing` post-training
- 训练：仅训练 `3000` steps，且基于短视频分布训练
- 评测：VBench 质量指标、长视频漂移指标、吞吐与延迟

论文特别强调两点：
- 它建立在公开开源基座上，而不是封闭自研视频模型上；
- 虽然训练域仍主要是 `5` 秒级短视频，但推理时可以稳定外推到多分钟。

### 4.2 Main Results
在与同量级开源自回归/流式视频方法对比时，`Rolling Forcing` 给出的主结果很强：
- 吞吐 `15.79 FPS`，延迟 `0.76 s`，已经达到实时级别；
- `Subject Consistency = 92.80`，显著高于 `Self Forcing` 的 `86.48`；
- `Background Consistency = 93.71`，高于 `Self Forcing` 的 `90.29`；
- `Imaging Quality = 70.75`，高于 `Self Forcing` 的 `68.68`；
- 长时漂移指标 $\Delta IQ = 0.01$，远低于 `CausVid` 的 `2.18` 与 `Self Forcing` 的 `1.66`。

如果只看 full VBench 汇总分，它也占优：
- `Quality Score = 84.08`，高于 `Self Forcing` 的 `81.39` 和 `CausVid` 的 `80.89`
- `Semantic Score = 69.78`，略高于 `Self Forcing` 的 `69.17`

论文的结论并不是“它只是更快”，而是“它几乎在不损失实时性的前提下，把误差累积压到了接近没有的程度”。

### 4.3 Ablation
消融非常说明问题：
- 去掉 `RF inference`，也就是推理时退回逐帧去噪，$\Delta IQ$ 会从 `0.01` 恶化到 `5.53`。
- 去掉 `RF training`，也就是训练和推理都不用 rolling-window，$\Delta IQ$ 也会升到 `0.89`。
- 去掉 `Self Forcing` 正则训练后，一致性和画质都会明显下降，论文指出主要表现为不自然的 camera motion。
- 去掉 `attention sink` 后，`Subject Consistency` 从 `92.80` 掉到 `83.22`，长时漂移重新变得明显。

这里最值得记住的是：
- rolling inference 决定它是不是能真正压住长时误差传播；
- rolling training 决定模型是否真的学会这种新的推理范式；
- `attention sink` 决定它有没有长程全局锚点；
- `SF` 正则决定运动是否自然。

## 方法关系图
![[Rolling-Forcing 方法关系表.excalidraw]]

## 5 我对这篇论文的理解
这篇论文最有价值的 insight 不只是“多加一个窗口”，而是把实时视频生成里的错误来源拆成了两层：
- 局部层面：逐帧 strict causal 去噪让错误来不及在邻近帧之间被修正；
- 全局层面：只有短期 KV cache，没有稳定的长期锚点。

`Rolling Forcing` 恰好一一对应：
- 用 rolling-window joint denoising 解决局部误差固化；
- 用 `attention sink + dynamic RoPE` 解决长期世界观漂移；
- 用扩展窗口蒸馏解决“训练时没见过这种推理分布”的 exposure bias。

所以它比 `Self Forcing` 更进一步的地方，不是更激进地“让训练贴近推理”，而是直接改造了推理单元本身。

## 6 Limitations
论文在附录里提到的局限也很值得记：
- 中间生成过的帧一旦离开 temporal context，就会被丢弃；模型真正长期记住的只有最开始那部分 global anchor，因此它仍然没有“可增长的中段长期记忆”。
- enlarged attention window 配合 `DMD` 训练非常吃显存，扩到更大模型时训练成本会更高。
- rolling-window 会在交互式应用里带来额外延迟，因为未来帧会被部分预生成；作者认为未来可以考虑 interaction 阶段逐帧、非 interaction 阶段 rolling-window 的混合推理策略。

## 相关链接（双向）
- [[Self-Forcing ✅]]
- [[CausVid✅]]
- [[流式视频生成]]
