# 06 Filtrage analogique 讲义

来源：[[ppt/ELEC101_filtrage 2026.pdf|ELEC101_filtrage 2026.pdf]]

这一讲讲模拟滤波。到这里，采集链路已经基本拼起来了：前面讲了采样、放大器、反馈和开关电容；现在要回答一个非常实际的问题：**在信号进入 ADC 之前，怎样限制频谱、选择有用频段，并用有限阶电路实现一个满足规格的滤波器？**

这一讲的主线是：

$$
\text{为什么要滤波}
\rightarrow \text{传递函数与约束}
\rightarrow \text{gabarit / 滤波器模板}
\rightarrow \text{标准逼近}
\rightarrow \text{低通原型与频率变换}
\rightarrow \text{LC / 主动 RC / 开关电容实现}
$$

要特别注意：真实滤波器不是“画一条理想频响曲线”就结束了。理想低通在数学上往往不可因果、不可稳定或需要无限阶实现；工程设计必须用有限阶有理函数去逼近理想需求。

## p.1-p.3 这一讲的位置和目标

PPT 标题是 Filtrage analogique，也就是模拟滤波。它位于 acquisition chain 中的滤波环节：

$$
\text{Entrée analogique}
\rightarrow \text{TL/TZ}
\rightarrow \text{Amplificateur}
\rightarrow \text{Filtre}
\rightarrow \text{CAN}
\rightarrow \text{Sortie numérique}
$$

本讲目标有两个：

1. 从规格估计滤波器复杂度，也就是大概需要几阶。
2. 认识常见滤波类型、标准逼近方式和实现技术的限制。

PPT 的结构是：

1. Introduction, applications：抗混叠、选频等应用。
2. Spécifications des filtres：传递函数、衰减模板、群延迟模板。
3. Approximations standards：Butterworth、Tchebycheff、Elliptique 等标准逼近。
4. Types de filtres：LC、主动 RC、开关电容、级联结构。

## p.4 采样前必须限制频谱

采样会让频谱周期复制。若连续信号为 $x(t)$，采样周期为 $T_s$，采样频率为：

$$
F_s=\frac{1}{T_s}
$$

采样信号可写成：

$$
x_d(t)=x(t)\sum_{k\in\mathbb{Z}}\delta(t-kT_s)
$$

频域中变成频谱复制：

$$
X_d(f)=F_s\sum_{k\in\mathbb{Z}}X(f-kF_s)
$$

如果原信号带宽为 $B$，要避免复制后的频谱互相重叠，需要满足 Nyquist-Shannon 条件：

$$
F_s>2B
$$

但真实输入信号往往不天然带限。即使有用信号在 $B$ 内，外界噪声、干扰、传感器寄生响应都可能在高频存在分量。采样后，这些高频分量会折叠到低频，形成 aliasing：

$$
f_{\mathrm{alias}}=\left|f-kF_s\right|
$$

一旦混叠发生，数字域里无法知道低频成分到底来自原始低频信号，还是来自高频折叠。因此 ADC 前通常需要抗混叠滤波器：

$$
\text{filtre anti-repliement}
$$

它的任务是：在采样之前，把 Nyquist 范围外的频率尽量压低。

## p.5 选频：无线接收中的滤波

滤波不只用于抗混叠，也用于选择频段。PPT 用无线接收机举例：天线收到的是宽频谱信号，其中包含多个频道、邻道干扰和噪声。接收链路通常有：

$$
\text{Antenne}
\rightarrow \text{LNA}
\rightarrow \text{RF filter}
\rightarrow \text{Mixer}
\rightarrow \text{IF/BB filter}
\rightarrow \text{ADC}
$$

其中：

- RF 滤波器用于抑制带外强干扰；
- IF 或 BB 滤波器用于选择目标信道；
- ADC 前滤波器还要防止混叠。

所以模拟滤波经常分布在多个位置，不是只在 ADC 前放一个滤波器。每一级承担的任务不同：前级滤波要抗强干扰、低噪声；后级滤波更接近信道选择和抗混叠。

## p.6-p.7 传递函数：滤波器的数学对象

线性时不变滤波器由冲激响应 $h(t)$ 描述：

