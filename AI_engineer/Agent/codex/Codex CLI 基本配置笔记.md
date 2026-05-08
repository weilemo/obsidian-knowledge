---
created: 2026-04-27
tags:
  - AI
  - Agent
  - Codex
  - CLI
  - Config
source-url:
  - https://developers.openai.com/codex/cli
  - https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan
  - https://developers.openai.com/
---

# Codex CLI 基本配置笔记

## 一句话目标

把 Codex CLI 配到一个“每天都能直接开干”的状态，最少应该完成这几件事：

- 安装
- 登录
- 设默认模型
- 设默认权限与沙箱
- 设常用 profile
- 配 shell 补全
- 明确 `AGENTS.md` / `config.toml` 的职责边界

## 1. 安装与登录

官方最基本的安装方式是：

```bash
npm i -g @openai/codex
```

启动：

```bash
codex
```

第一次运行一般会提示登录。  
如果你要手动登录相关能力，可以看：

```bash
codex login --help
```

本机当前支持：

```bash
codex login
codex login status
codex login --with-api-key
codex login --device-auth
```

如果你是 ChatGPT 订阅用户，通常直接走 ChatGPT 登录即可。  
如果你走 API key，也可以用：

```bash
printenv OPENAI_API_KEY | codex login --with-api-key
```

## 2. 配置文件在哪里

Codex CLI 的核心配置文件在：

[config.toml](/Users/moweile/.codex/config.toml)

你当前本机的配置大致是：

```toml
approval_policy = "on-request"
sandbox_mode = "workspace-write"
model = "gpt-5.4"
model_reasoning_effort = "medium"
```

这已经属于比较稳妥的日常配置。

我会把几个关键字段这样理解：

- `model`：默认模型
- `model_reasoning_effort`：默认思考强度
- `approval_policy`：命令和修改要不要经过你确认
- `sandbox_mode`：它能在哪个范围内动手

## 3. 最重要的四个配置项

### 模型

命令行临时覆盖：

```bash
codex -m gpt-5.4
```

长期默认：

```toml
model = "gpt-5.4"
```

### 推理强度

如果你经常做复杂任务，可以提高：

```toml
model_reasoning_effort = "high"
```

如果想日常更快：

```toml
model_reasoning_effort = "medium"
```

### 审批策略

常见值在本机帮助里有：

- `untrusted`
- `on-request`
- `never`

一般建议：

- 日常本地开发：`on-request`
- 完全自动脚本化：按任务再临时切

### 沙箱模式

本机帮助里常见值有：

- `read-only`
- `workspace-write`
- `danger-full-access`

我的建议：

- 默认用 `workspace-write`
- 只有非常明确知道后果时才开 `danger-full-access`

## 4. 配一个我会长期用的基础版本

如果只想先有一个稳妥配置，我会推荐类似这样：

```toml
approval_policy = "on-request"
sandbox_mode = "workspace-write"
model = "gpt-5.4"
model_reasoning_effort = "medium"

[sandbox_workspace_write]
network_access = true

[projects."/Users/moweile"]
trust_level = "trusted"
```

这套的含义是：

- 模型够强
- 不至于太慢
- 默认能改当前工作区
- 关键动作还会经过你
- 你自己的主目录工作流被视为可信

## 5. 命令行临时覆盖配置

Codex CLI 一个很好用的点是：  
很多设置不一定非要写死在 `config.toml`，可以在命令行临时覆盖。

例如：

```bash
codex -c model="gpt-5.4"
```

```bash
codex exec -c model_reasoning_effort="high" "先通读项目再给架构建议"
```

```bash
codex -c sandbox_mode="read-only"
```

适合：

- 这次任务临时要更强模型
- 这次任务临时只读
- 这次任务临时要不同 profile

## 6. 用 profile 管理不同工作模式

本机帮助显示支持：

```bash
-p, --profile <CONFIG_PROFILE>
```

这意味着你可以在 `config.toml` 里定义多套配置，然后按场景切换。  
虽然这里我不展开写完整 profile 模板，但思路非常值得用：

- `safe`：只读、保守审批
- `dev`：工作区可写、正常审批
- `fast`：更高自治、更低阻力

这样你不会总去手改全局配置。

## 7. Shell 补全建议打开

本机支持：

```bash
codex completion zsh
```

如果你用 `zsh`，建议生成补全脚本并写进 shell 配置。  
最小做法：

```bash
codex completion zsh
```

如果你后续要长期重度使用，再把输出落到补全文件里并在 `.zshrc` 里加载。

## 8. `AGENTS.md` 和 `config.toml` 分别负责什么

这个非常重要。

### `config.toml`

负责：

- 模型
- 权限
- 沙箱
- profile
- 工具接入级别配置

它解决的是：**Codex 这个工具怎么运行**

### `AGENTS.md`

负责：

- 你的协作规则
- 项目规范
- 目录约束
- 命名约定
- 测试要求

它解决的是：**Codex 在你的项目里应该怎么做事**

我的判断是：

- `config.toml` 是机器配置
- `AGENTS.md` 是工作制度

两者不能互相替代。

## 9. MCP 也是基础配置的一部分

很多人以为 MCP 是“高级玩法”，其实一旦你开始长期用 Codex，它就会很快进入基础配置层。

最常用命令：

```bash
codex mcp list
codex mcp add
codex mcp login
codex mcp remove
```

如果你长期要查文档、接 Figma、接内部系统，MCP 迟早会成为你的常规配置，而不是临时插件。

## 10. 我会怎么给自己做一套最小可用配置

如果重新从零开始，我会按这个顺序：

1. 安装 `codex`
2. 完成 ChatGPT 登录
3. 把 `config.toml` 设成 `workspace-write + on-request`
4. 把常用工作目录设成 trusted
5. 打开 zsh completion
6. 配最常用的 MCP
7. 给常用项目补 `AGENTS.md`

做到这里，Codex CLI 基本就进入“每天可以直接开工”的状态了。

## 11. 适合长期保留的检查命令

```bash
codex --help
codex login status
codex mcp list
codex completion --help
codex cloud --help
cat ~/.codex/config.toml
```

这些命令足够你排掉 80% 的“为什么今天 Codex 不对劲”。

## 最后怎么记

如果只压缩成一句：

**先把 Codex 配成一个稳定工具，再用 `AGENTS.md` 把它变成一个稳定搭档。**

## 参考链接

- CLI 文档: https://developers.openai.com/codex/cli
- ChatGPT 订阅与 Codex: https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan
- OpenAI Developers 首页导航: https://developers.openai.com/
