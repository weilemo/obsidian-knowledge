---
created: 2026-01-27
type: paper
status: unread
tags: ["video-generation", "block-diffusion", "kv-cache", "benchmark", "long-form"]
aliases: ["BlockVid: Block Diffusion for High-Quality and Consistent Minute-Long Video Generation", "BlockVid"]
summary: "语义稀疏KV与Block Forcing提升分钟级一致性"
pdf-url: "Attachments/arxiv_2511.22973.pdf"
github-url: ""
---

# BlockVid
## 一句话摘要
在 block diffusion 框架中引入语义稀疏 KV 缓存与 Block Forcing，显著提升分钟级视频一致性并提出 LV-Bench。

## PDF
[[Attachments/arxiv_2511.22973.pdf]]

## 1 Introduction
- Block diffusion 兼具 AR 与 diffusion 优势，但长程误差会进入 KV cache 并累积。
- 现有基准缺乏长视频一致性度量。

## 2 Related Work
- 对比 AR、Diffusion、Block diffusion 的效率与质量权衡。

## 3 Method
### 3.1 Formulation
- 视频块序列：$V=\{V_1,\ldots,V_n\}$，每块含 $T$ 帧。
- AR 生成：
$$
p(x_{1:N})=\prod_{i=1}^N p(x_i\mid x_{<i})
$$

### 3.2 Block Forcing
- 训练损失由 Self-Forcing 与 Block-Forcing 组成：
$$
L = L_{SF}+L_{BF}
$$
- 基础扩散形式：
$$
x_t=(1-t)x_{start}+t\epsilon,\quad v_t=\epsilon-x_{start}
$$
$$
L_{BF}=\mathbb{E}\|v_{pred}-(\epsilon-\gamma\,x_{cond})\|^2
$$

### 3.3 Semantic Sparse KV Cache
- 语义相似检索：
$$
\mathrm{sim}_i=\cos(E_c,E_i)
$$
- Top-$l$ 语义检索 + 动态阈值 $\tau$ 选择缓存 token。

### 3.4 Chunk-wise Noise Scheduling & Shuffling
- 分块噪声：
$$
\epsilon_c=\epsilon_{min}+\frac{c}{n}(\epsilon_{max}-\epsilon_{min})
$$
- 局部窗口洗牌（如 $s=4$）改善块边界平滑性。

## 4 LV-Bench
- 长视频基准，针对一致性与漂移提出 VDE 系列指标：
  - $VDE_{clar}$, $VDE_{mot}$, $VDE_{aes}$, $VDE_{bg}$, $VDE_{subj}$。

## 5 Experiment
- 在 VBench 与 LV-Bench 上显著超越基线。
- 报告 VDE Subject +22.2%，VDE Clarity +19.4%。

## 6 Limitation and Future Work
- 语义稀疏 KV 受显存限制，极长序列仍需更高效策略。

## 7 Conclusion
- BlockVid 系统性解决块级误差累积，并提供专用长视频评测基准。

## 相关链接（双向）
- [[Block Diffusion]]
- [[KV Cache]]
- [[LV-Bench]]
