---
created: 2026-05-24
published: 2023-10-05
type: paper
status: 未读
tags: [mllm, llava-1.5, visual-instruction-tuning, baseline]
aliases: [LLaVA-1.5, Improved Baselines with Visual Instruction Tuning]
summary: "LLaVA-1.5 技术报告，展示简单 MLP connector、CLIP-ViT-L-336px 和更好的数据配方即可形成强 MLLM baseline。"
pdf-url: Attachments/arxiv_2310.03744.pdf
source-url: https://arxiv.org/abs/2310.03744
---

# Improved Baselines with Visual Instruction Tuning

## 定位

这篇适合看 MLLM baseline recipe。它说明很多性能提升来自数据、分辨率、connector 和训练细节，而不一定需要复杂架构。

## 读这篇要抓什么

- CLIP-ViT-L-336px、MLP projector 和数据配方的作用。
- 预训练数据与 instruction tuning 数据如何配合。
- 评测覆盖哪些能力：VQA、OCR、知识、推理等。
- 训练成本与复现性。

## 对你的主线的价值

如果实验室要训 MLLM，这篇能帮助你判断最小可行 baseline。先复现强 baseline，再考虑 memory/coding/GUI agent 任务，是比较稳的路径。

## 分类判断

放在 `MLLM/10_视觉指令微调`，因为核心是 LLaVA 系列训练配方。

## 相关链接

- [[MLLM-研究地图]]
- [[Visual-Instruction-Tuning]]
