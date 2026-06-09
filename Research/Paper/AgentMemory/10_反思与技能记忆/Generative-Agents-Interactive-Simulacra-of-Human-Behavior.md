---
created: 2026-05-24
published: 2023-04-07
type: paper
status: 未读
tags: [agent-memory, reflection, planning, generative-agents]
aliases: [Generative Agents, Interactive Simulacra of Human Behavior]
summary: "提出 observation、memory、reflection、planning 组成的生成式 agent 架构，是理解 agent loop 的经典论文。"
pdf-url: Attachments/arxiv_2304.03442.pdf
source-url: https://arxiv.org/abs/2304.03442
---

# Generative Agents: Interactive Simulacra of Human Behavior

## 定位

这篇适合作为 agent loop 的架构图来看：观察进入 memory，memory 被检索并反思，反思再影响 planning 和 action。

## 读这篇要抓什么

- Memory stream 如何记录 observation。
- Reflection 如何从低层事件抽象出高层结论。
- Planning 如何被当前状态和检索记忆共同驱动。
- 它的评测更偏行为可信度，而不是严格任务成功率。

## 对你的主线的价值

如果你要做 coding agent memory，可以借鉴它的分层：原始日志、压缩摘要、高层反思、计划。不同层进入上下文的时机应该不同。

## 分类判断

放在 `AgentMemory/10_反思与技能记忆`，因为它连接 memory、reflection 和 planning。

## 相关链接

- [[Agent-Memory-研究地图]]
- [[MemGPT-Towards-LLMs-as-Operating-Systems]]
