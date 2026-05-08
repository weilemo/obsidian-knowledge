---
created: 2026-02-25
tags:
  - research
  - llm-inference
  - kv-cache
  - paper-summary
source-url:
  - https://arxiv.org/abs/2406.02069
  - https://arxiv.org/abs/2410.10819
  - https://arxiv.org/abs/2407.11550
  - https://arxiv.org/abs/2506.05344
  - https://arxiv.org/abs/2306.14048
  - https://arxiv.org/abs/2404.14469
  - https://arxiv.org/abs/2509.00388
  - https://arxiv.org/abs/2510.20707
---

# KV Cache 8篇论文总结（Budget分配 + 重要性判断）

## 阅读范围与方法
- 你要求按 8 个 subagent 依次阅读，我按 8 个独立子任务顺序完成（每篇 1 个子任务）。
- 本笔记基于各论文 arXiv 页面（标题、摘要、发布时间）进行结构化总结，适合快速建立全局认知与选题地图。

## 一图总览

| 论文 | 方向 | 核心机制 | 粒度 | 训练需求 | 主要收益 |
|---|---|---|---|---|---|
| PyramidKV | Budget分配 | 分层金字塔预算（低层多、高层少） | layer-level | training-free | 高压缩下保持长上下文能力 |
| DuoAttention | Budget分配 | 头分工：retrieval heads 全缓存 + streaming heads 常数缓存 | head-level | 轻量优化识别头 | 显著降内存并加速 prefill/decoding |
| Ada-KV | Budget分配 | 头级自适应预算分配（有理论上界引导） | head-level | training-free/plug-in | 对既有淘汰策略一致增益 |
| SparseMM | Budget分配（MLLM） | 利用视觉头稀疏性做非对称预算 | head-level | training-free | 多模态推理加速与降内存 |
| H2O | 重要性判断 | Heavy-Hitter + recent tokens 动态保留 | token-level | training-free | 经典早期强基线，吞吐提升明显 |
| SnapKV | 重要性判断 | 基于末端 observation window 预测头偏好并聚类选 KV | head+token | training-free | 长输入下速度/内存收益大 |
| GraphKV | 重要性判断 | 图传播动态更新 token 重要性（替代静态 top-k） | token-graph | training-free/plug-in | 动态依赖建模，更稳的保留决策 |
| MixKV | 重要性判断（LVLM） | 重要性 + 多样性联合优化 | head+token | training-free | 极限预算下语义覆盖更完整 |

## 逐篇摘要（按 8 个子任务顺序）

### Subagent 1: PyramidKV (arXiv:2406.02069)
- 链接: https://arxiv.org/abs/2406.02069
- 关键词: pyramidal information funneling, layer-wise budget
- 核心观点:
  - 注意力信息在层间呈“金字塔式收敛”：底层分散，高层聚焦关键 token。
  - 因此预算不应层间均匀，而应“低层多保留、高层少保留”。
- 方法要点:
  - 动态分配各层 KV cache 大小，替代统一预算。
- 适用场景:
  - 长上下文且显存紧张、希望保留稳定精度的通用 LLM 推理。
- 局限/注意:
  - 依赖对层间注意模式假设；跨模型泛化需单独验证。

### Subagent 2: DuoAttention (arXiv:2410.10819)
- 链接: https://arxiv.org/abs/2410.10819
- 关键词: retrieval heads, streaming heads
- 核心观点:
  - 并非所有头都需要全量历史 KV；少数 retrieval heads 才真正承担长程检索。
- 方法要点:
  - retrieval heads 用 full KV；streaming heads 用常数长度缓存。
  - 用轻量优化过程识别 retrieval heads。
- 适用场景:
  - 超长上下文、需要同时优化 prefill 与 decoding 的工业推理链路。
- 局限/注意:
  - 头分类准确性是关键；模型结构差异（MHA/GQA）会影响最优配置。

### Subagent 3: Ada-KV (arXiv:2407.11550)
- 链接: https://arxiv.org/abs/2407.11550
- 关键词: adaptive head-wise budget, loss upper bound
- 核心观点:
  - 均匀头预算不是最优，头间注意模式差异显著。
- 方法要点:
  - 给出 eviction 前后注意输出差异的理论上界。
  - 基于该目标进行 head-wise 自适应预算分配，可插拔到已有方法。
- 适用场景:
  - 已在用 SnapKV/H2O 类策略，希望低改造成本继续提效。
- 局限/注意:
  - 性能收益与原始基线质量相关；需按任务重调预算分配策略。

### Subagent 4: SparseMM (arXiv:2506.05344)
- 链接: https://arxiv.org/abs/2506.05344
- 关键词: visual heads sparsity, MLLM KV optimization
- 核心观点:
  - 多模态模型里只有小部分头对视觉理解贡献显著。
- 方法要点:
  - 训练免费识别“视觉相关头”，对头分配非对称预算，优先保视觉语义。
- 适用场景:
  - MLLM/LVLM 推理（图文问答、视觉理解）中的显存与延迟优化。
- 局限/注意:
  - 对纯文本 LLM 的收益未必同量级；视觉分数估计误差会影响效果。

