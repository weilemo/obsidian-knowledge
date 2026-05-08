# TD9 习题详解

> 课程：MATH3307P Probability & Statistics  
> 主题：协方差、相关系数、二元正态、不相关与独立、投资组合最小方差

---

## Exercice 1
已知联合密度
$$
p_{X,Y}(x,y)=3x,\quad 0<y<x<1,
$$
求 $\mathrm{Cov}(X,Y)$。

### 1) 先验检查：密度定义良好
密度函数需满足：
1. 非负；
2. 在定义域上积分为 $1$。

这里 $3x\ge 0$，且
$$
\iint p_{X,Y}(x,y)\,dxdy=\int_0^1\int_0^x 3x\,dy\,dx
=\int_0^1 3x^2\,dx=1.
$$
所以定义良好。

### 2) 用协方差定义
$$
\mathrm{Cov}(X,Y)=\mathbb E[XY]-\mathbb E[X]\mathbb E[Y].
$$

先算边缘密度：
$$
p_X(x)=\int_0^x 3x\,dy=3x^2,\quad 0<x<1,
$$
$$
p_Y(y)=\int_y^1 3x\,dx=\frac32(1-y^2),\quad 0<y<1.
$$

于是
$$
\mathbb E[X]=\int_0^1 x\,3x^2dx=\frac34,
$$
$$
\mathbb E[Y]=\int_0^1 y\cdot\frac32(1-y^2)dy=\frac38,
$$
$$
\mathbb E[XY]=\int_0^1\int_0^x xy\cdot 3x\,dy\,dx
=\int_0^1 \frac32x^4dx=\frac3{10}.
$$

所以
$$
\mathrm{Cov}(X,Y)=\frac3{10}-\frac34\cdot\frac38
=\frac3{160}.
$$

**结论：**
$$
\boxed{\mathrm{Cov}(X,Y)=\frac3{160}}.
$$

---

## Exercice 2
已知
$$
p_{X,Y}(x,y)=\frac13(x+y),\quad 0<x<1,\ 0<y<2,
$$
求 $\mathrm{Var}(2X-3Y+8)$。

### 1) 公式来源
对常数线性组合，方差公式为
$$
\mathrm{Var}(aX+bY+c)=a^2\mathrm{Var}(X)+b^2\mathrm{Var}(Y)+2ab\,\mathrm{Cov}(X,Y).
$$
这里 $a=2,b=-3$，所以
$$
\mathrm{Var}(2X-3Y+8)=4\mathrm{Var}(X)+9\mathrm{Var}(Y)-12\mathrm{Cov}(X,Y).
$$

### 2) 计算所需矩
边缘密度：
$$
p_X(x)=\int_0^2\frac13(x+y)dy=\frac23(x+1),\quad 0<x<1,
$$
$$
p_Y(y)=\int_0^1\frac13(x+y)dx=\frac16+\frac y3,\quad 0<y<2.
$$

$$
\mathbb E[X]=\int_0^1 x\cdot\frac23(x+1)dx=\frac59,
\quad
\mathbb E[X^2]=\int_0^1 x^2\cdot\frac23(x+1)dx=\frac{11}{36},
$$
$$
\mathrm{Var}(X)=\frac{11}{36}-\left(\frac59\right)^2=\frac{19}{324}.
$$

$$
\mathbb E[Y]=\int_0^2 y\left(\frac16+\frac y3\right)dy=\frac{11}{9},
\quad
\mathbb E[Y^2]=\int_0^2 y^2\left(\frac16+\frac y3\right)dy=\frac53,
$$
$$
\mathrm{Var}(Y)=\frac53-\left(\frac{11}{9}\right)^2=\frac{14}{81}.
$$

$$
\mathbb E[XY]=\int_0^1\int_0^2 xy\cdot\frac13(x+y)dydx=\frac34,
$$
$$
\mathrm{Cov}(X,Y)=\mathbb E[XY]-\mathbb E[X]\mathbb E[Y]
=\frac34-\frac59\cdot\frac{11}{9}=\frac{23}{324}.
$$

### 3) 代回方差公式
$$
\mathrm{Var}(2X-3Y+8)=4\cdot\frac{19}{324}+9\cdot\frac{14}{81}-12\cdot\frac{23}{324}
=\frac{43}{27}.
$$

**结论：**
$$
\boxed{\mathrm{Var}(2X-3Y+8)=\frac{43}{27}}.
$$

