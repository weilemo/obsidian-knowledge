# Project Memory

用途：维护论文库的长期记忆，供 Codex、Claude Code 或其他 agent 在 `/Users/moweile/Obsidian/Knowledge/Research/Paper` 工作时优先阅读。

## 使用规则

- 进入本目录后必须先读 `agent.md` 和 `AGENTS.md`；本文件只是快速记忆入口。
- 新增、收集、重写论文卡时，默认采用“细讲版”，覆盖问题定义、方法机制、关键公式、实验设置、主结论和局限。
- 先检查本地是否已有论文 PDF；如果没有，优先下载到同级 `Attachments/`，`pdf-url` 使用相对路径。
- `type: paper` 笔记必须补齐 `created`、`published`、`type`、`status`、`tags`、`aliases`、`summary`、`pdf-url`、`source-url`。
- 公式、目标函数、量化表达、复杂度和误差分解统一使用 LaTeX。

## 分类记忆

- 新增论文不要只按任务表象分类，优先按方法本质放入已有主题目录。
- 批量收录前先扫描目录结构和地图笔记，给出论文到目标目录的映射；执行后至少更新一处地图或总览入口。
- Paper vault 里常用入口包括 `Paper-Dashboard.md`、各主题地图、`KV_cache/`、`VideoGen/`、`CodingAgent/`、`AgentMemory/`、`MLLM/`、`LLMTraining/`。
- 用户短问别名如 “aqua-kv 是哪篇论文” 时，先搜本地 aliases/frontmatter，再直接回答匹配论文。
