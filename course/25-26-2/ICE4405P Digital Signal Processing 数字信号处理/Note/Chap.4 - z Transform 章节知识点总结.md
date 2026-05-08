# Chap.4 z-Transform 章节知识点总结（按 PPT 章节顺序重写）

> 课程：ICE4405P Digital Signal Processing  
> 讲义：`PPT/Chap.4-zTransform.pdf`（82 页）  
> 目录顺序：`4.1 -> 4.2 -> 4.3 -> 4.4 -> 4.5 -> 4.6`

---

## 0. 本章总目标（先抓主线）

本章核心是三件事：

1. 用 Z 变换把“序列 + 系统”放到复平面统一分析。  
2. 用 ROC 把“同一代数式对应不同时间序列”区分开。  
3. 通过极点、ROC、单位圆，统一判断因果性、稳定性、频率响应。

本章最重要的判断链：

$$
\text{时域支撑} \Longleftrightarrow \text{ROC 位置} \Longleftrightarrow \text{稳定/因果} \Longleftrightarrow \text{是否含单位圆}
$$

---

## 1. 4.1 Introduction（P3）

### 1.1 章节定位

- Z 变换是离散时间系统里对应于拉普拉斯变换的核心工具。  
- 用于求解 LCCDE（线性常系数差分方程）和分析系统性质。

### 1.2 本节重点

- 不要把 Z 变换只当成“公式变换”，它是“系统行为判定工具”。  
- 后续所有结论都围绕：极点、ROC、单位圆。

---

## 2. 4.2 The Bilateral z-Transform（P4-P18）

## 2.1 双边 Z 变换定义（P4）

$$
X(z)=\sum_{n=-\infty}^{\infty}x[n]z^{-n},\quad z\in\mathbb{C}
$$

单边（单侧）定义：

$$
X_u(z)=\sum_{n=0}^{\infty}x[n]z^{-n}
$$

### 重点

- 本章默认以双边 Z 变换为主。  
- 双边更适合讨论 ROC、左/右/双边序列。

## 2.2 与 DTFT 的关系（P5-P6）

令

$$
z=re^{j\omega}
$$

则

$$
X(re^{j\omega})=\sum_{n=-\infty}^{\infty}(x[n]r^{-n})e^{-j\omega n}
$$

即：它是加权序列 $x[n]r^{-n}$ 的 DTFT。特别地，当 $r=1$：

$$
X(e^{j\omega})=X(z)\big|_{|z|=1}
$$

### 重点

- DTFT 是 Z 变换在单位圆上的“切片”。  
- 所以“频率响应是否存在”取决于单位圆是否落在 ROC 内。

## 2.3 4.2.1 收敛与 ROC（P7-P15）

绝对收敛条件：

$$
\sum_{n=-\infty}^{\infty}|x[n]z^{-n}|<\infty
$$

ROC 通常为环域：

$$
r_1<|z|<r_2
$$

且对有理型 $X(z)=N(z)/D(z)$：极点来自 $D(z)=0$，ROC 不含极点。

### 2.3.1 最关键例子（必须会）

`例 4.1` 右边指数：

$$
x[n]=a^n u[n]\Rightarrow X(z)=\frac{1}{1-az^{-1}},\ \mathrm{ROC}:|z|>|a|
$$

`例 4.2` 左边指数：

$$
x[n]=-a^n u[-n-1]\Rightarrow X(z)=\frac{1}{1-az^{-1}},\ \mathrm{ROC}:|z|<|a|
$$

### 重点（高频考点）

- **同一个代数式，ROC 不同，时域序列不同。**  
- 右边序列 ROC 在外侧，左边序列 ROC 在内侧。  

`例 4.3/4.4` 进一步说明：多项相加时，整体 ROC 是各项 ROC 的交集，因此可出现外侧 ROC 或环形 ROC（双边序列）。

## 2.4 4.2.2 有限长序列收敛（P16-P18）

若 $x[n]$ 支撑在有限区间 $N_1\le n\le N_2$，则

$$
X(z)=\sum_{n=N_1}^{N_2}x[n]z^{-n}
$$

是有限项和，除 $z=0$ 或 $z=\infty$ 的边界情况外普遍收敛。

### 重点速记

- 右边有限长：ROC 近似全平面但去掉 $z=0$，即 $|z|>0$。  
- 左边有限长：ROC 近似全平面但去掉 $z=\infty$，即 $|z|<\infty$。  
- 双边有限长：

$$
0<|z|<\infty
$$

---

