---
created: 2026-04-09
published: 2023-06-24
type: paper
status: 已读
tags:
  - H2O
  - KVCache
  - HeavyHitter
  - LLMInference
aliases:
  - H2O
  - Heavy-Hitter Oracle
summary: 把 KV 淘汰建模为动态子模问题，提出 heavy-hitter + recent 的低成本在线保留策略，在低预算下保持精度并显著提升吞吐。
pdf-url: Attachments/arxiv_2306.14048.pdf
source-url:
  - https://arxiv.org/abs/2306.14048
  - Attachments/arxiv_2306.14048.pdf
  - https://github.com/FMInference/H2O
---

# H$_2$O: Heavy-Hitter Oracle for Efficient Generative Inference of Large Language Models

## PDF
- [[Attachments/arxiv_2306.14048.pdf]]

## Abstract
论文聚焦 LLM 生成阶段的 KV cache 瓶颈。核心观察是：注意力高度稀疏，且累计注意力呈幂律分布，少数 token（heavy hitters）贡献了大部分注意力质量。基于此，作者提出 H$_2$O：动态保留 heavy-hitter token 与最近 token 的 KV，并把这一过程形式化为动态子模优化。实验报告在 20% KV 预算下可在多任务上维持接近 full cache 的效果，同时系统吞吐和延迟显著改善。

## 1 Introduction
作者先明确问题规模：在 30B 模型、batch size=128、序列长度 1024 的设定下，KV cache 可达约 180GB。也就是说，除了模型参数本身，生成阶段的中间状态已成为部署瓶颈。

论文定义了“理想 KV cache 策略”的三个目标：
- 小 cache：降低内存占用；
- 低 miss rate：不破坏生成质量；
- 低开销淘汰：不让 eviction 本身变成新瓶颈。

对应三点挑战：
- 每一步生成是否真的可以不看所有历史 token？
- 最优淘汰策略是组合搜索问题；
- 即使离线能算“最优”，在线部署也可能代价过高。

引言提出三条关键经验结论作为解法基础：
- 注意力在推理时高度稀疏；
- 累计注意力存在 heavy-hitter；
- 使用“局部统计”的 greedy 近似在实践中接近“全局统计”。

## 2 Related Work and Problem Setting

### 2.1 Related Work
论文把相关工作分为三类：
- LLM 高效推理：剪枝、量化、条件计算等；
- 稀疏/低秩注意力近似：Reformer、Performer、Sparse Transformer 等；
- 经典缓存策略：LRU/LFU 等频率-时序驱动策略。

作者的定位是：不改模型训练，不额外微调，直接在生成阶段优化 KV cache 的在线淘汰策略。

### 2.2 Problem Formulation
记查询矩阵和键矩阵分别为 $Q\in\mathbb{R}^{n\times d}$、$K\in\mathbb{R}^{n\times d}$，缓存预算为 $k<n$。第 $i$ 步保留的 token 索引集合记为 $S_i$。

淘汰策略满足：
$$
|S_i|=k,\qquad |S_i\setminus S_{i-1}|\le 1
$$
即每步最多替换一个 KV 槽位。

受限缓存下第 $i$ 步注意力写作：
$$
o_i = D_i^{-1}\cdot \exp\!\big(Q_{i,*}(K_{S_i,*})^\top\big)
$$
$$
D_i=\Big(\exp\!\big(Q_{i,*}(K_{S_i,*})^\top\big)-\mathbf{1}_{[i]\setminus S_i}\Big)\cdot \mathbf{1}_i
$$
目标是让受限缓存生成过程尽可能接近 full-cache 生成过程。

## 3 Observations

### 3.1 Sparsity for Small Cache Size
在 OPT 系列模型上，作者统计到注意力矩阵在几乎所有层都超过 95% 稀疏。直观含义是：每一步真正“有用”的历史 KV 只占很小比例，为小预算缓存提供了可行性基础。

### 3.2 Heavy-Hitters for Low Miss Rate
作者观察到累计注意力分布呈幂律：少数 token 持续获得高累计注意力。把这些 token 屏蔽后，生成质量明显恶化，说明其是功能性关键 token，而非可随意压缩的冗余项。

进一步地，累计注意力与词频共现存在相关性，这解释了 heavy-hitter 现象为何稳定出现。

## 4 Heavy-Hitter Oracle

### 4.1 Greedy Algorithm for Low-Cost Policy
这一节解决的是在线组合优化问题：在固定 KV 预算 $k$ 下，如何每步只做极小改动，却尽量逼近 full-cache 生成轨迹。

#### 先修知识（最小集合）
- $[n]=\{1,2,\dots,n\}$，$2^{[n]}$ 是所有子集（幂集）。
- 集合函数：$f:2^{[n]}\to\mathbb{R}$。
- 子模性（边际收益递减）：
$$
X\subseteq Y,\ x\notin Y
\Rightarrow
f(X\cup\{x\})-f(X)\ge f(Y\cup\{x\})-f(Y)
$$

#### 动态子模框架
论文记
$$
F:2^{[n]}\times 2^{[n]}\to\mathbb{R}
$$
固定状态集合 $Z$ 后，$F(Z,\cdot)$ 对候选子集是子模函数。可理解为：在当前状态 $Z$ 下，给“保留集合”打分。

