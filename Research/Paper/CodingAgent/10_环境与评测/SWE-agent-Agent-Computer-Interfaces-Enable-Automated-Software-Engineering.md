---
created: 2026-05-24
published: 2024-05-06
type: paper
status: 未读
tags: [coding-agent, agent-interface, harness, automated-software-engineering]
aliases: [SWE-agent, Agent-Computer Interfaces]
summary: "提出面向软件工程 agent 的交互接口设计，强调好的环境接口能显著提升 LLM 解决真实 GitHub issue 的能力。"
pdf-url: Attachments/arxiv_2405.15793.pdf
source-url: https://arxiv.org/abs/2405.15793
---

# SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering

## 定位

这篇重点不是“又一个 coding agent”，而是 **ACI：Agent-Computer Interface**。对你后续搭 harness 非常关键。

## 读这篇要抓什么

- 命令接口如何限制/放大模型能力。
- 文件浏览、搜索、编辑、测试命令如何设计成 agent 友好的 action space。
- 同一个底座模型在不同 interface 下表现差异很大，说明 harness 不是中性容器，而是训练和评测的一部分。

## 对你的主线的价值

如果后续要做 SFT/RL，trajectory 质量很大程度取决于 interface。一个好的 ACI 可以让模型产生更干净的 observation-action-feedback 序列，也更容易插入 memory：例如“上次这个 repo 的测试入口是什么”“这个模块以前怎么改过”。

## 分类判断

放在 `CodingAgent/10_环境与评测`，因为它解决的是 agent 与计算机环境之间的接口问题。

## 相关链接

- [[Coding-Agent-研究地图]]
- [[SWE-bench-Can-Language-Models-Resolve-Real-World-GitHub-Issues]]
