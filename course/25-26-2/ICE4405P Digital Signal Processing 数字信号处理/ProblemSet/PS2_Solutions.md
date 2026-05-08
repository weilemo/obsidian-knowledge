# PS2 Solutions (Full-Proof Version)

> 课程：ICE4405P Digital Signal Processing  
> 题目：`ProblemSet/PS2.pdf`

## 0. 预备：本解答采用的变换定义

连续时间傅里叶变换（CTFT）约定：

$$
X_c(j\Omega)=\int_{-\infty}^{\infty}x_c(t)e^{-j\Omega t}\,dt,\quad
x_c(t)=\frac{1}{2\pi}\int_{-\infty}^{\infty}X_c(j\Omega)e^{j\Omega t}\,d\Omega
$$

离散时间傅里叶变换（DTFT）约定：

$$
X(e^{j\omega})=\sum_{n=-\infty}^{\infty}x[n]e^{-j\omega n}
$$

---

## 1. Sampling and Reconstruction

已知

$$
x_c(t)=2\cos\left(100\pi t-\frac{\pi}{4}\right)+\cos\left(300\pi t+\frac{\pi}{3}\right)
$$

理想重建滤波器

$$
H_r(j\Omega)=
\begin{cases}
T, & |\Omega|\le \frac{\pi}{T}\\
0, & |\Omega|> \frac{\pi}{T}
\end{cases}
$$

### 1(a) 求 $X_c(j\Omega)$（含公式证明）

先证明常用对偶：

$$
A\cos(\Omega_0 t+\phi)\xleftrightarrow{\mathcal{F}}
\pi A\!\left[e^{j\phi}\delta(\Omega-\Omega_0)+e^{-j\phi}\delta(\Omega+\Omega_0)\right]
$$

证明：

$$
\cos(\Omega_0 t+\phi)=\frac12\left(e^{j(\Omega_0 t+\phi)}+e^{-j(\Omega_0 t+\phi)}\right)
$$

故

$$
A\cos(\Omega_0 t+\phi)=\frac{A}{2}\left(e^{j\phi}e^{j\Omega_0 t}+e^{-j\phi}e^{-j\Omega_0 t}\right)
$$

而

$$
e^{j\Omega_0 t}\xleftrightarrow{\mathcal{F}}2\pi\delta(\Omega-\Omega_0),\quad
e^{-j\Omega_0 t}\xleftrightarrow{\mathcal{F}}2\pi\delta(\Omega+\Omega_0)
$$

线性叠加得证。

代入本题两项：

$$
\begin{aligned}
2\cos\left(100\pi t-\frac{\pi}{4}\right)
&\xleftrightarrow{\mathcal{F}}
2\pi\!\left[e^{-j\pi/4}\delta(\Omega-100\pi)+e^{j\pi/4}\delta(\Omega+100\pi)\right],\\
\cos\left(300\pi t+\frac{\pi}{3}\right)
&\xleftrightarrow{\mathcal{F}}
\pi\!\left[e^{j\pi/3}\delta(\Omega-300\pi)+e^{-j\pi/3}\delta(\Omega+300\pi)\right].
\end{aligned}
$$

所以

$$
\begin{aligned}
X_c(j\Omega)
&=2\pi e^{-j\pi/4}\delta(\Omega-100\pi)+2\pi e^{j\pi/4}\delta(\Omega+100\pi)\\
&\quad+\pi e^{j\pi/3}\delta(\Omega-300\pi)+\pi e^{-j\pi/3}\delta(\Omega+300\pi).
\end{aligned}
$$

### 1(b) $f_s=500$ Hz

$$
T=\frac{1}{500}=0.002,\quad \Omega_s=\frac{2\pi}{T}=1000\pi
$$

#### 第一步：证明采样后频谱复制公式

冲激采样模型：

$$
x_s(t)=x_c(t)\sum_{n=-\infty}^{\infty}\delta(t-nT)
$$

设

$$
s(t)=\sum_{n=-\infty}^{\infty}\delta(t-nT)
\xleftrightarrow{\mathcal{F}}
S(j\Omega)=\frac{2\pi}{T}\sum_{k=-\infty}^{\infty}\delta(\Omega-k\Omega_s)
$$

则

