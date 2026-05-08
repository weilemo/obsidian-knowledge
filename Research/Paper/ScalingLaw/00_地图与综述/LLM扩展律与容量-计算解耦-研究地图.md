---
created: 2026-04-22
type: note
status: evergreen
tags: [scaling-law, llm, dense-scaling, moe, token-indexed-parameters]
aliases: [LLM扩展律地图, Scaling Law Map]
summary: "围绕 LLM 质量-计算扩展规律，整理 dense、MoE 与 token-indexed parameter 三条扩展轴。"
---

# LLM扩展律与容量-计算解耦-研究地图

## 主题定义
这个主题关注一个核心问题：在固定或受限计算预算下，如何继续提升模型质量。当前可分为三类扩展轴：
- dense 参数扩展（经典 scaling law）；
- 稀疏专家扩展（MoE）；
- token-indexed 参数扩展（JTok/JTok-M）。

## 当前收录

### 10_新扩展轴与容量-计算解耦
- [[JTok-On-Token-Embedding-as-another-Axis-of-Scaling-Law]]

## 分类理由
- `JTok` 被放入本主题而不是 `KV_cache` / `SparseAttention`，因为它的论文主问题是“扩展律与质量-计算前沿重塑”，KV 与稀疏计算只属于系统实现层面的配套，不是其研究主线。
