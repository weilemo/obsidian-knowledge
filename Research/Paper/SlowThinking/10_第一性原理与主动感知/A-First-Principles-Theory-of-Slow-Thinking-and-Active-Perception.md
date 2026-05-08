---
created: 2026-04-22
published: 2026-04-14
type: paper
status: 已读
tags: [SlowThinking, ActivePerception, FirstPrinciples, CognitiveModeling, Reasoning]
aliases: [慢思考的第一性原理, A First-Principles Theory of Slow Thinking and Active Perception]
summary: "本文从 projection/lifting、最优采样器与统一不确定性目标出发，给出 slow thinking 作为 active perception 静态子空间的数学建模；本文笔记重写为“定义-定理-推导链”版本，并明确区分严格证明与 heuristic 部分。"
pdf-url: Research/Paper/SlowThinking/Attachments/Theory_of_Slow_Thinking_0414.pdf
source-url:
  - https://www.researchgate.net/publication/400747801_A_First-Principles_Theory_of_Slow_Thinking_and_Active_Perception
  - https://doi.org/10.13140/RG.2.2.21094.28488
---

# A First-Principles Theory of Slow Thinking and Active Perception

## PDF
- [[Research/Paper/SlowThinking/Attachments/Theory_of_Slow_Thinking_0414.pdf]]

## 核心结论
这篇论文最重要的主张不是“CoT 有用”，而是：

$$
\text{slow thinking} \subset \text{active lifting / active perception}
$$

更准确地说，作者先在一个固定 `projection` 的静态框架里，把慢思考形式化为对潜变量轨迹的边缘化与采样；然后再把这个静态理论推广为更一般的 `active lifting`，其中 latent sequence 不再由人工预设格式决定，而由“最大化不确定性下降速率”的目标诱导出来。

但要强调一个阅读判断：
- 第 2-3 节的 `static theory` 推导得最扎实。
- 第 4 节与第 6 节提出的 `unified objective -> active lifting -> projection emergence` 很强，但其中关键一步仍包含作者明确承认的 `informal argument`。

所以，这篇论文最适合读成：
- 一套很强的数学建模路线；
- 其中静态慢思考部分更接近完整理论；
- 主动感知总框架部分更接近高质量 theoretical proposal。

## 1. 问题设定
论文从序列分布建模出发。设：

$$
\Sigma: \text{observable vocabulary}, \qquad \Omega: \text{latent vocabulary}
$$

观测空间与潜空间分别为

$$
X = \Sigma^\omega, \qquad Z = \Omega^\omega.
$$

目标分布为

$$
P^* \in \mathcal P(\Sigma^\omega).
$$

作者不直接把问题写成“拟合一个语言模型”，而是先抽象出一类函数族 $\mathcal F$，再定义由函数族诱导的分布复杂度：

$$
\|P\|_{\mathcal F}
:=
\inf_{f \in \mathcal F}
\left\{
\|f\|_{\mathcal F}
\mid
P = P_f
\right\}.
$$

这一步的含义是：如果我们固定底层可实现机制，比如 Transformer，那么真正重要的不只是“能不能表示”，还包括“要以多复杂的函数才能表示”。

在具体分布参数化上，论文用 next-token conditionals 来定义一个序列分布。给定 logit 函数

$$
f : \Sigma^* \to \mathbb R_{-}^{|\Sigma|},
$$

定义

$$
P_f^{+1}(\cdot \mid x) = \operatorname{softmax}(f(x)),
$$

再由这些 next-token conditionals 唯一诱导一个分布

$$
P_f \in \mathcal P(\Sigma^\omega).
$$

这对应论文式 (13)。

## 2. 为什么需要 projection / lifting
论文第 2 节的第一条主线是：plain Transformer 直接在 observable space 上建模，表达能力有本质限制。

### 2.1 Plain Transformer 的限制
Theorem 3 在复杂度假设

$$
\mathrm{TC}^0 \subsetneq \mathrm{NC}^1
$$

