---
created: 2026-05-09
tags: [claude-code, anthropic, cli, agent, workflow]
source: "official-docs + personal"
---

# Claude Code 使用教程

## 一句话摘要

**Claude Code 是 Anthropic 的终端 coding agent。** 你在项目目录里运行 `claude`，它会基于当前仓库上下文帮你读代码、改代码、跑命令、继续会话，也支持脚本化调用。

## 这篇笔记解决什么问题

- Claude Code 怎么安装和启动
- 第一次怎么登录
- 平时最常用的命令有哪些
- 交互模式和一次性调用怎么选
- 会话怎么继续
- 怎么把它接进自己的日常开发流
- 它和 Codex CLI 可以怎么类比理解

## 安装与启动

根据 Anthropic 官方文档，标准安装方式是：

```bash
npm install -g @anthropic-ai/claude-code
```

注意：

- 不建议用 `sudo npm install -g`
- 常见要求是 `Node.js 18+`
- 常见 shell 如 `bash`、`zsh`、`fish` 都可以

安装完成后建议先检查：

```bash
claude doctor
```

进入项目目录启动：

```bash
cd your-project
claude
```

也可以直接带一句问题启动：

```bash
claude "explain this project"
```

## 首次登录

第一次启动时，Claude Code 会引导你做认证。

官方文档提到的常见方式包括：

- Anthropic Console
- Claude App 账号
- 企业接入：Amazon Bedrock / Google Vertex AI

默认情况下，Claude Code 使用 Anthropic API。

## 最常用的命令

### 启动交互会话

```bash
claude
```

进入一个交互式 REPL，会保留当前会话上下文。

### 带初始任务启动

```bash
claude "explain this project"
```

适合直接带着目标进入会话。

### 一次性执行并退出

```bash
claude -p "explain this function"
```

这是非交互模式，执行后直接输出结果并退出。很适合脚本化调用。

### 处理管道输入

```bash
cat logs.txt | claude -p "summarize the root cause"
```

这类用法很适合分析日志、diff、命令输出。

### 继续最近一次会话

```bash
claude -c
```

适合昨天做一半、今天继续。

### 继续最近会话并执行一次性任务

```bash
claude -c -p "Check for type errors"
```

### 按 session id 恢复指定会话

```bash
claude -r "<session-id>" "Finish this PR"
```

### 更新 Claude Code

```bash
claude update
```

### 配置 MCP

```bash
claude mcp
```

如果要把外部工具、服务或上下文系统接进 Claude Code，通常会用到它。

## 交互模式和一次性模式怎么选

### 用交互模式 `claude`

适合：

- 需要来回追问
- 任务有上下文积累
- 要逐步探索代码库
- 要连续做一串相关操作

典型例子：

```text
先概览这个仓库
告诉我入口文件在哪里
再帮我定位这个报错
最后给我一个最小修复方案
```

### 用一次性模式 `claude -p`

适合：

- 单个明确问题
- 要嵌进 shell 脚本
- 要处理命令或文件输出
- 不需要保留长会话

典型例子：

```bash
git diff | claude -p "review this patch for bugs"
```

## 一个顺手的日常工作流

我更推荐把 Claude Code 当成“项目内结对助手”来用。

### 读陌生仓库时

```bash
cd your-project
claude
```

然后先问：

```text
先帮我概览这个仓库结构，说明入口文件、核心模块和运行方式。
```

### 开始具体任务时

继续补一句：

```text
帮我修这个报错，只改最小范围，并在最后告诉我改了哪些文件。
```

### 改完之后

自己再检查：

```bash
git status
git diff
pytest
```

也可以反过来让 Claude 帮你读 diff：

```bash
git diff | claude -p "summarize what changed and what risks remain"
```

## 适合 Claude Code 的任务类型

很适合：

- 阅读和总结代码库
- 定位 bug
- 补测试
- 做小范围重构
- 写脚本
- 总结日志和报错
- 基于 diff 做 review

示例：

```bash
claude "Find why the training script crashes on startup"
claude "Add a minimal unit test for this parser"
claude "Refactor this module without changing behavior"
```

## 会话继续怎么理解

`claude -c` 的价值在于：**不是每次都从零开始。**

如果上一次你已经让它读过项目结构、看过日志、理解过问题背景，那么继续会话时就能直接在已有上下文上往下走。

常用方式：

```bash
claude -c
```

如果要按特定会话恢复：

```bash
claude -r "<session-id>"
```

## 配置与自定义

Claude Code 官方配置机制是 `settings.json`。

它支持分层配置，也支持一些环境变量和自定义命令能力。

例如关闭自动更新：

```bash
claude config set autoUpdates false --global
```

或者：

```bash
export DISABLE_AUTOUPDATER=1
```

## Slash Commands 是什么

Claude Code 支持自定义 slash commands。

可以把高频 prompt 封装成命令，比如：

- `/review`
- `/fix-tests`
- `/summarize-diff`

这样在会话里重复执行时会更省事。

官方文档说明：

- 本地 Markdown 文件可以定义自定义命令
- MCP 服务器也可以暴露 slash commands

## 和 Codex CLI 的类比理解

如果你已经熟悉 Codex CLI，可以这样理解：

- `claude`：进入一个项目上下文里的交互式 agent 会话
- `claude -p`：一次性调用，适合脚本化
- `claude -c`：继续上次上下文
- `claude mcp`：接入工具和上下文系统
- `settings.json` / slash commands：做个人工作流定制

它们的共同点是：

- 都适合在项目根目录里工作
- 都很依赖清晰任务描述
- 都适合和 shell、Git、日志分析结合

## 新手最小上手路线

如果第一次用，按这个顺序最稳：

```bash
npm install -g @anthropic-ai/claude-code
claude doctor
cd your-project
claude
```

进会话后先做三件事：

1. 让它概览项目
2. 让它说明运行入口和依赖
3. 再给一个明确的小任务

## 提问方式建议

Claude Code 最适合做“明确、局部、可验证”的任务。

比较好的提问方式：

- 解释这个模块做什么
- 找出这个报错的根因
- 只改这个函数并补测试
- 基于当前 diff 做 code review

不太好的起手方式：

- 随便看看帮我优化整个项目
- 把这个仓库全部重构一下

前者太散，后者太大，都会让结果更不稳。

## 我的默认使用顺序

1. 先进入仓库目录
2. 用 `claude` 打开交互会话
3. 先让它解释项目结构和入口
4. 再给一个单点明确任务
5. 改完以后自己检查 `git diff` 和测试
6. 需要跨天继续时，用 `claude -c`
7. 需要脚本化分析时，用 `claude -p`

更多远端多 provider 配置见：[[forcing_1 Claude Code 多 Provider 配置]]


## 相关命令速查

```bash
claude
claude "query"
claude -p "query"
claude -c
claude -c -p "query"
claude -r "<session-id>" "query"
claude doctor
claude update
claude mcp
```

## 相关资料

- [Set up Claude Code](https://docs.anthropic.com/en/docs/claude-code/getting-started)
- [Claude Code CLI reference](https://docs.anthropic.com/en/docs/claude-code/cli-reference)
- [Claude Code settings](https://docs.anthropic.com/en/docs/claude-code/settings)
- [Slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
- [Claude Code overview](https://docs.anthropic.com/en/docs/claude-code/overview)
