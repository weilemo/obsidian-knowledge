---
created: 2026-05-04
published: 2026-01-07
type: paper
status: 未读
tags:
  - AgentForesight
  - WorldModel
  - ToolUse
  - VLMAgents
  - Foresight
aliases:
  - Current Agents Fail to Leverage World Model as Tool for Foresight
summary: 当前 VLM agent 即使拿到 world model 这个“外部模拟器”，也往往不会在合适的时候调用它、不会正确解释 rollout、也无法把 foresight 稳定整合进后续行动；结果是 simulation 既不稳定增益，甚至常常带来退化。论文把这一瓶颈概括为 foresight governance，而不是 world model 质量本身。
pdf-url: Attachments/arxiv_2601.03905.pdf
source-url:
  - https://arxiv.org/abs/2601.03905
  - https://doi.org/10.48550/arXiv.2601.03905
  - Attachments/arxiv_2601.03905.pdf
---

# Current Agents Fail to Leverage World Model as Tool for Foresight

## PDF
- [[Attachments/arxiv_2601.03905.pdf]]

## 一句话摘要
这篇论文的重点不是“world model 能不能预测未来”，而是“现有 agent 能不能把 world model 当成一个该用就用、用了能懂、懂了能整合的工具”；作者发现当前主流 VLM agent 在这三步上都不稳定，因此 world model access 并不会自动转化成更强的 foresight。

## Abstract
作者研究一个很直接但此前常被默认成立的问题：如果给 vision-language agents 一个可调用的 generative world model 作为外部模拟器，它们是否会因此更擅长前瞻性决策。实验覆盖了 agentic decision-making 与 VQA 两类任务。结果表明，当前 agent 往往几乎不主动调用 simulation，在不少设置下调用率低于 $1\%$；即便调用了，也常误用 rollout，约有 $15\%$ 的案例出现理解或整合错误；整体性能改善并不稳定，甚至会出现最高约 $5\%$ 的退化。论文据此提出核心瓶颈不在于 world model 能否生成未来，而在于 agent 缺少一套可靠的 foresight governance 机制，无法决定何时模拟、如何解释结果、以及如何将其纳入后续 reasoning。

## 1 Introduction
论文的起点是：越来越多 agent 面向的是长时、不可逆、带环境反馈的任务，仅靠短视的局部 reasoning 不够。人类在类似任务中会做 mental simulation，先预想未来状态，再决定行动；但 LLM/VLM agent 即使能写出计划，也不等于能真正“预见”环境后果。

作者进一步指出，foresight 不是单一能力，而是一条完整流程：
- 要先决定什么情况下值得模拟；
- 再决定模拟哪些候选动作或假设；
- 还要把预测出的未来状态转成后续行动依据。

因此，论文把问题从“给 agent 一个 world model”改写为：

$$
\text{Agent 是否能把 world model 作为可选工具，策略性地用于环境前瞻？}
$$

作者的初步观察已经很有代表性：
- 很多 agent 即使有 world model 也不愿调用；
- 模型越大时，这种 reluctance 往往越明显；
- 即使调用，agent 也常常只看单一路径、忽视反事实分支，或用过度自信的内在判断覆盖 simulation 证据。

论文因此把自己的贡献定位在分析框架而非新模型：
- 提出 `world model as tool` 的概念框架；
- 给出一套评估 agent 是否会、以及是否会正确地使用 world model 的 protocol；
- 归纳不同模型家族的调用倾向、失败模式与治理瓶颈。

## 2 Related Work
作者把相关工作分成两类：

- `training-free foresight augmentation`
  通过 prompt 或结构化指令，把 foresight 模块外挂给 agent。

- `intrinsic world-model integration`
  直接把 world model 训练进 agent 架构，或共同训练生成式模拟器与 agent。

论文认为这两类路线各有问题：
- prompt 式方案往往过于僵硬，难以覆盖视觉世界状态的复杂性；
- 内生式方案训练成本高、跨模型家族难迁移、系统集成也更重。

相比之下，本文研究的是第三种视角：把 world model 当作现成外部工具，让 agent 自己决定是否调用。这样可以把问题聚焦到“agent 的交互治理能力”上，而不是把所有改进都归因于模型参数或训练方式。

## 3 Preliminaries
论文定义了一个 agent 与 world model 共存的交互过程。时刻 $t$，agent 已经积累的轨迹记为 $T_t$，真实环境状态为 $S_t$，任务目标为 $G$。agent 需要同时决定：

$$
(c_t, a_t) = A(T_t)
$$

其中：
- $a_t$ 是动作；
- $c_t \in \{E, W\}$ 表示动作是在真实环境 $E$ 中执行，还是先在 world model $W$ 中模拟。

若选择 world model，则只更新“假想轨迹”而不改变真实环境：

$$
S_{\text{pred}} = W(S_t, a_t)
$$

并把预测结果加入轨迹：

$$
T_{t+1} \leftarrow T_t \cup \{(a_t, S_{\text{pred}})\}
$$

若直接作用于真实环境，则：