$$
y(t)=h(t)*x(t)
$$

取 Laplace 变换：

$$
Y(p)=T(p)X(p)
$$

所以传递函数为：

$$
T(p)=\frac{Y(p)}{X(p)}
$$

对集中参数电路，也就是由有限个 $R$、$L$、$C$、受控源等构成的电路，传递函数通常是有理函数：

$$
T(p)=
\frac{\prod_{j=1}^{m}(p-z_j)}
{\prod_{i=1}^{n}(p-p_i)}
$$

其中：

- $z_j$ 是零点；
- $p_i$ 是极点；
- $n$ 是滤波器阶数。

滤波器阶数大致等于系统中独立储能元件的数量。阶数越高，幅频响应可以越陡，过渡带可以越窄，但实现更复杂、更敏感、更耗面积和功耗。

## p.8 瞬态响应与谐波响应

考虑输入为单频正弦或复指数：

$$
x(t)=e^{j\omega t}u(t)
$$

其中 $u(t)$ 是单位阶跃。Laplace 变换为：

$$
X(p)=\frac{1}{p-j\omega}
$$

输出：

$$
Y(p)=T(p)X(p)
$$

如果：

$$
T(p)=\frac{N(p)}{\prod_{i=1}^{n}(p-p_i)}
$$

则：

$$
Y(p)=
\frac{N(p)}
{\prod_{i=1}^{n}(p-p_i)}
\cdot
\frac{1}{p-j\omega}
$$

部分分式展开后：

$$
Y(p)=\sum_{i=1}^{n}\frac{C_i}{p-p_i}
+\frac{C_{n+1}}{p-j\omega}
$$

其中：

$$
C_{n+1}=T(j\omega)
$$

回到时域：

$$
y(t)=\sum_{i=1}^{n}C_ie^{p_it}
+T(j\omega)e^{j\omega t}
$$

这条公式非常重要。它说明输出由两部分组成：

1. 瞬态项：

$$
\sum_{i=1}^{n}C_ie^{p_it}
$$

2. 稳态谐波项：

$$
T(j\omega)e^{j\omega t}
$$

如果滤波器稳定，极点实部为负，瞬态项会衰减；最后只剩由 $T(j\omega)$ 决定的稳态响应。因此频率响应就是：

$$
T(j\omega)=T(p)\vert_{p=j\omega}
$$

## p.9 理想低通不可直接实现

PPT 给出理想低通：

$$
T(f)=e^{-j2\pi ft_0}\mathbf{1}_{[-f_c,f_c]}(f)
$$

它的幅度响应是矩形：

$$
|T(f)|=
\begin{cases}
1, & |f|\le f_c \\
0, & |f|>f_c
\end{cases}
$$

相位是线性相位：

$$
\arg T(f)=-2\pi ft_0
$$

对应冲激响应：

$$
h(t)=\int_{-\infty}^{+\infty}T(f)e^{j2\pi ft}\,df
$$

代入矩形频响：

$$
h(t)=2f_c\,\mathrm{sinc}\left(2\pi f_c(t-t_0)\right)
$$

这个冲激响应是无限长的 sinc，而且在 $t<t_0$ 之前也有非零值。若没有足够延迟，它甚至是非因果的。即使加上延迟，也需要无限时间支持，无法用有限阶模拟电路精确实现。

所以工程滤波的任务不是实现理想低通，而是用可实现的有理函数近似它。

## p.10 传递函数的稳定性与因果性约束

对有理传递函数：

$$
T(p)=
\frac{\prod_{j=1}^{m}(p-z_j)}
{\prod_{i=1}^{n}(p-p_i)}
$$

首先要满足因果可实现性。严格真有理系统通常要求：

$$
m<n
$$

或至少：

$$
m\le n
$$

否则高频增益会不受控，不能由有限带宽物理系统实现。

其次要稳定。连续时间稳定要求所有极点位于左半平面：

$$
\operatorname{Re}(p_i)<0
$$

PPT 还提到 Paley-Wiener 条件：一个因果滤波器的幅频响应不能在某个有限频带上严格为零。直观说，如果你要求滤波器在某个频带完全消失，同时又因果、稳定，就会违反物理可实现性。

