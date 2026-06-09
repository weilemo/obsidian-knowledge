# 02 Échantillonnage et TZ 讲义

来源：[[ppt/ELEC101_TZ 2026.pdf|ELEC101_TZ 2026.pdf]]

这一讲承接第一讲的 Laplace 变换，把视角从连续时间系统推进到采样系统。核心问题是：真实模拟信号 $x(t)$ 经过采样后变成样本序列 $x[k]$，这个过程在时间域和频域分别发生了什么？为什么采样频率不够会产生混叠？为什么离散系统不用 $p$ 域而用 $z$ 域？以及连续系统的稳定性如何映射到离散系统的单位圆内稳定性？

## p.1 标题：Échantillonnage et TZ

标题里的两个关键词：

- Échantillonnage：采样，把连续时间信号 $x(t)$ 变成离散时间样本 $x[k]$。
- TZ / Transformée en Z：$z$ 变换，是离散时间系统里对应 Laplace 变换的工具。

这讲的主线可以写成：

$$
x(t)
\xrightarrow{\text{échantillonnage}}
x[k]
\xrightarrow{\text{TZ}}
X(z)
$$

第一讲里连续 LTI 系统用：

$$
Y(p)=X(p)H(p)
$$

这一讲里离散 LTI 系统会用：

$$
Y(z)=X(z)H(z)
$$

## p.2 连续时间信号与离散时间信号

PPT 把模拟信号分成两大类：

1. 连续时间信号：记作 $x(t)$。
2. 离散时间信号：记作 $x[k]$。

连续时间信号在任意时刻 $t$ 都有定义；离散时间信号只在整数索引 $k$ 上有定义。二者通过采样周期 $T_e$ 连接：

$$
x[k]=x(kT_e)
$$

其中：

- $T_e$ 是 période d'échantillonnage，采样周期。
- $f_e$ 是 fréquence d'échantillonnage，采样频率。

二者关系是：

$$
f_e=\frac{1}{T_e}
$$

PPT 图里 $x(t)$ 是连续曲线，$x^\ast(t)$ 是在 $T_e,2T_e,3T_e,\ldots$ 这些时刻留下的样本。严格说，$x[k]$ 是一个序列，而 $x^\ast(t)$ 常用来表示“用 Dirac 冲激承载样本值”的采样信号。

## p.3 离散系统与 Nyquist-Shannon 定理

离散系统的输入输出关系写作：

$$
y[n]=f(x[n])
$$

它只在离散时刻处理数据。也就是说，系统不知道连续曲线上两个采样点之间发生了什么；它只看到样本序列。

采样周期 $T_e$ 或 $T_s$ 决定两个样本之间隔多久：

$$
t_n=nT_e
$$

PPT 给出 Nyquist-Shannon 定理：

> 若要无损采样一个带限信号，采样频率必须大于信号带宽的两倍。

如果信号最高频率或带宽是 $B_w$，则需要：

$$
f_e>2B_w
$$

这里 $2B_w$ 叫 Nyquist rate。它不是一个经验规则，而是由后面频谱复制不重叠的要求推出的。

直观理解：采样以后，频域中原信号频谱会以 $f_e$ 为周期复制。如果 $f_e$ 太小，复制出来的频谱副本会互相重叠，一旦重叠，就无法从采样结果唯一恢复原信号。

## p.4 离散输入、离散输出：差分方程

PPT 的例子是一个离散“微分器”：

$$
y[k]=x[k]-x[k-1]
$$

它的输出等于当前样本与前一个样本之差。若 $x[k]$ 代表一个随时间变化的信号，这个差值就近似表示变化趋势，所以叫 dérivateur。

一般的离散线性时不变系统可以用差分方程表示：

$$
y[k]
=-\sum_{i=1}^{n}\beta_i y[k-i]
+\sum_{j=0}^{m}\alpha_j x[k-j]
$$

每一项的意思是：

