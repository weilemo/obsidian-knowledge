
> 课程：ICE4405P Digital Signal Processing  
> 讲义：`PPT/Chap.3-SamplingandReconstruction.pdf`（共 59 页）

## 0. 本章主线（先建立全局图）

连续时间信号进入 DSP 系统的典型路径：

$$
 x_c(t) \xrightarrow{\text{Sampling }T} x[n] \xrightarrow{H(e^{j\omega})} y[n] \xrightarrow{\text{DAC + Reconstruction}} y_c(t)
$$

本章核心要解决 4 个问题：

1. 连续时间采样后，时域和频域分别发生什么变化。
2. 什么条件下能从样本完美重建原连续时间信号。
3. 数字系统频响如何映射成连续时间等效频响。
4. 如何做采样率变换（降采样、升采样、以及有理数 $L/M$ 变换）。

---

## 1. 符号与频率单位统一

### 1.1 采样参数

$$
T = \text{sampling period (s)},\quad f_s = \frac{1}{T}\;\text{(Hz)},\quad \Omega_s = 2\pi f_s = \frac{2\pi}{T}\;\text{(rad/s)}
$$

### 1.2 连续时间与离散时间频率对应

$$
\omega = \Omega T
$$

- $\Omega$：连续时间角频率，单位 rad/s。
- $\omega$：离散时间角频率，单位 rad/sample，且以 $2\pi$ 为周期。

---

## 2. 3.1–3.2：周期采样模型（时域）

### 2.1 从 $x_c(t)$ 到样本序列

$$
x[n] = x_c(nT),\quad n\in\mathbb{Z}
$$

### 2.2 冲激列采样模型（分析核心）

采样冲激列：

$$
s(t) = \sum_{n=-\infty}^{\infty}\delta(t-nT)
$$

冲激采样信号：

$$
x_s(t) = x_c(t)s(t) = \sum_{n=-\infty}^{\infty}x_c(nT)\delta(t-nT) = \sum_{n=-\infty}^{\infty}x[n]\delta(t-nT)
$$

关键区分：

- $x[n]$ 是序列（DSP 处理对象）。
- $x_s(t)$ 是连续时间冲激串（频域推导对象）。

---

## 3. 3.3：采样的频域本质（频谱复制 + 混叠）

### 3.1 采样冲激列的 CTFT

$$
S(j\Omega) = \frac{2\pi}{T}\sum_{k=-\infty}^{\infty}\delta(\Omega-k\Omega_s)
$$

#### 补充：为什么“周期信号的频谱只在谐波上有线谱”

设任意周期信号 $x_p(t)$ 周期为 $T_0$，基频为：

$$
\Omega_0=\frac{2\pi}{T_0}
$$

它可写成傅里叶级数：

$$
x_p(t)=\sum_{k=-\infty}^{\infty}c_k e^{jk\Omega_0 t}
$$

再用变换对

$$
e^{j\Omega_1 t}\xleftrightarrow{\mathcal{F}}2\pi\delta(\Omega-\Omega_1)
$$

可得

$$
X_p(j\Omega)=2\pi\sum_{k=-\infty}^{\infty}c_k\delta(\Omega-k\Omega_0)
$$

这说明：周期信号的频谱只出现在 $k\Omega_0$（谐波）这些离散频率点上。

对采样冲激列 $s(t)=\sum_n\delta(t-nT)$，其周期为 $T$，故谐波间隔是 $\Omega_s=2\pi/T$。  
并且其傅里叶级数系数

$$
c_k=\frac{1}{T}\int_{t_0}^{t_0+T}s(t)e^{-jk\Omega_s t}\,dt=\frac{1}{T}
$$

所以

$$
S(j\Omega)=\frac{2\pi}{T}\sum_{k=-\infty}^{\infty}\delta(\Omega-k\Omega_s)
$$

### 3.2 冲激采样后的频谱

$$
X_s(j\Omega) = \frac{1}{2\pi}X_c(j\Omega) * S(j\Omega)
$$

