---
created: 2026-05-24
published: 2023-10-10
type: paper
status: 已读
tags: [coding-agent, benchmark, repo-level, github-issue, execution-evaluation]
aliases: [SWE-bench, Can Language Models Resolve Real-World GitHub Issues]
summary: "提出真实 GitHub issue 级软件工程 benchmark：给模型一个 issue 和代码仓库快照，要求生成可应用的 patch，并用真实测试判断是否解决问题。它把代码生成评测从短函数补全推进到 repo-level 定位、修改、测试和长上下文推理。"
pdf-url: Attachments/arxiv_2310.06770.pdf
source-url: https://arxiv.org/abs/2310.06770
---

# SWE-bench: Can Language Models Resolve Real-World GitHub Issues?

## 一句话结论

SWE-bench 的核心贡献不是又做了一个代码题库，而是把 **真实 GitHub issue -> 真实 PR -> 真实测试** 这条软件工程闭环变成了可自动评测的 benchmark。它让模型必须像初级软件工程师一样做三件事：读 issue、在大仓库中定位相关代码、生成能通过测试的 patch。

这篇对你现在的转型主线非常关键，因为它天然连接：

- **Coding Harness**：任务、环境、patch、测试、日志都可被程序化管理。
- **Memory**：repo 结构、历史失败、测试入口、API 用法可以沉淀为长期记忆。
- **SFT/RL**：成功 patch、失败 patch、测试日志、执行结果都能转成训练信号。

## 解决什么问题

传统代码 benchmark 常见形式是：

- 给一个函数签名和 docstring，让模型补全函数；
- 给一个短问题，让模型写一段独立代码；
- 用单元测试验证答案。

这些任务有用，但和真实软件工程差距很大。真实 bug 修复通常需要：

- 在几千个文件里找到相关模块；
- 理解 issue 描述、历史上下文和已有测试；
- 修改多个函数、类、文件；
- 保持旧功能不坏；
- 生成能被 `patch` 程序应用的 diff；
- 在真实项目依赖和测试环境里通过测试。

SWE-bench 把这个问题形式化成 repo-level code editing benchmark。它问的是：

> 给定一个真实开源仓库在某个历史 commit 的状态，以及当时用户提交的 issue，语言模型能否生成一个 patch，使仓库通过与该 issue 相关的测试？

## 任务形式化

一条 SWE-bench task instance 可以抽象为：

$$
x = (C, P, T)
$$

其中：

- $C$：代码仓库在原始 PR 之前的 base commit，即待修复代码库。
- $P$：problem statement，由 GitHub issue 的标题、正文和 PR 初始提交之前的评论聚合而成。
- $T$：由原始 PR 中新增或修改的测试文件构造出的测试 patch。

模型需要生成预测 patch：

$$
\hat{\delta} = f_\theta(C, P)
$$

真实 PR 中非测试代码修改被记为 gold patch：

$$
\delta
$$

评测不是比较 $\hat{\delta}$ 和 $\delta$ 的文本相似度，而是把 $\hat{\delta}$ 应用到 $C$ 上，再运行测试。只要行为正确，模型可以给出不同于原始 PR 的修法。

## 数据集如何构造

作者从真实 GitHub PR 自动构造 benchmark。流程有三层过滤。

### Stage I：选择仓库并抓取 PR

作者从热门 PyPI 包中选择 12 个维护质量较高、测试较完善、主要由 Python 构成的开源仓库，包括：

- `django`
- `sympy`
- `scikit-learn`
- `matplotlib`
- `sphinx`
- `pytest`
- `xarray`
- `astropy`
- `pylint`
- `requests`
- `seaborn`
- `flask`

这些仓库总共抓取了 93,139 个 PR。

### Stage II：属性过滤

候选 PR 需要满足：

1. PR 已经 merge。
2. PR 关联并解决了某个 GitHub issue。
3. PR 修改了测试文件，说明开发者可能为这个 issue 添加了测试。

这一阶段的目的，是找到“问题描述”和“验证方式”都比较明确的真实修复样本。

### Stage III：执行过滤

作者进一步在真实环境中验证候选任务：

1. checkout 到 PR 的 base commit，得到修复前代码库 $C$。
2. 应用测试 patch $T$。
3. 运行测试，记录修复前日志。
4. 应用 gold patch $\delta$。
5. 再运行测试，记录修复后日志。
6. 保留至少有一个测试从 fail 变成 pass 的任务。
7. 过滤掉安装失败、运行失败、测试不可复现、或测试依赖新引入任意命名对象的样本。

