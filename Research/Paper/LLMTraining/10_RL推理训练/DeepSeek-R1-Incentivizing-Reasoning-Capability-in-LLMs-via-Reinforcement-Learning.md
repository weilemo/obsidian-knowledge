---
created: 2026-05-24
published: 2025-01-22
type: paper
status: 未读
tags: [llm-training, reinforcement-learning, rlvr, reasoning, deepseek-r1]
aliases: [DeepSeek-R1, Incentivizing Reasoning Capability in LLMs via Reinforcement Learning]
summary: "DeepSeek-R1 技术报告，展示通过强化学习激发推理能力，重点关注 rule-based reward、RLVR 和 SFT/RL 配合。"
pdf-url: Attachments/arxiv_2501.12948.pdf
source-url: https://arxiv.org/abs/2501.12948
---

# DeepSeek-R1: Incentivizing Reasoning Capability in LLMs via Reinforcement Learning

## 定位

这篇是第一阶段理解 RL reasoning 的入口。你不需要立刻复现 R1，但要理解为什么 rule-based reward 能让模型形成更强推理行为。

## 读这篇要抓什么

- RL 前是否需要 cold-start SFT。
- reward 如何定义，哪些任务适合自动验证。
- reasoning trace 如何出现，以及它是否稳定。
- RL 过程中的可读性、长度、重复、格式等副作用。
- 它和 coding RL 的类比：测试通过可以作为 reward，但 patch 质量还需要额外约束。

## 对你的主线的价值

Coding agent 有天然反馈，类似：

$$
R = R_{test} + R_{lint} + R_{minimal\_patch} - R_{cost}
$$

这里 $R_{test}$ 来自单元测试，$R_{lint}$ 来自静态检查，$R_{minimal\_patch}$ 惩罚无关修改，$R_{cost}$ 惩罚过多 token 或步骤。

## 分类判断

放在 `LLMTraining/10_RL推理训练`，因为核心是用 RL 激发推理和可验证任务能力。

## 相关链接

- [[LLM-Training-研究地图]]
- [[SWE-bench-Can-Language-Models-Resolve-Real-World-GitHub-Issues]]
