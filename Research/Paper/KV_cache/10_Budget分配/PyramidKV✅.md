---
created: 2026-04-09
published: 2024-06-04
type: paper
status: 已读
tags:
  - PyramidKV
  - KVCache
  - LLMInference
  - LongContext
aliases:
  - PyramidKV
summary: 基于跨层注意力“金字塔汇聚”规律进行分层非均匀 KV 预算分配，在极低缓存预算下显著优于固定预算方案。
pdf-url: Attachments/arxiv_2406.02069.pdf
source-url:
  - https://arxiv.org/abs/2406.02069
  - Attachments/arxiv_2406.02069.pdf
  - https://github.com/Zefan-Cai/PyramidKV
---

# PyramidKV: Dynamic KV Cache Compression based on Pyramidal Information Funneling

## PDF
- [[Attachments/arxiv_2406.02069.pdf]]

## Abstract
论文提出一个核心问题：不同 Transformer 层的注意力模式并不一致，为什么 KV 压缩还要在所有层使用同样的缓存预算？作者观察到长上下文下存在“Pyramidal Information Funneling”：低层注意力更分散，中层在文档内聚合，高层集中到少数关键 token。基于这一规律，PyramidKV 使用“低层多给预算、高层少给预算”的分层 KV 分配，并结合 attention score 做 token 选择。实验显示，在 LongBench 上仅保留约 12% KV 即可接近 FullKV；在极限场景（约 0.7% KV）显著超越固定预算方法。

## 1 Introduction
论文从部署瓶颈切入：长上下文推理时，KV cache 显存随序列长度线性增长。文中给出的例子是，LLaMA-2 7B 在 100K 输入下仅 KV cache 就需要 50GB 以上显存，而 2K 输入不到 1GB。

已有方法（如 StreamingLLM、SnapKV、H2O）主要优化“保留哪些 token”，但通常默认“每层缓存大小相同”。作者指出这会带来两个问题：
- 高层注意力已很稀疏，固定大预算会浪费；
- 低层注意力更稠密，固定小预算会丢关键信息。

因此本文把问题重心转为：在总预算固定时，如何跨层分配预算。

## 2 Related Work
论文回顾三类 KV 压缩代表方法：
- `StreamingLLM`：起始 token + 局部窗口保留；
- `H2O`：recent + heavy hitter 的动态保留；
- `SnapKV`：基于观察窗口注意力选择关键 KV。

PyramidKV 的差异点是：不是只改 token 选择规则，而是先改“层预算分配策略”，再在每层内部做 token 选择。

## 3 Pyramidal Information Funneling
作者在多文档 QA 长上下文场景下可视化跨层注意力，得到三阶段模式：
- 低层：注意力近似全局散射（broad-spectrum）；
- 中层：注意力开始在各文档内部聚合（localized）；
- 高层：注意力集中到少数关键 token（massive attention / attention sink）。

这直接支持了分层预算先验：越往上层，单位 token 的信息密度越高，所需 KV 数量可以更少。e

## 4 PyramidKV
### 4.1 Preliminaries and Problem Formulation
设模型共有 $m$ 层，输入长度为 $n$。第 $l$ 层完整 KV 为 $K^l, V^l \in \mathbb{R}^{n\times d}$。压缩目标是在每层预算 $k_l<n$ 下，选出子矩阵 $K_s^l, V_s^l$，使得压缩模型在数据集 $D$ 上的表现接近 FullKV：
$$
\text{score}(K^l,V^l,D)\approx \text{score}(K_s^l,V_s^l,D)
$$

### 4.2 Proposed Method
PyramidKV 分两步：

#### 4.2.1 KV Cache Size/Budget Allocation
先保留每层最后 $\alpha$ 个 instruction tokens（文中默认 $\alpha=8$）。

在剩余总预算
$$
k_{\text{total}}=\sum_{l=0}^{m-1} k_l
$$
上，定义“底层大、顶层小”的线性预算序列。

顶层预算：
$$
k_{m-1}=\frac{k_{\text{total}}}{\beta\cdot m}
$$
底层预算：
$$
k_0=\frac{2k_{\text{total}}}{m}-k_{m-1}
$$
中间层按等差递减：
$$
k_l = k_0 - \frac{k_0-k_{m-1}}{m-1}\cdot l
$$
其中 $\beta$ 控制金字塔形状（主实验用 $\beta=20$）。

