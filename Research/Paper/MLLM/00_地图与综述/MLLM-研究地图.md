---
created: 2026-05-24
type: map
status: active
tags: [paper-map, mllm, visual-instruction-tuning, 转型]
aliases: [MLLM 研究地图, 多模态大模型研究地图]
summary: "实验室转型阶段的 MLLM 入口：先看视觉指令微调和动态分辨率，再连接 GUI/coding/notebook agent。"
---

# MLLM 研究地图

## 为什么单独成类

这组论文服务于转型主线中的 **2. MLLM Pretrain - SFT - RL**。第一阶段不急着做大规模预训练，先理解现代 MLLM 的训练配方、视觉 token 处理和指令微调。

## 分类

### 10_视觉指令微调

- [[Visual-Instruction-Tuning]]：LLaVA 原始论文，理解 vision encoder + projector + LLM + instruction tuning。
- [[Improved-Baselines-with-Visual-Instruction-Tuning]]：LLaVA-1.5，重点看数据和 connector 细节如何形成强 baseline。

### 20_动态分辨率与视觉Token

- [[Qwen2-VL-Enhancing-Vision-Language-Models-Perception-of-the-World-at-Any-Resolution]]：现代 MLLM 处理任意分辨率、视频和 OCR/GUI 任务的重要入口。

## 第一阶段读法

重点回答：

1. 图像如何变成 token？
2. projector / connector 负责什么？
3. 预训练数据和指令数据分别解决什么？
4. 分辨率、OCR、GUI、video 对 token budget 有什么压力？
5. 如何迁移到多模态 coding agent？

## 和 Coding Agent 的连接

MLLM 不是孤立方向。更适合你的落点是：前端截图调试、GUI agent、notebook 图表理解、论文图表复现实验。这些任务既需要视觉输入，也需要代码修改和记忆。

## 相关链接

- [[Coding-Agent-研究地图]]
- [[Agent-Memory-研究地图]]
- [[LLM-Training-研究地图]]
