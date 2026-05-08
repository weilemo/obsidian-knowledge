---
created: 2026-02-03
tags: [codex, workflows]
source-url: "https://developers.openai.com/codex/workflows"
---

# Workflows
该页面提供一组“可复用工作流”，帮助你在不同场景下高效地与 Codex 协作。

## How to read these examples
每个示例通常包含：
- **When to use**：适用场景
- **Steps / prompts**：建议的操作步骤与提示词样式
- **Context notes**：需要提供的上下文（文件、截图、选区等）
- **Verification**：如何验证输出是否正确

IDE 扩展会自动提供打开文件/选区作为上下文；CLI 需要你明确引用文件或路径。

## Explain a codebase
**When to use**：快速理解模块职责、数据流或接口约定。

**IDE workflow**：打开关键文件并选中核心片段，请 Codex 说明该模块作用、依赖关系、调用链和关键边界条件；需要时让它标出“必须/可选”的输入字段。

**CLI workflow**：启动 Codex 后显式引用相关文件，让它输出结构化说明（模块职责、数据流、关键函数、易错点）。

**Verification**：对照说明与代码走一遍调用路径，或让 Codex给出“最小复现路径”。

## Fix a bug
**When to use**：已知复现步骤或报错信息。

**CLI workflow**：提供复现步骤、环境信息与约束（不改接口/不改依赖等），要求 Codex 先复现再修复，并给出验证命令。

**IDE workflow**：打开怀疑的文件与调用方，让 Codex 解释根因、给出修复并说明如何验证。

**Verification**：重新跑复现步骤 + 相关测试/linters。

## Write a test
**When to use**：新增功能或修复 bug 后补测试。

**IDE workflow**：选中目标函数/文件，要求按项目既有测试风格补单测，覆盖关键路径与边界情况。

**CLI workflow**：明确测试框架与文件位置，要求补测试并说明如何运行。

**Verification**：运行单测，确认失败场景/边界场景被覆盖。

## Prototype from a screenshot
**When to use**：只有设计稿/截图，需要快速做前端原型。

**CLI workflow**：上传截图并说明技术栈、约束与交付物（新路由/组件/README），要求 Codex 实现。

**IDE workflow**：在项目中附上截图并让 Codex 参照现有样式实现。

**Verification**：本地运行页面，逐项比对布局与交互。

## Iterate on UI with live updates
**When to use**：需要多轮 UI 迭代与视觉微调。

**CLI workflow**：先独立启动开发服务器，再让 Codex 给多个设计方案；你选一个后继续细化。

**Verification**：在浏览器里实时验证调整效果；若回滚或手动改动，明确告知 Codex 当前状态。

## Delegate refactor to the cloud
**When to use**：本地先梳理需求，再把大规模重构交给云端执行。

**Local planning**：在本地线程明确目标、范围与里程碑，可先让 Codex 输出计划。

**Cloud delegation**：创建 Cloud 线程（会克隆仓库并带上当前状态），按里程碑推进改动；完成后审阅 diff 并合并/拉回。

**Verification**：在云端或本地运行测试，必要时开 PR 进行审阅。

## Do a local code review
**When to use**：需要第二双眼睛审查本地改动。

**CLI workflow**：使用 `/review` 让 Codex 扫描本地变更，并指定关注点（安全性、性能、边界条件等）。

**Verification**：按建议修复后重跑测试或静态检查。

## Review a GitHub pull request
**When to use**：不想拉取分支，只希望在 GitHub 上完成审阅。

**Workflow**：在 GitHub PR 评论中提及 `@codex review`，并可加上关注重点。需要先在仓库启用 Codex 代码审阅。

**Verification**：根据评论逐项处理并更新 PR。

## Update documentation
**When to use**：更新 README、指南或发布说明。

**IDE/CLI workflow**：指定需要更新的文档文件和目标改动，要求 Codex 按既有风格改写并给出验证方式。

**Verification**：阅读渲染后的文档或运行文档站点构建。

