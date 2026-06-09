# Chapitre 3：Condition d'optimalité sans contrainte

来源：[[PPT/Slides_Chp3.pdf|Slides_Chp3.pdf]]

本讲讨论**无约束优化的最优性条件**。核心问题是：给定一个可微或二次可微函数，怎样判断某个点是否可能是最小点？哪些条件只是必要的，哪些条件足以保证最小？

本讲主线：

1. 全局最小与局部最小；
2. 可行方向与下降方向；
3. 最小值存在性与唯一性；
4. 无约束问题的一阶、二阶必要条件；
5. 无约束问题的充分条件；
6. 凸函数情形下的充要条件。

## 1. 无约束优化问题

无约束优化的标准形式是：

$$
\min_{x\in\mathbb{R}^n} f(x),
$$

其中目标函数 $f:\mathbb{R}^n\to\mathbb{R}$ 通常假设一阶可微或二阶可微。

更一般地，也可以在集合 $D\subset\mathbb{R}^n$ 上优化：

$$
\min_{x\in D} f(x).
$$

若 $D$ 是闭且有界的非空集合，因此在 $\mathbb{R}^n$ 中是紧集，且 $f$ 在 $D$ 上连续，则根据 Weierstrass 定理，$f$ 在 $D$ 上一定达到最小值和最大值。

## 2. 全局最小与局部最小

### 2.1 全局最小

设 $D\subset\mathbb{R}^n$。若 $x^\star\in D$ 满足：

$$
f(x^\star)\le f(x),\qquad \forall x\in D,
$$

则称 $x^\star$ 是 $f$ 在 $D$ 上的**全局最小点**。

对应的函数值：

$$
f(x^\star)=\min_{x\in D} f(x)
$$

称为全局最小值。

### 2.2 局部最小

若存在 $\varepsilon>0$，使得：

$$
f(x^\star)\le f(x),
\qquad
\forall x\in D\cap B_O(x^\star,\varepsilon),
$$

则称 $x^\star$ 是**局部最小点**。

局部最小只要求在点 $x^\star$ 附近不比周围点差；全局最小则要求在整个可行域内都最好。

### 2.3 为什么局部最小有时可以接受

在某些情形，局部最小已经足够好：

- 如果问题是凸优化，局部最小就是全局最小；
- 工程项目中有时只需要“足够好”的解；
- 对大规模非凸问题，寻找全局最优的时间成本可能过高。

例如大型神经网络训练有数亿参数，目标函数通常非凸，理论上很难保证找到全局最小点。但在实践中，足够低的训练损失和良好的泛化表现往往已经可接受。

不过在安全关键场景中，局部最小可能不能接受。例如：

- 飞行器控制；
- 自动驾驶或自动驾驶仪；
- 放疗计划；
- 电网调度。

这些问题中，一个“看起来还行”的局部解可能带来严重后果。

## 3. 可行方向

在有约束问题中，某个方向即使能让目标函数下降，也可能立刻走出可行域。因此需要区分可行方向与下降方向。

设可行域为 $D\subset\mathbb{R}^n$，点 $x\in D$。若向量 $d\in\mathbb{R}^n$ 满足存在 $\varepsilon>0$，使得：

$$
x+td\in D,\qquad \forall t\in[0,\varepsilon],
$$

则称 $d$ 是点 $x$ 处的**可行方向**。

点 $x$ 处所有可行方向的集合记为：

$$
\mathcal{F}(x)
=
\{d\in\mathbb{R}^n:\exists \varepsilon>0,\ x+td\in D,\ \forall t\in[0,\varepsilon]\}.
$$

在无约束问题中，$D=\mathbb{R}^n$，所以任意方向都是可行方向：

$$
\mathcal{F}(x)=\mathbb{R}^n.
$$

## 4. 下降方向

设 $f:D\to\mathbb{R}$，$x\in D$。若方向 $d$ 使得从 $x$ 沿 $d$ 出发能让函数值不增，则称 $d$ 是下降方向。

一种常用定义是：存在 $\varepsilon>0$，使得：

$$
f(x+td)\le f(x),
\qquad
\forall t\in[0,\varepsilon].
$$

若进一步有严格下降：

$$
f(x+td)< f(x),
\qquad
\forall t\in(0,\varepsilon],
$$

则称 $d$ 是**严格下降方向**。

点 $x$ 处下降方向集合可记为：

