# Chap.8 Digital Filter Design 章节知识点总结（按 PPT 章节顺序重写）

> 课程：ICE4405P Digital Signal Processing  
> 讲义：`PPT/Chap.8-DigitalFilterDesign.pdf`（122 页）  
> 目录顺序：`8.1 -> 8.2 -> 8.3 -> 8.4 -> 8.5 -> 8.6 -> 8.7 -> 8.8 -> 8.9`

---

## 0. 本章主线（先抓核心）

本章讨论“如何从频域指标设计一个可实现的数字滤波器”。

数字滤波器是频率选择性的离散时间 LTI 系统：希望让某些频率通过，让另一些频率被衰减。实际设计通常分成三步：

1. 写出指标：通带边缘、阻带边缘、通带纹波、阻带衰减、相位或群延迟要求。  
2. 找到逼近：用一个因果、稳定、可实现的系统逼近理想频率响应。  
3. 实现系统：把 $H(z)$ 写成差分方程、级联二阶节、MATLAB/硬件/软件实现。

两条主要路线：

- IIR：从模拟滤波器原型出发，常用 Butterworth、Chebyshev、Elliptic，再用冲激响应不变法或双线性变换得到 $H(z)$。  
- FIR：直接构造有限长冲激响应，常用窗函数法、频率采样法、等波纹设计、最小二乘设计。

本章最重要的判断：

- 只关心幅频、希望阶数低：优先 IIR。  
- 要精确线性相位、稳定性简单：优先 FIR。  
- 从模拟原型到数字 IIR 时，双线性变换最常用，因为它避免频谱混叠，但要做预畸变。

---

## 1. 8.1 Approximation Techniques：从连续时间指标到离散时间指标

数字滤波器经常处在如下链路中：

$$
x_c(t)\ \longrightarrow\ \text{A/D}\ \longrightarrow\ H(z)\ \longrightarrow\ \text{D/A}\ \longrightarrow\ y_c(t)
$$

严格说，$H(z)$ 是离散时间滤波器；工程上常直接称为 digital filter。

若采样间隔为 $T$，连续时间频率 $\Omega$ 与离散时间频率 $\omega$ 的基本对应关系是：

$$
\omega = \Omega T
$$

因此，在无混叠的主频带内：

$$
H_{\mathrm{eff}}(j\Omega)=
\begin{cases}
H(e^{j\Omega T}), & |\Omega|<\pi/T\\
0, & |\Omega|\ge \pi/T
\end{cases}
$$

反过来：

$$
H(e^{j\omega})=H_{\mathrm{eff}}\left(j\frac{\omega}{T}\right),\quad |\omega|<\pi
$$

### 1.1 IIR 与 FIR 设计路线

IIR 常用方法：

- impulse invariance（冲激响应不变法）；
- bilinear transformation（双线性变换）；
- frequency-domain least squares；
- 数值求解微分方程。

FIR 常用方法：

- ideal impulse response + window（理想冲激响应截断加窗）；
- frequency sampling；
- equiripple / Parks-McClellan；
- frequency-domain least squares。

---

## 2. 8.2 Continuous-Time Filter Design Overview：模拟滤波器原型

本章的 IIR 设计大量依赖经典模拟低通原型：

$$
H_c(s)=
\frac{\sum_{m=0}^{M_c}c_m s^m}
{\sum_{k=0}^{N}d_k s^k},
\quad M_c\le N
$$

条件 $M_c\le N$ 保证 $\Omega\to\infty$ 时增益不会发散。

经典模拟幅频逼近族：

| 类型 | 幅频特点 | 适合场景 |
|---|---|---|
| Butterworth | 通带、阻带单调；通带最大平坦 | 想要平滑、无纹波响应 |
| Chebyshev Type I | 通带等波纹，阻带单调 | 可接受通带纹波，换更窄过渡带 |
| Chebyshev Type II | 通带单调，阻带等波纹 | 不想通带有纹波，但可接受阻带波纹 |
| Elliptic | 通带、阻带都有纹波 | 同阶数下过渡带最窄 |

本章主要讨论幅度响应近似，即 $|H_c(j\Omega)|$ 或 $|H(e^{j\omega})|$。

---

## 3. 8.3 Butterworth Design

## 3.1 低通幅度指标

低通滤波器的基本指标可写成：

$$
1\ge |H_c(j\Omega)|\ge 1-\delta_1,\quad |\Omega|\le \Omega_p
$$

$$
|H_c(j\Omega)|\le \delta_2,\quad |\Omega|\ge \Omega_s
$$

其中：

- $\Omega_p$：通带边缘频率；
- $\Omega_s$：阻带边缘频率；
- $\delta_1$：通带允许下降量；
- $\delta_2$：阻带允许最大幅度。

Butterworth 的特点：通带和阻带都单调，没有纹波；在 $\Omega=0$ 附近尽可能平坦。

## 3.2 Butterworth 幅度平方响应

$N$ 阶 Butterworth 低通：

$$
|H_c(j\Omega)|^2=
\frac{1}{1+\left(\frac{\Omega}{\Omega_c}\right)^{2N}}
$$

重要性质：

1. 在直流处：

$$
|H_c(j0)|=1
$$

2. 在截止频率 $\Omega_c$ 处：

$$
|H_c(j\Omega_c)|^2=\frac{1}{2},
\quad
|H_c(j\Omega_c)|=\frac{1}{\sqrt{2}}
$$

所以 $\Omega_c$ 是 $3\,\mathrm{dB}$ 截止频率。

3. 阶数越大，过渡带越陡。

滚降速度：

$$
20N\,\mathrm{dB/decade}
$$

或：

$$
6N\,\mathrm{dB/octave}
$$

