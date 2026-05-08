---
created: 2026-04-09
published: 2024-04-22
type: paper
status: 已读
tags:
  - SnapKV
  - KVCache
  - LLMInference
  - HeadToken
aliases:
  - SnapKV
summary: 基于 observation window 识别头级稳定注意模式，训练免费压缩 prompt KV，在长上下文下显著提升解码速度与显存效率。
pdf-url: Attachments/arxiv_2404.14469.pdf
source-url:
  - https://arxiv.org/abs/2404.14469
  - Attachments/arxiv_2404.14469.pdf
---

# SnapKV: LLM Knows What You are Looking for Before Generation

## PDF
- [[Attachments/arxiv_2404.14469.pdf]]

## Abstract
SnapKV 关注一个现实瓶颈：长 prompt 场景里，真正拖慢推理的往往是 prompt KV 的体量，而不是生成阶段新增的少量 KV。论文提出训练免费（fine-tuning-free）方案：用 prompt 末端的 observation window 估计每个 attention head 在后续生成时持续关注的前缀位置，再只保留这些关键 KV。作者报告在 16K 输入时可实现约 `3.6x` 解码速度提升和 `8.2x` 显存效率提升，并在 16 个长序列基准上保持接近全量 KV 性能。

## 1 Introduction
论文首先明确两类成本：
- 计算成本：解码每步都要和历史 KV 做注意力，随 prompt 长度线性变慢；
- 显存成本：长 prompt KV 常常远大于生成长度，成为部署限制。

作者认为，很多已有方法更关注“生成过程中新增 KV 的淘汰”，但在真实应用（多轮对话、长文档问答、代码库检索）中，prompt KV 才是核心负担。SnapKV 的目标就是直接压 prompt KV，同时尽量不掉精度。

本文核心主张是：
- 每个头对 prompt 的关注具有可预见模式；
- 这种模式可以在“生成前”从 observation window 中估计出来。

## 2 Related Works
论文重点对比了 StreamLLM、H2O、FastGen、ScissorHands 等 KV 压缩方法，并指出共同局限：多数方法没有把“超长 prompt 的预压缩”作为主问题来处理，或在真实长上下文检索任务中缺少充分验证。SnapKV 的差异是显式建模 prompt 末端窗口对后续生成注意分配的预测能力。

## 3 Observations
作者在 UltraChat 过滤后的长样本上分析注意力分配，给出两个关键观察：

1. `Pattern can be identified before generation`  
用 prompt 末端窗口选出的重要前缀位置，与生成阶段真实重要位置重合率很高（Fig.2）。

2. `Pattern is consistent during generation`  
把后续生成分成多个窗口后，重要位置分布依然与末端 observation window 保持高一致（Fig.3）。

这两点共同支持 SnapKV：可以在生成前先“拍快照（snap）”得到可用的 KV 压缩索引。

## 4 SnapKV

### 4.1 Observation Window-based Algorithm
论文定义：
- prompt 长度 $L_{\text{prompt}}$
- observation window 长度 $L_{\text{obs}}$
- prefix 长度 $L_{\text{prefix}}$

满足：
$$
L_{\text{prompt}} = L_{\text{prefix}} + L_{\text{obs}}
$$

对 observation window 的 query 计算其对 prefix keys 的注意力并求和投票：
$$
C=\sum_{i=0}^{L_{\text{obs}}} W_{\text{obs}}[:,i,:]
$$
$$
I=\operatorname{Topk}(C,k), \quad k=\lfloor p\cdot L_{\text{prefix}}\rfloor
$$
其中 $p$ 是压缩率，$I$ 是每个 head 选出的关键前缀索引。

论文还定义了 hit rate 来衡量“预测到的重要位置”与“当前生成真实重要位置”的重合比例：
$$
H=\frac{\sum O}{\sum M^{\text{threshold}}_{\text{cur}}}
$$
其中 $O$ 为阈值重要特征与投票特征的交集掩码。

实现流程（对应伪代码）：
- 用 observation window 对 prefix 位置投票；
- 对投票分数做 1D pooling（聚类）；
- 选 top-k 前缀位置；
- 与 observation window 全部 KV 拼接成压缩缓存。

#### 4.1.1 机制细化（张量维度、投票与缓存构造）
下面给出一个更精确的张量视角（固定某一层）：

设 head 数为 $H$，单头维度为 $d_h$，则第 $h$ 个头有
$$
Q_h^{(O)}\in\mathbb{R}^{L_{\text{obs}}\times d_h},\quad
K_h^{(P)}\in\mathbb{R}^{L_{\text{prefix}}\times d_h}
$$
其中 $O$ 表示 observation window，$P$ 表示 prefix。

对应注意力矩阵
$$
A_h=\operatorname{softmax}\!\left(\frac{Q_h^{(O)}(K_h^{(P)})^\top}{\sqrt{d_h}}\right)\in\mathbb{R}^{L_{\text{obs}}\times L_{\text{prefix}}}
$$
其元素 $A_h(i,j)$ 表示：第 $i$ 个 observation token 的 query 对第 $j$ 个 prefix key 的注意力权重。

若把所有 head 堆叠成张量
$$
W_{\text{obs}}\in\mathbb{R}^{H\times L_{\text{obs}}\times L_{\text{prefix}}}
$$
则符号
$$
W_{\text{obs}}[:,i,:]
$$
表示固定第 $i$ 个 query 位置后，取“所有 head 对所有 prefix 位置”的二维切片，形状为 $\mathbb{R}^{H\times L_{\text{prefix}}}$。

