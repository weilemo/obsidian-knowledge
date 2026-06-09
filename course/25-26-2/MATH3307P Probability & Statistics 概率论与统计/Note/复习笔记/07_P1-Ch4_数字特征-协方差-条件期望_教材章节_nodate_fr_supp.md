# 07_P1-Ch4 数字特征、协方差与条件期望（教材章节补充总结）

## 1. 内容定位
- 这不是一份新的主线 PPT，而是对第 4 章内容的教材式系统补充。
- 它把前面两讲的内容串成一章：期望、方差、协方差、相关系数、向量期望、协方差矩阵、条件分布、条件期望、全期望公式。
- 最适合的用法不是替代主线课件，而是当作“定义更完整、例子更多、证明更细”的参考章。

## 2. 这一章补充了什么
- 更细地解释了为什么期望要绝对收敛，才能保证定义良好。
- 用更多实际例子说明“期望是平均收益”“方差是风险”。
- 把协方差、相关系数和投资组合风险放在一起讲，应用感更强。
- 系统写出了向量期望、协方差矩阵、条件分布、条件期望、全期望公式。

## 3. 关键公式

### 3.1 期望与函数期望

$$
\mathbb E[X]=\sum_i x_iP(X=x_i)
$$

或

$$
\mathbb E[X]=\int_{-\infty}^{+\infty}x f_X(x)\,dx.
$$

更一般地，

$$
\mathbb E[g(X)]=\sum_i g(x_i)P(X=x_i)
$$

或

$$
\mathbb E[g(X)]=\int_{-\infty}^{+\infty}g(x)f_X(x)\,dx.
$$

### 3.2 方差

$$
\mathrm{Var}(X)=\mathbb E[(X-\mathbb E[X])^2]
=\mathbb E[X^2]-(\mathbb E[X])^2.
$$

若 $a,b$ 为常数，则

$$
\mathrm{Var}(aX+b)=a^2\mathrm{Var}(X).
$$

### 3.3 协方差与相关系数

$$
\mathrm{Cov}(X,Y)=\mathbb E[(X-\mathbb E[X])(Y-\mathbb E[Y])]
=\mathbb E[XY]-\mathbb E[X]\mathbb E[Y].
$$

$$
\mathrm{Corr}(X,Y)=\frac{\mathrm{Cov}(X,Y)}{\sigma_X\sigma_Y}.
$$

### 3.4 和变量的方差

$$
\mathrm{Var}(X+Y)=\mathrm{Var}(X)+\mathrm{Var}(Y)+2\mathrm{Cov}(X,Y).
$$

若独立，则

$$
\mathrm{Var}(X+Y)=\mathrm{Var}(X)+\mathrm{Var}(Y).
$$

### 3.5 协方差矩阵

若

$$
X=(X_1,\dots,X_n)^\top,
$$

则

$$
\mathbb E[X]=(\mathbb E[X_1],\dots,\mathbb E[X_n])^\top,
$$

$$
\Sigma=\mathrm{Cov}(X)=\mathbb E[(X-\mathbb E[X])(X-\mathbb E[X])^\top].
$$

### 3.6 条件分布与条件期望

离散情形：

$$
P(X=x\mid Y=y)=\frac{P(X=x,Y=y)}{P(Y=y)}.
$$

连续情形：

$$
f_{X\mid Y}(x\mid y)=\frac{f_{X,Y}(x,y)}{f_Y(y)}.
$$

条件期望：

$$
\mathbb E[X\mid Y=y]=
\begin{cases}
\sum_x xP(X=x\mid Y=y),\\
\int_{-\infty}^{+\infty}x f_{X\mid Y}(x\mid y)\,dx.
\end{cases}
$$

### 3.7 全期望公式

$$
\mathbb E[X]=\mathbb E[\mathbb E[X\mid Y]].
$$

若 $Y$ 离散，

$$
\mathbb E[X]=\sum_j \mathbb E[X\mid Y=y_j]P(Y=y_j).
$$

若 $Y$ 连续，

$$
\mathbb E[X]=\int_{-\infty}^{+\infty}\mathbb E[X\mid Y=y]f_Y(y)\,dy.
$$

## 4. 重要补充理解
- 教材很强调：期望存在不是“形式上能写和式/积分”就行，而是要满足绝对可和或绝对可积。
- 方差的本质不是平均大小，而是围绕均值的波动大小，所以平移不改变方差。
- 协方差与相关系数都只刻画线性关系，不是所有依赖关系。
- 条件期望最实用的意义是：先按已知信息分层求平均，再做加权总平均。

## 5. 本章最有价值的几个例子
- Pascal 分赌注：解释期望为什么像“公平平均收益”。
- 投资组合：解释方差、协方差、相关系数怎样共同决定风险。
- Poisson thinning：说明条件分布能帮我们推出新分布。
- 矿工三扇门：说明全期望公式特别适合解决递推型平均时间问题。
- 随机和的期望：

$$
\mathbb E\left[\sum_{i=1}^N X_i\right]=\mathbb E[X_1]\mathbb E[N].
$$

这条在应用题里很常见。

## 6. 使用建议
- 想快速冲刺考试时，优先看第 6、7 讲主讲总结。
- 做题时如果发现某个定义、证明或应用例子不够扎实，再回来翻这份教材补充。
- 这份补充最适合查“为什么这个公式能这么写”“这个结论在应用上是什么意思”。
