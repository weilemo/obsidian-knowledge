---
created: 2026-05-24
published: 2023-10-12
type: paper
status: 未读
tags: [agent-memory, memgpt, virtual-context, memory-management]
aliases: [MemGPT, LLMs as Operating Systems]
summary: "把 LLM 上下文窗口类比为受限主存，提出 virtual context management，用系统视角管理长期记忆。"
pdf-url: Attachments/arxiv_2310.08560.pdf
source-url: https://arxiv.org/abs/2310.08560
---

# MemGPT: Towards LLMs as Operating Systems

## 定位

MemGPT 的核心不是某个检索技巧，而是把 LLM 看成需要内存管理的系统：上下文窗口有限，外部记忆巨大，必须决定何时换入/换出。

## 读这篇要抓什么

- memory tiers 如何划分。
- virtual context 如何缓解固定上下文窗口限制。
- 读写 memory 的控制逻辑是什么。
- 对 coding agent 来说，哪些信息应该常驻上下文，哪些应该外存检索。

## 对你的主线的价值

长 repo、长任务和多轮 debug 都会遇到 context pressure。MemGPT 可以作为 memory manager baseline，再和结构化 repo memory / task memory 比较。

## 分类判断

放在 `AgentMemory/20_长期记忆架构`，因为它解决 memory hierarchy 和上下文管理问题。

## 相关链接

- [[Agent-Memory-研究地图]]
- [[LongMemEval-Benchmarking-Chat-Assistants-on-Long-Term-Interactive-Memory]]