$$
X_s(j\Omega)=\frac{1}{2\pi}\left(X_c * S\right)(j\Omega)
=\frac{1}{T}\sum_{k=-\infty}^{\infty}X_c\!\left(j(\Omega-k\Omega_s)\right)
$$

即原谱以间隔 $\Omega_s$ 周期复制，并带系数 $1/T$。

#### 第二步：列出区间内冲激线位置

题目要求区间：

$$
-\frac{2\pi}{T}\le\Omega\le\frac{2\pi}{T}
\iff -1000\pi\le\Omega\le1000\pi
$$

原有线在 $\pm100\pi,\pm300\pi$，再加 $k=\pm1$ 平移得到：

$$
\pm(1000\pi-100\pi)=\pm900\pi,\quad
\pm(1000\pi-300\pi)=\pm700\pi.
$$

故可见线谱位置为

$$
\Omega=\pm100\pi,\ \pm300\pi,\ \pm700\pi,\ \pm900\pi.
$$

#### 第三步：重建输出

重建通带为

$$
|\Omega|\le \frac{\pi}{T}=500\pi.
$$

由于原最高频率 $300\pi<500\pi$，基带副本完整保留且与相邻副本不重叠。滤波器通带增益 $T$ 抵消采样产生的 $1/T$，因此

$$
x_r(t)=x_c(t)
=2\cos\left(100\pi t-\frac{\pi}{4}\right)+\cos\left(300\pi t+\frac{\pi}{3}\right).
$$

### 1(c) $f_s=250$ Hz

$$
T=\frac{1}{250}=0.004,\quad \Omega_s=500\pi,\quad \frac{\pi}{T}=250\pi.
$$

现在 $300\pi>250\pi$，高频分量超出奈奎斯特边界，将折叠到基带。折叠频率：

$$
\Omega_a=\Omega_s-300\pi=200\pi.
$$

相位由离散序列确定。对第二项采样：

$$
\cos\left(300\pi nT+\frac{\pi}{3}\right)
=\cos\left(1.2\pi n+\frac{\pi}{3}\right)
=\cos\left(-0.8\pi n+\frac{\pi}{3}\right)
=\cos\left(0.8\pi n-\frac{\pi}{3}\right).
$$

对应连续频率即 $200\pi$，相位 $-\pi/3$。故

$$
x_r(t)=2\cos\left(100\pi t-\frac{\pi}{4}\right)+\cos\left(200\pi t-\frac{\pi}{3}\right).
$$

---

## 2. DTFT Symmetry and Decimation

已知稳定序列满足

$$
X(e^{j\omega})=X\big(e^{j(\omega-\pi)}\big),\qquad x[n]=x[-n].
$$

### 2(a) 证明 $X(e^{j\omega})$ 周期为 $\pi$

将上式中的 $\omega$ 替换成 $\omega+\pi$：

$$
X\big(e^{j(\omega+\pi)}\big)=X\big(e^{j\omega}\big).
$$

故周期为 $\pi$。

### 2(b) 求 $x[3]$

先证明调制移频关系：

$$
x[n]e^{j\omega_0 n}\xleftrightarrow{\mathcal{F}}X(e^{j(\omega-\omega_0)}).
$$

取 $\omega_0=\pi$，即

$$
x[n](-1)^n \xleftrightarrow{\mathcal{F}} X\big(e^{j(\omega-\pi)}\big).
$$

题设给出右边恰等于 $X(e^{j\omega})$，由 DTFT 唯一性：

$$
x[n](-1)^n=x[n].
$$
因此

$$
\big((-1)^n-1\big)x[n]=0.
$$

当 $n$ 为奇数，$(-1)^n-1=-2\neq 0$，只能有

$$
x[2k+1]=0.
$$

所以

$$
x[3]=0.
$$

### 2(c) 已知 $y[n]=x[2n]$，能否重建 $x[n]$？

因为奇数样本全为 0，原序列信息完全包含在偶数样本中，而偶数样本正是 $y[n]$：

$$
x[2n]=y[n],\quad x[2n+1]=0.
$$

故可完美重建：

$$
x[n]=
\begin{cases}
y[n/2], & n\ \text{偶}\\
0, & n\ \text{奇}
\end{cases}
$$

---

## 3. 系统：$\downarrow3$、$\uparrow3$、理想低通

框图对应

$$
x[n]\xrightarrow{\downarrow3}x_d[n]\xrightarrow{\uparrow3}x_e[n]\xrightarrow{H(e^{j\omega})}x_r[n]
$$

