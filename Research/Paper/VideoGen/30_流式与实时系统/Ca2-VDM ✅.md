---
created: 2026-03-07
published: 2024-11-25
type: paper
status: 已读
tags:
  - CausalDiffusion
  - Autoregressive
  - KVCache
  - CacheSharing
  - VideoGeneration
aliases:
  - Ca2-VDM
summary: 因果生成+缓存共享实现高效AR视频扩散
pdf-url: Attachments/arxiv_2411.16375v2.pdf
github-url: https://github.com/Dawn-LX/CausalCache-VDM
---


# Ca2-VDM: Efficient Autoregressive Video Diffusion Model with Causal Generation and Cache Sharing
## PDF
- [[Attachments/arxiv_2411.16375v2.pdf]]

## 一句话摘要
Ca2-VDM 通过因果时序计算（Causal Generation）和跨去噪步共享缓存（Cache Sharing），在保持生成质量的同时显著降低 AR 视频扩散的重复计算与显存开销。

## 图解问答（你的问题 + 完整解释）

### 图 1：Existing AR-VDM vs Ca2-VDM
![[Attachments/ca2-vdm-fig1-existing-vs-ours.png]]

**你的问题**：解释一下 Ca2-VDM 这张图。  
**完整解释**：
- 这张图在对比“旧方法为什么慢”和“Ca2-VDM 怎么省计算”。
- 上半部分 (a) 是旧的 AR-VDM：每个 AR step 都把历史条件和当前噪声块一起送进双向生成模块，每一步还要做 $T$ 次去噪（图里 `×T`），因此重叠历史会被反复计算。
- 下半部分 (b) 是 Ca2-VDM：把流程拆成两段。
  - `Causal Gen.`：只负责当前 chunk 的去噪生成。
  - `Cache Writing`：把已去噪的干净 chunk 写入 KV-cache。
- 之后下一个 AR step 直接读历史 cache，不再重算历史；并且同一 AR step 内 $T$ 个去噪步共享这份历史 cache（图中 `Cache Sharing across T denoising steps`）。
- 核心收益：从“每步重算历史”变成“历史只算一次并复用”，推理延迟和显存占用显著下降。

### 图 2：Bidirectional Attention vs Causal Attention w/ KV-cache
![[Attachments/ca2-vdm-fig2-bidir-vs-causal-kv.png]]

**你的问题**：这张图怎么理解，为什么 bidirectional attention 的 cache 不好存（存了也不通用）？  
**完整解释**：
- 左图 (a) 双向注意力里，clean token 和 noisy token 双向交互。历史 token 的表示会被未来 noisy token 影响。
- 这会导致两个问题：
  - cache 计算问题：历史 KV 依赖当前噪声状态，不能提前稳定计算。
  - cache 存储问题：不同去噪步 $t$ 的 noisy 状态不同，历史 KV 也跟着变，跨 $t$ 不能通用，只能重复存/算。
- 右图 (b) 改成因果注意力后，历史只作为“过去”被读取，不再被未来 noisy token 反向污染。
- 因此可以把 clean prefix 对应的 KV 在 `t=0` 写入 cache，后续各去噪步复用同一份 clean KV；只更新 noisy 部分。
- 一句话：双向注意力的 cache 是“全局耦合快照”，因果注意力的 cache 是“稳定前缀记忆”。

### 图 3：Ca2-VDM Pipeline（训练/推理/模块）
![[Attachments/ca2-vdm-fig3-pipeline-overview.png]]

**你的问题**：这张总览图怎么理解？  
**完整解释**：
- (a) 训练阶段：
  - 随机保留前缀帧作为 clean prefix，不加噪；
  - 对目标后缀加噪做去噪学习；
  - 使用分段 timestep embedding：prefix 用 `tEmb(0)`，target 用 `tEmb(t)`。
- (b) 推理阶段每个 AR step 分两段：
  - `Denoising Stage`（蓝色）：对当前 chunk 做 $T$ 步去噪，读取历史 temporal/spatial KV-cache（跨 $T$ 步共享）。
  - `Cache Writing Stage`（黄色）：当前 chunk 去噪完成后，用干净结果写入 cache，供下一 AR step 复用。
- (c) 模块结构是 `LayerNorm -> Prefix-Enhanced Spatial Attn -> Causal Temporal Attn -> Visual-Text Cross Attn -> Linear`，并配合 `Cyclic-TPE + SPE` 处理长程位置编码。

