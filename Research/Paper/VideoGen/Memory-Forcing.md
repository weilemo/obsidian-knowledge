---
created: 2026-01-27
type: paper
status: unread
tags: ["video-generation", "world-model", "minecraft", "memory", "diffusion"]
aliases: ["Memory Forcing: Spatio-Temporal Memory for Consistent Scene Generation on Minecraft", "Memory Forcing"]
summary: "时空记忆与训练策略提升探索/回访一致性"
pdf-url: "Attachments/arxiv_2510.03198.pdf"
github-url: ""
---

# Memory Forcing
## 一句话摘要
通过几何索引的空间记忆与训练策略（Hybrid/Chained）平衡探索与回访一致性，提升 Minecraft 长程场景生成。

## PDF
[[Attachments/arxiv_2510.03198.pdf]]

## ABSTRACT
- 发现“时间记忆”与“空间记忆”之间的权衡：探索质量 vs 回访一致性。
- 提出 Memory Forcing：几何索引空间记忆 + 训练机制引导模型在不同场景下自适应使用记忆。

## INTRODUCTION
- AR 视频模型在交互世界建模中重要，但受限于有限上下文窗口。
- 仅时间记忆导致回访漂移；仅空间记忆导致探索失败。
- 教师强制训练低估推理漂移，促使模型过度依赖短期信息。

## 2 RELATED WORKS
- 归纳 AR 视频扩散、世界模型、记忆检索与 3D 重建相关工作。

## 3 MEMORY FORCING
### 3.1 Formulation
- 视频序列：$X_{1:T}=\{x_1,\ldots,x_T\}$。
- 噪声序列：$\tilde X_{1:T}$，噪声等级 $k_{1:T}$。
- 训练损失：
$$
L=\mathbb{E}_{k_{1:T},X_{1:T},\epsilon_{1:T}}\sum_j \|\epsilon-\epsilon_\theta(W_j,C_j,t)\|^2
$$

### 3.2 记忆结构
- 条件输入：$C_j=\{A_j,P_j,M_{spatial}\}$（动作/姿态/空间记忆）。
- 空间注意力：
$$
\mathrm{Attention}(\tilde Q,\tilde K_{spatial},V_{spatial})=\mathrm{Softmax}(\cdot)
$$

### 3.3 Hybrid Training
- 将轨迹分为“探索”和“回访”两类训练情境。
- 探索期强调时间记忆；回访期增强空间记忆检索。

### 3.4 Chained Forward Training
- 通过模型 rollout 生成更大位姿变化，迫使依赖空间记忆。
- 链式损失：
$$
L_{chain}=\sum_j \|\epsilon-\epsilon_\theta(W_j(x,\hat x),C_j,t)\|^2
$$

### 3.5 Point-to-Frame Retrieval & Incremental 3D Reconstruction
- 当前可见点映射历史帧，进行点到帧检索。
- 维护显式 3D cache，随时间增量更新。
- 关键帧选择：
$$
\mathrm{IsKeyframe}(t)=\mathrm{NovelCoverage}(I_t,G_{global})\ \text{or}\ (|H_t|<\tau_{hist})
$$

## 4 EXPERIMENTS
- 任务：Minecraft 场景生成与回访一致性。
- 评测：长期一致性、探索质量、效率。
- 结论：Memory Forcing 在一致性与探索之间实现更优平衡。

## 5 CONCLUSIONS
- 结合空间记忆与训练策略，可显著提升长程一致性与互动场景质量。

## 相关链接（双向）
- [[World Model]]
- [[Spatio-Temporal Memory]]
- [[Minecraft]]
