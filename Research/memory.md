# Project Memory

用途：维护研究区的长期记忆，供 Codex、Claude Code 或其他 agent 在 `/Users/moweile/Obsidian/Knowledge/Research` 工作时优先阅读。

## 使用规则

- 研究解释任务默认“直觉先行”：先给几何/机制直觉，再给公式、变量含义、实现映射和论文细节。
- 研究笔记要尽量落到本地文件、项目文档或论文卡中；不要只停留在聊天回答。
- 所有公式使用 LaTeX，块级公式优先 `$$...$$`。
- 如果任务进入 `Paper/` 或 `project/longvideo-kvcache-quant/`，继续读取对应子目录的 `memory.md` 和规则文件。

## 已知主题

- Flow Matching、DDPM、DDIM、Probability Flow ODE、ELF 等概念解释曾采用“直觉 -> 数学 -> 论文设计选择”的链路。
- 长视频 KV cache、视频生成量化、Self-Forcing、Quant-VideoGen 等任务集中在 `project/longvideo-kvcache-quant/` 和 `Paper/VideoGen`、`Paper/KV_cache` 周边。
