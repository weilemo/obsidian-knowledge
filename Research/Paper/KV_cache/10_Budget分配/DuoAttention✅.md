---
created: 2026-04-09
published: 2024-10-14
type: paper
status: 已读
tags: [DuoAttention, KVCache, LLMInference, LongContext]
aliases: [DuoAttention]
summary: "将注意力头划分为 Retrieval Heads 与 Streaming Heads：前者保留全量 KV，后者仅保留 sink+recent 的常数缓存，在保持长上下文能力的同时显著降低 prefill/decoding 的时延与显存。"
pdf-url: Attachments/arxiv_2410.10819.pdf
source-url:
  - https://arxiv.org/abs/2410.10819
  - Attachments/arxiv_2410.10819.pdf
  - https://github.com/mit-han-lab/duo-attention
---

# DuoAttention: Efficient Long-Context LLM Inference with Retrieval and Streaming Heads

## PDF
- [[Attachments/arxiv_2410.10819.pdf]]

## Abstract
这篇工作针对长上下文推理的核心瓶颈提出了一个非常“结构化”的方案：并不是所有 attention heads 都需要完整历史 KV。

作者把头分成两类：
- `Retrieval Heads`：负责跨长距离检索语义相关 token，需要 full KV；
- `Streaming Heads`：主要看 sink token 与最近 token，不需要 full KV。

DuoAttention 的部署策略是：只给 retrieval heads 保留全量 KV，给 streaming heads 使用常数长度缓存。论文报告在精度损失很小的前提下，取得了显著内存与时延收益，并且可与量化叠加，单卡 A100 上支持到百万级以上上下文。

## 1 Introduction
论文先明确了长上下文推理的三重代价：
- decoding 随序列长度线性增长；
- pre-filling 计算近似二次增长；
- KV cache 显存随长度线性增长。

文中给出的例子是：Llama-3-8B 若用 FP16 KV cache 服务 1M token，KV 需求约 137GB，超过单张 80GB GPU。

作者认为已有路线各有缺口：
- 架构改造（如 GQA）需要预训练阶段介入；
- 近似注意力方案常牺牲长上下文能力；
- KV 量化只降存储，不直接降 attention 计算；
- 系统优化（FlashAttention/vLLM 等）不直接缩 KV 体积。

因此本文核心问题是：
在不改模型参数的前提下，如何把“必须 full KV 的头”与“可流式压缩的头”区分开，并落地到高效推理实现。

## 2 DuoAttention

### 2.1 Retrieval Heads 与 Streaming Heads
作者先做定性观察：
- retrieval heads 在生成时会回看远处语义相关位置；

这意味着对 streaming heads 可以丢弃中间历史 token，仅保留 sink+recent，理论上把其缓存复杂度压到常数级。

### 2.2 用优化法识别 Retrieval Heads
#### 2.2.1 头重要性的可训练门控
给每层每个 KV head 一个门控系数 $\alpha_{i,j}\in[0,1]$，混合 full attention 与 streaming attention：

$$
\texttt{attn}_{i,j}
= \alpha_{i,j}\cdot \texttt{full\_attn}
+ (1-\alpha_{i,j})\cdot \texttt{streaming\_attn}.
$$

其中：

$$
\texttt{full\_attn}=\mathrm{softmax}(QK^\top\odot M_{\text{causal}})V,
$$

$$
\texttt{streaming\_attn}=\mathrm{softmax}(QK^\top\odot M_{\text{streaming}})V.
$$

这里 $M_{\text{streaming}}$ 是仅允许关注 sink+recent 的 $\Lambda$ 型 mask。直觉上，若某头变成 streaming 后输出几乎不变，则其 $\alpha$ 会被压低。

#### 2.2.2 合成数据监督（Passkey）
论文没有只用自然语言建模损失，而是构造了 passkey 合成任务：在超长上下文中随机插入多段 passkey，末尾要求模型回忆。这样训练信号几乎全部指向“长距离检索能力”，更适合筛 retrieval heads。