$$
X_s(j\Omega) = \frac{1}{T}\sum_{k=-\infty}^{\infty}X_c\big(j(\Omega-k\Omega_s)\big)
$$

#### 补充：把 $S(j\Omega)$ 代入的完整过程（逐步展开）

先写

$$
X_s(j\Omega)=\frac{1}{2\pi}\,X_c(j\Omega)*S(j\Omega)
$$

代入

$$
S(j\Omega)=\frac{2\pi}{T}\sum_{k=-\infty}^{\infty}\delta(\Omega-k\Omega_s)
$$

得到

$$
X_s(j\Omega)
=\frac{1}{2\pi}X_c(j\Omega)*\left(\frac{2\pi}{T}\sum_{k=-\infty}^{\infty}\delta(\Omega-k\Omega_s)\right)
=\frac{1}{T}\sum_{k=-\infty}^{\infty}\left[X_c(j\Omega)*\delta(\Omega-k\Omega_s)\right]
$$

再用卷积移位性质

$$
F(\Omega)*\delta(\Omega-\Omega_0)=F(\Omega-\Omega_0)
$$

等价地，也可直接用积分看一步：

$$
\left[X_c(j\Omega)*\delta(\Omega-k\Omega_s)\right]
=\int_{-\infty}^{\infty}X_c(j\lambda)\,\delta\!\big(\Omega-\lambda-k\Omega_s\big)\,d\lambda
=X_c\big(j(\Omega-k\Omega_s)\big)
$$

所以最终

$$
X_s(j\Omega)=\frac{1}{T}\sum_{k=-\infty}^{\infty}X_c\big(j(\Omega-k\Omega_s)\big)
$$

这就对应“每隔 $\Omega_s$ 把原谱平移复制一份，再全部相加”。

解释：原频谱以间隔 $\Omega_s$ 被周期复制。

### 3.3 Nyquist 条件与混叠

若 $x_c(t)$ 带限到 $|\Omega|\le \Omega_N$，无混叠条件为：

$$
\Omega_s > 2\Omega_N
$$

等价于：

$$
f_s > 2f_{\max}
$$

若 $\Omega_s \le 2\Omega_N$，频谱副本重叠，出现 aliasing（混叠），不同连续频率映射到同一离散频率，信息不可逆丢失。

### 3.4 余弦采样混叠直观

$$
x_c(t)=\cos(\Omega_0 t)\;\Rightarrow\;x[n]=\cos(\Omega_0 nT)=\cos(\omega_0 n),\;\omega_0=\Omega_0T
$$

因为离散频率按 $2\pi$ 取模，不同 $\Omega_0$ 可能得到相同 $\omega_0$。
当 $\Omega_s > \Omega_0 > \Omega_s/2$ 时，重建后会落到折叠频率：

$$
x_r(t)=\cos\big((\Omega_s-\Omega_0)t\big)
$$

#### 补充推导：余弦采样后频谱为什么会“折叠”

先写带相位的一般形式：

$$
x_c(t)=A\cos(\Omega_0 t+\phi)
$$

采样定义是

$$
x[n]=x_c(nT)=A\cos(\Omega_0 nT+\phi)=A\cos(\omega_0 n+\phi),\quad \omega_0=\Omega_0T
$$

用欧拉公式展开：

$$
x[n]=\frac{A}{2}e^{j\phi}e^{j\omega_0 n}+\frac{A}{2}e^{-j\phi}e^{-j\omega_0 n}
$$

根据 DTFT 基本对

$$
e^{j\omega_0 n}\xleftrightarrow{\text{DTFT}}2\pi\sum_{k=-\infty}^{\infty}\delta(\omega-\omega_0-2\pi k)
$$

$$
e^{-j\omega_0 n}\xleftrightarrow{\text{DTFT}}2\pi\sum_{k=-\infty}^{\infty}\delta(\omega+\omega_0-2\pi k)
$$

得到

