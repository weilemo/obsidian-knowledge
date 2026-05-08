---
created: 2026-04-08
published: 2023-11-30
type: paper
status: 已读
tags: [DMD, DiffusionDistillation, OneStepGeneration, ScoreMatching, TextToImage]
aliases: [Distribution Matching Distillation, One-step Diffusion with Distribution Matching Distillation, DMD]
summary: "将多步扩散模型蒸馏为单步生成器：用分布匹配梯度（真实score-伪造score）+ 回归正则稳定训练。"
pdf-url: "https://arxiv.org/pdf/2311.18828"
source-url:
  - https://arxiv.org/abs/2311.18828
  - https://arxiv.org/html/2311.18828v4
  - https://tianweiy.github.io/dmd/
---

# One-step Diffusion with Distribution Matching Distillation

## Abstract
论文提出 DMD（Distribution Matching Distillation），目标是在不显著牺牲图像质量的前提下，将昂贵的多步扩散采样蒸馏为单步生成。核心思想是直接做分布层面的对齐，而不是强制对齐 teacher 的逐步采样轨迹。训练时把近似 KL 梯度写成两类 score 的差：真实分布 score 与生成分布 score；再配合一个回归正则项稳定训练。论文在 ImageNet-64×64 和 zero-shot COCO 上报告了优于当时已发布 few-step 方法的结果。

## 1 Introduction
扩散模型质量高，但采样慢，通常需要几十到上百次网络前向。已有蒸馏方法多在学习“teacher 的噪声到图像映射”，但在复杂高维映射下容易退化。本文改为“只约束输出分布接近 teacher”，不强制一一对应的采样路径。

作者的关键观察是：
- 预训练扩散模型可以给出“把样本往更真实方向推”的 score 信息；
- 若再训练一个跟踪当前生成分布的 fake score 模型，就能得到“更真实且更不像假样本”的联合梯度方向；
- 仅靠分布匹配仍可能不稳，因此加入 paired 回归损失作为正则，保住模式覆盖与结构一致性。

## 2 Related Work
论文将相关工作分为三类：
- Diffusion Model：强调扩散在图像/音频/视频的高质量生成能力，但推理代价高。
- Diffusion Acceleration：包括快速求解器（20-50步）与蒸馏范式（单步/少步）；指出单纯轨迹蒸馏仍存在质量差距。
- Distribution Matching：将其与 GAN/GMMN 以及 VSD 关联，强调 DMD 是“用 score 近似做分布匹配”，并通过回归项增强稳定性与可扩展性。

## 3 Distribution Matching Distillation

### 3.1 Pretrained base model and One-step generator
给定预训练扩散 teacher（base model）$D_\theta$，训练 one-step 生成器 $G_\phi$，使其从噪声 $z\sim\mathcal{N}(0,I)$ 一次前向得到样本：
$$
x_0 = G_\phi(z)
$$
实现上，$G_\phi$ 使用与 teacher 去噪器同构的骨干（去掉时间条件），并用 teacher 权重初始化。

### 3.2 Distribution Matching Loss
目标是让生成分布 $p_\phi$ 逼近真实分布 $p_{\text{data}}$，以 KL 形式写作：
$$
\min_\phi\; D_{KL}(p_\phi\,\|\,p_{\text{data}})
$$
其梯度可写为 score 差驱动的形式（论文 Eq.2 思想）：
$$
\nabla_\phi D_{KL}
\propto
\mathbb{E}\left[\left(s_\phi(x)-s_{\text{data}}(x)\right)\frac{\partial x}{\partial \phi}\right]
$$
其中 $s_{\text{data}}$ 与 $s_\phi$ 分别是真实/生成分布 score。由于原始分布支撑不重叠与低概率区数值问题，论文在扩散噪声层面估计 score：
$$
x_t = \alpha_t G_\phi(z) + \sigma_t\epsilon,\quad \epsilon\sim\mathcal{N}(0,I)
$$
并使用两个扩散模型近似 real/fake 的 diffused score（论文 Eq.4,5 的思想）。最终得到时间步期望下的分布匹配梯度（Eq.7），并引入随时间变化的权重做梯度归一化（Eq.8）。

### 3.3 Regression loss and final objective
论文指出仅靠分布匹配在小噪声区域容易不稳定，可能出现 mode dropping，因此加入 paired regression。先离线构建噪声-图像对：
- 输入噪声 $z$；
- 用 teacher 的确定性 ODE 采样器生成对应图像 $y$。