#### 2.2.3 损失函数（训练门控参数 ）
蒸馏项（只在 passkey 尾部 token 上计算）+ 稀疏正则：

$$
\mathcal{L}_{\text{distill}}
=\frac{1}{N}\sum_{i=1}^{N}\sum_{j=T-l+1}^{T}
\left(H_{\text{full}}^{(i)}[j]-H_{\text{mixed}}^{(i)}[j]\right)^2,
$$

$$
\mathcal{L}_{\text{reg}}=\sum_{i=1}^{L}\sum_{j=1}^{H}|\alpha_{i,j}|,
$$

$$
\mathcal{L}=\mathcal{L}_{\text{distill}}+\lambda\mathcal{L}_{\text{reg}}.
$$

文中实验设置为 $\lambda=0.05$，仅训练门控参数（量级是 $N\times H$ 个），约 2000 steps 可完成。

#### 2.2.4 公式直觉：为什么是“尾部蒸馏 + 稀疏正则”
这组目标函数可以理解为“性能约束 + 成本约束”的组合：

- 蒸馏项
$$
\mathcal{L}_{\text{distill}}
=\frac{1}{N}\sum_{i=1}^{N}\sum_{j=T-l+1}^{T}
\left(H_{\text{full}}^{(i)}[j]-H_{\text{mixed}}^{(i)}[j]\right)^2
$$
作用是让 mixed attention 的隐藏状态贴近 full attention 的 teacher 行为。

- 稀疏正则
$$
\mathcal{L}_{\text{reg}}=\sum_{i=1}^{L}\sum_{j=1}^{H}|\alpha_{i,j}|
$$
作用是把更多门控压向 0，促使更多 heads 走 streaming 路径，从而真正省 KV 与算力。

其中“passkey 尾部 token”指的是合成样本里答案 key（通常是数字串）对应的最后 $l$ 个 token。  
只在这部分计算蒸馏，是因为 retrieval 能力最直接体现在“是否能正确生成 key 尾部”；这样监督更聚焦长程检索信号，也更省训练开销。

为什么不能只用蒸馏项：  
若没有 $\mathcal{L}_{\text{reg}}$，最容易的解是 $\alpha_{i,j}\approx 1$（几乎全头 full attention），虽然拟合好但几乎不省成本。  
因此需要 L1 稀疏项与蒸馏项配合：前者推动压缩，后者防止性能塌陷。

### 2.3 部署阶段（真正省算力/省显存的部分）
#### 2.3.1 二值化头类型
训练后按阈值 $\tau$ 把头二值化：

$$
\texttt{attn}_{i,j}=
\begin{cases}
\texttt{full\_attn}, & \alpha_{i,j}>\tau \\
\texttt{streaming\_attn}, & \text{otherwise}
\end{cases}
$$

即：$\alpha$ 高的头保留 full KV（retrieval），其余头走 streaming 缓存。

#### 2.3.2 工程实现要点
- 每层两套 cache：retrieval heads 的 full KV + streaming heads 的常数 KV；
- 先重排 Q/K/V 投影通道，把两类 heads 按连续分组，避免散乱 gather/scatter；
- 对新 token 分头计算后再拼接输出。

#### 2.3.3 Chunked Prefilling 复杂度改进
对 streaming heads，论文给出 prefill 复杂度从：

$$
O(L^2)\rightarrow O(LK),
$$

内存从：

$$
O(L)\rightarrow O(K),
$$

其中 $L$ 是序列长度，$K$ 是 chunk size。核心原因是每个 chunk 只需要与常数规模上下文交互。

## 3 Experiments

### 3.1 Setup
- 长上下文基准：Needle-in-a-Haystack (NIAH)、LongBench；
- 短上下文基准：MMLU、MBPP、MT-Bench；
- 模型：Llama-2/3、Mistral（含 MHA 与 GQA）；
- 对比：H2O、TOVA、StreamingLLM、FastGen。