$$
\begin{aligned}
X(e^{j\omega})
&=\pi A e^{j\phi}\sum_{k=-\infty}^{\infty}\delta(\omega-\omega_0-2\pi k)\\
&\quad+\pi A e^{-j\phi}\sum_{k=-\infty}^{\infty}\delta(\omega+\omega_0-2\pi k).
\end{aligned}
$$

这说明离散频谱在 $\pm\omega_0$ 处有谱线，并以 $2\pi$ 周期重复。

#### 为什么不同连续频率会映射成同一离散频率

离散域中

$$
\omega_0'=\omega_0+2\pi m,\quad m\in\mathbb{Z}
$$

对应同一序列，因为

$$
e^{j(\omega_0+2\pi m)n}=e^{j\omega_0 n}e^{j2\pi mn}=e^{j\omega_0 n}.
$$

又因为 $\omega_0=\Omega_0T$，可写成连续频率等价关系：

$$
\Omega_0'=\Omega_0+m\Omega_s,\quad \Omega_s=\frac{2\pi}{T}.
$$

这就是“采样后频率按 $\Omega_s$ 折叠/等价”的来源。

#### 折叠到基带的具体公式

当

$$
\Omega_s>\Omega_0>\frac{\Omega_s}{2}
$$

时，离散频率

$$
\omega_0=\Omega_0T\in(\pi,2\pi)
$$

将等价为

$$
\omega_a=2\pi-\omega_0\in(0,\pi).
$$

换回连续频率：

$$
\Omega_a=\frac{\omega_a}{T}=\frac{2\pi-\Omega_0T}{T}=\Omega_s-\Omega_0.
$$

因此重建后观测到的频率为

$$
x_r(t)=A\cos(\Omega_a t+\phi_a),\quad \Omega_a=\Omega_s-\Omega_0.
$$

其中相位 $\phi_a$ 由采样序列等价变换决定（例如可通过
$\cos(\omega_0 n+\phi)=\cos((2\pi-\omega_0)n-\phi)$ 求得）。

---

## 4. 3.4：$X(e^{j\omega})$、$X_c(j\Omega)$、$X_s(j\Omega)$ 的关系

DTFT 定义：

$$
X(e^{j\omega})=\sum_{n=-\infty}^{\infty}x[n]e^{-j\omega n}
$$

由冲激采样信号：

$$
X_s(j\Omega)=\int_{-\infty}^{\infty}x_s(t)e^{-j\Omega t}\,dt
=\sum_{n=-\infty}^{\infty}x[n]e^{-j\Omega nT}
$$

因此：

$$
X_s(j\Omega)=X(e^{j\omega})\Big|_{\omega=\Omega T}
\quad\Leftrightarrow\quad
X(e^{j\omega})=X_s\!\left(j\frac{\omega}{T}\right)
$$

再代入频谱复制公式：

$$
X(e^{j\omega})
=\frac{1}{T}\sum_{k=-\infty}^{\infty}
X_c\!\left(j\frac{\omega-2\pi k}{T}\right)
$$
 
要点：

- $X(e^{j\omega})$ 天生 $2\pi$ 周期。
- “离散域混叠”本质就是连续域副本在求和中叠加。

---

## 5. 3.5：带限信号理想重建

### 5.1 理想重建滤波器

重建结构：

$$
x_r(t)=x_s(t)*h_r(t)
$$

理想低通重建滤波器：

$$
H_r(j\Omega)=
\begin{cases}
T,& |\Omega|\le\Omega_c\\
0,& \text{otherwise}
\end{cases}
\quad\text{其中}\quad
\Omega_N<\Omega_c<\Omega_s-\Omega_N
$$

当无混叠时可恢复：

$$
X_r(j\Omega)=X_c(j\Omega)\Rightarrow x_r(t)=x_c(t)
$$

### 5.2 sinc 插值形式

$$
h_r(t)=\frac{T}{2\pi}\int_{-\Omega_c}^{\Omega_c}e^{j\Omega t}\,d\Omega
= T\frac{\sin(\Omega_c t)}{\pi t}
$$

取常见截止 $\Omega_c=\Omega_s/2=\pi/T$：