下说明：存在某个 HMM 分布 $P_{A,B,\lambda}$，使得任意固定结构的 Transformer 都无法把近似误差降到 0：

$$
\inf_{f \in \mathrm{TF}(L,H,d_h,p)}
D(P_{A,B,\lambda}, P_f) > 0.
$$

这个结论的直觉是：某些序列依赖本质上需要随输入长度增长的顺序计算深度，而 bounded-depth Transformer 只能做“有限深度 + 大量并行”的计算，因此无法逼近所有看似简单的分布。

### 2.2 引入 projection 后的参数化
于是作者考虑一个更大的 latent space，与一个投影

$$
\mathrm{Proj} : Z \to X.
$$

此时不再直接用 $P_f$ 表示观测分布，而是用

$$
P = \mathrm{Proj}_\# Q
$$

即 latent distribution $Q$ 经过 pushforward 得到 observable distribution。

对应的新复杂度定义为

$$
\|P\|_{\mathcal F, \mathrm{Proj}}
:=
\inf_{Q \in \mathcal P(Z)}
\left\{
\|Q\|_{\mathcal F}
\mid
P = \mathrm{Proj}_\# Q
\right\}.
$$

这对应论文式 (16)。它表达了整篇论文最核心的想法：

$$
\text{复杂的 observable distribution}
\quad \Rightarrow \quad
\text{也许可以通过更简单的 latent distribution + projection 来表示。}
$$

### 2.3 Lifting 的严格定义
如果只写 $P = \mathrm{Proj}_\# Q$ 还不够，因为我们要真正计算 observable prefix likelihood。为此，第 2.6 节证明了一个关键结构。

若

$$
\mathrm{Proj} : \Omega^\omega \rightharpoonup \Sigma^\omega
$$

是连续、满射、定义域闭的偏函数，那么对任意前缀 $x \in \Sigma^*$，其逆像可以写成有限个 cylinder set 的不交并：

$$
\mathrm{Proj}^{-1}([x])
=
\bigsqcup_{z \in I_x} [z] \cap \mathrm{Dom}(\mathrm{Proj}).
$$

在所有这样的 $I_x$ 中存在唯一极小者，记为

$$
\mathrm{Proj}^{-1}_{<\omega}(x).
$$

这就是 Definition 3 的 `lifting`。

这一步很关键，因为它把无限序列上的 inverse image 变成了有限前缀集合，从而可计算。

## 3. 静态 slow thinking 的严格推导
这里进入论文最扎实的部分。固定一个 projection 后，作者把 slow thinking 形式化成“对 latent explanation 的边缘化与采样”。

### 3.1 Observable likelihood 是对 latent prefix 的边缘化
Theorem 7 给出：

