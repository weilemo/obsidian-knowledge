---
created: 2026-02-03
type: tool
status: unread
tags: [codex, app]
aliases: ["Codex App Worktrees"]
summary: "通过 Git worktree 为 Codex 创建隔离的执行环境。"
source-url: "https://developers.openai.com/codex/app/worktrees"
---

# Codex App Worktrees
## 一句话摘要
Worktree 让 Codex 在独立工作区里执行任务，隔离改动并保持主仓库干净。

## 核心功能
- 仅支持 Git 仓库
- 与主仓库共享 `.git` 元数据
- 适合并行任务与隔离改动
- 可以作为 Codex 运行模式

## 使用步骤
- 选择项目并进入线程
- 选择 Worktree 模式
- 选择/创建起始分支
- Codex 创建新 worktree（detached HEAD）并执行任务

## 适用场景
- 需要隔离改动或并行执行
- 不希望污染主工作区

## 注意事项
- Worktree 只有已提交内容
- 如需依赖安装，建议在 Local Environments 中配置 setup 脚本

## 相关链接（双向）
- Codex App Features
- Codex App Local Environments
- Codex App Automations