### Subagent 5: H2O (arXiv:2306.14048)
- 链接: https://arxiv.org/abs/2306.14048
- 关键词: heavy hitters, dynamic submodular eviction
- 核心观点:
  - 少数 heavy-hitter token 对注意力贡献占主导，且必须与 recent token 平衡保留。
- 方法要点:
  - 将 KV 淘汰建模为动态子模优化问题，提出 H2O eviction policy。
- 适用场景:
  - 作为“重要 token + 近期 token”思路的经典基线与对照组。
- 局限/注意:
  - 重在 token 级保留，未显式利用层/头结构异质性。

### Subagent 6: SnapKV (arXiv:2404.14469)
- 链接: https://arxiv.org/abs/2404.14469
- 关键词: observation window, head-specific prompt features
- 核心观点:
  - 每个头在生成时关注模式稳定，可从 prompt 末端 observation window 预估。
- 方法要点:
  - 按头选择并聚类重要 KV 位置，实现训练免费压缩。
- 适用场景:
  - 长 prompt + 高频推理场景，强调部署简单与兼容现有框架。
- 局限/注意:
  - 对 observation window 质量敏感；任务迁移时可能需调整窗口策略。

### Subagent 7: GraphKV (arXiv:2509.00388)
- 链接: https://arxiv.org/abs/2509.00388
- 关键词: graph-based eviction, decay-signal-propagation
- 核心观点:
  - 静态 top-k 难捕获 token 间动态依赖，应在推理过程中更新重要性。
- 方法要点:
  - token 作图（节点重要性 + 边相似性），通过衰减信号传播更新保留决策。
  - 可 plug-and-play 融入 SnapKV/PyramidKV。
- 适用场景:
  - 语义依赖随生成阶段变化明显的长程推理任务。
- 局限/注意:
  - 图构建与传播带来额外开销，需要精细化实现避免抵消加速收益。

### Subagent 8: MixKV (arXiv:2510.20707)
- 链接: https://arxiv.org/abs/2510.20707
- 关键词: importance + diversity, LVLM redundancy
- 核心观点:
  - 仅按重要性保留会漏掉多模态语义覆盖；需联合“重要性与多样性”。
- 方法要点:
  - 建模 head-wise 语义冗余程度，在压缩时自适应平衡 diversity 与 importance。
- 适用场景:
  - LVLM 极限预算（如 budget=64）下仍要保持多模态语义覆盖。
- 局限/注意:
  - 联合目标更复杂，调参空间增大；不同模态任务收益不完全一致。

## 研究脉络（你可以据此设计实验）
- 阶段 1（经典 token 重要性）: H2O
- 阶段 2（结构感知与工程化）: SnapKV, PyramidKV, DuoAttention, Ada-KV
- 阶段 3（动态关系与多模态）: GraphKV, SparseMM, MixKV

## 可执行的对比实验建议
- 固定模型与预算，比较 4 类策略:
  - 均匀预算（baseline）
  - 头/层预算分配（PyramidKV, DuoAttention, Ada-KV）
  - token 重要性（H2O, SnapKV）
  - 动态图与多样性（GraphKV, MixKV）
- 统一报告:
  - 质量（LongBench/RULER 或你任务集）
  - 延迟（prefill, decoding 分开）
  - 显存峰值与吞吐
  - 压缩比-精度曲线（budget sweep）

## 参考链接
- PyramidKV: https://arxiv.org/abs/2406.02069
- DuoAttention: https://arxiv.org/abs/2410.10819
- Ada-KV: https://arxiv.org/abs/2407.11550
- SparseMM: https://arxiv.org/abs/2506.05344
- H2O: https://arxiv.org/abs/2306.14048
- SnapKV: https://arxiv.org/abs/2404.14469
- GraphKV: https://arxiv.org/abs/2509.00388
- MixKV: https://arxiv.org/abs/2510.20707

## 新增收录（2026-04-18）

### 00_架构先验
- [[MQA：Fast-Transformer-Decoding-One-Write-Head-is-All-You-Need]]
- [[GQA：Training-Generalized-Multi-Query-Transformer-Models-from-Multi-Head-Checkpoints]]
- [[RWKV：Reinventing-RNNs-for-the-Transformer-Era]]
- [[RetNet：Retentive-Network-A-Successor-to-Transformer-for-Large-Language-Models]]
- [[Mamba：Linear-Time-Sequence-Modeling-with-Selective-State-Spaces]]

### 20_重要性判断
- [[H2O✅]]
- [[SnapKV✅]]
- [[Transformers-are-Multi-State-RNNs-TOVA]]

### 30_流式缓存与无限上下文
- [[StreamingLLM-Efficient-Streaming-Language-Models-with-Attention-Sinks✅]]

### 40_分层存储与外存管理
- [[Efficient-Memory-Management-for-Large-Language-Model-Serving-with-PagedAttention]]
- [[Breaking-the-Boundaries-of-Long-Context-LLM-Inference]]
- [[RetrievalAttention]]

### 50_量化与编码压缩
- [[PQCache]]

### 已迁移到 SparseAttention（计算稀疏化主线）
- [[MInference-1.0]]
- [[MMInference]]
