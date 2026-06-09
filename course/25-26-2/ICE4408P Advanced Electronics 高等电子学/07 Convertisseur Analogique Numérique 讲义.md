# 07 Convertisseur Analogique Numérique 讲义

来源：[[ppt/ELEC101_CAN 2026.pdf|ELEC101_CAN 2026.pdf]]

说明：目录里还有 [[ppt/ELEC101_CAN 2026 (2).pdf|ELEC101_CAN 2026 (2).pdf]]，它是同主题的较短版本；本讲义以 34 页主版为准。

这一讲是整条 acquisition chain 的最后一环：把模拟信号变成数字码。前面几讲已经讲了如何描述信号、采样、放大、反馈、开关电容和模拟滤波；ADC / CAN 则回答最后一个问题：**连续幅值如何被有限 bit 数表示？量化误差如何进入系统？不同 ADC 架构如何在速度、精度、面积、功耗之间取舍？**

这一讲主线是：

$$
\text{真实世界模拟信号}
\rightarrow \text{采样}
\rightarrow \text{量化}
\rightarrow \text{量化噪声/SQNR}
\rightarrow \text{噪声预算}
\rightarrow \text{SAR / Flash / Pipeline / Ramp / Double-ramp}
$$

要牢牢记住：ADC 不是一个“理想读数器”。它同时受到采样频率、量化步长、热噪声、$1/f$ 噪声、比较器误差、元件匹配、时钟和架构选择的限制。

## p.1-p.3 这一讲的结构

PPT 标题是 Convertisseur Analogique Numérique，简称 CAN；英文里对应 ADC，Analogue to Digital Converter。

PPT 的结构是：

1. Introduction：为什么需要 ADC。
2. Principe et erreur de Quantification：量化原理与量化误差。
3. Architectures principales：主要 ADC 架构。
4. Conclusion：不同架构的速度、分辨率、功耗取舍。

这讲要和第 2 讲采样区分开：

- 采样是时间离散化：

$$
t\rightarrow kT_e
$$

- 量化是幅值离散化：

$$
x[k]\rightarrow N[k]
$$

ADC 同时涉及这两件事。

## p.4 真实世界是模拟的

PPT 先强调：真实世界的信号在进入数字处理之前，通常都是模拟量。

例如：

- 有线通信和无线通信中的电压、电流、电磁波；
- 光纤通信中的光强或光电流；
- 雷达、距离传感器、温度传感器、压力传感器；
- 音频信号；
- 医疗、生物、仪器测量中的连续物理量。

数字系统擅长计算、存储、编码、压缩和算法处理，但它不能直接处理连续物理量。ADC 就是模拟世界和数字计算之间的接口。

## p.5 ADC 是模拟与数字的接口

ADC 的输入是模拟电压或电流，输出是数字码：

$$
x(t)\quad \longrightarrow \quad (b_1,b_2,\ldots,b_{n_b})
$$

其中 $n_b$ 是 bit 数，也叫分辨率。输出码可以送入：

- DSP；
- 微控制器；
- FPGA；
- 数字通信基带；
- 存储或显示系统。

这也解释了为什么前面要先讲模拟前端。ADC 前的放大器、滤波器、采样保持和参考电压都会直接影响最终数字码的质量。

## p.6-p.7 ADC 的两个离散化步骤

模拟数字转换需要两步。

第一步是时间离散化，也就是采样：

$$
x(t)\rightarrow x[k]=x(kT_e)
$$

采样频率记为：

$$
f_e=\frac{1}{T_e}
$$

英文也常写作：

$$
f_s
$$

第二步是幅值离散化，也就是量化：

$$
x[k]\rightarrow N[k]
$$

量化把连续幅值集合映射到有限个已知电平。若 ADC 有 $n_b$ bit，则理想情况下有：

$$
2^{n_b}
$$

个量化等级。

所以 ADC 的输出不是“真实值”，而是某个量化区间的代表值。

## p.8 量化例子