## 3. 4.3 Properties of the ROC（P19-P29）

## 3.1 7 条性质（按讲义顺序）

1. ROC 是以原点为中心的环形区域。  
2. ROC 不包含极点。  
3. 有限长序列：ROC 几乎是全平面（除 0/∞ 边界）。  
4. 右边序列：ROC 在最外极点之外。  
5. 左边序列：ROC 在最内极点之内。  
6. 双边序列：ROC 在两极点半径之间。  
7. ROC 连通（不会是分裂碎片）。

## 3.2 稳定性、因果性、频率响应（P24）

对 LTI 系统 $H(z)=\mathcal{Z}\{h[n]\}$：

- 频率响应存在：

$$
H(e^{j\omega})\ \text{存在}\iff |z|=1\subset\mathrm{ROC}
$$

- BIBO 稳定：

$$
\sum_n|h[n]|<\infty\iff |z|=1\subset\mathrm{ROC}
$$

- 因果（右边冲激响应）：ROC 在最外极点外。

因此对有理系统：

$$
\text{稳定且因果}\iff \text{所有极点严格在单位圆内}
$$

## 3.3 4.3.1 与 4.3.2 速查（P28-P29）

有限长：

- 因果有限长：$|z|>0$  
- 反因果有限长：$|z|<\infty$  
- 双边有限长：$0<|z|<\infty$

无限长：

- 右边/因果：$|z|>r_{\max}$  
- 左边/反因果：$|z|<r_{\min}$  
- 双边：$r_1<|z|<r_2$

### 重点

- 4.3 是本章“判题核心”，必须熟。  
- 看见 ROC 先判断“左右边”，再判断“单位圆是否包含”。

---

## 4. 4.4 The Inverse z-Transform（P30-P51）

## 4.1 反变换总框架（P30-P31）

反变换不只看 $X(z)$ 代数式，必须带 ROC。常用四法：

1. Inspection（查表匹配）  
2. Partial Fraction（部分分式）  
3. Power Series（幂级数/Laurent 展开）  
4. Contour Integration（围道积分）

双边反演积分：

$$
x[n]=\frac{1}{2\pi j}\oint_C X(z)z^{n-1}dz
$$

## 4.2 4.4.1 Inspection Method（P32-P34）

核心是“标准对 + ROC 决定左右边”。最常用模板：

$$
\frac{1}{1-az^{-1}}
\xleftrightarrow{|z|>|a|}
a^n u[n],
\qquad
\frac{1}{1-az^{-1}}
\xleftrightarrow{|z|<|a|}
-a^n u[-n-1]
$$

### 重点

- 看见同一分式，第一反应：先看 ROC，再写时域。

## 4.3 4.4.2 Partial Fraction Method（P35-P43）

适用于有理函数。标准流程：

1. 先判断是否真分式，不是则先长除。  
2. 分母因式分解找极点。  
3. 做部分分式展开（含重极点项）。  
4. 根据 ROC 把每一项判成右边或左边。  
5. 合并得到 $x[n]$。

关键规则（讲义 P37）：

- 多项式项 $B_r z^{-r}\leftrightarrow B_r\delta[n-r]$。  
- 若某极点在 ROC 内侧边界外对应右边项；在外侧边界内对应左边项。  

### 重点

- 4.8/4.9 的本质：**同一个 $X(z)$ 因 ROC 不同而得到不同 $x[n]$**。  
- 4.10/4.11：重极点、共轭极点要会写标准形式。

## 4.4 4.4.3 Power Series Expansion（P44-P47）

思想：把 $X(z)$ 展成 $z^{-1}$ 或 $z$ 的级数，系数直接读出 $x[n]$。

几何级数：

$$
\frac{1}{1-w}=\sum_{n=0}^{\infty}w^n,\quad |w|<1
$$

### 重点

- 展开方向由 ROC 决定：  
- 外侧 ROC：通常按 $z^{-1}$ 展开（右边序列）。  
- 内侧 ROC：通常改写后按 $z$ 展开（左边序列）。

## 4.5 4.4.4-4.4.6 极点与时域形态（P48-P51）

### 单实极点

$$
\frac{1}{1-az^{-1}}\Rightarrow a^n
$$

- $|a|<1$：衰减；$|a|=1$：恒幅；$|a|>1$：增长。

### 双实极点

$$
\frac{1}{(1-az^{-1})^2}\Rightarrow (n+1)a^n
$$

多了 $n$ 因子，增长/衰减速度变化更明显。

### 共轭极点对

