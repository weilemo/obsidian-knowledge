---
created: 2026-04-22
published: 2026-01-31
type: paper
status: 未读
tags: [JTok, JTok-M, ScalingLaw, MoE, TokenIndexedParameters]
aliases: [JTok, JTok: On Token Embedding as another Axis of Scaling Law via Joint Token Self-modulation]
summary: "提出 token-indexed parameters 作为与 dense/MoE 正交的扩展轴，通过 JTok/JTok-M 在几乎不增加 FLOPs 的情况下扩展容量，并在 isoFLOPs 下验证 35% compute saving。"
pdf-url: https://arxiv.org/pdf/2602.00800
source-url:
  - https://arxiv.org/abs/2602.00800
  - https://arxiv.org/pdf/2602.00800
  - https://doi.org/10.48550/arXiv.2602.00800
---

# JTok: On Token Embedding as another Axis of Scaling Law via Joint Token Self-modulation

## Abstract
这篇论文提出一个新主张：除了传统的 dense 参数扩展与 MoE 稀疏专家扩展，还可以沿着“token-indexed parameters”这条新轴扩展模型容量。作者给出两个模块：`JTok` 与 `JTok-M`。它们都通过查表得到 token 相关向量，再以逐元素方式调制 backbone 更新，计算开销很小。论文在 dense 与 MoE 主干（总参数从 650M 到 61B）上都报告了稳定收益，并通过 isoFLOPs 分析说明 JTok-M 能把质量-计算前沿整体下移。

## 1 Introduction
论文认为现有扩展路径都有瓶颈：
- dense 扩展：能力提升与 FLOPs、显存几乎线性绑定；
- MoE 扩展：虽然解耦了部分容量与计算，但有路由、通信、HBM 压力与工程复杂度问题。

因此作者提出把“token 相关参数表”作为正交扩展轴：把额外容量主要放到可检索参数上，而非继续增大每步都要密集计算的主干矩阵。

## 2 Related Works
论文将工作放在四条脉络中比较：
- 经典 scaling law（Kaplan/Chinchilla 与 isoFLOPs 框架）；
- Vocabulary scaling/tokenizer 路线；
- MoE 路线（稀疏激活专家）；
- Large memory layer 路线（大规模可检索记忆层）。

与这些工作相比，JTok/JTok-M 的定位是：把 token-indexed 参数直接作为可扩展容量，并保持主干 FLOPs 近似不变。

## 3 Methodology

### 3.1 Preliminary
基于 Pre-Norm Transformer：

$$
\Delta \mathbf{a}_x^{\ell}=\mathrm{Attn}^{\ell}(\mathrm{RMSNorm}(\mathbf{h}_x^{\ell})),
\quad
\tilde{\mathbf{h}}_x^{\ell}=\mathbf{h}_x^{\ell}+\Delta \mathbf{a}_x^{\ell}
$$

$$
\Delta \mathbf{m}_x^{\ell}=\mathrm{FFN}^{\ell}(\mathrm{RMSNorm}(\tilde{\mathbf{h}}_x^{\ell})),
\quad
\mathbf{h}_x^{\ell+1}=\tilde{\mathbf{h}}_x^{\ell}+\Delta \mathbf{m}_x^{\ell}.
$$

并沿用 isoFLOPs 设定：

$$
C \approx 6N_cD,
$$

其中 $N_c$ 是 compute-intensive 参数量，$D$ 是训练 token 数。

### 3.2 JTok
每层维护 token-indexed 表 $\mathbf{E}^{\ell}\in\mathbb{R}^{V\times d}$，对 token id $x$ 检索向量并构造门控：

$$
\mathbf{p}_x^{\ell}=\mathbf{1}+\mathbf{s}^{\ell}\odot \mathrm{Norm}_{\varepsilon}(\mathbf{E}^{\ell}[x]).
$$

再调制 MLP 增量：

$$
\Delta \hat{\mathbf{m}}_x^{\ell}=\Delta \mathbf{m}_x^{\ell}\odot \mathbf{p}_x^{\ell},
\quad
\mathbf{h}_x^{\ell+1}=\tilde{\mathbf{h}}_x^{\ell}+\Delta \hat{\mathbf{m}}_x^{\ell}.
$$

