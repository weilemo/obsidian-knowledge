---
created: 2026-05-29
published: 2023-03-30
type: paper
status: 未读
tags: [paper, agent-self-improvement, self-feedback, iterative-refinement, inference-time]
aliases: [Self-Refine, Iterative Refinement with Self-Feedback]
summary: "提出一个无需额外训练的自反馈迭代框架：同一个 LLM 先生成初稿，再给出反馈，最后根据反馈修订输出。"
pdf-url: https://arxiv.org/pdf/2303.17651
source-url: https://arxiv.org/abs/2303.17651
---

# Self-Refine: Iterative Refinement with Self-Feedback

## 一句话

Self-Refine 是 agent 自我改进的最小形态：不改权重，只在推理时反复执行“生成答案 -> 自己评价 -> 自己修改”。

## 核心问题

普通 LLM 一次性生成答案时，常常没有显式的质量检查步骤。Self-Refine 想验证：如果让模型自己指出问题并改写答案，是否能在不训练新模型的情况下提升任务表现。

## 方法机制

它把一次任务拆成三个模块：

1. `Generator`：生成初始输出。
2. `Feedback`：阅读输出并给出自然语言反馈。
3. `Refiner`：根据反馈修订输出。

循环可以写成：

$$
y_0 = G(x)
$$

$$
f_t = F(x, y_t)
$$

$$
y_{t+1} = R(x, y_t, f_t)
$$

其中 $x$ 是任务输入，$y_t$ 是第 $t$ 轮输出，$f_t$ 是模型自己生成的反馈。

## 和自我改进的关系

这篇论文代表的是 **inference-time self-improvement**：改进发生在上下文里，而不是进入模型权重。它适合作为 SIA 的前置读物，因为 SIA 也有反馈 agent，只是 SIA 进一步把反馈用于 scaffold 与权重更新。

## 局限

- 自反馈质量受模型自身能力限制，弱模型容易“看不出自己的错”。
- 没有真实环境验证时，反馈可能变成语言上的自洽，而不是任务上的正确。
- 改进不跨任务持久保存，下一次调用不会天然继承经验。

## 相关链接

- [[Agent-Self-Improvement-研究地图]]
- [[Reflexion-Language-Agents-with-Verbal-Reinforcement-Learning]]
