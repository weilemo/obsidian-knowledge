---
created: 2026-01-25
published: 2024-07-01
type: paper
status: 已读
tags:
  - DiffusionForcing
  - SequenceModeling
  - Autoregressive
  - Guidance
aliases:
  - Diffusion-Forcing
summary: 逐token噪声融合自回归与扩散生成
pdf-url: Attachments/arxiv_2407.01392.pdf
github-url: ""
---

# Diffusion Forcing: Next-token Prediction Meets Full-Sequence Diffusion
## PDF
- [[Attachments/arxiv_2407.01392.pdf]]
## 一句话摘要
Diffusion Forcing 通过逐 token 独立噪声训练与可组合采样，将自回归可变长度与扩散指导能力结合起来。

## 论文核心图（Noise as Masking / Diffusion Forcing vs Teacher Forcing）
![[Attachments/diffusion-forcing-teaser.png]]

## 核心贡献
- 提出 Causal Diffusion Forcing（CDF），在因果结构上训练逐 token 噪声的扩散序列模型。
- 给出训练目标 (3.1)，证明为 ELBO 的重权重形式，覆盖所有噪声序列。
- 引入二维噪声调度网格 $K$，在采样阶段自由控制不同时间步的去噪进度。

## 与 VDM（Video Diffusion Models）的对比
- 对照论文：[[Video-Diffusion-Models✅]]。
- 总体定位：
  - VDM 更像“全序列联合扩散生成视频块”。
  - Diffusion Forcing 更像“因果 next-token 预测 + 扩散噪声建模”的统一框架。

### 1) 噪声建模粒度
- VDM 常见设定是整段样本共享同一扩散时间步 $t$，即同一噪声强度。
- Diffusion Forcing 为每个时间位置独立采样噪声级别（noise as masking）：
$$
z_i=\alpha_{t_i}x_i+\sigma_{t_i}\epsilon_i,\quad t_i\ \text{可随}\ i\ \text{变化}
$$
这使模型能同时处理“近处低噪声、远处高噪声”的异质时间上下文。

### 2) 架构归纳偏置
- VDM：3D U-Net（空间卷积 + 时间注意力）做全序列去噪，偏向离线块级生成。
- Diffusion Forcing：因果序列模型（论文示例为 RNN，可替换 Transformer），偏向在线滚动与可变长度预测。

### 3) 采样控制方式
- VDM：标准反向扩散链，通常对整段视频统一迭代去噪。
- Diffusion Forcing：引入二维调度矩阵 $K$，可对不同时间位置使用不同去噪进度，实现 next-token 与 full-sequence 两端之间的连续插值。

### 4) 条件生成机制差异
- VDM 在条件采样里讨论了 replacement 的缺口，并用 reconstruction guidance 修正：
$$
\mathbb{E}_q[x^b\mid z_t,x^a]
=
\mathbb{E}_q[x^b\mid z_t]
+
\frac{\sigma_t^2}{\alpha_t}\nabla_{z_t^b}\log q(x^a\mid z_t)
$$
当后项不可闭式计算时，用高斯重建近似得到引导项。
- Diffusion Forcing 的核心不是“先无条件再补条件梯度”，而是训练期就暴露于各种局部噪声/可见性组合，推理时通过噪声调度直接实现条件控制。

### 5) 典型优势与适用场景
- VDM：在固定长度、高保真视频合成上表现强，工程范式成熟。
- Diffusion Forcing：在长时域 rollout、误差累积控制、规划型采样上更灵活。

### 6) 一句话记忆
$$
\text{VDM: Full-Sequence Diffusion}\qquad
\text{Diffusion Forcing: Causal Prediction + Token-wise Diffusion}
$$

## 方法/模型（实现细节）
### 1) 模型结构与状态更新
以 RNN 为例（可替换为 Transformer），维护隐状态 $z_t$：
$$z_t \sim p_\theta(z_t\mid z_{t-1},x^{k_t}_t,k_t)$$
当 $k_t=0$ 时相当于“有信息”观测更新；当 $k_t=K$ 时相当于“无信息”先验更新。

### 2) 训练目标（Diffusion Forcing Loss）
对每个时间步采样独立噪声级别 $k_{1:T}$，最小化：
$$\mathbb{E}_{k_t,x_t,\epsilon_t}\left[\sum_{t=1}^T \|\epsilon_t-\epsilon_\theta(z_{t-1},x^{k_t}_t,k_t)\|_2^2\right]$$
论文指出该目标对应于 ELBO 的重权重形式，并在充分条件下覆盖所有子序列的似然优化。
![[Pasted image 20260307130328.png]]

### 3) 采样机制（二维噪声网格）上图左侧
定义噪声调度矩阵 $K\in[K]^{M\times T}$，行表示“去噪阶段”，列表示时间步。
从全噪声序列开始，按行从上到下、列从左到右逐步去噪，直到 $K_{0,t}=0$。
这种机制允许：
- 只对部分时间步进行更快去噪（可变长度）。
- 在长序列滚动生成时保持一定噪声，避免发散。

## 实验与结果
- 在视频预测与规划任务中，Diffusion Forcing 在长序列生成上稳定性优于传统自回归。
- 可通过不同 $K$ 设计实现“规划型”或“生成型”采样策略。

## 局限与注意事项
- 训练需要对噪声调度空间充分采样，否则泛化受限。
- 采样网格设计需要结合任务需求，否则可能出现过度保守或过度发散。

## 相关链接（双向）
- [[扩散强制]]
- [[自回归生成]]
- [[序列建模]]