若极点在 $re^{\pm j\omega_0}$，时域是振荡包络：

$$
r^n\cos(\omega_0 n+\alpha)
$$

- $0<r<1$：阻尼振荡  
- $r=1$：等幅振荡  
- $r>1$：发散振荡

### 重点

- 极点半径定“包络”，极点角度定“振荡频率”。

---

## 5. 4.5 z-Transform Properties（P52-P63）

设

$$
x[n]\xleftrightarrow{\mathcal{Z}}X(z)
$$

### 5.1 线性

$$
a x_1[n]+b x_2[n]\xleftrightarrow{\mathcal{Z}}aX_1(z)+bX_2(z)
$$

### 5.2 时移

$$
x[n-n_0]\xleftrightarrow{\mathcal{Z}}z^{-n_0}X(z)
$$

### 5.3 指数加权（调制）

$$
a^n x[n]\xleftrightarrow{\mathcal{Z}}X\!\left(\frac{z}{a}\right)
$$

ROC 按半径缩放。

### 5.4 乘 $n$（求导性质）

$$
nx[n]\xleftrightarrow{\mathcal{Z}}-z\frac{dX(z)}{dz}
$$

### 5.5 共轭

$$
x^*[n]\xleftrightarrow{\mathcal{Z}}X^*(z^*)
$$

### 5.6 时反

$$
x[-n]\xleftrightarrow{\mathcal{Z}}X(z^{-1})
$$

### 5.7 卷积定理

$$
y[n]=x_1[n]*x_2[n]\xleftrightarrow{\mathcal{Z}}Y(z)=X_1(z)X_2(z)
$$

### 本节重点

- 每条性质都要“同时追踪 ROC 变化”。  
- 做题最容易错在“式子对了但 ROC 错了”。

---

## 6. 4.6 Inverse z-Transform Using Contour Integration（P64-P82）

## 6.1 数学工具链（P65-P70）

- 解析函数与奇点（pole）。  
- Cauchy 积分定理：解析区域闭路积分为 0。  
- 留数定理：

$$
\oint_C F(z)dz=2\pi j\sum_k\operatorname{Res}_{z=p_k}\{F(z)\}
$$

## 6.2 反演积分与选择性（P71-P72）

在 ROC 内有 Laurent 展开：

$$
X(z)=\sum_{k=-\infty}^{\infty}x[k]z^{-k}
$$

乘上 $z^{n-1}$ 后围道积分，会利用

$$
\frac{1}{2\pi j}\oint_C z^{n-k-1}dz=
\begin{cases}
1,&k=n\\
0,&k\ne n
\end{cases}
$$

把第 $n$ 项“挑出来”，故

$$
x[n]=\frac{1}{2\pi j}\oint_C X(z)z^{n-1}dz
$$

若单位圆在 ROC 内，可退化为逆 DTFT。

## 6.3 计算流程（P73-P82）

令

$$
F_n(z)=X(z)z^{n-1}
$$

然后：

1. 根据 ROC 选围道 $C$。  
2. 找 $F_n(z)$ 在围道内极点。  
3. 求这些极点留数并求和。

### 重点

- ROC 决定“哪些极点在围道内”，直接决定结果对应右边/左边序列。  
- 4.20/4.21 展示了同一积分框架如何输出标准右边序列与实值振荡形式。

---

## 7. 本章重点清单（考试导向）

1. 必会：

$$
\frac{1}{1-az^{-1}}
\xleftrightarrow{|z|>|a|}
a^n u[n],\quad
\xleftrightarrow{|z|<|a|}
-a^n u[-n-1]
$$

2. 必会：

$$
X(e^{j\omega})\ \text{存在}\iff |z|=1\subset\mathrm{ROC}
$$

3. 必会：有理系统

$$
\text{稳定且因果}\iff \text{全部极点在单位圆内}
$$

4. 必会：部分分式法流程（含 ROC 判左右边）。  
5. 必会：卷积定理与时移/调制/求导性质。  
6. 了解：围道积分与留数法的步骤和物理含义。

---

## 8. 易错点（按失分频率）

1. 只写 $X(z)$ 不写 ROC。  
2. 把“极点在单位圆内”误当成所有情况下都稳定（忽略 ROC）。  
3. 部分分式后只看系数，不按 ROC 判右边/左边。  
4. 用性质时漏掉 ROC 变化。  
5. 把 $X(e^{j\omega})$ 存在条件写错成“极点不在单位圆上”而忽略“单位圆必须在 ROC 内”。
