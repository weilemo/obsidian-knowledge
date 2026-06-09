# TD 与 Q-learning

## 从完整 return 到 bootstrapping

Monte Carlo 方法等到一条 trajectory 结束后，用完整 return 更新价值：

$$
V(s_t) \leftarrow V(s_t) + \alpha\left[G_t - V(s_t)\right]
$$

Temporal Difference learning 不等到结束，而是用一步 reward 和下一状态的估计值更新：

$$
V(s_t) \leftarrow V(s_t) + \alpha\left[r_t+\gamma V(s_{t+1})-V(s_t)\right]
$$

TD error 定义为：

$$
\delta_t = r_t+\gamma V(s_{t+1})-V(s_t)
$$

直观理解：$\delta_t$ 衡量“当前预测”和“一步之后更好的预测”之间的差。

## SARSA

SARSA 是 on-policy 方法，更新当前策略实际采取的动作：

$$
Q(s_t,a_t) \leftarrow Q(s_t,a_t) + \alpha
\left[
r_t+\gamma Q(s_{t+1},a_{t+1})-Q(s_t,a_t)
\right]
$$

它叫 SARSA，是因为一次更新用到：

$$
(s_t,a_t,r_t,s_{t+1},a_{t+1})
$$

## Q-learning

Q-learning 是 off-policy 方法，用下一状态的最大动作价值来更新：

$$
Q(s_t,a_t) \leftarrow Q(s_t,a_t) + \alpha
\left[
r_t+\gamma \max_{a'}Q(s_{t+1},a')-Q(s_t,a_t)
\right]
$$

它学习的是最优 action-value function $Q^*$，即使采样行为来自带探索的策略。

## On-policy vs Off-policy

| 类型 | 学什么 | 数据来自谁 | 例子 |
|---|---|---|---|
| on-policy | 当前策略 $\pi$ 的价值或改进方向 | 当前策略自己采样 | SARSA、REINFORCE、PPO |
| off-policy | 目标策略或最优策略 | 可以来自别的策略或旧数据 | Q-learning、DQN、offline RL |

## 为什么这对 CS285 重要

CS285 后面的 DQN、offline RL、actor-critic 都在复用这里的思想：

1. 用 neural network 表示 $Q_\theta(s,a)$ 或 $V_\phi(s)$。
2. 用 bootstrapping 构造 target。
3. 用 replay buffer 或已有数据训练。
4. 面对 distribution shift 和 overestimation。

## 和 LLM / Agent 的连接

在 coding agent 里，一条轨迹可能是：

$$
\tau = (s_0,a_0,r_0,s_1,a_1,r_1,\ldots,s_T)
$$

其中：

- $s_t$：当前代码、测试结果、历史消息、memory。
- $a_t$：修改文件、运行测试、搜索、解释。
- $r_t$：测试是否更接近通过、lint 是否减少、用户是否满意。

如果只有最终 reward，credit assignment 很难。TD 思想提供了一个中间估计：

$$
\text{当前步骤是否让未来成功概率更高？}
$$

