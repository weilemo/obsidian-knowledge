
---

## 4(a) 详细推导：由 \(X(e^{j\omega})\) 求 \(x[n]\)

给定：

$$
X(e^{j\omega})=\frac{1-a^2}{(1-ae^{-j\omega})(1-ae^{j\omega})},\quad |a|<1.
$$

### 方法 1：拆成两段几何级数

注意：

$$
\frac{1}{1-ae^{-j\omega}}=\sum_{n=0}^{\infty}a^n e^{-j\omega n},\quad |a|<1
$$

以及

$$
\frac{1}{1-ae^{j\omega}}=\sum_{m=0}^{\infty}a^m e^{j\omega m},\quad |a|<1.
$$

于是

$$
\begin{aligned}
X(e^{j\omega})
&=(1-a^2)\left(\sum_{n=0}^{\infty}a^n e^{-j\omega n}\right)
\left(\sum_{m=0}^{\infty}a^m e^{j\omega m}\right)\\
&=(1-a^2)\sum_{n=0}^{\infty}\sum_{m=0}^{\infty}a^{n+m}e^{-j\omega (n-m)}.
\end{aligned}
$$

令 \(k=n-m\)。对每个整数 \(k\)：
- 当 \(k\ge 0\)：取 \(n=m+k\)，有 \(a^{n+m}=a^{2m+k}\)。
- 当 \(k<0\)：取 \(m=n-k\)，有 \(a^{n+m}=a^{2n-k}\)。

因此

$$
X(e^{j\omega})=\sum_{k=-\infty}^{\infty}\left[(1-a^2)\sum_{\ell=0}^{\infty}a^{2\ell+|k|}\right]e^{-j\omega k}.
$$

括号内是几何级数：

$$
(1-a^2)\sum_{\ell=0}^{\infty}a^{2\ell+|k|}
=(1-a^2)a^{|k|}\sum_{\ell=0}^{\infty}(a^2)^{\ell}
=(1-a^2)a^{|k|}\cdot\frac{1}{1-a^2}=a^{|k|}.
$$

所以

$$
X(e^{j\omega})=\sum_{k=-\infty}^{\infty}a^{|k|}e^{-j\omega k}.
$$

这就是 DTFT 形式，因此

$$
\boxed{x[n]=a^{|n|}}.
$$

### 方法 2：标准对偶记忆

已知经典结果：

$$
\sum_{n=-\infty}^{\infty}a^{|n|}e^{-j\omega n}
=\frac{1-a^2}{1-2a\cos\omega+a^2},\quad |a|<1.
$$

而题目分母

$$
(1-ae^{-j\omega})(1-ae^{j\omega})=1-2a\cos\omega+a^2,
$$

因此直接识别出

$$
\boxed{x[n]=a^{|n|}}.
$$
