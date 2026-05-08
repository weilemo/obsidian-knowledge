---
created: 2026-04-09
published: 2024-07-16
type: paper
status: 已读
tags:
  - AdaKV
  - KVCache
  - LLMInference
  - AdaptiveBudget
aliases:
  - Ada-KV
  - AdaKV
summary: 从注意力输出扰动上界出发，提出 head-wise 自适应预算分配（Ada-KV），以插件方式提升 Top-k KV 淘汰方法。
pdf-url: Attachments/arxiv_2407.11550.pdf
source-url:
  - https://arxiv.org/abs/2407.11550
  - Attachments/arxiv_2407.11550.pdf
  - https://github.com/FFY0/AdaKV
---

# Ada-KV: Optimizing KV Cache Eviction by Adaptive Budget Allocation for Efficient LLM Inference

## PDF
- [[Attachments/arxiv_2407.11550.pdf]]

## Abstract
论文指出现有 Top-k KV 淘汰方法普遍采用“各注意力头均匀预算”，忽略了头间注意力分布差异。作者先给出压缩前后注意力输出差异的理论上界，再据此提出 Ada-KV：按头的注意力集中程度动态分配预算（稀疏头少给、分散头多给）。Ada-KV 可作为 plug-and-play 组件集成到现有方法（如 SnapKV、Pyramid）中。实验覆盖 Ruler 13 个数据集与 LongBench 16 个数据集，并在 question-aware / question-agnostic 两种场景下都带来稳定提升。

## 1 Introduction
核心问题：在总预算固定时，如何在不同 attention heads 之间分配预算，才能最小化 KV 淘汰带来的注意力输出偏差。

作者指出 uniform allocation 的结构性缺陷：
- 某些头注意力高度集中，给太多预算是浪费；
- 某些头注意力较分散，给同样预算会损失关键上下文。

因此，Ada-KV 的目标不是改“怎么选 Top-k”，而是改“每个头的 k 该是多少”。

## 2 Related Works
论文把相关工作分为：
- Cache eviction 方法：StreamingLLM、H2O、SnapKV、Pyramid 等；
- Sparse attention 方法：在计算时稀疏，但通常不直接缩小 KV 存储。

Ada-KV 的定位是：针对 Top-k eviction 提供头级预算分配层，和现有选择策略兼容，不依赖训练。

## 3 Methodology

### 3.1 Preliminaries
论文在标准多头注意力设定下定义了淘汰前输出 $y$ 与淘汰后输出 $\hat y$，并将淘汰决策写为每头的二值指示变量 $\mathcal{I}_i^j$（保留或删除第 $j$ 个 KV）。

### 3.2 Theoretical Foundation: Revisiting Top-$k$ Methods with Bounded Eviction Loss
定义淘汰损失为：
$$
L_1\ \text{Eviction Loss}=\|y-\hat y\|_1
$$

论文给出上界（Theorem 1）：
$$
L_1\ \text{Eviction Loss}\le \epsilon
=2hC-2C\sum_{i=1}^{h}\sum_{j=1}^{n}\mathcal{I}_i^j A_i^j
$$
其中 $C$ 为常数（与 $V_iW_i^O$ 的行范数上界相关）。

进一步证明（Theorem 2）：在给定各头预算 $\{B_i\}$ 下，Top-k 选择可使该上界最小。  
这一步把“Top-k 为什么合理”形式化成了一个可优化目标。

#### 3.2.1 Theorem 1 公式推导与直观理解
记第 $i$ 个 head 的注意力分布为 $A_i\in\mathbb{R}^{1\times n}$，二值保留掩码为 $\mathcal{I}_i\in\{0,1\}^{1\times n}$。定义保留质量
$$
F_i:=\|A_i\odot \mathcal{I}_i\|_1=\sum_{j=1}^{n}\mathcal{I}_i^jA_i^j\in(0,1].
$$
淘汰后重归一化注意力：
$$
\hat A_i=\frac{A_i\odot \mathcal{I}_i}{F_i}.
$$

从输出差异出发：
$$
\|y-\hat y\|_1
=\left\|\sum_{i=1}^{h}(A_i-\hat A_i)V_iW_i^O\right\|_1
\le \sum_{i=1}^{h}\|(A_i-\hat A_i)V_iW_i^O\|_1.
$$
令
$$
C:=\max_i\|V_iW_i^O\|_\infty,
$$
则有
$$
\|(A_i-\hat A_i)V_iW_i^O\|_1
\le C\|A_i-\hat A_i\|_1.
$$
所以
$$
\|y-\hat y\|_1\le C\sum_{i=1}^{h}\|A_i-\hat A_i\|_1.
$$

