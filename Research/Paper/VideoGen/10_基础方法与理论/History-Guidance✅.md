---
created: 2026-01-25
published: 2025-02-10
type: paper
status: 已读
tags:
  - HistoryGuidance
  - VideoDiffusion
  - CFG
  - TemporalConsistency
aliases:
  - History-Guidance
summary: DFoT支持可变历史指导提升一致性
pdf-url: Attachments/arxiv_2502.06764.pdf
github-url: ""
source-url:
  - https://arxiv.org/abs/2502.06764
  - https://arxiv.org/html/2502.06764
  - https://boyuan.space/history-guidance
---

# History-Guided Video Diffusion

## PDF
[[Attachments/arxiv_2502.06764.pdf]]

## Abstract
论文从一个很自然但长期未被系统化的问题出发：视频扩散能否像 CFG 一样，对“历史帧条件”做可组合指导？作者指出直接把 CFG 套到可变长度历史上会遇到结构和训练两方面障碍。为此提出 Diffusion Forcing Transformer（DFoT），通过“每帧独立噪声”让模型在训练分布内支持任意历史子集条件；在此基础上提出 History Guidance 家族。实验表明，最简单的 Vanilla History Guidance 已显著提升画质与时序一致性，而跨时间与频率的组合指导进一步改善动态性、OOD 历史鲁棒性，并支持超长视频稳定 rollout。

## 1 Introduction
论文的核心问题是：
- 现有视频扩散里的 CFG 通常依赖文本/单图条件；
- 但视频生成真正重要的条件往往是“已有历史帧集合”（history）。

作者希望把 history 从“固定长度提示”升级为“可变长度、可选子集、可按频率处理”的条件变量，并指出这是当前 VDM 体系难以直接实现的。

论文贡献可概括为三点：
- 提出 DFoT，使模型可在采样时对任意历史部分条件化。
- 提出 History Guidance（HG）家族：Vanilla / Temporal / Fractional 及其组合 HG-tf。
- 在长视频生成与鲁棒历史条件场景展示显著优势，并给出 ELBO 理论支撑。

## 2 Challenges when Guiding with History
论文先形式化 history-conditioned 目标。设视频帧索引集合为 $\mathcal{T}=\{1,\dots,T\}$，历史索引 $\mathcal{H}\subset\mathcal{T}$，待生成索引 $\mathcal{G}=\mathcal{T}\setminus\mathcal{H}$，目标是建模 $p(x_{\mathcal{G}}\mid x_{\mathcal{H}})$。

history 版 CFG 形式为：
$$
\nabla \log p_k(x_{\mathcal{G}}^k)
+ \omega\left[\nabla \log p_k(x_{\mathcal{G}}^k\mid x_{\mathcal{H}})-\nabla \log p_k(x_{\mathcal{G}}^k)\right]
$$

作者指出两大障碍：
- 固定长度条件架构：常见 DiT/U-Net 条件注入（AdaLN/通道拼接）本质上绑定固定条件长度。
- Framewise Binary Dropout 效果差：虽然可模拟“随机历史子集”，但 token 利用率低（大量帧参与注意力却不贡献损失），长视频更明显。

## 3 The Diffusion Forcing Transformer

### 3.1 Noise as Masking
DFoT 延续 Diffusion Forcing 的“噪声即掩码”视角：
- $k_t=0$ 代表该帧未掩码（干净）；
- $k_t=1$ 代表该帧完全掩码；
- 中间噪声对应部分掩码。

### 3.2 History as Noise-Free Frames
将 history 条件化写成统一噪声分配：
$$
k_t=
\begin{cases}
0, & t\in\mathcal{H}\\
k, & t\in\mathcal{G}
\end{cases}
$$
即历史帧作为 clean token 与生成帧共同输入同一个全序列 Transformer，不再把 history 当外部独立条件分支。

### 3.3 Training with Per-frame Independent Noise
与传统“全帧同噪声”不同，DFoT 对每帧独立采样噪声，训练目标为：
$$
\mathbb{E}_{k_{\mathcal{T}},x_{\mathcal{T}},\epsilon_{\mathcal{T}}}
\left[\|\epsilon_{\mathcal{T}}-\epsilon_\theta(x_{\mathcal{T}}^{k_{\mathcal{T}}},k_{\mathcal{T}})\|^2\right]
$$

论文给出理论结论：该目标对应一个重加权但有效的 ELBO 优化。

这带来两点关键收益：
- 更高 token 利用率（损失覆盖全部帧，不是只在随机子集上学习）；
- 可变历史长度被“放进训练分布”，为采样时灵活 history 提供支持。

### 3.4 Sampling with Arbitrary History
采样时，直接输入 noisy 的待生成帧与 clean 的任意历史子集帧，即可估计条件分数并用 DDPM/DDIM 等标准采样器生成。

## 4 History Guidance

### 4.1 Vanilla History Guidance (HG-v)
最简单 HG 就是对任意历史做 CFG。
无条件分数是条件分数的特例：令历史子集为空（或历史全掩码）即可得到 $\nabla\log p_k(x_{\mathcal{G}}^k)$。

### 4.2 History Guidance Across Time and Frequency
论文把 HG 推广到组合分数形式：
$$
\nabla\log p_k(x_{\mathcal{G}}^k)
+\sum_i \omega_i\left[
\nabla\log p_k(x_{\mathcal{G}}^k\mid x_{\mathcal{H}_i}^{k_{\mathcal{H}_i}})
-\nabla\log p_k(x_{\mathcal{G}}^k)
\right]
$$