这再次说明：理想 brick-wall 滤波器只能作为目标，不能作为有限阶真实电路。

## p.11 衰减模板 gabarit d'affaiblissement

滤波器规格通常不用 $|T(j\omega)|$ 直接表达，而用衰减：

$$
A(\omega)=-20\log_{10}|T(j\omega)|
$$

若：

$$
|T(j\omega)|=1
$$

则：

$$
A(\omega)=0\,\mathrm{dB}
$$

若：

$$
|T(j\omega)|=0.1
$$

则：

$$
A(\omega)=20\,\mathrm{dB}
$$

滤波器模板 gabarit 通常规定：

- 通带最大衰减 $A_{\max}$；
- 阻带最小衰减 $A_{\min}$；
- 通带边缘频率；
- 阻带边缘频率；
- 过渡带宽度。

对低通例子，常见规格是：

$$
A(\omega)\le A_{\max},\quad 0\le \omega\le \omega_p
$$

$$
A(\omega)\ge A_{\min},\quad \omega\ge \omega_s
$$

其中 $\omega_p$ 是通带边缘，$\omega_s$ 是阻带边缘。过渡带越窄、阻带衰减越大，所需阶数越高。

对实系数集中参数滤波器，有反射性质：

$$
T(\overline{p})=\overline{T(p)}
$$

并且：

$$
|T(j\omega)|^2
=\left[T(p)T(-p)\right]_{p=j\omega}
$$

这在从幅度平方构造稳定左半平面极点时很有用。

## p.12 群延迟模板

幅度不是滤波器唯一指标，相位也很重要。相位通常是非线性的，直接看：

$$
\arg T(j\omega)
$$

不太方便，所以引入群延迟：

$$
t_g(\omega)=
-\frac{\partial \arg T(j\omega)}{\partial \omega}
$$

如果相位近似线性：

$$
\arg T(j\omega)\approx -\omega t_0+\phi_0
$$

则：

$$
t_g(\omega)\approx t_0
$$

这表示不同频率分量经历相同延迟，波形不容易被相位失真拉坏。

如果群延迟随频率变化很大，那么一个宽带信号的不同频率分量会到达时间不同，导致波形畸变。对通信信号、脉冲信号和音频系统，群延迟往往和幅度指标一样重要。

## p.13-p.14 标准逼近与低通原型

标准滤波器设计通常先构造一个归一化低通原型 prototype。归一化意味着：

- 通带边缘归一化为：

$$
\Omega=1
$$

- 幅度按指定纹波归一化；
- 先在原型域 $S$ 中设计，再通过频率变换得到低通、高通、带通或带阻。

PPT 用归一化复变量：

$$
S=\Sigma+j\Omega
$$

标准原型的幅度平方写成：

$$
|T(\Omega)|^2
=
\frac{1}{1+\varepsilon^2\psi_n^2(\Omega)}
$$

对应衰减：

$$
A(\Omega)
=10\log_{10}\left(1+\varepsilon^2\psi_n^2(\Omega)\right)
$$

其中：

- $\psi_n(\Omega)$ 是特征函数；
- $n$ 是阶数；
- $\varepsilon$ 控制通带纹波或通带最大衰减。

逼近问题就是：选一个 $\psi_n(\Omega)$，让它满足给定 gabarit，同时阶数尽量低、相位和实现难度可接受。

## p.15 原型规格与阶数条件

低通原型的通带是：

$$
0\le \Omega\le 1
$$

阻带从：

$$
\Omega_s>1
$$

开始。

通带最大衰减为：

$$
A_{\max}
$$

阻带最小衰减为：

$$
A_{\min}
$$

在通带边缘：

$$
\psi_n(1)=1
$$

所以：

$$
A_{\max}
=10\log_{10}(1+\varepsilon^2)
$$

从这个式子可以得到：

$$
\varepsilon
=\sqrt{10^{A_{\max}/10}-1}
$$

在阻带边缘 $\Omega_s$ 处，需要：

$$
A(\Omega_s)\ge A_{\min}
$$

也就是：

$$
10\log_{10}\left(1+\varepsilon^2\psi_n^2(\Omega_s)\right)
\ge A_{\min}
$$

等价于：