$$
S_{t+1} \leftarrow E(S_t, a_t)
$$

再把真实观测写入同一个轨迹容器：

$$
T_{t+1} \leftarrow T_t \cup \{(a_t, S_{t+1})\}
$$

这套设计有个很关键的含义：真实经验与模拟经验被混放进统一上下文，因此性能不只取决于 simulator 的存在，还取决于 agent 是否能处理“真实和假想信息混杂”的 reasoning 负担。

论文进一步控制了三种 interaction mode：
- `Normal Mode`：agent 知道 world model 存在，但是否调用由自己决定；
- `WM Invisible Mode`：agent 不知道 world model 的存在，作为常规 baseline；
- `WM Force Mode`：agent 被要求先模拟再行动，用于测试强制 foresight 是否真的有益。

## 4 Method / Evaluation Framing
这篇论文没有提出新的 model architecture，方法部分本质上是一个评估框架。核心思想是把“world model as tool”的使用过程拆成三段可分析链路：

1. `input governance`
   agent 是否知道什么时候该模拟、模拟什么动作或假设。

2. `meaning governance`
   agent 是否能从 rollout 中提取稳定、无歧义的证据，而不是被模糊结果带偏。

3. `action governance`
   agent 是否能把 simulation 结果转成后续真实行动，而不是进入 loop、过度规划或再次忽视模拟证据。

后续所有实验与错误分析，本质上都围绕这三层治理能力展开。

## 5 Experiments

### 5.1 Task Choices
作者选择了两类任务：

- `agentic decision-making tasks`
  包括 `FrozenLake`、`Navigation`、`PrimitiveSkill`、`Sokoban`，覆盖 2D symbolic、3D 场景、多步控制与不同 embodiment。

- `pure VQA reasoning tasks`
  包括 `3DSRBench`、`MMSI Bench`、`SAT`、`Spatial-MM Object`，关注视觉空间推理与潜在动态变化问题。

这个设计很重要，因为它把“需要真实交互的 foresight”与“只需要感知层面想象的 foresight”区分开来。

### 5.2 Models and World Models
论文评测了 9 个 vision-language models，来自 `GPT`、`Llama`、`Qwen` 三个家族，并覆盖不同尺寸。

world model 的构造因任务而异：
- 对 agentic tasks，直接复制环境状态，在克隆环境里执行假设动作，因此 simulator 近似 ground-truth；
- 对 VQA tasks，使用 `Wan2.1` 根据 agent 给出的文本式 simulation instruction 生成未来视觉状态。

作者明确说明：这里重点不是比较不同 world model 的 fidelity，而是研究 agent 是否会用、会不会用。

### 5.3 Main Results

#### Finding 1: World Model 并不会稳定提升性能
在 agent tasks 上，绝大多数模型接入 world model 后平均成功率反而下降。只有 `GPT-5-mini` 与 `GPT-5` 的平均值略有提升，但幅度也很小：
- `GPT-5-mini` 从 $0.41$ 升到 $0.43$
- `GPT-5` 从 $0.47$ 升到 $0.48$

其余大多数模型出现退化，例如：
- `Llama-4-Maverick` 从 $0.35$ 降到 $0.27$
- `Qwen2.5-VL-32B` 从 $0.40$ 降到 $0.34$
- `Qwen2.5-VL-72B` 从 $0.37$ 降到 $0.33$

VQA 上影响更接近“净中性”：
- 多数平均分变化只有 $\pm 0.01$
- 个别 benchmark 会有小幅涨跌，但整体难称稳定增益

#### Finding 2: 模型通常根本不愿意调用 world model
world model usage rate 很低，尤其在 VQA 上尤为明显：
- `GPT-5` 在 VQA 四个 benchmark 上平均调用率为 $0.0000$
- `GPT-5-mini` 平均仅 $0.0087$
- `GPT-4o` 平均仅 $0.0022$

Llama 家族是明显例外：
- `Llama-4-Maverick` 在 agent tasks 上平均调用率高达 $0.9956$
- 在 VQA 上平均也有 $0.3678$

但更关键的是，高调用率并不自动对应高收益，这意味着“愿意用”与“会用”是两回事。

#### Finding 3: 不同模型家族有稳定的调用人格
作者发现：
- `Llama` 最积极调用 world model，但收益很有限；
- `GPT` 系列中小模型更常调用，大模型更偏向依赖内部判断；
- `Qwen2.5-VL-7B` 作为最小模型之一，反而异常不愿调用，呈现某种“错位自信”。

这说明 world model invocation 不是简单由任务难度驱动，而与模型家族的自信模式、默认交互习惯有关。

#### Finding 4: 个案层面看，world model 的净效应接近中性甚至偏负
论文把样本分成 `WM Helps` 与 `WM Hurts`。结论是：
- 在 VQA 上，两者几乎打平；
- 在 agent tasks 上，`WM Hurts` 比 `WM Helps` 更常见。

也就是说，当前接口下的 world model 更像一个高噪声信息源，而不是稳定的认知增强器。

## 6 Analysis

