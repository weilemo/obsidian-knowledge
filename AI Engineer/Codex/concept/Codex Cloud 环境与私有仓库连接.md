---
created: 2026-02-03
tags: [codex, cloud, github]
source-url: "https://developers.openai.com/codex/cloud"
---

# Codex Cloud 环境与私有仓库连接

## Codex web setup
- 进入 Codex web 并连接 GitHub；连接后 Codex 才能访问你的仓库并创建 PR。
- 需要 Plus/Pro/Business/Edu/Enterprise 计划；部分企业工作区需要管理员先完成设置。

## Set up your first Codex cloud environment
1. 进入 Codex cloud 并选择开始。
2. 点击 Connect to GitHub 安装/授权 ChatGPT GitHub Connector。
   - 授权 ChatGPT Connector
   - 选择安装目标（通常是你的主组织）
   - 允许要连接到 Codex 的仓库（私有仓库也在此授权）
3. 选择仓库并创建环境；可添加协作者邮箱以赋予编辑权限。
4. 运行几个试任务（如写测试、修 bug、探索代码）。citeturn2view0

## Connect more GitHub repositories with Codex cloud
- Environments 或 Manage Environments → Create Environment → 选择仓库 → 填写名称/描述 → 设置可见性 → Create。

## Cloud environments（配置要点）
### How Codex cloud tasks run
- Codex 创建容器并检出你选择的分支/commit。
- 运行 setup 脚本；如使用缓存可执行维护脚本。
- 应用网络访问设置（setup 阶段有网络；agent 阶段默认无网络，可按需开放）。
- agent 循环执行命令、改代码、跑检查；如仓库含 `AGENTS.md`，会用于查找测试/格式化命令。
- 任务结束给出回答与 diff，可继续追问或开 PR。

### Environment variables and secrets
- 环境变量在整个任务期可用（含 setup 与 agent）。
- Secrets 只在 setup 阶段可用，agent 阶段会移除。

### Automatic setup / Manual setup
- 常见包管理器（npm/yarn/pnpm/pip/pipenv/poetry）可自动安装依赖。
- 复杂项目可提供自定义 setup 脚本；注意 `export` 不会跨到 agent 阶段。

### Container caching
- 容器缓存可加速后续任务（默认最多 12 小时）。


