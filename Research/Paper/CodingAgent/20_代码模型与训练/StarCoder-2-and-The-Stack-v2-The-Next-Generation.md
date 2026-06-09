---
created: 2026-05-24
published: 2024-02-29
type: paper
status: 未读
tags: [code-llm, pretraining-data, starcoder, stack-v2]
aliases: [StarCoder2, The Stack v2]
summary: "BigCode 的开放代码模型与代码数据集技术报告，重点在透明代码语料、训练配置和开放许可。"
pdf-url: Attachments/arxiv_2402.19173.pdf
source-url: https://arxiv.org/abs/2402.19173
---

# StarCoder 2 and The Stack v2: The Next Generation

## 定位

这篇适合作为代码预训练数据治理的参考。它的价值不只是模型结果，而是代码数据如何收集、过滤、去重、许可管理和公开。

## 读这篇要抓什么

- The Stack v2 的来源、过滤和开放策略。
- 代码模型训练中数据质量、许可证、重复样本和 benchmark contamination 的处理。
- 对比 Qwen2.5-Coder：一个偏开放科研路线，一个偏强性能工程路线。

## 对你的主线的价值

如果你后续做 coding SFT/RL，数据来源和污染控制会很重要。特别是 SWE-bench 类任务，训练集和评测集泄漏会直接影响结论可信度。

## 分类判断

放在 `CodingAgent/20_代码模型与训练`，因为它是代码模型和代码语料路线。

## 相关链接

- [[Coding-Agent-研究地图]]
- [[Qwen2.5-Coder-Technical-Report]]
