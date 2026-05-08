---
created: 2026-05-02
type: note
status: 在用
tags:
  - RoPE
  - KVCache
  - PositionalEncoding
  - VideoDiffusion
  - Streaming
summary: 总结 CausVid、Self Forcing、Rolling Forcing 的问题递进，以及 RoPE 如何编码到 K 中、三维 RoPE 与视频 KV cache 的数学关系
---

# RoPE、KV Cache与视频流式生成中的位置编码

## 1. 先看方法谱系：Rolling Forcing 比 Self Forcing、CausVid 多解决了什么

这三篇论文解决的不是同一个层面的问题，而是逐层推进。

### 1.1 CausVid 先解决“能不能把双向视频扩散改成流式 AR 系统”
`CausVid` 的核心贡献是：
- 把原本必须访问未来帧的双向视频扩散，改造成因果结构；
- 再把 many-step 教师蒸馏成 few-step 学生；
- 配合 `KV cache` 实现低延迟流式推理。

所以 `CausVid` 先解决的是“系统形态”问题：高质量视频扩散能不能进入 autoregressive / streaming 范式。

但它仍然留下几个问题：
- 训练分布和真实自回归推理分布没有完全对齐；
- 历史依赖主要靠滑动窗口，远历史会被截断；
- 长时间 rollout 时误差仍会累积。

### 1.2 Self Forcing 再解决“train-test gap / exposure bias”
`Self Forcing` 指出：`CausVid` 这类方法虽然已经是 AR diffusion，但训练时仍大量看真值上下文，推理时却只能看模型自己生成的上下文，这就是典型的曝光偏差。

它的关键改进是：训练时就做真实 self-rollout。也就是说，第 $i$ 帧在训练时就条件化于模型自己已经生成的 $x_\theta^{<i}$，而不是条件化于真值历史。

因此 `Self Forcing` 主要修的是：
$$
\text{训练分布} \neq \text{推理分布}
$$

但它的推理单元本身仍然是“逐帧定稿”的 strict causal rollout。也就是说：
- 它修正了训练方式；
- 但没有从根本上改掉“当前帧一旦出错，就会立刻写入未来历史”的推理动力学。

### 1.3 Rolling Forcing 再解决“逐帧推理单元本身太脆弱”
`Rolling Forcing` 的核心判断是：即便训练分布已经更贴近推理分布，如果推理时还是严格逐帧去噪，那么早期局部错误仍然会被立刻固化并一路传播。

它做了三件事：
- 用 `rolling-window joint denoising` 代替逐帧独立去噪，让邻近帧在局部窗口中先互相纠错；
- 用 `attention sink + dynamic RoPE` 维持长期全局锚点，减轻世界观漂移；
- 用扩展窗口蒸馏把训练也适配到这种 rolling 推理范式。

所以可以把这三者概括成：

$$
\text{CausVid}: \text{先让流式 AR video diffusion 成立}
$$

$$
\text{Self Forcing}: \text{再让训练分布对齐推理分布}
$$

$$
\text{Rolling Forcing}: \text{再让推理单元本身更不容易滚坏}
$$

## 2. RoPE 是什么

`RoPE`（Rotary Positional Embedding）不是把一个位置向量直接加到 token 上，而是对每个 head 的 $Q$ 和 $K$ 做位置相关的旋转。

设第 $n$ 个 token 的输入表示为 $x_n$，线性投影得到：

$$
q_n = W_Q x_n,\qquad
k_n = W_K x_n,\qquad
v_n = W_V x_n
$$

RoPE 不直接作用在 $v_n$ 上，而是作用在 $q_n$ 与 $k_n$ 上。

## 3. RoPE 如何编码到 K 里面

### 3.1 二维一组的旋转形式
把 $q_n, k_n$ 的通道按两维一组拆开。对第 $i$ 组：

$$
\begin{pmatrix}
q'_{n,2i}\\
q'_{n,2i+1}
\end{pmatrix}
=
\begin{pmatrix}
\cos(n\theta_i) & -\sin(n\theta_i)\\
\sin(n\theta_i) & \cos(n\theta_i)
\end{pmatrix}
\begin{pmatrix}
q_{n,2i}\\
q_{n,2i+1}
\end{pmatrix}
$$

$$
\begin{pmatrix}
k'_{n,2i}\\
k'_{n,2i+1}
\end{pmatrix}
=
\begin{pmatrix}
\cos(n\theta_i) & -\sin(n\theta_i)\\
\sin(n\theta_i) & \cos(n\theta_i)
\end{pmatrix}
\begin{pmatrix}
k_{n,2i}\\
k_{n,2i+1}
\end{pmatrix}
$$

因此缓存中的历史 key 通常不是原始 $k_n$，而是已经带了位置旋转的：