且

$$
H(e^{j\omega})=
\begin{cases}
3,& |\omega|\le \pi/3\\
0,& \pi/3<|\omega|\le\pi.
\end{cases}
$$

### 3.1 先证明该结构的理想重建条件

抽取 3 的频域关系：

$$
X_d(e^{j\omega})=\frac{1}{3}\sum_{k=0}^{2}X\!\left(e^{j\frac{\omega+2\pi k}{3}}\right).
$$

插值 3（零插值）频域关系：

$$
X_e(e^{j\omega})=X_d(e^{j3\omega}).
$$

若原信号带限到 $|\omega|\le\pi/3$，则抽取时三项不重叠（无混叠），且

$$
X_d(e^{j\omega})=\frac{1}{3}X\!\left(e^{j\omega/3}\right).
$$

再经插值：

$$
X_e(e^{j\omega})=\frac{1}{3}X(e^{j\omega}),\quad |\omega|\le\pi/3.
$$

最后理想低通在通带乘以 3，得到

$$
X_r(e^{j\omega})=X(e^{j\omega}),\quad |\omega|\le\pi/3.
$$

所以是否失真只取决于输入是否带限在 $|\omega|\le\pi/3$。

### 3(a) $x[n]=\cos(\pi n/4)$

谱线在 $\omega=\pm\pi/4$，满足

$$
\frac{\pi}{4}<\frac{\pi}{3}.
$$

因此可无失真重建：

$$
x_r[n]=x[n].
$$

结论：Yes。

### 3(b) $x[n]=\cos(\pi n/2)$

谱线在 $\omega=\pm\pi/2$，超出安全带宽 $\pi/3$，会发生混叠，故不可能无失真恢复原频率。

$$
x_r[n]\neq x[n].
$$

结论：No。

### 3(c) $x[n]=\left[\frac{\sin(\pi n/8)}{\pi n}\right]^2$

设

$$
g[n]=\frac{\sin(\omega_c n)}{\pi n},\quad \omega_c=\frac{\pi}{8}.
$$

标准对：

$$
G(e^{j\omega})=
\begin{cases}
1,& |\omega|\le\omega_c\\
0,& \text{else}.
\end{cases}
$$

本题 $x[n]=g^2[n]$，时域相乘对应频域周期卷积：

$$
X(e^{j\omega})=\frac{1}{2\pi}\big(G*G\big)(e^{j\omega}).
$$

两个宽度为 $2\omega_c$ 的矩形卷积后支撑宽度变为 $4\omega_c$，即

$$
|\omega|\le 2\omega_c=\frac{\pi}{4}<\frac{\pi}{3}.
$$

仍在安全带宽内，所以

$$
x_r[n]=x[n].
$$

结论：Yes。

---

## 4. Inverse Z-transform（含分解步骤）

### 4(a)

$$
X(z)=\frac{1}{1+\frac{1}{2}z^{-1}},\quad |z|>\frac{1}{2}
=\frac{1}{1-\left(-\frac12\right)z^{-1}}.
$$

根据模板

$$
\frac{1}{1-az^{-1}}\ \xleftrightarrow{|z|>|a|}\ a^n u[n]
$$

得

$$
x[n]=\left(-\frac12\right)^n u[n].
$$

### 4(b)

同一代数式但 ROC 为 $|z|<1/2$，对应左边序列模板

$$
\frac{1}{1-az^{-1}}\ \xleftrightarrow{|z|<|a|}\ -a^n u[-n-1].
$$

代入 $a=-1/2$：

$$
x[n]=-\left(-\frac12\right)^n u[-n-1].
$$

### 4(c)

$$
X(z)=\frac{1-\frac12 z^{-1}}{1+\frac34 z^{-1}+\frac18 z^{-2}},\quad |z|>\frac12.
$$

分母因式分解：

$$
1+\frac34 z^{-1}+\frac18 z^{-2}
=\left(1+\frac12 z^{-1}\right)\left(1+\frac14 z^{-1}\right).
$$

设

$$
X(z)=\frac{A}{1+\frac12 z^{-1}}+\frac{B}{1+\frac14 z^{-1}}.
$$

通分并比较系数：

$$
1-\frac12 z^{-1}=A\left(1+\frac14 z^{-1}\right)+B\left(1+\frac12 z^{-1}\right).
$$

