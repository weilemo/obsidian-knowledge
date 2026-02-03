---
created: 2026-01-25
type: paper
status: unread
tags: [LongLive, Autoregressive, Interactive, KVCache]
aliases: [LONGLIVE]
summary: "帧级AR实现交互式长视频流式生成"
pdf-url: "Attachments/arxiv_2509.22622.pdf"
github-url: ""
---

# LONGLIVE: Real-Time Interactive Long Video Generation
## PDF
- [[Attachments/arxiv_2509.22622.pdf]]
## 一句话摘要
LONGLIVE 通过 KV-recache + streaming long tuning + 短窗注意力，使因果 AR 模型可实时生成并平滑切换提示词。

## 核心贡献
- 提出 **KV-recache**：在提示词切换时重建 KV 缓存，保持语义一致与视觉连续。
- 提出 **Streaming Long Tuning**：训练中模拟长序列滚动生成，使 train-test 对齐。
- 提出 **短窗注意力 + Frame Sink**：在加速推理的同时保持长程一致性。

## 方法/模型（实现细节）
### 1) KV-recache（提示词切换）
问题：保留 KV 会导致新提示词被“旧语义”污染，清空 KV 又会导致画面断裂。
解决：在切换处使用 **已生成视频前缀 + 新提示词** 重建缓存：
- 将最近生成帧作为视觉上下文。
- 与新 prompt 一起经过 cross-attention 重新计算 KV。
- 后续生成继续使用更新后的缓存，实现平滑且语义一致的切换。

### 2) Streaming Long Tuning
训练时按“流式推理”方式滚动生成：
- 每轮生成一段短 clip，保留历史 KV；
- 下一轮在历史 KV 基础上继续生成；
- 只对当前 clip 反向传播，避免 OOM。
这样训练过程与推理过程一致，减少长序列发散。

### 3) 短窗注意力 + Frame Sink
- 短窗注意力限制可见历史窗口，降低计算复杂度。
- Frame sink 让首段关键 token 永久驻留 KV，作为全局锚点。
- 推理时保持固定大小的 KV（局部窗口 + sink），显著提升速度且保持一致性。

## 实验与结果
- 单 H100 可达约 20.7 FPS，支持 240 秒长视频。
- KV-recache 在提示词切换中兼顾一致性与新语义遵循。

## 局限与注意事项
- 需要显式检测 prompt 切换时机并触发 recache。
- 短窗注意力窗口过小会影响长期一致性，需要与 frame sink 配合。

## 相关链接（双向）
- [[交互式视频生成]]
- [[长视频生成]]
- [[自回归视频]]
