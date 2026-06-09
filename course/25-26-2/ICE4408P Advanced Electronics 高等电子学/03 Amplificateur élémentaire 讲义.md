# 03 Amplificateur élémentaire 讲义

来源：[[ppt/ELEC101_Amplificateur_SE 2026.pdf|ELEC101_Amplificateur_SE 2026.pdf]]

这一讲进入 acquisition chain 里的放大器部分。前两讲讲的是如何描述连续/离散信号以及采样；这一讲关心的是：真实输入信号往往很小，怎样用晶体管把它放大？为什么晶体管本身是非线性的，但我们仍然可以在某个工作点附近把它当作线性放大器？放大器的增益、带宽、噪声、失真又如何评价？

## p.1-p.3 这一讲的位置

PPT 的目录分成三部分：

1. Introduction：为什么需要放大器。
2. Amplificateur élémentaire：用最简单的 NMOS + 负载电阻构成电压放大器。
3. Source d'erreur et métrique d'évaluation：放大器误差来源，以及用 SNR、SNDR 等指标评价。

这里的 élémentaire 不是说不重要，而是说先研究最基本的单端放大结构。后续差分放大器、运放和反馈都建立在这套小信号分析上。

## p.4 放大器在采集链路里的作用

PPT 的链路是：

$$
\text{Entrée analogique}
\rightarrow \text{TL/TZ}
\rightarrow \text{Amplificateur}
\rightarrow \text{Filtre}
\rightarrow \text{CAN}
\rightarrow \text{Sortie numérique}
$$

放大器有两个主要作用。

第一，放大低幅度信号。传感器、天线、通信接收端得到的信号常常很弱，如果直接送入滤波器或 ADC，会被噪声、失调、量化误差淹没。

第二，放大器不仅用于“放大”，还用于实现滤波器和 ADC 内部的基本功能。比如有源滤波器需要运放，比较器和采样保持电路也依赖放大结构。

所以这一讲不是孤立电路，而是在回答：**如何让后级系统看到一个足够大、但又尽量不失真的模拟信号。**

## p.5 远距离传输后的弱信号例子

PPT 给出一个通信链路例子：

- $5\,\mathrm{km}$ 后有 $69\,\mathrm{dB}$ 衰减。
- 发射信号幅度为 $1\,\mathrm{V}$。
- 接收端只剩约 $0.36\,\mathrm{mV}$。

dB 衰减和电压幅度比的关系是：

$$
A_{dB}=20\log_{10}\left(\frac{V_{\mathrm{out}}}{V_{\mathrm{in}}}\right)
$$

若衰减为 $-69\,\mathrm{dB}$：

$$
\frac{V_{\mathrm{out}}}{V_{\mathrm{in}}}
=10^{-\frac{69}{20}}
\approx 3.55\times 10^{-4}
$$

所以：

$$
V_{\mathrm{out}}\approx 1\,\mathrm{V}\times 3.55\times 10^{-4}
=0.355\,\mathrm{mV}
$$

这和 PPT 的 $0.36\,\mathrm{mV}$ 一致。

这个例子说明：如果没有接收端放大器，后续 ADC 很可能根本无法有效分辨信号。

## p.6 电压放大的三个 ingredients

PPT 说实现电压放大通常需要三样东西：

1. 电源：source d'alimentation，比如电池、整流电源、$V_{DD}$。
2. 电压到电流的调制器：modulateur tension/courant，典型器件是 transistor。
3. 把电流变回电压的负载：charge，可以是电阻、电感，或者另一个晶体管。

也就是说，基本放大器不是凭空把能量变大。输入小信号只是在“控制”电源能量如何流向负载。输出信号能量主要来自电源。

最简单的抽象是：

$$
v_e \rightarrow i_T \rightarrow v_s
$$

其中 transistor 把输入电压变化转换成电流变化，负载再把电流变化转换成输出电压变化。

## p.7 进入基本放大器

这一页只是目录跳转：从 introduction 进入 amplificateur élémentaire。

