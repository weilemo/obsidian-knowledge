# 08_P1-Ch5 收敛、特征函数、大数定律与中心极限定理（教材补充讲义）

> 对应材料：`chapter 5.pdf`  
> 定位：第 8、9 讲的教材式补充。它把收敛、特征函数、LLN、CLT 的证明链条讲得更完整。

## 1. 这份教材补充解决什么问题

课件通常讲主线：定义、公式、例子。教材补充更像把背后的逻辑补全：

1. 为什么依概率收敛这样定义；
2. 为什么依分布收敛只看连续点；
3. 为什么特征函数能决定分布；
4. 为什么大数定律可以由 Chebyshev 不等式推出；
5. 为什么中心极限定理可以用特征函数证明。

这一章的核心是两个字：极限。

大数定律回答“平均值是否稳定”；中心极限定理回答“稳定后的误差形状是什么”。

---

## 2. 依概率收敛：坏事件概率消失

定义：

$$
X_n\xrightarrow{P}X
\Longleftrightarrow
\forall \varepsilon>0,\ P(|X_n-X|\ge \varepsilon)\to 0.
$$

这里的意思不是每个样本点都越来越接近，而是误差超过 $\varepsilon$ 的那些样本点组成的事件，其概率越来越小。

等价地，

$$
P(|X_n-X|<\varepsilon)\to 1.
$$

### 2.1 四则运算为什么成立

若

$$
X_n\xrightarrow{P}a,\qquad Y_n\xrightarrow{P}b,
$$

则

$$
X_n+Y_n\xrightarrow{P}a+b.
$$

证明的关键是三角不等式。若

$$
|X_n-a|<\frac{\varepsilon}{2},
\qquad
|Y_n-b|<\frac{\varepsilon}{2},
$$

则

$$
|(X_n+Y_n)-(a+b)|
\le |X_n-a|+|Y_n-b|
<\varepsilon.
$$

因此坏事件满足包含关系：

$$
\{|(X_n+Y_n)-(a+b)|\ge \varepsilon\}
\subset
\left\{|X_n-a|\ge \frac{\varepsilon}{2}\right\}
\cup
\left\{|Y_n-b|\ge \frac{\varepsilon}{2}\right\}.
$$

于是

$$
P(|(X_n+Y_n)-(a+b)|\ge \varepsilon)
\le
P\left(|X_n-a|\ge \frac{\varepsilon}{2}\right)
+
P\left(|Y_n-b|\ge \frac{\varepsilon}{2}\right)
\to 0.
$$

乘法和除法也是类似思想，只是需要先控制变量不要跑得太远。

---

## 3. 依分布收敛：分布函数形状靠近

定义：

$$
X_n\xrightarrow{L}X
$$

表示

$$
F_{X_n}(x)\to F_X(x)
$$

对所有 $F_X$ 的连续点成立。

为什么只要求连续点？教材给了一个很好的例子：

$$
P\left(X_n=\frac1n\right)=1.
$$

显然 $X_n$ 应该趋向常数 $0$。但它的分布函数在 $0$ 附近会出现跳跃点问题。如果强行要求所有点逐点收敛，极限可能不是一个右连续的分布函数。

所以依分布收敛只要求在极限分布函数的连续点上收敛。

重要关系：

$$
X_n\xrightarrow{P}X\Longrightarrow X_n\xrightarrow{L}X.
$$

如果极限是常数 $c$，则反过来也成立：

$$
X_n\xrightarrow{L}c\Longleftrightarrow X_n\xrightarrow{P}c.
$$

---

## 4. 特征函数：分布的 Fourier 编码

定义：

$$
\varphi_X(t)=\mathbb E[e^{itX}].
$$

离散型：

$$
\varphi_X(t)=\sum_k e^{itx_k}P(X=x_k).
$$

连续型：

$$
\varphi_X(t)=\int_{-\infty}^{+\infty}e^{itx}p(x)\,dx.
$$

特征函数总存在，因为

$$
|e^{itX}|=1.
$$

### 4.1 基本性质

$$
|\varphi_X(t)|\le 1,\qquad \varphi_X(0)=1.
$$

$$
\varphi_X(-t)=\overline{\varphi_X(t)}.
$$

若 $Y=aX+b$，

$$
\varphi_Y(t)=e^{ibt}\varphi_X(at).
$$

若 $X,Y$ 独立，

$$
\varphi_{X+Y}(t)=\varphi_X(t)\varphi_Y(t).
$$

若 $\mathbb E[|X|^l]<\infty$，则

$$
\varphi_X^{(k)}(0)=i^k\mathbb E[X^k],
\qquad 1\le k\le l.
$$

特别地，

