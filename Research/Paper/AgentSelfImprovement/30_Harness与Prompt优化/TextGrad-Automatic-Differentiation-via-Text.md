---
created: 2026-05-29
published: 2024-06-11
type: paper
status: 未读
tags: [paper, agent-self-improvement, textgrad, textual-gradient, prompt-optimization, optimization]
aliases: [TextGrad, Automatic Differentiation via Text]
summary: "把自然语言反馈视为文本梯度，用 LLM 评价器反向传播改进信号，从而优化 prompt、代码、答案等文本变量。"
pdf-url: https://arxiv.org/pdf/2406.07496
source-url: https://arxiv.org/abs/2406.07496
---

# TextGrad: Automatic Differentiation via Text

## 一句话

TextGrad 把“哪里错了、怎么改”的自然语言反馈包装成近似梯度，让文本对象也能像参数一样被迭代优化。

## 核心问题

传统梯度适合连续可微参数，但 prompt、程序、论文段落、agent 指令都是离散文本。TextGrad 想把 LLM 的 critique 能力变成一种通用优化信号。

## 方法机制

可以把文本变量记作 $z$，目标函数由一个 evaluator 给出。TextGrad 不是计算数值梯度，而是生成 textual gradient：

$$
g_t = \nabla_{\text{text}} L(z_t)
$$

这里 $g_t$ 是自然语言形式的修改建议。随后 optimizer 根据 $g_t$ 生成新文本：

$$
z_{t+1} = \operatorname{Update}(z_t, g_t)
$$

## 和自我改进的关系

TextGrad 是 prompt/harness 自我改进的重要工具化路线。它比 Self-Refine 更一般：被优化对象不一定是答案，也可以是 prompt、系统指令、代码或 agent 的中间模块。

## 局限

- textual gradient 的可靠性依赖 evaluator。
- 更新过程不是严格数学梯度下降，可能不稳定。
- 对开放式目标容易出现“看起来更好但实际指标没变”的情况。

## 相关链接

- [[Agent-Self-Improvement-研究地图]]
- [[DSPy-Compiling-Declarative-Language-Model-Calls-into-Self-Improving-Pipelines]]