---

## Exercice 3
已知
$$
p_{X,Y}(x,y)=\frac83,\quad 0<x<1,\ 0<y<1,\ 0<x-y<\frac12,
$$
求 $\mathrm{Corr}(X,Y)$。

### 1) 几何区域与分段
条件 $0<x-y<\frac12$ 等价于
$$
y<x<y+\frac12,
$$
再与 $0<x<1,0<y<1$ 叠加：
- 当 $0<x<\frac12$，有 $0<y<x$；
- 当 $\frac12<x<1$，有 $x-\frac12<y<x$。

### 2) 先求均值与二阶矩
$$
\mathbb E[X]=\frac83\left(\int_0^{1/2}\int_0^x x\,dydx+\int_{1/2}^1\int_{x-1/2}^x x\,dydx\right)=\frac{11}{18}.
$$

$$
\mathbb E[Y]=\frac83\left(\int_0^{1/2}\int_0^x y\,dydx+\int_{1/2}^1\int_{x-1/2}^x y\,dydx\right)=\frac{7}{18}.
$$

$$
\mathbb E[X^2]=\frac83\left(\int_0^{1/2}\int_0^x x^2\,dydx+\int_{1/2}^1\int_{x-1/2}^x x^2\,dydx\right)=\frac{31}{72}.
$$

$$
\mathbb E[Y^2]=\frac83\left(\int_0^{1/2}\int_0^x y^2\,dydx+\int_{1/2}^1\int_{x-1/2}^x y^2\,dydx\right)=\frac{17}{72}.
$$

$$
\mathbb E[XY]=\frac83\left(\int_0^{1/2}\int_0^x xy\,dydx+\int_{1/2}^1\int_{x-1/2}^x xy\,dydx\right)=\frac14.
$$

因此
$$
\mathrm{Var}(X)=\frac{31}{72}-\left(\frac{11}{18}\right)^2=\frac{37}{648},
\quad
\mathrm{Var}(Y)=\frac{17}{72}-\left(\frac7{18}\right)^2=\frac{55}{648},
$$
$$
\mathrm{Cov}(X,Y)=\frac14-\frac{11}{18}\cdot\frac7{18}=-\frac1{324}.
$$

### 3) 相关系数
$$
\mathrm{Corr}(X,Y)=\frac{\mathrm{Cov}(X,Y)}{\sqrt{\mathrm{Var}(X)\mathrm{Var}(Y)}}
=\frac{-1/324}{\sqrt{(37/648)(55/648)}}
=-\frac{2}{\sqrt{2035}}\approx -0.0443.
$$

**结论：**
$$
\boxed{\mathrm{Corr}(X,Y)=-\frac{2}{\sqrt{2035}}\approx -0.0443}.
$$

---

## Exercice 4
题目结论：二维正态
$$
(X,Y)\sim\mathcal N(\mu_1,\mu_2,\sigma_1^2,\sigma_2^2,\rho)
$$
中的参数 $\rho$ 正是相关系数，即
$$
\rho=\mathrm{Corr}(X,Y)=\frac{\mathrm{Cov}(X,Y)}{\sigma_1\sigma_2}.
$$

这是二维正态分布参数化定义的一部分。

---

## Exercice 5
证明：二维正态下，“不相关”和“独立”等价。

### 1) 独立 $\Rightarrow$ 不相关
一般随机变量都成立：若 $X,Y$ 独立，则
$$
\mathbb E[XY]=\mathbb E[X]\mathbb E[Y]\Rightarrow \mathrm{Cov}(X,Y)=0.
$$

### 2) 不相关 $\Rightarrow$ 独立（仅对二维正态成立）
二维正态联合密度中交叉项与 $\rho$ 对应。若不相关，则
$$
\mathrm{Cov}(X,Y)=0 \Rightarrow \rho=0.
$$
此时联合密度可分解为两个一维正态密度乘积：
$$
f_{X,Y}(x,y)=f_X(x)f_Y(y),
$$
故 $X,Y$ 独立。

**结论：**二维正态中
$$
\boxed{X\perp Y\ \Longleftrightarrow\ \mathrm{Cov}(X,Y)=0\ \Longleftrightarrow\ \mathrm{Corr}(X,Y)=0.}
$$

---

## Exercice 6：独立与相关的反例

