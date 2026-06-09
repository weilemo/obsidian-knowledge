---
created: 2026-05-24
published: 2023-08-24
type: paper
status: 未读
tags: [code-llm, code-llama, fim, foundation-model]
aliases: [Code Llama, Open Foundation Models for Code]
summary: "Meta 的经典代码基础模型报告，介绍代码专门化、Python 变体、指令模型与 Fill-in-the-Middle 能力。"
pdf-url: Attachments/arxiv_2308.12950.pdf
source-url: https://arxiv.org/abs/2308.12950
---

# Code Llama: Open Foundation Models for Code

## 定位

Code Llama 是 code foundation model 的经典基线。读它是为了理解代码模型从通用 LLM 到代码专门化模型的基本路线。

## 读这篇要抓什么

- continued pretraining 如何把通用 LLM 转成 code LLM。
- Fill-in-the-Middle 任务为什么适合代码编辑。
- Python-specialized model 与 instruction model 的差异。
- 它与现代 coding agent 的关系：单次补全能力是基础，但不足以解决 repo-level 任务。

## 对你的主线的价值

如果后续要做 patch-level SFT，FIM 是必须理解的训练形式。代码编辑常常不是从头生成，而是在上下文中插入、替换、保持接口一致。

## 分类判断

放在 `CodingAgent/20_代码模型与训练`，因为它是代码基础模型训练报告。

## 相关链接

- [[Coding-Agent-研究地图]]
- [[Qwen2.5-Coder-Technical-Report]]