回归项写作（Eq.9 思想）：
$$
\mathcal{L}_{\text{reg}} = \mathbb{E}_{(z,y)}\big[d\big(G_\phi(z),y\big)\big]
$$
其中 $d(\cdot,\cdot)$ 采用 LPIPS。最终训练目标是分布匹配梯度与回归项联合优化，同时在线更新 fake score 模型。

### 3.4 Distillation with classifier-free guidance
对文本生成场景，论文给出 CFG 适配：
- paired 数据由 guided teacher 采样构建；
- real score 用 guided teacher 的均值预测替换；
- fake score 分支保持原形式；
- 训练时固定 guidance scale。

## 4 Experiments

### 4.1 Class-conditional Image Generation
在 ImageNet-64×64，单步 DMD 报告 FID 2.62（表 1），相对当时多种 one-step/few-step 蒸馏基线显著提升，并接近 teacher（EDM，FID 2.32）。论文强调在几乎不损质量的同时达到数量级加速。

### 4.2 Ablation Studies
论文对两个关键组件做消融：
- 去掉 Distribution Matching：图像真实性与结构显著下降；
- 去掉 Regression：训练不稳、易模式塌缩。

并比较不同时间权重策略，作者提出的权重（Eq.8）在 CIFAR 上优于 DreamFusion/ProlificDreamer 风格权重。

### 4.3 Text-to-Image Generation
在 Stable Diffusion v1.5 蒸馏设置下（LAION-Aesthetic 训练，zero-shot COCO 评测）：
- DMD 1-step 报告 FID 11.49、延迟约 0.09s；
- teacher（SD1.5）FID 8.78、延迟约 2.59s。

论文还报告高 guidance（如 8）设置：DMD 在同等 1-step 延迟下显著优于若干 4-step 加速基线，并保持更高 CLIP 对齐。

## 5 Limitations
论文明确的限制包括：
- 与高步数 teacher（100/1000 NFE）相比仍有轻微质量差距；
- 同时微调 generator 与 fake score 模型，训练显存压力较大；
- 可考虑 LoRA 等方式降低训练成本。

## 补充理解（本次疑惑点）
- 这里的“轨迹”在数学上是生成过程的时间参数化路径 $\{x_t\}_{t\in[0,T]}$；轨迹蒸馏更像对齐路径/时间演化，DMD 则主要对齐终点分布而非逐步路径。
- student 和 teacher 的核心差别通常不是参数量，而是推理步数与时间离散方式；很多蒸馏设定里 student 架构可与 teacher 同量级，只是把多步采样压缩成一步或少步。
- score 不是“打分”，而是对数密度梯度：
$$
s_p(x)=\nabla_x \log p(x)
$$
它表示“当前样本往哪个方向移动会更像该分布的高概率区域”。
- DMD 的分布匹配项负责集合级约束：让当前生成分布 $p_\phi$ 朝真实/teacher 分布靠近；teacher 在这里不只提供初始化与 paired target，还提供 real score，作为“往哪边更真实”的梯度代理。
- 回归项是 paired regression：
$$
\mathcal{L}_{\text{reg}}=\mathbb{E}_{(z,y)}[d(G_\phi(z),y)]
$$
其中 $y$ 由 teacher 对同一噪声 $z$ 的确定性采样得到。它提供点对点锚点，主要负责稳住训练、抑制 mode dropping，并保住 teacher 的大结构/构图骨架。
- `mode dropping` 指只学到真实分布中的部分模式而漏掉其他模式，本质是覆盖不足而非单纯“画质差”。纯分布匹配更易出现这一问题，因为它只有分布级约束，没有“同一个噪声应对应哪类输出”的配对约束。
- 小噪声区域训练不稳的直觉是：此时分布更尖锐、局部曲率更大，real/fake score 的估计误差会被放大；仅靠分布匹配时，梯度更容易 noisy。回归项相当于给生成器加了一根“拴住 teacher 结构”的绳子。
- “在线更新 fake score 模型”指 fake diffusion model 不是固定的，而是随着 student 分布变化持续更新，用来近似当前生成分布的 noisy score；real score 基本来自固定的预训练 teacher。

## 相关链接（双向）
- [[Distribution Matching Distillation]]
- [[Diffusion Distillation]]
- [[Text-to-Image]]