PPT 用一个 $1\,\mathrm{Hz}$、幅度 $1\,\mathrm{V}$ 的信号举例，采样频率为：

$$
f_e=10\,\mathrm{Hz}
$$

图中对比了不同 bit 数的量化结果。bit 数越多，量化等级越密，阶梯波越接近原始信号；bit 数越少，阶梯感越明显，误差越大。

可以把量化想成把连续数轴切成很多小区间。每个输入值落在哪个区间，就输出对应的整数码。量化误差就是真实值和代表值之间的差。

## p.9 量化定义

设 ADC 支持的输入范围从：

$$
v_{\min}
$$

到：

$$
v_{\max}
$$

满量程 pleine échelle 为：

$$
PE=v_{\max}-v_{\min}
$$

若分辨率为 $n_b$ bit，则量化步长 quantum 为：

$$
q=\frac{PE}{2^{n_b}}
$$

数字输出码 $N[k]$ 对应的估计值为：

$$
a[k]=v_{\min}+N[k]q+\frac{q}{2}
$$

其中 $\frac{q}{2}$ 表示 mid-rise 量化中每个区间的中心值。

输入和估计值之间满足：

$$
x[k]=a[k]+e[k]
$$

也就是：

$$
a[k]=x[k]-e[k]
$$

量化误差 $e[k]$ 理想情况下位于：

$$
-\frac{q}{2}\le e[k]\le \frac{q}{2}
$$

二进制输出可写成：

$$
N[k]
=b_1[k]2^{n_b-1}
+b_2[k]2^{n_b-2}
+\cdots
+b_{n_b}[k]
$$

其中 $b_1$ 是 MSB，Most Significant Bit；$b_{n_b}$ 是 LSB，Least Significant Bit。

## p.10 量化例题

PPT 给出：

$$
n_b=3
$$

$$
PE=2\,\mathrm{V}
$$

因此：

$$
q=\frac{PE}{2^{n_b}}
=\frac{2}{8}
=0.25\,\mathrm{V}
$$

输入：

$$
x[k]=-0.53\,\mathrm{V}
$$

从图上看，输入范围大致是：

$$
[-1\,\mathrm{V},1\,\mathrm{V}]
$$

所以：

$$
v_{\min}=-1\,\mathrm{V}
$$

mid-rise 量化的第 $N$ 个代表值为：

$$
a_N=-1+\left(N+\frac{1}{2}\right)q
$$

要找 $x=-0.53$ 所在区间：

$$
N=\left\lfloor\frac{x-v_{\min}}{q}\right\rfloor
$$

代入：

$$
N=\left\lfloor\frac{-0.53-(-1)}{0.25}\right\rfloor
=\left\lfloor 1.88\right\rfloor
=1
$$

所以数字码：

$$
N=1
$$

3 bit 二进制为：

$$
001
$$

估计值：

$$
a=-1+\left(1+\frac{1}{2}\right)0.25
=-0.625\,\mathrm{V}
$$

量化误差：

$$
e=x-a
=-0.53-(-0.625)
=0.095\,\mathrm{V}
$$

误差确实满足：

$$
|e|<\frac{q}{2}=0.125\,\mathrm{V}
$$

这个例题的目的不是记住某个码，而是熟悉 $q$、$N$、$a[k]$ 和 $e[k]$ 的关系。

## p.11-p.12 量化误差模型

理想量化噪声模型通常假设误差 $e$ 在区间：

$$
\left[-\frac{q}{2},\frac{q}{2}\right]
$$

上均匀分布：

$$
p(e)=\frac{1}{q}
$$

均值为：

$$
\mathbb{E}[e]=0
$$

方差为：

$$
\sigma_e^2
=\frac{1}{q}\int_{-q/2}^{q/2}e^2\,de
$$

计算：

$$
\sigma_e^2
=\frac{1}{q}
\left[
\frac{e^3}{3}
\right]_{-q/2}^{q/2}
$$