### 图 4：Causal Temporal Attention + Cyclic-TPE + KV 队列
![[Attachments/ca2-vdm-fig4-cyclic-tpe-kv-queue.png]]

**你的问题**：还用这张图。  
**完整解释**：
- 这张图回答两个核心问题：  
  1) 因果时序注意力在训练/推理时如何与 KV-cache 配合；  
  2) 为什么要用 Cyclic-TPE，而不是每步重分配原始 TPE。
- (a) 训练：对长度 $L$ 的序列做因果注意力（注意力图是下三角），并对时间位置做随机偏移（random shift）以提升泛化；此时还没有跨步 cache 复用。
- (b) 推理：当前 AR step 只为新 chunk 计算 $Q$，而历史前缀的 $K,V$ 直接从 cache 读取；去噪完成后在 `t=0` 进行 cache writing，把当前 chunk 的 clean $K,V$ 写入队列。
- (c) 下半部分对比：
  - 左：不使用 KV-cache 时，窗口前移后 TPE 会“重分配”到输入 token，导致同一语义内容在不同 AR step 上位置编码不一致。
  - 右：使用 KV-cache + Cyclic-TPE 时，TPE 与写入的 $K,V$ 绑定；当队列达到 $P_{\max}$ 后，最旧项出队并循环位移（cyclic shift），保持编码规则稳定。
- 关键收益：在长视频滚动生成中，避免“位置编码抖动”，同时让历史 cache 真正可复用。

### 补充问答：窗口前移、$P$、$tEmb(0)$ 和 $tEmb(t)$

**你的问题**：`P_{k+1}=P_k+l` 里的窗口和 $P$ 是什么？为什么训练/推理里有时用 `tEmb(0)`，有时用 `tEmb(t)`？  
**完整解释**：
- 定义：
  - $P_k$：第 $k$ 个 AR step 开始时，已生成并可作为条件的前缀长度。
  - $l$：该 AR step 新生成的 chunk 长度。
  - 因此前缀更新为
$$
P_{k+1}=P_k+l
$$
- 直觉：每次生成完 $l$ 帧，条件窗口就向前推进 $l$ 帧。
- timestep embedding 语义：
  - `tEmb(0)`：干净、无噪声状态。
  - `tEmb(t)`：当前扩散去噪步的带噪状态。
- 为什么这样分配：
  - 训练时：prefix 是干净条件，所以用 `tEmb(0)`；target 是带噪去噪对象，所以用 `tEmb(t)`。
  - 推理去噪阶段：当前 chunk 仍是带噪 latent，使用 `tEmb(t)`。
  - 推理写 cache 阶段：写入的是已去噪后的干净结果，为了让 cache 跨所有去噪步稳定复用，写 cache 用 `tEmb(0)`。
- 设计目标：让 clean-prefix cache 与去噪步 $t$ 解耦，实现“同一份 cache 跨 $T$ 步共享”。

## 核心贡献
- 提出因果生成：把时序注意力改为单向，允许条件帧的 KV 在前序 AR 步预计算并复用。
- 提出缓存共享：条件帧统一使用 tEmb(0)，使同一份 clean-prefix KV 可在所有去噪步复用，而非每个 t 各存一份。
- 提出时序 KV-cache 队列 + Cyclic-TPE：在可扩展长条件下维持训练/推理位置编码对齐。
- 在 AR 质量和效率上同时取得优势：与双向/固定条件基线相比更快且更省显存。


## 方法/模型（实现细节）
### 1) 问题设定与潜空间扩散
视频先经 VAE 编码为潜变量序列：
$$
\boldsymbol{z}_0 = \mathcal{E}(\boldsymbol{x}_0),\quad \hat{\boldsymbol{x}}_0 = \mathcal{D}(\hat{\boldsymbol{z}}_0)
$$
训练目标是条件生成未来帧：
$$
p_\theta(\boldsymbol{z}_{0}^{P:L}\mid \boldsymbol{z}_0^{0:P})
$$
其中前缀 $\boldsymbol{z}_0^{0:P}$ 为 clean prefix，后缀为 denoising target。

