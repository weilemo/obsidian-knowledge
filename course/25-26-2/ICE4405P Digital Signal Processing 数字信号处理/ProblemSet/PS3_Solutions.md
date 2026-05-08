# PS3 Solutions (Detailed)

## Problem 1
Given two 8-point sequences from the figure:

- For `x1[n]`: nonzero samples are
  - `x1[1]=a, x1[2]=b, x1[3]=c, x1[4]=d, x1[5]=e`.
- For `x2[n]`: nonzero samples are
  - `x2[0]=d, x2[1]=e, x2[5]=a, x2[6]=b, x2[7]=c`.

This is a circular time shift by 4 samples:

$$
x_2[n] = x_1[((n-4))_8].
$$

Using the DFT circular-shift property

$$
x[((n-m))_N] \xleftrightarrow{\text{DFT}} W_N^{km}X[k],
$$

with `N=8`, `m=4`:

$$
X_2[k] = W_8^{4k}X_1[k] = e^{-j2\pi(4k)/8}X_1[k] = e^{-j\pi k}X_1[k] = (-1)^kX_1[k].
$$

So the relationship is

$$
\boxed{X_2[k]=(-1)^kX_1[k]}
$$

---

## Problem 2
From the figure, the real finite-length sequence is

$$
x[n]=[4,3,2,1,0,0],\quad n=0,1,2,3,4,5.
$$

Its 6-point DFT is `X[k]`.

### (a) `Y[k]=W_6^{5k}X[k]`
By circular-shift property:

$$
Y[k]=W_6^{mk}X[k] \Rightarrow y[n]=x[((n-m))_6].
$$

Here `m=5`, so

$$
y[n]=x[((n-5))_6]=x[((n+1))_6].
$$

Thus

- `y[0]=x[1]=3`
- `y[1]=x[2]=2`
- `y[2]=x[3]=1`
- `y[3]=x[4]=0`
- `y[4]=x[5]=0`
- `y[5]=x[0]=4`

Hence

$$
\boxed{y[n]=[3,2,1,0,0,4]}
$$

### (b) `W[k]=\mathrm{Im}\{X[k]\}`
Using

$$
\mathrm{Im}\{X[k]\}=\frac{X[k]-X^*[k]}{2j},
$$

and inverse DFT, the corresponding sequence is

$$
w[n]=\frac{x[n]-x[((-n))_6]}{2j}.
$$

Compute `x[((-n))_6]`:

- `n=0: x[0]=4`
- `n=1: x[5]=0`
- `n=2: x[4]=0`
- `n=3: x[3]=1`
- `n=4: x[2]=2`
- `n=5: x[1]=3`

So

$$
\boxed{w[n]=[0,-1.5j,-1j,0,1j,1.5j]}
$$

(If sketching, draw imaginary-valued stems: negative at `n=1,2`, positive at `n=4,5`.)

### (c) `Q[k]=X[2k+1],\ k=0,1,2`
So

$$
Q[0]=X[1],\ Q[1]=X[3],\ Q[2]=X[5].
$$

First compute `X[k]` (6-point DFT of `[4,3,2,1,0,0]`):

$$
X[1]=3.5-4.3301j,\ X[3]=2,\ X[5]=3.5+4.3301j.
$$

Now apply 3-point IDFT:

$$
q[n]=\frac{1}{3}\sum_{k=0}^{2}Q[k]W_3^{-kn}.
$$

Result:

$$
\boxed{q[n]=[3,\ 1.5-2.5981j,\ -1-1.7321j]},\quad n=0,1,2.
$$

---

## Problem 3
Given

$$
p[n]=\{1,2,0,1\},\quad q[n]=\{2,2,1,1\}.
$$

### (a) 4-point DFT of `p[n]` and `q[n]`
Using

$$
X[k]=\sum_{n=0}^{3}x[n]W_4^{kn},\quad W_4=e^{-j\pi/2}=-j.
$$

For `p[n]`:

$$
P[0]=4,\ P[1]=1-j,\ P[2]=-2,\ P[3]=1+j.
$$

For `q[n]`:

$$
Q[0]=6,\ Q[1]=1-j,\ Q[2]=0,\ Q[3]=1+j.
$$

### (b) Circular convolution `p[n] \circledast_4 q[n]`
Frequency-domain multiplication:

$$
Y[k]=P[k]Q[k].
$$

So

$$
Y[0]=24,\ Y[1]=-2j,\ Y[2]=0,\ Y[3]=2j.
$$

Taking 4-point IDFT gives

$$
\boxed{y[n]=\{6,7,6,5\}}.
$$

---

## Problem 4
From the figure:

$$
x[n]=\{6,5,4,3\},\quad n=0,1,2,3.
$$

### (a) 

$$
x_1[n]=x[((n-2))_4],\ 0\le n\le 3.
$$

Compute:

- `x1[0]=x[2]=4`
- `x1[1]=x[3]=3`
- `x1[2]=x[0]=6`
- `x1[3]=x[1]=5`

Hence

$$
\boxed{x_1[n]=\{4,3,6,5\}}.
$$

### (b)

$$
x_2[n]=x[((-n))_4],\ 0\le n\le 3.
$$

Compute:

- `x2[0]=x[0]=6`
- `x2[1]=x[3]=3`
- `x2[2]=x[2]=4`
- `x2[3]=x[1]=5`

Hence

$$
\boxed{x_2[n]=\{6,3,4,5\}}.
$$

---

## Problem 5
For `N=1024=2^{10}`:

### (a) Direct DFT
Each of `N` outputs needs `N` complex multiplications:

$$
N^2=1024^2=2^{20}.
$$

### (b) FFT (radix-2)
Complex multiplications count is

$$
\frac{N}{2}\log_2N=\frac{1024}{2}\cdot 10=5120=5\cdot 2^{10}.
$$

So:

$$
\boxed{\text{Direct DFT: }2^{20},\quad \text{FFT: }5\cdot 2^{10}}.
$$

---

## Problem 6
Find 8-point DFT of

$$
x[n]=\{1,2,3,4,4,3,2,1\}.
$$

Final DFT values (same for DIT and DIF):

$$
\begin{aligned}
X[0]&=20,\\
X[1]&=-5.8284-2.4142j,\\
X[2]&=0,\\
X[3]&=-0.1716-0.4142j,\\
X[4]&=0,\\
X[5]&=-0.1716+0.4142j,\\
X[6]&=0,\\
X[7]&=-5.8284+2.4142j.
\end{aligned}
$$

### (a) DIT-FFT flow (radix-2)
- Input order: bit-reversed index order, then 3 butterfly stages.
- Twiddle factors by stage:
  - Stage 1: no twiddle (`W_2^0`).
  - Stage 2: `W_4^0, W_4^1`.
  - Stage 3: `W_8^0, W_8^1, W_8^2, W_8^3`.

A valid flow graph is the standard 8-point radix-2 DIT butterfly network with these twiddles.

### (b) DIF-FFT flow (radix-2)
- Input in natural order.
- 3 butterfly stages with twiddles applied on difference branches first.
- Output comes out in bit-reversed order; reorder to natural index to get the same `X[k]` above.

A valid flow graph is the standard 8-point radix-2 DIF butterfly network.

### Note for submission
For hand-written/typed report, draw the two standard 8-point butterfly diagrams and label twiddles clearly; both must produce the same final `X[k]` set above.