再看每个 head：
$$
A_i-\hat A_i
=\left(1-\frac{\mathcal{I}_i}{F_i}\right)\odot A_i,
$$
于是
$$
\|A_i-\hat A_i\|_1
=\sum_{j=1}^{n}\left|1-\frac{\mathcal{I}_i^j}{F_i}\right|A_i^j
=2(1-F_i).
$$
代回得
$$
\|y-\hat y\|_1
\le 2C\sum_{i=1}^{h}(1-F_i)
=2hC-2C\sum_{i=1}^{h}F_i
=2hC-2C\sum_{i=1}^{h}\sum_{j=1}^{n}\mathcal{I}_i^jA_i^j.
$$

直观上，这个上界只惩罚“未保留的注意力质量”。因此在固定预算下，最优策略是尽量让
$$
\sum_{i,j}\mathcal{I}_i^jA_i^j
$$
最大，也就是优先保留高注意力权重项（Top-k 的理论动机）。

#### 3.2.2 $V_i$ 与 $W_i^O$ 是什么（维度解释）
以单层多头注意力、单时刻 query 为例：
$$
A_i\in\mathbb{R}^{1\times n},\quad
V_i\in\mathbb{R}^{n\times d_h},\quad
W_i^O\in\mathbb{R}^{d_h\times d_{\text{model}}}.
$$
其中：
- $V_i$：第 $i$ 个 head 的 value 矩阵（每个历史 token 一个 value 向量）。
- $W_i^O$：该 head 到模型输出空间的投影矩阵（output projection 对应分块）。

因此：
$$
A_iV_i\in\mathbb{R}^{1\times d_h},\qquad
(A_iV_i)W_i^O\in\mathbb{R}^{1\times d_{\text{model}}}.
$$
也就是说，每个 head 先在 $d_h$ 子空间聚合，再映射回模型维度。  
在上界中使用
$$
\|V_iW_i^O\|_\infty
$$
是为了统一约束该线性映射的幅度，从而把输出误差上界化为“注意力分布偏移量”乘以常数。

### 3.3 Optimizing Top-$k$ Methods with Adaptive Budget Allocation
在固定总预算 $B=\sum_i B_i$ 下，Ada-KV 先把所有头的观测注意力拼接，再做全局 Top-$B$，然后按各头入选频次分配预算：
- 入选多的头分更多预算；
- 入选少的头分更少预算。

算法上是非常直接的 4 步：
1. 拼接各头权重；
2. 取全局 Top-$B$；
3. 统计每头命中次数 $f_i$；
4. 令 $B_i^\*=f_i$。

论文给出结论（Theorem 3）：该分配使 Top-k 对应的上界在所有预算分配中最小：
$$
\epsilon^{**}=\min_{\{B_i\}}\epsilon^*
$$

### 3.4 Integration into Existing Cache Eviction Methods
作者把 Ada-KV 集成到两条 SOTA 线，得到：
- Ada-SnapKV
- Ada-Pyramid

并加入 safeguard 参数 $\alpha$（默认 0.2）：
- 防止某些头被分到过小预算；
- 提升对“关键头偶发变化”的鲁棒性。

#### 3.4.1 无代码实现总流程（预算分配层）
把 Ada-KV 当作一个“预算分配前置层”，插在任意 Top-k 选择器之前：
1. 确定该层/该阶段总预算 $B$。
2. 得到 head-token 打分矩阵 $S_{i,j}$（来自基方法打分）。
3. 在全部 $(i,j)$ 上做一次全局 Top-$B$。
4. 统计每个 head 的命中次数 $f_i$，作为原始头预算。
5. 做 safeguard 混合：
$$
B_i\leftarrow (1-\alpha)f_i+\alpha\frac{B}{h}
$$
6. 整数化并修正，使 $\sum_i B_i=B$（必要时设置最小头预算）。
7. 各 head 内再执行基方法的 Top-$B_i$ 选择。

该流程的关键点：Ada-KV 不替代基方法打分，只重分配“每头能用多少预算”。

#### 3.4.2 Ada-SnapKV 实现思路（prompt 预压缩）
1. 按 SnapKV 流程先算 observation window 对 prefix 的投票分数 $C_h(j)$。
2. 把所有 head 的 $C_h(j)$ 拼接后做全局 Top-$B$，得到每头预算 $B_h$。
3. 每个 head 在 prefix 上保留 Top-$B_h$ 的索引。
4. 与 observation window 的全部 KV 做并集，得到最终缓存。

直觉：远程 prefix 用自适应预算“精选”，近端 observation window 全量保留以保证局部连贯。

