---
created: 2026-04-27
tags:
  - AI
  - Agent
  - Codex
  - CLI
  - MCP
  - Skills
source-url:
  - https://developers.openai.com/codex/cli
  - https://developers.openai.com/codex/use-cases
  - https://openai.com/index/introducing-upgrades-to-codex/
  - https://openai.com/index/introducing-the-codex-app/
---

# Codex 能力使用笔记：图片输入、Web Search、MCP、Skills、Subagents、Cloud Tasks

## 一句话先记住

这 6 个能力里：

- `图片输入`、`Web Search`、`MCP` 更像是 **给单个 agent 加工具**
- `Skills` 更像是 **把一套可复用工作流封装起来**
- `Subagents` 更像是 **把任务拆给多个 agent 协作**
- `Cloud Tasks` 更像是 **把任务扔到云端异步跑，再把结果拉回本地**

## 1. 图片输入怎么用

官方已经明确，Codex CLI 支持图片输入。  
本机 `codex --help` 和 `codex exec --help` 里对应参数是：

```bash
-i, --image <FILE>...
```

最常见用法：

```bash
codex -i ./screenshot.png "根据这张图修复前端样式"
```

```bash
codex exec -i ./wireframe.png "按这张线框图生成首页"
```

适合场景：

- 给 UI 截图让它修 bug
- 给设计稿让它还原页面
- 给报错截图让它解释问题
- 给流程图让它生成代码或文档

我自己的使用建议：

- 图片最好和文字要求一起给，不要只丢图
- 直接说明“你要它看什么”
- 如果是 UI，最好告诉它“只改哪个页面 / 哪个组件”

推荐 prompt：

```bash
codex -i ./bug.png "只看这个报错弹窗和按钮区域，分析根因并修复，不要改其他页面"
```

## 2. Web Search 怎么用

本机 `codex --help` 里对应参数是：

```bash
--search
```

官方说明是：启用后，Codex 可以使用原生 `web_search` 工具。

最直接用法：

```bash
codex --search "检查 Next.js 这个报错在官方文档里的推荐修法"
```

```bash
codex exec --search "对比 OpenAI 官方文档里 gpt-5.4 和 gpt-5.3-codex 的定位差异"
```

适合场景：

- 查官方文档
- 查最新 API 参数或 breaking changes
- 查最新库版本行为
- 查线上信息而不是只靠本地代码

我自己的判断标准：

- 只要信息可能变化，就开 `--search`
- 只要你需要“最新”或“官方原文”，就开 `--search`

## 3. MCP 怎么用

MCP 可以理解成：**把外部系统接进 Codex**。  
例如文档、数据库、设计工具、团队内部系统、脚本接口等。

本机 `codex mcp --help` 里有这些命令：

```bash
codex mcp list
codex mcp get
codex mcp add
codex mcp remove
codex mcp login
codex mcp logout
```

最常见流程：

### 查看已经接好的 MCP

```bash
codex mcp list
```

### 添加一个 MCP

具体参数要看对应 MCP 的说明文档，但通常会是类似这种形式：

```bash
codex mcp add <name> ...
```

### 登录某个需要认证的 MCP

```bash
codex mcp login <name>
```

用法思路上，MCP 最适合：

- 接 OpenAI docs / 第三方 docs
- 接 Figma / Linear / Slack / GitHub 这类系统
- 接你自己封装好的内部 CLI 或服务

官方 use cases 里也一直在强调这一点：  
Codex 很适合“Create a CLI Codex can use”，也就是给 Codex 一个可组合的工具入口。

## 4. Skills 怎么用

Skills 的本质不是“多一个命令”，而是：

**把一整套反复要做的事情打包成可复用能力。**

官方在 Codex app 介绍和 use cases 里对 Skills 的定位很清楚：

- 它可以把 instructions、resources、scripts 打包在一起
- 适合重复工作流
- 可以自动触发，也可以显式调用

你可以把 Skill 理解成：

- 一个带说明书的工作模块
- 一个“可被 agent 记住的 SOP”
- 一个把工具、文档、脚本、约束打包好的能力包

适合做成 Skill 的任务：

- 固定格式写周报 / 技术总结
- 固定方式部署项目
- 固定方式读某种文件并产出结果
- 固定方式接某个内部系统

你在 Codex 里使用 Skill 的思路一般是：

- 显式说“用某个 skill 处理这个任务”
- 或者把任务描述得足够像该 Skill 的触发条件

我自己的理解：

- `MCP` 是接工具
- `Skill` 是封流程

如果一个任务总要重复 3 次以上，而且每次步骤都差不多，就值得做成 Skill。

## 5. Subagents 怎么用

Subagents 的本质是：**把一个大任务拆成多个 agent 并行或分工执行。**

官方开发者站把 `Subagents` 单独列为 Codex 的概念和配置项，桌面版介绍里也一直强调多 agent、多线程、并行工作。

什么时候该用 Subagents：

- 一个任务天然能拆成几块
- 不同子任务之间上下文耦合不高
- 你不想让一个 agent 又查资料又改代码又写总结

典型拆法：

- Agent A：读代码并找问题
- Agent B：写实现
- Agent C：补测试 / 做 review

你可以把它理解成：

- 单 agent：一个人从头干到尾
- Subagents：你开始“带团队”

我自己的经验判断：

- 小任务别拆，拆了更乱
- 只有当任务真的能并行，Subagents 才有价值
- 桌面版比 CLI 更适合重度用 Subagents，因为它更像一个调度台

## 6. Cloud Tasks 怎么用

Cloud Tasks 是 Codex 里非常重要但容易忽视的一块。  
它的意义是：**任务不一定非要在你本机当前这个终端里跑完。**

本机 `codex cloud --help` 里有这些命令：

```bash
codex cloud exec
codex cloud status
codex cloud list
codex cloud apply
codex cloud diff
```

我会把它理解成这个流：

### 提交任务到云端

```bash
codex cloud exec
```

或根据具体参数提交一个非交互云任务。

### 看云任务状态

```bash
codex cloud status
codex cloud list
```

### 把改动拉回本地

```bash
codex cloud diff
codex cloud apply
```

适合场景：

- 长任务
- 你不想盯着本地终端一直跑
- 想把任务异步挂着
- 想让本地继续干别的事

官方在桌面版和升级说明里都强调，Codex 现在已经是“本地 + 云端联动”的产品，而不是纯本地 CLI。

## 这 6 个能力应该怎么组合

我自己的实用组合是：

### 组合 1：图片输入 + Web Search

适合前端问题：

- 给它 UI 截图
- 同时开 `--search`
- 让它对照官方文档或最新规范修

### 组合 2：MCP + Skills

适合团队工作流：

- 用 `MCP` 接系统
- 用 `Skill` 固化流程

### 组合 3：Subagents + Cloud Tasks

适合大任务：

- 任务拆开
- 扔到多个 agent / 多个云任务里
- 最后本地 review 和 apply

## 最后怎么记

如果只让我压缩成 6 句话：

- `图片输入`：让 Codex 看图干活
- `Web Search`：让 Codex 查最新资料
- `MCP`：让 Codex 连外部系统
- `Skills`：让 Codex 复用一整套工作流
- `Subagents`：让 Codex 分身协作
- `Cloud Tasks`：让 Codex 在云端异步推进任务

## 参考链接

- CLI 文档: https://developers.openai.com/codex/cli
- Codex Use Cases: https://developers.openai.com/codex/use-cases
- Codex 升级说明: https://openai.com/index/introducing-upgrades-to-codex/
- Codex 桌面版介绍: https://openai.com/index/introducing-the-codex-app/