核心是“查表 + 逐元素运算”，不引入大矩阵乘法。

### 3.3 JTok-M
JTok-M 为每个 token 增加一个可路由的 modulator 池。路由器给出 top-$K$ 混合：

$$
\mathbf{g}_x^{\ell}=(\mathrm{RMSNorm}(\mathbf{h}_x^{\ell}))^\top\mathbf{R}^{\ell},
\quad
G_x^{\ell}=\mathrm{TopK}(\mathbf{g}_x^{\ell},K),
$$

$$
\mathbf{e}_x^{\ell}=\sum_{i\in G_x^{\ell}} w_i^{\ell}\mathbf{E}_i^{\ell}[x],
$$

$$
\Delta \mathbf{r}_x^{\ell}=\frac{1}{\sqrt{2N_l}}\,\mathbf{s}_{\mathrm{JTok-M}}^{\ell}\odot \mathrm{Norm}_{\varepsilon}(\mathbf{e}_x^{\ell}),
$$

$$
\mathbf{h}_x^{\ell+1}=\tilde{\mathbf{h}}_x^{\ell}+\Delta \mathbf{m}_x^{\ell}+\Delta \mathbf{r}_x^{\ell}.
$$

相比 JTok，JTok-M 是上下文相关、稀疏激活的 token-indexed 混合。

### 3.4 Scaling Hypothesis（论文核心理论）
定义有效参数：

$$
N_{\mathrm{eff}}=N_c+\gamma(\rho)N_n=N_c\left(1+\eta\gamma(\rho)\right),
$$

其中 $\eta=N_n/N_c$，$\rho=K/n_e$。

在该假设下，JTok-M 的计算最优前沿满足乘法下移：

$$
\mathcal{L}_{\mathrm{JTok-M}}^*(C;\eta,\rho)=\left(1+\eta\gamma(\rho)\right)^{-\frac{\alpha\beta}{\alpha+\beta}}\cdot \mathcal{L}^*(C),
$$

并推导等性能所需计算：

$$
C_{\mathrm{JTok-M}}^*(\mathcal{L}^{\star})=\frac{1}{1+\eta\gamma(\rho)}\,C_{\mathrm{base}}^*(\mathcal{L}^{\star}).
$$

结论是：在固定 JTok-M 配置下，compute saving 比例可对 backbone 尺度保持近似稳定。

## 4 Experiments

### 4.1 Main Quality Results
- 在多组 dense/MoE 主干上，训练 loss 曲线都更低；
- 下游任务在知识、推理、代码、数学维度都有提升；
- 在 17B-A2B MoE 上，文中报告代表性提升包括：MMLU +4.11、ARC +8.28、CMMLU +9.34。

### 4.2 Scaling Laws
- 多个 backbone 尺度下，JTok-M 的相对收益保持稳定（约 2.5%~3.0% loss 改善量级）；
- isoFLOPs 实验显示 efficient frontier 在 log-log 下斜率近似一致但截距下移；
- 论文给出的总结量化是：同算力预算下约 2.2% loss 改善，等性能下约 35% 计算节省。

### 4.3 System Efficiency
论文给出工程优化后开销：
- 训练吞吐下降可控制在约 6.78%；
- 推理 prefill/decoding 吞吐下降分别约 0.8%~2.3% 与 4.5%~7.3%。

这说明它不是“免费增益”，但在较小系统代价下换来明显质量收益。

## 5 Conclusion and Outlook
JTok/JTok-M 的关键价值是把 token-indexed parameters 变成可验证的“新扩展轴”：
- 与 dense/MoE 扩展互补；
- 理论上可并入 scaling law 框架；
- 实证上在多尺度主干与 isoFLOPs 下都成立。

## Appendix Notes
附录给了两类重要补充：
- scaling 推导与拟合细节（包括 frontiers 回归）；
- 系统实现细节（embedding parallel、token dedup、CPU offload、负载均衡损失等）。

## 相关链接（双向）
- [[LLM扩展律与容量-计算解耦-研究地图]]
