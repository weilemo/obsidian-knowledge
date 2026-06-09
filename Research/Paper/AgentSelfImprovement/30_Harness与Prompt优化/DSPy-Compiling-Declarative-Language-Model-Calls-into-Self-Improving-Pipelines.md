---
created: 2026-05-29
published: 2023-10-05
type: paper
status: 未读
tags: [paper, agent-self-improvement, dspy, prompt-optimization, pipeline, harness]
aliases: [DSPy, DSPy Self-Improving Pipelines]
summary: "把 LLM 应用写成声明式模块，并通过 compiler 自动优化 prompt、示例和模块参数，使 LLM pipeline 从手调 prompt 走向可优化程序。"
pdf-url: https://arxiv.org/pdf/2310.03714
source-url: https://arxiv.org/abs/2310.03714
---

# DSPy: Compiling Declarative Language Model Calls into Self-Improving Pipelines

## 一句话

DSPy 把 prompt engineering 变成 pipeline optimization：开发者声明输入输出签名和模块结构，系统根据数据与指标自动搜索更好的 prompt/示例配置。

## 核心问题

复杂 LLM 应用常由多个 prompt、检索器、重写器、评估器组成。手工调 prompt 不可复现、难迁移，也很难系统比较。DSPy 的问题意识是：LLM pipeline 应该像程序一样可编译、可优化。

## 方法机制

DSPy 把 LLM 调用抽象成模块，并给每个模块定义 signature。优化器根据训练集和 metric 调整 prompt、few-shot 示例、chain-of-thought 格式等。

抽象目标是：

$$
\theta^\ast = \arg\max_\theta \operatorname{Metric}(P_\theta, \mathcal{D})
$$

其中 $P_\theta$ 是由 prompt、示例和模块配置参数化的 pipeline，$\mathcal{D}$ 是开发集或训练集。

## 和自我改进的关系

DSPy 不直接强调 agent 自我意识，而是提供了 harness 自我改进的工程基础：agent 的外部程序结构、prompt 和调用策略可以被自动搜索优化。SIA 中 scaffold/harness 更新可以放在这条线上理解。

## 局限

- 需要明确 metric；没有评价函数时很难自动优化。
- 优化结果可能对开发集过拟合。
- 它优化的是 LLM 程序外壳，通常不更新底座模型权重。

## 相关链接

- [[Agent-Self-Improvement-研究地图]]
- [[Coding-Agent-研究地图]]
