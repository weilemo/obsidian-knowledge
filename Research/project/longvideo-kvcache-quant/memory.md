# Project Memory

用途：维护 longvideo-kvcache-quant 项目的长期记忆，供 Codex、Claude Code 或其他 agent 进入本目录时优先阅读。

## 使用规则

- 先读 `项目文档.md` 和 `实验思路.md`，再回答方案、更新阶段或解释实验。
- 用户问张量维度时，要逐轴解释，并继续串到 patchify、token 数、KV cache 长度、chunk 切分和显存影响。
- 涉及 Self-Forcing、Quant-VideoGen、KV cache、head-wise/mixed precision 等内容时，优先把解释落回本项目已有术语和阶段规划。
- 更新实验计划时尽量编辑现有项目文档，不要另起孤立文件。
- 公式与张量表达使用 LaTeX。

## 已知上下文

- `实验思路.md` 曾插入过阶段化实验设计；后续新增实验要保持阶段编号和主线连贯。
- Quant-VideoGen 相关代码阅读重点在真实 baseline、cache hook 路径、`triton-nstages-kmeans-int2` 等实现细节。
- 解释视频生成缓存时，不只说抽象 KV cache，要映射到具体帧块、token 序列和缓存生命周期。