$$
h_r(t)=\frac{\sin(\pi t/T)}{\pi t/T}=\operatorname{sinc}\!\left(\frac{t}{T}\right)
$$

于是重建公式（Whittaker-Shannon 插值）：

$$
x_r(t)=\sum_{n=-\infty}^{\infty}x[n]\,\operatorname{sinc}\!\left(\frac{t}{T}-n\right)
$$

---

## 6. 3.6：连续时间信号的离散处理（等效频响）

系统链路：

$$
x_c(t)\xrightarrow{C/D}x[n]\xrightarrow{H(e^{j\omega})}y[n]\xrightarrow{D/C}y_c(t)
$$

在理想采样与理想重建、且无混叠前提下：

$$
Y_c(j\Omega)=H(e^{j\Omega T})X_c(j\Omega),\quad |\Omega|<\frac{\pi}{T}
$$

结论：数字滤波器通过映射 $\omega=\Omega T$ 实现连续时间滤波行为。改 $T$ 会改变等效模拟截止频率。

---

## 7. 3.7：降采样（Decimation）

### 7.1 定义

按整数 $M$ 降采样：

$$
x_d[n]=x[nM]
$$

若原序列由 $x_c(nT)$ 得来，则新采样周期 $T'=MT$，采样率降为原来的 $1/M$。

### 7.2 频域关系

$$
X_d(e^{j\omega})=
\frac{1}{M}\sum_{k=0}^{M-1}
X\!\left(e^{j\left(\frac{\omega}{M}-\frac{2\pi k}{M}\right)}\right)
$$

解释：频谱先压缩，再叠加 $M$ 份平移副本，易混叠。

#### 补充：从定义推导到 7.2 公式（整理版）

Step 1: 从定义出发

$$
x_d[n]=x[nM],\qquad
X_d(e^{j\omega})=\sum_{n=-\infty}^{\infty}x[nM]e^{-j\omega n}
$$

Step 2: 代入逆 DTFT 并交换求和积分

$$
x[nM]=\frac{1}{2\pi}\int_{-\pi}^{\pi}X(e^{j\theta})e^{j\theta nM}\,d\theta
$$

$$
\begin{aligned}
X_d(e^{j\omega})
&=\frac{1}{2\pi}\int_{-\pi}^{\pi}X(e^{j\theta})
\left(\sum_{n=-\infty}^{\infty}e^{-jn(\omega-M\theta)}\right)d\theta
\end{aligned}
$$

Step 3: 用指数和恒等式（分布意义）

$$
\sum_{n=-\infty}^{\infty}e^{-jn\alpha}
=2\pi\sum_{r=-\infty}^{\infty}\delta(\alpha-2\pi r)
$$

得到

$$
\begin{aligned}
X_d(e^{j\omega})
&=\int_{-\pi}^{\pi}X(e^{j\theta})
\sum_{r=-\infty}^{\infty}\delta(\omega-M\theta-2\pi r)\,d\theta\\
&=\frac{1}{M}\int_{-\pi}^{\pi}X(e^{j\theta})
\sum_{r=-\infty}^{\infty}\delta\!\left(\theta-\frac{\omega-2\pi r}{M}\right)d\theta
\end{aligned}
$$

这里用到冲激缩放：

$$
\delta(a\theta-b)=\frac{1}{|a|}\delta\!\left(\theta-\frac{b}{a}\right)
$$

以及冲激抽样性质：

$$
\int f(\theta)\,\delta(\theta-\theta_0)\,d\theta=f(\theta_0)
$$

所以

$$
X_d(e^{j\omega})
=\frac{1}{M}\sum_{r=-\infty}^{\infty}
X\!\left(e^{j\frac{\omega-2\pi r}{M}}\right)
$$

Step 4: 为什么只剩 \(M\) 项（\(r=qM+k\) 分组）

令

$$
r=qM+k,\quad k=0,1,\dots,M-1,\ q\in\mathbb{Z}
$$

则