头比例设置示例：
- Llama-2-7B-32K（MHA）用 25% retrieval ratio；
- Llama-3-8B-1048K（GQA）用 50% retrieval ratio。

### 3.2 Long-Context 结果
#### 3.2.1 NIAH
在同等 KV 预算下，DuoAttention 在不同深度、长序列条件下保持高检索准确率；基线方法普遍因淘汰关键历史 KV 而退化明显。

#### 3.2.2 LongBench
论文报告 DuoAttention 在 KV 预算-精度折中上整体优于基线，并在不少任务上接近 full attention。

附录全表给出两组代表性平均分：
- Llama-3-8B-1048K：Full 40.08，Duo(50%) 40.21；
- Llama-2-7B-32K：Full 37.52，Duo(25%) 34.49（显著优于同预算 H2O/SLLM/TOVA）。

### 3.3 Short-Context 结果
在 MMLU、MBPP、MT-Bench 上，DuoAttention 在 50% KV 预算下总体接近无损，并通常优于同预算对比方法。说明该方法没有用“短任务能力明显掉点”来换长上下文效率。

### 3.4 Efficiency（论文最关键的工程价值）
论文给出的峰值收益（跨预算扫描）包括：
- 解码显存降低最高约 $2.55\times$（MHA）/$1.67\times$（GQA）；
- 解码速度提升最高约 $2.18\times$（MHA）/$1.50\times$（GQA）；
- 预填充速度提升最高约 $1.73\times$（MHA）/$1.63\times$（GQA）。

并且这些收益与 retrieval ratio 呈现可解释的线性趋势：retrieval 比例越低，节省越明显。

### 3.5 与量化组合
DuoAttention 与权重量化/KV 量化兼容。论文在 Llama-3-8B + A100-80G 上报告：
- 8-bit 权重 + 4-bit KV + DuoAttention，可支持约 3.30M token；
- 相比朴素 BF16 full attention，容量提升约 $6.4\times$。

### 3.6 Ablation
论文消融主要结论：
- “优化式识别”优于仅靠 attention profiling；
- 用 passkey 合成数据做识别优于直接语言建模损失；
- 识别阶段需要 sink+recent 共同约束，单独用一边效果差；
- 部署阶段 sink/recent 增大到一定阈值后收益趋于饱和。

## 4 Related Work
论文把相关方法分为四类：
- 架构层（MQA/GQA、线性注意力等）；
- 近似注意力（Sparse/Longformer/BigBird/H2O/TOVA/StreamingLLM/FastGen 等）；
- KV 量化（8-bit/4-bit）；
- 系统优化（FlashAttention、vLLM、FlashDecoding、RingAttention）。

DuoAttention 的定位是“头级异构缓存策略”：
- 比纯系统优化更直接缩减 KV 规模；
- 比纯量化同时兼顾计算与存储；
- 比统一淘汰策略更贴合不同头的功能差异；
- 且不需要重训主模型参数。

## 5 Conclusion
这篇工作的核心贡献不是“提出又一个淘汰规则”，而是把 KV 压缩问题改写成“头功能分治”：
- retrieval heads 保证长程检索能力；
- streaming heads 提供常数缓存与线性可扩展性。

这种分治结构让方法同时打到三件事：
- 长上下文能力保留；
- decoding/prefill 速度提升；
- KV 显存压力大幅下降。

## Appendix A 关键补充信息
- 训练实现使用 FSDP2 + DeepSpeed Ulysses 序列并行；
- 流式 attention 训练端使用 block-sparse 近似；
- 给出了完整 LongBench 明细表，以及与 FastGen 在可跑子集上的对比；
- 说明了 H2O/TOVA/FastGen 在超长上下文上的实现限制与评测修正方式。

## 相关链接（双向）
- [[KV Cache]]
- [[H2O✅]]
- [[SnapKV✅]]
- [[PyramidKV✅]]
- [[Ada-KV✅]]
