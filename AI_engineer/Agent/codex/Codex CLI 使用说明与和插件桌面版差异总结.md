---
created: 2026-04-27
tags:
  - AI
  - Agent
  - Codex
  - CLI
source-url:
  - https://developers.openai.com/codex/cli
  - https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan
  - https://openai.com/index/introducing-upgrades-to-codex/
  - https://openai.com/index/introducing-the-codex-app/
---

# Codex CLI 使用说明与和插件桌面版差异总结

## 一句话结论

`Codex CLI` 是一个**本地、终端优先、适合单任务深度推进**的编码代理工具。  
它和 `Codex IDE 插件`、`Codex 桌面版` 不是三套不同能力，而是**同一套 Codex 在不同工作界面上的分工**。

我自己的总结是：

- `CLI`：最像“在终端里直接跟一个能读代码、改代码、跑命令的工程师搭档”
- `IDE 插件`：最像“把这个搭档塞进 VS Code / Cursor，让它吃当前编辑器上下文”
- `桌面版`：最像“多 Agent 指挥中心”，重点不是单次改代码，而是并行、多线程、长任务管理

## Codex CLI 是什么

官方把 Codex CLI 定义为一个可以直接在终端里运行的本地编码代理。它能在你的仓库里：

- 读取代码
- 修改文件
- 运行命令
- 做代码审查
- 使用图片、Web Search、MCP、Subagents 等能力

本机 `codex --help` 里最核心的命令有：

- `codex`：启动交互式终端会话
- `codex exec`：非交互执行，适合脚本化
- `codex review`：非交互代码审查
- `codex login` / `logout`：登录与退出
- `codex resume` / `fork`：找回历史会话或从历史会话分叉
- `codex mcp` / `mcp-server`：接外部工具
- `codex app`：直接启动桌面版

官方 CLI 快速开始也很直接：

```bash
npm i -g @openai/codex
codex
```

首次运行时会提示你登录，可以用 `ChatGPT 账号` 或 `API key`。  
参考：OpenAI Developers `CLI` 页面、Help Center `Using Codex with your ChatGPT plan`。

## Codex CLI 最值得记住的使用方式

### 1. 交互式使用

最标准的用法就是直接在项目目录里运行：

```bash
cd your-project
codex
```

这时候它会进入一个终端 UI，会围绕当前仓库理解上下文、提出修改、运行命令。

适合：

- 改一个功能
- 修一个 bug
- 让它先读代码再解释结构
- 让它本地跑测试、补代码、修 lint

### 2. 非交互执行

如果你想把 Codex 当脚本工具用，用 `exec`：

```bash
codex exec "总结当前项目结构并指出入口文件"
```

这个模式很适合：

- 批量化任务
- 自动化工作流
- 在 shell 脚本里调用
- 做固定格式导出

### 3. 历史会话恢复

这个很实用：

```bash
codex resume
codex resume --last
codex fork --last
```

含义：

- `resume`：回到老对话
- `resume --last`：直接续上最近一次
- `fork --last`：基于最近一次上下文开一个新分支会话

### 4. 权限与自动化强度

CLI 的核心不是“能不能改代码”，而是**你给它多大行动权限**。  
官方文档强调三类审批/权限模式，目的是控制它读写和执行命令的边界。

从本机帮助和官方说明看，最常用的是：

- 保守模式：多读少动，关键动作都确认
- 自动编辑：自动改文件，但命令执行仍较克制
- 更高自治：能在更大范围内直接推进任务

如果刚开始用，建议先用默认/保守模式，再逐步放权。

### 5. CLI 不只是文本

官方现在明确支持这些能力：

- 图片输入
- Web Search
- MCP
- Skills
- Subagents
- Cloud tasks

也就是说，CLI 已经不是“只能打一段 prompt 的终端聊天工具”，而是一个能在本地终端里调度多种工具的 agent harness。

## 我认为 CLI 最适合的场景

### 适合

- 你本来就大量在终端里工作
- 你想在当前仓库直接让 agent 读代码、改代码、跑命令
- 你希望把 agent 能力写进脚本或 shell workflow
- 你希望掌控执行细节、权限和上下文边界

### 不那么适合

- 你主要依赖 IDE 的当前选中代码、打开文件上下文
- 你想同时盯多个长期任务并行推进
- 你更想把多个 agent 当项目管理对象来调度，而不是只跟一个 agent 配合