$$
\psi_n(\Omega_s)
\ge
D
$$

其中：

$$
D=
\sqrt{
\frac{10^{A_{\min}/10}-1}
{10^{A_{\max}/10}-1}
}
$$

这个 $D$ 是规格对特征函数提出的最低要求。过渡带越窄、$A_{\min}$ 越大、$A_{\max}$ 越小，$D$ 越难满足，阶数就越高。

## p.16-p.17 常见标准逼近

PPT 把标准逼近分成多项式和有理函数两类。

### Butterworth

Butterworth 的特征函数是：

$$
\psi_n(\Omega)=\Omega^n
$$

它的特点是通带最大平坦，低频附近没有纹波：

$$
|T(\Omega)|^2
=
\frac{1}{1+\varepsilon^2\Omega^{2n}}
$$

优点是幅度响应平滑，缺点是过渡带滚降相对慢，因此同样规格下阶数可能较高。

### Tchebycheff

Tchebycheff 通带纹波型使用 Chebyshev 多项式：

$$
\psi_n(\Omega)=T_n(\Omega)
$$

它允许通带内等波纹，以换取更快的过渡带滚降。同样阻带衰减和过渡带宽度下，阶数通常低于 Butterworth。

### Elliptique / Cauer

Elliptic 滤波器的特征函数是有理函数。它在通带和阻带都允许纹波，因此过渡带最陡，同样规格下阶数往往最低。

代价是：

- 相位和群延迟更差；
- 对元件误差更敏感；
- 实现和调试更复杂。

所以三者的直觉排序是：

$$
\text{Butterworth：最平滑，阶数较高}
$$

$$
\text{Tchebycheff：通带有纹波，滚降更快}
$$

$$
\text{Elliptic：通带/阻带都有纹波，阶数最低但最激进}
$$

## p.18 低通原型到其他滤波器的频率变换

标准表格通常给的是低通原型：

$$
T_{\mathrm{LP}}(S)
$$

要得到高通、带通、带阻，需要把原型变量 $S$ 替换成目标变量 $p$ 的函数：

$$
S=f(p)
$$

### 低通到高通

高通变换常写成：

$$
S=\frac{\omega_p}{p}
$$

或归一化后：

$$
S=\frac{1}{p}
$$

它会把低通原型中的低频和高频互换。原型低频通过，对应目标高频通过。

### 低通到带通

带通中心频率为：

$$
\omega_0=\sqrt{\omega_1\omega_2}
$$

带宽：

$$
B=\omega_2-\omega_1
$$

常用变换：

$$
S=\frac{\omega_0}{B}
\left(
\frac{p}{\omega_0}
+\frac{\omega_0}{p}
\right)
$$

带通会把一个低通极点变成一对带通极点，所以阶数通常翻倍。

### 低通到带阻

带阻变换与带通互为倒数形式，常写成：

$$
S=
\frac{B}{\omega_0}
\left(
\frac{p}{\omega_0}
+\frac{\omega_0}{p}
\right)^{-1}
$$

PPT 还给出几何对称条件：

$$
\omega_1\omega_4=\omega_2\omega_3=\omega_0^2
$$

这表示带通/带阻模板在对数频率轴上关于中心频率 $\omega_0$ 对称。

## p.19 标准逼近设计流程

PPT 给出构造滤波器的步骤，可以整理成：

1. 明确应用需求：到底要保留什么、抑制什么。
2. 画目标滤波器的 gabarit，确定 $A_{\min}$、$A_{\max}$ 和边缘频率。
3. 把目标 gabarit 变换成低通原型 gabarit，得到 $\Omega_s$。
4. 选择逼近类型，比如 Butterworth、Tchebycheff 或 Elliptic。
5. 用阶数条件求最小 $n$：

$$
\psi_n(\Omega_s)\ge D
$$

其中：

$$
D=
\sqrt{
\frac{10^{A_{\min}/10}-1}
{10^{A_{\max}/10}-1}
}
$$

6. 查表或计算该阶数、该逼近的原型传递函数。
7. 选择或调整 $\varepsilon$，使通带衰减满足规格：

$$
\varepsilon
=\sqrt{10^{A_{\max}/10}-1}
$$

