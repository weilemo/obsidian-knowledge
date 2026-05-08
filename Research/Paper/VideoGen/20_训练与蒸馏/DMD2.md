---
created: 2026-04-08
published: 2024-05-23
type: paper
status: 已读
tags: [DMD2, DiffusionDistillation, OneStepGeneration, MultiStepGeneration, TTUR, GAN]
aliases: [Improved Distribution Matching Distillation for Fast Image Synthesis, DMD2]
summary: "在 DMD 基础上去回归、引入 TTUR+GAN+backward simulation，并扩展到多步生成，显著提升质量与可扩展性。"
pdf-url: "https://arxiv.org/pdf/2405.14867"
source-url:
  - https://arxiv.org/abs/2405.14867
  - https://arxiv.org/html/2405.14867v2
  - https://tianweiy.github.io/dmd2/
  - https://github.com/tianweiy/DMD2
---

# Improved Distribution Matching Distillation for Fast Image Synthesis

## Abstract
本文提出 DMD2，对 DMD 的训练流程进行系统改进。核心问题是：原始 DMD 为了稳定训练依赖回归损失和大规模 noise-image paired 数据，代价高且把 student 绑在 teacher 轨迹上。DMD2 的改进包括：去回归、用 TTUR 稳定纯分布匹配、引入 GAN 损失接触真实数据、支持多步 student，并通过 backward simulation 缓解训练-推理输入失配。论文在 ImageNet 与 COCO 上报告了明显提升，并在若干设定下超过 teacher。

## 1 Introduction
作者指出 few-step 蒸馏长期存在“速度提升与质量下降”的矛盾。DMD 的分布匹配思想优于纯轨迹模仿，但受回归正则牵制：
- 训练前需要大量 paired 数据，尤其对 SDXL 级别非常昂贵；
- student 难以超越 teacher，因为回归项逼迫复刻 teacher 路径。

DMD2 的主线是“把分布匹配做纯、做稳、做强”：
- 去掉回归项；
- 通过不同更新频率让 fake critic 跟上生成分布漂移；
- 加 GAN 分支补齐真实数据监督；
- 把方法从 one-step 扩展到 multi-step，并修复训练-推理失配。

## 2 Related Work
论文回顾三类工作并给出定位：
- Diffusion Distillation：PD/Consistency/TRACT/CTM 等主要沿轨迹或一致性蒸馏；
- GAN-based Distillation：ADD/LADD/UFOGen/Lightning 等用对抗学习加强分布对齐；
- Score Distillation 到 DMD：DMD 用“real score - fake score”近似 KL 梯度，稳定但依赖回归 paired 数据。

DMD2 的定位是把 DMD 从“有效但受回归约束”升级为“无需回归且可扩展到高分辨率 few-step”。

## 3 Background: Diffusion and Distribution Matching Distillation
论文先重述扩散与 DMD 基础。

扩散模型在噪声层面的 score 与去噪预测关联（Eq.1）。DMD 的核心梯度（Eq.2）可写为：
$$
\nabla_\phi \mathcal{L}_{\text{DMD}}
\propto
\mathbb{E}_{t,\epsilon,z}\left[
\left(s_{\text{real}}(x_t,t)-s_{\text{fake}}(x_t,t)\right)
\frac{\partial G_\phi(z)}{\partial \phi}
\right]
$$
其中
$$
x_t=\Psi(G_\phi(z),t)=\alpha_t G_\phi(z)+\sigma_t\epsilon
$$
原始 DMD 额外使用 paired regression（Eq.3）：
$$
\mathcal{L}_{\text{reg}}=\mathbb{E}_{(z,y)}\left[d\big(G_\phi(z),y\big)\right]
$$
DMD2 认为这一步在大规模 T2I 下成本过高且限制上限。

## 4 Improved Distribution Matching Distillation

### 4.1 Removing the regression loss: true distribution matching and easier large-scale training
第一步直接移除回归项，保留“纯分布匹配”。这样不再需要离线构建海量 paired 数据，训练链路显著简化，也避免 student 被 teacher 轨迹硬约束。

