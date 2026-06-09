# TP2 Circuits à capacités commutées 实验教程

这次 TP2 的主题是 **开关电容电路**（switched-capacitor circuits）。核心目标是：先理解一个开关电容积分器，再用两个离散积分器构造正弦振荡器，最后在 LTspice 中实现一个频率可调的正弦发生器。

实验给定采样频率：

$$
f_e=\frac{1}{T_e}=1.0\,\mathrm{kHz}
$$

所以采样周期是：

$$
T_e=1\,\mathrm{ms}
$$

---

## 0. 文件夹里的文件分别有什么用

TP2 文件夹中主要有：

| 文件 | 作用 |
|---|---|
| `TP2_Capacom_new.pdf` | 实验题目原文，共 12 个问题 |
| `TP_Capacom/gen-sin.m` | Matlab/Octave 脚本，用来仿真离散振荡器 |
| `TP_Capacom/gen-sin.ipynb` | Jupyter 版本，内容和 `gen-sin.m` 类似 |
| `TP_Capacom/Tremolo.m` | 音频 tremolo 效果演示脚本，和本 TP 的主线关系不大 |
| `TP_Capacom/*.wav` | 给 `Tremolo.m` 使用的音频素材 |

本实验最重要的是：

1. `TP2_Capacom_new.pdf`
2. `gen-sin.m` 或 `gen-sin.ipynb`
3. LTspice

`.wav` 和 `Tremolo.m` 可以先不管，它们更像补充演示材料，不是 12 个问题的主线。

---

## 1. 第一部分：非反相开关电容积分器

### 1.1 这部分要做什么

第一部分研究这个电路：

- 一个运放；
- 一个反馈电容 $C_2$；
- 一个输入采样电容 $C_1$；
- 四个由 $\Phi_1$ 和 $\Phi_2$ 控制的开关。

定义：

$$
k=\frac{C_1}{C_2}
$$

题目要求证明，在偶数采样时刻，也就是 $\Phi_2$ 结束时，积分器的传递函数为：

$$
I(z)=\frac{V_s(z)}{V_e(z)}
=
\frac{kz^{-1}}{1-z^{-1}}
$$

这个式子的意思是：输出会把之前采样到的输入一点一点累加起来，所以它是一个离散时间积分器。

---

### 1.2 第 1 问：传递函数怎么来

开关电容积分器每个周期的输出变化可以写成：

$$
V_s[n]-V_s[n-1]=kV_e[n-1]
$$

对两边做 $z$ 变换：

$$
V_s(z)-z^{-1}V_s(z)=kz^{-1}V_e(z)
$$

整理：

$$
V_s(z)(1-z^{-1})=kz^{-1}V_e(z)
$$

所以：

$$
\frac{V_s(z)}{V_e(z)}
=
\frac{kz^{-1}}{1-z^{-1}}
$$

也就是题目给出的结果。

---

### 1.3 第 2 问：$V_e=1\,\mathrm{V}$，$k=1$ 时输出是多少

题目给：

$$
V_e=1\,\mathrm{V}
$$

$$
V_s(0)=0
$$

$$
k=1
$$

递推公式是：

$$
V_s[n]=V_s[n-1]+kV_e[n-1]
$$

代入 $k=1$ 和 $V_e=1\,\mathrm{V}$：

$$
V_s[n]=V_s[n-1]+1
$$

所以理论输出为：

| 周期 $n$ | $V_s[n]$ |
|---:|---:|
| 0 | $0\,\mathrm{V}$ |
| 1 | $1\,\mathrm{V}$ |
| 2 | $2\,\mathrm{V}$ |
| 3 | $3\,\mathrm{V}$ |
| 4 | $4\,\mathrm{V}$ |
| 5 | $5\,\mathrm{V}$ |
| 6 | $6\,\mathrm{V}$ |
| 7 | $7\,\mathrm{V}$ |
| 8 | $8\,\mathrm{V}$ |
| 9 | $9\,\mathrm{V}$ |
| 10 | $10\,\mathrm{V}$ |

但真实 LTspice 仿真里运放供电是：

$$
+5\,\mathrm{V},\quad -5\,\mathrm{V}
$$

所以输出不会真的涨到 $10\,\mathrm{V}$，而是在接近 $+5\,\mathrm{V}$ 后饱和。