后面会从一个理想电流源模型开始，再换成真实 NMOS。这样安排的意义是先看清“放大”本质，再讨论真实器件非线性。

## p.8 理想放大器：受控电流源 + 电阻负载

PPT 先假设有一个理想受控电流源：

$$
I_T=g_mV_e
$$

这里：

- $V_e$ 是输入电压。
- $I_T$ 是被输入电压控制的电流。
- $g_m$ 是跨导 transconductance，单位是 $\mathrm{A/V}$。

电路上方有电源 $V_{DD}$，负载电阻为 $R_d$。输出节点电压是：

$$
V_s=V_{DD}-R_dI_T
$$

代入 $I_T=g_mV_e$：

$$
V_s=V_{DD}-R_dg_mV_e
$$

电压增益定义为输出对输入的导数：

$$
A=\frac{\partial V_s}{\partial V_e}
$$

所以：

$$
A=-R_dg_m
$$

负号表示这是反相放大器：输入 $V_e$ 增大，电流 $I_T$ 增大，电阻上的压降 $R_dI_T$ 增大，于是输出 $V_s$ 下降。

这个理想模型抓住了基本放大器的核心：

$$
\text{电压变化}
\xrightarrow{g_m}
\text{电流变化}
\xrightarrow{R_d}
\text{电压变化}
$$

## p.9 真实放大器：用 transistor 近似电流源

PPT 接着说，现实中没有完美线性受控电流源。最接近的器件是 transistor，比如 NMOS。

但 NMOS 有两个问题：

1. 它不总是工作在 source de courant 区域。
2. 即使在电流源区域，电流和输入电压的关系也不是线性的。

所以真实放大器需要解决两个层面的问题：

- 工作区选择：让 transistor 落在合适区域。
- 线性化：在工作点附近把非线性曲线近似成直线。

这就是后面静态分析和小信号分析的原因。

## p.10 NMOS 的三个工作区

PPT 把 NMOS 看成三种等效行为。

### 1. 开路开关

当：

$$
V_{GS}<V_T
$$

其中 $V_T$ 是阈值电压，transistor 关断，近似为开路。

### 2. 电流源

当：

$$
V_{GS}>V_T
$$

且：

$$
V_{DS}>V_{GS}-V_T
$$

NMOS 工作在饱和区，近似为电流源。PPT 给出的电流模型是：

$$
I_T=K(V_{GS}-V_T)^2
$$

这里 $K$ 是和工艺、尺寸相关的常数。

这一段是做放大器最想要的区域，因为输入电压控制电流，电流再通过负载变成输出电压。

### 3. 电阻

当：

$$
V_{GS}>V_T
$$

且：

$$
V_{DS}<V_{GS}-V_T
$$

NMOS 更像一个受控电阻。PPT 写成：