## 3.3 Butterworth 极点与系统函数

归一化 Butterworth 低通可写成：

$$
H_c(s)=\frac{1}{B_N(s)}
=\frac{1}{\prod_{k=1}^{N}(s-s_k)}
$$

极点为：

$$
s_k=\Omega_c e^{j\pi\left[0.5-\frac{2k-1}{2N}\right]},
\quad k=1,2,\dots,N
$$

稳定系统只取左半平面极点。Butterworth 低通没有有限零点，可理解为 $N$ 个零点在无穷远处。

若 $N$ 为奇数，有一个极点落在负实轴 $-\Omega_c$。

## 3.4 常用归一化 Butterworth 多项式

当 $\Omega_c=1$ 时：

$$
B_1(s)=s+1
$$

$$
B_2(s)=s^2+\sqrt{2}s+1
$$

$$
B_3(s)=(s^2+s+1)(s+1)
$$

$$
B_4(s)=(s^2+0.76536s+1)(s^2+1.84776s+1)
$$

$$
B_5(s)=(s+1)(s^2+0.6180s+1)(s^2+1.6180s+1)
$$

$$
B_6(s)=(s^2+0.5176s+1)(s^2+\sqrt{2}s+1)(s^2+1.9318s+1)
$$

频率缩放规则：

$$
s\mapsto \frac{s}{\Omega_c}
$$

若归一化原型为 $H_{\mathrm{norm}}(s)$，则新截止频率下：

$$
H_c(s)=H_{\mathrm{norm}}\left(\frac{s}{\Omega_c}\right)
$$

## 3.5 从幅度指标求阶数 $N$

PPT 使用正的 dB 指标：

$$
\epsilon_{\mathrm{dB}}=-20\log_{10}(1-\delta_1)
$$

$$
A_s=-20\log_{10}(\delta_2)
$$

低通指标为：

$$
-\epsilon_{\mathrm{dB}}\le 20\log_{10}|H_c(j\Omega)|\le 0,\quad |\Omega|\le \Omega_p
$$

$$
20\log_{10}|H_c(j\Omega)|\le -A_s,\quad |\Omega|\ge \Omega_s
$$

由 Butterworth 幅度平方：

$$
10^{\epsilon_{\mathrm{dB}}/10}-1=
\left(\frac{\Omega_p}{\Omega_c}\right)^{2N}
$$

$$
10^{A_s/10}-1=
\left(\frac{\Omega_s}{\Omega_c}\right)^{2N}
$$

两式相除：

$$
\left(\frac{\Omega_p}{\Omega_s}\right)^{2N}
=
\frac{10^{\epsilon_{\mathrm{dB}}/10}-1}
{10^{A_s/10}-1}
$$

所以阶数取：

$$
\boxed{
N=
\left\lceil
\frac{
\log_{10}\left(
\frac{10^{\epsilon_{\mathrm{dB}}/10}-1}
{10^{A_s/10}-1}
\right)}
{2\log_{10}(\Omega_p/\Omega_s)}
\right\rceil
}
$$

因为 $\Omega_p<\Omega_s$，分母为负；分子通常也为负，最终 $N$ 为正。

## 3.6 截止频率 $\Omega_c$ 的选择

因为 $N$ 要向上取整，通带边缘和阻带边缘一般不能同时精确等号成立。

常见选择：让通带边缘刚好满足指标：

$$
\Omega_c=
\frac{\Omega_p}
{\left(10^{\epsilon_{\mathrm{dB}}/10}-1\right)^{1/(2N)}}
$$

若让阻带边缘刚好满足指标：

$$
\Omega_c=
\frac{\Omega_s}
{\left(10^{A_s/10}-1\right)^{1/(2N)}}
$$

也可在两者之间选择，使通带和阻带要求都留有裕量。

## 3.7 Example 8.4：Butterworth 低通设计

给定：

$$
\Omega_p=20,\quad \epsilon_{\mathrm{dB}}=2\,\mathrm{dB}
$$

$$
\Omega_s=30,\quad A_s=10\,\mathrm{dB}
$$

阶数：

$$
N=
\left\lceil
\frac{
\log_{10}\left(
\frac{10^{2/10}-1}{10^{10/10}-1}
\right)}
{2\log_{10}(20/30)}
\right\rceil
=\lceil 3.3709\rceil=4
$$

让通带边缘匹配：

$$
\Omega_c=
\frac{20}{(10^{2/10}-1)^{1/8}}
=21.3868\,\mathrm{rad/s}
$$

归一化四阶 Butterworth：

$$
H_{\mathrm{norm}}(s)=
\frac{1}{(s^2+0.76536s+1)(s^2+1.84776s+1)}
$$

缩放 $s\mapsto s/21.3868$：

$$
H_c(s)=
\frac{(21.3868)^4}
{(s^2+16.37s+457.4)(s^2+39.52s+457.4)}
$$

---

## 4. 8.4 Chebyshev Design

Chebyshev 滤波器用纹波换取更陡的过渡带。

两类：

- Type I：通带等波纹，阻带单调；
- Type II：通带单调，阻带等波纹。

同阶数下，Chebyshev 通常比 Butterworth 过渡带更窄，但幅频不再完全平滑。

## 4.1 Chebyshev Type I 幅度响应

Type I 的幅度平方为：

$$
|H_c(j\Omega)|^2=
\frac{1}{1+\epsilon^2T_N^2(\Omega/\Omega_c)}
$$

其中 $T_N(x)$ 是 $N$ 阶 Chebyshev 多项式。

递推定义：

$$
T_N(x)=2xT_{N-1}(x)-T_{N-2}(x)
$$

$$
T_0(x)=1,\quad T_1(x)=x
$$