- $x[k-j]$：过去第 $j$ 个输入样本。
- $y[k-i]$：过去第 $i$ 个输出样本。
- $\alpha_j$：输入样本的加权系数。
- $\beta_i$：反馈输出样本的加权系数。

如果系统只由输入样本组成，例如：

$$
y[k]=\alpha_0x[k]+\alpha_1x[k-1]+\cdots+\alpha_mx[k-m]
$$

它没有输出反馈，通常对应有限冲激响应 FIR/RIF。

如果系统包含过去输出，例如：

$$
y[k]=-\beta_1y[k-1]+\alpha_0x[k]
$$

它有递归结构，通常对应无限冲激响应 IIR/RII。

## p.5 采样输入、连续输出：零阶保持

这一页讲 $x$ échantillonné et $y$ continu，也就是输入是样本序列，输出要变回连续时间信号。

PPT 中的 bloqueur 是零阶保持器，英文是 zero-order hold。它做的事情很简单：每拿到一个样本值，就把这个值保持一个采样周期。

如果样本是 $x[k]$，零阶保持输出 $y(t)$ 大致满足：

$$
y(t)=x[k],\quad kT_e\le t<(k+1)T_e
$$

所以输出是阶梯状波形，而不是平滑曲线。

零阶保持在实际系统中很常见：

- DAC 输出后会保持每个数字样本对应的模拟电平。
- 采样保持电路在 ADC 转换期间保持输入值不变。

这也带来一个重要后果：保持器本身有频率响应，不是理想透明的。后面 p.29-p.31 会推导它的传递函数 $T_B(p)$ 和 sinc 形状的幅频响应。

## p.6 采样可以建模为乘以 Dirac 梳

PPT 现在正式建立采样模型。

连续信号是 $x(t)$。采样时刻是：

$$
t=nT_e,\quad n\in\mathbb{Z}
$$

定义 Dirac 梳，也叫 peigne de Dirac：

$$
\operatorname{III}_{T_e}(t)=\sum_{n=-\infty}^{+\infty}\delta(t-nT_e)
$$

那么采样信号可以写作：

$$
x^\ast(t)=x(t)\operatorname{III}_{T_e}(t)
$$

利用 Dirac 的抽样性质：

$$
x(t)\delta(t-nT_e)=x(nT_e)\delta(t-nT_e)
$$

所以：

$$
x^\ast(t)
=\sum_{n=-\infty}^{+\infty}x(nT_e)\delta(t-nT_e)
$$

这条公式非常重要。它说明采样不是“简单删掉中间点”这么粗糙，而可以被严谨建模成：每个采样时刻放一个 Dirac 冲激，冲激面积等于该时刻的信号值。

## p.7-p.10 正弦信号例子：为什么会混叠

PPT 构造两个连续正弦信号：

$$
x_1(t)=\cos(2\pi f_1t)
$$

$$
x_2(t)=\cos(2\pi f_2t)
$$

采样频率为：

$$
f_e=\frac{1}{T_e}
$$

并取：

$$
f_2=f_e+f_1
$$

采样 $x_1(t)$ 得到：

$$
x_1^\ast(t)
=\sum_{n=-\infty}^{+\infty}
\cos(2\pi f_1nT_e)\delta(t-nT_e)
$$

采样 $x_2(t)$ 得到：

$$
x_2^\ast(t)
=\sum_{n=-\infty}^{+\infty}
\cos(2\pi f_2nT_e)\delta(t-nT_e)
$$

把 $f_2=f_e+f_1$ 代入：

$$
\cos(2\pi f_2nT_e)
=\cos(2\pi(f_e+f_1)nT_e)
$$

由于：

$$
f_eT_e=1
$$

所以：

$$
2\pi f_enT_e=2\pi n
$$

于是：

$$
\cos(2\pi f_2nT_e)
=\cos(2\pi n+2\pi f_1nT_e)
=\cos(2\pi f_1nT_e)
$$

因此：

$$
x_2^\ast(t)=x_1^\ast(t)
$$

这就是混叠 aliasing 的本质：两个不同频率的连续信号，采样以后可能产生完全相同的样本序列。

