---
created: 2026-02-03
type: tool
status: unread
tags: [codex, app]
aliases: ["Codex App Troubleshooting"]
summary: "常见问题与排查路径。"
source-url: "https://developers.openai.com/codex/app/troubleshooting"
---

# Codex App Troubleshooting
## 一句话摘要
整理 Codex App 常见问题的原因与快速排查路径。

## 核心功能
- Review 面板与 git 状态同步说明
- 项目/线程可见性问题排查
- Worktree 与代码运行差异说明

## 使用步骤
- 文件未更新：先检查 Review 面板是否切到正确范围
- 线程消失：检查左侧过滤条件或到设置里恢复归档
- 项目丢失：侧边栏三点菜单移除后，可用 Add new project / Cmd+O 重新添加
- Worktree 运行异常：检查依赖安装与 setup 脚本
- Cloud 入口不可用：确认当前打开的项目是已初始化的 git 仓库（存在 `.git/`）

## 适用场景
- Review 看不到改动
- 线程或项目列表异常
- Worktree 中命令无法运行

## 注意事项
- Worktree 只包含已提交文件
- 需要把依赖安装写进 Local Environments 的 setup

## 相关链接（双向）
- Codex App Review
- Codex App Worktrees
- Codex App Local Environments
