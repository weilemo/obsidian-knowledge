---
created: 2026-05-02
type: note
status: evergreen
tags:
  - research-map
  - kv-cache
  - quantization
  - compression
aliases:
  - KV 量化与编码压缩研究地图
  - KV Cache Quantization Map
summary: 梳理 KV cache 量化与编码压缩路线，从标量量化、预测增强、误差补偿到向量量化与视频特化量化，作为本目录的导航入口。
---

# KV 量化与编码压缩研究地图

## 这条线在研究什么
这一支工作的核心问题不是“保留哪些 token”，而是：

$$
\text{在尽量不破坏生成质量的前提下，如何把 KV cache 存得更小、读得更快。}
$$

和 `H2O`、`SnapKV` 这类“重要性选择 / 淘汰”路线不同，这里更关注：
- 量化 bit-width；
- 误差补偿；
- 码本压缩；
- 训练免费或轻量校准的系统实现。

## 当前目录里的论文怎么分

### 1. 标量量化起点
- [[KIVI]]
- [[KVQuant]]

这一组的共同特点是：
- 先把 KV 当作数值分布问题；
- 再决定 `K` 和 `V` 应该沿什么维度量化；
- 目标是把 sub-4-bit 做到尽量可用。

如果你想先理解“为什么 K/V 不该一把梭同一种量化方式”，先读这组。

### 2. 预测增强 / 自适应量化
- [[Cache-Me-If-You-Must]]

这一路的关键变化是：
- 不直接压整个原始 KV；
- 而是先预测可恢复部分，再量化残差。

它比纯量化器设计更进一步，开始显式利用缓存内部结构依赖。

### 3. 误差补偿式近无损压缩
- [[GEAR]]

这条线强调：
- 光靠统一低比特量化不够；
- 还要用低秩和稀疏结构去补偿量化误差。

它很适合和“极低比特但不想明显掉点”的目标绑定理解。

### 4. 向量量化 / 编码压缩
- [[PQCache]]
- [[VQKV]]

这组更像“重新编码 KV 表征”：
- `PQCache` 用产品量化；
- `VQKV` 用向量量化和码本索引。

和标量量化相比，它们更关心高压缩率下的重建 fidelity。

### 5. 视频 / 多模态特化量化
- [[VidKV]]
- [[Quant-VideoGen]]

这组最值得关注的点是：
- 视频场景里，`value` 的最佳量化粒度可能和文本 LLM 不同；
- 视频生成里的时空冗余可以在量化前被先利用；
- 长视频 forcing 里的 KV 量化，不只是 LLM 方案的简单平移。

如果你在做 `longvideo-kvcache-quant` 项目，这组就是最直接的主线。

## 推荐阅读顺序

### 路线 A：先建通用量化直觉
1. [[KIVI]]
2. [[KVQuant]]
3. [[GEAR]]
4. [[VQKV]]

### 路线 B：直接面向你的视频项目
1. [[Quant-VideoGen]]
2. [[VidKV]]
3. [[KIVI]]
4. [[Cache-Me-If-You-Must]]
5. [[Relax-Forcing]]
6. [[Deep-Forcing]]

## 和其他目录的关系

### 与 `20_重要性判断`
- 那边回答“留谁”；
- 这边回答“怎么存”。

### 与 `10_Budget分配`
- 那边回答“预算怎么分”；
- 这边回答“给定预算后如何进一步压缩”。

### 与 `VideoGen`
- 那边关心长视频 rollout、一致性、memory role；
- 这边可以提供视频项目里真正可部署的 KV 量化工具箱。

## 当前最值得继续补的空位
- 缺一个本目录自己的“统一对比表”，把 bit-width、粒度、是否训练免费、是否视频专用放在一起。
- 缺一条“结构化记忆 + 量化联合设计”的专门笔记，连接 [[Relax-Forcing]] / [[Deep-Forcing]] 和本目录。

## 相关链接（双向）
- [[KV Cache 8篇论文总结（Budget分配 + 重要性判断）]]
- [[Quant-VideoGen]]
- [[Relax-Forcing]]
- [[Deep-Forcing]]