PPT 图中的例子是：

$$
f_e=10\,\mathrm{Hz}
$$

$$
f_1=3\,\mathrm{Hz}
$$

$$
f_2=13\,\mathrm{Hz}=10+3
$$

所以 $3\,\mathrm{Hz}$ 和 $13\,\mathrm{Hz}$ 在 $10\,\mathrm{Hz}$ 采样下无法区分。采样点落在两条连续曲线的同一组位置上，离散系统只看到这些点，所以会以为它们是同一个信号。

## p.11 Dirac 梳的频域形式

PPT 说明 Dirac 梳在频域里仍然是 Dirac 梳。利用 Fourier 级数可以得到：

$$
\operatorname{III}_{T_e}(t)
=f_e\sum_{n=-\infty}^{+\infty}e^{j2\pi nf_et}
$$

它的 Fourier 变换是：

$$
\mathcal{F}\{\operatorname{III}_{T_e}(t)\}
=f_e\sum_{n=-\infty}^{+\infty}\delta(f-nf_e)
$$

也就是说：

- 时间域中每隔 $T_e$ 一个冲激。
- 频域中每隔 $f_e$ 一个冲激。

这对后面很关键，因为采样在时间域是：

$$
x^\ast(t)=x(t)\operatorname{III}_{T_e}(t)
$$

而“时间域相乘”会变成“频域卷积”。

## p.12 采样导致频谱周期复制

由上一页：

$$
x^\ast(t)=x(t)\operatorname{III}_{T_e}(t)
$$

时间域相乘对应频域卷积：

$$
X^\ast(f)=X(f)\ast \mathcal{F}\{\operatorname{III}_{T_e}(t)\}
$$

又因为：

$$
\mathcal{F}\{\operatorname{III}_{T_e}(t)\}
=f_e\sum_{n=-\infty}^{+\infty}\delta(f-nf_e)
$$

所以：

$$
X^\ast(f)
=X(f)\ast f_e\sum_{n=-\infty}^{+\infty}\delta(f-nf_e)
$$

卷积 Dirac 的效果是平移，因此：

$$
X^\ast(f)
=f_e\sum_{n=-\infty}^{+\infty}X(f-nf_e)
$$

这就是整讲最重要的公式。它说明采样后的频谱不是只保留一份 $X(f)$，而是把 $X(f)$ 以 $f_e$ 为周期无限复制。

所以 PPT 结论是：

> Le spectre de $X^\ast(f)$ est infini et périodisé avec une période $f_e$.

中文就是：采样信号的频谱是无限延展的，并且以采样频率 $f_e$ 为周期。

## p.13 当 $f_e>2B_w$ 时：频谱副本不重叠

设原信号是带限的：

$$
X(f)=0,\quad |f|>B_w
$$

采样后频谱副本中心分别在：

$$
0,\ \pm f_e,\ \pm 2f_e,\ldots
$$

如果：

$$
f_e>2B_w
$$

那么每个频谱副本之间不会重叠。图中绿色区域在 $-B_w$ 到 $B_w$，复制到 $\pm f_e$ 后仍然和原始频谱分开。

这时可以用一个理想低通滤波器把中心那一份取出来：

$$
X(f)\quad \text{from}\quad X^\ast(f)
$$

所以采样可以无损恢复。

## p.14 当 $f_e<2B_w$ 时：频谱副本重叠

如果：

$$
f_e<2B_w
$$

则相邻频谱副本互相重叠。重叠后低频部分里会混入高频副本折叠过来的成分，这就是 repliement，也就是混叠。

一旦混叠发生，单靠采样后的离散序列无法判断某个低频成分到底是真的低频，还是高频折叠下来的。

这也是为什么 ADC 前需要 analog anti-aliasing filter。它必须在采样之前把超过 Nyquist 范围的高频分量衰减掉。

## p.15-p.16 比较两个采样频率

PPT 用两个采样频率比较频谱复制的密集程度。

