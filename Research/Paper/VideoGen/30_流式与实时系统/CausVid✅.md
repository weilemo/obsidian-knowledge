---
created: 2026-01-25
published: 2024-12-10
type: paper
status: 已读
tags:
  - CausVid
  - Autoregressive
  - DMD
  - Streaming
  - VideoGeneration
  - KVCache
aliases:
  - CausVid
summary: 把高质量双向视频扩散蒸馏成 few-step 因果生成器，通过因果结构改造、非对称 DMD 蒸馏、ODE 初始化和 KV cache，实现低延迟流式视频生成
pdf-url: Attachments/arxiv_2412.07772.pdf
github-url: https://github.com/tianweiy/CausVid
source-url:
  - https://arxiv.org/abs/2412.07772
  - https://causvid.github.io/
  - https://github.com/tianweiy/CausVid
---

# From Slow Bidirectional to Fast Autoregressive Video Diffusion Models

## PDF
- [[Attachments/arxiv_2412.07772.pdf]]

## 一句话摘要
`CausVid` 的核心贡献是把本来必须“看完整段未来”的双向视频扩散模型，改造成能按时间顺序一边生成一边输出的因果视频生成器，再用 `DMD` 把 `50-step` 教师蒸馏成 `4-step` 学生，从而把高质量视频扩散第一次真正推向低延迟流式生成。

## Abstract
这篇论文抓住了视频扩散走向交互式应用时最根本的瓶颈：现有高质量视频扩散模型虽然效果强，但生成任意一帧都要依赖整段视频上下文，包括未来帧，所以推理时必须整段一起算，延迟非常大，不适合实时或交互式系统。`CausVid` 的思路是先把双向视频扩散 Transformer 改造成自回归因果结构，让模型能按块顺序生成；再把原本 `50-step` 的扩散过程蒸馏成 `4-step` few-step 生成器，进一步压低计算成本。为了让这个蒸馏过程稳定，作者又补了两个关键设计：一是用教师的 `ODE trajectory` 先初始化学生，避免直接蒸馏发散；二是用双向教师去监督因果学生，而不是让因果学生跟随因果教师，从而减少误差积累的继承。最终它在单卡上实现了约 `1.3s` 初始延迟和 `9.4 FPS` 的流式生成，并支持长视频、image-to-video、streaming video-to-video translation 和 dynamic prompting。

## 1 Introduction
论文的出发点非常直接：
- 双向视频扩散模型质量高，但推理时必须访问未来帧，天然高延迟。
- 交互式视频生成、世界模型、游戏渲染等场景要求的是“当前帧尽快吐出来”，而不是整段算完再看。

所以作者要解决的问题不是单纯“把视频做长”，而是把原本离线、整段式的视频扩散，改造成可流式、可交互、可持续 rollout 的因果生成器。

这篇论文的重要性在于它做了一个范式转换：
- 以前高质量视频扩散几乎都默认是 bidirectional / offline。
- `CausVid` 证明了这类模型可以被系统性地转写成 autoregressive / streaming 形态，而且质量并不会完全崩掉。

## 2 方法直觉
扩散建模本身仍是标准形式。给定干净样本 $x_0$，前向加噪写作：
$$
x_t=\alpha_t x_0+\sigma_t \epsilon,\qquad \epsilon\sim\mathcal{N}(0,I)
$$
传统视频扩散的问题不在扩散公式，而在 Transformer 的时序依赖方式：双向注意力让当前帧可以看未来帧，因此推理时不可能边生成边显示。

`CausVid` 的解决思路可以拆成两步：
- 先改结构：把双向视频 DiT 变成因果生成器。
- 再改推理成本：把 many-step 扩散蒸馏成 few-step 生成器。

如果只做第一步，模型虽然因果了，但还是很慢，而且质量容易掉；如果只做第二步，但结构仍然双向，也无法流式输出。所以这篇论文真正有价值的是把“因果化”和“few-step distillation”绑定到了一起。

## 3 Method

### 3.1 Causal Architecture
作者并没有把模型粗暴改成逐 token 单向注意力，而是采用块级因果结构：把视频按 chunk 切分，chunk 内允许双向建模，chunk 间使用因果顺序。