8. 应用频率变换，把低通原型变成目标低通、高通、带通或带阻。
9. 选择实现技术：LC、主动 RC、开关电容、级联二阶节等。

这套流程的价值在于：不要一上来就画电路，而是先从规格决定阶数和原型。

## p.20-p.22 例子：超声传感器的高通滤波

PPT 给了一个小故事：Lara 用超声传感器测距，但测量受可听频率干扰。Fabian 分析后认为，误差主要来自：

$$
f<20\,\mathrm{kHz}
$$

而有用超声信号在：

$$
f>50\,\mathrm{kHz}
$$

所以选择高通滤波器。

规格为：

- 通带：$f>50\,\mathrm{kHz}$；
- 通带最大衰减：

$$
A_{\max}=2\,\mathrm{dB}
$$

- 阻带：$f<20\,\mathrm{kHz}$；
- 阻带最小衰减：

$$
A_{\min}=10\,\mathrm{dB}
$$

高通转低通原型时，阻带归一化频率为：

$$
\Omega_s=\frac{50}{20}=2.5
$$

选择 Butterworth：

$$
\psi_n(\Omega)=\Omega^n
$$

先计算：

$$
D=
\sqrt{
\frac{10^{A_{\min}/10}-1}
{10^{A_{\max}/10}-1}
}
$$

代入：

$$
A_{\min}=10\,\mathrm{dB}
$$

$$
A_{\max}=2\,\mathrm{dB}
$$

得到：

$$
D=
\sqrt{
\frac{10^{1}-1}
{10^{0.2}-1}
}
\approx 3.92
$$

Butterworth 条件为：

$$
\Omega_s^n\ge D
$$

因此：

$$
n\ge \frac{\log D}{\log \Omega_s}
$$

代入：

$$
n\ge \frac{\log(3.92)}{\log(2.5)}
\approx 1.49
$$

阶数必须是整数，所以：

$$
n=2
$$

这个例子展示了如何从一句工程需求“滤掉 $20\,\mathrm{kHz}$ 以下，可用频段从 $50\,\mathrm{kHz}$ 开始”变成一个二阶高通滤波器设计任务。

## p.23 方法回顾

PPT 再次列出设计方法，是为了强调：阶数计算只是流程中的一步。完整设计还需要：

- 从应用确定规格；
- 选择逼近；
- 确定阶数；
- 选择 $\varepsilon$；
- 做频率变换；
- 选择电路实现；
- 检查元件误差、噪声、失真、功耗和面积。

尤其是模拟滤波器，理论传递函数满足规格不代表真实电路也满足。真实运放带宽、元件误差、寄生和温度漂移都会改变响应。

## p.24-p.26 滤波器实现技术分类

选择滤波器技术时，PPT 列出一些评价标准：

- 对元件变化和温度变化是否敏感；
- 失真和噪声是否低；
- 面积、功耗、成本是否可接受；
- 选择性是否高；
- 是否容易校准；
- 是否适合集成。

常见技术包括：

- LC 滤波器；
- 主动 RC 滤波器；
- 开关电容滤波器；
- 由一阶/二阶节级联构成的高阶滤波器；
- 在某些场景中也会使用 Gm-C、数字滤波等混合方案。

本课重点比较 LC、主动 RC 和开关电容。

## p.27-p.28 LC 滤波器

理想 LC 滤波器由电感和电容构成，理论上无损、低噪声，适合高频和射频前端。

PPT 从功率角度描述了二端口：

- 输入可用功率：

$$
P_i=\frac{E^2}{4R_1}
$$

- 输出功率：

$$
P_u=\frac{V_2^2}{R_2}
$$

- 反射功率：

$$
P_r=P_i-P_u
$$

传输系数和反射系数可写为：

$$
|t|^2=\frac{P_u}{P_i}
$$

$$
|r|^2=\frac{P_r}{P_i}
$$

PPT 还定义：

$$
|K|^2=\frac{P_r}{P_u}
$$

于是：

$$
|t|^2
=\frac{P_u}{P_u+P_r}
=\frac{1}{1+|K|^2}
$$

这和标准逼近中的特征函数形式很像：

