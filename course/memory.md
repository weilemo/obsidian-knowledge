# Project Memory

用途：维护课程资料区的长期记忆，供 Codex、Claude Code 或其他 agent 在 `/Users/moweile/Obsidian/Knowledge/Course` 工作时优先阅读。

## 使用规则

- 进入本目录后先读 `agent.md`；本文件只记录跨任务可复用的课程区记忆。
- 写课程笔记时，默认产出可独立阅读的 Obsidian 文件，而不是只给聊天解释。
- 数学、概率、统计、优化、体系结构等内容中的公式必须使用 LaTeX，块级公式优先 `$$...$$`。
- 解题说明要先讲公式来源、成立条件和为什么适用于当前题；不要默认用户已经知道某个定理或技巧。

## 已知工作流

- 课程文件夹任务要做成可导航的工作区：课程概览、章节/讲义、作业/TD、资料附件和索引应尽量对应清楚。
- “写总结笔记”默认分为考试复习版和讲义版；已有复习版时不要覆盖，讲义版单独创建或更新。
- 比较两门课覆盖关系时，先检查本地课程文件和章节证据，再回答“已覆盖什么、还差什么、先补什么”。
- 从 OCW 或公开课程收集资料时，优先下载本地 PDF 并放到课程目录的清晰子文件夹中，避免只有链接。

## 可复用归档记忆

### 课程工作区与公开课资料

- 新建或整理课程文件夹时，默认做成可导航的 Obsidian 工作区，而不是资料堆。优先复用本目录已有编号结构：`00 Overview`、`01 Syllabus`、`02 Units` 或 `02 Calendar`、`03 Lecture Notes`、`04 Problem Sets` 或 `04 Assignments`、`05 Exams` 或 `05 Tools`、`06 Reading Notes`、`08 Code`、`99 Resources`。
- `CS285 Deep Reinforcement Learning` 课程区以 UC Berkeley CS285 为主线，并用 Stanford CS234 的必要基础做桥接；目标服务 LLM RL 推理训练、Coding Agent、Agent Memory、MLLM / world model 和 video-world-model quantization。
- 收集 MIT OCW 等公开课资料时，先找完整 course archive ZIP；若没有可用 ZIP，再逐个 resource page 解析并下载官方 PDF。
- 下载课程资料时，默认排除视频 transcript PDF，除非用户明确要求保留 transcript。
- 下载完成后要做数量或索引验证，例如统计目标目录下 PDF 数量，并维护 `Resources.md`、`Downloaded PDF Index.md` 或对应索引。

### PPT/PDF 转讲义

- 用户说“给这个 ppt 写一个讲义”时，默认产出完整、可复习、可独立阅读的 Obsidian Markdown 讲义，而不是短摘要。
- 用户说“写下一讲”时，默认沿用上一讲格式并按课程顺序继续处理下一份课件，不需要重复确认格式。
- 对数学、优化、概率统计类课件，PDF 文本抽取只当章节线索；若公式或符号乱码，应按标准数学表述重建，全部公式使用 LaTeX。
- 本环境中 `pdfinfo`、`pdftotext` 不应作为首选；优先用 Python 的 `pypdf` 或 `fitz` 抽取 PDF 文本。
- 讲义完成后要做轻量校验：检查标题结构、`$$` 公式块是否成对、是否残留 `TODO`、乱码符号或明显抽取噪声。

### 课程覆盖差集

- 遇到“学完 A 课能否覆盖 B 课”“这门课还有哪些没覆盖”时，先扫描本地课程目录、已有笔记和课件标题，再给判断；不要只凭课程印象回答。
- 这类回答优先采用结构：`已覆盖什么`、`还差什么`、`先补什么`，并把差集落到本地章节、PDF 或笔记证据上。
- 对 `CS61C Berkeley Computer Architecture` 与 `25-26-2/ICE4414P Computer Architecture 计算机体系结构` 的对照，已知 CS61C 能支撑 RISC-V、CPU、pipeline、cache 等基础，但本校课还需重点补：Chapter 1 量化公式，Chapter 3 深层 ILP，Chapter 5 多处理器/cache coherence/synchronization/memory consistency，以及 virtual memory supplement。

### 课程项目边界

- 处理课程大作业时，若使用公开完成 repo，只能标为“参考答案/对照工程”，不能包装成用户原创完成作业。
- 项目类交付要明确边界：找到了什么、验证了什么、哪些只是参考、哪些是自己的实现思路或可继续开发的部分。
- 对 `ICE4414P Computer Architecture` project，后续若补项目能力，优先阅读 `project/README.md`、`Project.pdf` 和已有 `实现思路说明.md`；重点锚点是两级流水线 RISC-V CPU、`ALU/regfile/imm_gen/branch_comp/control_logic/csr`、`test_runner.py`。