$$
\mathcal{D}(x).
$$

在算法中，下降方向很重要：若能找到一个可行的严格下降方向，就说明当前点不可能是局部最小点。

## 5. 下降方向的梯度刻画

设 $f$ 在 $x$ 处可微。沿方向 $d$ 的一阶展开为：

$$
f(x+td)
=
f(x)+t\langle \nabla f(x),d\rangle+o(t).
$$

因此：

- 若 $\langle \nabla f(x),d\rangle<0$，则 $d$ 是严格下降方向；
- 若 $d$ 是下降方向，通常应有

$$
\langle \nabla f(x),d\rangle\le 0.
$$

特别地，最速下降方向是负梯度方向：

$$
d=-\nabla f(x).
$$

因为：

$$
\langle \nabla f(x),-\nabla f(x)\rangle
=-\|\nabla f(x)\|^2<0
$$

只要 $\nabla f(x)\ne 0$，负梯度方向就是严格下降方向。

这解释了梯度法的基本迭代形式：

$$
x_{k+1}=x_k-\alpha_k\nabla f(x_k),
$$

其中 $\alpha_k>0$ 是步长。

## 6. 最小值存在性

### 6.1 Weierstrass 存在定理

设 $K\subset\mathbb{R}^n$ 是非空紧集，$f:K\to\mathbb{R}$ 连续。则 $f$ 在 $K$ 上一定达到最小值。也就是说，存在 $x^\star\in K$，使得：

$$
f(x^\star)=\min_{x\in K}f(x).
$$

同理，$f$ 也在 $K$ 上达到最大值。

在 $\mathbb{R}^n$ 中，紧集等价于闭且有界。因此常用判断是：

$$
K\ \text{closed and bounded}
\quad\Longrightarrow\quad
K\ \text{compact}.
$$

### 6.2 强制函数的存在定理

若 $f:\mathbb{R}^n\to\mathbb{R}$ 连续且强制，即：

$$
\lim_{\|x\|\to+\infty} f(x)=+\infty,
$$

则 $f$ 至少存在一个全局最小点。

直观解释：虽然 $\mathbb{R}^n$ 不是紧集，但强制性保证了函数在无穷远处会变大，所以最小值只能出现在某个足够大的闭球内；闭球是紧的，于是可用 Weierstrass 定理。

## 7. 最小值唯一性

设 $D\subset\mathbb{R}^n$ 是凸集，$f:D\to\mathbb{R}$ 严格凸。若 $f$ 在 $D$ 上存在最小点，则该最小点唯一。

证明思路很简单。若存在两个不同的全局最小点 $x_1\ne x_2$，且最小值为 $m$，则对 $\theta\in(0,1)$：

$$
f(\theta x_1+(1-\theta)x_2)
<
\theta f(x_1)+(1-\theta)f(x_2)
=m.
$$

这与 $m$ 是全局最小值矛盾。因此最小点只能有一个。

注意：严格凸保证唯一性，但不单独保证存在性。存在性仍然需要紧性、强制性或其他条件。

## 8. 无约束问题的一阶必要条件

考虑无约束问题：

$$
\min_{x\in\mathbb{R}^n} f(x).
$$

设 $x^\star$ 是局部最小点。如果 $f$ 在 $x^\star$ 可微，则必须有：

$$
\nabla f(x^\star)=0.
$$

这称为**一阶必要条件**。

满足

$$
\nabla f(x)=0
$$

的点称为**临界点**或**驻点**。

但要注意：临界点不一定是最小点。它也可能是：

- 局部最大点；
- 鞍点；
- 更复杂的平坦点。

例如：

$$
f(x)=x^3
$$

在 $x=0$ 处满足 $f'(0)=0$，但 $0$ 不是局部最小也不是局部最大。

## 9. 无约束问题的二阶必要条件

如果 $x^\star$ 是局部最小点，且 $f$ 在 $x^\star$ 二次可微，则除了：

$$
\nabla f(x^\star)=0,
$$

还必须有 Hessian 半正定：

$$
H_f(x^\star)\succeq 0.
$$

也就是说，对任意方向 $d\in\mathbb{R}^n$：

$$
d^\top H_f(x^\star)d\ge 0.
$$

这称为**二阶必要条件**。

直觉来自二阶 Taylor 展开：

$$
f(x^\star+td)
=f(x^\star)
+t\langle \nabla f(x^\star),d\rangle
+\frac12 t^2 d^\top H_f(x^\star)d
+o(t^2).
$$