$$
\frac{\omega-2\pi r}{M}
=\frac{\omega-2\pi(qM+k)}{M}
=\frac{\omega}{M}-\frac{2\pi k}{M}-2\pi q
$$

而 \(X(e^{j\theta})\) 对 \(\theta\) 是 \(2\pi\) 周期，故同一 \(k\) 下不同 \(q\) 给出相同谱值，只需保留 \(k=0,\dots,M-1\)：

$$
X_d(e^{j\omega})=
\frac{1}{M}\sum_{k=0}^{M-1}
X\!\left(e^{j\left(\frac{\omega}{M}-\frac{2\pi k}{M}\right)}\right)
$$

#### \(M=2\) 特例

$$
\begin{aligned}
X_d(e^{j\omega})
&=\frac{1}{2}\sum_{k=0}^{1}X\!\left(e^{j\left(\frac{\omega}{2}-\pi k\right)}\right)\\
&=\frac{1}{2}\left[X(e^{j\omega/2})+X(e^{j(\omega/2-\pi)})\right]
\end{aligned}
$$

### 7.3 抗混叠条件

降采样前应限带到：

$$
|\omega|\le\frac{\pi}{M}
$$

工程结构：

$$
x[n]\xrightarrow{H_d(e^{j\omega})\;(\omega_c=\pi/M)}\tilde x[n]\xrightarrow{\downarrow M}\tilde x_d[n]
$$

否则 $\downarrow M$ 后副本重叠，失真不可逆。

---

## 8. 3.8：升采样（Interpolation）

### 8.1 零插入扩展

按整数 $L$ 升采样（扩展）定义：

$$
x_e[n]=
\begin{cases}
x[n/L],& n=0,\pm L,\pm2L,\dots\\
0,& \text{otherwise}
\end{cases}
$$

DTFT 关系：

$$
X_e(e^{j\omega})=X(e^{j\omega L})
$$

解释：频谱压缩 $L$ 倍，并产生镜像（images）。

### 8.2 插值低通滤波器

理想插值滤波器：

$$
H_i(e^{j\omega})=
\begin{cases}
L,& |\omega|\le\pi/L\\
0,& \text{otherwise}
\end{cases}
$$

时域核：

$$
h_i[n]=\operatorname{sinc}\!\left(\frac{n}{L}\right)
$$

理想插值输出：

$$
x_i[n]=\sum_{k=-\infty}^{\infty}x[k]\,\operatorname{sinc}\!\left(\frac{n-kL}{L}\right)
$$

### 8.3 线性插值（实用近似）

三角核：

$$
h_{\text{lin}}[n]=
\begin{cases}
1-\frac{|n|}{L},& |n|\le L\\
0,& \text{otherwise}
\end{cases}
$$

幅频特性近似：

$$
\left|H_{\text{lin}}(e^{j\omega})\right|
=\frac{1}{L}\left(\frac{\sin(\omega L/2)}{\sin(\omega/2)}\right)^2
$$

优缺点：实现简单，但通带下垂更明显、阻带抑制弱于理想 sinc 插值。

---

## 9. 有理数采样率变换 $L/M$

标准结构：

$$
x[n]\xrightarrow{\uparrow L}x_e[n]\xrightarrow{H(e^{j\omega})}v[n]\xrightarrow{\downarrow M}y[n]
$$

滤波器需同时满足：

1. 去除升采样后的镜像（要求 $\omega_c\le\pi/L$）。
2. 防止降采样前混叠（要求 $\omega_c\le\pi/M$）。

综合可选：

$$
\omega_c\le \min\left(\frac{\pi}{L},\frac{\pi}{M}\right)
$$

常见增益取 $L$，用于幅度标定。

---

## 10. 工程案例：CD 过采样与 ZOH

CD 基础采样率：$44.1\,\text{kHz}$。

DAC 常见零阶保持（ZOH）：

$$
h_1(t)=u(t)-u(t-T)
$$

其频响：

$$
H_1(j\Omega)=T e^{-j\Omega T/2}\frac{\sin(\Omega T/2)}{\Omega T/2}
$$

