---
created: 2026-05-24
published: 2023-03-20
type: paper
status: 未读
tags: [agent-memory, reflexion, verbal-rl, self-improvement]
aliases: [Reflexion, Verbal Reinforcement Learning]
summary: "提出让语言 agent 把失败反馈转成自然语言反思，并在后续尝试中复用，是 memory + feedback agent 的经典起点。"
pdf-url: Attachments/arxiv_2303.11366.pdf
source-url: https://arxiv.org/abs/2303.11366
---

# Reflexion: Language Agents with Verbal Reinforcement Learning

## 定位

这篇是连接 coding feedback 和 memory 的桥。它没有直接更新模型参数，而是把失败经验写成语言反思，再放回下一次尝试。

## 读这篇要抓什么

- **Feedback** 如何转成 reflection。
- Reflection 如何作为 episodic memory 参与下一轮决策。
- 它和真正参数更新的 RL 有什么区别。
- 在 coding agent 中，测试失败、lint 错误、堆栈信息都可以转成 reflection。

## 对你的主线的价值

它给出一个很低成本的 baseline：不训练模型，只维护反思记忆。后续如果你做 SFT/RL，可以把高质量 reflection trajectory 蒸馏进模型。

## 分类判断

放在 `AgentMemory/10_反思与技能记忆`，因为核心是失败经验如何进入下一次行为。

## 相关链接

- [[Agent-Memory-研究地图]]
- [[SWE-agent-Agent-Computer-Interfaces-Enable-Automated-Software-Engineering]]
