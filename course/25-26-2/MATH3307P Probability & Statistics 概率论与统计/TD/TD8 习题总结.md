21# TD8 习题总结（Probability, 2026-04-23）

题目来源：`/Users/moweile/Obsidian/Knowledge/Course/25-26-2/MATH3307P Probability & Statistics 概率论与统计/TD/TD8.pdf`

说明：按 `agent.md` 规范，关键公式均说明来源与适用条件，并给出必要推导。

## Ex1 期望与方差的存在性与计算

公式来源（非负随机变量）：

$$
\mathbb E[X]=\int_0^\infty (1-F_X(t))\,dt,\qquad
\mathbb E[X^2]=2\int_0^\infty t(1-F_X(t))\,dt.
$$

若给的是密度，也可用

$$
\mathbb E[X]=\int x f(x)\,dx,\quad \mathbb E[X^2]=\int x^2 f(x)\,dx,\quad
\mathrm{Var}(X)=\mathbb E[X^2]-\mathbb E[X]^2.
$$

术语说明（本题里建议这样区分）：
- `定义良好`：给定的 $F_X$ / $f_X$ 能否对应一个合法随机变量分布（CDF/密度条件是否成立）。
- `可积`：$\mathbb E|X|<\infty$（对非负变量就是 $\mathbb E[X]<\infty$）。
- `二阶可积`：$\mathbb E[X^2]<\infty$（方差存在还需再减去均值平方）。

密度函数 `定义良好` 的判定（连续型）：
- 非负性：$f_X(x)\ge 0$（几乎处处）。
- 归一化：$\int_{-\infty}^{+\infty} f_X(x)\,dx=1$。
- 满足后可定义分布函数

$$
F_X(x)=\int_{-\infty}^{x} f_X(t)\,dt,
$$

从而对应一个合法随机变量分布。

### (a) $F_X(x)=1-e^{-\lambda x},\ x\ge0$
这是参数 $\lambda$ 的指数分布：

$$
\mathbb E[X]=\frac1\lambda,\qquad
\mathrm{Var}(X)=\frac1{\lambda^2}.
$$

`定义良好` 证明（验证 CDF 四条性质）：

$$
F_X(x)=
\begin{cases}
0, & x<0,\\
1-e^{-\lambda x}, & x\ge0,\ \lambda>0.
\end{cases}
$$

1. 单调不减：在 $x\ge0$ 上

$$
F'_X(x)=\lambda e^{-\lambda x}>0,
$$

且与 $x<0$ 的常数段 0 拼接后仍单调不减。  
2. 右连续：分段内连续；在 $0$ 点

$$
\lim_{x\downarrow0}(1-e^{-\lambda x})=0=F_X(0).
$$

3. 左端极限：

$$
\lim_{x\to-\infty}F_X(x)=0.
$$

4. 右端极限：

$$
\lim_{x\to+\infty}F_X(x)=1-e^{-\lambda x}=1.
$$

故 $F_X$ 是合法分布函数，随机变量定义良好。

结论：定义良好，可积（$\mathbb E|X|<\infty$）。

### (b) $f_X(x)=\frac14 x e^{-x/2},\ x\ge0$
这是 Gamma 分布（shape $2$, scale $2$）：

`定义良好` 证明（按密度判定两条件）：

1. 非负性：对 $x\ge0$，有 $x\ge0,\ e^{-x/2}>0$，故

$$
f_X(x)=\frac14 x e^{-x/2}\ge0.
$$

2. 归一化：

$$
\int_{-\infty}^{+\infty}f_X(x)\,dx=\int_0^\infty \frac14 x e^{-x/2}\,dx.
$$

令 $u=x/2$（即 $x=2u,\ dx=2du$），则

$$
\int_0^\infty \frac14 x e^{-x/2}\,dx
=\int_0^\infty u e^{-u}\,du
=\Gamma(2)=1.
$$

因此该密度定义良好。

$$
\mathbb E[X]=4,\qquad \mathrm{Var}(X)=8.
$$

结论：定义良好，可积且二阶可积。

### (c) $F_X(x)=\frac{x}{x+1},\ x\ge0$
生存函数

$$
1-F_X(x)=\frac1{x+1}.
$$

于是

$$
\mathbb E[X]=\int_0^\infty \frac{1}{x+1}\,dx=+\infty.
$$

结论：随机变量定义良好，但不可积，因此期望、方差都不存在（发散）。

### (d) $F_X(x)=\frac{x^2+1}{x^2+2},\ x\ge0$
生存函数

$$
1-F_X(x)=\frac1{x^2+2}.
$$

所以

$$
\mathbb E[X]=\int_0^\infty \frac{1}{x^2+2}\,dx
=\frac{\pi}{2\sqrt2}<\infty.
$$

但

$$
\mathbb E[X^2]=2\int_0^\infty \frac{x}{x^2+2}\,dx=+\infty.
$$

结论：可积但不二阶可积，方差不存在（无穷大）。

---

## Ex2 Cauchy 分布是否有期望/方差
密度：

$$
f(x)=\frac1\pi\frac1{1+x^2},\quad x\in\mathbb R.
$$

检查期望需看

$$
\int_{\mathbb R}|x|f(x)\,dx.
$$

当 $|x|\to\infty$ 时，$|x|f(x)\sim \frac1{|x|}$，积分发散。

结论：$\mathbb E[X]$ 不存在（主值可为 0，但不是期望），方差也不存在。