对应幅度会出现 sinc 下垂（droop）。若不做过采样，模拟重建滤波器过渡带很窄，设计困难。

采用 $4\times$ 过采样（$44.1\to176.4\,\text{kHz}$）后：

- 频谱镜像被推远。
- 模拟低通滤波器可更平缓。
- 与数字插值配合，可显著减轻可听频段失真与设计成本。

---

## 11. 本章高频易错点

1. 把 $x[n]$ 与 $x_s(t)$ 混为一谈。
2. 混淆 $\Omega$（rad/s）与 $\omega$（rad/sample），忘了 $\omega=\Omega T$。
3. 记成“$f_s\ge2f_{\max}$ 总是可完美重建”，实际还依赖理想带限与理想滤波假设，工程中通常留裕量。
4. 降采样忘记先低通，直接 $\downarrow M$ 导致混叠。
5. 升采样后只做零插入不做插值滤波，镜像未去除。
6. 插值滤波器增益漏乘 $L$，导致幅度缩小。
7. 对 “离散频率模 $2\pi$ 等价” 不敏感，导致余弦采样题 alias 频率判断错误。

---

## 12. 题型模板（考试/作业可直接套）

### 模板 A：判断是否混叠

1. 先写带宽上界（连续域 $\Omega_N$ 或离散域 $\omega_N$）。
2. 写采样率/变采样因子。
3. 套条件：

$$
\Omega_s>2\Omega_N
\quad\text{或}\quad
\omega_N<\frac{\pi}{M}
$$

4. 结论给出“是否混叠 + 原因（副本是否重叠）”。

### 模板 B：写出采样后频谱

$$
X_s(j\Omega)=\frac{1}{T}\sum_{k=-\infty}^{\infty}X_c\big(j(\Omega-k\Omega_s)\big)
$$

再画（或描述）“以 $\Omega_s$ 为间隔复制”的频谱图。

### 模板 C：降采样系统设计

1. 目标：$\downarrow M$。
2. 先设计抗混叠低通：$\omega_c\le\pi/M$。
3. 再降采样并写：

$$
X_d(e^{j\omega})=
\frac{1}{M}\sum_{k=0}^{M-1}
X\!\left(e^{j\left(\frac{\omega}{M}-\frac{2\pi k}{M}\right)}\right)
$$

4. 指出“是否存在副本重叠”。

### 模板 D：升采样系统设计

1. 先 $\uparrow L$（零插入）。
2. 再插值低通（$\omega_c=\pi/L$，增益 $L$）。
3. 写结论：去镜像，恢复平滑中间样点。

---

## 13. 一页速记（考前 3 分钟）

$$
x[n]=x_c(nT),\quad \Omega_s=\frac{2\pi}{T},\quad \omega=\Omega T
$$

$$
X_s(j\Omega)=\frac{1}{T}\sum_k X_c\big(j(\Omega-k\Omega_s)\big)
$$

$$
\text{无混叠：}\Omega_s>2\Omega_N
$$

$$
X(e^{j\omega})=X_s\!\left(j\frac{\omega}{T}\right)
=\frac{1}{T}\sum_k X_c\!\left(j\frac{\omega-2\pi k}{T}\right)
$$

$$
x_r(t)=\sum_n x[n]\,\operatorname{sinc}\!\left(\frac{t}{T}-n\right)
$$

$$
\downarrow M:\quad X_d(e^{j\omega})=
\frac{1}{M}\sum_{k=0}^{M-1}X\!\left(e^{j(\omega/M-2\pi k/M)}\right),\;\omega_c\le\pi/M
$$

$$
\uparrow L:\quad X_e(e^{j\omega})=X(e^{j\omega L}),\;
H_i(e^{j\omega})=\begin{cases}L,&|\omega|\le\pi/L\\0,&\text{else}\end{cases}
$$

$$
L/M:\quad \omega_c\le\min\left(\frac{\pi}{L},\frac{\pi}{M}\right)
$$
