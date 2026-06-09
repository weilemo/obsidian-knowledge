---
created: 2026-05-29
published: 2023-12-14
type: paper
status: 未读
tags: [paper, agent-self-improvement, program-search, evolutionary-search, scientific-discovery, llm]
aliases: [FunSearch, Discovering New Mathematics and Algorithms Using Large Language Models]
summary: "用 LLM 生成程序候选，再用自动 evaluator 打分并选择高分程序继续变异，形成程序级进化搜索闭环。"
pdf-url: https://www.nature.com/articles/s41586-023-06924-6.pdf
source-url: https://www.nature.com/articles/s41586-023-06924-6
---

# FunSearch: Discovering New Mathematics and Algorithms Using Large Language Models

## 一句话

FunSearch 把 LLM 当作程序变异器，把 evaluator 当作选择压力，让算法发现变成“生成候选程序 -> 运行评分 -> 保留高分 -> 继续演化”。

## 核心问题

LLM 可以写代码，但直接生成一次答案很难保证发现新算法。FunSearch 的关键问题是：能否把 LLM 的代码生成能力嵌入可验证的搜索循环，从而发现人类也认可的新解法。

## 方法机制

循环结构：

1. 维护一个高质量程序池。
2. 从程序池采样候选作为上下文。
3. LLM 生成新的程序变体。
4. 自动 evaluator 运行程序并打分。
5. 高分程序进入程序池，继续迭代。

抽象形式：

$$
p_{t+1} \sim M(\operatorname{Prompt}(\mathcal{P}_t))
$$

$$
s_{t+1} = E(p_{t+1})
$$

$$
\mathcal{P}_{t+1} = \operatorname{Select}(\mathcal{P}_t \cup \{p_{t+1}\}, s)
$$

## 和自我改进的关系

FunSearch 不一定修改 LLM 自身，但它展示了“外部评价器 + 候选程序池 + 选择压力”的演化闭环。GPU kernel agent、AlphaEvolve、SIA 的 kernel 任务都可以从这条线理解。

## 局限

- 依赖可自动执行、可打分的任务。
- evaluator 设计会决定搜索方向，可能导致投机性解法。
- 主要改进程序池，而不是模型权重本身。

## 相关链接

- [[Agent-Self-Improvement-研究地图]]
- [[Coding-Agent-研究地图]]
