---
created: 2026-01-25
type: paper
status: unread
tags: [CausalDiffusion, Distillation, Streaming, VideoGeneration]
aliases: [CausVid]
summary: "双向扩散蒸馏为低延迟因果生成器"
pdf-url: "Attachments/arxiv_2412.07772v1.pdf"
github-url: ""
---

# From Slow Bidirectional to Fast Causal Video Generators (CausVid)
## PDF
- [[Attachments/arxiv_2412.07772v1.pdf]]
## 一句话摘要
CausVid 通过因果注意力 + DMD 蒸馏，把双向扩散模型压缩为少步流式生成器，显著降低延迟。

## 核心贡献
- 将双向视频扩散蒸馏为因果生成器，实现低延迟流式输出。
- 采用 DMD 进行分布匹配蒸馏，并引入非对称蒸馏策略。
- 使用教师 ODE 轨迹初始化学生模型，稳定训练。

## 方法/模型（实现细节）
### 1) 扩散建模基础
前向噪声过程：
$$x_t = \alpha_t x_0 + \sigma_t\epsilon,\quad \epsilon\sim\mathcal{N}(0,I)$$
噪声预测训练目标：
$$\mathcal{L}(\theta)=\mathbb{E}_{t,x_0,\epsilon}\|\epsilon_\theta(x_t,t)-\epsilon\|_2^2$$
得分函数：
$$s_\theta(x_t,t)=\nabla_{x_t}\log p(x_t)=-\frac{\epsilon_\theta(x_t,t)}{\sigma_t}$$

### 2) 因果注意力结构
将视频 latent 序列按块划分，块内双向注意力、块间因果注意力。
注意力掩码：
$$M_{i,j}=\begin{cases}1,&\lfloor j/k\rfloor\le\lfloor i/k\rfloor\\0,&\text{otherwise}\end{cases}$$
这使当前块无法访问未来块，但保留块内局部双向信息。

### 3) DMD 蒸馏与非对称监督
DMD 近似最小化生成分布与数据分布的反向 KL，梯度形式：
$$\nabla_\phi L_{DMD}\approx-\mathbb{E}_t\left[(s_{data}(\Psi(G_\phi(\epsilon),t),t)-s_{gen}(\Psi(G_\phi(\epsilon),t),t))\,\frac{dG_\phi(\epsilon)}{d\phi}\right]$$
关键设计：
- **ODE 初始化**：用教师生成 ODE 轨迹对学生预训练，避免直接蒸馏不稳定。
- **非对称蒸馏**：用双向教师监督因果学生，避免从弱因果教师继承误差。

## 实验与结果
- 128 帧视频初始延迟约 1.3s，之后约 9.4 FPS 流式输出。
- 与传统双向扩散相比延迟大幅降低，质量保持接近。

## 局限与注意事项
- 训练依赖高质量双向教师模型。
- 块大小与蒸馏步数需平衡速度与质量。

## 相关链接（双向）
- [[因果视频扩散]]
- [[流式视频生成]]
- [[扩散蒸馏]]
