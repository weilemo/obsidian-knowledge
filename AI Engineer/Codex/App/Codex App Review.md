---
created: 2026-02-03
type: tool
status: unread
tags: [codex, app]
aliases: ["Codex App Review"]
summary: "Review 面板用于查看与采纳 Codex 的改动。"
source-url: "https://developers.openai.com/codex/app/review"
---

# Codex App Review
## 一句话摘要
Review 面板用于审阅 Codex 改动、切换改动范围，并进行批注与采纳。

## 核心功能
- 仅对 Git 仓库启用
- 查看 uncommitted 或整分支的变更
- 过滤 staged / unstaged 变更
- 查看 “last turn” 的改动
- 行内评论与反馈

## 使用步骤
- 在主界面右侧打开 Review 面板
- 选择查看范围（uncommitted / branch / last turn）
- 点击文件进入 diff 视图
- 行内添加评论或通过聊天给出审阅反馈

## 适用场景
- 需要确认变更细节再采纳
- 与 Codex 迭代式修正同一改动

## 注意事项
- Review 内容与 git 状态一致
- 行内评论更适合指出具体问题与位置

## 相关链接（双向）
- Codex App Features
- Codex App Settings
- Codex App Troubleshooting
