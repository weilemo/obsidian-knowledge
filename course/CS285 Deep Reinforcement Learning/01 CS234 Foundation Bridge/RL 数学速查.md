# RL 数学速查

## 概率分布

策略通常是条件概率分布：

$$
\pi_\theta(a\mid s)
$$

含义：在状态 $s$ 下，参数为 $\theta$ 的策略选择动作 $a$ 的概率。

## 期望

强化学习的目标通常是最大化期望累计奖励：

$$
J(\theta)=\mathbb{E}_{\tau \sim p_\theta(\tau)}[R(\tau)]
$$

其中 $\tau$ 是 trajectory，$R(\tau)$ 是整条轨迹的 return。

## 条件期望

value function 是条件期望：

$$
V^\pi(s)=\mathbb{E}_\pi[G_t\mid s_t=s]
$$

action-value function 也是条件期望：

$$
Q^\pi(s,a)=\mathbb{E}_\pi[G_t\mid s_t=s,a_t=a]
$$

## 折扣和

return：

$$
G_t=\sum_{k=0}^{\infty}\gamma^k r_{t+k}
$$

$\gamma$ 越接近 $1$，越重视长期奖励；$\gamma$ 越接近 $0$，越重视即时奖励。

## 梯度下降与梯度上升

最小化 loss 用梯度下降：

$$
\theta \leftarrow \theta - \alpha \nabla_\theta L(\theta)
$$

最大化 reward objective 用梯度上升：

$$
\theta \leftarrow \theta + \alpha \nabla_\theta J(\theta)
$$

很多实现里会把最大化 $J(\theta)$ 写成最小化 $-J(\theta)$。

## Log-Derivative Trick

核心恒等式：

$$
\nabla_\theta p_\theta(x)
=p_\theta(x)\nabla_\theta \log p_\theta(x)
$$

推导：

$$
\nabla_\theta \log p_\theta(x)
=
\frac{1}{p_\theta(x)}\nabla_\theta p_\theta(x)
$$

所以：

$$
\nabla_\theta p_\theta(x)
=
p_\theta(x)\nabla_\theta \log p_\theta(x)
$$

这是 policy gradient 能绕开环境不可微问题的关键。

## KL Divergence

KL divergence 衡量两个分布差异：

$$
D_{KL}(p\|q)=\sum_x p(x)\log\frac{p(x)}{q(x)}
$$

在 RLHF / PPO 中，KL 常用于限制新模型不要偏离参考模型太远：

$$
D_{KL}(\pi_\theta \| \pi_{\text{ref}})
$$

## Entropy

策略熵：

$$
H(\pi(\cdot\mid s))
=
-\sum_a \pi(a\mid s)\log \pi(a\mid s)
$$

熵越高，策略越随机；熵越低，策略越确定。

在 RL 中，entropy bonus 常用于鼓励 exploration。