采样频谱公式仍然是：

$$
X^\ast(f)=f_e\sum_{n=-\infty}^{+\infty}X(f-nf_e)
$$

### 第一种情况：$f_e=f_1$

采样频率较低，频谱副本间距就是 $f_1$。图中 $n=-2,-1,0,1,2$ 的副本很密，容易重叠。

### 第二种情况：$f_e=2f_1$

采样频率变大，副本之间间距变成 $2f_1$。图中副本更稀疏，重叠风险降低。

这一页想让你形成直觉：**采样频率越高，频域副本隔得越远；采样频率越低，副本越挤，越容易 aliasing。**

## p.17 $z$ 变换定义

连续时间系统用 Laplace 变换：

$$
X(p)=\int x(t)e^{-pt}\,dt
$$

离散时间系统用 $z$ 变换：

$$
X(z)=\mathcal{Z}\{x[n]\}
=\sum_{n=-\infty}^{+\infty}x[n]z^{-n}
$$

这是一种双边 $z$ 变换写法。如果系统和信号是因果的，也常用单边形式：

$$
X(z)=\sum_{n=0}^{+\infty}x[n]z^{-n}
$$

$z$ 变换的作用和 Laplace 变换类似：

- Laplace 变换适合连续时间系统。
- $z$ 变换适合离散时间系统。

离散系统的差分方程在 $z$ 域里会变成代数方程，就像连续系统的微分方程在 $p$ 域里变成代数方程一样。

## p.18 $z$ 变换的性质

### 线性

$$
\mathcal{Z}\{a x_1[n]+b x_2[n]\}
=aX_1(z)+bX_2(z)
$$

### 延迟

延迟 $k$ 个样本：

$$
\mathcal{Z}\{x[n-k]\}=z^{-k}X(z)
$$

这条性质很重要，因为差分方程里全是 $x[k-j]$ 和 $y[k-i]$。每延迟一个采样点，就会多一个 $z^{-1}$。

例如：

$$
y[k]=x[k]-x[k-1]
$$

做 $z$ 变换：

$$
Y(z)=X(z)-z^{-1}X(z)
$$

所以系统函数是：

$$
H(z)=\frac{Y(z)}{X(z)}=1-z^{-1}
$$

### 卷积

离散 LTI 系统：

$$
y[n]=x[n]\ast h[n]
$$

$z$ 域中：

$$
Y(z)=X(z)H(z)
$$

这和第一讲中：

$$
Y(p)=X(p)H(p)
$$

完全平行。

## p.19-p.20 练习 2：从采样信号推导 $Z=e^{pT_e}$

PPT 的练习问三件事：

1. 写出采样信号 $x^\ast(t)$。
2. 求它的 Laplace 变换，再和 $z$ 变换比较。
3. 推出 $z$ 与 $p$ 的关系，以及离散时间稳定条件。

对因果信号，从 $n=0$ 开始：

$$
x^\ast(t)=\sum_{n=0}^{+\infty}x(nT_e)\delta(t-nT_e)
$$

Laplace 变换：

$$
X^\ast(p)
=\int_0^{+\infty}x^\ast(t)e^{-pt}\,dt
$$

代入 Dirac 表达式：

$$
X^\ast(p)
=\sum_{n=0}^{+\infty}x(nT_e)e^{-pnT_e}
$$

$z$ 变换写作：

$$
X(z)=\sum_{n=0}^{+\infty}x[n]z^{-n}
$$

而：

$$
x[n]=x(nT_e)
$$

所以：

$$
X(z)=\sum_{n=0}^{+\infty}x(nT_e)z^{-n}
$$

比较：

$$
z^{-n}=e^{-pnT_e}
$$

得到：

$$
z=e^{pT_e}
$$

这就是连续 $p$ 平面和离散 $z$ 平面的核心映射。

## p.21 连续稳定性到离散稳定性的映射

连续时间系统稳定时，极点满足：

$$
p=-\lambda+j\omega
$$

其中：

$$
\lambda>0
$$