$$
|T(\Omega)|^2
=\frac{1}{1+\varepsilon^2\psi_n^2(\Omega)}
$$

LC 原型低通可以直接由查表公式得到元件值。PPT 给了 Butterworth、$A_{\max}=3\,\mathrm{dB}$ 的五阶低通原型。典型结构是电感串联、电容并联交替出现。

LC 的优点：

- 低噪声；
- 高频性能好；
- 无需运放；
- 可用于射频。

缺点：

- 片上电感面积大、品质因数有限；
- 低频大电感/大电容不适合集成；
- 调谐和工艺偏差仍需处理。

## p.29 主动 RC 滤波器

主动 RC 用运放、电阻、电容实现滤波器。PPT 给的是 Sallen-Key 二阶低通单元：

$$
T(p)=
\frac{\omega_0^2}
{p^2+\frac{\omega_0}{Q_0}p+\omega_0^2}
$$

其中：

$$
\omega_0=\frac{1}{R\sqrt{C_1C_2}}
$$

PPT 给出的品质因数形式为：

$$
Q_0=\frac{1}{2}\sqrt{\frac{C_1}{C_2}}
$$

具体表达会随 Sallen-Key 电路连接和增益配置不同而变化，但核心都是：二阶节由一个自然频率 $\omega_0$ 和品质因数 $Q_0$ 描述。

主动 RC 的优点：

- 不需要电感；
- 适合中低频；
- 设计直观；
- 可以级联二阶节实现高阶滤波器。

但性能受运放限制。PPT 指出：即使理论上是 Butterworth、截止频率 $10\,\mathrm{kHz}$ 的滤波器，真实运放在高频处有限增益和有限带宽会导致响应在更高频严重劣化。

也就是说，主动 RC 设计不能只看理想 $R$、$C$；还要检查运放：

- 增益带宽积；
- 相位裕度；
- 输出摆幅；
- 噪声；
- 失真；
- slew rate。

## p.30 开关电容滤波器

开关电容滤波器用电容比和时钟频率决定极点零点。PPT 给出一个二阶低通单元的 $z$ 域形式：

$$
T(z)=
-\frac{C_1C_3}{C_AC_B}
\cdot
\frac{
z\left(\frac{C_4}{C_B}+1\right)
}{
z^2+
\left(
\frac{C_2C_3}{C_AC_B}
-\frac{C_4}{C_B}
-2
\right)z
+1
}
$$

这个式子看起来复杂，但结构上很清楚：它是二阶离散时间滤波器：

$$
T(z)=\frac{N(z)}{D(z)}
$$

系数由电容比决定。相比主动 RC，它的优势是：

$$
\text{频率精度}
\approx
\text{电容比精度 + 时钟精度}
$$

而不是绝对 $R$、$C$ 精度。

缺点也来自离散时间工作方式：

- 需要时钟；
- 有开关注入和时钟馈通；
- 对运放建立时间要求高；
- 可能产生混叠；
- 高频信号需要先被连续时间滤波限制。

## p.31 级联结构

高阶滤波器通常不直接实现一个大阶数传递函数，而是拆成一阶和二阶小节级联：

$$
T(p)=T_1(p)T_2(p)\cdots T_m(p)
$$

或者：

$$
T_i(p)=k_i\frac{N_i(p)}{D_i(p)}
$$

这种 cascade structure 的特点是：

1. 每个 cell 实现一阶或二阶滤波。
2. 假设各级之间相互作用可以忽略，通常需要缓冲或阻抗隔离。
3. 总滤波器需要决定：
   - 分母 $D_i$ 的分配顺序；
   - 分子 $N_i$ 的分配顺序；
   - 各级增益 $k_i$ 的分配。

级联顺序不是无关紧要。高 $Q$ 二阶节可能产生很大的内部峰值，如果放在前级，可能导致饱和或失真。因此工程设计会考虑动态范围、噪声贡献和实现敏感度来排序。

## p.32 练习 1：群延迟与包络延迟

题目给定一个窄带信号：

$$
x(t)=a(t)e^{j\omega_0t}
$$

滤波器是以 $\omega_0$ 为中心的带通滤波器。假设在 $\omega_0$ 附近幅度近似常数：

$$
|T(j\omega)|\approx T_0
$$

