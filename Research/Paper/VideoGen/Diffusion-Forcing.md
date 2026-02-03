---
created: 2026-01-25
type: paper
status: unread
tags: [DiffusionForcing, SequenceModeling, Autoregressive, Guidance]
aliases: [Diffusion-Forcing]
summary: "逐token噪声融合自回归与扩散生成"
pdf-url: "Attachments/arxiv_2407.01392.pdf"
github-url: ""
---

# Diffusion Forcing: Next-token Prediction Meets Full-Sequence Diffusion
## PDF
- [[Attachments/arxiv_2407.01392.pdf]]
## 一句话摘要
Diffusion Forcing 通过逐 token 独立噪声训练与可组合采样，将自回归可变长度与扩散指导能力结合起来。

## 核心贡献
- 提出 Causal Diffusion Forcing（CDF），在因果结构上训练逐 token 噪声的扩散序列模型。
- 给出训练目标 (3.1)，证明为 ELBO 的重权重形式，覆盖所有噪声序列。
- 引入二维噪声调度网格 $K$，在采样阶段自由控制不同时间步的去噪进度。

## 方法/模型（实现细节）
### 1) 模型结构与状态更新
以 RNN 为例（可替换为 Transformer），维护隐状态 $z_t$：
$$z_t \sim p_\theta(z_t\mid z_{t-1},x^{k_t}_t,k_t)$$
当 $k_t=0$ 时相当于“有信息”观测更新；当 $k_t=K$ 时相当于“无信息”先验更新。

### 2) 训练目标（Diffusion Forcing Loss）
对每个时间步采样独立噪声级别 $k_{1:T}$，最小化：
$$\mathbb{E}_{k_t,x_t,\epsilon_t}\left[\sum_{t=1}^T \|\epsilon_t-\epsilon_\theta(z_{t-1},x^{k_t}_t,k_t)\|_2^2\right]$$
论文指出该目标对应于 ELBO 的重权重形式，并在充分条件下覆盖所有子序列的似然优化。

### 3) 采样机制（二维噪声网格）
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
