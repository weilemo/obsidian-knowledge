# TD4 习题详解（Probability, 2026-03-26）

题目来源：`/Users/moweile/Obsidian/Knowledge/Course/25-26-2/MATH3307P Probability & Statistics 概率论与统计/TD/TD4.pdf`

说明：本笔记中凡用到公式，均补充来源/推导，不默认已知。

## 目录
- [Ex1 已知密度求分布函数](#ex1-已知密度求分布函数)
- [Ex2 已知分布函数求参数与密度](#ex2-已知分布函数求参数与密度)
- [Ex3 分段密度归一化与概率](#ex3-分段密度归一化与概率)
- [Ex4 油罐容量的 95% 保障](#ex4-油罐容量的-95-保障)
- [Ex5 独立同分布尾事件](#ex5-独立同分布尾事件)
- [Ex6 拒收概率：二项精确与泊松近似](#ex6-拒收概率二项精确与泊松近似)
- [Ex7 泊松参数由 P(X=1)=P(X=2)](#ex7-泊松参数由-px1px2)
- [Ex8 泊松抽稀（thinning）](#ex8-泊松抽稀thinning)
- [Ex9 混合人群下的贝叶斯反推](#ex9-混合人群下的贝叶斯反推)
- [Ex10 三次独立观测后的计数变量](#ex10-三次独立观测后的计数变量)
- [Ex11 5 组件系统何时优于 3 组件](#ex11-5-组件系统何时优于-3-组件)
- [Ex12 均匀分布下二次不等式概率](#ex12-均匀分布下二次不等式概率)
- [Ex13 判别式与正态中位数](#ex13-判别式与正态中位数)
- [Ex14 指数等待与一年离开次数](#ex14-指数等待与一年离开次数)
- [Ex15 正态区间概率 N(110,12^2)](#ex15-正态区间概率-n110122)
- [Ex16 航班到达时间概率 N(240,20^2)](#ex16-航班到达时间概率-n240202)
- [Ex17 招考分数线反推](#ex17-招考分数线反推)
- [Ex18 比较两个正态尾概率](#ex18-比较两个正态尾概率)
- [Ex19 已知双侧尾概率求单侧概率](#ex19-已知双侧尾概率求单侧概率)

---

## Ex1 已知密度求分布函数
给定密度
$$
f(x)=\begin{cases}
1+x, & -1\le x<0,\\
1-x, & 0\le x<1,\\
0, & \text{其它}.
\end{cases}
$$

公式来源：连续型随机变量分布函数
$$
F(x)=\int_{-\infty}^x f(t)\,dt.
$$

分段积分：
$$
F(x)=\begin{cases}
0, & x<-1,\\
\int_{-1}^x (1+t)dt = x+\dfrac{x^2}{2}+\dfrac12, & -1\le x<0,\\
\dfrac12+\int_0^x (1-t)dt = \dfrac12+x-\dfrac{x^2}{2}, & 0\le x<1,\\
1, & x\ge1.
\end{cases}
$$

---

## Ex2 已知分布函数求参数与密度
给定
$$
F(x)=\begin{cases}
0, & x\le0,\\
Ax^2, & 0<x\le1,\\
1, & x>1.
\end{cases}
$$

### (1) 求 $A$
分布函数右连续，且在 $x=1$ 处应满足 $F(1)=1$，故
$$
A=1.
$$

### (2) 求 $P(0.3<X<0.7)$
连续型下
$$
P(a<X<b)=F(b)-F(a)=0.7^2-0.3^2=0.49-0.09=\boxed{0.40}.
$$

### (3) 求密度
公式来源：若 $F$ 可导，则 $f(x)=F'(x)$（几乎处处）。
$$
f(x)=\begin{cases}
2x, & 0<x<1,\\
0, & \text{其它}.
\end{cases}
$$

---

## Ex3 分段密度归一化与概率
给定
$$
f(x)=\begin{cases}
cx^2+x, & 0\le x\le 0.5,\\
0, & \text{其它}.
\end{cases}
$$

### (1) 求 $c$
密度归一化：
$$
\int_0^{0.5}(cx^2+x)dx=1
\Rightarrow c\cdot\frac{1}{24}+\frac18=1
\Rightarrow c=\boxed{21}.
$$

### (2) 分布函数
$$
F(x)=\begin{cases}
0, & x<0,\\
\int_0^x(21t^2+t)dt=7x^3+\dfrac{x^2}{2}, & 0\le x\le 0.5,\\
1, & x>0.5.
\end{cases}
$$

### (3) 20 分钟内完成概率
20 分钟 $=\dfrac13$ 小时：
$$
P\left(X\le\frac13\right)=F\left(\frac13\right)=7\cdot\frac{1}{27}+\frac{1}{18}=\frac{17}{54}\approx 0.3148.
$$

### (4) 超过 10 分钟概率
10 分钟 $=\dfrac16$ 小时：
$$
P\left(X>\frac16\right)=1-F\left(\frac16\right)=1-\left(7\cdot\frac1{216}+\frac1{72}\right)=1-\frac{5}{108}=\frac{103}{108}\approx 0.9537.
$$

---

## Ex4 油罐容量的 95% 保障
$$
f(x)=\begin{cases}
0.05\left(1-\frac{x}{100}\right)^4, & 0\le x\le 100,\\
0, & \text{其它}.
\end{cases}
$$
设油罐容量为 $C$（同单位：千升）。要求
$$
P(X>C)<0.05\iff F(C)\ge0.95.
$$

先求分布函数：
$$
F(x)=\int_0^x0.05\left(1-\frac{t}{100}\right)^4dt
=1-\left(1-\frac{x}{100}\right)^5.
$$

令 $F(C)=0.95$：
$$
1-\left(1-\frac{C}{100}\right)^5=0.95
\Rightarrow \left(1-\frac{C}{100}\right)^5=0.05
\Rightarrow C=100\left(1-0.05^{1/5}\right).
$$

数值：
$$
\boxed{C\approx 45.07}
$$
（约 $4.507\times10^4$ L）。

---

## Ex5 独立同分布尾事件
已知 $X,Y$ 同分布且独立，
$$
f_X(x)=\begin{cases}
\frac{3}{8}x^2, & 0\le x\le2,\\
0, & \text{其它}.
\end{cases}
$$
定义 $A=\{X>a\},\ B=\{Y>a\}$，且 $P(A\cup B)=3/4$。

设 $q=P(A)=P(B)$，则（独立）
$$
P(A\cup B)=q+q-q^2=2q-q^2=\frac34.
$$
解得 $q=1/2$（另一根 $3/2$ 舍去）。

又
$$
F_X(x)=\int_0^x\frac{3}{8}t^2dt=\frac{x^3}{8},\quad 0\le x\le2,
$$
故
$$
P(X>a)=1-F(a)=1-\frac{a^3}{8}=\frac12
\Rightarrow a^3=4
\Rightarrow \boxed{a=\sqrt[3]{4}\approx1.5874}.
$$

---

## Ex6 拒收概率：二项精确与泊松近似
不合格率 $p=0.02$，抽检 $n=40$，若不合格数 $\ge2$ 则拒收。
令 $X\sim\mathrm{Bin}(40,0.02)$。

### (1) 精确（二项）
$$
P(\text{拒收})=P(X\ge2)=1-P(X=0)-P(X=1)
$$
$$
=1-0.98^{40}-\binom{40}{1}(0.02)(0.98)^{39}
\approx \boxed{0.19046}.
$$

### (2) 泊松近似
公式来源：当 $n$ 大、$p$ 小，且 $\lambda=np$ 中等时，$\mathrm{Bin}(n,p)\approx\mathrm{Pois}(\lambda)$。

这里 $\lambda=40\times0.02=0.8$：
$$
P(\text{拒收})\approx 1-e^{-0.8}(1+0.8)\approx \boxed{0.19121}.
$$

---

## Ex7 泊松参数由 P(X=1)=P(X=2)
设 $X\sim\mathrm{Pois}(\lambda)$：
$$
P(X=k)=e^{-\lambda}\frac{\lambda^k}{k!}.
$$
条件
$$
P(X=1)=P(X=2)
\Rightarrow e^{-\lambda}\lambda=e^{-\lambda}\frac{\lambda^2}{2}
\Rightarrow \lambda=2.
$$

故
$$
P(X=4)=e^{-2}\frac{2^4}{4!}=\boxed{\frac{2}{3}e^{-2}}.
$$

---

## Ex8 泊松抽稀（thinning）
设到店总人数 $N\sim\mathrm{Pois}(\lambda)$，每人购买独立概率 $p$。记购买人数为 $Y$。

条件分布：
$$
Y\mid N=n\sim\mathrm{Bin}(n,p).
$$

全概率：
$$
P(Y=k)=\sum_{n=k}^{\infty}P(Y=k\mid N=n)P(N=n)
$$
$$
=\sum_{n=k}^{\infty}\binom{n}{k}p^k(1-p)^{n-k}e^{-\lambda}\frac{\lambda^n}{n!}
$$
$$
=e^{-\lambda}\frac{(\lambda p)^k}{k!}\sum_{j=0}^{\infty}\frac{(\lambda(1-p))^j}{j!}
=e^{-\lambda p}\frac{(\lambda p)^k}{k!}.
$$

因此
$$
\boxed{Y\sim\mathrm{Pois}(\lambda p)}.
$$

---

## Ex9 混合人群下的贝叶斯反推
设 $E$：药有效，$E^c$：无效。

先验：
$$
P(E)=0.75,\quad P(E^c)=0.25.
$$

条件模型：
- 若有效：$X\sim\mathrm{Pois}(3)$
- 若无效：$X\sim\mathrm{Pois}(5)$

给定 $X=2$，求 $P(E\mid X=2)$：
$$
P(E\mid X=2)=\frac{P(E)P(X=2\mid E)}{P(E)P(X=2\mid E)+P(E^c)P(X=2\mid E^c)}
$$
$$
=\frac{0.75\,e^{-3}\frac{3^2}{2!}}{0.75\,e^{-3}\frac{3^2}{2!}+0.25\,e^{-5}\frac{5^2}{2!}}
\approx \boxed{0.88864}.
$$

---

## Ex10 三次独立观测后的计数变量
给定密度 $f(x)=2x$（$0<x<1$），独立观测 3 次。令 $Y$ 为“满足 $X\le 1/2$ 的次数”。

先算单次成功概率：
$$
q=P(X\le1/2)=\int_0^{1/2}2x\,dx=\frac14.
$$

因此
$$
Y\sim\mathrm{Bin}(3,1/4),
$$
$$
P(Y=2)=\binom32\left(\frac14\right)^2\left(\frac34\right)=\boxed{\frac{9}{64}}.
$$

---

## Ex11 5 组件系统何时优于 3 组件
每个组件独立成功概率 $p$。
系统在“至少一半组件成功”时工作。

### 3 组件系统
至少 2 个成功：
$$
R_3=\binom32p^2(1-p)+p^3=3p^2-2p^3.
$$

### 5 组件系统
至少 3 个成功：
$$
R_5=\binom53p^3(1-p)^2+\binom54p^4(1-p)+p^5
=10p^3-15p^4+6p^5.
$$

比较 $R_5>R_3$：
$$
R_5-R_3=3p^2(2p^3-5p^2+4p-1)
=3p^2(p-1)^2(2p-1).
$$

故在 $0\le p\le1$ 内，
$$
R_5>R_3 \iff p>\frac12,
$$
且 $p=1/2$（以及 $p=1$）时两者相等。

---

## Ex12 均匀分布下二次不等式概率
$X\sim U(0,1)$，求
$$
P\left(X^2-\frac34X+\frac18\ge0\right).
$$

先解方程：
$$
x^2-\frac34x+\frac18=0
\Rightarrow x=\frac14,\ \frac12.
$$
抛物线开口向上，故不等式成立区间为
$$
(0,1)\setminus\left(\frac14,\frac12\right).
$$
长度法（均匀分布）：
$$
P=1-\left(\frac12-\frac14\right)=\boxed{\frac34}.
$$

---

## Ex13 判别式与正态中位数
$K\sim N(\mu,\sigma^2)$，方程
$$
x^2+4x+K=0
$$
无实根当且仅当判别式 $\Delta<0$：
$$
16-4K<0\iff K>4.
$$

已知 $P(K>4)=0.5$。正态分布关于均值对称，且中位数=均值，所以
$$
\boxed{\mu=4}.
$$

---

## Ex14 指数等待与一年离开次数
等待时间 $X\sim\mathrm{Exp}(\text{均值 }5)$，密度
$$
f(x)=\frac15e^{-x/5},\quad x>0.
$$
每次若等待超过 10 分钟离开。

单次离开概率：
$$
q=P(X>10)=e^{-10/5}=e^{-2}.
$$
一年去 5 次，设独立，则
$$
Y\sim\mathrm{Bin}(5,q).
$$

求
$$
P(Y\ge1)=1-P(Y=0)=1-(1-q)^5
=\boxed{1-(1-e^{-2})^5}.
$$

---

## Ex15 正态区间概率 N(110,12^2)
$X\sim N(110,12^2)$，求 $P(100\le X\le120)$。

标准化：
$$
Z=\frac{X-110}{12}\sim N(0,1),
$$
$$
P(100\le X\le120)=P\left(-\frac{10}{12}\le Z\le\frac{10}{12}\right)
=\Phi(0.8333)-\Phi(-0.8333).
$$
数值
$$
\boxed{\approx 0.59534}.
$$

---

## Ex16 航班到达时间概率 N(240,20^2)
飞行时长 $X\sim N(240,20^2)$（分钟）。10:10 起飞。

- 14:30 对应时长 260 分钟
- 14:20 对应时长 250 分钟
- 13:50 对应时长 220 分钟

### (1) 14:30 之后到达
$$
P(X>260)=1-\Phi\left(\frac{260-240}{20}\right)=1-\Phi(1)\approx \boxed{0.15866}.
$$

### (2) 14:20 之前到达
$$
P(X<250)=\Phi\left(\frac{250-240}{20}\right)=\Phi(0.5)\approx \boxed{0.69146}.
$$

### (3) 13:50 到 14:30 之间到达
$$
P(220\le X\le260)=\Phi(1)-\Phi(-1)\approx \boxed{0.68269}.
$$

---

## Ex17 招考分数线反推
总人数 10000，成绩服从正态 $N(\mu,\sigma^2)$。

已知：
- 超过 90 分有 359 人：$P(X>90)=0.0359$，故 $P(X\le90)=0.9641$。
- 低于 60 分有 1151 人：$P(X<60)=0.1151$。

设标准化后
$$
z_1=\frac{90-\mu}{\sigma}=\Phi^{-1}(0.9641)\approx 1.800,
$$
$$
z_2=\frac{60-\mu}{\sigma}=\Phi^{-1}(0.1151)\approx -1.200.
$$
两式相减：
$$
\frac{30}{\sigma}=z_1-z_2\approx3\Rightarrow \sigma\approx10,
$$
$$
\mu\approx 90-1.8\times10=72.
$$

录取前 2500 人，即上分位 25%（下分位 75%）：
$$
x_* = \mu+\sigma z_{0.75},\quad z_{0.75}\approx0.67449.
$$
故
$$
x_*\approx72+10\times0.67449=\boxed{78.74\text{ 分（约 }78.7\text{）}}.
$$

---

## Ex18 比较两个正态尾概率
$$
X\sim N(\mu,4^2),\quad Y\sim N(\mu,5^2).
$$

$$
p_1=P(X\le\mu-4)=P\left(\frac{X-\mu}{4}\le-1\right)=\Phi(-1),
$$
$$
p_2=P(Y\ge\mu+5)=P\left(\frac{Y-\mu}{5}\ge1\right)=1-\Phi(1)=\Phi(-1).
$$

因此
$$
\boxed{p_1=p_2}\quad(\text{均约 }0.1587).
$$

---

## Ex19 已知双侧尾概率求单侧概率
$X\sim N(0,\sigma^2)$，已知
$$
P(|X|>k)=0.1.
$$

由对称性：
$$
P(X>k)=P(X<-k)=0.05.
$$

所以
$$
P(X<k)=1-P(X\ge k)=1-0.05=\boxed{0.95}.
$$

