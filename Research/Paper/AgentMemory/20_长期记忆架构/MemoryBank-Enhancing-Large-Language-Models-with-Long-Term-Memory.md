---
created: 2026-05-24
published: 2023-05-17
type: paper
status: 未读
tags: [agent-memory, long-term-memory, user-modeling, forgetting]
aliases: [MemoryBank]
summary: "面向长期对话的 LLM 记忆机制，包含记忆召回、持续更新、用户画像和遗忘曲线。"
pdf-url: Attachments/arxiv_2305.10250.pdf
source-url: https://arxiv.org/abs/2305.10250
---

# MemoryBank: Enhancing Large Language Models with Long-Term Memory

## 定位

MemoryBank 是长期交互记忆的一条早期路线，重点在记忆如何随时间更新、强化和遗忘。

## 读这篇要抓什么

- 记忆如何从对话中抽取和总结。
- 记忆强度如何随时间衰减或被强化。
- 用户画像如何影响后续响应。
- 它的局限：更偏 companion/chat，离 coding agent 的 procedural memory 还有距离。

## 对你的主线的价值

虽然应用场景不是 coding，但“记忆需要更新和遗忘”很重要。coding agent 也会遇到旧 repo 状态、过时 API、错误经验污染等问题。

## 分类判断

放在 `AgentMemory/20_长期记忆架构`，因为核心是长期记忆管理机制。

## 相关链接

- [[Agent-Memory-研究地图]]
- [[MemGPT-Towards-LLMs-as-Operating-Systems]]