最终从 93,139 个 PR 中得到 2,294 个 evaluation instances：

$$
93139 \rightarrow 11407 \rightarrow 2294
$$

这个过滤过程很重要：SWE-bench 的价值在于它不是“看起来像真实 issue”，而是真的能在执行层面验证 issue 是否被解决。

## 每条样本包含什么

论文 appendix 中给出 task instance 的关键字段。对你做 harness 最有价值的是这些：

- `repo`：任务来自哪个仓库。
- `base_commit`：恢复修复前代码库所需的 commit。
- `problem_statement`：issue 描述。
- `patch`：原始 PR 的 gold patch。
- `test_patch`：用于验证该 issue 的测试 patch。
- `FAIL_TO_PASS`：修复前失败、修复后通过的测试列表。
- `PASS_TO_PASS`：修复前通过、修复后仍应通过的测试列表。
- `instance_id`：由 repo 和 PR 编号构成的任务 ID。

这里最关键的是 `FAIL_TO_PASS` 和 `PASS_TO_PASS`。前者验证模型是否真的修了 bug，后者验证模型有没有破坏原有功能。

## 评价指标

SWE-bench 的主指标是 resolved rate：

$$
\text{ResolvedRate} =
\frac{1}{N}
\sum_{i=1}^{N}
\mathbb{1}[\text{Resolved}(i)]
$$

其中某个任务 $i$ 被认为 resolved，当且仅当预测 patch $\hat{\delta}_i$ 满足：

1. patch 可以被成功应用到代码库；
2. 所有 `FAIL_TO_PASS` 测试通过；
3. 所有 `PASS_TO_PASS` 测试通过。

可以写成：

$$
\text{Resolved}(i)=
\mathbb{1}
\left[
\forall t \in F_i \cup P_i,\ 
\text{status}(t; C_i \oplus T_i \oplus \hat{\delta}_i)=\text{pass}
\right]
$$

其中：

- $F_i$ 是第 $i$ 个任务的 `FAIL_TO_PASS` 测试集合。
- $P_i$ 是第 $i$ 个任务的 `PASS_TO_PASS` 测试集合。
- $C_i$ 是 base commit 对应的代码库。
- $T_i$ 是测试 patch。
- $\oplus$ 表示把 patch 应用到代码库上。

这个评价方式比文本相似度强很多，因为它允许模型给出与 gold patch 不同但行为正确的修复。

## 为什么它难

SWE-bench 的难点不是单点代码能力，而是软件工程闭环能力。

### 1. 仓库极大，相关代码极少

平均每个任务的非测试代码规模约为：

- 3,010 个非测试文件；
- 438K 行非测试代码。

但 gold patch 平均只改：

- 1.7 个文件；
- 3.0 个函数；
- 32.8 行。

所以核心难题是 localization：

> 模型需要在巨大代码库中找到极少数真正该改的位置。

这直接解释了为什么 retrieval、long context 和 memory 都会成为 coding agent 的核心技术。

### 2. 测试要求同时修新问题和保旧功能

平均每个任务包含：

- 9.1 个 `FAIL_TO_PASS` 测试；
- 120.8 个总测试。

这意味着模型不能只“让某个失败测试过”，还要避免破坏旧行为。对 RL 来说，这提示 reward 不能只有单一 pass/fail，最好区分：

$$
R = R_{\text{fix}} + R_{\text{regression}} + R_{\text{patch-format}} - R_{\text{cost}}
$$

其中：

- $R_{\text{fix}}$ 对应 `FAIL_TO_PASS`；
- $R_{\text{regression}}$ 对应 `PASS_TO_PASS`；
- $R_{\text{patch-format}}$ 对应 patch 是否可应用；
- $R_{\text{cost}}$ 对应 token、步骤数、无关修改等成本。

### 3. 长上下文不是直接解药

论文中一个很有启发的发现是：给模型更多 BM25 检索上下文，不一定提高结果。Claude 2 在 BM25 设置下，13k 上下文比 27k、50k 更好。

原因很直接：检索更多文件会提高 oracle 文件覆盖率，但也会引入更多干扰。模型不只是缺上下文，也缺“在上下文里定位真正关键代码”的能力。

这对你的 memory 方向很重要：memory/retrieval 的目标不是把更多东西塞进 prompt，而是更准确地组织和压缩任务相关信息。

## Baseline 设计

论文主要评估两种 context setting。

### BM25 sparse retrieval