#### 4.2.2 KV Cache Selection
在每层预算确定后，按 attention score 选 token。对每个 head：
$$
A^h=\text{softmax}\!\left(\frac{Q^h(K^h)^\top}{\sqrt{d_k}}\right)
$$
分数定义为 token 从 instruction window 接收到的累计注意力：
$$
s_i^h=\sum_{j\in[n-\alpha,n]}A_{ij}^h
$$
每层每头保留分数最高的 top-$k_l$ token，其余 KV 丢弃。

## 5 Experiment
### 5.1 Setup
- 模型：LLaMA-3-8B-Instruct、Mistral-7B-Instruct、LLaMA-3-70B-Instruct  
- 基准：LongBench 17 个数据集 + Needle in a Haystack  
- 对比：SnapKV、H2O、StreamingLLM、FullKV  
- 预算公平性：让 PyramidKV 的跨层平均缓存大小与基线固定缓存大小一致（总内存一致）

### 5.2 Main Results on LongBench
论文在两种设置下报告结果：`KV Size=64`（极限内存）和 `KV Size=2048`（性能保持）。

在 `KV Size=64` 下，平均分（Avg）：
- LLaMA-3-8B：PyramidKV `34.76`，优于 SnapKV `33.05` / H2O `33.89` / StreamingLLM `30.43`
- Mistral-7B：PyramidKV `32.19`，优于 SnapKV `30.72` / H2O `30.88` / StreamingLLM `25.60`
- LLaMA-3-70B：PyramidKV `42.01`，优于 SnapKV `39.45` / H2O `39.94` / StreamingLLM `35.47`

在 `KV Size=2048` 下，PyramidKV 依然能与 FullKV 持平甚至略超（如 LLaMA-3-8B：`41.49` vs FullKV `41.46`）。

论文摘要级结论：
- 约 `12%` KV（对应较大缓存场景）可逼近 FullKV；
- 极限场景仅约 `0.7%` KV 时，优势更明显；
- 在 TREC 上最高可达 `+20.5` 绝对提升（相对其他压缩方法）。

### 5.3 Needle in a Haystack（长上下文检索）
在 8K/32K 检索实验中，PyramidKV 明显更稳：
- LLaMA-3-70B, 8K, KV=128：PyramidKV `100.0`，SnapKV `98.6`，H2O `82.3`
- LLaMA-3-8B, 8K, KV=128：PyramidKV `97.4`，SnapKV `87.4`，H2O `49.1`
- Mistral-7B, 32K, KV=128：PyramidKV `91.6`，SnapKV `80.1`，H2O `64.9`

这说明分层预算在“长上下文事实定位”任务里尤其有效。

### 5.4 Memory Reduction
LLaMA-3-8B（seq=8192, batch=1, fp16）下，Table 2 报告：
- FullKV：`6848M`（100%）
- PyramidKV, cache=2048：`1712M`（25.0%）
- PyramidKV, cache=1024：`856M`（12.5%）
- PyramidKV, cache=512：`428M`（6.3%）

总体上，PyramidKV 用显著更低内存换取有限性能损失，且在小预算下优势更大。

## 6 Conclusion
PyramidKV 的核心贡献不是提出新的 token 打分函数，而是提出“先分层分预算，再做层内选择”的范式。它把 KV 压缩从单一 token 维优化，推进到跨层资源调度问题，并用实验证明：在强内存约束下，预算分配策略本身就是决定性能的关键变量。

## Appendix A Limitations
论文明确了两点限制：
- 只在三类主流英文模型上验证（LLaMA-3-8B/70B、Mistral-7B）；
- 主要覆盖英文任务，跨语言泛化仍待验证。

## Appendix B Future Work
作者提出两个后续方向：
- 预算从“静态分层”走向“动态分层/分头”（随输入实时调整）；
- 将该策略更系统地用于 in-context learning 场景（尤其 few-shot 任务）。

## 相关链接（双向）
- [[KV Cache]]
- [[H2O✅]]
- [[SnapKV✅]]