也就是：

$$
\operatorname{Re}(p)<0
$$

通过：

$$
z=e^{pT_e}
$$

得到：

$$
z=e^{(-\lambda+j\omega)T_e}
=e^{-\lambda T_e}e^{j\omega T_e}
$$

其模长是：

$$
|z|=e^{-\lambda T_e}
$$

因为 $\lambda>0$，所以：

$$
|z|<1
$$

因此：

$$
\operatorname{Re}(p)<0
\quad \Longleftrightarrow \quad
|z|<1
$$

这就是为什么连续系统稳定看左半平面，而离散系统稳定看单位圆内部。

更完整地说：

- $p$ 左半平面 $\operatorname{Re}(p)<0$ 映射到 $z$ 平面单位圆内 $|z|<1$。
- $p$ 虚轴 $\operatorname{Re}(p)=0$ 映射到 $z$ 平面单位圆 $|z|=1$。
- $p$ 右半平面 $\operatorname{Re}(p)>0$ 映射到 $z$ 平面单位圆外 $|z|>1$。

## p.22 离散系统稳定性

### 时间域稳定性

离散滤波器 $h[n]$ 是 EBSB/BIBO 稳定，当且仅当冲激响应绝对可和：

$$
\sum_{n=-\infty}^{+\infty}|h[n]|<+\infty
$$

如果是因果系统，常写成：

$$
\sum_{n=0}^{+\infty}|h[n]|<+\infty
$$

### $z$ 域稳定性

离散系统 $H(z)$ 是 EBSB 稳定，当且仅当所有极点都在单位圆内部：

$$
|z_i|<1
$$

### 广义稳定

如果系统有一阶极点在单位圆上：

$$
|z_i|=1
$$

则可以是 stable au sens large，也就是广义稳定。它对应持续振荡或不衰减但有界的情况。

但如果单位圆上的极点阶数大于 $1$，或者有极点在单位圆外：

$$
|z_i|>1
$$

系统会发散。

## p.23 极点图：Laplace 平面与 $z$ 平面

这页是图示总结：

- 连续时间 Laplace 平面中，稳定区域是左半平面。
- 离散时间 $z$ 平面中，稳定区域是单位圆内部。

映射关系是：

$$
z=e^{pT_e}
$$

如果：

$$
p=\sigma+j\omega
$$

则：

$$
z=e^{\sigma T_e}e^{j\omega T_e}
$$

所以：

- $\sigma$ 控制 $z$ 的半径：

$$
|z|=e^{\sigma T_e}
$$

- $\omega$ 控制 $z$ 的角度：

$$
\arg(z)=\omega T_e
$$

这也是为什么离散系统频率响应通常在单位圆上看：

$$
z=e^{j\omega T_e}
$$

## p.24 连续系统与离散系统对照

PPT 把第一讲和这一讲的工具并排比较。

### 时间域

连续系统：

$$
y(t)=x(t)\ast h(t)
$$

离散系统：

$$
y[n]=x[n]\ast h[n]
$$

### 变换域

连续系统：

$$
Y(p)=X(p)H(p)
$$

离散系统：

$$
Y(z)=X(z)H(z)
$$

### 变量映射

连续到离散：

$$
z=e^{pT_e}
$$

### 频率响应

连续系统频率响应：

$$
H(j\omega)=H(p)\vert_{p=j\omega}
$$

离散系统频率响应：

$$
H(e^{j\omega T_e})=H(z)\vert_{z=e^{j\omega T_e}}
$$

这页的意义是：你可以把离散系统看作连续系统分析方法的平行版本，只是稳定区域、变量和频率轴的表达变了。

## p.25-p.28 练习 1：ECG 信号与 50 Hz 干扰

PPT 给出一个 ECG 信号频谱：

- 有用信号在大约 $[-30,30]\,\mathrm{Hz}$。
- 有一个 $50\,\mathrm{Hz}$ 附近的干扰，画在 $48$ 到 $52\,\mathrm{Hz}$。