其掩码可以写成：
$$
M_{i,j}=
\begin{cases}
1, & \left\lfloor \frac{j}{k}\right\rfloor \le \left\lfloor \frac{i}{k}\right\rfloor \\
0, & \text{otherwise}
\end{cases}
$$
其中 $k$ 是 chunk 大小。这个设计的含义是：
- 当前 chunk 不能访问未来 chunk；
- 但 chunk 内部仍保留局部双向建模能力。

这是一种很实际的折中。它没有把视频生成彻底离散成 LLM 式逐 token 预测，而是尽量保留原视频扩散对局部时空结构的建模能力，同时获得可流式 rollout 的时序约束。

### 3.2 Asymmetric DMD Distillation
结构改成因果之后，作者继续用 `DMD` 做分布匹配蒸馏，把高成本教师压到 few-step 学生。

核心直觉是：不再逐步模仿教师的全部去噪轨迹，而是直接让学生生成分布向教师/数据分布靠拢。对应梯度形式可以写成“两个 score 的差”：
$$
\nabla_\phi \mathcal{L}_{\mathrm{DMD}}
\approx
-\mathbb{E}\left[
\left(s_{\mathrm{data}}-s_{\mathrm{gen}}\right)
\frac{\partial G_\phi}{\partial \phi}
\right]
$$
这里最关键的不是公式本身，而是论文强调的 `asymmetric` 设置：
- 学生是因果模型；
- 教师仍然是双向模型。

这点非常重要。因为如果让因果学生去模仿一个已经会积累误差的因果教师，那么长时误差会被一并蒸馏进去；而用更强的双向教师监督，学生能继承更高质量的局部视频先验。

### 3.3 Student Initialization via Teacher ODE Trajectories
直接从随机初始化开始做视频版 `DMD` 非常不稳，所以作者先用教师产生的 `ODE solution pairs` 对学生做预初始化。

你可以把这一步理解为：
- 先让学生学会落在“合理的视频扩散解轨道附近”；
- 再用 DMD 去做真正的 few-step 分布压缩。

论文的消融说明这一步不是小技巧，而是训练能否站稳的关键。没有 ODE 初始化时，few-step 学生的 frame quality 会明显掉下去。

### 3.4 Efficient Inference with KV Caching
做成因果结构以后，推理时就可以保留历史的 KV cache，而不必每次重算全部过去上下文。

这使得模型具备两个核心能力：
- 初始等待时间显著下降；
- 一旦进入稳定阶段，后续帧可以连续流式输出。

从系统角度看，`CausVid` 的真正突破不是某个单独 loss，而是“因果结构 + few-step + KV cache”三者组合后，第一次把高质量视频扩散拉进了接近实时的交互区间。

## 4 Experiments

### 4.1 Setup
- 任务：text-to-video 为主，同时测试 long video、streaming V2V、I2V
- 教师：双向 many-step 视频扩散模型
- 学生：因果 few-step 生成器
- 蒸馏：`50-step -> 4-step`
- 推理：单 GPU，KV cache 流式生成

从最新 arXiv 版本和项目页给出的主结果看，它在 `VBench-Long` 上达到 `84.27`，并在当时验证榜单上排名第一。

### 4.2 Main Results
这篇论文最亮眼的数字有三类。

第一类是实时性：
- 生成 `120` 帧、`10` 秒视频时，`Latency = 1.3 s`
- `Throughput = 9.4 FPS`
- 对比 bidirectional teacher 的 `219.2 s / 0.6 FPS`，延迟和吞吐都发生了数量级变化

第二类是短视频质量：
- `10` 秒文本生成里，`Temporal Quality = 94.7`
- `Frame Quality = 64.4`
- `Text Alignment = 30.1`

第三类是长视频能力：
- `30` 秒长视频评测里，`Temporal Quality = 94.9`
- `Frame Quality = 63.4`
- `Text Alignment = 28.9`

论文强调的是：它不是只换来速度，质量也基本进入了第一梯队。尤其在 long video 上，它比多数 autoregressive 基线更能抑制误差累积。

