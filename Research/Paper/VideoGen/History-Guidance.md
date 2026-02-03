---
created: 2026-01-25
type: paper
status: unread
tags: [HistoryGuidance, VideoDiffusion, CFG, TemporalConsistency]
aliases: [History-Guidance]
summary: "DFoT支持可变历史指导提升一致性"
pdf-url: "Attachments/arxiv_2502.06764.pdf"
github-url: ""
---

# History-Guided Video Diffusion
## PDF
- [[Attachments/arxiv_2502.06764.pdf]]
## 一句话摘要
History-Guided Video Diffusion 用 DFoT 让“历史帧条件”变成可组合的噪声掩码，并提出多种历史指导策略提升长序列一致性。

## 核心贡献
- 将 Diffusion Forcing 扩展为非因果 Transformer（DFoT），支持可变历史长度条件。
- 提出 History Guidance 家族（vanilla / temporal / fractional），在一致性与动态性之间可调。
- 给出训练目标与 ELBO 证明，确保不同历史条件都处于训练分布内。

## 方法/模型（实现细节）
### 1) CFG 基础与历史条件扩展
传统 CFG：
$$\nabla\log p_k(x^k\mid c)\approx \nabla\log p_k(x^k)+\omega(\nabla\log p_k(x^k\mid c)-\nabla\log p_k(x^k))$$
在视频中，历史帧与生成帧属于同一序列 $x_T$。设历史索引 $H$、生成索引 $G$，目标是 $p(x_G\mid x_H)$。

### 2) 噪声即掩码（Noise-as-Masking）
对每一帧分配噪声等级 $k_t$：
$$k_t=\begin{cases}0,&t\in H\\k,&t\in G\end{cases}$$
历史帧可视作“低噪”或“部分噪声”的条件，从而允许灵活选择历史子集。

### 3) DFoT 训练目标
不同于统一噪声，DFoT 对每帧独立采样噪声：
$$\mathbb{E}_{k_T,x_T,\epsilon_T}\|\epsilon_T-\epsilon_\theta(x_T^{k_T},k_T)\|_2^2$$
该目标对应 ELBO 的重权重形式，保证“任意历史子集”都在训练分布内。

### 4) History Guidance 组合采样
通过同时估计多种“历史掩码”条件分数并线性组合，得到：
- **Vanilla HG**：使用完整历史与无历史分数差。
- **Fractional HG**：只保留历史低频成分，改善动态性。
- **Temporal HG**：对不同时间段历史加权，提升 OOD 历史鲁棒性。

## 实验与结果
- 在 Kinetics-600 等数据集上显著提升 FVD 与一致性指标。
- Vanilla HG 提升一致性但可能静态；Fractional HG 改善动态性。

## 局限与注意事项
- 多分数组合增加采样开销。
- 高 guidance scale 可能牺牲多样性。

## 相关链接（双向）
- [[历史条件生成]]
- [[视频扩散]]
- [[扩散强制]]
