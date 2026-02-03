---
created: 2026-01-27
type: paper
status: unread
tags: ["video-generation", "diffusion", "long-form", "error-recycling"]
aliases: ["Stable Video Infinity: Generation with Error Recycling", "SVI"]
summary: "误差回收微调实现无限长度视频"
pdf-url: "Attachments/arxiv_2510.09212.pdf"
github-url: ""
---

# Stable Video Infinity
## 一句话摘要
通过 Error-Recycling Fine-Tuning 将误差注入与回收融入训练，显著提升无限长度视频的长期一致性。

## PDF
[[Attachments/arxiv_2510.09212.pdf]]

## ABSTRACT
- 指出现有方法仅“缓解”漂移而非“纠正”误差。
- 提出 SVI：闭环错误回收，训练模型识别并修复自身错误。
- 可支持流式故事线与多条件控制（音频/骨架/文本）。

## INTRODUCTION
- 长视频生成的核心问题是误差累积与场景同质化。
- 现有方法依赖噪声调度/锚帧/采样改造，无法彻底修复误差。
- 观察误差形态与图像修复退化一致，引出“误差回收”思路。

## 2 RELATED WORK
- 归纳 anti-drifting、噪声重排、锚帧等策略的局限。

## 3 PRELIMINARIES AND MOTIVATION
### Flow Matching
- 中间状态：
$$
X_t = t\,X_{vid} + (1-t)\,X_{noi}
$$
- 速度场：
$$
V_t = \frac{dX_t}{dt},\quad \hat V_t = u(X_t, X_{img}, C, t;\theta)
$$
- 推理积分：
$$
X_{t_{k+1}} = X_{t_k} + (t_{k+1}-t_k)\,u(X_{t_k}, X_{img}, t_k;\theta)
$$

### 误差动机
- 在训练中直接接触生成误差，有助于修复长程漂移。

## 4 STABLE VIDEO INFINITY
### 4.1 Error Injection
- 残差误差：
$$
E = \hat X_{vid} - X_{vid}
$$
- 注入：
$$
\tilde X_{vid}=X_{vid}+I_{vid}E_{vid},\quad
\tilde X_{noi}=X_{noi}+I_{noi}E_{noi},\quad
\tilde X_{img}=X_{img}+I_{img}E_{img}
$$
- 噪声输入：
$$
\tilde X_t = t\tilde X_{vid} + (1-t)\tilde X_{noi}
$$

### 4.2 Error Recycling
- 误差银行：$B_* = \{B_{*,n}\}$，控制上限 $Z=500$。
- 采样：
$$
E_{vid}\sim \mathrm{Unif}(B_{vid,n}),\quad E_{noi}\sim \mathrm{Unif}(B_{noi,n})
$$
- 结合“干净输入”概率 $p$ 混合训练，保持生成能力。

### 4.3 Multi-Condition Extension
- 扩展条件 $C=\{C_{vis}, C_{emb}\}$，兼容多模态控制。

## 5 EXPERIMENTS
- 三类基准：一致性、创意、条件控制。
- 展示无限长度滚动生成与稳定一致性。
- 误差回收提升长程运动稳定与场景变化质量。

## 6 CONCLUSION
- SVI 通过“闭环误差回收”修复漂移，使无限长度生成可行。

## 相关链接（双向）
- [[Error Recycling]]
- [[Flow Matching]]
- [[Long-Form Video Generation]]
