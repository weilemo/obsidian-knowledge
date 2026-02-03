---
created: 2026-01-25
type: tool
status: unread
tags: [OpenCode, Agents, Configuration, Tooling]
aliases: ["OpenCode Agents"]
summary: "介绍 OpenCode 的 agents 类型、使用方式与配置选项"
source-url: "https://opencode.ai/docs/agents/"
---

# OpenCode Agents
## 一句话摘要
OpenCode 的 agents 用于把任务拆成可配置的主代理与子代理，并通过配置文件控制模型、权限与工具。

## 核心功能
- 定义主代理与子代理，按任务类型选择不同能力。
- 通过 `@` 提及或快捷键切换/调用代理。
- 支持 JSON 或 Markdown 方式创建自定义代理。

## 使用步骤
- 主代理切换：用 Tab 或配置的 `switch_agent` 快捷键。
- 子代理调用：在输入中用 `@agent` 触发。
- 自定义代理：在 `opencode.json` 或 `~/.config/opencode/agents/` 中配置。

## 适用场景
- 规划型分析（Plan）与全工具开发（Build）分离。
- 对代码库进行快速检索（Explore 子代理）。
- 为特定流程创建自定义代理（如 code-review）。

## 注意事项
- Plan 模式默认将写入与 bash 权限设为 `ask`。
- 子代理继承主代理模型，除非显式指定。
- 权限支持 `allow/ask/deny` 以及命令通配配置。

## 相关链接（双向）
- [[Agent配置]]
- [[OpenCode权限]]
