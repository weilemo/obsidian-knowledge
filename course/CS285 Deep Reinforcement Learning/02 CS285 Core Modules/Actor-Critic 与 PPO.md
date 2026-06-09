# Actor-Critic 与 PPO

## Actor-Critic 的核心想法

Actor 是策略：

$$
\pi_\theta(a\mid s)
$$

Critic 是价值估计器：

$$
V_\phi(s)
$$

actor 负责选择动作，critic 负责判断当前动作比平均水平好多少。

## Advantage

advantage 定义为：

$$
A^\pi(s,a)=Q^\pi(s,a)-V^\pi(s)
$$

直观理解：

- $Q^\pi(s,a)$：在状态 $s$ 做动作 $a$ 后，未来预计能拿多少奖励。
- $V^\pi(s)$：在状态 $s$ 按平均策略行动，未来预计能拿多少奖励。
- $A^\pi(s,a)$：动作 $a$ 比当前策略平均动作好多少。

policy gradient 可以写成：

$$
\nabla_\theta J(\theta)
=
\mathbb{E}
\left[
\nabla_\theta \log \pi_\theta(a_t\mid s_t)A^\pi(s_t,a_t)
\right]
$$

## PPO

PPO 希望策略更新不要一步跨太大。定义概率比值：

$$
r_t(\theta)=
\frac{\pi_\theta(a_t\mid s_t)}
{\pi_{\theta_{\text{old}}}(a_t\mid s_t)}
$$

clipped objective：

$$
L^{CLIP}(\theta)=
\mathbb{E}_t
\left[
\min
\left(
r_t(\theta)A_t,
\operatorname{clip}(r_t(\theta),1-\epsilon,1+\epsilon)A_t
\right)
\right]
$$

直观理解：如果新策略让某个动作概率变化太大，就把收益截断，防止训练发散。

## 为什么 PPO 常出现在 LLM RLHF

LLM 的策略空间极大。直接 policy gradient 容易让模型分布突然漂移，导致：

1. 语言质量下降。
2. reward hacking。
3. 训练不稳定。
4. 偏离 SFT 模型太远。

PPO 用 clipped objective 和 KL 约束，让模型在靠近旧策略的范围内改进。

## 和 RLVR 的关系

RLVR 的 reward 可以来自规则验证器，例如数学答案正确、代码测试通过。

对应关系：

| RL 符号 | LLM RLVR 对照 |
|---|---|
| $s_t$ | prompt + 已生成推理 |
| $a_t$ | 下一个 token 或一段 reasoning action |
| $\pi_\theta$ | 当前语言模型 |
| $R$ | verifier / rule-based reward |
| $A_t$ | 当前输出相对 baseline 的优势 |
| KL | 不要偏离参考模型太远 |

