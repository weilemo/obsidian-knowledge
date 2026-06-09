---
created: 2026-05-26
type: article-note
status: done
tags: [codex, agent, workflow, automation]
aliases: ["Codex-maxxing", "如何榨干 Codex"]
source-url: "https://x.com/jxnlco/status/2057153744630890620"
summary: "Jason Liu 的 Codex 使用心法：长线程、外部记忆、自动化调度和可验证闭环。"
---

# Codex-maxxing 使用心法

## 一句话
把 Codex 当成长期协作的工作系统，而不是一次性问答工具。

## 核心观点
- **长线程沉淀上下文**：每个工作流保留一个长期线程，例如日程、开源项目、社交监控；上下文、偏好、历史决策会自然积累。
- **口述优先**：直接把原始想法、模糊需求和溯源线索说给 Codex，不必过度打磨 prompt。
- **Heartbeats 让任务自己跑**：用定时触发检查 Slack、Gmail、PR、评论、客服排队等外部状态。
- **@computer 补足连接器能力**：当 MCP / Connector 不能完成文件上传、网页点击等动作时，让 Codex 操作真实 UI。
- **Goal 模式适合长任务**：只要目标和验收标准清晰，Codex 可以持续推进数小时到数天。
- **验证机制决定能否自动闭环**：没有测试、检查清单或明确完成条件，自动化只会变成愿望。
- **记忆放在本地文件系统**：用 Obsidian / AGENTS.md 管理项目、人员、待办和规则，避免核心记忆锁在平台里。
- **把成功流程封装成 Skills / Connectors**：做成可复用工作流，下次不再从零教 Codex。

## 可执行做法
- 为高频工作流建立置顶长期线程。
- 把长期规则写进 `AGENTS.md`，把项目状态写进 Obsidian。
- 给自动化任务补上明确的停止条件，例如“测试全部通过”“PR 评论全部处理”“草稿生成但不发送”。
- 对需要人工确认的动作，只让 Codex 起草、汇总、准备，不直接发送或提交。
- 做完一次有效流程后，沉淀成 Skill、脚本或模板。

## 我的启发
Codex 的关键不是“单次回答更聪明”，而是能不能围绕一个可验证目标持续推进。长期线程提供上下文，Obsidian 提供可控记忆，Heartbeats / Goal 模式提供执行节奏，测试和人工审批提供边界。

## 相关链接
- [[Codex App Automations]]
- [[Codex Workflows]]
- [[Codex App Features]]
