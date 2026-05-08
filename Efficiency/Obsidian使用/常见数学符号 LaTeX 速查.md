---
created: 2026-04-09
type: cheat-sheet
tags:
  - Obsidian
  - LaTeX
  - Math
  - 公式
aliases:
  - 数学符号 LaTeX 速查
summary: 常见数学符号的 LaTeX 写法与可直接复用示例
---

# 常见数学符号 LaTeX 速查

> 说明：左侧是 LaTeX 写法，下面是渲染效果。可直接复制到 Obsidian。

## 1. 希腊字母

- `\\alpha, \\beta, \\gamma, \\delta, \\epsilon, \\lambda, \\mu, \\pi, \\sigma, \\omega`
$$
\alpha, \beta, \gamma, \delta, \epsilon, \lambda, \mu, \pi, \sigma, \omega
$$

- `\\Gamma, \\Delta, \\Lambda, \\Pi, \\Sigma, \\Omega`
$$
\Gamma, \Delta, \Lambda, \Pi, \Sigma, \Omega
$$

## 2. 上下标与分数

- 上下标：`x^2`, `x_i`, `x_{i+1}`, `e^{-x}`
$$
x^2,\ x_i,\ x_{i+1},\ e^{-x}
$$

- 分数：`\\frac{a}{b}`，连分数：`\\cfrac{1}{1+\\cfrac{1}{2}}`
$$
\frac{a}{b},\ \cfrac{1}{1+\cfrac{1}{2}}
$$

- 根号：`\\sqrt{x}`, `\\sqrt[n]{x}`
$$
\sqrt{x},\ \sqrt[n]{x}
$$

## 3. 基本运算符

- 加减乘除：`+`, `-`, `\\times`, `\\cdot`, `\\div`
$$
a+b-c,\ a\times b,\ a\cdot b,\ a\div b
$$

- 正负号：`\\pm`, `\\mp`
$$
a\pm b,\ a\mp b
$$

- 求和与连乘：`\\sum`, `\\prod`
$$
\sum_{i=1}^{n} i,\ \prod_{i=1}^{n} i
$$

## 4. 比较与关系符号

- `=`, `\\neq`, `\\approx`, `\\sim`, `\\equiv`
$$
a=b,\ a\neq b,\ a\approx b,\ a\sim b,\ a\equiv b
$$

- `>`, `<`, `\\ge`, `\\le`
$$
a>b,\ a<b,\ a\ge b,\ a\le b
$$

- 集合关系：`\\in`, `\\notin`, `\\subset`, `\\subseteq`, `\\supseteq`
$$
x\in A,\ x\notin A,\ A\subset B,\ A\subseteq B,\ B\supseteq A
$$

## 5. 集合与逻辑

- 常见集合：`\\mathbb{N}, \\mathbb{Z}, \\mathbb{Q}, \\mathbb{R}, \\mathbb{C}`
$$
\mathbb{N},\ \mathbb{Z},\ \mathbb{Q},\ \mathbb{R},\ \mathbb{C}
$$

- 并交补：`\\cup`, `\\cap`, `\\setminus`, `\\varnothing`
$$
A\cup B,\ A\cap B,\ A\setminus B,\ \varnothing
$$

- 逻辑符号：`\\land`, `\\lor`, `\\neg`, `\\forall`, `\\exists`, `\\Rightarrow`, `\\Leftrightarrow`
$$
P\land Q,\ P\lor Q,\ \neg P,\ \forall x,\ \exists y,\ P\Rightarrow Q,\ P\Leftrightarrow Q
$$

## 6. 微积分常用

- 极限：`\\lim_{x\\to 0} \\frac{\\sin x}{x}`
$$
\lim_{x\to 0}\frac{\sin x}{x}
$$

- 导数：`f'(x)`, `\\frac{\\mathrm{d}y}{\\mathrm{d}x}`, `\\frac{\\partial z}{\\partial x}`
$$
f'(x),\ \frac{\mathrm{d}y}{\mathrm{d}x},\ \frac{\partial z}{\partial x}
$$

- 积分：`\\int_a^b f(x)\\,\\mathrm{d}x`, `\\iint`, `\\oint`
$$
\int_a^b f(x)\,\mathrm{d}x,\ \iint_D f(x,y)\,\mathrm{d}A,\ \oint_C \mathbf{F}\cdot\mathrm{d}\mathbf{r}
$$

## 7. 线性代数与向量

- 向量与范数：`\\vec{v}`, `\\mathbf{v}`, `\\|x\\|`, `\\|x\\|_2`
$$
\vec{v},\ \mathbf{v},\ \|x\|,\ \|x\|_2
$$

- 内积：`\\langle x, y \\rangle`
$$
\langle x, y \rangle
$$

- 矩阵：

```latex
\begin{bmatrix}
a & b \\
c & d
\end{bmatrix}
```

$$
\begin{bmatrix}
a & b \\
c & d
\end{bmatrix}
$$

- 行列式：
$$
\det(A)
$$

## 8. 概率统计常用

- 概率与期望：`\\mathbb{P}(A)`, `\\mathbb{E}[X]`, `\\mathrm{Var}(X)`
$$
\mathbb{P}(A),\ \mathbb{E}[X],\ \mathrm{Var}(X)
$$

- 条件概率：`\\mathbb{P}(A\\mid B)`
$$
\mathbb{P}(A\mid B)
$$

- 常见分布记号：`X \\sim \\mathcal{N}(\\mu,\\sigma^2)`
$$
X \sim \mathcal{N}(\mu,\sigma^2)
$$

## 9. 箭头与标注

- 箭头：`\\leftarrow`, `\\rightarrow`, `\\leftrightarrow`, `\\mapsto`
$$
A\leftarrow B,\ A\rightarrow B,\ A\leftrightarrow B,\ x\mapsto f(x)
$$

- 上下括号注释：`\\overbrace{...}^{...}`, `\\underbrace{...}_{...}`
$$
\overbrace{a+b+\cdots+z}^{26\text{ 项}},\ \underbrace{1+1+\cdots+1}_{n\text{ 个}}
$$

## 10. 括号与尺寸控制

- 自动伸缩：`\\left( \\frac{a}{b} \\right)`, `\\left[ \\cdot \\right]`, `\\left\\{ \\cdot \\right\\}`
$$
\left(\frac{a}{b}\right),\ \left[\frac{a}{b}\right],\ \left\{\frac{a}{b}\right\}
$$

- 不同括号：`\\langle x \\rangle`, `\\lfloor x \\rfloor`, `\\lceil x \\rceil`
$$
\langle x \rangle,\ \lfloor x \rfloor,\ \lceil x \rceil
$$

## 11. 公式排版小贴士（Obsidian）

- 行内公式用 `$...$`，短表达式更紧凑。
- 独立公式优先用 `$$...$$`，阅读性更好。
- 在积分里用 `\\,` 增加微小空格，例如 `\\int f(x)\\,\\mathrm{d}x`。
- 变量斜体、函数名直立：三角函数直接写 `\\sin, \\cos, \\log`。
- 多行推导可用 `align` 环境：

```latex
\begin{align}
a+b &= c \\
2a+b &= d
\end{align}
```

## 12. 一段可复用模板

```latex
$$
\begin{align}
\text{Given } x &\in \mathbb{R}^n, \\
\|x\|_2 &= \sqrt{\sum_{i=1}^n x_i^2}, \\
\mathbb{E}[X] &= \int_{-\infty}^{\infty} x f_X(x)\,\mathrm{d}x.
\end{align}
$$
```

