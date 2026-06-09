---
created: 2026-05-24
published: 2024-09-18
type: paper
status: 未读
tags: [mllm, qwen2-vl, dynamic-resolution, visual-token, video]
aliases: [Qwen2-VL, Qwen2-VL Technical Report]
summary: "Qwen2-VL 技术报告，重点在任意分辨率感知、动态视觉 token、视频理解和 OCR/GUI 等实用多模态能力。"
pdf-url: Attachments/arxiv_2409.12191.pdf
source-url: https://arxiv.org/abs/2409.12191
---

# Qwen2-VL: Enhancing Vision-Language Model's Perception of the World at Any Resolution

## 定位

这篇代表现代 MLLM 从静态图像问答走向任意分辨率、视频和真实视觉任务。

## 读这篇要抓什么

- 任意分辨率输入如何变成视觉 token。
- 动态分辨率如何影响上下文长度和推理成本。
- OCR、文档、GUI、video 等任务对模型有什么新要求。
- 它与 coding agent 的潜在连接：截图 bug、网页 UI、notebook 图表、IDE 状态。

## 对你的主线的价值

如果你要把 coding agent 扩成 MLLM agent，Qwen2-VL 是很好的工程参照。尤其是 GUI / web / notebook 场景，视觉 token budget 会直接影响 long-context 和 memory 设计。

## 分类判断

放在 `MLLM/20_动态分辨率与视觉Token`，因为核心是视觉 token 和分辨率处理。

## 相关链接

- [[MLLM-研究地图]]
- [[Visual-Instruction-Tuning]]