在局部最小点，一阶项为零；若某个方向上二阶项为负，则沿该方向会下降，矛盾。因此 Hessian 必须半正定。

## 10. 无约束问题的充分条件

设 $f$ 在 $x^\star$ 附近二次可微，且：

$$
\nabla f(x^\star)=0.
$$

如果 Hessian 正定：

$$
H_f(x^\star)\succ 0,
$$

则 $x^\star$ 是 $f$ 的严格局部最小点。

这是常用的**二阶充分条件**。

证明直觉仍来自 Taylor 展开：

$$
f(x^\star+h)
=f(x^\star)
+\frac12 h^\top H_f(x^\star)h
+o(\|h\|^2).
$$

若 $H_f(x^\star)\succ 0$，则对足够小的非零 $h$，二次项严格为正，因此：

$$
f(x^\star+h)>f(x^\star).
$$

此外，如果在 $x^\star$ 的某个邻域内：

$$
H_f(x)\succeq 0
$$

并且 $\nabla f(x^\star)=0$，则 $x^\star$ 也是局部最小点。这类条件可以理解为：函数在该邻域内是凸的，而驻点就是局部最小点。

## 11. 必要条件与充分条件的区别

必要条件用于**排除错误候选点**。例如若某点 $x$ 满足：

$$
\nabla f(x)\ne 0,
$$

则它不可能是无约束可微问题的局部最小点。

充分条件用于**确认正确解**。例如若某点满足：

$$
\nabla f(x)=0,\qquad H_f(x)\succ 0,
$$

则它一定是严格局部最小点。

但必要条件不一定充分：

$$
\nabla f(x)=0
$$

只能说明 $x$ 是候选点，不能直接说明它是最小点。

## 12. 凸函数情形下的充要条件

设 $f:\mathbb{R}^n\to\mathbb{R}$ 是可微凸函数。则：

$$
x^\star\ \text{是全局最小点}
\quad\Longleftrightarrow\quad
\nabla f(x^\star)=0.
$$

这时一阶条件既是必要条件，也是充分条件。

证明来自凸函数的一阶刻画：

$$
f(y)\ge f(x)+\langle \nabla f(x),y-x\rangle,
\qquad \forall x,y.
$$

令 $x=x^\star$，若 $\nabla f(x^\star)=0$，则：

$$
f(y)\ge f(x^\star),
\qquad \forall y.
$$

因此 $x^\star$ 是全局最小点。

若 $f$ 严格凸，则全局最小点至多一个；若再存在满足 $\nabla f(x^\star)=0$ 的点，则它就是唯一全局最小点。

## 13. 一维情形速查

对一维函数 $f:\mathbb{R}\to\mathbb{R}$：

一阶必要条件：

$$
f'(x^\star)=0.
$$

二阶必要条件：

$$
f''(x^\star)\ge 0.
$$

二阶充分条件：

$$
f'(x^\star)=0,\qquad f''(x^\star)>0
\quad\Longrightarrow\quad
x^\star\ \text{是严格局部最小点}.
$$

若：

$$
f'(x^\star)=0,\qquad f''(x^\star)<0,
$$

则 $x^\star$ 是严格局部最大点。

若：

$$
f'(x^\star)=0,\qquad f''(x^\star)=0,
$$

则二阶判别失效，需要看更高阶项或其他方法。

## 14. 本讲总结

本讲最重要的逻辑是：

$$
\text{局部最小}
\Longrightarrow
\nabla f(x^\star)=0
\Longrightarrow
\text{候选点}.
$$

如果还知道二阶信息：

$$
\text{局部最小}
\Longrightarrow
H_f(x^\star)\succeq 0.
$$

反过来，若：

$$
\nabla f(x^\star)=0,\qquad H_f(x^\star)\succ 0,
$$

则：

$$
x^\star\ \text{是严格局部最小点}.
$$

在凸优化中，结论更强：

$$
\nabla f(x^\star)=0
\Longleftrightarrow
x^\star\ \text{是全局最小点}.
$$

所以无约束优化的基本工作流程是：

1. 解方程 $\nabla f(x)=0$ 找候选点；
2. 用 Hessian 判断候选点类型；
3. 若函数凸，则驻点直接给出全局最小；
4. 若函数严格凸且最小点存在，则全局最小点唯一。