### 问题 1：由频谱对称性判断时间信号性质

题目说：

- 模 $T(\omega)$ 是偶函数。
- 相位 $\phi(\omega)$ 是奇函数。

写频谱为：

$$
X(j\omega)=T(\omega)e^{j\phi(\omega)}
$$

如果：

$$
T(-\omega)=T(\omega)
$$

并且：

$$
\phi(-\omega)=-\phi(\omega)
$$

那么：

$$
X(-j\omega)=X^\ast(j\omega)
$$

这正是实信号 Fourier 变换的共轭对称性质。所以可以推出：

$$
x(t)\in \mathbb{R}
$$

也就是 ECG 是实信号。

PPT 用 Fourier 逆变换也说明了这一点：

$$
x(t)
=\frac{1}{2\pi}\int_{-\infty}^{+\infty}
T(\omega)e^{j\phi(\omega)}e^{j\omega t}\,d\omega
$$

把 $\omega<0$ 和 $\omega>0$ 两部分合并后，会得到余弦形式：

$$
x(t)
=\frac{1}{2\pi}\int_0^{+\infty}
2T(\omega)\cos(\phi(\omega)+\omega t)\,d\omega
$$

这个表达式是实数，因此 $x(t)$ 为实信号。

### 问题 2：$f_e=70\,\mathrm{Hz}$ 采样后的频谱

采样后频谱复制：

$$
X^\ast(f)=f_e\sum_{n=-\infty}^{+\infty}X(f-nf_e)
$$

当：

$$
f_e=70\,\mathrm{Hz}
$$

原本 $48$ 到 $52\,\mathrm{Hz}$ 的 50 Hz 干扰会在采样频谱中出现副本。特别是从 $f_e=70$ 附近折叠回来：

$$
70-52=18
$$

$$
70-48=22
$$

所以 $48$ 到 $52\,\mathrm{Hz}$ 的干扰会折叠到：

$$
18\text{ 到 }22\,\mathrm{Hz}
$$

而 ECG 有用信号覆盖：

$$
-30\text{ 到 }30\,\mathrm{Hz}
$$

所以折叠后的干扰落进有用频带内部，造成混叠污染。

### 问题 3：如何避免混叠

PPT 给出两种办法。

第一种：采样前做模拟滤波。也就是在 ADC 前加 anti-aliasing filter，把 $50\,\mathrm{Hz}$ 干扰先衰减掉，再采样。

第二种：提高采样频率。PPT 写需要采样频率大于 $82\,\mathrm{Hz}$，原因是要避免 $48$ 到 $52\,\mathrm{Hz}$ 的干扰副本落进 $[-30,30]\,\mathrm{Hz}$ 有用频带。

看正频率折叠，干扰会从 $f_e-52$ 到 $f_e-48$ 这段折回来。为了不落入 $30\,\mathrm{Hz}$ 以下，需要：

$$
f_e-52>30
$$

即：

$$
f_e>82\,\mathrm{Hz}
$$

然后可以再用数字滤波处理。

## p.29-p.31 练习 3：采样与零阶保持器

这一题研究 bloqueur，也就是零阶保持器。

图中有三种信号：

- $x(t)$：原连续信号。
- $x^\ast(t)$：用 Dirac 冲激表示的采样信号。
- $x_{EB}(t)$：经过 bloqueur 后的阶梯状信号。

### 问题 1：用样本和阶跃函数表示保持器输出

定义一个矩形脉冲：

$$
p(t)=u(t)-u(t-T_e)
$$

它在 $[0,T_e]$ 内等于 $1$，其他地方等于 $0$。

零阶保持就是把每个样本 $x(nT_e)$ 拉成一个宽度为 $T_e$ 的矩形。因此：

$$
x_{EB}(t)
=\left(\sum_{n=0}^{+\infty}x(nT_e)\delta(t-nT_e)\right)\ast p(t)
$$

也就是：

$$
x_{EB}(t)=x^\ast(t)\ast p(t)
$$