得到

$$
A+B=1,\quad \frac14A+\frac12B=-\frac12.
$$

解得

$$
A=4,\quad B=-3.
$$

所以

$$
X(z)=\frac{4}{1+\frac12 z^{-1}}-\frac{3}{1+\frac14 z^{-1}}.
$$

ROC 在外侧，对应右边序列：

$$
x[n]=4\left(-\frac12\right)^n u[n]-3\left(-\frac14\right)^n u[n].
$$

---

## 5. Causal LTI System

已知

$$
x[n]=u[-n-1]+\left(\frac12\right)^n u[n]
$$

$$
Y(z)=\frac{-\frac12 z^{-1}}{\left(1-\frac12 z^{-1}\right)(1+z^{-1})}.
$$

### 5(a) 求 $H(z)$ 与 ROC

先求 $X(z)$：

$$
\mathcal{Z}\{u[-n-1]\}=-\frac{1}{1-z^{-1}},\quad |z|<1,
$$

$$
\mathcal{Z}\left\{\left(\frac12\right)^n u[n]\right\}
=\frac{1}{1-\frac12 z^{-1}},\quad |z|>\frac12.
$$

相加：

$$
\begin{aligned}
X(z)
&=-\frac{1}{1-z^{-1}}+\frac{1}{1-\frac12 z^{-1}}\\
&=\frac{-\frac12 z^{-1}}{(1-z^{-1})\left(1-\frac12 z^{-1}\right)}.
\end{aligned}
$$

因此

$$
H(z)=\frac{Y(z)}{X(z)}
=\frac{1-z^{-1}}{1+z^{-1}}.
$$

系统题设为 causal，且 $H(z)$ 极点在 $z=-1$，故

$$
\mathrm{ROC}_H:\ |z|>1.
$$

### 5(b) 求 $Y(z)$ 的 ROC

$Y(z)$ 极点在 $z=\frac12$ 与 $z=-1$。因输入含左边项和右边项，输出为双边序列，对应 ROC 取两极点之间：

$$
\mathrm{ROC}_Y:\ \frac12<|z|<1.
$$

### 5(c) 求 $y[n]$（含系数求解）

设

$$
Y(z)=\frac{A}{1-\frac12 z^{-1}}+\frac{B}{1+z^{-1}}.
$$

通分：

$$
-\frac12 z^{-1}
=A(1+z^{-1})+B\left(1-\frac12 z^{-1}\right).
$$

比较常数项与 $z^{-1}$ 项：

$$
A+B=0,\quad A-\frac12B=-\frac12.
$$

解得

$$
A=-\frac13,\quad B=\frac13.
$$

所以

$$
Y(z)= -\frac{1}{3}\frac{1}{1-\frac12 z^{-1}}
+\frac{1}{3}\frac{1}{1+z^{-1}}.
$$

结合 ROC $\frac12<|z|<1$：

- 第一项（极点 $1/2$）取右边序列；
- 第二项（极点 $-1$）取左边序列。

故

$$
y[n]=-\frac13\left(\frac12\right)^n u[n]-\frac13(-1)^n u[-n-1].
$$

---

## 6. 最终答案汇总

1. $X_c(j\Omega)$ 如 1(a)；$f_s=500$ Hz 时 $x_r(t)=x_c(t)$；$f_s=250$ Hz 时
$$
x_r(t)=2\cos\left(100\pi t-\frac{\pi}{4}\right)+\cos\left(200\pi t-\frac{\pi}{3}\right).
$$
2. 周期为 $\pi$，$x[3]=0$，可由 $y[n]=x[2n]$ 完全重构。
3. (a) Yes，(b) No，(c) Yes。
4. (a) $\left(-\frac12\right)^n u[n]$；(b) $-\left(-\frac12\right)^n u[-n-1]$；
$$
\text{(c) }4\left(-\frac12\right)^n u[n]-3\left(-\frac14\right)^n u[n].
$$
5.
$$
H(z)=\frac{1-z^{-1}}{1+z^{-1}},\quad \mathrm{ROC}_H:|z|>1,
$$
$$
\mathrm{ROC}_Y:\frac12<|z|<1,\quad
y[n]=-\frac13\left(\frac12\right)^n u[n]-\frac13(-1)^n u[-n-1].
$$
