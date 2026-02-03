---
created: 2026-01-25
type: tool
tags:
  - OpenCode
  - Architect
  - Workflow
  - Agents
aliases:
  - Architect 使用指南
summary: 完整介绍 Architect 的定位、权限与调度流程
source-url: https://opencode.ai/docs/agents/
---

# Architect 使用指南
## 一句话摘要
Architect 是 OpenCode 的“主调度代理”，用最小权限调用 researcher/coder/reviewer/scribe 完成科研工作流。

## 适用场景
- 需要“调研 → 实现 → 审查 → 归档”的科研工作流
- 想把任务拆分给专门化子代理执行，确保权限最小化

## 核心概念
- **Primary agent**：主代理，可直接与用户交互（用 Tab 或快捷键切换）
- **Subagent**：子代理，可被主代理调用，或通过 `@` 直接唤起
- **Permissions**：通过 `permission` 控制 `edit`/`bash`/`webfetch` 等权限
- **Task permissions**：用 `permission.task` 限制主代理可调用的子代理

## Architect 的角色定位
Architect 是主入口（primary），本身几乎不做“实操”，只负责：
1) 拆解任务
2) 挑选合适子代理
3) 汇总结果并给出交付物

**最小权限策略**：Architect 仅保留 `write`（输出总结/计划），
不能 `edit`/`webfetch`/`bash`，只能调用被允许的 subagent。

## 你的 5 个 Agent 配置结构（回顾）
- @researcher：只读调研（允许 webfetch / curl / wget / git clone）
- @coder：仅本地写代码（bash 仅白名单）
- @reviewer：严格审查（只读）
- @scribe：阅读并写入 Obsidian（webfetch + edit）
- @architect：调度与总控

## 使用方式
### 1) 直接在对话中唤起子代理
```
@researcher 帮我查 3 篇相关论文，并附链接
@coder 写一个能解析 arXiv PDF 的脚本
@reviewer 审查这段代码的边界条件
@scribe 总结这篇论文并写入 Obsidian
```

### 2) 使用 Architect 进行完整流程
```
@architect 帮我完成一个科研任务：
1) 先找相关论文
2) 实现一个基线代码
3) 审查代码
4) 写入笔记
```

## Architect 的标准工作流（推荐）
1. **澄清目标**：问清范围、输出格式、截止时间。
2. **拆解步骤**：调研 → 实现 → 审查 → 归档。
3. **分配子代理**：
   - 调研：@researcher
   - 实现：@coder
   - 审查：@reviewer
   - 归档：@scribe
4. **汇总交付**：整理结果与下一步建议。

## 权限与安全机制（来自官方文档）
- 权限支持 `allow / ask / deny` 三种策略。
- 可在 `permission.bash` 中用通配符精确控制命令。
- 可在 Markdown 代理中直接定义权限（`~/.config/opencode/agents/*.md`）。
- 可用 `permission.task` 控制 Architect 能调用的子代理集合。

## 实战示例（超详细）
### 示例：论文复现任务
**用户需求**：复现某篇论文并产出笔记。

**步骤 1：调研**
@architect → 调用 @researcher：
- 搜索论文 PDF / 代码仓库 / 相关工作
- 返回可验证链接

**步骤 2：实现**
@architect → 调用 @coder：
- 写最小可运行代码
- 要求 Type Hints + 单元测试

**步骤 3：审查**
@architect → 调用 @reviewer：
- 找潜在 bug 和边界条件
- 输出可执行修复建议或 Pass

**步骤 4：归档**
@architect → 调用 @scribe：
- 生成 Obsidian 笔记（含 YAML + 双向链接）
- 保存到指定 Vault

## 常见问题
### Q1: 为什么 Architect 不允许 webfetch？
为了保证最小权限，它只负责调度，外部访问交由 researcher/scribe。

### Q2: 如何限制某个子代理执行危险命令？
在对应 agent 的 `permission.bash` 中设置白名单，默认 deny。

### Q3: 我想让 Architect 只调用指定子代理？
在 `permission.task` 中设置允许列表，其他全部 deny。

## 相关链接（双向）
- [[OpenCode Agents]]
- [[最小权限原则]]
- [[科研工作流]]