## 4.3 Ablation
消融部分非常有信息量，因为它把这篇论文的三层贡献拆开验证了。

第一，单纯把双向模型改成 many-step causal model 并不够：
- 双向教师：`Temporal 94.6 / Frame 62.7 / Text 29.6`
- many-step causal：`Temporal 92.4 / Frame 60.1 / Text 28.5`

说明“只因果化不蒸馏”会明显掉质量，而且会出现更强的 error accumulation。

第二，`bidirectional teacher` 明显优于 `causal teacher`：
- `ODE init + causal teacher` 时，`Frame Quality = 61.7`
- `ODE init + bidirectional teacher` 时，`Frame Quality = 64.4`

这正是 `asymmetric distillation` 的价值：别让一个本身已经带因果误差的老师来教学生。

第三，`ODE initialization` 很关键：
- 没有 ODE init、只用 `None` teacher 的 few-step 模型，`Frame Quality` 只有 `48.1`
- 加上 `ODE init + bidirectional teacher` 才到最终最好结果

所以这篇论文不是“随便拿个 DMD 就蒸出来了”，而是训练稳定性几乎全靠 `ODE init` 和 `asymmetric teacher` 两个设计托住。

## 4.4 Applications
这篇论文另一个很强的点，是它没有把自己局限在 text-to-video。

### Streaming Video-to-Video
在 streaming V2V 上：
- `StreamV2V`：`Temporal 92.5 / Frame 59.3 / Text 26.9`
- `CausVid`：`Temporal 93.2 / Frame 61.7 / Text 27.7`

### Zero-shot Image-to-Video
在无需额外训练的 I2V 上：
- `CogVideoX-5B`：`Temporal 87.0 / Frame 64.9 / Text 28.9`
- `Pyramid Flow`：`Temporal 88.4 / Frame 60.3 / Text 27.6`
- `CausVid`：`Temporal 92.0 / Frame 65.0 / Text 28.9`

这说明 `CausVid` 的 autoregressive 结构本身就很适合“给一个起点，然后继续往后滚”的生成任务，因此自然支持动态 prompt、I2V、视频续写和流式编辑。

## 5 我对这篇论文的理解
如果说后面的 `Self Forcing`、`Rolling Forcing`、`Deep Forcing` 都是在修补“自回归视频扩散滚久了会出问题”这件事，那么 `CausVid` 做的是更前一层的工作：它先证明了“高质量双向视频扩散可以被成功改造成自回归流式系统”。

从谱系上看，它的重要性主要有三点：
- 它把 bidirectional video diffusion 正式带进了 streaming/autoregressive 范式。
- 它把 `DMD` 从图像/一般生成蒸馏扩展到视频 few-step streaming 场景。
- 它奠定了后面很多工作默认采用的 recipe：`causalization + few-step distillation + KV cache`。

但它也留下了后续工作的主要改进方向：
- 它虽然能长 rollout，但训练输出分布和真实自回归推理分布还没有完全对齐。
- 它依赖 sliding window，因此很远的历史会被丢掉。
- chunk 边界和长程记忆问题还没有真正解决。

这也是为什么后面的 `Self Forcing` 会更强调 train-test gap，而 `Rolling Forcing` 会进一步改造推理单元本身。

## 6 Limitations
论文明确提到几类局限：
- 长程一致性仍有限。Sliding window 只保留大约 `10` 秒上下文，超出窗口的历史会被截断，所以当很早出现过的物体或场景重新回来时，可能出现不一致。
- chunk 边界有时间不连续。VAE 是按 chunk 解码的，缺少跨 chunk 依赖，因此相邻片段边界会有 flicker 或不平滑。
- DMD 会牺牲一些输出多样性。作者明确指出这是 reverse-KL 类分布匹配目标的典型副作用。
- 延迟虽然已经下降很多，但仍受当前 VAE 设计限制，因为必须先生成一段 latent frames 才能解码出像素。

## 相关链接（双向）
- [[Self-Forcing ✅]]
- [[Rolling-Forcing✅]]
- [[流式视频生成]]