$$
\mathbb E[X]=\frac{\varphi_X'(0)}{i},
$$

$$
\mathrm{Var}(X)=-\varphi_X''(0)+(\varphi_X'(0))^2.
$$

这里 $(\varphi_X'(0))^2$ 通常是负的，因为 $\varphi_X'(0)=i\mathbb E[X]$。

### 4.2 常见特征函数

Bernoulli$(p)$：

$$
\varphi(t)=1-p+pe^{it}.
$$

Poisson$(\lambda)$：

$$
\varphi(t)=\exp(\lambda(e^{it}-1)).
$$

Binomial$(n,p)$：

$$
\varphi(t)=(1-p+pe^{it})^n.
$$

Normal$(\mu,\sigma^2)$：

$$
\varphi(t)=\exp\left(i\mu t-\frac{\sigma^2t^2}{2}\right).
$$

Exponential$(\lambda)$：

$$
\varphi(t)=\left(1-\frac{it}{\lambda}\right)^{-1}.
$$

Gamma$(\alpha,\lambda)$：

$$
\varphi(t)=\left(1-\frac{it}{\lambda}\right)^{-\alpha}.
$$

---

## 5. 特征函数为什么能唯一决定分布

教材这里补了反演公式。若 $x_1<x_2$ 是分布函数 $F$ 的连续点，则

$$
F(x_2)-F(x_1)
=
\lim_{T\to\infty}\frac{1}{2\pi}
\int_{-T}^{T}
\frac{e^{-itx_1}-e^{-itx_2}}{it}\varphi(t)\,dt.
$$

这说明只要知道 $\varphi(t)$，就能恢复任意区间概率。

因此特征函数唯一决定分布。

若 $X$ 有密度 $p$，且 $\varphi$ 可积，则有更直接的反演：

$$
p(x)=\frac{1}{2\pi}\int_{-\infty}^{+\infty}e^{-itx}\varphi(t)\,dt.
$$

这就是 Fourier 反变换。

### 5.1 Lévy 连续性定理

特征函数还可以判断分布收敛：

$$
X_n\xrightarrow{L}X
$$

当且仅当

$$
\varphi_{X_n}(t)\to \varphi_X(t)
$$

对所有 $t$ 成立。

这条定理是用特征函数证明 CLT 的关键。

---

## 6. 大数定律的几个版本

### 6.0 预备工具：Chebyshev 不等式

Chebyshev 不等式说：若随机变量 $X$ 有有限期望和有限方差，则对任意 $\varepsilon>0$，

$$
P(|X-\mathbb E[X]|\ge \varepsilon)
\le
\frac{\mathrm{Var}(X)}{\varepsilon^2}.
$$

它的意义是：如果方差很小，那么 $X$ 离均值很远的概率就必须很小。

#### 证明

令

$$
Y=(X-\mathbb E[X])^2.
$$

则 $Y$ 是非负随机变量，并且

$$
\mathbb E[Y]=\mathbb E[(X-\mathbb E[X])^2]=\mathrm{Var}(X).
$$

注意事件

$$
|X-\mathbb E[X]|\ge \varepsilon
$$

等价于

$$
(X-\mathbb E[X])^2\ge \varepsilon^2,
$$

也就是

$$
Y\ge \varepsilon^2.
$$

对非负随机变量 $Y$ 使用 Markov 不等式：

$$
P(Y\ge a)\le \frac{\mathbb E[Y]}{a},\qquad a>0.
$$

取

$$
a=\varepsilon^2,
$$

得到

$$
P(Y\ge \varepsilon^2)
\le
\frac{\mathbb E[Y]}{\varepsilon^2}.
$$

代回 $Y=(X-\mathbb E[X])^2$：

$$
P((X-\mathbb E[X])^2\ge \varepsilon^2)
\le
\frac{\mathbb E[(X-\mathbb E[X])^2]}{\varepsilon^2}.
$$

也就是

$$
P(|X-\mathbb E[X]|\ge \varepsilon)
\le
\frac{\mathrm{Var}(X)}{\varepsilon^2}.
$$

这就证明了 Chebyshev 不等式。

#### Markov 不等式为什么成立

上面用到的 Markov 不等式也可以一行证明。若 $Y\ge 0$，则在事件 $\{Y\ge a\}$ 上有 $Y\ge a$，所以

$$
\mathbb E[Y]
\ge
\mathbb E[Y\mathbf 1_{\{Y\ge a\}}]
\ge
aP(Y\ge a).
$$

因此

$$
P(Y\ge a)\le \frac{\mathbb E[Y]}{a}.
$$

所以 Chebyshev 不等式本质上就是把 Markov 不等式用在平方偏差

$$
(X-\mathbb E[X])^2
$$

上。

### 6.1 Bernoulli 大数定律

若 $S_n$ 是 $n$ 次 Bernoulli 试验中事件 $A$ 出现次数，$P(A)=p$，则

$$
\frac{S_n}{n}\xrightarrow{P}p.
$$

证明用 Chebyshev：

$$
\mathbb E\left[\frac{S_n}{n}\right]=p,
\qquad
\mathrm{Var}\left(\frac{S_n}{n}\right)=\frac{p(1-p)}{n}.
$$

所以

$$
P\left(\left|\frac{S_n}{n}-p\right|\ge \varepsilon\right)
\le
\frac{p(1-p)}{n\varepsilon^2}\to 0.
$$

### 6.2 Chebyshev 大数定律

若 $X_i$ 两两不相关，且

$$
\mathrm{Var}(X_i)\le c,
$$

则

$$
\frac1n\sum_{i=1}^{n}X_i
-
\frac1n\sum_{i=1}^{n}\mathbb E[X_i]
\xrightarrow{P}0.
$$

证明核心：

$$
\mathrm{Var}\left(\frac1n\sum_{i=1}^{n}X_i\right)
=\frac{1}{n^2}\sum_{i=1}^{n}\mathrm{Var}(X_i)
\le \frac{c}{n}.
$$

再用 Chebyshev 即可。

### 6.3 Markov 大数定律条件

只要

$$
\frac{1}{n^2}\mathrm{Var}\left(\sum_{i=1}^{n}X_i\right)\to 0,
$$

就有

$$
\frac{\sum_{i=1}^{n}X_i-\mathbb E[\sum_{i=1}^{n}X_i]}{n}\xrightarrow{P}0.
$$

这比 Chebyshev 版本更抽象，因为它直接抓住真正需要的方差条件。

### 6.4 Khintchine 大数定律

若 $X_i$ 独立同分布，且 $\mathbb E[X_i]=\mu$ 存在，则

$$
\frac1n\sum_{i=1}^{n}X_i\xrightarrow{P}\mu.
$$

它不要求方差有限，这是比 Chebyshev 大数定律更强的地方。

---

## 7. 中心极限定理

设 $X_i$ 独立同分布，且

$$
\mathbb E[X_i]=\mu,\qquad \mathrm{Var}(X_i)=\sigma^2>0.
$$

则

$$
\frac{X_1+\cdots+X_n-n\mu}{\sigma\sqrt n}
\xrightarrow{L}N(0,1).
$$

### 7.1 特征函数证明主线

令

$$
Y_i=X_i-\mu.
$$

设 $Y_i$ 的特征函数为 $\varphi(t)$。由于

$$
\mathbb E[Y_i]=0,\qquad \mathrm{Var}(Y_i)=\sigma^2,
$$

所以在 $0$ 附近

$$
\varphi(t)=1-\frac{\sigma^2t^2}{2}+o(t^2).
$$

标准化和的特征函数为

$$
\left[\varphi\left(\frac{t}{\sigma\sqrt n}\right)\right]^n.
$$

代入展开：

$$
\varphi\left(\frac{t}{\sigma\sqrt n}\right)
=1-\frac{t^2}{2n}+o\left(\frac1n\right).
$$

因此

$$
\left[1-\frac{t^2}{2n}+o\left(\frac1n\right)\right]^n
\to e^{-t^2/2}.
$$

而 $e^{-t^2/2}$ 是 $N(0,1)$ 的特征函数。由 Lévy 连续性定理，CLT 得证。

---

## 8. 二项分布的正态近似

若 $S_n\sim \mathrm{Bin}(n,p)$，则

$$
\frac{S_n-np}{\sqrt{np(1-p)}}\xrightarrow{L}N(0,1).
$$

这是 de Moivre-Laplace 定理。

实际应用中要注意连续性修正：

$$
P(a\le S_n\le b)
\approx
\Phi\left(\frac{b+0.5-np}{\sqrt{np(1-p)}}\right)
-
\Phi\left(\frac{a-0.5-np}{\sqrt{np(1-p)}}\right).
$$

常见三类题：

1. 已知阈值，求概率；
2. 已知概率，求阈值；
3. 已知误差和置信度，求样本量。

---

## 9. 非同分布情形的 CLT

教材最后给出 Lindeberg 与 Lyapunov 条件。

设 $X_i$ 独立但不一定同分布，

$$
\mu_i=\mathbb E[X_i],\qquad \sigma_i^2=\mathrm{Var}(X_i),
$$

并令

$$
B_n^2=\sum_{i=1}^{n}\sigma_i^2.
$$

若满足 Lindeberg 条件：

$$
\forall \tau>0,\quad
\frac{1}{B_n^2}\sum_{i=1}^{n}
\mathbb E\left[(X_i-\mu_i)^2
\mathbf 1_{\{|X_i-\mu_i|>\tau B_n\}}\right]\to 0,
$$

则

$$
\frac{\sum_{i=1}^{n}(X_i-\mu_i)}{B_n}
\xrightarrow{L}N(0,1).
$$

Lyapunov 条件是更容易检查的充分条件：若存在 $\delta>0$，使得

$$
\frac{1}{B_n^{2+\delta}}
\sum_{i=1}^{n}\mathbb E[|X_i-\mu_i|^{2+\delta}]
\to 0,
$$

则 Lindeberg 条件成立。

这部分考试通常不会像基础 CLT 那样高频，但它说明 CLT 不只适用于独立同分布情形。

---

## 10. 复习路线

先掌握收敛：

$$
X_n\xrightarrow{P}X,\qquad X_n\xrightarrow{L}X.
$$

再掌握特征函数：

$$
\varphi_X(t)=\mathbb E[e^{itX}].
$$

然后把 LLN 和 CLT 分清：

- LLN：平均值趋近常数；
- CLT：标准化误差趋近正态。

最后用题目训练三件事：Chebyshev 放缩、CLT 标准化、二项分布连续性修正。
