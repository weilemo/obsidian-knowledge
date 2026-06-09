---
created: 2026-05-24
published: 2023-05-25
type: paper
status: 未读
tags: [agent-memory, skill-library, lifelong-learning, llm-agent]
aliases: [Voyager, Open-Ended Embodied Agent]
summary: "Minecraft 环境中的开放式 LLM agent，核心启发是把经验沉淀为可复用 skill library。"
pdf-url: Attachments/arxiv_2305.16291.pdf
source-url: https://arxiv.org/abs/2305.16291
---

# Voyager: An Open-Ended Embodied Agent with Large Language Models

## 定位

虽然环境是 Minecraft，但对你最有价值的是 **skill library**：agent 不只是记文本，而是把成功策略存成可执行技能。

## 读这篇要抓什么

- curriculum 如何产生新任务。
- skill library 存储什么，如何检索和复用。
- self-verification 如何判断技能是否成功。
- 这些设计如何迁移到 coding：例如“定位 Django URL 路由”“修 pytest fixture”“处理 import cycle”。

## 对你的主线的价值

Coding agent 的 memory 很适合做成 procedural memory：不仅记“发生过什么”，还记“下次怎么做”。这比纯向量检索更贴近工程任务。

## 分类判断

放在 `AgentMemory/10_反思与技能记忆`，因为它的关键贡献是经验技能化。

## 相关链接

- [[Agent-Memory-研究地图]]
- [[Reflexion-Language-Agents-with-Verbal-Reinforcement-Learning]]