$$
R_T=\frac{K'}{V_{GS}-V_T}
$$

在这个区域，transistor 不再适合作为理想电流源放大器。

## p.11 NMOS 放大器的非线性传输关系

对 NMOS 共源放大结构，输入是：

$$
V_e=V_{GS}
$$

电流是：

$$
I_T=K(V_e-V_T)^2
$$

输出：

$$
V_s=V_{DD}-R_dI_T
$$

所以：

$$
V_s=V_{DD}-R_dK(V_e-V_T)^2
$$

PPT 标出问题：$V_s$ 和 $V_e$ 是二次关系，不是线性关系。

如果输入变化很大，输出会明显弯曲，产生失真。解决办法不是让 transistor 变成全局线性，而是在一个合适的工作点附近做局部线性近似。

## p.12 静态分析：工作点与传输曲线

PPT 的图画的是静态传输曲线：

$$
V_s=f(V_e)
$$

曲线分为三个区域：

- Zone 1：interrupteur ouvert，transistor 关断，输出接近 $V_{DD}$。
- Zone 2：source de courant，适合放大。
- Zone 3：résistance，输出接近低电平，transistor 像电阻。

选择一个工作点：

$$
M_0=(V_{E0},V_{S0})
$$

在工作点附近定义小信号：

$$
v_e=V_e-V_{E0}
$$

$$
v_s=V_s-V_{S0}
$$

曲线在 $M_0$ 附近可用切线近似：

$$
v_s\simeq A v_e
$$

其中：

$$
A=\left.\frac{dV_s}{dV_e}\right|_{V_{E0}}
$$

这就是小信号增益。注意这里有两个层次：

- 大写 $V_e,V_s$：总电压，包含 DC 工作点。
- 小写 $v_e,v_s$：围绕工作点的小变化。

这一页是整讲的门槛：放大器不是全局线性的，而是在 bias point 附近局部线性。

## p.13 输入动态范围与输出动态范围

PPT 定义 dynamique d'entrée 和 dynamique de sortie。

输入动态范围 $\Delta V_e$：在工作点 $V_{E0}$ 附近，输入还能被传输曲线近似为线性的范围。

输出动态范围 $\Delta V_s$：对应的输出变化范围。

如果输入太小，输出可能被噪声主导；如果输入太大，曲线非线性明显，输出失真或饱和。

所以放大器设计总是在平衡：

$$
\text{足够大信号}
\quad \text{vs.} \quad
\text{仍在近似线性区}
$$

动态范围越大，系统越能容忍输入幅度变化；但对于简单 NMOS 放大器，这个范围通常有限。

## p.14 小信号分析方法

PPT 定义 analyse petit signal：研究电路对工作点附近无穷小变化的响应。

它可以快速求：

- 增益；
- 输入阻抗；
- 输出阻抗；
- 截止频率；
- 频率响应。

小信号分析步骤有两条：

### 1. 非线性器件线性化

NMOS 被替换成线性受控电流源：

$$
i_t=g_m v_e
$$

这里 $g_m$ 是在工作点处的跨导：

$$
g_m=\left.\frac{dI_T}{dV_{GS}}\right|_{V_{GS}=V_{E0}}
$$

若：

$$
I_T=K(V_{GS}-V_T)^2
$$

则：

$$
g_m=2K(V_{E0}-V_T)
$$

### 2. DC 电源小信号接地

小信号分析只看变化量。理想 DC 电源 $V_{DD}$ 的变化量为 $0$，所以在小信号等效电路中，$V_{DD}$ 被短路到地。

这不是说电源真的消失，而是说电源在小信号意义下是 AC ground。

## p.15 基本放大器的小信号模型

PPT 把 NMOS 共源放大器变成小信号模型：

- NMOS 变成受控电流源 $g_mv_e$。
- $V_{DD}$ 短路到地。
- 负载电阻 $R_d$ 接到小信号地。

输出电压是电流源流过 $R_d$ 产生的电压。由于电流方向使输出节点电压下降：

$$
v_s=-g_mR_dv_e
$$

所以小信号增益为：

$$
A=\frac{v_s}{v_e}=-g_mR_d
$$

这个结果和 p.8 的理想模型一致，但现在它来自真实 NMOS 在工作点附近的线性化。

PPT 还画了 Thévenin 等效模型：

$$
v_s=-g_mR_dv_e
$$

也就是输出可以看成一个受输入控制的反相电压源。

## p.16 放大器频率响应

放大器增益不是所有频率都一样。PPT 定义频率响应：

$$
A(j\omega)=\frac{v_s(j\omega)}{v_e(j\omega)}
$$

图中低频增益为 $A_0$，随着频率升高，电容效应使增益下降。

几个关键概念：

### 截止频率

$f_c$ 是低频增益下降 $3\,\mathrm{dB}$ 的频率。一阶低通放大器常写成：

$$
A(j2\pi f)=\frac{A_0}{1+j\frac{f}{f_c}}
$$

### 过渡频率

$f_T$ 是增益降到 $1$ 的频率，也就是：

$$
|A(f_T)|=1
$$

在 dB 中等于：

$$
0\,\mathrm{dB}
$$

### 增益带宽积

PPT 给出：

$$
PGB=A_0f_c
$$

PGB 是 produit gain bande，增益带宽积。对于一阶主极点放大器，在一定条件下它近似等于 $f_T$。

图上还标出：

- 增益斜率 $-6\,\mathrm{dB/oct}$，对应 $-20\,\mathrm{dB/dec}$。
- 更高阶极点叠加后可能出现 $-12\,\mathrm{dB/oct}$。
- 相位随频率下降，接近 $-180^\circ$ 时会影响反馈稳定性。

## p.17 增益带宽积守恒

PPT 用三个例子说明同一个放大器族的 PGB 近似守恒：

$$
100\times 100\,\mathrm{MHz}=10\,\mathrm{GHz}
$$

$$
1\times 10\,\mathrm{GHz}=10\,\mathrm{GHz}
$$

$$
10000\times 1\,\mathrm{MHz}=10\,\mathrm{GHz}
$$

对一阶传递函数：

$$
A(j2\pi f)=\frac{A_0}{1+j\frac{f}{f_c}}
$$

当：

$$
f\gg f_c
$$

幅值近似为：

$$
|A(f)|\simeq A_0\frac{f_c}{f}
$$

在 $f=f_T$ 时：

$$
|A(f_T)|=1
$$

所以：

$$
1\simeq A_0\frac{f_c}{f_T}
$$

得到：

$$
f_T\simeq A_0f_c
$$

这说明提高低频增益通常会牺牲带宽；要更大增益同时保持带宽，就需要更高的 $f_T$ 或更复杂架构。

## p.18-p.23 练习 1：一级与两级放大器频率响应

PPT 给出两个电路：

- 单级 NMOS 共源放大器，输出端有负载电容 $C_L$。
- 两级级联放大器，每一级有自己的负载电阻和负载电容。

### 单级小信号模型

单级电路的小信号模型包含：

- 受控电流源 $g_mv_e$。
- 负载电阻 $R_d$。
- 输出电容 $C_L$。

输出节点看到的是 $R_d$ 和 $C_L$ 形成的一阶低通。传递函数为：

$$
G_{1-\mathrm{et}}(p)
=\frac{-g_mR_d}{R_dC_Lp+1}
$$

低频增益：

$$
G_0=-g_mR_d
$$

极点：

$$
p_1=-\frac{1}{R_dC_L}
$$

截止角频率：

$$
\omega_c=\frac{1}{R_dC_L}
$$

对应频率：

$$
f_c=\frac{1}{2\pi R_dC_L}
$$

频率响应幅值：

$$
|G_1(\omega)|
=\frac{g_mR_d}
{\sqrt{1+R_d^2C_L^2\omega^2}}
$$

它就是低通形式：低频放大，高频因为电容旁路/充放电限制而衰减。

### 两级级联

两级放大器的总增益是两级传递函数相乘：

$$
G_{\mathrm{tot}}(p)=G_1(p)G_2(p)
$$

PPT 给出：

$$
G_{\mathrm{tot}}(p)
=
\frac{g_m^2R_{d1}R_{d2}}
{R_{d1}R_{d2}C_{L1}C_{L2}p^2
+(R_{d1}C_{L1}+R_{d2}C_{L2})p+1}
$$

如果把它写成两个一阶因子：

$$
G_{\mathrm{tot}}(p)
=
\frac{g_m^2R_{d1}R_{d2}}
{(1+R_{d1}C_{L1}p)(1+R_{d2}C_{L2}p)}
$$

则两个极点是：

$$
p_1=-\frac{1}{R_{d1}C_{L1}}
$$

$$
p_2=-\frac{1}{R_{d2}C_{L2}}
$$

低频增益：

$$
G_{\mathrm{DC},2\mathrm{et}}
=g_m^2R_{d1}R_{d2}
$$

PPT 数值例子里单级低频增益是：

$$
G_{\mathrm{DC},1\mathrm{et}}=R_dg_m=30
$$

两级低频增益是：

$$
G_{\mathrm{DC},2\mathrm{et}}=R_1R_2g_m^2=900
$$

### 两级稳定性

PPT 结论是：两个极点都是实数且负数，只要：

$$
R_{d1}>0,\quad R_{d2}>0,\quad C_{L1}>0,\quad C_{L2}>0
$$

就有：

$$
p_1<0,\quad p_2<0
$$

因此这个开环两级 RC 型放大器本身稳定。

注意：这里讲的是没有反馈闭环的传递函数稳定性。后面讲运放和反馈时，多级放大器的相位裕度会变成大问题。

## p.24 进入误差来源与评价指标

这一页是目录跳转，从“放大器结构和频响”进入“误差与评价”。

对真实放大器来说，只有增益还不够。一个放大器可能增益很大，但如果噪声大、失真强、带宽不足，仍然不能用于高质量采集系统。

## p.25 放大器误差来源：噪声与失真

PPT 把电子系统精度下降的来源分为两大类：

1. Bruit：噪声。
2. Distorsion：失真。

### 噪声

噪声可以建模为叠加在有用信号上的随机信号：

$$
y(t)=s(t)+b(t)
$$

其中 $s(t)$ 是有用信号，$b(t)$ 是噪声。

白噪声的功率谱密度 DSP 是常数，也就是每个频率附近的噪声功率密度相同。

有色噪声的 DSP 不均匀，不同频段噪声强度不同。

### 失真

失真是由系统对输入信号的非理想响应造成的，幅度通常依赖输入信号本身。

PPT 分为：

- 线性失真：可以理解为滤波。例如不同频率增益不同、相位延迟不同。
- 非线性失真：产生输入中原本没有的新频率成分。

## p.26 常见噪声类型

PPT 列出白噪声和有色噪声。

### 白噪声

包括：

- 热噪声：来自电阻和晶体管中载流子的热运动。
- 量化噪声：ADC 量化带来的误差。
- 相位噪声：会导致时钟抖动 jitter。

如果白噪声功率谱密度为 $DSP$，带宽为 $B$，噪声功率近似：

$$
P_B=DSP\cdot B
$$

这正是后面例题中用的公式。

### 有色噪声

包括：

- flicker noise，也叫 $1/f$ 噪声，低频更明显。
- popcorn noise，表现为随机跳变。

在低频、高精度模拟电路中，$1/f$ 噪声经常比白噪声更麻烦。

## p.27 非线性失真的来源与后果

PPT 列出非线性失真的原因：

- 饱和 saturation。
- 符号间干扰 interférence entre symbole。
- 器件 mismatch，组件不匹配。

非线性的后果：

1. 分辨率下降。
2. 频谱中出现输入频率整数倍的新分量。

如果输入是单频：

$$
v_e(t)=A\cos(\omega t)
$$

理想线性放大器输出应该只有同一个频率：

$$
v_s(t)=GA\cos(\omega t)
$$

但非线性放大器会产生：

$$
\cos(2\omega t),\quad \cos(3\omega t),\ldots
$$

这些就是 harmonics，谐波。

## p.28 用多项式模型解释谐波

PPT 用二阶多项式建模非线性放大器：

$$
V_{s-\mathrm{rl}}=\alpha+\beta V_e+\gamma V_e^2
$$

输入是：

$$
V_e=Amp\cdot \cos(\omega t)
$$

代入：

$$
V_{s-\mathrm{rl}}
=\alpha+\beta Amp\cos(\omega t)
+\gamma Amp^2\cos^2(\omega t)
$$

利用：

$$
\cos^2(\omega t)=\frac{1+\cos(2\omega t)}{2}
$$

得到：

$$
V_{s-\mathrm{rl}}
=\alpha+\frac{\gamma Amp^2}{2}
+\beta Amp\cos(\omega t)
+\frac{\gamma Amp^2}{2}\cos(2\omega t)
$$

可以分成三部分：

### DC 分量

$$
V_0=\alpha+\frac{\gamma Amp^2}{2}
$$

### 基波分量

$$
V_1=\beta Amp
$$

频率是 $\omega$。

### 二次谐波

$$
V_2=\frac{\gamma Amp^2}{2}
$$

频率是 $2\omega$。

这说明二阶非线性会产生二次谐波。更高阶多项式会产生更高次谐波。

## p.29 SNR 与 SNDR

PPT 给出两个主要指标。

### SNR

SNR 只衡量信号和噪声：

$$
SNR_{dB}
=10\log_{10}\left(\frac{P_{\mathrm{signal}}}{P_{\mathrm{bruit}}}\right)
$$

如果 $SNR$ 越大，说明噪声越小，信号越清楚。

### SNDR / SINAD

SNDR 同时考虑噪声和失真：

$$
SNDR_{dB}
=10\log_{10}
\left(
\frac{P_{\mathrm{signal}}}
{P_{\mathrm{bruit}}+P_{\mathrm{distorsion}}}
\right)
$$

对正弦输出，如果基波幅值是 $V_1$，二次、三次等谐波幅值是 $V_2,V_3,\ldots$，噪声均方根是 $V_{\mathrm{rms-bruit}}$，则：

$$
SNDR_{dB}
=10\log_{10}
\left(
\frac{\frac{V_1^2}{2}}
{\frac{1}{2}(V_2^2+V_3^2+\cdots)+V_{\mathrm{rms-bruit}}^2}
\right)
$$

这里用 $\frac{V^2}{2}$ 是因为幅值为 $V$ 的正弦信号，其平均功率与：

$$
V_{\mathrm{rms}}^2=\left(\frac{V}{\sqrt{2}}\right)^2=\frac{V^2}{2}
$$

成正比。

## p.30 放大器输出频谱

PPT 展示了一个音频放大器 ADAU1592 的输出频谱。

读这类图时要看：

- 主峰：有用信号基波。
- 其他离散尖峰：谐波或杂散 spur。
- 底部连续噪声地板：noise floor。

如果只有基波且噪声地板很低，说明放大器比较理想。如果二次、三次谐波很高，则非线性失真明显。若噪声地板高，则 SNR 低。

## p.31-p.36 练习 2：非线性 NMOS 放大器的 SNR/SNDR

PPT 给出一个受控电流源形式的放大器，并给出输出噪声谱。问题是：

1. 求线性化输出表达式。
2. 计算增益、有用信号功率、二次谐波功率。
3. 对 $A=0.1\,\mathrm{V}$ 和 $A=0.01\,\mathrm{V}$ 计算 SNR 和 SNDR。

### p.32-p.34 输出表达式展开

根据回路：

$$
V_s=V_{DD}-RI_T
$$

NMOS 电流模型：

$$
I_T=K(V_e-V_T)^2
$$

所以：

$$
V_s=V_{DD}-RK(V_e-V_T)^2
$$

输入设为：

$$
V_e=B+A\cos(\omega t)
$$

其中：

- $B$ 是 DC 偏置。
- $A\cos(\omega t)$ 是小信号输入。

代入：

$$
V_s
=V_{DD}-RK(B-V_T+A\cos(\omega t))^2
$$

展开：

$$
V_s
=V_{DD}-RK(B-V_T)^2
-2KRA(B-V_T)\cos(\omega t)
-RKA^2\cos^2(\omega t)
$$

再用：

$$
\cos^2(\omega t)=\frac{1+\cos(2\omega t)}{2}
$$

得到：

$$
V_s=\alpha_0+\alpha_1\cos(\omega t)+\alpha_2\cos(2\omega t)
$$

其中：

$$
\alpha_0
=V_{DD}-RK(B-V_T)^2-\frac{RKA^2}{2}
$$

$$
\alpha_1=-2KRA(B-V_T)
$$

$$
\alpha_2=-\frac{RKA^2}{2}
$$

这说明即使输入只有一个频率 $\omega$，输出也有 $2\omega$ 的二次谐波。

### p.35 增益与二次谐波功率

基波幅值是：

$$
|\alpha_1|=2KRA(B-V_T)
$$

输入幅值是 $A$，所以小信号增益幅值：

$$
G=\left|\frac{\alpha_1}{A}\right|
=2KR(B-V_T)
$$

有用输出信号功率：

$$
P_S=\frac{G^2A^2}{2}
$$

二次谐波幅值是：

$$
|\alpha_2|=\frac{RKA^2}{2}
$$

因此二次谐波功率：

$$
P_{\mathrm{harm2}}
=\frac{\alpha_2^2}{2}
=\frac{R^2K^2A^4}{8}
$$

PPT 数值结果：

$$
G=9.5
$$

当：

$$
A=0.1\,\mathrm{V}
$$

有：

$$
P_S=0.45\,\mathrm{V}^2
$$

$$
P_{\mathrm{harm2}}=3.125\times 10^{-4}\,\mathrm{V}^2
$$

### p.36 SNR 与 SNDR 数值

噪声功率由噪声谱密度乘以带宽：

$$
P_B=DSP\cdot Bande
$$

PPT 给出：

$$
P_B=5\times 10^{-9}\times 20000
=10^{-4}\,\mathrm{V}^2
$$

SNR：

$$
SNR_{dB}
=10\log_{10}\left(\frac{P_S}{P_B}\right)
$$

SNDR：

$$
SNDR_{dB}
=10\log_{10}
\left(
\frac{P_S}{P_B+P_D}
\right)
$$

这里 $P_D$ 主要取二次谐波功率：

$$
P_D=P_{\mathrm{harm2}}
$$

#### 情况 1：$A=0.1\,\mathrm{V}$

PPT 给出：

$$
P_S=0.45\,\mathrm{V}^2
$$

$$
P_{\mathrm{harm2}}=3.125\times 10^{-4}\,\mathrm{V}^2
$$

$$
P_B=10^{-4}\,\mathrm{V}^2
$$

所以：

$$
SNR=36.5\,\mathrm{dB}
$$

而：

$$
SNDR=30.4\,\mathrm{dB}
$$

可以看到 SNDR 明显低于 SNR，因为失真功率比噪声功率还大。

#### 情况 2：$A=0.01\,\mathrm{V}$

PPT 给出：

$$
P_S=0.0045\,\mathrm{V}^2
$$

$$
P_{\mathrm{harm2}}=3.125\times 10^{-8}\,\mathrm{V}^2
$$

此时：

$$
SNR=16.5\,\mathrm{dB}
$$

$$
SNDR=16.5\,\mathrm{dB}
$$

为什么两者几乎一样？因为输入幅度变小后，二次谐波功率按 $A^4$ 下降，非常小，主要误差变成噪声。

### 这个例题的关键直觉

有用信号功率：

$$
P_S\propto A^2
$$

二次谐波失真功率：

$$
P_{\mathrm{harm2}}\propto A^4
$$

所以输入幅度变大时：

- 信号功率增加，SNR 变好。
- 但非线性失真增长更快，SNDR 可能变差。

输入幅度变小时：

- 失真变得很小。
- 但信号也变小，噪声相对更明显。

这就是模拟前端设计里的经典折中：信号不能太小，否则噪声主导；也不能太大，否则失真主导。

## p.37 结束页

最后一页是 questions。

这讲到这里为止，真正需要吃下来的主线是：

$$
\text{NMOS 非线性}
\rightarrow \text{选择工作点}
\rightarrow \text{小信号线性化}
\rightarrow A=-g_mR_d
\rightarrow \text{频率响应与 PGB}
\rightarrow \text{噪声/失真}
\rightarrow \text{SNR/SNDR}
$$

看后面的差分放大器和反馈时，这几个概念会反复出现：工作点、小信号、跨导、负载、极点、增益带宽积、噪声和非线性失真。