因为完整代码库太大，作者用 BM25 从 issue 文本检索相关文件，把能放进上下文窗口的文件拼进 prompt。BM25 的优点是简单稳定；缺点是自然语言 issue 和代码文件之间存在语义鸿沟。

论文报告，在 27k token 限制下：

- BM25 平均覆盖 oracle 文件约 44.41%；
- 约 39.83% 任务中，BM25 能覆盖全部 oracle 文件；
- 但也有大量任务完全没检索到 oracle 文件。

这说明单纯 lexical retrieval 不足以支撑 repo-level 修复。

### Oracle retrieval

oracle retrieval 直接把 gold patch 修改过的文件提供给模型。这不是实际可用系统，而是分析上限：如果定位问题已经解决，模型是否能完成修改？

即便在 oracle retrieval 下，模型表现仍然很低，说明困难不只是检索，还有：

- 理解 issue 与代码行为；
- 生成正确 patch；
- 保持测试不回归；
- 处理项目内部 API 和隐含约束。

## 实验结果

在 BM25 retrieval 设置下，论文报告的 resolved rate 很低：

- Claude 2：约 1.97%
- GPT-4-turbo：约 1.31%
- ChatGPT-3.5：约 0.17%
- SWE-Llama 7B / 13B：约 0.70%
- Claude 3 Opus 在后续版本表中约 3.79%

SWE-bench Lite 上结果稍高，但仍然很低。

这些数字的意义不是“模型完全不会写代码”，而是：

> 现有 LLM 的函数级代码能力，并不能直接转化为真实仓库里的 autonomous software engineering 能力。

## SWE-Llama：用训练集做 SFT

论文还构造了 SWE-bench-train：

- 19,000 个 issue-PR pairs；
- 来自额外 37 个 Python repo；
- 与 evaluation repo 不重合，减少数据污染风险；
- 不强制要求 PR 修改测试文件，所以规模更大。

作者基于 CodeLlama-Python 7B 和 13B 做 SFT，得到 SWE-Llama。训练目标是：

$$
\max_\theta \sum_{(P, C_r, \delta) \in \mathcal{D}_{train}}
\log p_\theta(\delta \mid P, C_r)
$$

其中 $C_r$ 是检索或 oracle 提供的相关代码上下文，$\delta$ 是 gold patch。

训练上使用 LoRA，只微调 attention sublayer，并过滤掉超过 30k token 的样本。

SWE-Llama 的结果提示两件事：

1. repo-level patch generation 可以被 SFT 学到一部分；
2. 如果训练时用 oracle context，测试时换成 BM25 context，会出现明显 distribution shift。

这点对你做 harness 很关键：训练 trajectory 的 context 分布必须和部署/评测时一致，否则模型会学到错误假设，比如“prompt 里的每个文件都该被编辑”。

## 论文的几个关键观察

### 观察 1：问题定位是瓶颈

BM25 扩大上下文时，oracle 文件覆盖率上升，但 resolved rate 不一定上升。这说明模型会被无关上下文干扰。

对你的研究启发：

- 需要 file localization agent；
- 需要 repo memory；
- 需要动态检索，而不是一次性塞文件；
- 需要把测试日志、调用链、文件依赖图纳入 context selection。

### 观察 2：模型生成的 patch 往往太短

论文发现，模型成功应用的 patch 通常比 gold patch 更短、更简单，且很少跨多个文件。这说明模型倾向于局部、保守甚至浅层修复。

对你的研究启发：

- reward 不能只看 patch apply；
- 需要用测试覆盖、回归测试、代码风格、复杂度约束来防止“过短投机修复”；
- 可以研究 patch planning，让模型先决定涉及哪些文件/函数，再动手改。

### 观察 3：patch 格式本身就是难点

模型经常生成不可应用的 patch。论文甚至需要自动修复 patch header 和上下文行。

对 harness 设计的启发：

- 初期可以让 agent 使用编辑工具而不是直接吐 `.patch`；
- action space 可以设计成 `open_file`、`search`、`replace_range`、`run_tests`；
- 这样能减少格式错误，把难点集中到定位和语义修改上。

### 观察 4：部分 issue 需要多模态能力

论文提到某些 repo 的 issue 中含图片链接，例如 matplotlib、seaborn 的可视化 bug。这些任务可能需要模型理解截图或图像。

这正好连接你的 MLLM 主线：未来可以做 **multimodal SWE-bench-style task**，让模型处理 issue screenshot、网页 UI、notebook 图表，再修改代码。

## 这篇论文的局限

### 1. 只覆盖 Python

