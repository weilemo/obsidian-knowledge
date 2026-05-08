---
created: 2026-02-03
type: tool
status: unread
tags: [codex, app]
aliases: ["Codex App Automations"]
summary: "在本地后台定时运行 Codex 任务并推送结果到 Inbox。"
source-url: "https://developers.openai.com/codex/app/automations"
---

# Codex App Automations
## 一句话摘要
Automations 允许你在后台定期运行 Codex 任务，并把结果投递到 Inbox。

## 核心功能
- 定时/周期性任务
- 自动把结果放入 Inbox
- 可结合 Skills 与工具链
- Git 项目默认在新 worktree 中运行

## 使用步骤
- 在 Automations 面板创建任务
- 选择运行频率与目标项目
- 填写任务提示词与输出要求
- 需要联网时设置允许域名

## 适用场景
- 定期总结、监控或重复检查
- 批量处理或定期生成报告

## Start with a task（模板清单与作用）
以下为截图中可见的全部 Automation 模板（按界面顺序）：

1. `Scan recent commits for likely bugs and propose minimal fixes.`
   作用：扫描最近提交，识别高风险改动，并给出最小修复建议。
2. `Draft release notes from merged PRs.`
   作用：从已合并 PR 自动生成发布说明草稿。
3. `Summarize yesterday's git activity for standup.`
   作用：汇总昨日 Git 活动，生成站会可直接使用的简报。
4. `Summarize CI failures and flaky tests.`
   作用：归纳 CI 失败与不稳定测试，帮助快速定位质量风险。
5. `Create a small classic game with minimal scope.`
   作用：以最小范围实现一个经典小游戏，适合快速原型练习。
6. `Suggest next skills to deepen from recent PRs and reviews.`
   作用：基于最近 PR 与 review，给出下一步能力提升建议。
7. `Synthesize this week's PRs, rollouts, incidents, and reviews.`
   作用：整合本周 PR、发布、事故与评审，形成周报级摘要。
8. `Watch for performance regressions in recent changes.`
   作用：监控近期改动是否带来性能回退并预警。
9. `Detect dependency and SDK drift; propose alignment.`
   作用：检测依赖与 SDK 版本漂移，并提出统一对齐方案。
10. `Find test gaps from recent changes; create draft PRs.`
    作用：识别近期改动的测试缺口，并生成补测草稿 PR。
11. `Run a pre-release checklist before tagging.`
    作用：在打版本标签前自动执行预发布检查清单。
12. `Update AGENTS.md with new workflows and commands.`
    作用：根据新流程/命令更新 `AGENTS.md` 文档。
13. `Summarize last week's PRs by teammate and theme.`
    作用：按成员与主题汇总上周 PR，便于复盘协作产出。
14. `Triage new issues and suggest owners and priority.`
    作用：初筛新 issue，并建议负责人和优先级。
15. `Check CI failures; group likely root causes.`
    作用：对 CI 失败进行根因聚类，减少重复排查成本。
16. `Scan outdated dependencies and propose safe upgrades.`
    作用：扫描过期依赖并提出低风险升级路径。
17. `Audit performance regressions; propose fixes.`
    作用：审计性能回退并输出可执行修复建议。
18. `Update the changelog with this week's highlights.`
    作用：将本周重点变更自动整理到 changelog。

## 模板分组速记
- 研发质量：1, 4, 8, 10, 15, 17
- 发布与文档：2, 11, 12, 18
- 协作与管理：3, 7, 13, 14
- 依赖治理：9, 16
- 学习与练习：5, 6

## 注意事项
- App 必须保持运行
- 使用 full disk access 风险更高
- 允许的命令范围要谨慎配置
- 定期清理 worktree

## 相关链接（双向）
- Codex App Features
- Codex App Worktrees
- Codex App Troubleshooting