---

### 1.4 第 3 问：LTspice 仿真怎么做

这一步要在 LTspice 里搭第一部分的积分器，并画出输入和输出。

#### 元件

需要：

- `UniversalOpamp2`
- 两个电容 $C_1$ 和 $C_2$
- 四个 voltage-controlled switch
- 两个时钟电压源 $\Phi_1$ 和 $\Phi_2$
- 一个输入直流电压源 $V_e=1\,\mathrm{V}$
- 两个运放电源 $+5\,\mathrm{V}$ 和 $-5\,\mathrm{V}$

#### 电容

题目要求：

$$
C_1=C_2=10\,\mathrm{pF}
$$

在 LTspice 里直接写：

```text
10p
```

这样：

$$
k=\frac{C_1}{C_2}=1
$$

#### 开关模型

用 `Spice Directive` 加入：

```spice
.model SWID SW(Ron=1 Roff=1g Vt=2.5 Vh=2)
```

然后每个开关的 `Value` 写：

```text
SWID
```

#### 时钟 $\Phi_1$

题目给：

$$
T_e=1\,\mathrm{ms}
$$

$\Phi_1$ 用：

```spice
PULSE(0 5 0 10u 10u 480u 1m)
```

含义：

- 低电平：$0\,\mathrm{V}$
- 高电平：$5\,\mathrm{V}$
- 延迟：$0$
- 上升时间：$10\,\mu\mathrm{s}$
- 下降时间：$10\,\mu\mathrm{s}$
- 高电平持续时间：$480\,\mu\mathrm{s}$
- 周期：$1\,\mathrm{ms}$

#### 时钟 $\Phi_2$

$\Phi_2$ 与 $\Phi_1$ 相差半个周期，所以延迟 $500\,\mu\mathrm{s}$：

```spice
PULSE(0 5 500u 10u 10u 480u 1m)
```

#### 仿真命令

仿真 10 ms：

```spice
.tran 10m
```

#### 要画的波形

运行后画：

```text
V(ve)
V(vs)
V(phi1)
V(phi2)
```

要观察：

- $V_e$ 是一条 $1\,\mathrm{V}$ 的水平线；
- $\Phi_1$ 和 $\Phi_2$ 是两个错开半周期的方波；
- $V_s$ 一开始每个周期增加约 $1\,\mathrm{V}$；
- $V_s$ 接近 $+5\,\mathrm{V}$ 后饱和。

这就是第 3 问要比较的结果：仿真一开始和第 2 问理论结果一致，但后面受运放供电限制而饱和。

---

## 2. 第二部分：第一个离散振荡器

### 2.1 这部分要做什么

题目想生成一个正弦波：

$$
x(t)=x_1\cos(\omega_0t)+x_2\sin(\omega_0t)
$$

正弦波满足：

$$
\frac{d^2x}{dt^2}+\omega_0^2x=0
$$

可以拆成两个一阶方程：

$$
\frac{dx}{dt}=\omega_0 y
$$

$$
\frac{dy}{dt}=-\omega_0 x
$$

所以如果用两个积分器互相连接，就能做出振荡器。

---

### 2.2 第 4 问：用哪种 Euler 近似

Euler 近似有两种写法：

$$
\frac{dx}{dt}[n]\approx\frac{x[n]-x[n-1]}{T_e}
$$

或者：

$$
\frac{dx}{dt}[n]\approx\frac{x[n+1]-x[n]}{T_e}
$$

第一个振荡器对应显式 Euler：

$$
\frac{x[n+1]-x[n]}{T_e}=\omega_0y[n]
$$

$$
\frac{y[n+1]-y[n]}{T_e}=-\omega_0x[n]
$$

所以：

$$
x[n+1]=x[n]+k y[n]
$$

$$
y[n+1]=y[n]-k x[n]
$$

其中：

$$
k=\omega_0T_e
$$

---

### 2.3 第 5 问：用 `gen-sin.m` 仿真

打开：

```text
TP_Capacom/gen-sin.m
```

原始代码是：

```matlab
k=0.05; N=1000;

x=zeros(N); y=zeros(N);
x(1)=1;

for i = 1:N-1,
  x(i+1) = x(i) + k * y(i);
  y(i+1) = y(i) - k * x(i);
end
```