闭式表达：

$$
T_N(x)=
\begin{cases}
\cos(N\cos^{-1}x), & |x|\le 1\\
\cosh(N\cosh^{-1}x), & |x|>1
\end{cases}
$$

在 $|\Omega/\Omega_c|\le 1$ 的通带内，$T_N$ 在 $[-1,1]$ 之间振荡，所以幅度在：

$$
\frac{1}{\sqrt{1+\epsilon^2}}
\le |H_c(j\Omega)|\le 1
$$

通带纹波 dB 为：

$$
\epsilon_{\mathrm{dB}}=10\log_{10}(1+\epsilon^2)
$$

因此：

$$
\epsilon=\sqrt{10^{\epsilon_{\mathrm{dB}}/10}-1}
$$

## 4.2 Type I 系统函数与极点

Type I 可写成：

$$
H_c(s)=\frac{K}{V_N(s)}
$$

其中：

$$
V_N(s)=\prod_{k=1}^{N}(s-s_k)
$$

极点位于 $s$ 平面的椭圆上。令：

$$
\alpha=\epsilon^{-1}+\sqrt{1+\epsilon^{-2}}
$$

$$
a=\frac{1}{2}\left(\alpha^{1/N}-\alpha^{-1/N}\right)
$$

$$
b=\frac{1}{2}\left(\alpha^{1/N}+\alpha^{-1/N}\right)
$$

这些参数控制椭圆形状。

增益 $K$ 的选择：

- $N$ 为奇数：令 $H_c(0)=1$；
- $N$ 为偶数：令 $H_c(0)=1/\sqrt{1+\epsilon^2}$。

## 4.3 Type I 从指标求阶数

给定：

$$
\epsilon_{\mathrm{dB}},\quad A_s,\quad \Omega_p,\quad \Omega_s
$$

阶数：

$$
\boxed{
N=
\left\lceil
\frac{
\cosh^{-1}
\left(
\sqrt{
\frac{10^{A_s/10}-1}
{10^{\epsilon_{\mathrm{dB}}/10}-1}
}
\right)}
{\cosh^{-1}(\Omega_s/\Omega_p)}
\right\rceil
}
$$

设计流程：

1. 由 $\epsilon_{\mathrm{dB}}$ 得 $\epsilon$。  
2. 用公式求最小阶数 $N$。  
3. 查表或用 MATLAB 得到归一化 Type I 原型。  
4. 按 $\Omega_p$ 缩放：

$$
s\mapsto \frac{s}{\Omega_p}
$$

## 4.4 Example 8.5：Chebyshev Type I

指标：

$$
\epsilon_{\mathrm{dB}}=2\,\mathrm{dB},\quad A_s=20\,\mathrm{dB}
$$

$$
\Omega_p=40,\quad \Omega_s=52
$$

阶数：

$$
N=
\left\lceil
\frac{
\cosh^{-1}
\left(
\sqrt{
\frac{10^{20/10}-1}{10^{2/10}-1}
}
\right)}
{\cosh^{-1}(52/40)}
\right\rceil
=5
$$

2 dB 表中五阶原型：

$$
H_{\mathrm{norm}}(s)=
\frac{0.08172}
{s^5+0.70646s^4+1.49954s^3+0.69348s^2+0.45935s+0.08172}
$$

缩放：

$$
H_c(s)=H_{\mathrm{norm}}\left(\frac{s}{40}\right)
$$

## 4.5 Chebyshev Type II

Type II 的特点：通带单调，阻带等波纹，并且在阻带中有有限零点。

幅度平方可写成：

$$
|H_c(j\Omega)|^2=
\frac{1}
{1+\epsilon^2
\frac{T_N^2(\Omega_s/\Omega_p)}
{T_N^2(\Omega_s/\Omega)}
}
$$

更常见的理解方式：

- 通带不振荡；
- 阻带通过零点产生等波纹；
- 阶数公式与 Type I 形式相同；
- 系统函数在 $j\Omega$ 轴上有零点。

零点位置：

$$
z_m=
j\frac{\Omega_s}
{\cos\left[\frac{\pi}{2N}(2m-1)\right]},
\quad m=1,2,\dots,N
$$

极点可由 Type I 相关的双曲构造得到。PPT 给出：

$$
p_k=\alpha_k+j\beta_k
$$

其中：

$$
\alpha_k=
\frac{\Omega_p\Omega_s\sigma_k}{\sigma_k^2+\omega_k^2}
$$

$$
\beta_k=
\frac{\Omega_p\Omega_s\omega_k}{\sigma_k^2+\omega_k^2}
$$

$$
\sigma_k=
-\sin\left(\frac{\pi}{2N}(2k-1)\right)
\sinh\left[
\frac{1}{N}\sinh^{-1}\left(\frac{1}{\epsilon}\right)
\right]
$$

$$
\omega_k=
\cos\left(\frac{\pi}{2N}(2k-1)\right)
\cosh\left[
\frac{1}{N}\sinh^{-1}\left(\frac{1}{\epsilon}\right)
\right]
$$

## 4.6 Example 8.6：Chebyshev Type II

指标：

$$
\epsilon_{\mathrm{dB}}=2\,\mathrm{dB},\quad A_s=40\,\mathrm{dB}
$$

$$
\Omega_p=100,\quad \Omega_s=200
$$

阶数仍用：

$$
N=
\left\lceil
\frac{
\cosh^{-1}
\left(
\sqrt{
\frac{10^{A_s/10}-1}{10^{\epsilon_{\mathrm{dB}}/10}-1}
}
\right)}
{\cosh^{-1}(\Omega_s/\Omega_p)}
\right\rceil
=5
$$

MATLAB 中常用：

