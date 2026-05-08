 # Zero Padded Impulse Train（更直观版）

**目标序列（周期为 M 的冲激列）**

$$
x[n]=\sum_{k=-\infty}^{\infty}\delta[n-Mk]
$$

含义：每隔 M 个采样点出现一个 1，其余为 0。

**计算 DTFT**

$$
X(e^{j\omega})=\sum_{n=-\infty}^{\infty}x[n]e^{-j\omega n}
=\sum_{n=-\infty}^{\infty}\Big(\sum_{k=-\infty}^{\infty}\delta[n-Mk]\Big)e^{-j\omega n}
$$

利用冲激“抽样”性质：只在 $n=Mk$ 时有贡献，所以

$$
X(e^{j\omega})=\sum_{k=-\infty}^{\infty}e^{-j\omega Mk}
$$

这是一串**等间隔的复指数和**，在频域对应**等间隔的冲激列**：

$$
\sum_{k=-\infty}^{\infty}e^{-j\omega Mk}
=\frac{2\pi}{M}\sum_{m=-\infty}^{\infty}\delta\!\left(\omega-\frac{2\pi m}{M}\right)
$$

**结论（时域冲激列 ↔ 频域冲激列）**

$$
\sum_{k=-\infty}^{\infty}\delta[n-Mk]
\;\xleftrightarrow{\ \mathcal{F}\ }\;
\frac{2\pi}{M}\sum_{m=-\infty}^{\infty}\delta\!\left(\omega-\frac{2\pi m}{M}\right)
$$

**一句话理解**
- 时域是“每隔 M 点一个冲激”。
- 频域就是“每隔 $2\pi/M$ 一个冲激”。

---

## 关键等号的推导

要推导：

$$
\sum_{k=-\infty}^{\infty}e^{-j\omega Mk}
=\frac{2\pi}{M}\sum_{m=-\infty}^{\infty}\delta\!\left(\omega-\frac{2\pi m}{M}\right)
$$

**步骤（傅里叶级数 + 梳状谱）**

设

$$
S(\omega)=\sum_{k=-\infty}^{\infty}e^{-j\omega Mk}.
$$

注意周期性：

$$
S\left(\omega+\frac{2\pi}{M}\right)
=\sum_{k}e^{-j(\omega+2\pi/M)Mk}
=\sum_{k}e^{-j\omega Mk}e^{-j2\pi k}=S(\omega).
$$

所以 \(S(\omega)\) 是周期为 \(2\pi/M\) 的函数，可写成傅里叶级数：

$$
S(\omega)=\sum_{m=-\infty}^{\infty}c_m e^{jmM\omega}.
$$

求系数：

$$
c_m=\frac{M}{2\pi}\int_{-\pi/M}^{\pi/M}S(\omega)e^{-jmM\omega}\,d\omega.
$$

代入并交换求和：

$$
c_m=\frac{M}{2\pi}\sum_{k}\int_{-\pi/M}^{\pi/M}e^{-j\omega M(k+m)}\,d\omega.
$$

积分只有在 \(k=-m\) 时非零：

$$
\int_{-\pi/M}^{\pi/M}e^{-j\omega M(k+m)}\,d\omega
=\begin{cases}
2\pi/M,& k=-m\\
0,& k\neq -m
\end{cases}
$$

所以 \(c_m=1\)，得到：

$$
S(\omega)=\sum_{m=-\infty}^{\infty}e^{jmM\omega}.
$$

使用梳状谱恒等式（Poisson 求和）：

$$
\sum_{m=-\infty}^{\infty}e^{jmM\omega}
=\frac{2\pi}{M}\sum_{m=-\infty}^{\infty}\delta\!\left(\omega-\frac{2\pi m}{M}\right).
$$

因此

$$
\boxed{
\sum_{k=-\infty}^{\infty}e^{-j\omega Mk}
=\frac{2\pi}{M}\sum_{m=-\infty}^{\infty}\delta\!\left(\omega-\frac{2\pi m}{M}\right)
}
$$

---

## Poisson 求和（梳状谱恒等式）

常用形式：

$$
\sum_{m=-\infty}^{\infty}e^{jmM\omega}
=\frac{2\pi}{M}\sum_{m=-\infty}^{\infty}\delta\!\left(\omega-\frac{2\pi m}{M}\right)
$$

含义：
- 左边是频率域的“周期复指数和”。
- 右边是频率域的“冲激梳状谱”。
- 间隔为 \(2\pi/M\)。