这个就是第一个振荡器。

观察结果：

- $x$ 和 $y$ 看起来像正弦/余弦；
- 但是振幅会慢慢变大；
- 相图不是闭合圆，而是向外螺旋。

结论：

> The first oscillator is unstable.

---

### 2.4 第 6 问：用极点解释稳定性

题目给第一个振荡器的极点：

$$
z_{\pm}=1\pm jk
$$

模长是：

$$
|z_{\pm}|=\sqrt{1+k^2}
$$

只要：

$$
k>0
$$

就有：

$$
\sqrt{1+k^2}>1
$$

所以极点在单位圆外，系统不稳定。

---

## 3. 第三部分：第二个离散振荡器

### 3.1 这部分要做什么

为了让振荡器稳定，题目修改第二个积分器，让环路中少一个延迟。

新的方程是：

$$
x[n+1]=x[n]+k y[n]
$$

$$
y[n+1]=y[n]-k x[n+1]
$$

注意第二行用的是新的 $x[n+1]$，不是旧的 $x[n]$。

---

### 3.2 第 7 问：修改 `gen-sin.m`

把原始循环：

```matlab
for i = 1:N-1,
  x(i+1) = x(i) + k * y(i);
  y(i+1) = y(i) - k * x(i);
end
```

改成：

```matlab
for i = 1:N-1,
  x(i+1) = x(i) + k * y(i);
  y(i+1) = y(i) - k * x(i+1);
end
```

这就是第二个振荡器。

---

### 3.3 第 8 问：仿真结论

运行修改后的脚本。

观察：

- $x$ 和 $y$ 保持振荡；
- 振幅不再明显发散；
- 相图接近闭合轨迹。

结论：

> The second oscillator is stable or marginally stable for suitable values of $k$.

---

### 3.4 第 9 问：稳定条件

题目给第二个振荡器的极点：

当：

$$
k\leq 2
$$

时：

$$
z_{\pm}
=
\frac{2-k^2\pm jk\sqrt{4-k^2}}{2}
$$

计算模长：

$$
|z_{\pm}|^2
=
\left(\frac{2-k^2}{2}\right)^2
+
\left(\frac{k\sqrt{4-k^2}}{2}\right)^2
$$

展开：

$$
|z_{\pm}|^2
=
\frac{(2-k^2)^2+k^2(4-k^2)}{4}
$$

$$
=
\frac{4}{4}
=1
$$

所以当：

$$
0<k<2
$$

极点在单位圆上，系统保持有界振荡。

稳定条件写成：

$$
\boxed{0<k<2}
$$

---

## 4. 第四部分：LTspice 中实现正弦发生器

### 4.1 这部分要做什么

最后要在 LTspice 中搭第二个振荡器，让它产生频率在：

$$
2\,\mathrm{Hz}\sim 20\,\mathrm{Hz}
$$

之间的正弦波。

题目要求：

$$
C_2=10\,\mathrm{pF}
$$

通过改变 $C_1$ 改变：

$$
k=\frac{C_1}{C_2}
$$

从而改变振荡频率。

---

### 4.2 第 10 问：计算 2 Hz 和 20 Hz 对应的 $k$ 和 $C_1$

第二个振荡器的极点可以写成：

$$
z=e^{j\theta}
$$

其中：

$$
\cos\theta=1-\frac{k^2}{2}
$$

所以：

$$
\theta=2\arcsin\left(\frac{k}{2}\right)
$$

频率关系：

$$
f_0=\frac{\theta}{2\pi T_e}
$$

反过来得到：

$$
k=2\sin\left(\pi\frac{f_0}{f_e}\right)
$$

因为：

$$
f_e=1000\,\mathrm{Hz}
$$

所以 2 Hz 时：

$$
k=2\sin\left(\pi\frac{2}{1000}\right)
\approx 0.01257
$$

$$
C_1=kC_2=0.01257\times 10\,\mathrm{pF}
\approx 0.126\,\mathrm{pF}
$$

20 Hz 时：

$$
k=2\sin\left(\pi\frac{20}{1000}\right)
\approx 0.1256
$$

$$
C_1=kC_2=0.1256\times 10\,\mathrm{pF}
\approx 1.26\,\mathrm{pF}
$$

---

### 4.3 第 11 问：为什么仿真不会自己振起来