SWE-bench 的初版集中在 Python 项目。其他语言如 JavaScript、Java、C++、Rust 的构建系统、测试框架、依赖管理差异很大，不能直接认为结论完全迁移。

### 2. 测试通过不等于完美修复

执行评测强于文本相似度，但测试本身可能不完备。模型可能通过 hidden tests 但仍有隐含 bug，也可能写出行为正确但风格差、维护性差的 patch。

### 3. 过滤策略偏向有测试的 PR

只有修改测试文件、能稳定复现 fail-to-pass 的 PR 才容易进入 benchmark。这保证可评测性，但会排除大量真实软件工程任务，例如重构、性能优化、文档修复、设计变更。

### 4. Oracle retrieval 不是现实系统

oracle retrieval 适合分析“如果定位已解决，模型能不能修”，但不能代表真实 agent 能力。真实 agent 必须自己定位文件。

### 5. 评测成本高

每个任务都要 checkout、安装依赖、应用 patch、运行测试。完整评测耗时和成本都不低，所以后续才有 SWE-bench Lite、Verified 等衍生版本。

## 对你的 2/3/6 主线的直接启发

### 3：Coding Harness

你第一阶段应该优先复刻 SWE-bench 的核心对象，而不是急着训练模型：

- task object：`repo + base_commit + issue + tests`
- environment：checkout、install、run tests
- action space：search、read、edit、test
- evaluator：`FAIL_TO_PASS + PASS_TO_PASS`
- trajectory logger：记录每一步观察、动作、测试反馈和最终 patch

### 6：Memory

SWE-bench 暗示了几类非常自然的 coding memory：

- **repo memory**：模块职责、文件路径、测试入口、依赖关系。
- **issue memory**：历史 issue 的症状、定位路径、最终修法。
- **failure memory**：失败测试、错误日志、错误 patch 为什么失败。
- **skill memory**：例如“Django migration 类问题怎么定位”“pytest fixture 错误怎么排查”。

Memory 的评测不应该只问“检索到了什么”，而应该问：

$$
\Delta \text{ResolvedRate}
=
\text{ResolvedRate}_{memory}
-
\text{ResolvedRate}_{no\ memory}
$$

以及：

$$
\Delta \text{Cost}
=
\text{Steps}_{memory}
-
\text{Steps}_{no\ memory}
$$

也就是 memory 是否提高通过率、减少步骤、降低 token 成本、减少重复错误。

### 2：SFT/RL

SWE-bench 给 SFT/RL 提供了很清楚的数据结构：

- 成功轨迹可以做 SFT；
- 失败后修正轨迹可以做反思式 SFT；
- 测试结果可以做 rule-based reward；
- patch apply / lint / unit test / regression test 可以组成多项 reward；
- 失败 patch 可以训练 verifier 或 critic。

一个合理的训练闭环可以是：

$$
\text{Issue}
\rightarrow
\text{Agent Trajectory}
\rightarrow
\text{Patch}
\rightarrow
\text{Test Feedback}
\rightarrow
\text{Reflection / Memory}
\rightarrow
\text{SFT or RL}
$$

## 如果你要基于它做课题

我会把问题收窄成：

> 如何让 coding agent 在 SWE-bench-style 任务中，通过结构化 memory 更好地定位文件、复用调试经验，并在测试反馈下持续改进？

可以先做三个 baseline：

1. **No Memory Agent**：只用当前 issue + search/edit/test。
2. **Retrieval Memory Agent**：把历史 issue/patch/test log 向量检索进上下文。
3. **Structured Memory Agent**：显式维护 repo map、test map、failure ledger、skill library。

核心指标：

- resolved rate；
- patch apply rate；
- average steps；
- average token cost；
- file localization recall；
- regression failure rate。

## 分类判断

沿用当前分类即可：这篇属于 `CodingAgent/10_环境与评测`，因为它定义的是 repo-level coding agent 的任务、数据结构和执行评测方式。后续如果该目录继续加入 SWE-bench Verified、SWE-bench Multimodal、SWE-RL、Agentless 等论文，可以拆成：

- `10_环境与评测/Benchmark`
- `10_环境与评测/Harness与Agent接口`
- `30_训练与RL`

目前两篇论文规模还不需要拆。

## 相关链接

- [[Coding-Agent-研究地图]]
- [[SWE-agent-Agent-Computer-Interfaces-Enable-Automated-Software-Engineering]]
- [[Agent-Memory-研究地图]]
- [[LLM-Training-研究地图]]
- [[MLLM-研究地图]]