第 $i$ 步缓存集合满足
$$
|S_i|=k,\qquad |S_i\setminus S_{i-1}|\le 1
$$
即缓存大小不变，且每步最多替换一个槽位（low-cost）。

#### Greedy 低成本更新（1-swap）
先把新 token 纳入候选池：
$$
G_i=S_{i-1}\cup\{i\}
$$
然后只做一次删除决策：
$$
u=\arg\max_{v\in G_i} F_{\text{score}}(G_i\setminus\{v\}),\qquad
S_i=G_i\setminus\{u\}
$$
即“删掉谁能让剩余集合分数最高，就删谁”。若 $F_{\text{score}}$ 是可加分数，这等价于删除最小贡献项。

#### 局部统计与 heavy-hitter
H$_2$O 用局部累计注意力来实例化 $F_{\text{score}}$（在线可计算），从而近似识别 heavy-hitter，而不需要不可得的未来全局统计。

#### 一个简化数值例子
设 $k=3$。step 4 前 $S_3=\{1,2,3\}$，新 token 为 $4$：
$$
G_4=\{1,2,3,4\}
$$
若局部分数是 $[1.4,1.5,0.5,0.6]$，删除第 3 个，得
$$
S_4=\{1,2,4\}
$$
step 5 时新 token 为 $5$：
$$
G_5=\{1,2,4,5\}
$$
若分数更新为 $[1.43,1.52,0.65,0.9]$，删除第 4 个，得
$$
S_5=\{1,2,5\}
$$

#### Figure 3 解读与 Algorithm 1 指代
- 上半图（Decoding Step 4）：第 4 步执行一次 1-swap，红叉是被淘汰项。
- 中间图（Decoding Step 5）：第 5 步重复同样规则。
- 下半图（Eviction w. Global Statistic, infeasible）：若能访问未来全局统计，可能选出不同淘汰对象，但在线解码做不到。

图注中的 “Algorithm 1” 指的就是本节的 H$_2$ eviction 贪心算法（低成本在线更新规则）。

实践中，论文采用 heavy-hitter + recent 的联合保留（常见近似各占一半预算）以平衡长期锚点与局部连贯性。

### 4.2 Theoretical Guarantee and System Implementation
论文在“温和假设”下给出近似保证：
$$
f(\widetilde S_i)\ge (1-\alpha)(1-1/e)\max_{|S|=k}f(S)-\beta
$$
其中 $\alpha\in(0,1),\beta>0$。

系统实现上，作者强调 eviction 时不做昂贵 memory swap，而是直接复用/覆盖槽位，减少 I/O 开销。

## 5 Empirical Evaluation

### 5.1 End-to-End Accuracy Under Cache Budget
模型覆盖 OPT、LLaMA、GPT-NeoX，多任务来自 HELM 与 lm-eval-harness。

主结论：
- 当预算低于 20% 时，H$_2$O 在多数任务上仍接近 full cache（约 5x 内存缩减）；
- 相比只保留 recent 的 Local 策略，H$_2$O 在模型规模、任务类型上都更稳定；
- 在一些长序列任务里，Local 会明显崩溃，而 H$_2$O 在 20% 预算下仍可接近 full-cache 表现。

论文还显示 H$_2$ 信号可增强其它稀疏策略（如 strided/fixed sparse baseline），显著降低低预算下的退化。

### 5.2 Throughput and Latency
论文把 H$_2$O 集成到 FlexGen，并在端到端设置（含 prefill+decode）下评测。

摘要级结果（20% 预算）：
- 相对 FlexGen 吞吐最高约 $3\times$；
- 相对 DeepSpeed ZeRO-Inference 与 HF Accelerate 最高约 $29\times$；
- 同 batch size 下延迟最高降低约 $1.9\times$。

表格中的典型数字（T4）包括：
- `512+1024, OPT-6.7B`：FlexGen `16.9 token/s`，H$_2$O `52.1 token/s`；
- XSUM, `OPT-30B`：FlexGen `3.29 token/s`，H$_2$O `6.70 token/s`。

A100 上 `2048+2048, OPT-6.7B, batch=24`：
- latency: `99.5s -> 53.5s`；
- throughput: `494.1 -> 918.9 token/s`。

### 5.3 Ablation Results
论文给出 5 组关键消融问答：
- 可扩展到超长流式输入，报告可处理到 400 万 token，并优于 StreamLLM 困惑度；
- 在 zero-shot 到 ten-shot 场景都稳定；
- 与量化兼容；
- 仅保留 heavy 或仅保留 local 都不够，二者结合最稳；
- 附录中观察到生成文本多样性提升。

## 6 Conclusion and Discussion
H$_2$O 的贡献不只是一个启发式规则，而是把 KV 淘汰从“局部工程技巧”提升为“有经验规律 + 有近似保证 + 可系统落地”的完整路径。后续大量 KV 压缩工作沿用了它提出的核心范式：在极低预算下同时保留“全局关键 token（heavy-hitter）”与“局部近期上下文（recent）”。

## Appendix Notes
附录补充了实现细节、更多实验（量化、streaming、多 shot）、以及完整理论推导（动态子模、鲁棒 greedy、误差传播分析）。

## 相关链接（双向）
- [[KV Cache]]
- [[MixKV]]
- [[SnapKV✅]]
