---
created: 2026-01-27
type: tool
status: unread
tags: ["cursor", "cloud-agent", "文档", "工具"]
aliases: ["Cursor-Cloud-Agent-工具说明"]
summary: "Cursor 云端代理全功能操作与 API 指南"
source-url: "https://cursor.com/cn/docs/cloud-agent"
---

# Cursor Cloud Agent（工具使用说明）
## 一句话摘要
覆盖 Cloud Agent 的创建、配置、Web/Mobile、出站 IP 与 API 端点全流程用法。

## 核心功能
- 云端代理：在隔离 Ubuntu 环境中异步运行与接管
- 环境配置：UI 向导或 Dockerfile 设定依赖、快照、运行命令
- Secrets 管理：集中加密环境变量注入
- 验证测试：云端 VM 或本地分支验证
- Web/Mobile：跨设备协作、PWA、Slack 通知
- 出站 IP：提供可拉取的出口 IP 段 JSON
- API：端点用于创建、跟踪、控制、删除 Agent

## 使用步骤
### 1) 创建与运行 Cloud Agent
- 入口：编辑器 Agent 下拉选择 `Cloud` 或访问 `https://cursor.com/agents`。
- 启动：输入任务并启动。
- 运行中：可追加指令或接管。

### 2) 初始设置与环境配置
**UI 向导（推荐）**
1. 命令面板运行 `Cursor: Start Cloud Agent Setup`。
2. 按向导完成：基础环境、依赖安装、快照、安装/启动命令、机密配置。
3. 自动生成 `.cursor/environment.json`。

**Dockerfile（高级）**
1. 编写 Dockerfile 配置系统依赖（编译器/调试器/基础镜像）。
2. 不要 `COPY` 全项目（工作区由 Cursor 管理）。
3. 手动创建快照并编辑 `.cursor/environment.json`。

### 3) 维护命令与启动命令
- `install`：写入可重复执行的安装命令（如 `npm install`、`bazel build`）。
- `start`：可选，用于启动依赖服务（如 `sudo service docker start`）。
- `terminals`：配置持续运行的进程（如 `npm run watch`），在 tmux 会话中运行。

### 4) Secrets（环境变量/机密）
- Desktop：`Cursor Settings` → `Cloud Agents` → `Secrets`。
- Web：`Cursor Dashboard` → `Cloud Agents` → `Secrets`。
- 以键值对添加机密，自动注入所有 Cloud Agents。

### 5) 验证与测试更改
**云端测试**
1. Agent 侧边栏选择 Agent → `Open VM`。
2. SSH 登录，必要时配置端口转发。

**本地测试**
1. `Checkout Branch` 或手动：`git fetch origin`、`git checkout <agent-branch-name>`。
2. 复制 `.env.local` 或引用 Secrets。
3. 运行初始化与测试命令（如 `npm install`、`npm test`）。

### 6) Web 与移动端
**快速开始**
1. 打开 `https://cursor.com/agents`。
2. 登录 Cursor 账号并连接 GitHub。
3. 输入任务启动 Agent。

**移动端安装（PWA）**
- iOS：Safari → 分享 → 添加到主屏幕。
- Android：Chrome → 菜单 → 添加到主屏幕/安装应用。

**协作与通知**
- “Open in Cursor” 接续桌面工作流。
- 共享链接协作，网页端可审阅并合并 PR。
- Slack 中 `@Cursor` 触发 Agent，可选择完成通知。

### 7) 出站 IP 范围
- JSON API：`https://cursor.com/docs/ips.json`
- 字段：`version`、`modified`、`cloudAgents`（CIDR 列表）。
- 防火墙/允许列表放行出站 IP。

### 8) Cloud Agents API（端点）
**认证**
- Basic Authentication；API Key 在 Cursor 控制台获取。

**端点与用法**
- 列出 Agents：`GET /v0/agents`（参数：`limit`、`cursor`、`prUrl`）
- Agent 状态：`GET /v0/agents/{id}`
- Agent 会话：`GET /v0/agents/{id}/conversation`
- 启动 Agent：`POST /v0/agents`
  - `prompt.text` 必填；`prompt.images` 可选（最多 5）
  - `source.repository` 必填（除非提供 `source.prUrl`）
  - `model` 可选；未指定则自动选择
  - `target.autoCreatePr`、`target.autoBranch` 等可选
  - `webhook.url` 可选，配置状态通知
- 添加后续指令：`POST /v0/agents/{id}/followup`
- 停止 Agent：`POST /v0/agents/{id}/stop`
- 删除 Agent：`DELETE /v0/agents/{id}`（不可撤销）
- API Key 信息：`GET /v0/me`
- 列出模型：`GET /v0/models`
- 列出 GitHub 仓库：`GET /v0/repositories`

### 9) CI 失败自动修复（GitHub Actions）
- 全局关闭：Dashboard → Cloud Agents → My Settings → 关闭 “Automatically fix CI Failures”。
- PR 评论控制：`@cursor autofix off/on`。
- 手动请求：`@cursor please fix the CI failures`。

## 适用场景
- 需要异步执行的代码改动与验证
- 需要云端环境复现与隔离的任务
- 跨设备协作与移动端驱动的开发任务
- 需要 API 批量调度 Cloud Agents

## 注意事项
- Cloud Agent 可访问互联网，存在提示注入风险。
- `.env.local` 不会随分支同步，切勿提交到仓库。
- 出站 IP 会变化，需监控 JSON API。
- Cloud Agents API 暂不支持 MCP。

## 相关链接（双向）
- [[Cursor]]
- [[Cloud Agent]]
