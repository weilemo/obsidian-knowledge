---
created: 2026-05-29
published: 2022-03-28
type: paper
status: 未读
tags: [paper, agent-self-improvement, self-training, reasoning, rationale, finetuning]
aliases: [STaR, Self-Taught Reasoner]
summary: "提出用模型自己生成的推理过程来训练模型：生成 rationale，保留能得到正确答案的样本，再微调模型，形成自举式 reasoning 改进。"
pdf-url: https://arxiv.org/pdf/2203.14465
source-url: https://arxiv.org/abs/2203.14465
---

# STaR: Self-Taught Reasoner Bootstrapping Reasoning With Reasoning

## 一句话

STaR 是权重级自我改进的重要早期模板：模型先自己写推理链，再用正确样本反过来训练自己。

## 核心问题

Chain-of-thought prompting 需要高质量推理样例，但人工写 rationale 成本很高。STaR 想解决的是：能不能让模型自己生成推理数据，再用答案正确性筛选出可训练样本。

## 方法机制

基本循环：

1. 用少量 rationale 示例提示模型，为训练问题生成 rationale 和答案。
2. 如果答案正确，保留该 rationale。
3. 如果答案错误，则给模型正确答案，让它尝试生成能导向正确答案的 rationale。
4. 用收集到的 rationale 微调模型。
5. 重复以上过程。

可以抽象为：

$$
\mathcal{D}_{t+1} = \{(x, r, y) \mid M_t(x) \rightarrow (r, y),\ y = y^\ast\}
$$

$$
M_{t+1} = \operatorname{Finetune}(M_t, \mathcal{D}_{t+1})
$$

其中 $r$ 是 reasoning rationale，$y^\ast$ 是真实答案。

## 和自我改进的关系

Self-Refine 改的是当前输出，STaR 改的是模型参数。它说明“自生成数据 + 外部正确性筛选 + 微调”可以形成能力自举，是后续 self-training、RLAIF、self-rewarding、SIA 权重更新路线的基础。

## 局限

- 依赖可验证答案；开放式任务很难判断 rationale 是否真的可靠。
- 错误 rationale 可能被答案正确性掩盖。
- 自举过程可能放大模型已有偏差。

## 相关链接

- [[Agent-Self-Improvement-研究地图]]
- [[LLM-Training-研究地图]]