```matlab
[n,Wn] = cheb2ord(100,200,2,40,'s');
[b,a] = cheby2(n,40,Wn,'s');
[H,w] = freqs(b,a);
plot(w,20*log10(abs(H)));
```

注意：手算因 $N$ 向上取整，实际阻带衰减可能大于要求；MATLAB 可能会调整参数，使最小阻带衰减刚好等于目标值。

---

## 5. 8.5 Elliptic Design

Elliptic filters（椭圆滤波器）允许通带和阻带都出现等波纹，以换取最窄的过渡带。

同样阶数下，经典模拟逼近族的过渡带通常满足：

$$
\text{Butterworth 最宽}
\quad \rightarrow \quad
\text{Chebyshev}
\quad \rightarrow \quad
\text{Elliptic 最窄}
$$

但代价是响应纹波更多、设计表或软件依赖更强。

## 5.1 幅度响应形式

椭圆低通可写成：

$$
|H_c(j\Omega)|^2=
\frac{1}{1+\epsilon^2U_N^2(\Omega/\Omega_p)}
$$

其中 $U_N(\cdot)$ 是 Jacobi elliptic function。

定义过渡比：

$$
\Omega_r=\frac{\Omega_s}{\Omega_p}
$$

设计时给定 $\epsilon_{\mathrm{dB}}$、$A_s$ 与 $\Omega_r$，查表或用软件确定最小阶数 $N$ 与系数。

## 5.2 系统函数结构

归一化椭圆低通可写成二阶节乘积。

若 $N$ 为奇数：

$$
H_c(s)=
\frac{H_0}{s+s_0}
\prod_{i=1}^{(N-1)/2}
\frac{s^2+A_{0i}}{s^2+B_{1i}s+B_{0i}}
$$

若 $N$ 为偶数：

$$
H_c(s)=
\prod_{i=1}^{N/2}
\frac{s^2+A_{0i}}{s^2+B_{1i}s+B_{0i}}
$$

椭圆滤波器的阻带零点位于 $j\Omega$ 轴上，因此 numerator 中常出现偶次多项式。

## 5.3 从幅度指标设计

流程：

1. 给定 $\epsilon_{\mathrm{dB}}$、$A_s$、$\Omega_p$、$\Omega_s$。  
2. 计算：

$$
\Omega_r=\frac{\Omega_s}{\Omega_p}
$$

3. 查表选择最小阶数 $N$，使表中的可实现过渡比满足要求。  
4. 取得归一化原型系数。  
5. 缩放：

$$
s\mapsto \frac{s}{\Omega_p}
$$

## 5.4 Example 8.7：椭圆低通

指标：

$$
\epsilon_{\mathrm{dB}}=1\,\mathrm{dB},\quad A_s=40\,\mathrm{dB}
$$

$$
f_p=10\,\mathrm{kHz},\quad f_s=14.4\,\mathrm{kHz}
$$

过渡比：

$$
\Omega_r=\frac{14.4}{10}=1.44
$$

查 1 dB / 40 dB 表，取 $N=5$。

归一化原型：

$$
H(s)=
\frac{
0.04698s^4+0.22007s^2+0.22985
}
{
s^5+0.92339s^4+1.84712s^3+1.12923s^2+0.78813s+0.22985
}
$$

缩放：

$$
s\mapsto \frac{s}{2\pi\cdot 10000}
$$

MATLAB 常用：

```matlab
[n,Wn] = ellipord(2*pi*10000,2*pi*14400,1,40,'s');
[b,a] = ellip(n,1,40,Wn,'s');
```

---

## 6. 8.6 从模拟原型设计离散时间 IIR

模拟原型 $H_c(s)$ 要变成数字滤波器 $H(z)$，本章重点讲两种方法：

1. impulse invariance：冲激响应不变法。  
2. bilinear transformation：双线性变换。

两者的核心区别：

| 方法 | 保留什么 | 主要问题 |
|---|---|---|
| 冲激响应不变法 | $h[n]$ 是 $h_c(t)$ 的采样 | 频率响应会混叠 |
| 双线性变换 | 左半平面到单位圆内的一一映射 | 频率轴非线性畸变 |

## 6.1 Impulse Invariant Design

基本思想：

$$
h[n]=G h_c(nT_d)
$$

其中 $T_d$ 是采样间隔，$G$ 是增益常数。

频域关系：

$$
H(e^{j\omega})=
\frac{G}{T_d}
\sum_{k=-\infty}^{\infty}
H_c\left(
j\frac{\omega}{T_d}
j\frac{2\pi k}{T_d}
\right)
$$

这说明数字频率响应是模拟频率响应的周期复制叠加，即会发生 aliasing。

降低混叠的方法：

- 使用低通原型，且阻带单调衰减；
- 采样率更高，即 $T_d$ 更小；
- 让模拟截止频率远低于采样频率。

## 6.2 部分分式构造

若模拟系统：

$$
H_c(s)=\sum_{k=1}^{N}\frac{A_k}{s-s_k}
$$

则：

$$
h_c(t)=\sum_{k=1}^{N}A_k e^{s_k t}u(t)
$$

采样得到：

$$
h[n]=G\sum_{k=1}^{N}A_k e^{s_k nT_d}u[n]
$$

利用：

$$
\sum_{n=0}^{\infty}(e^{s_kT_d}z^{-1})^n
=
\frac{1}{1-e^{s_kT_d}z^{-1}}
$$

所以：

$$
\boxed{
H(z)=
G\sum_{k=1}^{N}
\frac{A_k}{1-e^{s_kT_d}z^{-1}}
}
$$

极点映射：

$$
p_k=e^{s_kT_d}
$$

若 $\operatorname{Re}(s_k)<0$，则：

