---
created: 2026-01-27
type: paper
status: unread
tags: ["video-generation", "diffusion", "autoregressive", "memory", "long-form"]
aliases: ["Pack and Force Your Memory: Long-form and Consistent Video Generation", "MemoryPack", "Direct Forcing"]
summary: "MemoryPack+Direct Forcing 提升长视频一致性"
pdf-url: "Attachments/arxiv_2510.01784.pdf"
github-url: ""
---

# Pack and Force Your Memory
## 一句话摘要
通过 MemoryPack 的长短期记忆检索与 Direct Forcing 的单步对齐训练，显著缓解长视频生成的漂移与误差累积。

## PDF
[[Attachments/arxiv_2510.01784.pdf]]

## Abstract
- 指出长视频生成的双重难题：长程依赖与 AR 误差累积。
- 提出 MemoryPack（文本+图像引导的动态记忆检索）与 Direct Forcing（单步近似对齐训练与推理）。
- 强调线性复杂度、分钟级一致性、训练-推理对齐。

## 1 Introduction
- DiT 在短视频上表现突出，但长视频受制于 $O(L^2)$ 复杂度与上下文漂移。
- 既有方法依赖固定窗口/压缩，缺乏全局语义与长程一致性。
- 训练-推理错配导致误差在长时间滚动中放大。
- 论文将长视频生成重新表述为“长短期信息检索”问题，引出 MemoryPack；并通过 Direct Forcing 解决错配。

## 2 Related Works
### 2.1 Efficient Accumulate for Long Video Generation
- 线性注意力/稀疏注意力/缓存策略等提升效率，但难以兼顾长程一致性。
- 部分方法依赖固定压缩或规则路由，难以自动学习长期语义。

### 2.2 Framework for Video Generation
- 多数方法聚焦秒级视频；长视频常使用 AR 方式并依赖短窗上下文。
- 现有长视频方法依赖最近帧，导致远程信息丢失。

## 3 Method
### 3.0 Problem Setup
- 给定历史片段 $\{x_0,\ldots,x_{n-1}\}$、文本提示 $P$ 与图像条件 $I$，生成下一段 $x_n$。
- 基于 DiT 架构，AR 生成未来片段。

### 3.1 MemoryPack
**目标**：在保持短期运动细节的同时，引入全局语义与长程一致性。

**组成**
- FramePack：短期上下文（局部窗口压缩）。
- SemanticPack：长期上下文（文本+图像引导的动态记忆）。

**SemanticPack 核心过程**
1) Memorize：历史窗口内自注意力生成紧凑嵌入。
2) Squeeze：用文本/图像语义对记忆进行跨注意力对齐。

**记忆更新公式**
$$
\psi_{n+1} = \mathrm{Squeeze}(\psi_n,\,\mathrm{Memorize}(x_n))
$$
初始化：
$$
\psi_0 = [\text{prompt feature};\,\text{image feature}]
$$
**复杂度**：SemanticPack 为 $O(n)$，适配长序列。

### RoPE Consistency
- 为解决跨段位置丢失，将图像 token 作为 CLS 并设置全局位置索引。
- 相对位置一致性：
$$
R_q(x_q,m)R_k(x_k,n)=R_g(x_q,x_k,n-m)
$$
$$
\Theta_k(x_k,n)-\Theta_q(x_q,m)=\Theta_g(x_q,x_k,n-m)
$$

### 3.2 Direct Forcing
**Rectified Flow**
$$
x_t = t x + (1-t)\epsilon,\quad t\in[0,1]
$$
$$
u_t = x-\epsilon
$$
$$
L_{FM}(\theta)=\mathbb{E}\|v_\theta(x_t,t)-u_t\|^2
$$

**推理 ODE**
$$
\hat x_1 = \int_0^1 v_\theta(x_t,t)\,dt
$$

**单步近似**
$$
\tilde x_1 = x_t + \Delta t\, v_\theta(x_t,t) \approx \hat x_1,\quad \Delta t=1-t
$$

**训练策略**
- 使用单步近似生成 $\tilde x$ 作为训练条件，降低分布错配。
- 梯度累积跨多个 clip 更新，强化跨段一致性。

## 4 Experiments
### Implementation Details
- 数据：Mira + Sekai，约 16k clips/150 小时，最长 1 分钟。
- 骨干：Framepack-F1；AdamW，lr $1e-5$；两阶段训练。

### Metrics
- VBench：成像质量、美学、动态度、运动平滑、背景一致、主体一致。
- 额外暴露偏差评估（长程漂移）。

### Results
- MemoryPack 在长时一致性（背景/主体/运动平滑）显著提升。
- Direct Forcing 明显降低长期漂移，推理稳定性更强。

## 5 Conclusion
- MemoryPack+Direct Forcing 为长视频 AR 生成提供高一致性与效率的统一方案。

## 6 Ethics Statement
- 关注生成内容的潜在误用与版权问题（需合规使用）。

## 7 Reproducibility Statement
- 提供模型/训练细节，强调可复现实验配置。

## 相关链接（双向）
- [[MemoryPack]]
- [[Direct Forcing]]
- [[Autoregressive Video Generation]]
