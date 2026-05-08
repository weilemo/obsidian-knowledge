---
created: 2026-02-03
type: tool
status: unread
tags: [codex, app]
aliases: ["Codex App Local Environments"]
summary: "为项目配置 setup 脚本与常用命令，保证一致的本地执行环境。"
source-url: "https://developers.openai.com/codex/app/local-environments"
---

# Codex App Local Environments
## 一句话摘要
Local Environments 用于配置项目级 setup 步骤与常用命令，保证 Codex 在本地或 worktree 中可重复运行。

## 核心功能
- 项目级配置文件（`.codex/`）
- setup 脚本可在新 worktree 自动执行
- 常用命令以按钮形式固定在顶部

## 使用步骤
- 在 Settings 的 Local Environments 中为项目创建配置
- 定义 setup 脚本（如依赖安装）
- 定义常用 Actions（如测试、启动服务）
- 根据需要把 `.codex/` 提交到仓库共享

## 适用场景
- 项目依赖较多，需要一致的启动/测试流程
- 需要在 worktree 中自动完成环境初始化

## 注意事项
- setup 脚本默认会执行，请确保安全可重复
- Actions 会在集成终端运行

## 相关链接（双向）
- Codex App Worktrees
- Codex App Commands
- Codex App Settings