$$
|p_k|=|e^{s_kT_d}|=e^{\operatorname{Re}(s_k)T_d}<1
$$

因此稳定模拟极点会映射到单位圆内。

增益 $G$ 常选为让直流增益匹配：

$$
H(1)=H_c(0)
$$

## 6.3 Example 8.8：从有理 $H_c(s)$ 做冲激响应不变

给定：

$$
H_c(s)=
\frac{0.5(s+4)}{(s+1)(s+2)}
$$

部分分式：

$$
H_c(s)=\frac{1.5}{s+1}-\frac{1}{s+2}
$$

反拉普拉斯：

$$
h_c(t)=\left(1.5e^{-t}-e^{-2t}\right)u(t)
$$

采样并缩放：

$$
H(z)=G\left[
\frac{1.5}{1-e^{-T_d}z^{-1}}
-
\frac{1}{1-e^{-2T_d}z^{-1}}
\right]
$$

再由：

$$
H(1)=H_c(0)
$$

求 $G$。

MATLAB：

```matlab
as = conv([1 1],[1 2]);
bs = 0.5*[1 4];
[bz10,az10] = impinvar(bs,as,10);
[bz50,az50] = impinvar(bs,as,50);
```

采样率越高，混叠越小。

## 6.4 从数字指标用冲激响应不变法

若数字指标给的是 $\omega_p,\omega_s$，用冲激响应不变法时先用线性关系：

$$
\Omega_i=\frac{\omega_i}{T_d}
$$

把数字边缘频率转换成模拟边缘频率，再设计 $H_c(s)$，最后用 impulse invariance 得到 $H(z)$。

注意：因为该方法有频谱混叠，通常不适合高通或带阻等需要保留高频结构的设计。

## 6.5 Bilinear Transformation Design

双线性变换：

$$
\boxed{
s=\frac{2}{T_d}\frac{1-z^{-1}}{1+z^{-1}}
}
$$

反变换：

$$
\boxed{
z=\frac{1+\frac{T_d}{2}s}{1-\frac{T_d}{2}s}
}
$$

设计方程：

$$
\boxed{
H(z)=H_c(s)\Bigg|_{s=\frac{2}{T_d}\frac{1-z^{-1}}{1+z^{-1}}}
}
$$

### 为什么稳定性会保留？

若 $s$ 在左半平面，$\operatorname{Re}(s)<0$，代入：

$$
z=\frac{1+\frac{T_d}{2}s}{1-\frac{T_d}{2}s}
$$

可证明 $|z|<1$。因此稳定模拟滤波器会变成稳定数字滤波器。

双线性变换是一一映射，所以不会出现冲激响应不变法的频率混叠。

## 6.6 频率畸变与预畸变

令 $z=e^{j\omega}$，代入双线性变换：

$$
s=\frac{2}{T_d}
\frac{1-e^{-j\omega}}{1+e^{-j\omega}}
$$

利用半角公式可得：

$$
s=j\frac{2}{T_d}\tan\left(\frac{\omega}{2}\right)
$$

因此模拟频率与数字频率的关系为：

$$
\boxed{
\Omega=\frac{2}{T_d}\tan\left(\frac{\omega}{2}\right)
}
$$

反过来：

$$
\boxed{
\omega=2\tan^{-1}\left(\frac{\Omega T_d}{2}\right)
}
$$

这是一种非线性频率映射，称为 frequency warping。

为了让关键数字频率 $\omega_i$ 映射后准确落在目标位置，设计模拟原型前要做预畸变：

$$
\boxed{
\Omega_i=\frac{2}{T_d}\tan\left(\frac{\omega_i}{2}\right)
}
$$

实际设计中常令 $T_d=1$，因为从 $H_c(s)$ 回到 $H(z)$ 时比例会抵消。

低通原型中位于 $s=\infty$ 的零点，双线性变换后会映射到：

$$
z=-1
$$

即数字频率 $\omega=\pi$。

## 6.7 双线性变换设计步骤

给定数字低通指标：

$$
\omega_p,\quad \omega_s,\quad \epsilon_{\mathrm{dB}},\quad A_s
$$

步骤：

1. 预畸变：

$$
\Omega_p=\frac{2}{T_d}\tan\left(\frac{\omega_p}{2}\right),
\quad
\Omega_s=\frac{2}{T_d}\tan\left(\frac{\omega_s}{2}\right)
$$

2. 用模拟滤波器方法设计 $H_c(s)$。  
3. 用双线性变换得到 $H(z)$：

$$
H(z)=H_c\left(
\frac{2}{T_d}\frac{1-z^{-1}}{1+z^{-1}}
\right)
$$

## 6.8 Example 8.10：双线性低通设计

设计数字低通：

$$
\epsilon_{\mathrm{dB}}=3.01\,\mathrm{dB},\quad A_s=15\,\mathrm{dB}
$$

$$
\omega_p=0.5\pi,\quad \omega_s=0.75\pi
$$

采样频率：

$$
f_s=\frac{1}{T_d}=2\,\mathrm{kHz}
$$

预畸变：

$$
\Omega_p=2\cdot 2000\tan\left(\frac{0.5\pi}{2}\right)=4000\,\mathrm{rad/s}
$$

$$
\Omega_s=2\cdot 2000\tan\left(\frac{0.75\pi}{2}\right)=9657\,\mathrm{rad/s}
$$

要求通带、阻带都单调，所以选 Butterworth。

阶数：

$$
N=
\left\lceil
\frac{
\log_{10}\left(
\frac{10^{3.01/10}-1}{10^{15/10}-1}
\right)}
{2\log_{10}(4000/9657)}
\right\rceil
=2
$$

归一化二阶 Butterworth：