$$
\sigma_e^2
=\frac{1}{q}
\cdot
\frac{2}{3}
\left(\frac{q}{2}\right)^3
=\frac{q^2}{12}
$$

因此量化噪声功率为：

$$
P_q=\frac{q^2}{12}
$$

如果把量化噪声近似看成白噪声，并均匀分布在 Nyquist 频带：

$$
\left[-\frac{f_e}{2},\frac{f_e}{2}\right]
$$

则噪声功率谱密度近似为常数：

$$
S_e(f)=\frac{q^2}{12f_e}
$$

因为积分整个 Nyquist 带宽：

$$
\int_{-f_e/2}^{f_e/2}S_e(f)\,df
=\frac{q^2}{12}
$$

这个白噪声模型成立需要条件：输入和量化误差足够去相关，输入跨越多个量化级，没有严重周期性锁定。对小信号或确定性信号，量化误差可能出现谐波失真，而不完全像白噪声。

## p.13 SQNR：量化信噪比

SQNR 是 Signal to Quantization Noise Ratio：

$$
\mathrm{SQNR}
=\frac{\text{signal power}}{\text{quantization noise power}}
$$

若输入为正弦：

$$
x(t)=A_{\mathrm{mp}}\sin(2\pi ft)
$$

其平均功率为：

$$
P_s=\frac{A_{\mathrm{mp}}^2}{2}
$$

量化噪声功率：

$$
P_q=\frac{q^2}{12}
$$

所以：

$$
\mathrm{SQNR}
=\frac{A_{\mathrm{mp}}^2/2}{q^2/12}
=6\frac{A_{\mathrm{mp}}^2}{q^2}
$$

又因为：

$$
q=\frac{PE}{2^{n_b}}
$$

所以：

$$
\mathrm{SQNR}
=6A_{\mathrm{mp}}^2
\frac{2^{2n_b}}{PE^2}
$$

写成 PPT 的形式：

$$
\mathrm{SQNR}
=\frac{3}{2}\cdot 2^{2n_b}
\left(\frac{2A_{\mathrm{mp}}}{PE}\right)^2
$$

取 dB：

$$
\mathrm{SQNR}_{dB}
=10\log_{10}(\mathrm{SQNR})
$$

得到：

$$
\mathrm{SQNR}_{dB}
=1.76+6.02n_b
+20\log_{10}\left(\frac{2A_{\mathrm{mp}}}{PE}\right)
$$

如果正弦满量程使用，即：

$$
2A_{\mathrm{mp}}=PE
$$

则：

$$
\mathrm{SQNR}_{dB}
\approx 6.02n_b+1.76
$$

这就是理想 ADC 的经典公式：每增加 1 bit，量化 SNR 提高约 $6\,\mathrm{dB}$。

## p.14 过采样对量化噪声的影响

过采样不会改变总量化噪声功率：

$$
P_q=\frac{q^2}{12}
$$

但会把这个噪声铺到更宽的频带上。若信号只占：

$$
[-B_w,B_w]
$$

而采样频率提高到 $f_e'$，量化噪声均匀分布在：

$$
\left[-\frac{f_e'}{2},\frac{f_e'}{2}\right]
$$

那么落在信号带宽内的噪声比例降低。

定义过采样比：

