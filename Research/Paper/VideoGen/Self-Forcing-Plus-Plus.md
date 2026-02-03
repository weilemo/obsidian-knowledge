---
created: 2026-01-27
type: paper
status: unread
tags: ["video-generation", "autoregressive", "distillation", "long-horizon", "streaming"]
aliases: ["Self-Forcing++: Towards Minute-Scale High-Quality Video Generation", "Self-Forcing++"]
summary: "噪声回注+扩展DMD实现分钟级长视频"
pdf-url: "Attachments/arxiv_2510.02283.pdf"
github-url: ""
---

# Self-Forcing++
## 一句话摘要
通过后向噪声初始化、扩展 DMD 滑窗蒸馏与滚动 KV cache 训练，把长视频生成扩展到分钟级并抑制质量退化。

## PDF
[[Attachments/arxiv_2510.02283.pdf]]

## Abstract
- 现有教师模型仅能 5–10 秒，学生模型长时滚动易退化。
- Self-Forcing++ 不需要长视频教师，也不重训长视频数据集。
- 通过“回注噪声 + 扩展蒸馏 + 滚动缓存”显著提升长时一致性与质量。

## 1 Introduction
- 长视频主要瓶颈：训练-推理时域错配、错误累积。
- 过曝与运动停滞是 Self-Forcing 系列的主要失败模式。
- 目标：在不增加推理成本的情况下扩展时长到分钟级。

## 2 Related Work
- CausVid、Self-Forcing 等蒸馏策略解决短时质量，但长时退化明显。
- Diffusion Forcing 等方式训练不稳定或成本高。

## 3 Method
### 3.1 Background
- 先将双向教师蒸馏为少步生成器，再转为 AR 学生。
- 现有 Self-Forcing 的训练长度受教师 5s 限制。

### 3.2 Extend training beyond teacher’s limit
**后向噪声初始化**
- 学生先滚动生成长序列 $N\gg T$，再按噪声日程回注：
$$
x_t=(1-\sigma_t)x_0+\sigma_t\epsilon,
\quad x_0=x_{t-1}-\sigma_{t-1}\hat\epsilon_\theta(x_{t-1},t-1)
$$
- 目标：保持与历史一致的噪声轨迹，避免长序列语境断裂。

**扩展 DMD（滑窗蒸馏）**
- 从长序列中均匀采样长度 $K$ 窗口，对齐教师/学生分布：
$$
\nabla_\theta L_{DMD}^{\text{extended}}
=\mathbb{E}_{t,z}\big[\nabla_\theta\,\mathrm{KL}(p_t^T(z)\,\|\,p_{\theta,t}^S(z))\big]
$$
- 核心直觉：教师只需修正长序列中的短窗退化片段。

**滚动 KV Cache**
- 训练与推理统一使用滚动缓存，避免错配导致的闪烁与漂移。

### 3.3 Improving Long-Term Smoothness via GRPO
- 引入 GRPO 作为可选增强，强调运动连续性。
- 重要性权重：
$$
\rho_{t,i}=\frac{\pi_\theta(a_{t,i}\mid s_{t,i})}{\pi_{\theta_{old}}(a_{t,i}\mid s_{t,i})}
$$
- 以光流强度作为长期平滑奖励代理。

## 4 Experiments
- 评测长时生成（50/75/100s），与 Self-Forcing、CausVid 对比。
- 改善过曝与运动衰减，长时质量更稳定。
- 提出改进基准以避免对退化视频的错误打分。

## 5 Conclusion
- Self-Forcing++ 在不引入长视频教师的前提下显著提升长时 AR 视频生成能力。

## 6 Limitations and Further Work
- 仍受教师能力与蒸馏上限限制；超长场景仍可能出现渐进退化。

## 7 Discussion
- 讨论与 Rolling Forcing/LongLive 的差异及潜在融合。

## 相关链接（双向）
- [[Self-Forcing]]
- [[Distribution Matching Distillation]]
- [[Rolling KV Cache]]
