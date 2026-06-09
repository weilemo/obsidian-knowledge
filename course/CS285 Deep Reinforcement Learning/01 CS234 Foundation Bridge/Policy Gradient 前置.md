# Policy Gradient 前置

## 优化目标

策略 $\pi_\theta(a\mid s)$ 由参数 $\theta$ 控制。强化学习希望最大化期望 return：

$$
J(\theta)=\mathbb{E}_{\tau \sim p_\theta(\tau)}[R(\tau)]
$$

其中 trajectory 为：

$$
\tau=(s_0,a_0,s_1,a_1,\ldots,s_T)
$$

trajectory 的概率为：

$$
p_\theta(\tau)=p(s_0)\prod_{t=0}^{T}
\pi_\theta(a_t\mid s_t)P(s_{t+1}\mid s_t,a_t)
$$

## Log-Derivative Trick

关键恒等式：

$$
\nabla_\theta p_\theta(\tau)
=p_\theta(\tau)\nabla_\theta \log p_\theta(\tau)
$$

因此：

$$
\nabla_\theta J(\theta)
=\mathbb{E}_{\tau \sim p_\theta(\tau)}
\left[
\nabla_\theta \log p_\theta(\tau)R(\tau)
\right]
$$

环境转移 $P(s_{t+1}\mid s_t,a_t)$ 通常不依赖 $\theta$，所以：

$$
\nabla_\theta \log p_\theta(\tau)
=\sum_{t=0}^{T}\nabla_\theta \log \pi_\theta(a_t\mid s_t)
$$

得到 policy gradient：

$$
\nabla_\theta J(\theta)
=\mathbb{E}_{\tau \sim p_\theta(\tau)}
\left[
\sum_{t=0}^{T}\nabla_\theta \log \pi_\theta(a_t\mid s_t)R(\tau)
\right]
$$

## 直观解释

如果某条轨迹 reward 高，就提高这条轨迹中动作的 log probability。

如果某条轨迹 reward 低，就降低这条轨迹中动作的 log probability。

用一句话记：

$$
\text{good action becomes more likely, bad action becomes less likely}
$$

## Baseline

直接用 $R(\tau)$ 方差很大。可以减去 baseline：

$$
\nabla_\theta J(\theta)
=\mathbb{E}
\left[
\sum_t \nabla_\theta \log \pi_\theta(a_t\mid s_t)
\left(R(\tau)-b(s_t)\right)
\right]
$$

常见 baseline 是 value function：

$$
b(s_t)=V^\pi(s_t)
$$

于是得到 advantage：

$$
A^\pi(s_t,a_t)=Q^\pi(s_t,a_t)-V^\pi(s_t)
$$

## 和 LLM RL 的连接

LLM 里策略是语言模型：

$$
\pi_\theta(y_t\mid x,y_{<t})
$$

一次完整回答或推理过程可以看成 trajectory。reward 可以来自：

- 人类偏好模型。
- rule-based verifier。
- 单元测试。
- 数学答案检查器。
- agent task success signal。

RLHF / RLVR 的核心，就是用 reward 调整生成分布，让高 reward 的输出更容易出现。

