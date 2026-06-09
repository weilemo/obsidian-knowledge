# MDP 与 Bellman

## MDP 是什么

强化学习把问题建模成 Markov Decision Process：

$$
\mathcal{M} = (\mathcal{S}, \mathcal{A}, P, r, \gamma)
$$

其中：

| 符号 | 含义 |
|---|---|
| $\mathcal{S}$ | state space，所有可能状态 |
| $\mathcal{A}$ | action space，所有可能动作 |
| $P(s' \mid s,a)$ | transition dynamics，从状态 $s$ 执行动作 $a$ 后转移到 $s'$ 的概率 |
| $r(s,a)$ | reward function，执行动作后的即时奖励 |
| $\gamma$ | discount factor，未来奖励的折扣 |

Markov 性质指的是：

$$
P(s_{t+1}\mid s_t,a_t,s_{t-1},a_{t-1},\ldots)=P(s_{t+1}\mid s_t,a_t)
$$

直观理解：只要知道当前状态和当前动作，历史就不再额外提供预测下一状态的信息。

## Policy

policy 是 agent 的行为规则：

$$
\pi(a\mid s)=P(a_t=a\mid s_t=s)
$$

如果是确定性策略，可以写成：

$$
a=\pi(s)
$$

如果是随机策略，策略输出的是动作分布。

## Return

从时间 $t$ 开始的累计折扣奖励：

$$
G_t = r_t + \gamma r_{t+1} + \gamma^2 r_{t+2} + \cdots
$$

也就是：

$$
G_t = \sum_{k=0}^{\infty}\gamma^k r_{t+k}
$$

RL 的核心目标是找到一个策略 $\pi$，让期望 return 最大。

## Value Function

state-value function：

$$
V^\pi(s)=\mathbb{E}_\pi[G_t \mid s_t=s]
$$

含义：在状态 $s$ 开始，之后一直按照策略 $\pi$ 行动，期望能拿到多少累计奖励。

action-value function：

$$
Q^\pi(s,a)=\mathbb{E}_\pi[G_t \mid s_t=s,a_t=a]
$$

含义：在状态 $s$ 先执行动作 $a$，之后按照策略 $\pi$ 行动，期望能拿到多少累计奖励。

## Bellman Expectation Equation

价值可以拆成“当前奖励 + 下一状态价值”：

$$
V^\pi(s)=\sum_a \pi(a\mid s)\sum_{s'}P(s'\mid s,a)
\left[r(s,a)+\gamma V^\pi(s')\right]
$$

对应 $Q^\pi$：

$$
Q^\pi(s,a)=\sum_{s'}P(s'\mid s,a)
\left[r(s,a)+\gamma \sum_{a'}\pi(a'\mid s')Q^\pi(s',a')\right]
$$

这就是 Bellman 思想：一个长期问题可以递归地拆成一步问题。

## Bellman Optimality Equation

最优 value function：

$$
V^*(s)=\max_a \sum_{s'}P(s'\mid s,a)
\left[r(s,a)+\gamma V^*(s')\right]
$$

最优 action-value function：

$$
Q^*(s,a)=\sum_{s'}P(s'\mid s,a)
\left[r(s,a)+\gamma \max_{a'}Q^*(s',a')\right]
$$

最优策略可以从 $Q^*$ 里读出来：

$$
\pi^*(s)=\arg\max_a Q^*(s,a)
$$

## 和 LLM / Agent 的连接

| RL 概念 | LLM / Agent 对照 |
|---|---|
| state $s$ | prompt、历史轨迹、当前文件状态、memory |
| action $a$ | 生成 token、调用工具、编辑代码、运行测试 |
| reward $r$ | 单步反馈、测试通过、规则奖励、人类偏好 |
| trajectory $\tau$ | 一次完整推理 / coding / tool-use 过程 |
| policy $\pi$ | 当前模型或 agent 的行为分布 |
| value $V$ | 当前状态未来成功概率或预期收益 |

关键迁移：agent training 不是只看最终答案，而是把整个过程看成 trajectory。

