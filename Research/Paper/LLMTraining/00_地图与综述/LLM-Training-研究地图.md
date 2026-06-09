---
created: 2026-05-24
type: map
status: active
tags: [paper-map, llm-training, reinforcement-learning, 转型]
aliases: [LLM Training 研究地图, LLM SFT RL 研究地图]
summary: "实验室转型阶段的训练入口：重点关注 SFT/RL 如何把环境反馈、测试结果和反思轨迹转成模型能力。"
---

# LLM Training 研究地图

## 为什么单独成类

这组论文服务于 **2. Pretrain - SFT - RL** 中的训练机制部分。第一阶段先收一篇代表性 RL reasoning 论文，后续再扩展 DPO、GRPO、RLVR、coding RL 等子类。

## 分类

### 10_RL推理训练

- [[DeepSeek-R1-Incentivizing-Reasoning-Capability-in-LLMs-via-Reinforcement-Learning]]：理解 rule-based reward、RLVR 和 reasoning emergence 的入口。

## 第一阶段读法

重点回答：

1. reward 从哪里来？
2. 哪些任务适合 rule-based reward？
3. SFT 与 RL 的分工是什么？
4. RL 是否真的优化了泛化推理，还是只优化 benchmark？
5. coding agent 中的测试结果能否作为类似 reward？

## 和 Coding Agent 的连接

Coding 是天然适合 RL 的场景之一，因为测试、lint、类型检查、运行结果都能给出相对明确的反馈。后续路线可以从 rejection sampling / verifier / best-of-N distillation 开始，再推进到 RL。

## 相关链接

- [[Coding-Agent-研究地图]]
- [[Agent-Memory-研究地图]]
- [[MLLM-研究地图]]