### 2) 部分加噪训练目标（支持 cache sharing）
在训练中仅对目标后缀加噪，并使用分段 timestep：prefix 用 $t=0$，target 用 $t$。
$$
\widetilde{\mathcal{L}}_{\text{simple}}(\theta)=
\mathbb{E}_{\boldsymbol{z},\boldsymbol{\epsilon},t}
\left[\left\|
\left(\boldsymbol{\epsilon}_\theta([\boldsymbol{z}_0^{0:P},\boldsymbol{z}_t^{P:L}],\boldsymbol{t})-\boldsymbol{\epsilon}\right)\odot\boldsymbol{m}
\right\|_2^2\right]
$$
其中 $\boldsymbol{m}$ 只对 denoising target 计损失。

### 3) 因果时序注意力（Causal Generation）
把时序注意力改为下三角掩码：
$$
\text{CausalAttn}(\boldsymbol{Q},\boldsymbol{K},\boldsymbol{V})=
\text{Softmax}\left(\frac{\boldsymbol{Q}\boldsymbol{K}^\top}{\sqrt{C'}}+\boldsymbol{M}\right)\boldsymbol{V}
$$
其中 $\boldsymbol{M}_{i,j}=-\infty$（当 $i<j$）否则为 0。
这保证当前帧只依赖过去帧，使 prefix 的 KV 可在历史 AR 步提前写入并复用。

### 4) Prefix-Enhanced Spatial Attention
对每个目标帧在空间注意力里拼接一个短前缀（长度 $P'$）增强条件引导：
$$
\bar{\boldsymbol{K}}(i)=
\begin{cases}
\boldsymbol{W}^K[\boldsymbol{h}_0^{P-P'};\ldots;\boldsymbol{h}_0^{P-1};\boldsymbol{h}_t^i], & i\ge P\\
\boldsymbol{W}^K[\boldsymbol{h}_0^i;\ldots;\boldsymbol{h}_0^i], & i<P
\end{cases}
$$
值向量同理增强。文中实验显示 PE 与更大 $P_{max}$ 均能提升长程一致性。

### 5) AR 推理：去噪阶段 + 写缓存阶段
每个 AR 步生成一个 $l$ 帧 chunk：
- 去噪阶段：在条件前缀 $\boldsymbol{z}_0^{0:P_k}$ 下去噪目标 $\boldsymbol{z}_t^{P_k:P_k+l}$。
- 写缓存阶段：把当前生成 chunk 的 clean KV 写入队列供下一 AR 步复用。

时序 KV 拼接为：
$$
\tilde{\boldsymbol{K}}(k,t)=[\boldsymbol{K}_0^{0:P_k},\boldsymbol{K}_t^{P_k:P_k+l}],\quad
\tilde{\boldsymbol{V}}(k,t)=[\boldsymbol{V}_0^{0:P_k},\boldsymbol{V}_t^{P_k:P_k+l}]
$$
并计算：
$$
\text{CausalAttn}(\boldsymbol{Q}_t^{P_k:P_k+l},\tilde{\boldsymbol{K}}(k,t),\tilde{\boldsymbol{V}}(k,t))
$$

### 6) Cyclic-TPE 与队列机制
当条件长度达到 $P_{max}$ 后，最早 KV 出队；为保持训练/推理位置编码一致，采用循环位移的 temporal positional embeddings（Cyclic-TPEs）。

## 实验与结果
- 生成质量：在 MSR-VTT/UCF101 上 zero-shot 与 finetune FVD 具竞争力；长程 AR 的 step-FVD 相比 GenLV/StreamT2V 更稳。
- 时间开销（A100, 256x256, 80 帧, 100 denoise steps）：
  - StreamT2V: 150s
  - OS-Ext: 130.1s
  - OS-Fix: 77.5s
  - **Ca2-VDM: 52.1s**
- 复杂度趋势：OS-Ext 随条件扩展趋向二次增长，Ca2-VDM 近线性增长。
- 显存（与 Live2Diff 对比，T=50）：
  - Live2Diff KV: 17.70GB（总 29.46GB）
  - **Ca2-VDM w/ PE KV: 0.86GB（总 4.79GB）**
  - **Ca2-VDM w/o PE KV: 0.77GB（总 3.95GB）**

## 局限与注意事项
- 训练效率权衡：可扩展条件与 Cyclic-TPE 提高了训练覆盖需求，收敛时间可能变长。
- 长期生成退化仍存在：超长视频仍可能出现外观漂移与质量下降。
- 队列长度与 $P_{max}$ 需要按场景调参，在一致性与计算成本间折中。

## 相关链接（双向）
- [[Autoregressive Video Diffusion]]
- [[KV Cache]]
- [[Causal Attention]]
- [[流式视频生成]]