其意义是：
- `time` 轴：组合不同历史时间窗口的条件分数；
- `frequency` 轴：组合不同噪声等级（频率信息保留程度）的历史分数。

### 4.3 Temporal History Guidance (HG-t)
HG-t 通过组合长短历史或多个短窗口历史分数，缓解长历史 OOD 条件导致的崩坏/过拟合问题，在保留长期依赖的同时提升稳定性。

### 4.4 Fractional History Guidance (HG-f)
作者发现 HG-v 在大 guidance scale 下会“趋静态”（复制最近帧）。
HG-f 用部分噪声历史做指导，相当于更多保留低频一致性、放松高频细节约束，从而在不破坏一致性的情况下提升运动动态。

其公式写作：
$$
\nabla\log p_k(x_{\mathcal{G}}^k\mid x_{\mathcal{H}})
+\omega\left[
\nabla\log p_k(x_{\mathcal{G}}^k\mid x_{\mathcal{H}}^{k_{\mathcal{H}}})
-\nabla\log p_k(x_{\mathcal{G}}^k)
\right]
$$
其中 $k_{\mathcal{H}}\in(0,1)$ 控制历史掩码强度。

### 4.5 Time Axis / Frequency Axis 的具体实现（补充）
论文中两条轴都可写成同一个“组合分数”框架：
$$
s_{\text{total}}
=
s_{\text{uncond}}
+
\sum_i \omega_i\left(s_i-s_{\text{uncond}}\right),
\quad
s_i=\nabla\log p_k(x_{\mathcal{G}}^k\mid x_{\mathcal{H}_i}^{k_{\mathcal{H}_i}})
$$
其中 $s_{\text{uncond}}$ 是无条件分数（历史全掩码）。

`Time axis`（Temporal HG）的实现要点：
1. 选多个历史子集 $\mathcal{H}_i$（如长窗+短窗，或多个重叠短窗）。
2. 令所有子集的历史噪声都为 $k_{\mathcal{H}_i}=0$（干净历史）。
3. 各自前向得到 $s_i$，再按 $\omega_i$ 与 $s_{\text{uncond}}$ 组合。

`Frequency axis`（Fractional HG）的实现要点：
1. 历史子集可固定（通常同一 $\mathcal{H}$）。
2. 改变历史噪声强度 $k_{\mathcal{H}}\in(0,1)$，得到部分加噪历史 $x_{\mathcal{H}}^{k_{\mathcal{H}}}$。
3. 用部分加噪历史求分数并参与组合；$k_{\mathcal{H}}$ 越大，通常越偏向低频一致性、放松高频细节约束。

`HG-tf`（time+frequency 同时用）可按如下采样模板执行：
1. 先算 $s_{\text{uncond}}$。
2. 遍历多个 $(\mathcal{H}_i, k_{\mathcal{H}_i}, \omega_i)$ 配置，分别算 $s_i$。
3. 组合成 $s_{\text{total}}$，再用 DDIM/DDPM 的一步更新推进采样。

## 5 Experiments

### 5.1 Experimental Setup
- 数据：Kinetics-600（128x128）、RE10K（256x256）、Minecraft（256x256）以及机器人 imitation learning 任务。
- 基线：
  - SD（固定历史长度条件扩散）；
  - BD（二值 history dropout，作为 DFoT 训练目标消融）；
  - FS（全序列扩散 + reconstruction guidance）。
- 指标：FVD、VBench（质量/一致性/动态性分项）、确定性任务用 frame-wise LPIPS。

### 5.2 Evaluating DFoT as a Base Model
不使用 HG 时，DFoT 仍是强基线。
Kinetics-600 对比中（同架构设置）：
- DFoT(scratch) FVD 4.3，优于 SD 4.8、BD 6.4、FS 95.5；
- 从 FS 微调 12.5% 训练成本得到的 DFoT 也可达 4.7，证明迁移改造可行。

### 5.3 Improving Video Generation via HG
- HG-v：随着 guidance 增强，帧质量与一致性提高；但 scale 过高会损失多样性，FVD 出现反弹。
- HG-f：显著缓解“高 guidance 静态化”。论文报告最佳 FVD 从 HG-v 的 181.6 进一步降到 170.4；并显著优于 FS（1040）、SD（247.5）、DFoT 无指导（208.0）。

### 5.4 New Abilities via Temporal HG
论文给出三类新能力：
- OOD 历史鲁棒：在 RE10K 极端视角变化插帧中，HG-t 可通过拆分短窗口并组合分数保持连贯。
- 长上下文生成（Minecraft）：FVD 从 97.63 提升到 79.19。
- 长程记忆 + 反应式控制（机器人）：成功率 83%，而基线无法完整完成任务。

### 5.5 Ultra Long Video Generation
论文展示单图扩展到 862 帧 RE10K 导航视频。作者认为这依赖于：
- DFoT 的可变历史条件能力；
- HG 在质量、一致性和 rollout 稳定性上的联合提升。

## 6 Conclusion
DFoT 把“任意历史条件化”变成可训练、可采样的统一框架；HG 则把这项能力转化为可控生成收益。整体上，该工作把 history 从固定输入升级为可组合指导信号，为长视频一致性、动态性与可扩展 rollout 提供了统一路径。

## Impact Statement
论文强调了视频生成增强能力的双重性：一方面可服务于机器人与内容生产，另一方面也存在被滥用生成有害内容的风险，应结合负责任使用规范。

## Acknowledgements
论文致谢了合作与资助支持（详见原文致谢部分）。

## 相关链接（双向）
- [[历史条件生成]]
- [[视频扩散]]
- [[Diffusion-Forcing ✅]]