### 4.2 Stabilizing pure distribution matching with a Two Time-scale Update Rule
去回归后训练会抖动。论文将不稳定归因于 fake score 模型对非平稳生成分布跟踪不足。解决方案是 TTUR：
- fake score 更新频率高于 generator；
- 论文给出有效设置约为 5:1（fake:generator）。

这使得无回归版本能恢复到接近 DMD 的稳定性与质量。

### 4.3 Surpassing the teacher model using a GAN loss and real data
在 DMD 框架中引入 GAN 分支，让模型直接利用真实图像监督，缓解 teacher real score 近似误差。论文采用轻量集成：在 fake diffusion denoiser 的 bottleneck 上接分类头，使用标准 non-saturating GAN 目标（Eq.4 思想）。

该目标同样是分布级监督，不依赖 paired 数据，和 DMD 目标更一致。

### 4.4 Multi-step generator
DMD 原本面向 one-step。DMD2 扩展到 few-step：固定时间调度，在每步交替进行去噪与前向扩散（与一致性模型风格相近）。

论文给出 4-step 例子（teacher 1000-step 设定）时间表：
$$
[999,\;749,\;499,\;249]
$$

### 4.5 Multi-step generator simulation to avoid training/inference mismatch
以往多步蒸馏常用“noisy real image”训练中间步，但推理中中间输入来自 student 上一步输出，导致域失配。DMD2 用 backward simulation：
- 训练时就让 student 先跑若干步生成中间状态；
- 再对这些“推理态输入”施加损失。

这样减小 train-test gap，提升多步质量与稳定性。

### 4.6 Putting everything together
完整训练循环交替两部分：
- 更新 generator：分布匹配损失 + GAN 生成器损失；
- 更新 fake critic：去噪 score matching + GAN 判别损失；
并保持 TTUR（高频更新 fake critic）。

## 5 Experiments

### 5.1 Class-conditional Image Generation
ImageNet-64×64 上：
- DMD: FID 2.62
- DMD2: FID 1.51
- DMD2 + longer training: FID 1.28
- teacher (EDM ODE): FID 2.32

说明 DMD2 在单步条件下已明显优于原 DMD，并可达到/超过 teacher 的部分设定。

### 5.2 Text-to-Image Synthesis
在 SDXL 蒸馏（COCO 子集评测）上，论文报告 DMD2 的 1-step/4-step 在 FID、Patch FID、CLIP 上与 teacher 接近，且推理步数显著更少。

在 SD v1.5 线（附录表）中，DMD2 one-step 报告 FID 8.35，并优于原始 DMD。论文的人评也显示 DMD2 在视觉偏好和文本对齐上优于若干蒸馏基线，并在部分样本上超过 teacher 偏好。

### 5.3 Ablation Studies
关键消融结论：
- 仅去回归会退化（训练不稳）；
- 加 TTUR 可把“无回归 DMD”拉回稳定区间；
- 再加 GAN 可继续提升；
- 对 SDXL 4-step，去 GAN、去 distribution matching、去 backward simulation 都会造成明显质量或对齐下降。

## 6 Limitations
论文给出的主要限制：
- 相比 teacher，仍有轻微多样性下降；
- 对大模型（如 SDXL）通常仍需 4-step 才能稳定逼近 teacher 质量；
- 常用固定 guidance 训练，灵活性受限；
- 大规模训练算力开销仍高。

## 7 Broader Impact
正向影响：降低高质量图像生成成本，促进创作工具与内容生产。负向风险：误导性内容、伪造身份与数据偏见扩散。论文建议配套检测/防滥用机制与公平性改进方向。

## 8 Acknowledgements
论文致谢了评测与工程协作贡献者，并说明了主要经费支持来源。

## 相关链接（双向）
- [[Distribution Matching Distillation]]
- [[Diffusion Distillation]]
- [[GAN for Diffusion]]