$$
H_{\mathrm{norm}}(s)=
\frac{1}{s^2+\sqrt{2}s+1}
$$

缩放：

$$
H_c(s)=H_{\mathrm{norm}}\left(\frac{s}{4000}\right)
$$

最后代入：

$$
s=\frac{2}{T_d}\frac{1-z^{-1}}{1+z^{-1}}
$$

得到数字滤波器 $H(z)$。

---

## 7. 8.7 Frequency Transformations

低通原型可以转换成高通、带通、带阻。

如果最终要数字滤波器，有两条路线：

1. 先在模拟域做低通到高通/带通/带阻的变换，再离散化。  
2. 先把低通原型离散化，再做离散时间频率变换。

对双线性变换而言，两条路线都可用。

## 7.1 连续时间低通到低通

归一化低通原型截止频率为 $1\,\mathrm{rad/s}$。

目标低通边缘为 $\Omega_p$ 时：

$$
s\mapsto \frac{s}{\Omega_p}
$$

$$
H_{\mathrm{desired}}(s)=H_c\left(\frac{s}{\Omega_p}\right)
$$

## 7.2 连续时间低通到高通

低通到高通：

$$
s\mapsto \frac{\Omega_p}{s}
$$

$$
H_{\mathrm{desired}}(s)=H_c\left(\frac{\Omega_p}{s}\right)
$$

直观上，低频和高频互换：低通原型的通带被映射到高频区域。

## 7.3 连续时间低通到带通

给定带通通带边缘：

$$
\Omega_{p1},\quad \Omega_{p2}
$$

定义中心频率与带宽：

$$
\Omega_c=\sqrt{\Omega_{p1}\Omega_{p2}}
$$

$$
\Omega_b=\Omega_{p2}-\Omega_{p1}
$$

低通到带通：

$$
s\mapsto \frac{s^2+\Omega_c^2}{s\Omega_b}
$$

## 7.4 连续时间低通到带阻

低通到带阻：

$$
s\mapsto \frac{s\Omega_b}{s^2+\Omega_c^2}
$$

带通/带阻变换会把一个低通原型极点映射成一对极点，因此阶数通常翻倍。

## 7.5 Example 8.12：带通双线性设计

指标：

$$
f_s=200\,\mathrm{kHz},\quad \epsilon_{\mathrm{dB}}=1\,\mathrm{dB},\quad A_s=20\,\mathrm{dB}
$$

阻带与通带边缘：

$$
f_{s1}=20\,\mathrm{Hz},\quad f_{p1}=50\,\mathrm{Hz}
$$

$$
f_{p2}=20\,\mathrm{kHz},\quad f_{s2}=45\,\mathrm{kHz}
$$

先预畸变得到模拟频率：

$$
\Omega_{s1}=125.66\,\mathrm{rad/s}
$$

$$
\Omega_{p1}=314.16\,\mathrm{rad/s}
$$

$$
\Omega_{p2}=129.67\,\mathrm{krad/s}
$$

$$
\Omega_{s2}=341.63\,\mathrm{krad/s}
$$

映射到低通原型后得到两个候选阻带频率：

$$
A=2.5052,\quad B=2.6401
$$

取更严格的：

$$
\Omega_s=\min\{A,B\}=2.5052
$$

采用 Chebyshev Type I，阶数：

$$
N=3
$$

归一化原型：

$$
H_c(s)=
\frac{0.4913}{s^3+0.988s^2+1.238s+0.491}
$$

MATLAB 可直接完成：

```matlab
[n,Wn] = cheb1ord([50/100000 20000/100000], ...
                  [20/100000 45000/100000],1,20);
[b,a] = cheby1(n,1,Wn);
[H,F] = freqz(b,a,512,200000);
semilogx(F,20*log10(abs(H)));
```

---

## 8. 8.8 FIR Filters

FIR 滤波器具有有限长冲激响应：

$$
H(z)=\sum_{n=0}^{M}h[n]z^{-n}
$$

也称：

- nonrecursive filter；
- moving-average filter；
- transversal filter；
- tapped-delay-line filter。

## 8.1 FIR 相比 IIR 的优缺点

优点：

1. 可以实现精确线性相位。  
2. 非递归结构天然稳定。  
3. 系数量化更容易控制。  

缺点：

1. 同样幅度选择性下，所需阶数通常比 IIR 高。  
2. 计算量更大。  
3. 存储需求更高。

## 8.2 Windowing Design：理想响应截断加窗

理想目标：

$$
H_d(e^{j\omega})=
\sum_{n=-\infty}^{\infty}
h_d[n]e^{-j\omega n}
$$

最简单的 FIR 近似是截断：

$$
h[n]=
\begin{cases}
h_d[n], & 0\le n\le M\\
0, & \text{otherwise}
\end{cases}
$$

更一般地，用窗函数平滑截断：

$$
h[n]=h_d[n]w[n]
$$

时域相乘对应频域卷积，因此实际频率响应是理想响应与窗频谱的卷积。窗函数会控制主瓣宽度和旁瓣高度：

- 主瓣越窄，过渡带越窄；
- 旁瓣越低，阻带衰减越大；
- 二者通常不能同时最优。

## 8.3 线性相位条件

若 $h[n]$ 关于 $M/2$ 对称：

$$
h[n]=h[M-n]
$$

则 FIR 有广义线性相位：

$$
H(e^{j\omega})=A_e(e^{j\omega})e^{-j\omega M/2}
$$

其中 $A_e(e^{j\omega})$ 为实偶函数。

若 $h[n]$ 关于 $M/2$ 反对称：

$$
h[n]=-h[M-n]
$$

则：