相位在 $\omega_0$ 附近做一阶展开：

$$
\phi(\omega)
\approx
\phi_0
+(\omega-\omega_0)
\left.\frac{\partial \phi}{\partial \omega}\right|_{\omega_0}
$$

群延迟定义：

$$
t_g(\omega_0)
=
-\left.\frac{\partial \phi}{\partial \omega}\right|_{\omega_0}
$$

因此：

$$
\phi(\omega)
\approx
\phi_0-(\omega-\omega_0)t_g
$$

对窄带包络来说，滤波器输出近似为：

$$
s(t)
\approx
T_0e^{j\phi_0}a(t-t_g)e^{j\omega_0t}
$$

也就是说，载波附近的包络 $a(t)$ 被延迟了：

$$
t_g
$$

这就是群延迟名字的来源：它描述的是一组相邻频率成分，也就是信号包络的传播延迟。

## p.33 练习 2：ZigBee 接收机滤波

练习 2 是 ZigBee 接收机的滤波设计题。题目要求：

1. 判断 channel 1 和 channel 2 哪个更难滤。
2. 确定几何对称的带通滤波器 gabarit。
3. 把带通 gabarit 变换为低通原型，得到 $\Omega_s$。
4. 计算原型阶数。
5. 提出滤波器实现。

这类题的解法不是先套公式，而是先画频谱：

- 有用信号中心频率和带宽；
- 邻道位置；
- ADC/DSP 前需要保留的频段；
- 需要抑制的邻道或镜像频段。

若要做带通到低通原型变换，需要先确定：

$$
\omega_0=\sqrt{\omega_1\omega_2}
$$

和：

$$
B=\omega_2-\omega_1
$$

然后对阻带边缘 $\omega_s$ 计算等效低通频率：

$$
\Omega_s=
\left|
\frac{\omega_s^2-\omega_0^2}
{B\omega_s}
\right|
$$

取最小的 $\Omega_s$ 作为最严格阻带规格，再用：

$$
\psi_n(\Omega_s)\ge D
$$

求阶数。

判断哪个 channel 更难滤，通常看邻道或干扰距离有用带宽边缘有多近。距离越近，过渡带越窄，所需阶数越高，也就越严格。

## 本讲总结

模拟滤波器的设计可以用一条清晰流程概括：

$$
\text{应用需求}
\rightarrow \text{gabarit}
\rightarrow \text{低通原型}
\rightarrow \text{标准逼近}
\rightarrow \text{阶数}
\rightarrow \text{频率变换}
\rightarrow \text{电路实现}
$$

滤波器传递函数是：

$$
T(p)=\frac{Y(p)}{X(p)}
$$

对有理滤波器：

$$
T(p)=
\frac{\prod_j(p-z_j)}
{\prod_i(p-p_i)}
$$

稳定性要求：

$$
\operatorname{Re}(p_i)<0
$$

幅度规格常用衰减表示：

$$
A(\omega)=-20\log_{10}|T(j\omega)|
$$

相位规格常用群延迟表示：

$$
t_g(\omega)=
-\frac{\partial \arg T(j\omega)}{\partial \omega}
$$

标准低通原型的幅度平方是：

$$
|T(\Omega)|^2
=
\frac{1}{1+\varepsilon^2\psi_n^2(\Omega)}
$$

阶数条件来自：

$$
\psi_n(\Omega_s)\ge
\sqrt{
\frac{10^{A_{\min}/10}-1}
{10^{A_{\max}/10}-1}
}
$$

Butterworth、Tchebycheff、Elliptic 是三种典型权衡：

$$
\text{平滑}
\leftrightarrow
\text{滚降速度}
\leftrightarrow
\text{阶数和实现难度}
$$

实现上：

- LC 适合低噪声高频，但片上电感困难；
- 主动 RC 适合中低频，但受运放和绝对 $R,C$ 影响；
- 开关电容适合集成和精确频率控制，但需要时钟、快速运放，并且本质上是采样系统。

这讲和 ADC 的关系非常直接：滤波器负责在采样和量化之前控制频谱。没有合适的模拟滤波，后面的数字处理再强，也无法消除已经混叠进来的错误频率成分。