$$
(\mathrm{Proj}_\# P)^{\le |x|}(x)
=
\sum_{z \in \mathrm{Proj}^{-1}_{<\omega}(x)}
P^{\le |z|}(z).
$$

这对应论文式 (22)。

这就是 slow thinking 最核心的数学形式：  
观测前缀 $x$ 的概率，不是由一个单一路径给出，而是由所有可能 latent explanation 的总和给出。

进一步，对条件概率也有：

$$
(\mathrm{Proj}_\# P)^{\le |x|+|y|}(y \mid x)
=
\int
P(\Phi(z,y) \mid z)\,
dQ^*(z \mid x),
$$

其中 $\Phi$ 是 next-segment map，而

$$
Q^*(z \mid x)
:=
\frac{P^{\le |z|}(z)}
{(\mathrm{Proj}_\# P)^{\le |x|}(x)},
\qquad
z \in \mathrm{Proj}^{-1}_{<\omega}(x)
$$

是 posterior sampler，对应式 (23)-(24)。

所以在这个框架里：
- `observable text` 是表层对象；
- `latent sequence` 是中间解释；
- `slow thinking` 本质上就是对 latent explanations 的边缘化。

### 3.2 为什么需要采样
式 (22) 虽然是严格的，但通常

$$
\mathrm{Proj}^{-1}_{<\omega}(x)
$$

巨大到无法枚举，因此必须做 Monte Carlo。

最简单的 likelihood estimator 是重要性采样：

$$
p_n(x)
=
\frac{1}{n}
\sum_{i=1}^n
\frac{P^{\le |Z^{(i)}|}(Z^{(i)})}
{Q(Z^{(i)} \mid x)},
\qquad
Z^{(i)} \sim Q(\cdot \mid x).
$$

论文证明其方差由

$$
\chi^2(Q^*(\cdot \mid x)\,\|\,Q(\cdot \mid x))
$$

控制，因此最优 inference sampler 正是 posterior sampler $Q^*$。

这一步给出了“为什么多想几步有时有用”的第一层解释：  
不是 token 变多本身神奇，而是你在 latent explanation space 里做了更充分的近似积分。

### 3.3 训练梯度的严格推导
这篇论文最有意思的结果之一，是训练和推理需要不同的最优 sampler。

设训练目标为 cross entropy：

$$
L(P_f)
=
- \int \log (\mathrm{Proj}_\# P_f)^{\le |x|}(x)\, dP^*(x).
$$

其精确梯度可写成

$$
v^*
=
\nabla_\theta L(P_f)
=
- \int
\sum_{z \in \mathrm{Proj}^{-1}_{<\omega}(x)}
\frac{\nabla_\theta P_f^{\le |z|}(z)}
{(\mathrm{Proj}_\# P_f)^{\le |x|}(x)}
\,
dP^*(x).
$$

等价地，对单个样本 $x$，

$$
v^*(x)
=
- \nabla_\theta \log (\mathrm{Proj}_\# P_f)^{\le |x|}(x)
=
- \int \nabla_\theta \log P_f^{\le |z|}(z)\, dQ^*(z \mid x).
$$

接着作者构造采样梯度估计器 $v_n(x)$，并最小化它的均方误差

$$
\mathbb E \left[\|v^*(x) - v_n(x)\|^2\right].
$$

如果把分子和分母的采样器分开，最优解不是两个都取 posterior sampler。论文 Proposition 33 给出唯一最优解：

$$
Q(\cdot \mid x) = Q^*(\cdot \mid x),
$$

而分子对应的最优 train sampler 为

$$
\overline{Q}(z \mid x)
\propto
P_f^{\le |z|}(z)\,
\left\|
\nabla_\theta \log P_f^{\le |z|}(z)
\right\|.
$$

这就是式 (49)，也是 Definition 11 的 `inquisitive sampler`。

它的推导逻辑可以压缩成一句：

$$
\text{训练时不仅关心“哪个 latent explanation 更可能”，还关心“哪个 explanation 对参数更新更有信息量”。}
$$

对应的梯度估计误差满足

$$
\mathbb E \left[\|v^*(x) - v_n(x)\|^2\right]
=
\frac{1}{n}
\left[
C_\downarrow^2
(\mathrm{Proj}_\# P_f)^{\le |x|}(x)^2
\chi^2(Q^* \,\|\, Q)
+
C_\uparrow^2
\chi^2(\overline{Q} \,\|\, \overline{Q})
+ (C_\uparrow^2 - C_\downarrow^2)
\right]
+ O(n^{-2}),
$$

即论文式 (51)。这说明 slow thinking 的训练效率由两个对齐问题共同控制：
- inference sampler 是否逼近 posterior；
- train sampler 是否逼近 inquisitive sampler。

### 3.4 Sampler hierarchy 与非因果性
论文进一步区分：
- identity sampler；
- predictive sampler；
- causal sampler；
- explanatory sampler。

其中最重要的数学结论是：

1. Theorem 15：posterior sampler 一般几乎从不属于 causal sampler 类。
2. Proposition 16：如果一个 sampler 本身不是 causal 的，那么它与任何 causal sampler 的 $\chi^2$ 距离都有正下界。

这意味着：

$$
Q^* \notin \mathcal Q_{\text{causal}}
\quad \text{generically}.
$$

因此，若只用因果式 CoT sampler 去逼近真正的 posterior，存在结构性 gap，而不只是实现不够好。

这也是作者为何把更一般的 sampler 类命名为 `explanatory sampler`：  
它们允许后文解释前文，而不被单向时间顺序限制。

### 3.5 Slow thinking 的定义与 scaling law
在这个静态理论里，作者把 slow thinking 定义为：  
对某个目标算子 $V^*(p,x,\theta)$ 的一致估计，其中凡是涉及

$$
\mathrm{Proj}^{-1}_{<\omega}(x)
$$

上的求和，都用采样近似。

于是多个任务的误差都呈现出统一的

$$
O\!\left(\frac{\chi^2}{n}\right)
$$

型缩放：
- encoding likelihood estimation；
- decoding；
- training gradient estimation；
- multi-choice reasoning。

这给了论文一个很强的统一叙述：  
`多采样为何有效`，在这个框架里不是经验现象，而是 latent marginalization 误差的自然结果。

## 4. 统一目标：最大化不确定性下降速率
第 4 节开始，论文想把前面的静态理论统一到单一目标下。

设

$$
C(\theta)
=
- \int \log P_\theta^{\le |x|}(x)\, dP^*(x) - H(P^*)
$$

表示“可约不确定性”。若参数更新轨迹为 $(\theta_s)$，每步耗时为 $t_{s+1}-t_s$，则目标写成

$$
\int_0^\infty C(\theta_{\operatorname{step}(t)})\, dt
=
\sum_{s=0}^\infty C(\theta_s)\,(t_{s+1}-t_s).
$$

对应论文式 (62)。

这个目标有两个效果：
- 它奖励低 loss；
- 它还奖励更快地降低 loss。

作者用它来解释三件事为什么会一起出现：
- 更强的表示能力；
- 更高的采样效率；
- 快慢思考之间的内生平衡。

这里要注意：这一节主要是 `informal argument`，不是像第 2-3 节那样完全严密的定理链。

## 5. 从 static theory 到 active lifting
这里是整篇论文最野心勃勃的部分。

### 5.1 一般 sampler 与 lifted distribution
Definition 21 定义一般 sampler：

$$
Q : X \times \Omega^* \to \mathcal P(\Omega).
$$

也就是说，给定数据样本 $x$ 与当前 latent prefix $z$，sampler 决定下一个 latent token 的条件分布。

它诱导出长度 $T$ 的 latent sequence distribution：

$$
Q^{\le T}(z \mid x)
=
\prod_{t=1}^T Q(z_t \mid x, z_{<t}).
$$

Definition 22 定义 lifted distribution：

$$
P_{\text{lift}}
=
P^* \otimes Q^{\le \omega}
\in
\mathcal P(X \times \Omega^\omega).
$$

再把它分解为 latent marginal 与 posterior-on-data：

$$
P_{\text{lift}}
=
P_{\le \omega}^* \otimes Q_{\le \omega}^*.
$$

其中：
- $Q_{\le \omega}^*$ 是 induced latent prior；
- $P^*(\cdot \mid z)$ 是给定 latent description 后的数据后验。

### 5.2 每一步观察后的不确定性
作者把“感知”建模为：观察样本 $x$ 时，主动生成一串 latent token $Z_1,Z_2,\dots$。  
在第 $t$ 步后，剩余不确定性由 posterior data distribution 描述。

定义

$$
C_t
=
\mathbb E_{X \sim P^*}
\mathbb E_{Z \sim Q^{\le t}(\cdot \mid X)}
\left[
- \log \frac{dP^*(\cdot \mid Z)}{dP^*}(X)
\right].
$$

这是式 (93)。在有限离散情形下，它等价于

$$
C_t
=
\int \log \frac{Q_{\le t}^*(z)}{Q^{\le t}(z \mid x)}
\,
dQ^{\le t}(z \mid x)\, dP^*(x)
=
H(Z \mid X) - H(Z).
$$

它形式上类似 mutual information 的负值：

$$
-C_t = I(X;Z),
$$

但作者为了避免测度论细节，不直接把它叫 mutual information。

### 5.3 引入 latent model 后的 min-max 目标
为了让 latent descriptions 不只是有效，还要足够 regular、可学习，作者再引入一个 latent model

$$
P \in \mathcal P(\Omega^\omega)
$$

去拟合 induced prior $Q_{\le \omega}^*$。

这时 $C_t$ 可重写为

$$
C_t
=
\max_{P \in \mathcal P(\Omega^\omega)}
\int
\log \frac{P^{\le t}(z)}{Q^{\le t}(z \mid x)}
\,
dQ^{\le t}(z \mid x)\, dP^*(x),
$$

即论文式 (95)。

最终总目标为

$$
\min_{Q \in \mathcal Q^{+1}}
\sum_{t=0}^\infty C_t
=
\min_Q \max_P
\sum_{t=0}^\infty
\int
\log \frac{P^{\le t}(z_{\le t})}
{Q^{\le t}(z_{\le t} \mid x)}
\,
dQ^{\le \omega}(z \mid x)\, dP^*(x).
$$

这就是式 (96)。

它的解释是：
- $Q$ 要主动选择 latent description，使信息尽快进入系统；
- $P$ 要把这些 descriptions 学成一套稳定、可预测的“语言”。

### 5.4 为什么这会导向 projection 的出现
这一步是本文最关键、也最需要保留审慎态度的地方。

Remark 24 给出如下论证思路：若 $(Q,P)$ 是全局最优，并额外满足一些技术假设，则几乎处处有

$$
P^*(\cdot \mid z) = \delta_{\mathrm{Proj}(z)}.
$$

一旦成立，就意味着每个无限 latent sequence $z$ 最终唯一对应一个 observable sample，于是“投影”

$$
\mathrm{Proj} : \Omega^\omega \to X
$$

不是事先给定的，而是从最优目标中涌现出来。

这时原来的静态模型

$$
P_{\text{obs}} = \mathrm{Proj}_\# P
$$

就被重新得到；而 active lifting 则成为比 static lifting 更一般的框架。

这里必须明确：
- 这个结论在论文中不是封闭的严格大定理；
- 它依赖于作者在 Remark 24 中给出的 `informal argument` 与若干合理假设；
- 但它确实给出了“slow thinking 是 active perception 特例”的核心数学桥梁。

## 6. 为什么 slow thinking 是 active lifting 的静态子空间
现在可以把前两部分接起来。

在 static theory 里：
- 先手工给定一个 projection $\mathrm{Proj}$；
- 再由它诱导 lifting $\mathrm{Proj}^{-1}_{<\omega}$；
- 再在这个 lifting 上做 posterior sampling 与训练。

在 active lifting 里：
- sampler $Q$ 是自由变量；
- latent prior $P$ 由训练出来；
- projection 是由最优结构隐式涌现。

所以论文认为：

$$
\text{static slow thinking}
=
\text{active lifting 的一个受限子类},
$$

其中“受限”体现在：
- projection 被预先固定；
- latent format 被人工指定；
- 推理空间不是自由形成的，而是限定在某种 thought-template 里。

## 7. 现有 reasoning LLM 在这个框架里的位置
第 5 节用一个很具体的 `pause-to-think` projection，把 DeepSeek-R1 类模型嵌入进来。

令

$$
\Omega = \Sigma \cup \{\langle s\rangle, \langle /s\rangle\},
$$

其中 thought span 形如

$$
\langle s\rangle y \langle /s\rangle.
$$

latent 序列写成

$$
z = (y^{(t)} x_t)_{t=1}^{|x|},
\qquad
y^{(t)} \in T,
$$

projection 只保留可见 token：

$$
\mathrm{Proj}\big((y^{(t)}x_t)_t\big) = (x_t)_t.
$$

于是 lifting 为

$$
\mathrm{Proj}^{-1}_{<\omega}(x)
=
\left\{
(y^{(t)}x_t)_{t=1}^{|x|}
\mid
y^{(t)} \in T
\right\}.
$$

这说明现有 CoT / pause-to-think 模型本质上是在做：  
对所有可能的 thought insertion 轨迹做 latent marginalization。

### Forgetful latent
作者进一步定义 `forgetful latent`：若后续 thought 的分布只依赖 observable context，而不依赖更早的 thought 内容，则称 latent 是 forgetful 的。

这解释了现有推理模型常见的一个实现习惯：
- 旧 thought 不持久保存；
- 新一轮推理主要重新编码 observable context。

这在工程上便宜，但也限制了表示能力，因此作者把它视为现有 slow thinking 模型在 representation hierarchy 上的低位点。

## 8. 工程后果：三阶段升级路径
这一部分虽然不是主定理，但和前面的数学推导关系非常紧密。

### Stage 1
沿 sampler hierarchy 往上爬：
- 从 identity / predictive sampler 走向 explanatory sampler；
- 目标是减小

$$
\chi^2(Q^* \,\|\, Q)
\quad \text{和} \quad
\chi^2(\overline{Q} \,\|\, \overline{Q}).
$$

### Stage 2
沿 representation hierarchy 往上爬：
- 从 forgetful latent 走向 persistent and ubiquitous thinking；
- 提高逼近能力，而不只是提高采样效率。

### Stage 3
进入 active lifting：
- 不再手工规定 thought format；
- 让 latent language 从目标函数中自发长出来。

## 9. 初步实验
论文只给了一个 Stage 1 的初步实验，不足以单独支撑整套理论，但和理论方向是一致的。

实验设置：
- base model：Qwen2.5-7B base；
- data：OpenWebMath；
- methods：SFT、predictive-sampler RL、explanatory-sampler RL；
- sample size：$n = 8$。

报告的相对增益为

$$
\frac{L_{\text{fast}} - L_{\text{expl}}}
{L_{\text{fast}} - L_{\text{pred}}}
- 1
\approx 264\%.
$$

作者还定义了 `causal gap` 指标，实验证据支持 explanatory sampler 的确捕捉到了 response 相关、但因果 sampler 拿不到的信息。

## 10. 这篇论文到底哪里严格，哪里不严格
这是读这篇文章最重要的元判断。

### 相对严格的部分
- Transformer expressivity 的复杂度论限制；
- projection / lifting / next-segment map 的定义与性质；
- observable likelihood 对 latent prefix 的边缘化公式；
- posterior sampler、importance sampling variance；
- inquisitive sampler 的推导；
- sampler hierarchy 与非因果性结论；
- $\chi^2 / n$ 型 slow thinking scaling laws。

### 相对 heuristic 的部分
- unified objective 如何“自然”导出整个 static theory；
- active lifting 的全局目标为何一定诱导 deterministic projection；
- minimum-length regular coding 与“语言发明”的关系；
- 视觉 schema、object/part、diffusion 统一等外推。

### 我的判断
这篇论文最值得信的不是“所有远景都已被证明”，而是下面这条中间强结论：

$$
\text{一旦把 reasoning 看成 latent explanation 的边缘化问题，}
$$

那么：
- 为什么要 slow thinking；
- 为什么要采样；
- 为什么 sampler 质量决定 test-time efficiency；
- 为什么训练与推理的最优策略不同；
- 为什么单向因果 CoT 往往不是最优；

这些现象都能被放进一个共同数学框架里。

## Notes
- 这篇论文最有价值的部分，不是“提出了一个新 prompt format”，而是把 `reasoning = latent marginalization` 这件事系统写清楚了。
- 如果只想抓最重要的数学主线，应优先看第 2.6 节、Theorem 7、第 3.4.2 节的 inquisitive sampler、Theorem 15 / Proposition 16、以及第 6.2 节的式 (93)(95)(96)。
- 如果只关心“慢思考是否能被解释成更一般的主动感知/潜变量推理过程”，简短答案是：可以，而且论文给出了一条比较完整的推导链；但从 unified objective 到 projection emergence 的最后一步，目前还不是完全封闭的严格证明。

## 阅读前置
如果目标是“真正读懂正文主线”，而不是只看概念摘要，那么建议把前置知识分成三层。

### 一、必须掌握
这些内容不熟的话，正文会非常吃力。

1. 概率论与条件分布
需要熟悉：
- 随机变量与条件概率
- 边缘分布与联合分布
- 贝叶斯公式
- 条件期望
- 马尔可夫链与 HMM

在这篇论文里，它们分别对应：
- observable / latent 的联合建模
- posterior sampler $Q^*(z \mid x)$
- 用 latent 边缘化得到 observable likelihood

2. 信息论基本量
需要熟悉：
- entropy
- cross-entropy
- KL divergence
- $\chi^2$ divergence
- mutual information 的直觉

在这篇论文里，它们分别对应：
- 训练目标
- 采样误差
- 第 6 节的不确定性下降目标

3. Monte Carlo 与重要性采样
需要熟悉：
- importance sampling
- 无偏估计 / 有偏估计
- 方差为什么由 proposal quality 控制
- 采样数 $n$ 增大时误差如何缩放

在这篇论文里，这一层直接对应第 3 节的主线。

### 二、边读边补
这些内容最好有基础，但不一定要在开始前全补完。

1. 测度论语言
至少要能接受并大致理解这些对象：
- Borel probability measure
- pushforward measure
- conditional measure
- Radon-Nikodym derivative
- disintegration theorem

你不一定要自己重证明，但要知道它们分别在干什么：
- `pushforward`：解释 $\mathrm{Proj}_\# P$
- `conditional measure`：解释 posterior
- `Radon-Nikodym derivative`：解释第 6 节的密度写法
- `disintegration`：解释 lifted distribution 的分解

2. 统计学习中的梯度估计
需要熟悉：
- score function / log-derivative trick
- policy gradient 的基本形式
- 为什么训练时“高概率样本”不一定是“高信息样本”

这一层对应 inquisitive sampler：

$$
\overline{Q}(z \mid x)
\propto
P_f^{\le |z|}(z)
\left\|
\nabla_\theta \log P_f^{\le |z|}(z)
\right\|.
$$

### 三、可暂时跳过
这些会帮助你读得更彻底，但不是一开始的瓶颈。

1. 电路复杂度
包括：
- $\mathrm{TC}^0$、$\mathrm{NC}^1$
- bounded-depth circuit
- uniformity
- 为什么 Transformer 可被刻画成某类电路

这一块主要用于理解第 2 节“plain Transformer 为什么表达受限”。如果现在不熟，可以先接受结论，晚点再回头补。

2. 附录里的测度论与复杂度证明细节
正文主线先读通，再啃附录更划算。

## 最低阅读路线
如果想用最小投入先读懂主线，建议按下面顺序：

1. 先会这些概念
- 条件分布
- 边缘化
- HMM
- KL divergence
- $\chi^2$ divergence
- importance sampling

2. 再读正文这些位置
- 第 2.6 节：projection / lifting
- Theorem 7：observable likelihood 的 latent 边缘化公式
- 第 3.4.2 节：inquisitive sampler
- Theorem 15 / Proposition 16：为什么最优 sampler 一般不是 causal 的
- 第 6.2 节：式 (93)(95)(96)

3. 最后再决定是否补这些
- 电路复杂度
- 附录证明
- 第 6.3 以后关于 minimum-length coding 和视觉表示的外推

## 一句话判断
如果你现在已经熟悉：
- 概率图模型 / HMM
- importance sampling
- KL 与 cross-entropy
- LLM 训练里的 policy gradient 直觉

那你已经能读懂这篇文章的大部分主线。

如果还想真正吃透第 2 节和第 6 节的技术细节，再补：
- 测度论语言
- 电路复杂度语言

## 相关链接（双向）
- [[慢思考与主动感知-研究地图]]