$$
H(e^{j\omega})=jA_o(e^{j\omega})e^{-j\omega M/2}
$$

其中 $A_o(e^{j\omega})$ 为实奇函数。

核心结论：设计 FIR 线性相位时，选择关于 $M/2$ 对称的窗函数和理想冲激响应。

## 8.4 低通 FIR 的理想冲激响应

目标低通：

$$
H_d(e^{j\omega})=
\begin{cases}
e^{-j\omega M/2}, & |\omega|<\omega_c\\
0, & \text{otherwise}
\end{cases}
$$

其中 $e^{-j\omega M/2}$ 给出线性相位延迟。

其冲激响应为：

$$
h_d[n]=
\frac{\sin\left(\omega_c(n-M/2)\right)}
{\pi(n-M/2)}
$$

当 $n=M/2$ 时，用极限：

$$
h_d[M/2]=\frac{\omega_c}{\pi}
$$

实际 FIR 系数：

$$
h[n]=h_d[n]w[n]
$$

## 8.5 FIR 低通指标与窗函数选择

常见低通指标：

$$
\omega_p,\quad \omega_s,\quad \delta
$$

其中：

- $\omega_p$：通带边缘；
- $\omega_s$：阻带边缘；
- $\delta$：纹波或阻带误差尺度。

PPT 给出的近似 dB 指标：

$$
A_s=-20\log_{10}\delta
$$

$$
\epsilon_{\mathrm{dB}}=20\log_{10}(1+\delta)
$$

常用窗函数经验表：

| Window | 过渡宽度近似 | 最小阻带衰减 |
|---|---:|---:|
| Rectangular | $1.81\pi/M$ | $21\,\mathrm{dB}$ |
| Bartlett | $1.80\pi/M$ | $25\,\mathrm{dB}$ |
| Hanning | $5.01\pi/M$ | $44\,\mathrm{dB}$ |
| Hamming | $6.27\pi/M$ | $53\,\mathrm{dB}$ |
| Blackman | $9.19\pi/M$ | $74\,\mathrm{dB}$ |

设计规则：

1. 根据所需 $A_s$ 选择刚好满足阻带衰减的窗。  
2. 根据过渡宽度约束选 $M$：

$$
\Delta\omega\le \omega_s-\omega_p
$$

3. 取截止频率在通带和阻带中间：

$$
\omega_c=\frac{\omega_p+\omega_s}{2}
$$

4. 计算：

$$
h[n]=h_d[n]w[n]
$$

5. 画 `freqz` 检查，不满足就增加 $M$ 或换窗。

## 8.6 Kaiser 窗

Kaiser 窗提供一个可调参数 $\beta$：

$$
w[n]=
\frac{
I_0\left(
\beta\sqrt{1-\left[\frac{n-\alpha}{\alpha}\right]^2}
\right)
}
{I_0(\beta)}
$$

其中：

$$
\alpha=\frac{M}{2}
$$

$I_0(\cdot)$ 是零阶第一类修正 Bessel 函数。

经验公式：

$$
\beta\approx
\begin{cases}
0, & A_s<21\\
0.5842(A_s-21)^{0.4}+0.07886(A_s-21), & 21\le A_s\le 50\\
0.1102(A_s-8.7), & A_s>50
\end{cases}
$$

阶数近似：

$$
M\approx
\frac{A_s-8}{2.285\Delta\omega}
$$

## 8.7 Example 8.13：FIR 低通窗函数法

指标：

$$
\omega_p=0.4\pi,\quad \omega_s=0.6\pi
$$

$$
\delta=0.0032
$$

阻带衰减：

$$
A_s=-20\log_{10}(0.0032)\approx 50\,\mathrm{dB}
$$

查表，Hamming 窗最小阻带衰减约 $53\,\mathrm{dB}$，满足要求。

过渡宽度：

$$
\omega_s-\omega_p=0.2\pi
$$

Hamming 经验宽度：

$$
\Delta\omega\approx \frac{6.27\pi}{M}
$$

要求：

$$
\frac{6.27\pi}{M}\le 0.2\pi
$$

所以：

$$
M\ge 31.35
$$

取：

$$
M=32
$$

截止频率：

$$
\omega_c=\frac{0.4\pi+0.6\pi}{2}=0.5\pi
$$

MATLAB：

```matlab
b = fir1(32,2*.25,hamming(32+1));
[H,F] = freqz(b,1,512,1);
plot(F,20*log10(abs(H)));
```

Kaiser 设计中：

$$
\beta\approx 4.5335
$$

$$
M\approx 30
$$

```matlab
bk = fir1(30,2*.25,kaiser(30+1,4.5335));
[Hk,F] = freqz(bk,1,512,1);
```

---

## 9. 8.9 MATLAB Filter Design Functions

## 9.1 分析与实现函数

| Function | Purpose |
|---|---|
| `filter(b,a,x)` | 用直接 II 型结构滤波 |
| `freqs(b,a)` | 模拟域 $s$-domain 频率响应 |
| `freqz(b,a)` | 数字域 $z$-domain 频率响应 |
| `grpdelay(b,a)` | 群延迟 |
| `impz(b,a)` | 冲激响应 |
| `unwrap()` | 相位展开 |
| `zplane(b,a)` | $z$ 平面零极点图 |

## 9.2 线性系统变换

| Function | Purpose |
|---|---|
| `residuez()` | $z$ 域部分分式展开 |
| `tf2zp()` | 传递函数到零极点 |
| `zp2sos()` | 零极点到二阶节 |

实际实现高阶 IIR 时，建议使用二阶节 SOS，而不是直接高阶多项式，数值稳定性更好。

## 9.3 IIR 设计函数

