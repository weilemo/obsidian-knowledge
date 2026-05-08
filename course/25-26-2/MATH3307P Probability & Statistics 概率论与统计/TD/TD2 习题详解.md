# TD2 习题详解（Probability, 2026-03-12）

题目来源：`/Users/moweile/Obsidian/Knowledge/Course/25-26-2/MATH3307P Probability & Statistics 概率论与统计/TD/TD2.pdf`

说明：本笔记中凡用到公式，均补充“来源/推导/适用条件”，不默认读者已知。

## 目录
- [Exercice 1 事件表达与集合运算](#exercice-1-事件表达与集合运算)
- [Exercice 2 交集概率的最大最小值](#exercice-2-交集概率的最大最小值)
- [Exercice 3（符号可能缺失的题）](#exercice-3符号可能缺失的题)
- [Exercice 4 Jordan 公式（容斥）](#exercice-4-jordan-公式容斥)
- [Exercice 5 乘客随机上车（占盒问题）](#exercice-5-乘客随机上车占盒问题)
- [Exercice 6 信封错装（错排）](#exercice-6-信封错装错排)
- [Exercice 7 鞋子抽样无完整对子](#exercice-7-鞋子抽样无完整对子)
- [Exercice 8 两个不等式与推广](#exercice-8-两个不等式与推广)
- [Exercice 9 选 3 个不同数字](#exercice-9-选-3-个不同数字)
- [Exercice 10 三报订阅概率](#exercice-10-三报订阅概率)
- [Exercice 11 两种彩票直觉比较](#exercice-11-两种彩票直觉比较)

---

## Exercice 1 事件表达与集合运算
设事件为 $A,B,C,D$。

### 1) 用集合表达事件
(a) 至少一个事件发生：
$$
A\cup B\cup C\cup D.
$$

(b) 恰好一个发生：
$$
(A\cap B^c\cap C^c\cap D^c)\cup(A^c\cap B\cap C^c\cap D^c)\cup(A^c\cap B^c\cap C\cap D^c)\cup(A^c\cap B^c\cap C^c\cap D).
$$

(c) 至多一个发生：
“一个也不发生”或“恰好一个发生”
$$
A^c\cap B^c\cap C^c\cap D^c\;\cup\;\text{(b)}.
$$

(d) 至少一个不发生：
$$
(A\cap B\cap C\cap D)^c=A^c\cup B^c\cup C^c\cup D^c.
$$

### 2) 化简集合表达式
(a) $(A\cup B)\cup(A\cup B)=A\cup B$（幂等律）

(b) $(A\cup B)\cap(B\cup C)$：
用分配律
$$
(A\cup B)\cap(B\cup C)=[A\cap(B\cup C)]\cup[B\cap(B\cup C)]
=(A\cap B)\cup(A\cap C)\cup B
=B\cup(A\cap C).
$$

(c) $(A\cup B)\cap(B\cup A)\cap(A\cup B)=A\cup B$（同式重复）

### 3) 证明等式
以下都用集合代数恒等式完成：

(a) $(A\cup B)\setminus B=A\cap B^c$。而
$$
A\setminus(A\cap B)=A\cap(A\cap B)^c=A\cap(A^c\cup B^c)=A\cap B^c.
$$
两边相等。

(b) $(A\cup B)\setminus(A\cap B)$：
$$
(A\cup B)\cap(A\cap B)^c=(A\cup B)\cap(A^c\cup B^c)
=(A\cap B^c)\cup(A^c\cap B).
$$
这是对称差。若题面出现上划线缺失，请核对原题是否为
$$(A\cap B^c)\cup(A^c\cap B).$$

(c) $A\setminus(B\cap C)$：
$$
A\cap(B\cap C)^c=A\cap(B^c\cup C^c)=(A\cap B^c)\cup(A\cap C^c)=(A\setminus B)\cup(A\setminus C).
$$

(d) $A\setminus(B\cup C)$：
$$
A\cap(B\cup C)^c=A\cap(B^c\cap C^c)=(A\cap B^c)\cap C^c=(A\setminus B)\setminus C.
$$

---

## Exercice 2 交集概率的最大最小值
已知 $P(A)=0.6,\ P(B)=0.8$。

### 公式来源
由并集公式
$$
P(A\cup B)=P(A)+P(B)-P(A\cap B),
$$
且 $0\le P(A\cup B)\le 1$，得到
$$
P(A)+P(B)-1\le P(A\cap B)\le \min\{P(A),P(B)\}.
$$

### 代入数值
最小值：
$$
P(A\cap B)_{\min}=0.6+0.8-1=0.4.
$$
条件：$P(A\cup B)=1$（即 $A\cup B=\Omega$，两事件尽量“分散”）。

最大值：
$$
P(A\cap B)_{\max}=\min(0.6,0.8)=0.6.
$$
条件：较小事件包含于较大事件（$A\subseteq B$）。

---

## Exercice 3（符号可能缺失的题）
原文抽取为：
“On suppose que $P(AB)=P(A\cap B)$. Sachant $P(A)=p$, trouver $P(B)$.”

PDF 抽取可能丢失上划线或符号，常见的 3 种解释如下。请对照你 PDF 的原图选择对应答案。

### 解释 1：若题意是 $P(A\cap B)=P(A)P(B)$（独立）
则
$$
P(A\cap B)=p\,P(B).
$$
只给了 $P(A)=p$，无法唯一确定 $P(B)$，$P(B)$ 可为任意 $[0,1]$。独立性只给出乘法关系，不给数值。

### 解释 2：若题意是 $P(A^c\cap B)=P(A\cap B)$
则
$$
P(B)=P(A\cap B)+P(A^c\cap B)=2P(A\cap B).
$$
仍不足以唯一确定 $P(B)$，除非额外给出 $P(A\cap B)$ 或独立性等条件。

### 解释 3：若题意是 $P(A\cup B)=P(A\cap B)$
由
$$
P(A\cup B)=P(A)+P(B)-P(A\cap B),
$$
得到
$$
P(B)=2P(A\cap B)-p,
$$
仍需 $P(A\cap B)$ 才能确定。

如你能给我 Ex3 的清晰截图，我会把这一题改成唯一解版本。

---

## Exercice 4 Jordan 公式（容斥）
目标：证明
$$
P\left(\bigcup_{i=1}^n A_i\right)=S_1-S_2+S_3-\cdots+(-1)^{n-1}S_n.
$$

### 推导（指示函数法）
对任意样本点 $\omega$，定义指示函数 $\mathbf{1}_{A_i}(\omega)$。
有恒等式：
$$
\mathbf{1}_{\cup A_i}=\sum_i \mathbf{1}_{A_i}-\sum_{i<j}\mathbf{1}_{A_i\cap A_j}+\sum_{i<j<k}\mathbf{1}_{A_i\cap A_j\cap A_k}-\cdots+(-1)^{n-1}\mathbf{1}_{\cap A_i}.
$$
理由：若 $\omega$ 落在恰好 $m$ 个事件中，则右侧数值为
$$
\binom{m}{1}-\binom{m}{2}+\cdots+(-1)^{m-1}\binom{m}{m}=1.
$$
取期望即得所需公式。

---

## Exercice 5 乘客随机上车（占盒问题）
有 $k$ 个乘客独立等概率选择 $n$ 个车厢。问每个车厢至少 1 人的概率。

### 样本空间
每个乘客有 $n$ 种选择，总样本数 $n^k$。

### 容斥推导
设 $E_i$ 为“第 $i$ 节车厢为空”。
所求为 $P(\cap_i E_i^c)=1-P(\cup_i E_i)$。

容斥：
$$
P(\cup_i E_i)=\sum_{j=1}^n (-1)^{j+1}\binom{n}{j}\left(\frac{n-j}{n}\right)^k.
$$
因此
$$
\boxed{
P(\text{每厢至少 1 人})=
\sum_{j=0}^n (-1)^j\binom{n}{j}\left(\frac{n-j}{n}\right)^k
}
$$
（其中 $j=0$ 项为 1）。

### 补充：容斥公式为什么是这样
对任意固定的 $j$ 个车厢为空（比如选出一组大小为 $j$ 的车厢集合），剩下可选车厢数是 $n-j$，每位乘客有 $n-j$ 种选择，总数 $(n-j)^k$。  
有 $\binom{n}{j}$ 种方式选出这 $j$ 个空车厢。  
容斥的符号 $(-1)^j$ 来自“加上单空、减去双空、再加回三空...”的修正。  
因此“至少一个空车厢”的概率为
$$
\frac{1}{n^k}\sum_{j=1}^n (-1)^{j+1}\binom{n}{j}(n-j)^k,
$$
所以“每厢至少 1 人”的概率就是
$$
\frac{1}{n^k}\sum_{j=0}^n (-1)^j\binom{n}{j}(n-j)^k.
$$

### 等价计数式为什么成立（与第二类斯特林数）
把“每个车厢至少 1 人”看成“从 $k$ 个乘客到 $n$ 个车厢的满射”。  
满射的计数可以分两步：  
1. 先把 $k$ 个乘客划分成 $n$ 个非空组（每组将去同一个车厢），分法数是第二类斯特林数 $S(k,n)$；  
2. 再把这 $n$ 个组分配到 $n$ 个有标签车厢，方式数是 $n!$。

所以满足条件的分配数为 $n!\,S(k,n)$，概率为
$$
\boxed{\frac{n!\,S(k,n)}{n^k}}.
$$

这和容斥式是同一个数。下面给出第二类斯特林数的容斥公式推导。

### 补充：第二类斯特林数公式推导
**定义**：$S(k,n)$ 表示把 $k$ 个不同元素划分成 $n$ 个**非空且无序**子集的数量。  
我们先数**满射** $f:[k]\\to[n]$ 的数量，再除以 $n!$（因为子集无序）。

#### 第一步：数满射的数量
总函数数目：$n^k$。  
设 $E_i$ 为“第 $i$ 个盒子为空”，则“不是满射”即 $\\cup_{i=1}^n E_i$。  
用容斥：
$$
\\#\\{\\text{满射}\\}=\\sum_{j=0}^n (-1)^j \\binom{n}{j}(n-j)^k.
$$
说明：选出 $j$ 个空盒后，剩余可用盒子是 $n-j$，函数数是 $(n-j)^k$。

#### 第二步：除以 $n!$
每个划分对应 $n!$ 个满射（给 $n$ 个子集贴上标签 $1,\\dots,n$）。因此
$$
S(k,n)=\\frac{1}{n!}\\sum_{j=0}^n (-1)^j \\binom{n}{j}(n-j)^k.
$$

#### 常见等价形式
把求和换元 $j\\leftarrow n-j$：
$$
S(k,n)=\\frac{1}{n!}\\sum_{j=0}^n (-1)^{n-j}\\binom{n}{j} j^k.
$$
这就是常见的“斯特林公式（容斥形式）”。 
$$
S(k,n)=\frac{1}{n!}\sum_{j=0}^n(-1)^{n-j}\binom{n}{j}j^k,
$$
把 $j^k$ 改写为 $(n-(n-j))^k$ 后即可化成上面的容斥表达式。

---

## Exercice 6 信封错装（错排）
把 $n$ 封信随机放入 $n$ 个信封（排列等可能）。
设 $A_i$ 为“第 $i$ 封信在正确信封”。

### 1) 至少一封正确
$$
P(\text{至少一封})=1-P(\text{全错}).
$$

### 2) 全错（错排）
容斥：
$$
\#(\text{全错})=n!-\binom{n}{1}(n-1)!+\binom{n}{2}(n-2)!-\cdots+(-1)^n\binom{n}{n}0!.
$$
所以
$$
\boxed{\frac{!n}{n!}=\sum_{j=0}^n\frac{(-1)^j}{j!}}
$$
其中 $!n$ 为错排数。

### 3) 恰好 $k$ 封正确
先选出正确的 $k$ 封：$\binom{n}{k}$，其余 $n-k$ 封全错：$!(n-k)$。

$$
\boxed{
P(\text{恰好 }k\text{ 封})=\frac{\binom{n}{k}!(n-k)}{n!}
}
$$

---

## Exercice 7 鞋子抽样无完整对子
共有 $n$ 双鞋（共 $2n$ 只），随机取 $2r$ 只（$2r\le n$）。求“不出现完整一双”。

### 计数
- 先选出 $2r$ 个“鞋对”（从 $n$ 双中选）：$\binom{n}{2r}$。
- 每双鞋里选 1 只：$2^{2r}$。

总样本数：$\binom{2n}{2r}$。

$$
\boxed{
P=\frac{\binom{n}{2r}2^{2r}}{\binom{2n}{2r}}
}
$$

---

## Exercice 8 两个不等式与推广
### 1) $P(A\cap B)\ge 1-P(A)-P(B)$
更标准写法是
$$
P(A\cap B)\ge P(A)+P(B)-1.
$$

推导：
$$
P(A\cap B)=1-P(A^c\cup B^c)\ge 1-[P(A^c)+P(B^c)]
=P(A)+P(B)-1.
$$
这里用到**并集上界**（Boole 不等式）
$$
P(\cup_i E_i)\le\sum_i P(E_i).
$$

### 2) $P\left(\cap_{i=1}^\infty A_i\right)\ge 1-\sum_{i=1}^\infty P(A_i^c)$
用补集与并集上界：
$$
P\left(\cap_i A_i\right)=1-P\left(\cup_i A_i^c\right)
\ge 1-\sum_i P(A_i^c).
$$

---

## Exercice 9 选 3 个不同数字
样本空间：从 $\{0,1,\dots,9\}$ 中选 3 个不同数字，
$$
\#\Omega=\binom{10}{3}.
$$

1) $A_1$：不含 0 和 5
$$
\#=\binom{8}{3}\quad\Rightarrow\quad P(A_1)=\frac{\binom{8}{3}}{\binom{10}{3}}.
$$

2) $A_2$：不含 0 或不含 5
这是“不是同时含 0 和 5”。
同时含 0 和 5 时第三个数字可从剩余 8 个里选：$8$ 种。
$$
P(A_2)=1-\frac{8}{\binom{10}{3}}.
$$

3) $A_3$：含 0 且不含 5
选定 0，排除 5，其余 2 个从 8 个里选：
$$
P(A_3)=\frac{\binom{8}{2}}{\binom{10}{3}}.
$$

---

## Exercice 10 三报订阅概率
给定：
$$
P(A)=0.25,\ P(B)=0.20,\ P(C)=0.15,
$$
$$
P(AB)=0.10,\ P(AC)=0.08,\ P(BC)=0.05,
$$
$$
P(ABC)=0.03.
$$

### 1) 只订 A
$$
P(A\text{ only})=P(A)-P(AB)-P(AC)+P(ABC)=0.10.
$$

### 2) 只订一个
先算只订 B、只订 C：
$$
P(B\text{ only})=0.20-0.10-0.05+0.03=0.08,
$$
$$
P(C\text{ only})=0.15-0.08-0.05+0.03=0.05.
$$
因此
$$
P(\text{只订一个})=0.10+0.08+0.05=0.23.
$$

### 3) 至少订一个
容斥：
$$
P(A\cup B\cup C)=0.25+0.20+0.15-0.10-0.08-0.05+0.03=0.40.
$$

### 4) 一个都不订
$$
P(\text{无订阅})=1-0.40=0.60.
$$

---

## Exercice 11 两种彩票直觉比较
比较：
1) 扔 1 个骰子 4 次，至少出现一次 6。
2) 扔 2 个骰子 24 次，至少出现一次“双 6”。

### 计算
1) 单次出 6 的概率 $1/6$。
$$
P_1=1-\left(\frac56\right)^4\approx 0.5177.
$$

2) 单次出“双 6”的概率 $1/36$。
$$
P_2=1-\left(\frac{35}{36}\right)^{24}\approx 0.4914.
$$

结论：
$$
P_1>P_2,
$$
所以玩家的判断是错误的。