这个式子很直观：采样信号是一串冲激，和矩形脉冲卷积后，每个冲激都会变成一个矩形平台。

### 问题 2：保持器的 Laplace 传递函数

由卷积性质：

$$
X_{EB}(p)=X^\ast(p)T_B(p)
$$

其中 $T_B(p)$ 是保持器的传递函数。因为：

$$
p(t)=u(t)-u(t-T_e)
$$

所以：

$$
T_B(p)
=\mathcal{L}\{u(t)\}-\mathcal{L}\{u(t-T_e)\}
$$

利用：

$$
\mathcal{L}\{u(t)\}=\frac{1}{p}
$$

以及：

$$
\mathcal{L}\{u(t-T_e)\}=\frac{e^{-pT_e}}{p}
$$

得到：

$$
T_B(p)=\frac{1-e^{-pT_e}}{p}
$$

这就是零阶保持器的传递函数。

### 问题 3：保持器的频率响应

令：

$$
p=j\omega
$$

则：

$$
T_B(j\omega)
=\frac{1-e^{-j\omega T_e}}{j\omega}
$$

又因为：

$$
\omega=2\pi f
$$

所以：

$$
T_B(j\omega)
=\frac{1-e^{-j2\pi fT_e}}{j2\pi f}
$$

把分子改写成对称形式：

$$
1-e^{-j2\pi fT_e}
=e^{-j\pi fT_e}
\left(e^{j\pi fT_e}-e^{-j\pi fT_e}\right)
$$

而：

$$
e^{j\theta}-e^{-j\theta}=2j\sin\theta
$$

于是：

$$
T_B(j\omega)
=e^{-j\pi fT_e}\frac{\sin(\pi fT_e)}{\pi f}
$$

幅值为：

$$
|T_B(j\omega)|
=\left|\frac{\sin(\pi fT_e)}{\pi f}\right|
$$

也可写成：

$$
|T_B(j\omega)|
=\left|T_e\,\mathrm{sinc}(\pi fT_e)\right|
$$

如果采用标准归一化 sinc：

$$
\mathrm{sinc}(x)=\frac{\sin x}{x}
$$

那么：

$$
\frac{\sin(\pi fT_e)}{\pi f}
=T_e\frac{\sin(\pi fT_e)}{\pi fT_e}
=T_e\,\mathrm{sinc}(\pi fT_e)
$$

这个结果说明零阶保持器不是理想低通。它的幅频响应有 sinc 形状，会在高频处逐渐衰减，并且在：

$$
f=\frac{1}{T_e}=f_e
$$

以及其整数倍附近出现零点。

所以实际采样-保持链路中，保持器会带来 amplitude droop，也就是频率越高保持器衰减越明显。

## 这一讲真正要串起来的东西

第二讲的主线是：

$$
x(t)
\xrightarrow{\times \operatorname{III}_{T_e}(t)}
x^\ast(t)
\xrightarrow{\mathcal{F}}
X^\ast(f)=f_e\sum_n X(f-nf_e)
$$

也就是：

- 时间域采样 = 乘以 Dirac 梳。
- 频域效果 = 原频谱以 $f_e$ 为周期复制。
- 若 $f_e>2B_w$，副本不重叠，可恢复。
- 若 $f_e<2B_w$，副本重叠，发生混叠。

离散系统分析的主线是：

$$
y[n]=x[n]\ast h[n]
\xrightarrow{\mathcal{Z}}
Y(z)=X(z)H(z)
$$

并且连续和离散变量之间有：

$$
z=e^{pT_e}
$$

所以稳定区域从：

$$
\operatorname{Re}(p)<0
$$

映射成：

$$
|z|<1
$$

最后，零阶保持器的频率响应：

$$
T_B(p)=\frac{1-e^{-pT_e}}{p}
$$

$$
|T_B(j\omega)|=
\left|\frac{\sin(\pi fT_e)}{\pi f}\right|
$$

说明采样后再保持成连续波形时，系统本身也会改变频谱。