$$
\mathrm{OSR}
=\frac{f_e'}{2B_w}
$$

PPT 给出一般 SQNR：

$$
\mathrm{SQNR}_{dB}
\approx
6.02n_b+1.76
+20\log_{10}\left(\frac{2A_{\mathrm{mp}}}{PE}\right)
+10\log_{10}\left(\frac{f_e}{2B_w}\right)
$$

也就是：

$$
\mathrm{SQNR}_{dB}
\approx
6.02n_b+1.76
+20\log_{10}\left(\frac{2A_{\mathrm{mp}}}{PE}\right)
+10\log_{10}(\mathrm{OSR})
$$

过采样每增加 $4$ 倍，量化噪声带内功率下降 $6\,\mathrm{dB}$，相当于约 1 bit 的 SQNR 提升：

$$
10\log_{10}(4)\approx 6.02\,\mathrm{dB}
$$

注意：这只是均匀白量化噪声 + 后续低通滤波的结果，不包含噪声整形。若是 $\Delta\Sigma$ ADC，还会通过噪声整形进一步把量化噪声推到带外，本课件这里没有展开。

## p.15 噪声预算

真实 ADC 误差不只有量化噪声。PPT 提到：

- 热噪声；
- $1/f$ 噪声，也叫 flicker noise；
- 量化噪声；
- 其他比较器、参考、电源、时钟相关噪声。

如果不同噪声源近似不相关，总噪声功率可以相加：

$$
P_{B,\mathrm{tot}}
=P_{B,\mathrm{quant}}
+P_{B,\mathrm{ther}}
+P_{B,\mathrm{flicker}}
+\cdots
$$

全局 SNR：

$$
\mathrm{SNR}_{\mathrm{glob},dB}
=10\log_{10}
\left(
\frac{P_s}
{P_{B,\mathrm{tot}}}
\right)
$$

也就是：

$$
\mathrm{SNR}_{\mathrm{glob},dB}
=10\log_{10}
\left(
\frac{P_s}
{P_{B,\mathrm{quant}}+P_{B,\mathrm{ther}}+P_{B,\mathrm{flicker}}+\cdots}
\right)
$$

设计 ADC 时要做 noise budget。不能只把量化噪声做得很低，却让热噪声或参考噪声主导；也不能为了压低每个噪声源无限增加功耗和面积。最终目标是满足规格下的最佳复杂度和功耗。

## p.16 主要 ADC 架构概览

PPT 后半部分进入架构：

- CAN à approximations successives：逐次逼近 ADC，SAR ADC；
- CAN flash；
- semi-flash；
- pipeline；
- conversion à largeur d'impulsion modulée：脉冲宽度/斜坡类转换；
- double-ramp：双斜率 ADC。

这些架构的差异，本质上是回答同一个问题：怎样最快、最省、最准地找到输入电压对应的数字码？

## p.17-p.18 SAR ADC：逐次逼近

SAR ADC 的基本结构包括：

- 采样保持；
- DAC / CNA；
- 比较器；
- SAR 逻辑；
- 参考电压 $V_{\mathrm{ref}}$。

工作过程类似二分搜索。以 $N$ bit 为例：

1. 先测试 MSB，把 DAC 输出设为半满量程。
2. 比较输入 $V_E$ 和 DAC 输出。
3. 若 $V_E$ 更大，保留该 bit；否则清零。
4. 再测试下一 bit。
5. 重复直到 LSB。

每一位需要一次比较，所以理想情况下需要约：

$$
N
$$

个比较周期。

优点：

- 性能均衡；
- 成本低；
- 功耗较低；
- 分辨率适中；
- 适合微控制器、传感器接口和中速数据采集。

缺点：

- 比 flash 慢；
- 速度受 DAC 建立时间和比较器速度限制；
- 高精度时对电容匹配、参考稳定性要求高。

## p.19-p.20 电容分压器

PPT 插入了电容分压器，因为 SAR ADC 常用电容阵列 DAC。

电容分压器中，若输入 $V_e$ 施加到串联电容网络，输出可由电荷守恒得到类似：

$$
V_s=\frac{C_1}{C_1+C_2}V_e
$$

具体分子取决于输出节点定义，但核心是：电压比例由电容比决定。

优点：

- 没有 DC 电流，功耗低；
- DC 和 AC 行为可分别控制；
- 适合集成电容阵列。

缺点：

- 对寄生电容敏感。

若输出节点存在寄生电容 $C_p$，比例会变成：

$$
V_s=
\frac{C_1}{C_1+C_2+C_p}V_e
$$

这会造成 DAC 权重误差。实际 SAR ADC 要通过版图匹配、dummy 电容、校准等方式减小影响。

## p.21-p.24 电荷重分配 SAR ADC

PPT 展示了 charge redistribution ADC。它用二进制加权电容阵列，例如：

$$
C,\quad \frac{C}{2},\quad \frac{C}{4},\quad \frac{C}{4}
$$

最后一个常作为补偿电容，让总电容匹配为便于计算的值。

### 1. 采样模式

采样时，电容阵列采样输入 $V_E$，比较器输入节点 $V_x$ 被置零：

$$
V_x=0
$$

电容上储存与输入相关的电荷。

### 2. 保持模式

保持时，输入断开，电容底板切换，使比较节点变为：

$$
V_x=-V_E
$$

这相当于把输入电压以电荷形式保存在阵列里。

### 3. 从 MSB 到 LSB 测试

然后逐次把电容接到 $V_{\mathrm{ref}}$，测试每一位。第一次测试 MSB 时：

$$
V_x=\frac{V_{\mathrm{ref}}}{2}-V_E
$$

比较器判断 $V_x$ 的符号，即判断：

$$
V_E \gtrless \frac{V_{\mathrm{ref}}}{2}
$$

后续测试继续加入更小权重，例如：

$$
\frac{V_{\mathrm{ref}}}{4},\quad
\frac{V_{\mathrm{ref}}}{8},\quad \ldots
$$

PPT 中某一步写到：

$$
V_x=\frac{V_{\mathrm{ref}}}{2}
+\frac{V_{\mathrm{ref}}}{8}
-V_E
$$

说明某些 bit 已经被保留，正在测试更低位。

转换结束时，$V_x$ 小于一个 LSB 对应误差。初始分布在所有电容上的电荷被重新分配到接 $V_{\mathrm{ref}}$ 的电容上，所以叫 redistribution de charges。

这种结构的优点是：

- 采样和 DAC 由同一电容阵列完成；
- 功耗低；
- 适合集成；
- 对某些寄生电容相对不敏感。

## p.25-p.27 Flash ADC：最快但代价高

高速 ADC 需要很高采样率，例如：

$$
100\,\mathrm{MS/s}
\sim
1\,\mathrm{GS/s}
$$

甚至更高。应用包括：

- 通信；
- 视频；
- 医学成像；
- 雷达；
- 网络分析仪。

真正一拍完成转换的架构是 flash ADC。它用一组比较器同时比较输入和多个参考阈值。

若分辨率为 $N$ bit，需要：

$$
2^N-1
$$

个比较器。

例如 3 bit flash ADC 需要 7 个阈值比较器。比较器输出 thermometer code，再通过编码器转换成二进制码。

优点：

- 极快；
- 可在一个时钟周期内完成转换；
- 适合视频、超高速采样和宽带应用。

缺点：

- 比较器数量指数增长；
- 功耗大；
- 输入电容大；
- 参考电阻串耗电；
- 比较器失调造成非线性；
- 分辨率通常较低。

PPT 提到：比较器输入电容很大，且在高频输入下会与信号源阻抗耦合，导致输入端出现较大电流，这会加重失真和驱动难度。

## p.28 Semi-flash ADC

Semi-flash 把一次高分辨率 flash 转换拆成两步。例如 10 bit 转换可以先用 5 bit flash 得到高位，再用 DAC 重构并相减，最后用另一个 5 bit flash 得到低位。

流程是：

$$
\text{coarse flash}
\rightarrow \text{DAC}
\rightarrow \text{residue}
\rightarrow \text{fine flash}
$$

优点：

- 比全 flash 面积小；
- 比较器数量显著减少；
- 输入电容降低；
- 功耗降低；
- 可达到约 10 bit 以上。

缺点：

- 需要多个阶段；
- 转换速率低于 flash；
- 需要采样保持和残差放大/校正；
- DAC 和级间误差会影响线性度。

## p.29 Pipeline ADC

Pipeline ADC 把转换分成多个级，每一级完成若干 bit 的粗量化，然后产生残差信号传给下一级。

一个典型 stage 包括：

- 采样保持；
- 小 bit 数 ADC；
- DAC；
- 减法器；
- 残差放大器。

如果每级输出 $M$ bit，多级级联后得到更高分辨率。PPT 写的是多个寄存器拼成最终数字字。

优点：

- 分辨率可达约 14 到 16 bit；
- 采样率可到数百 MS/s 甚至更高；
- 比同分辨率 flash 面积和功耗低；
- 吞吐率高，因为多个样本可以在流水线不同阶段同时处理。

缺点：

- 有 latency；
- 级间增益误差、DAC 误差和比较器失调需要校正；
- 残差放大器功耗较高；
- 设计复杂。

Pipeline 是高速中高分辨率 ADC 的经典折中。

## p.30 分辨率受元件匹配限制

PPT 强调：SAR、flash、pipeline 等很多架构的精度都会受 CMOS 标准工艺中的电容、电阻匹配限制。

典型无校准精度大约受限在：

$$
10\text{ 到 }12\,\mathrm{bit}
$$

如果有激光修调或校准，可以再提高一些。

这是因为 $N$ bit ADC 的 LSB 很小：

$$
\mathrm{LSB}=q=\frac{PE}{2^N}
$$

例如 $16$ bit 时：

$$
\frac{1}{2^{16}}\approx 15\,\mathrm{ppm}
$$

这要求参考、电容比、电阻比、比较器 offset 等都非常精确。架构理论上可行，不代表普通未校准电路能达到对应有效位数。

PPT 表格大意：

- SAR：约 10 bit、数百 MHz 量级，低成本、低功耗，但速度中等。
- Flash：约 5 到 6 bit、可达数十 GHz，非常快，但功耗大。
- Pipeline：约 14 到 16 bit、约 GHz 量级，分辨率和速度折中，但功耗不低。

这些数字是量级直觉，不是所有产品的固定上限。

## p.31-p.32 斜坡 / PWM 类转换

Ramp 或 PWM 类转换利用积分器的线性斜坡，把电压幅度转换成时间宽度。

基本思想是：产生一个斜坡：

$$
V_{\mathrm{ramp}}(t)
$$

让它从初始值开始线性变化。当斜坡达到输入电压 $V_E$ 时，比较器翻转。计数器记录所经过的时钟周期数：

$$
M
$$

因为斜坡与时间线性相关，所以：

$$
V_E\propto M
$$

优点：

- 线性度可以很高；
- 结构简单；
- 分辨率可以高，比如 18 bit 量级。

缺点：

- 转换时间很长；
- 高分辨率需要大量时钟周期；
- 依赖积分器 $R,C$ 的线性与稳定性；
- 不适合高速信号。

PPT 举例：若分辨率为 $16$ bit，需要：

$$
2^{16}=65536
$$

个时钟周期。对音频立体声 $44\,\mathrm{kHz}$ 这类速度，如果直接用单斜率方式，会要求很高时钟频率，变得不划算。

## p.33 双斜率 ADC

Double-ramp ADC 常用于高精度低速仪表。它的核心思想是分两段积分。

第一段，在固定时间内积分输入 $-V_E$。设固定积分时间为：

$$
T_1=N_1T_H
$$

其中 $T_H$ 是时钟周期。积分器输出变化量：

$$
\Delta V_1=-\frac{V_E}{RC}T_1
$$

第二段，切换到参考电压 $V_{\mathrm{ref}}$ 反向积分，直到积分器输出回到阈值。设这段时间：

$$
T_2=N_2T_H
$$

则：

$$
\Delta V_2=\frac{V_{\mathrm{ref}}}{RC}T_2
$$

回到起点条件：

$$
\left|\Delta V_1\right|=\left|\Delta V_2\right|
$$

所以：

$$
\frac{V_E}{RC}T_1
=
\frac{V_{\mathrm{ref}}}{RC}T_2
$$

$RC$ 消掉：

$$
\frac{T_2}{T_1}
=
\frac{V_E}{V_{\mathrm{ref}}}
$$

用计数表示：

$$
\frac{N_2}{N_1}
=
\frac{V_E}{V_{\mathrm{ref}}}
$$

因此：

$$
N_2
=N_1\frac{V_E}{V_{\mathrm{ref}}}
$$

输出数字码由第二段计数 $N_2$ 给出。

双斜率的优点：

- 对 $RC$ 绝对值不敏感，因为 $RC$ 在两段积分中抵消；
- 对比较器 offset 不敏感；
- 第一段积分本身对输入做低通平均，抗噪声能力好；
- 分辨率高，适合仪表。

缺点：

- 速度很慢；
- 不适合宽带高速采样。

这就是很多数字万用表使用双斜率或类似积分型 ADC 的原因。

## p.34 架构总结

PPT 的最后总结可以用一张权衡表理解：

| 架构 | 典型优势 | 典型劣势 | 适合场景 |
|---|---|---|---|
| SAR | 成本低、功耗低、速度和分辨率均衡 | 比 flash 慢，高精度受 DAC 匹配限制 | 微控制器、传感器、中速采集 |
| Flash | 速度最快 | 比较器数量多、功耗高、分辨率低 | 视频、超高速、宽带采样 |
| Pipeline | 高速 + 中高分辨率 | 功耗和复杂度较高，有延迟 | 通信、成像、高速数据采集 |
| Ramp / PWM | 结构简单、线性度高 | 很慢，依赖时间测量 | 低速高分辨率 |
| Double-ramp | 高精度、抗噪声、对 $RC$ 不敏感 | 非常慢 | 仪器仪表、低频测量 |

可以把架构选择看成一个多目标优化：

$$
\text{速度}
\leftrightarrow
\text{分辨率}
\leftrightarrow
\text{功耗}
\leftrightarrow
\text{面积}
\leftrightarrow
\text{线性度}
$$

没有单一 ADC 架构在所有指标上最好。

## 本讲总结

ADC 做两件事：

$$
\text{时间采样}
\quad\text{和}\quad
\text{幅值量化}
$$

量化步长为：

$$
q=\frac{PE}{2^{n_b}}
$$

量化误差理想范围：

$$
-\frac{q}{2}\le e[k]\le \frac{q}{2}
$$

理想均匀量化噪声功率：

$$
P_q=\frac{q^2}{12}
$$

满量程正弦输入的理想量化信噪比：

$$
\mathrm{SQNR}_{dB}\approx 6.02n_b+1.76
$$

若考虑过采样：

$$
\mathrm{SQNR}_{dB}
\approx
6.02n_b+1.76
+20\log_{10}\left(\frac{2A_{\mathrm{mp}}}{PE}\right)
+10\log_{10}\left(\frac{f_e}{2B_w}\right)
$$

真实 ADC 还要做总噪声预算：

$$
\mathrm{SNR}_{\mathrm{glob},dB}
=10\log_{10}
\left(
\frac{P_s}
{P_{B,\mathrm{quant}}+P_{B,\mathrm{ther}}+P_{B,\mathrm{flicker}}+\cdots}
\right)
$$

架构上：

- SAR 是均衡型；
- Flash 是速度型；
- Pipeline 是高速中高分辨率折中；
- Ramp / PWM 和 double-ramp 是高精度低速型。

这门高等电子学主线到 ADC 这里闭环：

$$
\text{连续模拟信号}
\rightarrow \text{采样理论}
\rightarrow \text{放大}
\rightarrow \text{反馈}
\rightarrow \text{开关电容}
\rightarrow \text{模拟滤波}
\rightarrow \text{量化为数字码}
$$

所以最后回到一句话：模拟前端的目标不是简单“把电压变成数字”，而是在噪声、失真、带宽、稳定性、混叠和量化误差之间，设计一条足够可靠的信号通路。
