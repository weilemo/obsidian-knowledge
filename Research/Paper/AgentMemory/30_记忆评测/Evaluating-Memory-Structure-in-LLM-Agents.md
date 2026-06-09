---
created: 2026-05-24
published: 2026-02-11
type: paper
status: 未读
tags: [agent-memory, benchmark, memory-structure, structmemeval]
aliases: [StructMemEval, Evaluating Memory Structure in LLM Agents]
summary: "提出 StructMemEval，强调长期记忆评测不应只测事实召回，还要测 agent 能否把记忆组织成合适结构。"
pdf-url: Attachments/arxiv_2602.11243.pdf
source-url: https://arxiv.org/abs/2602.11243
---

# Evaluating Memory Structure in LLM Agents

## 定位

这篇很适合你的 6 方向，因为它把问题从“能不能记住事实”推进到“能不能组织记忆结构”。

## 读这篇要抓什么

- StructMemEval 测什么类型的结构化记忆任务。
- 普通 RAG 和 memory agent 的差异在哪里。
- 显式结构提示为什么会改变 agent 表现。
- 结构化 memory 对 coding agent 有何意义：目录树、依赖图、todo list、debug ledger 都是结构。

## 对你的主线的价值

Coding memory 不能只是向量库。repo 结构、任务状态、测试失败历史天然是结构化对象。你可以把这篇作为“结构化 coding memory”的评测灵感。

## 分类判断

放在 `AgentMemory/30_记忆评测`，因为核心是评测 memory organization。

## 相关链接

- [[Agent-Memory-研究地图]]
- [[LongMemEval-Benchmarking-Chat-Assistants-on-Long-Term-Interactive-Memory]]