论文的投票公式
$$
C=\sum_{i=0}^{L_{\text{obs}}} W_{\text{obs}}[:,i,:]
$$
可理解为沿 query 维度求和（实现里常写成 $0$ 到 $L_{\text{obs}}-1$）。因此
$$
C\in\mathbb{R}^{H\times L_{\text{prefix}}},\quad
C_h\in\mathbb{R}^{L_{\text{prefix}}}
$$
其中 $C_h$ 是第 $h$ 个头的一维投票向量（长度 $L_{\text{prefix}}$）。

随后每个头独立做 top-k：
$$
I_h=\operatorname{Topk}(C_h,k),\quad
k=\lfloor p\cdot L_{\text{prefix}}\rfloor
$$

“聚类邻域（pooling neighborhood）”指在 prefix 索引轴上的局部窗口（如 kernel=7 的邻域），先做 1D pooling 再 top-k。直觉上是“保留一簇相关 token”，避免只保留离散点导致语义断裂。

最终缓存按 head 构造为：
$$
S_h=I_h\cup O,\qquad
K_h^{\text{cache}}=K_h[S_h],\ V_h^{\text{cache}}=V_h[S_h]
$$
两部分含义不同：
- 选中的 prefix KV（$I_h$）：远程历史中的“精选记忆”，且每个 head 可不同；
- observation window 全部 KV（$O$）：最近上下文的“完整记忆”，用于保持局部连贯与最新条件不丢失。

### 4.2 Robustness Analysis of Hit Rate
作者在 QMSum / Openreview / SPACE 上测试鲁棒性，回答两个问题：

#### 4.2.1 Contextual Dependency of Patterns
同一文档换不同指令，重要位置会变化（重合下降），说明“重要性是上下文相关的”，固定策略并不稳。

#### 4.2.2 Invariance to Instruction Positions
无论问题在前还是在后，hit rate 都保持较高，说明 observation window 机制对指令位置不敏感。

### 4.3 Efficient Clustering via Pooling
只保留离散 top 位置会破坏局部上下文完整性（例如只抓到电话区号）。论文引入 pooling 聚合邻域，等价于“先找中心，再保留簇周边”，显著改善检索和生成稳定性。

## 5 Experiments

### 5.1 Benchmarks on LWM-Text-Chat-1M
在单卡 A100-80GB 上，Needle-in-a-Haystack 压力测试把上下文拉到 `380K` token。  
SnapKV 设 prompt KV 上限为 1024（约 380x 压缩）后，仍能在较长区间维持较高检索成功率；而原始实现约在 33K 左右就 OOM。

速度/内存方面（固定生成长度 512）：
- 16K 输入、batch=2 时，解码速度约 `3.6x` 提升；
- 同 batch 下可承载输入长度约 `8.2x` 提升（显存效率显著改善）。

### 5.2 Ablation: Effectiveness of Pooling
在更难的 LongEval-Lines 改造任务上，加入 pooling 明显优于不加 pooling，验证“保留簇结构”比稀疏点选更稳。

### 5.3 Experiments on LongBench
评测模型：LWM-Text-Chat-1M、LongChat-7B-32k、Mistral-7B-Instruct-v0.2、Mixtral-8x7B。  
设置：prompt KV 限制为 1024/2048/4096，`kernel=7`，`window=32`。

结论：
- 16 个数据集整体仅轻微性能下降，部分任务甚至超过 All-KV；
- 平均输入约 13K 时，KV=1024 对应约 `92%` 压缩，KV=4096 约 `68%` 压缩；
- 与 H2O（同容量上限 4096）比较，SnapKV 明显更优；例如在 Mistral 上，SnapKV-1024 已可在多数基准超过 H2O-4096。

### 5.4 Experiments on Command-R
在 Command-R（128K 上下文）上，设置 KV 上限 4096（约 2x–32x 压缩）：

- Needle（多次置乱版本）：分数 `9.866 -> 9.819`，约 `-0.5%`，几乎无损；
- RAG Citation：`-1.2%`；
- End-to-End RAG：`-2.1%`；
- BioASQ 生成实验中，24K 上下文（200 文档）平均反而提升约 `+5.4%`。

### 5.5 Case Study: Compatibility with Parallel Decoding
与 Medusa 结合后，在 10K prompt 下：
- 相对原 Medusa 约 `1.3x` 加速；
- 相对原生自回归解码约 `2.2x` 加速。

说明 SnapKV 与并行解码是可叠加的。

## 6 Discussions
论文强调 SnapKV 主要优化“生成阶段对 prompt KV 的使用”，并不能替代模型本身的长上下文能力；如果基座模型本来长上下文表现弱，SnapKV 不会神奇修复该问题。它的价值在于：在已有长上下文能力之上，降低推理成本并尽量保留效果。

## Appendix A Discussion of Generation Time Speedup
附录时间拆解显示：长上下文下生成时间通常主导总耗时。SnapKV 能把生成延迟近似稳定在常数级别，而 prompting 阶段成本基本不变，因此整体端到端收益主要来自 generation。

## Appendix B Visulization of the Generated Context
附录给出多个可视化样例（QMSum / Qasper 等），显示 SnapKV 在 1024/2048/4096 三档容量下，多数情况下可保留与 All-KV 接近的关键信息覆盖与答案质量。

## 相关链接（双向）
- [[KV Cache]]
- [[H2O]]