### 6.1 Attribution Analysis
作者把 world model 带来的成败归纳成 8 类 attribution，并进一步抽象为一套 success / failure taxonomy。核心结论是：world model 的问题主要不是“预测未来太差”，而是 agent 在治理 foresight 时失稳。

成功链路对应三阶段：
- `Strategic Input`
- `Clear Interpretation`
- `Grounded Action`

失败链路则对应三类治理崩溃：
- `Calibration Failures`
- `Interpretation Ambiguity`
- `Unstable Integration Policy`

### 6.2 Agent Tasks 的主要问题：执行不稳定
在 agent tasks 中，simulation 确实有时能改善 planning 与 state understanding，但失败更频繁，且类型更多样。常见问题包括：
- action loops；
- over-planning；
- 工具使用低效；
- 误读模拟结果；
- 注意力漂移。

因此，agent 不是完全无法从 foresight 中受益，而是无法把它稳定转成连续前进的行动策略。

### 6.3 VQA 的主要问题：歧义被放大
在 VQA 中，world model 常作为“视觉确认器”使用，即模型先有一个猜想，再让 simulator 验证。但这会导致一种确认偏误：
- 若初始假设错了，simulation prompt 也会围绕错假设构造；
- world model 返回看似合理但其实跟错假设一致的画面；
- 最终 agent 被进一步误导。

所以 VQA 中的核心问题更像是 meaning governance 失败，即 simulation request 与 simulation outcome 都含糊，从而放大不确定性而不是消除它。

### 6.4 更多调用不代表更好
论文还发现 world model 调用次数与成功率往往负相关。这不意味着“simulation 有害”，而更像是：

$$
\text{更多调用} \approx \text{更高困惑与更差整合能力}
$$

模型在反复重查，而不是在累计有效证据。

### 6.5 强制调用 world model 会更糟
在 `WM Force Mode` 下，agent tasks 的表现比 optional access 更差。这个结果很重要，因为它直接反驳了一个直觉：

$$
\text{如果 simulation 有潜力，强制多用一点应该更好}
$$

事实恰好相反。当前 agent 既然本来就不会稳定治理 foresight，强制它每步都模拟，只会把这套弱点系统性放大。

## 7 Discussion
作者在讨论中给出三个很有启发性的后续方向。

### 7.1 从 confirmation 转向 discrimination
当前 agent 常把 world model 当“验证单一猜想”的工具，而不是“比较多个候选假设”的工具。更合理的协议是：
- 先提出多个 plausible hypothesis；
- 分别模拟；
- 再选择最符合观测线索的那个。

这会把 simulation 从“自我确认”变成“结构化假设检验”。

### 7.2 给 foresight 单独做模块，而不是塞进长上下文
作者建议把 foresight interaction 显式拆成：
- `Decider`：决定是否模拟、模拟什么；
- `Reflector`：解释真实观测与模拟结果是否一致；
- `Memory`：维护长短期目标与关键信息选择性释放。

这个建议很像把 foresight governance 从 prompt 工程提升到系统设计层。

### 7.3 需要真正针对 tool interaction 的训练
仅靠 prompting 很难教会 agent：
- 何时调用；
- 如何形成高质量 simulation query；
- 如何避免无差别重复调用。

因此作者建议用带在线多轮 rollout 的 RL 或高质量 SFT 数据来训练 world-model interaction habit，并加入适度的 information gain 或调用惩罚机制。

## 8 Conclusion
论文的核心结论可以压缩成一句话：

$$
\text{当前 agent 缺的不是 future simulator，而是治理 future simulator 的能力。}
$$

把 world model 接进 agent pipeline，不会自动带来 anticipatory cognition。真正缺失的是一套能稳定管理“何时模拟、如何解释、何时行动”的内在机制。作者因此把未来方向聚焦到 governance、接口设计与训练目标上，而不是单纯继续提升模拟器本身。

## Limitations
作者也说明了若干限制：
- 没覆盖 `Gemini` 与 `Claude`；
- agent tasks 与 VQA tasks 使用了不同类型的 simulator，跨任务可比性有限；
- `Wan2.1` 在 VQA 中偶尔会有生成伪影；
- 部分失败其实混杂了 agent instruction 不清导致的 simulator 输出歧义。

不过这些限制并不削弱论文主结论，因为作者研究的重点本来就是 agent 侧的使用能力，而不是 world model 的绝对上限。

## 我的理解
这篇论文最有价值的地方，是把一个容易被“系统拼装直觉”掩盖的问题揭出来了：很多人会自然认为，只要把更强的 simulator 接给 agent，它就会变得更会前瞻。但论文显示，工具存在与工具被正确吸收之间，隔着一整层 interaction governance。

如果把这件事迁移到更广泛的 agent/tool 使用问题上，它其实也在暗示：
- tool augmentation 的瓶颈往往不在 tool 本身；
- 而在 agent 有没有形成稳定的调用策略、解释协议与记忆整合机制。

这让本文不只是 world model 论文，也是一篇很典型的“agent tool use failure analysis”论文。

## 相关链接
- [[AgentForesight-研究地图]]
