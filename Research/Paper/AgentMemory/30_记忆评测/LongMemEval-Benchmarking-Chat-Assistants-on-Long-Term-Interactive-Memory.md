---
created: 2026-05-24
published: 2024-10-14
type: paper
status: 未读
tags: [agent-memory, benchmark, long-term-memory, evaluation]
aliases: [LongMemEval]
summary: "面向长期交互记忆的 benchmark，测试信息抽取、多会话推理、时间推理、知识更新和拒答。"
pdf-url: Attachments/arxiv_2410.10813.pdf
source-url: https://arxiv.org/abs/2410.10813
---

# LongMemEval: Benchmarking Chat Assistants on Long-Term Interactive Memory

## 定位

这篇用于回答“memory 怎么评测”。它不是 coding benchmark，但里面的长期交互能力可以迁移到长期 coding task。

## 读这篇要抓什么

- 长期记忆能力被拆成哪些维度。
- 多会话历史如何构造问题。
- 检索、索引、阅读阶段分别有哪些设计选择。
- 评测中如何处理时间更新和冲突信息。

## 对你的主线的价值

Coding agent memory 也需要类似能力：跨任务 recall、时间更新、冲突处理、该不知道时拒答。后续可以设计 `LongRepoEval` 或 `LongIssueMemoryEval` 风格的任务。

## 分类判断

放在 `AgentMemory/30_记忆评测`，因为核心是 memory benchmark。

## 相关链接

- [[Agent-Memory-研究地图]]
- [[Evaluating-Memory-Structure-in-LLM-Agents]]