## 和 Codex IDE 插件最大的不同

这是最容易混淆的一组。

### 共同点

- 底层都是 Codex
- 都能做本地编码协作
- 都能承接云端任务与本地任务的上下文

### 最大不同

`CLI` 的核心优势是：**它把 agent 放进终端工作流里。**  
`IDE 插件` 的核心优势是：**它把 agent 放进编辑器上下文里。**

官方对 IDE 插件的描述很明确：

- 它能利用你当前打开的文件
- 它能利用你当前选中的代码
- 你可以在编辑器里直接预览和处理本地改动
- 你可以在 IDE 里创建、跟踪和接管 cloud tasks

所以如果只说“最大的不同”，我会这么记：

- `CLI`：围绕**仓库 + 终端命令流**
- `IDE 插件`：围绕**编辑器上下文 + 当前代码视图**

换句话说：

- 你在 `CLI` 里更像是在“带一个会写代码的命令行搭档”
- 你在 `IDE 插件` 里更像是在“给编辑器加了一个超级结对程序员”

## 和 Codex 桌面版最大的不同

这一组差异更大。

官方在《Introducing the Codex app》里给桌面版的定位非常明确：  
它是一个 **command center for agents**。

### 桌面版在做什么

- 多个 agent 并行工作
- 每个任务有独立 thread
- 以 project 为单位切换上下文
- 内建 worktrees，减少多 agent 并行改同仓库时的冲突
- 可以在 app 里看 diff、评论、接回本地继续改
- 有技能管理界面
- 更强调长任务、并行任务、跨项目调度

### CLI 在做什么

- 更强调你当前这个终端里的单线程深度协作
- 更强调直接控制命令、目录、权限、脚本化
- 更适合“现在就在这个 repo 里狠狠干活”

所以如果只提**最大的不同**，我会这样写：

- `CLI` 最大特点：**终端内本地协作**
- `桌面版` 最大特点：**多 Agent 并行调度与任务编排**

这不是“桌面版只是 CLI 的 GUI”那么简单。  
更准确地说，桌面版是把 Codex 从“单个 agent 搭档”扩展成了“多个 agent 的控制台”。

## 三者怎么选

### 选 CLI

当你：

- 常驻终端
- 喜欢命令式工作流
- 需要脚本化
- 更关心本地立即执行

### 选 IDE 插件

当你：

- 大部分时间都在 VS Code / Cursor 里
- 想让 agent 直接吃当前选区、当前文件、当前 diff
- 希望改动预览和手工收尾更顺

### 选桌面版

当你：

- 想同时跑多个 agent
- 想管理长期任务
- 想跨项目切换 thread
- 想要 worktree、skills、长任务监督这一整套调度体验

## 我的实际理解

如果把它们类比成工作岗位：

- `CLI` 像一位坐在你终端里的资深工程师
- `IDE 插件` 像一位贴在你编辑器边上的 pair programmer
- `桌面版` 像一个 agent PM / 调度台

所以最关键的不是“哪个更强”，而是：

**你现在是在做本地单任务深挖，还是在做多任务、多 Agent 的编排。**

## 关键原文摘录

### 关于 CLI

> Install the Codex CLI with npm.  
来源：OpenAI Developers `CLI` 页面

> The first time you run Codex, you'll be prompted to sign in.  
来源：OpenAI Developers `CLI` 页面

### 关于 IDE 插件

> The IDE extension brings the Codex agent into VS Code, Cursor, and other VS Code forks  
来源：OpenAI《Introducing upgrades to Codex》

> Codex can use context like the files you’ve opened or the code you’ve selected  
来源：OpenAI《Introducing upgrades to Codex》

### 关于桌面版

> the Codex desktop app, a command center for agents  
来源：OpenAI《Introducing the Codex app》

> designed to effortlessly manage multiple agents at once, run work in parallel, and collaborate with agents over long-running tasks  
来源：OpenAI《Introducing the Codex app》

## 参考链接

- OpenAI Developers CLI: https://developers.openai.com/codex/cli
- ChatGPT 订阅与 Codex: https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan
- Codex 升级说明: https://openai.com/index/introducing-upgrades-to-codex/
- Codex 桌面版介绍: https://openai.com/index/introducing-the-codex-app/