$$
k'_n = R(n)k_n
$$

### 3.2 为什么它变成相对位置编码
注意力分数用的是旋转后的 $q'_n$ 和 $k'_m$：

$$
\mathrm{score}(n,m) = {q'_n}^\top k'_m
$$

利用旋转矩阵性质：

$$
R(a)^\top R(b) = R(b-a)
$$

得到：

$$
{q'_n}^\top k'_m
=
q_n^\top R(m-n)k_m
$$

所以分数依赖的是相对位置差 $m-n$，而不是绝对位置单独出现。这就是 RoPE 的核心。

### 3.3 复数写法
把每对维度看成一个复数：

$$
\tilde q_{n,i} = q_{n,2i} + i q_{n,2i+1},\qquad
\tilde k_{n,i} = k_{n,2i} + i k_{n,2i+1}
$$

则 RoPE 写成：

$$
\tilde q'_{n,i} = \tilde q_{n,i} e^{i n\theta_i},\qquad
\tilde k'_{n,i} = \tilde k_{n,i} e^{i n\theta_i}
$$

于是注意力里自然出现相位差：

$$
e^{i(n-m)\theta_i}
$$

这说明相对位置信息被编码进了 $Q/K$ 的相位关系中。

## 4. RoPE 和 KV Cache 的关系

自回归推理时，历史 token 的 key/value 会被缓存。

到第 $t$ 步时：
- 当前 token 生成新的 $q'_t$；
- 直接与缓存中的历史 $\{k'_1,\dots,k'_{t-1}\}$ 计算注意力；
- 再用相应权重去读取历史 $\{v_1,\dots,v_{t-1}\}$。

注意力形式为：

$$
\mathrm{Attn}(t,j)\propto
\exp\left(
\frac{{q'_t}^\top k'_j}{\sqrt d}
\right)
$$

因此要非常明确地区分：

- `K cache`：缓存的是已经带位置编码的 $k'_j = R(j)k_j$
- `V cache`：缓存的是内容值 $v_j$，通常不做 RoPE

所以“RoPE 编码到 KV 里”这句话并不严格。更准确地说：

$$
\text{RoPE 编码到 } Q \text{ 和 } K \text{，不编码到 } V
$$

## 5. 视频里怎么理解 KV Cache 的时间维和空间维

文本只有一维顺序位置，但视频 token 至少有三维位置：

$$
(t,h,w)
$$

其中：
- $t$：时间帧索引
- $h$：空间高度索引
- $w$：空间宽度索引

因此视频中的一个 key 不是“某个历史内容”这么简单，而是：

$$
\text{某个时刻 } t \text{、某个空间 patch } (h,w) \text{ 的内容表示}
$$

这意味着视频 KV cache 中的历史 $K/V$ 同时承担两层含义：
- 内容信息：这个 patch 长什么样；
- 时空位置信息：它属于哪一帧、画面哪一块区域。

因此模型在做注意力时，本质上在同时判断：
- 当前帧要不要看更早的历史帧；
- 如果要看，要看那一帧中的哪个空间区域。

## 6. 三维 RoPE 为什么不会混淆维度

### 6.1 维度混淆的含义
所谓“混淆维度”，是指模型分不清两个位置差异到底来自：
- 时间变化；
- 高度变化；
- 宽度变化。

如果把视频 token 直接 flatten 成一个一维编号，再做 1D RoPE，就容易出现这种问题：模型只知道编号差多少，却不知道这是“下一帧同位置”还是“同一帧右边一个 patch”。

### 6.2 三维 RoPE 的标准形式
设每个 head 的维度为 $d$，拆成三部分：

$$
d = d_t + d_h + d_w
$$

并把 query/key 拆成三块：

$$
q =
\begin{bmatrix}
q^{(t)}\\
q^{(h)}\\
q^{(w)}
\end{bmatrix},
\qquad
k =
\begin{bmatrix}
k^{(t)}\\
k^{(h)}\\
k^{(w)}
\end{bmatrix}
$$

定义三个轴各自的旋转：

$$
R_t(t),\qquad R_h(h),\qquad R_w(w)
$$

整体旋转是块对角形式：

$$
R(t,h,w)=
\begin{bmatrix}
R_t(t) & 0 & 0\\
0 & R_h(h) & 0\\
0 & 0 & R_w(w)
\end{bmatrix}
$$

于是：

$$
q' = R(t,h,w)q,\qquad
k' = R(t,h,w)k
$$

### 6.3 为什么不会混淆
注意力分数自然分解成三项：

$$
\langle q'_1, k'_2\rangle
=
\langle R_t(t_1)q_1^{(t)}, R_t(t_2)k_2^{(t)}\rangle
+
\langle R_h(h_1)q_1^{(h)}, R_h(h_2)k_2^{(h)}\rangle
+
\langle R_w(w_1)q_1^{(w)}, R_w(w_2)k_2^{(w)}\rangle
$$

不会出现这样的交叉项：

$$
\langle R_t(t_1)q_1^{(t)}, R_h(h_2)k_2^{(h)}\rangle
$$

原因很简单：时间、高度、宽度作用在互不重叠的通道子空间里，整体是块对角结构，不会轴间串台。

因此三维 RoPE 本质上是：

$$
R(t,h,w) = R_t(t)\oplus R_h(h)\oplus R_w(w)
$$

这意味着：
- 时间位移只进入时间子空间；
- 高度位移只进入高度子空间；
- 宽度位移只进入宽度子空间。

### 6.4 相对位置仍然是分轴成立
每个轴都满足：

$$
R(a)^\top R(b)=R(b-a)
$$

因此注意力分数等价于依赖：

$$
\Delta t = t_2-t_1,\qquad
\Delta h = h_2-h_1,\qquad
\Delta w = w_2-w_1
$$

也就是说，模型看到的是三组分轴相对位移，而不是一个混在一起的一维编号差。

## 7. 为什么 Rolling Forcing 要动态调整时间维 RoPE

在视频流式生成里，如果把最开始的全局锚点帧长期保留在 `KV cache` 中，它们内容上很有用，但时间位置会越来越远。

如果仍然直接用原始时间位置去解释这些旧 key，那么它们和当前帧的相对时间差会不断增大，最后超出训练时见过的时间范围，造成：
- 时间错位；
- 闪烁；
- 甚至“突然跳回开头画面”的 artifact。

因此 `Rolling Forcing` 的处理可以理解为：
- 空间维位置不动，因为这些 patch 仍然属于相同空间区域；
- 只重对齐时间维 RoPE，让这些全局锚点始终处在一个更合理的相对时间距离上。

这正是它为什么强调 `dynamic RoPE`，而且主要改的是时间维，不是空间维。

## 8. Deep Forcing 里的时间维 RoPE 重对齐到底在做什么

`Deep Forcing` 的做法可以理解成：不重算整段历史，只对已经缓存的旧 `sink key` 补一个时间相位偏移，让它们看起来像被“搬到”当前时间线附近。

若某个 sink token 原本位于时间 $t_{\text{old}}$，现在希望等效对齐到新的时间位置 $t_{\text{new}}$，则令：

$$
\Delta = t_{\text{new}} - t_{\text{old}}
$$

对时间子空间里的 key 做一次额外旋转：

$$
k_{\text{new}}^{(t)} = R_t(\Delta)\, k_{\text{old}}^{(t)}
$$

由于 RoPE 满足：

$$
R_t(a+b)=R_t(a)R_t(b)
$$

如果原来

$$
k_{\text{old}}^{(t)}=R_t(t_{\text{old}})k^{(t)}
$$

那么补完相位后就有：

$$
k_{\text{new}}^{(t)}
=
R_t(\Delta)R_t(t_{\text{old}})k^{(t)}
=
R_t(t_{\text{new}})k^{(t)}
$$

也就是说，它等价于把这个旧 token 的时间位置从 $t_{\text{old}}$ 平移到了 $t_{\text{new}}$。

最小例子：若某个 sink 帧原来在第 $2$ 帧，现在希望它在注意力里等效于第 $10$ 帧，那么

$$
\Delta = 10 - 2 = 8
$$

只需对它的时间维 key 再乘一次 $R_t(8)$。这样无需重算内容，也无需改空间维位置，只是把时间相位往当前时间线附近平移。

## 9. 一页速记

### 9.1 方法递进
$$
\text{CausVid}: \text{让 streaming AR video diffusion 成立}
$$

$$
\text{Self Forcing}: \text{解决 train-test gap / exposure bias}
$$

$$
\text{Rolling Forcing}: \text{解决逐帧推理单元的误差固化与长期漂移}
$$

### 9.2 RoPE 的数学本质
$$
q'_n = R(n)q_n,\qquad
k'_m = R(m)k_m
$$

$$
{q'_n}^\top k'_m = q_n^\top R(m-n)k_m
$$

### 9.3 KV cache 中真正带位置的是谁
$$
K\text{-cache}: k'_j = R(j)k_j
$$

$$
V\text{-cache}: v_j
$$

### 9.4 三维 RoPE 不混淆维度的原因
$$
R(t,h,w)=R_t(t)\oplus R_h(h)\oplus R_w(w)
$$

也就是：分轴编码，分轴作用，最后再在注意力分数层面相加。

## 相关笔记
- [[CausVid✅]]
- [[Self-Forcing ✅]]
- [[Rolling-Forcing✅]]
- [[StreamingLLM-Efficient-Streaming-Language-Models-with-Attention-Sinks✅]]