#### 3.4.3 Ada-Pyramid 实现思路（层间+头间联合）
1. 保留 Pyramid 的层间总预算分配（每层总预算 $B^{(\ell)}$）。
2. 对每层 $\ell$，收集该层 head-token 分数 $S^{(\ell)}_{i,j}$。
3. 在该层内运行 Ada-KV 分配，得到头预算 $B_i^{(\ell)}$，满足：
$$
\sum_i B_i^{(\ell)}=B^{(\ell)}.
$$
4. 每个 head 再按原 Pyramid 选择器做 Top-$B_i^{(\ell)}$。
5. 所有层重复。

直觉：Pyramid 负责“层间预算”，Ada-KV 补齐“层内头间预算”。

#### 3.4.4 落地注意事项
- 预算合法性：保证 $B_i\ge 0$ 且总和精确守恒。
- 整数化策略：建议“先浮点后配额修正”，避免总预算漂移。
- $\alpha$ 调参：过小会头预算塌缩，过大会退化成近均匀分配。
- 评估口径：建议同时报告 question-aware 与 question-agnostic，避免高估实战收益。

### 3.5 Implementation of Computation under Adaptive Budget Allocation
为避免“头预算不等导致计算低效”，论文实现了：
- 基于 variable-length FlashAttention 的计算路径；
- 扁平化缓存布局 + 自定义 CUDA kernel；
- GQA 兼容策略（按组聚合注意力，避免冗余复制 KV）。

结论是：在相同预算下，自适应分配可保持与传统方法接近的效率，同时提升质量。

## 4 Experiments
### 4.1 Settings
- Base models：Llama-3.1-8B-Instruct、Mistral-7B-Instruct-v0.2  
- Benchmarks：Ruler（13 tasks）+ LongBench（16 datasets）  
- 比较方法：SnapKV、Pyramid、StreamingLLM，以及其 Ada 增强版  
- 同时评估 question-aware 与更现实的 question-agnostic 场景

### 4.2 Ruler Benchmark
总体结论：Ada-SnapKV / Ada-Pyramid 在两种场景都优于原始方法，且在 question-agnostic 下优势更明显。

论文给出代表性数字（Llama-3.1-8B）：
- SnapKV 在 80% / 20% cache 下分数约 `87.59 / 44.02`
- Ada-SnapKV 提升到约 `92.67 / 53.29`

并在困难子任务（如 S-NIAH-3、MK-NIAH-2）中报告明显提升，例如 80% 预算下可从 `62.4` 提到 `97.6`、从 `85.2` 提到 `99.6`。

### 4.3 LongBench Benchmark
在 fixed budget（128/256/512/1024/2048）和 ratio budget 两种评估下，Ada 版本整体优于原方法。

作者强调一个关键观察：  
从 question-aware 转到 question-agnostic 后，所有方法都会掉分，说明只用 question-aware 评估会高估实战性能。

论文示例（Llama, budget=2048）：
- SnapKV 平均分从约 `49.09`（aware）降到 `42.86`（agnostic）

task-domain 表里（question-agnostic, Llama-3.1-8B）：
- 在 10% / 20% / 40% 预算下，Ada-SnapKV 平均分分别约 `37.45 / 42.87 / 46.24`，均高于 SnapKV。

### 4.4 Computation Efficiency Under Adaptive Allocation
在 budget=1024 的效率实验中，Ada-SnapKV 与 SnapKV 的峰值显存和解码延迟接近，且都明显优于 Full cache，说明 Ada-KV 的质量增益不是以牺牲效率换来的。

## 5 Broad Benefits of the Adaptive Budget Allocation Strategy
论文展示了 Ada-KV 的“可迁移增强”能力：不仅能提升 SnapKV/Pyramid，也可增强后续方法（如 CriticalKV、DefensiveKV）。在给出的 LongBench question-agnostic 结果中，结合 Ada-KV 后分数继续提升，例如 20% cache 时 DefensiveKV 从 `43.78` 提升到 `46.68`。

## 6 Conclusion
论文贡献可以概括为三点：
- 理论上，把 Top-k 淘汰目标与输出扰动上界联系起来；
- 方法上，提出首个 head-wise adaptive budget allocation；
- 工程上，实现了可插拔、可高效落地的 Ada 版本，并在两大长上下文基准的两种评估场景中验证了收益。

## Appendix A Appendix
附录包含：
- Theorem 推导细节；
- Ruler / LongBench 详细分任务结果；
- $\alpha$ 稳健性分析；
- 额外可视化与 benchmark 配置细节；
- Limitations：当前 head-wise 分配主要在单层内进行，未来可探索跨层联合分配。

## 相关链接（双向）
- [[KV Cache]]
- [[SnapKV]]
- [[PyramidKV]]
