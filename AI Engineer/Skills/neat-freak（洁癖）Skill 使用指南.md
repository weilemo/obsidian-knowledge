---
created: 2026-04-29
tags:
  - AI工程
  - Skills
  - Codex
  - neat-freak
source-url:
  - https://github.com/KKKKhazix/khazix-skills
  - https://github.com/KKKKhazix/khazix-skills/tree/main/neat-freak
  - https://github.com/KKKKhazix/khazix-skills/blob/main/neat-freak/SKILL.md
---

# neat-freak（洁癖）Skill 使用指南

## 它是什么

`neat-freak` 是一个给 Agent 做“任务收尾同步”的 Skill。它的核心目标不是追加记录，而是把项目里已经变脏、过期、重复、冲突的知识重新整理干净：重点覆盖项目文档、项目级 Agent 说明文件，以及 Agent 的记忆层。[GitHub 仓库 README](https://github.com/KKKKhazix/khazix-skills) 把它概括为：干完活跑一下 `/neat`，自动把这次改动和项目文档、`CLAUDE.md`、Agent 记忆对齐。

对 Codex 来说，这件事尤其有用，因为 Codex 本地 Skills 目录就是 `~/.codex/skills/`，而 `neat-freak` 的官方说明也明确写了它支持 Codex，并且在 Codex 场景里更关注 `AGENTS.md`、`README.md`、`docs/` 这一层的同步。[来源 1](https://github.com/KKKKhazix/khazix-skills) [来源 2](https://github.com/KKKKhazix/khazix-skills/blob/main/neat-freak/SKILL.md)

## 什么时候用

最适合在下面这些时机跑一次：

- 做完一个功能。
- 修完一个 Bug。
- 准备结束当前会话。
- 准备开新窗口继续开发。
- 准备把项目交给同事、下游项目或另一个 Agent。
- 你已经感觉文档、记忆、代码之间开始不一致。

官方触发词包含 `/neat`、`/sync`、`整理一下`、`同步一下`、`更新记忆`、`收尾`、`sync up` 等。[SKILL.md](https://github.com/KKKKhazix/khazix-skills/blob/main/neat-freak/SKILL.md)

## 我这里怎么开始用

### 本机状态

这台机器里我已经装好了，位置是：

`~/.codex/skills/neat-freak`

对应绝对路径：

`/Users/moweile/.codex/skills/neat-freak`

### 第一次使用前

1. 安装完后重启一次 Codex 桌面版，让它重新加载本地 Skills。
2. 进入你正在开发的项目。
3. 在任务收尾时直接输入触发词。

### 最简单的用法

```text
/neat
```

或者：

```text
整理一下
```

### 更稳的用法

如果你这次改动比较大，建议直接把范围说清楚：

```text
/neat
这次我完成了 XX 功能，并改了 YY 逻辑。
请全面审查这个项目的 README、docs、AGENTS.md / CLAUDE.md 和相关记忆。
按 docs -> 项目级说明 -> 记忆 的顺序同步。
最后给我一份变更摘要，告诉我你改了哪些文件、删了哪些过期信息、还有哪些地方没法自动判断。
```

如果是跨项目联动，可以再补一句：

```text
/neat
这次改动涉及项目 A 和项目 B，B 依赖 A。
请两边都检查，不要只同步当前项目。
```

## 它实际会做什么

根据 `SKILL.md` 的结构，`neat-freak` 的工作大致分成 5 步：

1. 机械式盘点当前项目和相关项目里的 Markdown 文档，不允许漏看关键文件。
2. 根据“变更影响矩阵”判断这次代码改动会影响哪些知识层。
3. 真的去改文件，而不是只给建议。
4. 跑一轮自检，确认没有漏改、错改、相对时间遗留或跨项目遗漏。
5. 输出一份变更摘要，让你知道它到底动了什么。

它强调的顺序是：先改 `docs/`，再改项目根的 `CLAUDE.md` / `AGENTS.md`，最后再整理记忆层。[SKILL.md](https://github.com/KKKKhazix/khazix-skills/blob/main/neat-freak/SKILL.md)

## Codex 里最该关注的点

### 1. 把它当“会话存档器”

最适合的使用姿势不是等项目烂掉再补救，而是每次任务做完就跑一次，把它当成知识层面的保存游戏进度。

### 2. Codex 里优先关注这些文件

- 项目根 `AGENTS.md`
- 项目根 `README.md`
- `docs/` 目录
- 其他散落在项目根或二级目录里的 `.md` 文件

`SKILL.md` 里提到，Codex 的等价“记忆层”更多依赖 `AGENTS.md` 以及项目文档，而不是 Claude Code 那种独立 memory 目录。[SKILL.md](https://github.com/KKKKhazix/khazix-skills/blob/main/neat-freak/SKILL.md)

### 3. 不要只说“改一下文档”

更好的说法是明确要求它：

- 审查全部 Markdown 文件
- 更新过期信息
- 合并重复内容
- 删除已经失效的待办和旧约束
- 输出变更摘要

这样更符合它“编辑而不是记录员”的设计目标。[SKILL.md](https://github.com/KKKKhazix/khazix-skills/blob/main/neat-freak/SKILL.md)

## 推荐的日常工作流

### 场景 1：普通单项目开发

```text
做功能 / 修 Bug
-> 本地验证
-> /neat
-> 看变更摘要
-> 结束当前窗口
```

### 场景 2：文档明显落后于代码

```text
/neat
重点检查文档是否落后于当前代码实现。
如果 README、docs、AGENTS.md 里有过期内容，请直接修正并删除旧信息。
最后只给我一份变更摘要。
```

### 场景 3：跨项目接口联动

```text
/neat
这次不仅改了当前项目，也影响了依赖它的下游项目。
请把两个项目的接入文档、架构文档和项目级说明一起同步。
```

## 使用时的判断标准

如果这次跑完后，满足下面这些状态，基本就说明这个 Skill 发挥作用了：

- 新功能已经出现在 `README.md` 或 `docs/` 的合适位置。
- `AGENTS.md` / `CLAUDE.md` 不再保留旧实现说明。
- 环境变量、路由、数据库、运行方式和当前代码一致。
- 过期的相对时间描述被改成了绝对日期。
- 没有明显重复、互相打架的知识条目。
- 最后你能收到一份简洁的变更摘要。

## 一段可直接复用的收尾提示词

```text
/neat
请把这次会话涉及到的项目知识做一次完整收尾：
1. 枚举并检查项目内所有相关 Markdown 文件；
2. 同步 README、docs、AGENTS.md / CLAUDE.md；
3. 合并重复内容，删除过期信息，修正错误事实；
4. 如果这次改动有跨项目影响，把下游项目文档也一起同步；
5. 最后给我一份变更摘要，只列实际修改过的内容。
```

## 原文结构速记

`neat-freak` 的原始说明基本可以记成下面这套结构：

1. 为什么知识同步重要。
2. 三层知识分别服务谁。
3. 先盘点，再判断影响，再动手改。
4. 改完必须自检。
5. 最后输出变更摘要。

这也是它和“单纯写一条记忆”最大的区别。它要处理的是整个项目的知识面，而不是补一条聊天记录。

## 经典资料 / 参考链接

- 仓库首页：[KKKKhazix/khazix-skills](https://github.com/KKKKhazix/khazix-skills)
- Skill 目录：[neat-freak](https://github.com/KKKKhazix/khazix-skills/tree/main/neat-freak)
- Skill 原文：[neat-freak/SKILL.md](https://github.com/KKKKhazix/khazix-skills/blob/main/neat-freak/SKILL.md)
- 本机安装位置：`/Users/moweile/.codex/skills/neat-freak`

## 关键原文摘录

> “合并优于追加，删除优于保留。”  
> 来源：[neat-freak/SKILL.md](https://github.com/KKKKhazix/khazix-skills/blob/main/neat-freak/SKILL.md)
