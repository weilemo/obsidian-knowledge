---
created: 2026-05-29
published: 2026-05-27
type: paper
status: 未读
tags: [paper, agent-self-improvement, recursive-self-improvement, sia, weight-update, harness-update]
aliases: [SIA, Self-Improving Agents, AI智能体递归自我改进框架]
summary: "提出 Self-Improving Agents 框架，让 feedback agent 根据任务反馈同时改进任务 agent 的 scaffold/harness 与模型权重，并在法律、GPU kernel、单细胞 RNA 去噪任务中验证。"
pdf-url: https://arxiv.org/pdf/2605.27276
source-url: https://arxiv.org/abs/2605.27276
---

# SIA: Self-Improving Agents

## 一句话

SIA 的核心定位是：把过去分散的 prompt/harness 优化、反思记忆、自训练权重更新，统一进一个 agent 递归自我改进循环。

## 核心问题

多数 agent 系统只会优化外部任务流程：规划、调用工具、改代码、跑测试。但如果 agent 能从任务反馈中修改自己的 scaffold，甚至更新任务模型权重，那么它就从“会做任务”转向“会改进自己做任务的方式”。

## 方法机制

SIA 的抽象闭环可以理解为：

1. Task Agent 在任务环境中执行。
2. 环境返回任务结果、错误、评分或实验反馈。
3. Feedback Agent 分析失败原因和改进机会。
4. 系统更新 task agent 的 scaffold/harness。
5. 系统构造训练信号，更新任务模型权重。
6. 新 agent 继续下一轮任务。

可以写成：

$$
\tau_t = A_{\theta_t, h_t}(x, \mathcal{E})
$$

$$
f_t = F(\tau_t, r_t)
$$

$$
h_{t+1} = U_h(h_t, f_t)
$$

$$
\theta_{t+1} = U_\theta(\theta_t, f_t)
$$

其中 $\theta_t$ 是模型权重，$h_t$ 是 agent scaffold 或 harness，$\tau_t$ 是任务轨迹，$r_t$ 是环境反馈。

## 和前序工作的关系

- 对 [[Self-Refine-Iterative-Refinement-with-Self-Feedback]]：SIA 不只改当前答案，而是把反馈沉淀到系统。
- 对 [[STaR-Self-Taught-Reasoner-Bootstrapping-Reasoning-With-Reasoning]]：SIA 继承了“反馈生成训练信号”的权重更新思想。
- 对 [[DSPy-Compiling-Declarative-Language-Model-Calls-into-Self-Improving-Pipelines]] 和 [[TextGrad-Automatic-Differentiation-via-Text]]：SIA 的 scaffold/harness 更新可以看作更 agent 化的 pipeline optimization。
- 对 [[FunSearch-Discovering-New-Mathematics-and-Algorithms-Using-Large-Language-Models]]：SIA 的 GPU kernel 任务与程序演化路线关系很近。

## 值得重点看的实验

- LawBench：验证法律推理/问答任务上自我改进是否有效。
- GPU kernels：验证可执行 benchmark feedback 是否能推动代码性能提升。
- 单细胞 RNA 去噪：验证科学计算/生物任务中的自我改进能力。

## 局限与风险

- 自我改进依赖反馈质量；反馈错误会被写进 scaffold 或权重。
- 权重更新可能造成灾难性遗忘或 benchmark 过拟合。
- 如果环境 reward 不够稳健，agent 可能学会 reward hacking。
- 安全上需要限制 agent 能改什么、何时改、如何回滚。

## 相关链接

- [[Agent-Self-Improvement-研究地图]]
- [[LLM-Training-研究地图]]
- [[Coding-Agent-研究地图]]
