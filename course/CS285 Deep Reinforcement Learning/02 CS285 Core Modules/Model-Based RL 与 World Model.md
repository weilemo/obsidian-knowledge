# Model-Based RL 与 World Model

## Model-Based RL 的问题

model-free RL 直接学习 policy 或 value。model-based RL 先学习环境动力学：

$$
\hat{P}_\phi(s_{t+1}\mid s_t,a_t)
$$

然后用学到的模型做 planning 或生成模拟数据。

## 基本流程

1. 收集真实环境数据：

$$
\mathcal{D}=\{(s_t,a_t,r_t,s_{t+1})\}
$$

2. 训练 dynamics model：

$$
\phi^*=\arg\max_\phi
\sum_{(s,a,s')\in\mathcal{D}}
\log \hat{P}_\phi(s'\mid s,a)
$$

3. 用模型预测未来。
4. 选择预期 return 最大的 action sequence。

## Model Predictive Control

MPC 每一步都重新规划：

$$
a_{t:t+H}^*
=
\arg\max_{a_{t:t+H}}
\sum_{h=0}^{H}
\gamma^h r(s_{t+h},a_{t+h})
$$

执行第一个动作 $a_t^*$ 后，再观察新状态并重新规划。

## 主要困难

| 困难 | 含义 |
|---|---|
| model bias | 模型预测错，planning 会放大错误 |
| compounding error | 多步 rollout 中误差逐步累积 |
| uncertainty | 模型不知道自己哪里不确定 |
| distribution shift | policy 访问到训练数据没覆盖的状态 |

## 和 video / world model 的连接

video generation model 可以看作一种 learned dynamics model：

$$
\hat{P}_\phi(x_{t+1:t+k}\mid x_{\le t}, c)
$$

其中 $x$ 是 video latent 或 frame，$c$ 是 condition。

对当前 video quantization / world model 方向，值得关注的问题是：

1. 哪些 token / head 对未来 dynamics 预测更关键？
2. quantization error 是否会在长 horizon 中累积？
3. 能否根据 model uncertainty 或 temporal role 做 adaptive precision？
4. VBench 里的 motion smoothness、subject consistency 是否能被理解成 trajectory-level reward？

