# Final Project Proposal

## 候选方向

### 方向 1：Coding Agent 的 Trajectory-Level Reward Shaping

问题：coding agent 的最终 reward 往往只有测试是否通过，但中间步骤有大量可利用信号。

核心想法：

$$
R(\tau)=R_{\text{final}}+\lambda \sum_t r_{\text{process}}(s_t,a_t)
$$

候选过程奖励：

- 编译错误减少。
- 测试失败数量减少。
- diff 更小但更有效。
- 关键文件定位更快。
- 反复无效操作减少。

### 方向 2：Memory-Augmented Agent 的 Reflection Reward

问题：agent memory 不只是存历史，还应当影响未来策略。

核心问题：

$$
\pi(a_t\mid s_t,m_t)
$$

其中 $m_t$ 是 memory state。可以研究：

- 什么样的 reflection 会提高后续成功率？
- memory 检索错误是否导致负 reward？
- verbal reinforcement learning 如何形式化？

### 方向 3：RLVR 数据选择与 Reasoning Emergence

问题：rule-based reward 有效，但不同数据分布可能导致不同 reasoning 行为。

可研究：

- easy / medium / hard problem mixture。
- sparse reward vs shaped reward。
- verifier precision 对训练稳定性的影响。

### 方向 4：Video / World Model 的 Adaptive Precision Policy

问题：长视频生成中，不同 head / token / timestep 对未来一致性的影响不同。

可以把 bit allocation 看成 policy：

$$
a_t \in \{2\text{-bit},4\text{-bit},8\text{-bit},bf16\}
$$

reward 可以来自：

$$
R = \text{quality score} - \lambda \cdot \text{memory cost}
$$

候选指标：

- subject consistency。
- motion smoothness。
- background consistency。
- KV cache memory。
- inference speed。

## 当前最推荐

优先选择方向 4，因为它最贴近实验室资源；同时用方向 1/2/3 作为 LLM agent 主线的理论补充。

标题草案：

> Adaptive Precision as a Sequential Decision Policy for Long-Horizon Video Generation

## 下一步

1. 学完 Week 4 后再定最终题目。
2. 学完 Week 6 后写 1 页 proposal。
3. 用已有 videoquant / HeadWiseKVQuant 结果做 feasibility check。

