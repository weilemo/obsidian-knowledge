---
created: 2026-04-10
type: note
status: 在用
tags:
  - ELBO
  - Diffusion
  - DDPM
  - VariationalInference
  - MSE
summary: 系统总结扩散模型中ELBO分解、KL到加权MSE推导与噪声采样机制
---

# ELBO与扩散模型：从严格推导到训练目标

## 1. ELBO 是什么
ELBO（Evidence Lower Bound）是对对数似然 $\log p_\theta(x_0)$ 的下界。训练时最大化 ELBO，等价于最小化负 ELBO。

$$
\log p_\theta(x_0) \ge \mathrm{ELBO}(x_0), \qquad
\mathcal L_{\mathrm{VLB}} := -\mathrm{ELBO}
$$

它的作用是：把难以直接优化的边缘似然，转化成可计算的分项目标。

## 2. 扩散模型中的 ELBO 严格推导
设前向扩散过程（固定）：

$$
q(x_{1:T}\mid x_0)=\prod_{t=1}^T q(x_t\mid x_{t-1})
$$

设反向生成模型（可学习）：

$$
p_\theta(x_{0:T}) = p(x_T)\prod_{t=1}^T p_\theta(x_{t-1}\mid x_t)
$$

从边缘似然出发：

$$
\log p_\theta(x_0)
= \log \int p_\theta(x_{0:T})\,dx_{1:T}
= \log \int q(x_{1:T}\mid x_0)\frac{p_\theta(x_{0:T})}{q(x_{1:T}\mid x_0)}\,dx_{1:T}
$$

由 Jensen 不等式：

$$
\log p_\theta(x_0)
\ge
\mathbb E_{q(x_{1:T}\mid x_0)}\left[
\log p_\theta(x_{0:T}) - \log q(x_{1:T}\mid x_0)
\right]
=: \mathrm{ELBO}
$$

对负 ELBO 做标准重排，得到：

$$
\mathcal L_{\mathrm{VLB}}
=
\underbrace{\mathrm{KL}\big(q(x_T\mid x_0)\,\|\,p(x_T)\big)}_{\text{prior term}}
+
\sum_{t=2}^T
\underbrace{\mathbb E_q\left[\mathrm{KL}\big(q(x_{t-1}\mid x_t,x_0)\,\|\,p_\theta(x_{t-1}\mid x_t)\big)\right]}_{\text{denoising terms}}
+
\underbrace{\mathbb E_q[-\log p_\theta(x_0\mid x_1)]}_{\text{reconstruction term}}
$$

## 3. 为什么会分成 prior / denoising / reconstruction
- prior term：约束链条顶端噪声分布与先验 $p(x_T)$（通常高斯）对齐，保证可从简单噪声开始采样。
- denoising terms：每一步都让反向核 $p_\theta(x_{t-1}\mid x_t)$ 逼近真实后验，等价于把“从噪声到数据”的难题拆成多步小去噪。
- reconstruction term：最后一步从 $x_1$ 重建 $x_0$ 的数据拟合项。

实践里常把 reconstruction 也归在“去噪家族”里，但严格分解通常单列。

## 4. 每个 KL 项为何可写成“常数 + 加权 MSE”
采用 DDPM 常见高斯设定：

$$
q(x_t\mid x_{t-1})=\mathcal N(\sqrt{\alpha_t}x_{t-1},\,\beta_t I),
\quad \alpha_t=1-\beta_t,
\quad \bar\alpha_t=\prod_{s=1}^t \alpha_s
$$

则：

$$
x_t=\sqrt{\bar\alpha_t}x_0 + \sqrt{1-\bar\alpha_t}\,\epsilon,
\quad \epsilon\sim\mathcal N(0,I)
$$

第 $t$ 项去噪 KL：

$$
\mathcal L_{t-1}
=\mathbb E_q\left[\mathrm{KL}\big(q(x_{t-1}\mid x_t,x_0)\,\|\,p_\theta(x_{t-1}\mid x_t)\big)\right]
$$

记：