如果理想系统初始条件全是 0：

$$
x[0]=0,\quad y[0]=0
$$

那么递推以后永远是：

$$
x[n]=0,\quad y[n]=0
$$

所以理想仿真中振荡器不会自己启动。

实际电路中会有：

- 噪声；
- 运放 offset；
- 开关注入电荷；
- 初始电容电荷不完全为 0；
- 数值扰动。

这些都会给系统一个很小的初始扰动，让振荡开始。

题目让你加一个 `PULSE` 到某个运放正输入端，就是人为给系统一个启动扰动。

可以这样解释：

> With zero initial conditions, the ideal oscillator remains at rest. In practice, noise, offsets and charge injection initiate oscillations. In simulation, a pulse source is added to create a non-zero initial condition.

---

### 4.4 第 12 问：采样频率 $f_e$ 高一点或低一点有什么影响

题目固定了：

$$
f_e=1\,\mathrm{kHz}
$$

然后通过改变 $k$ 调频。

如果选择更高的 $f_e$：

优点：

- 每个周期采样点更多；
- 生成的正弦波更平滑；
- 离散近似更接近连续系统；
- 频率误差和波形失真更小。

缺点：

- 开关要更快；
- 运放需要更高带宽和更快 settling；
- 功耗可能变大；
- 对时钟非理想和开关注入更敏感；
- 对同样的 $f_0$，$k$ 会更小，导致 $C_1$ 很小，难以精确实现。

如果选择更低的 $f_e$：

优点：

- 电路速度要求降低；
- 时钟更容易实现；
- 对同样的 $f_0$，$C_1$ 可以更大，更容易实现。

缺点：

- 正弦波采样点更少；
- 波形更粗糙；
- 离散近似误差更大；
- 更容易出现 aliasing 或频谱杂散；
- 必须保持 $f_0$ 远小于 $f_e/2$。

---

## 5. 实验最终要交什么

报告里建议按这个顺序写：

1. 实验目的：用开关电容积分器构造振荡器。
2. 第一部分：推导积分器传递函数。
3. 第一部分：计算 $V_e=1\,\mathrm{V}$、$k=1$ 时的理论输出。
4. 第一部分：贴 LTspice 波形，说明输出阶梯上升并在 $+5\,\mathrm{V}$ 附近饱和。
5. 第二部分：写第一个振荡器的离散方程。
6. 第二部分：用 `gen-sin.m` 说明第一个振荡器不稳定。
7. 第二部分：用 $z_{\pm}=1\pm jk$ 解释为什么不稳定。
8. 第三部分：写第二个振荡器的离散方程。
9. 第三部分：说明修改 `gen-sin.m` 后系统有界振荡。
10. 第三部分：推导稳定条件 $0<k<2$。
11. 第四部分：计算 2 Hz 和 20 Hz 对应的 $k$ 与 $C_1$。
12. 第四部分：解释为什么零初始条件下不会启动，以及为什么要加 pulse。
13. 第四部分：讨论采样频率 $f_e$ 的取舍。

---

## 6. 关键答案汇总

积分器传递函数：

$$
I(z)=\frac{kz^{-1}}{1-z^{-1}}
$$

常数输入时递推：

$$
V_s[n]=V_s[n-1]+kV_e[n-1]
$$

$V_e=1\,\mathrm{V}$、$k=1$ 时：

$$
V_s[n]=n\,\mathrm{V}
$$

第一个振荡器：

$$
x[n+1]=x[n]+k y[n]
$$

$$
y[n+1]=y[n]-k x[n]
$$

极点：

$$
z_{\pm}=1\pm jk
$$

因为：

$$
|z_{\pm}|=\sqrt{1+k^2}>1
$$

所以不稳定。

第二个振荡器：

$$
x[n+1]=x[n]+k y[n]
$$

$$
y[n+1]=y[n]-k x[n+1]
$$

稳定条件：

$$
\boxed{0<k<2}
$$

频率调节公式：

$$
k=2\sin\left(\pi\frac{f_0}{f_e}\right)
$$

2 Hz：

$$
k\approx 0.01257,\qquad C_1\approx 0.126\,\mathrm{pF}
$$

20 Hz：

$$
k\approx 0.1256,\qquad C_1\approx 1.26\,\mathrm{pF}
$$