---

## Ex3 热水器“到 $m$ 年强制更换”模型
设原寿命 $X\sim\mathrm{Exp}(\lambda)$，客户实际使用寿命

$$
T=\min(X,m).
$$

公式来源（非负变量截断）：

$$
\mathbb E[T]=\int_0^m P(X>t)\,dt,\qquad
\mathbb E[T^2]=2\int_0^m t\,P(X>t)\,dt.
$$

因 $P(X>t)=e^{-\lambda t}$：

$$
\mathbb E[T]=\int_0^m e^{-\lambda t}dt
=\frac{1-e^{-\lambda m}}{\lambda}.
$$

再算二阶矩：

$$
\mathbb E[T^2]
=2\int_0^m t e^{-\lambda t}dt
=\frac{2}{\lambda^2}\Bigl(1-e^{-\lambda m}(1+\lambda m)\Bigr).
$$

故

$$
\mathrm{Var}(T)=\mathbb E[T^2]-\mathbb E[T]^2
=\frac{1-2\lambda m e^{-\lambda m}-e^{-2\lambda m}}{\lambda^2}.
$$

---

## Ex4 最大值、最小值与极限分布
给定 $X_0,\dots,X_n$ 相互独立且 $X_i\sim U(0,n)$。另有 $Y\sim B(n,p)$，且与所有 $X_i$ 独立。

定义

$$
Y_n=\max(X_0,\dots,X_n),\quad
Z_n=\min(X_0,\dots,X_n),\quad
T_n=\min(X_0,\dots,X_n,Y).
$$

### (a) $Y_n$ 的分布、期望、方差
对 $0\le t\le n$：

$$
F_{Y_n}(t)=P(Y_n\le t)=\prod_{i=0}^n P(X_i\le t)=\left(\frac{t}{n}\right)^{n+1}.
$$

密度

$$
f_{Y_n}(t)=\frac{n+1}{n^{n+1}}t^n,\quad 0<t<n.
$$

把 $Y_n/n$ 看作 $n+1$ 个 $U(0,1)$ 的最大值，可得

$$
\mathbb E[Y_n]=\frac{n(n+1)}{n+2},
$$

$$
\mathrm{Var}(Y_n)=\frac{n^2(n+1)}{(n+2)^2(n+3)}.
$$

### (b) $Z_n$ 的分布函数
对 $0\le t\le n$：

$$
P(Z_n>t)=\prod_{i=0}^n P(X_i>t)=\left(1-\frac{t}{n}\right)^{n+1},
$$

所以

$$
F_{Z_n}(t)=1-\left(1-\frac{t}{n}\right)^{n+1}.
$$

并补充边界：

$$
F_{Z_n}(t)=0\ (t<0),\qquad F_{Z_n}(t)=1\ (t\ge n).
$$

### (c) $\lim_{n\to\infty}F_{Z_n}(t)$
固定 $t\in\mathbb R$：

$$
\left(1-\frac{t}{n}\right)^{n+1}\to e^{-t}\quad (t\ge0).
$$

故极限分布为

$$
\lim_{n\to\infty}F_{Z_n}(t)=
\begin{cases}
0, & t<0,\\
1-e^{-t}, & t\ge0.
\end{cases}
$$

即极限是 $\mathrm{Exp}(1)$。

### (d) $T_n$ 的分布函数
利用独立性：

$$
P(T_n>t)=P(Z_n>t,\ Y>t)=P(Z_n>t)\,P(Y>t).
$$

因此

$$
F_{T_n}(t)=1-\bigl(1-F_{Z_n}(t)\bigr)\bigl(1-F_Y(t)\bigr).
$$

这里 $F_Y$ 是二项分布 $B(n,p)$ 的分布函数。

### (e) $\lim_{n\to\infty}F_{T_n}(t)$
对固定 $t\ge0$，有 $Y\sim B(n,p)$ 且 $np\to\infty$，故 $P(Y\le t)\to0$，即 $P(Y>t)\to1$。

所以

$$
P(T_n>t)\to e^{-t},
$$

从而

$$
\lim_{n\to\infty}F_{T_n}(t)=
\begin{cases}
0, & t<0,\\
1-e^{-t}, & t\ge0.
\end{cases}
$$

---

## Ex5 单检 vs 混检：哪种更省测试次数
设总人数 $n$，每人阳性概率 $p$，独立。每组 $k$ 人（先假设 $k\mid n$）。

### 单检

$$
N_{\text{single}}=n.
$$

### 混检（两阶段 Dorfman）
每组总是先做 1 次组检；若组阳性（概率 $1-(1-p)^k$）再做 $k$ 次个检。

每组期望检测次数：

$$
\mathbb E[N_{\text{group}}]=1+k\bigl(1-(1-p)^k\bigr).
$$

总共有 $n/k$ 组：

$$
\mathbb E[N_{\text{pool}}]
=\frac{n}{k}\left[1+k\bigl(1-(1-p)^k\bigr)\right]
=n\left(\frac1k+1-(1-p)^k\right).
$$

因此混检更经济当且仅当

$$
\frac1k+1-(1-p)^k<1
\iff
\frac1k<(1-p)^k.
$$

结论：
- 当 $p$ 较小且 $k$ 选得合适时，混检明显节省检测次数；
- 当 $p$ 较大时，组阳性概率高，混检优势减弱甚至不如单检。