$$
q(x_{t-1}\mid x_t,x_0)=\mathcal N(\tilde\mu_t,\tilde\beta_t I),
\quad
p_\theta(x_{t-1}\mid x_t)=\mathcal N(\mu_\theta,\sigma_t^2 I)
$$

高斯 KL 给出：

$$
\mathrm{KL}
=
\frac{1}{2\sigma_t^2}\|\tilde\mu_t-\mu_\theta\|_2^2 + C_t
$$

其中 $C_t$ 与 $\theta$ 无关（常数项）。在 $\epsilon$ 参数化下：

$$
\mu_\theta(x_t,t)=\frac{1}{\sqrt{\alpha_t}}\left(x_t-\frac{\beta_t}{\sqrt{1-\bar\alpha_t}}\epsilon_\theta(x_t,t)\right)
$$

$$
\tilde\mu_t(x_t,x_0)=\frac{1}{\sqrt{\alpha_t}}\left(x_t-\frac{\beta_t}{\sqrt{1-\bar\alpha_t}}\epsilon\right)
$$

相减得：

$$
\tilde\mu_t-\mu_\theta
=
\frac{\beta_t}{\sqrt{\alpha_t}\sqrt{1-\bar\alpha_t}}\big(\epsilon-\epsilon_\theta(x_t,t)\big)
$$

代回可得：

$$
\mathcal L_{t-1}
=
\mathbb E_{x_0,\epsilon}\left[
\frac{\beta_t^2}{2\sigma_t^2\alpha_t(1-\bar\alpha_t)}
\|\epsilon-\epsilon_\theta(x_t,t)\|_2^2
\right] + C_t
$$

因此每个 KL 项都可写为：

$$
\text{常数} + w_t\cdot\text{MSE},
\quad
w_t=\frac{\beta_t^2}{2\sigma_t^2\alpha_t(1-\bar\alpha_t)}
$$

## 5. 什么是“ELBO 的重权重形式”
把各步加权 MSE 写成统一形式：

$$
\mathcal L = \sum_{t=1}^T \tilde w_t\,\mathbb E\left[\|\epsilon-\epsilon_\theta(x_t,t)\|_2^2\right]
$$

这里 $\tilde w_t$ 可以是理论权重，也可以是工程上的重加权（如 SNR reweighting）。本质是重新分配不同噪声层的训练强度。

若训练时从分布 $r(t)$ 采样时间步，则无偏估计写作：

$$
\mathbb E_{t\sim r}\left[\frac{\tilde w_t}{r(t)}\,\|\epsilon-\epsilon_\theta(x_t,t)\|_2^2\right]
$$

## 6. 为什么训练时随机采样噪声级别
目标本来就是对所有噪声层求期望，随机采样是 Monte Carlo 估计：

$$
\mathcal L = \mathbb E_{t,x_0,\epsilon}[\ell_\theta(x_t,t)]
$$

在序列扩散（如 Diffusion Forcing）中，还会对每个 token 独立采样 $t_i$，从而让模型见到“局部高噪声 + 局部低噪声”的多种组合，提高长序列条件下的泛化与稳定性。

## 7. 什么是 $\beta$-schedule
$\beta$-schedule 是每一步前向加噪强度的时间表 $\{\beta_t\}_{t=1}^T$：

$$
q(x_t\mid x_{t-1})=\mathcal N(\sqrt{1-\beta_t}x_{t-1},\,\beta_t I)
$$

它决定了不同 $t$ 的信噪比结构（SNR 分布），常见有 linear / cosine / sigmoid。直观上：
- 采样 $t$ 决定“选哪个噪声档位”；
- schedule 决定“该档位具体有多吵”。

## 8. 一页速记
$$
\log p_\theta(x_0)\ge \mathrm{ELBO}
\Rightarrow
\mathcal L_{\mathrm{VLB}}=\text{prior} + \sum\text{denoising} + \text{reconstruction}
$$

$$
\text{每个 denoising KL} = C_t + w_t\cdot\mathrm{MSE}
$$

$$
\text{训练可看作对不同噪声层的加权回归问题}
$$

## 相关笔记
- [[Diffusion-Forcing ✅]]
- [[Video-Diffusion-Models✅]]
