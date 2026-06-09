---
created: 2026-05-24
published: 2023-04-17
type: paper
status: 未读
tags: [mllm, llava, visual-instruction-tuning, sft]
aliases: [LLaVA, Visual Instruction Tuning]
summary: "LLaVA 原始论文，提出用 GPT-4 生成视觉指令数据，并连接 vision encoder 与 LLM 进行多模态指令微调。"
pdf-url: Attachments/arxiv_2304.08485.pdf
source-url: https://arxiv.org/abs/2304.08485
---

# Visual Instruction Tuning

## 定位

LLaVA 是 MLLM 训练范式的经典起点：预训练视觉-语言对齐，再用指令数据做 SFT。

## 读这篇要抓什么

- vision encoder、projector、LLM backbone 如何连接。
- 视觉指令数据如何生成。
- pretraining 与 instruction tuning 各自负责什么。
- 它为什么能以较低成本获得强多模态对话能力。

## 对你的主线的价值

如果后续做多模态 coding agent，这篇是最基础的模型结构和 SFT 入口。截图、UI、图表都需要先被压成 LLM 可消费的视觉 token。

## 分类判断

放在 `MLLM/10_视觉指令微调`，因为核心是视觉指令微调范式。

## 相关链接

- [[MLLM-研究地图]]
- [[Improved-Baselines-with-Visual-Instruction-Tuning]]
