---
created: 2026-05-29
type: map
status: active
tags: [paper-map, agent-self-improvement, recursive-self-improvement, self-training, harness, 转型]
aliases: [Agent Self-Improvement 研究地图, AI智能体自我改进研究地图, 递归自我改进研究地图]
summary: "围绕 AI agent 自我改进与自我进化的论文入口：从自反馈、反思记忆、自训练、prompt/harness 优化，到程序演化与 SIA 式递归闭环。"
---

# Agent Self-Improvement 研究地图

## 为什么单独成类

SIA 这类工作把过去几条分散路线合到一起：agent 不只是调用工具完成外部任务，还会根据任务反馈修改自己的 prompt、harness、记忆、训练数据，甚至任务模型权重。

这条线和已有目录的关系是：

- [[Agent-Memory-研究地图]]：偏“记住失败经验、技能和长期事实”。
- [[LLM-Training-研究地图]]：偏“把反馈转成 SFT/RL/偏好优化”。
- [[Coding-Agent-研究地图]]：偏“在真实软件工程环境里执行和迭代”。
- 本目录：专门追踪“agent 如何形成自我改进闭环”。

## 分类

### 10_自反馈与反思

- [[Self-Refine-Iterative-Refinement-with-Self-Feedback]]：模型自己生成反馈并迭代改答案，是最干净的 inference-time self-improvement 模板。
- [[Reflexion-Language-Agents-with-Verbal-Reinforcement-Learning]]：已有卡；失败反馈写成 verbal memory，是 agent 反思闭环的代表。
- [[Voyager-An-Open-Ended-Embodied-Agent-with-Large-Language-Models]]：已有卡；把成功经验固化成 skill library，更接近持续技能积累。

### 20_自训练与权重更新

- [[STaR-Self-Taught-Reasoner-Bootstrapping-Reasoning-With-Reasoning]]：自生成 reasoning trace，再筛选微调，是权重级自我改进的早期核心论文。

### 30_Harness与Prompt优化

- [[DSPy-Compiling-Declarative-Language-Model-Calls-into-Self-Improving-Pipelines]]：把 LLM pipeline 编译/优化成可调系统，而不是手写 prompt。
- [[TextGrad-Automatic-Differentiation-via-Text]]：用文本反馈近似梯度，优化 prompt、代码和文本变量。

### 40_程序演化与发现

- [[FunSearch-Discovering-New-Mathematics-and-Algorithms-Using-Large-Language-Models]]：LLM 生成程序，外部 evaluator 选择，形成进化式发现闭环。

### 50_递归自我改进框架

- [[SIA-Self-Improving-Agents]]：把 agent scaffold 更新和任务模型权重更新统一到同一套自我改进循环里。

## 一条主线读法

1. 先读 [[Self-Refine-Iterative-Refinement-with-Self-Feedback]]：理解“生成 - 评价 - 修改”的最小闭环。
2. 接着读 [[Reflexion-Language-Agents-with-Verbal-Reinforcement-Learning]] 和 [[Voyager-An-Open-Ended-Embodied-Agent-with-Large-Language-Models]]：看反馈如何沉淀成 memory/skill。
3. 再读 [[STaR-Self-Taught-Reasoner-Bootstrapping-Reasoning-With-Reasoning]]：看自生成数据如何进入权重。
4. 然后读 [[DSPy-Compiling-Declarative-Language-Model-Calls-into-Self-Improving-Pipelines]] 和 [[TextGrad-Automatic-Differentiation-via-Text]]：看 prompt/harness 如何被自动优化。
5. 最后读 [[FunSearch-Discovering-New-Mathematics-and-Algorithms-Using-Large-Language-Models]] 与 [[SIA-Self-Improving-Agents]]：前者是程序演化闭环，后者是更统一的 agent 递归改进框架。

## 关键问题

- 反馈是来自模型自己、外部 verifier、环境 reward，还是人工标注？
- 改进对象是上下文、记忆、prompt、代码、harness，还是模型权重？
- 自我改进是否会积累错误经验，导致 reward hacking 或能力退化？
- 任务反馈能否泛化到新任务，还是只是在 benchmark 内过拟合？
- 是否有可复现的闭环：生成、执行、评价、选择、更新、回归测试？

## 相关链接

- [[Agent-Memory-研究地图]]
- [[LLM-Training-研究地图]]
- [[Coding-Agent-研究地图]]
