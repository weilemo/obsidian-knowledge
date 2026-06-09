---
created: 2026-05-24
type: map
status: active
tags: [paper-map, agent-memory, long-term-memory, 转型]
aliases: [Agent Memory 研究地图, LLM Agent 记忆研究地图]
summary: "实验室转型阶段的 Memory 入口：从反思、技能库、长期记忆架构到记忆评测，服务于 Coding/MLLM Agent 的持续学习。"
---

# Agent Memory 研究地图

## 为什么单独成类

这组论文服务于转型主线中的 **6. 记忆**。对 coding agent 来说，memory 不是聊天偏好，而是跨任务复用经验：仓库结构、测试入口、失败修复、API 用法、环境 gotcha、可复用调试技能。

## 分类

### 10_反思与技能记忆

- [[Reflexion-Language-Agents-with-Verbal-Reinforcement-Learning]]：失败反馈转成语言反思，是 memory-augmented agent 的基础范式。
- [[Voyager-An-Open-Ended-Embodied-Agent-with-Large-Language-Models]]：skill library 很适合迁移到 coding agent 的可复用修复技能。
- [[Generative-Agents-Interactive-Simulacra-of-Human-Behavior]]：observation、memory、reflection、planning 的完整 agent loop。

### 20_长期记忆架构

- [[MemGPT-Towards-LLMs-as-Operating-Systems]]：把上下文窗口当作受限内存，设计 virtual context management。
- [[MemoryBank-Enhancing-Large-Language-Models-with-Long-Term-Memory]]：长期交互记忆、用户建模和遗忘曲线。
- [[Memory-Matters-The-Need-to-Improve-Long-Term-Memory-in-LLM-Agents]]：综述式短文，适合建立 episodic / semantic / procedural memory 分类。

### 30_记忆评测

- [[LongMemEval-Benchmarking-Chat-Assistants-on-Long-Term-Interactive-Memory]]：多会话长期记忆 benchmark。
- [[Evaluating-Memory-Structure-in-LLM-Agents]]：强调 memory structure，而不只是 fact recall。

## 第一阶段读法

读 memory 论文时不要只问“存在哪里”，而要问：

1. 什么信息值得写入？
2. 什么时候写入，什么时候遗忘？
3. 检索结果如何进入推理上下文？
4. memory 错误会如何误导 agent？
5. 评测是 recall、task success，还是结构化组织能力？

## 和 Coding Agent 的连接

你可以把 coding memory 分成三层：

- **repo memory**：模块职责、测试入口、依赖关系。
- **task memory**：历史 issue、失败尝试、最终 patch。
- **skill memory**：可复用调试套路、命令序列、API 使用经验。

## 相关链接

- [[Coding-Agent-研究地图]]
- [[MLLM-研究地图]]
- [[LLM-Training-研究地图]]
