---
created: 2026-05-24
type: map
status: active
tags: [paper-map, coding-agent, harness, 转型]
aliases: [Coding Agent 研究地图, Coding Harness 论文地图]
summary: "实验室转型阶段的 Coding Agent 入口：先掌握真实 repo-level 任务环境，再连接代码模型训练与后续 RL / memory 闭环。"
---

# Coding Agent 研究地图

## 为什么单独成类

这组论文服务于转型主线中的 **3. Coding - 模型训练 + Harness**。它不只是“代码生成”，而是把模型放进真实软件工程环境中：读 issue、浏览仓库、编辑文件、运行测试、根据反馈迭代，最后产生 patch。

## 分类

### 10_环境与评测

- [[SWE-bench-Can-Language-Models-Resolve-Real-World-GitHub-Issues]]：真实 GitHub issue 级 benchmark，是 repo-level coding agent 的任务定义基准。
- [[SWE-agent-Agent-Computer-Interfaces-Enable-Automated-Software-Engineering]]：强调 agent-computer interface，适合学习如何设计文件浏览、编辑、测试接口。

### 20_代码模型与训练

- [[Qwen2.5-Coder-Technical-Report]]：现代开源 code LLM 的训练数据、模型族和 benchmark 配方。
- [[StarCoder-2-and-The-Stack-v2-The-Next-Generation]]：开放代码模型与数据治理路线，适合看 code pretraining corpus。
- [[Code-Llama-Open-Foundation-Models-for-Code]]：经典 code foundation model，适合作为 FIM、专门化和代码能力评测基线。

## 第一阶段读法

优先回答五个问题：

1. 任务环境是什么？
2. 模型能观察到什么？
3. 模型可以执行什么 action？
4. feedback / reward / evaluation 怎么定义？
5. 哪些 trajectory 可以转成 SFT / RL 数据？

## 和 2/6 的连接

Coding Agent 是最适合承接 MLLM/SFT/RL 资源的环境层。后续可以把 issue、测试日志、网页截图、notebook 图表、GUI 状态都变成多模态观察，再用 memory 记录 repo 结构、失败经验和调试技能。

## 相关链接

- [[Agent-Memory-研究地图]]
- [[MLLM-研究地图]]
- [[LLM-Training-研究地图]]