| Function | Purpose |
|---|---|
| `besself(n,Wn)` | 模拟 Bessel，群延迟较平坦 |
| `butter(n,Wn,'ftype','s')` | Butterworth 模拟/数字设计 |
| `cheby1(n,Rp,Wn,'ftype','s')` | Chebyshev Type I |
| `cheby2(n,Rs,Wn,'ftype','s')` | Chebyshev Type II |
| `ellip(n,Rp,Rs,Wn,'ftype','s')` | Elliptic |

## 9.4 阶数选择与 FIR 设计

| Function | Purpose |
|---|---|
| `buttord(Wp,Ws,Rp,Rs,'s')` | Butterworth 阶数选择 |
| `cheb1ord(Wp,Ws,Rp,Rs,'s')` | Chebyshev I 阶数选择 |
| `cheb2ord(Wp,Ws,Rp,Rs,'s')` | Chebyshev II 阶数选择 |
| `ellipord(Wp,Ws,Rp,Rs,'s')` | Elliptic 阶数选择 |
| `fir1()` | 基于窗函数的 FIR 设计 |
| `fir2()` | 任意幅度响应 FIR 设计 |
| `remez()` | Parks-McClellan 最优等波纹 FIR |
| `remezord()` | Parks-McClellan 阶数估计 |

## 9.5 模拟到数字离散化

| Function | Purpose |
|---|---|
| `bilinear(bs,as,Fs,Fp)` | 双线性变换，`Fp` 可指定匹配频率 |
| `impinvar(bs,as,Fs)` | 冲激响应不变法 |

---

## 10. 本章速记（考试/实现高频结论）

1. Butterworth 幅度：

$$
|H_c(j\Omega)|^2=
\frac{1}{1+(\Omega/\Omega_c)^{2N}}
$$

2. Butterworth 阶数：

$$
N=
\left\lceil
\frac{
\log_{10}\left(
\frac{10^{\epsilon_{\mathrm{dB}}/10}-1}
{10^{A_s/10}-1}
\right)}
{2\log_{10}(\Omega_p/\Omega_s)}
\right\rceil
$$

3. Chebyshev I 幅度：

$$
|H_c(j\Omega)|^2=
\frac{1}{1+\epsilon^2T_N^2(\Omega/\Omega_c)}
$$

4. Chebyshev 阶数：

$$
N=
\left\lceil
\frac{
\cosh^{-1}
\left(
\sqrt{
\frac{10^{A_s/10}-1}
{10^{\epsilon_{\mathrm{dB}}/10}-1}
}
\right)}
{\cosh^{-1}(\Omega_s/\Omega_p)}
\right\rceil
$$

5. 椭圆滤波器：同阶数下过渡带最窄，但通带、阻带都有纹波。

6. 冲激响应不变法：

$$
h[n]=Gh_c(nT_d)
$$

$$
p_k=e^{s_kT_d}
$$

主要问题是频率混叠。

7. 双线性变换：

$$
s=\frac{2}{T_d}\frac{1-z^{-1}}{1+z^{-1}}
$$

无混叠，但有频率畸变。

8. 预畸变：

$$
\Omega_i=\frac{2}{T_d}\tan\left(\frac{\omega_i}{2}\right)
$$

9. FIR 窗函数法：

$$
h[n]=h_d[n]w[n]
$$

10. 低通 FIR 理想冲激响应：

$$
h_d[n]=
\frac{\sin\left(\omega_c(n-M/2)\right)}
{\pi(n-M/2)}
$$

11. Kaiser 窗阶数估计：

$$
M\approx
\frac{A_s-8}{2.285\Delta\omega}
$$

---

## 11. 与前后章节衔接

- Chapter 6 和 Chapter 7 解决“如何计算频谱/卷积”：DFT 与 FFT。  
- Chapter 8 解决“如何设计系统”：根据频率指标构造 $H(z)$。  
- IIR 设计依赖模拟原型与 $s\to z$ 映射。  
- FIR 设计依赖理想频率响应、窗函数和线性相位结构。  
- 做题时先判断滤波器类型：IIR 还是 FIR、模拟原型还是数字指标、是否需要预畸变。

---

## 12. 典型题型流程

## 12.1 IIR 低通双线性设计

1. 读出 $\omega_p,\omega_s,\epsilon_{\mathrm{dB}},A_s$。  
2. 预畸变：

$$
\Omega_p=\frac{2}{T_d}\tan\left(\frac{\omega_p}{2}\right),
\quad
\Omega_s=\frac{2}{T_d}\tan\left(\frac{\omega_s}{2}\right)
$$

3. 根据幅度形状选模拟原型：
   - 单调：Butterworth；
   - 通带纹波：Chebyshev I；
   - 阻带纹波：Chebyshev II；
   - 最窄过渡带：Elliptic。
4. 求阶数 $N$。  
5. 查表或 MATLAB 得 $H_c(s)$。  
6. 代入：

$$
s=\frac{2}{T_d}\frac{1-z^{-1}}{1+z^{-1}}
$$

7. 得到 $H(z)$，再用 `freqz` 验证。

## 12.2 FIR 窗函数低通设计

1. 读出 $\omega_p,\omega_s,\delta$ 或 $A_s$。  
2. 根据 $A_s$ 选窗函数。  
3. 用窗函数表估计 $M$，使：

$$
\Delta\omega\le \omega_s-\omega_p
$$

4. 取：

$$
\omega_c=\frac{\omega_p+\omega_s}{2}
$$

5. 写理想冲激响应：

$$
h_d[n]=
\frac{\sin\left(\omega_c(n-M/2)\right)}
{\pi(n-M/2)}
$$

6. 加窗：

$$
h[n]=h_d[n]w[n]
$$

7. 验证通带、阻带和过渡带。

