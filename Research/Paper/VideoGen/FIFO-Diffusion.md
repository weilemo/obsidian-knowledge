---
created: 2026-01-25
type: paper
status: unread
tags: [VideoDiffusion, LongVideo, DiagonalDenoising, Queue]
aliases: [FIFO-Diffusion]
summary: "对角去噪队列实现无限长视频生成"
pdf-url: "Attachments/arxiv_2405.11473.pdf"
github-url: ""
---

# FIFO-Diffusion: Generating Infinite Videos from Text without Training
## PDF
- [[Attachments/arxiv_2405.11473.pdf]]
## 一句话摘要
FIFO-Diffusion 通过“对角去噪队列”在不重新训练的情况下生成任意长视频，显存开销与视频长度无关。

## 核心贡献
- 提出对角去噪（diagonal denoising）队列，让短片段视频扩散模型生成无限长视频。
- 提出 latent partitioning 与 lookahead denoising，降低训练-推理分布差异并提升稳定性。
- 理论上证明对角去噪误差与噪声跨度上界相关，并给出经验验证。

## 方法/模型（实现细节）
### 1) 基础扩散建模
对视频潜变量 $z_0=\mathrm{Enc}(v)$ 进行扩散训练，噪声预测目标为：
$$\mathcal{L}=\mathbb{E}_{v,\epsilon,t}\left[\|\epsilon_\theta(z_t;c,t)-\epsilon\|\right]$$
常规采样使用统一噪声时间表：
$$[z^1_{\tau_{t-1}},\ldots,z^f_{\tau_{t-1}}]=\Phi([z^1_{\tau_t},\ldots,z^f_{\tau_t}],[\tau_t;\ldots;\tau_t],c;\epsilon_\theta)$$

### 2) 对角去噪（Diagonal Denoising）
设时间表 $0=\tau_0<\tau_1<\dots<\tau_f=T$，对角去噪一步为：
$$[z^1_{\tau_0},\ldots,z^f_{\tau_{f-1}}]=\Phi([z^1_{\tau_1},\ldots,z^f_{\tau_f}],[\tau_1;\ldots;\tau_f],c;\epsilon_\theta)$$
队列 $Q$ 保存不同噪声级别的帧：每次去噪后，最前面的帧达到 $\tau_0=0$ 并出队，新的噪声帧入队，实现 FIFO 长视频生成。

### 3) Latent Partitioning
将扩散过程切成 $n$ 个区间，降低“最大噪声跨度”。每个分区更新为：
$$Q_k \leftarrow \Phi(Q_k,\tau_k,c;\epsilon_\theta)$$
这样噪声跨度从 $|\sigma_{\tau_f}-\sigma_{\tau_1}|$ 降到更小的分段跨度，提高稳定性与并行性。

### 4) Lookahead Denoising
允许较噪帧参考更干净帧，减轻对角去噪带来的训练-推理差异。论文证明误差上界满足：
$$\|\epsilon_\theta(z_{diag},\tau_{diag})-\epsilon(z_{vdm},\tau)\| \le O(|\sigma_{\tau_f}-\sigma_{\tau_1}|)$$
减少跨度可显著降低误差累积。

## 实验与结果
- 在 VideoCrafter2 等基线模型上生成 10K 帧长视频，质量与一致性保持稳定。
- 在长视频场景下显著优于朴素分块自回归策略。

## 局限与注意事项
- 依赖基础模型的质量；若基模短视频质量差，长视频仍会受限。
- lookahead 带来额外计算量，需要与吞吐平衡。

## 相关链接（双向）
- [[长视频生成]]
- [[视频扩散]]
- [[自回归视频]]
