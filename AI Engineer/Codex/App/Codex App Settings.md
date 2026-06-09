---
created: 2026-02-03
type: tool
status: unread
tags: [codex, app]
aliases: ["Codex App Settings"]
summary: "设置入口、配置文件与个性化项。"
source-url: "https://developers.openai.com/codex/app/settings"
---

# Codex App Settings
## 一句话摘要
Codex App 设置包括外观、通知、Git、集成与个性化，并可通过配置文件持久化。

## 核心功能
- 设置入口与快捷键（Cmd+,）
- `~/.codex/config.toml` 配置文件
- 基础设置：外观、通知、Agent 配置
- 集成：Git、MCP、IDE
- 个性化：Codex instructions（全局）

## 使用步骤
- 在菜单栏选择 Codex App > Settings
- 或使用快捷键 Cmd+,
- 需要全局指令时，在 Codex instructions 中填写
- 需要项目级规则时，在项目根目录写入 `AGENTS.md`

## 适用场景
- 想统一管理 Codex 行为与偏好
- 需要保存跨项目的默认设置

## 注意事项
- 全局指令影响所有项目
- 项目级指令以 `AGENTS.md` 为准

## 相关链接（双向）
- Codex App 概览
- Codex App Features
- Codex App Review
- Codex App Automations
