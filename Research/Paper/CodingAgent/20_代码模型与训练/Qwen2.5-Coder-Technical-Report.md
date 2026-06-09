---
created: 2026-05-24
published: 2024-09-18
type: paper
status: 未读
tags: [code-llm, qwen, pretraining, sft, coding-agent]
aliases: [Qwen2.5-Coder, Qwen2.5-Coder Technical Report]
summary: "Qwen2.5-Coder 系列技术报告，覆盖代码预训练、指令微调、模型规模和代码 benchmark，是现代开源 code LLM 的重要参照。"
pdf-url: Attachments/arxiv_2409.12186.pdf
source-url: https://arxiv.org/abs/2409.12186
---

# Qwen2.5-Coder Technical Report

## 定位

这篇适合作为 code LLM 训练 recipe 的入口。它回答的是“代码模型本身怎么训练”，而不是 agent 环境怎么设计。

## 读这篇要抓什么

- 代码预训练数据如何构成，普通文本与代码数据如何混合。
- 指令微调如何覆盖代码生成、解释、调试、修复、数学推理等能力。
- benchmark 如何分层：函数级、竞赛级、repo/agent 级。
- 对 coding agent 来说，底座模型能力和 harness 能力如何互相补位。

## 对你的主线的价值

如果实验室有训练资源，这篇能帮助你判断：哪些能力应通过 continued pretraining 获得，哪些能力更适合通过 SFT trajectory 或 RL feedback 获得。

## 分类判断

放在 `CodingAgent/20_代码模型与训练`，因为核心是代码模型训练与评测。

## 相关链接

- [[Coding-Agent-研究地图]]
- [[StarCoder-2-and-The-Stack-v2-The-Next-Generation]]
- [[Code-Llama-Open-Foundation-Models-for-Code]]