### 6.1 取 $X\sim\mathcal N(0,1)$，$Y=X^2$
> 题面“loi uniforme centrée réduite”与 $X\sim\mathcal N(0,1)$ 有文字冲突，按给出的分布式子采用标准正态。

$$
\mathrm{Cov}(X,Y)=\mathrm{Cov}(X,X^2)=\mathbb E[X^3]-\mathbb E[X]\mathbb E[X^2].
$$
对标准正态，$\mathbb E[X]=0$，奇次矩 $\mathbb E[X^3]=0$，故
$$
\mathrm{Cov}(X,Y)=0.
$$
但 $Y$ 是 $X$ 的确定函数（$Y=X^2$），若独立则条件分布应不变，这里显然不成立（例如知道 $X=0$ 就知道 $Y=0$）。

所以：不相关，但不独立。

### 6.2 $(X,Y)$ 在单位圆盘上均匀
联合密度
$$
f_{X,Y}(x,y)=\frac1\pi,\quad x^2+y^2\le1.
$$
由对称性：
$$
\mathbb E[X]=\mathbb E[Y]=0,
$$
且被积函数 $xy$ 关于 $x\mapsto -x$ 或 $y\mapsto -y$ 是奇对称，故
$$
\mathbb E[XY]=0\Rightarrow \mathrm{Cov}(X,Y)=0.
$$

但不独立：若独立，支持集应接近矩形乘积；这里支持集是圆盘，且给定 $X=x$ 后 $Y$ 只能落在
$$
-\sqrt{1-x^2}\le Y\le \sqrt{1-x^2}
$$
内，明显依赖 $x$。

所以：也是不相关但不独立。

---

## Exercice 7：两资产组合最小方差
设投资权重为 $(x_1,x_2)$，且 $x_2=1-x_1$。资产收益分别为 $X,Y$。

### 1) 组合收益
$$
R=x_1X+x_2Y=x_1X+(1-x_1)Y.
$$

### 2) 组合期望
由期望线性性：
$$
\mathbb E[R]=x_1\mu_1+(1-x_1)\mu_2.
$$

### 3) 组合风险（方差）
由二元线性组合方差公式：
$$
\mathrm{Var}(R)=x_1^2\sigma_1^2+(1-x_1)^2\sigma_2^2+2x_1(1-x_1)\mathrm{Cov}(X,Y),
$$
又
$$
\mathrm{Cov}(X,Y)=\rho\sigma_1\sigma_2,
$$
故
$$
\mathrm{Var}(R)=x_1^2\sigma_1^2+(1-x_1)^2\sigma_2^2+2x_1(1-x_1)\rho\sigma_1\sigma_2.
$$

### 4) 最小方差权重
令
$$
V(x_1)=\mathrm{Var}(R).
$$
对 $x_1$ 求导并令 0：
$$
V'(x_1)=2x_1\sigma_1^2-2(1-x_1)\sigma_2^2+2(1-2x_1)\rho\sigma_1\sigma_2=0.
$$
解得
$$
\boxed{
x_1^*=\frac{\sigma_2^2-\rho\sigma_1\sigma_2}{\sigma_1^2+\sigma_2^2-2\rho\sigma_1\sigma_2}
},
\quad
x_2^*=1-x_1^*=\frac{\sigma_1^2-\rho\sigma_1\sigma_2}{\sigma_1^2+\sigma_2^2-2\rho\sigma_1\sigma_2}.
$$

二阶导
$$
V''(x_1)=2\bigl(\sigma_1^2+\sigma_2^2-2\rho\sigma_1\sigma_2\bigr)=2\mathrm{Var}(X-Y)\ge0,
$$
故该点为最小值点（退化情形除外）。

---

## 本次 TD9 核心结论汇总
$$
\mathrm{Cov}(X,Y)=\mathbb E[XY]-\mathbb E[X]\mathbb E[Y],
$$
$$
\mathrm{Var}(aX+bY+c)=a^2\mathrm{Var}(X)+b^2\mathrm{Var}(Y)+2ab\,\mathrm{Cov}(X,Y),
$$
$$
\mathrm{Corr}(X,Y)=\frac{\mathrm{Cov}(X,Y)}{\sqrt{\mathrm{Var}(X)\mathrm{Var}(Y)}},
$$
$$
\text{二维正态下： }\mathrm{Cov}(X,Y)=0\iff X\perp Y.
$$
