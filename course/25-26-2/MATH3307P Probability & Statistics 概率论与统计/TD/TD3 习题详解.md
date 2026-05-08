# TD3 习题详解（Probability, 2026-03-19）

题目来源：`/Users/moweile/Obsidian/Knowledge/Course/25-26-2/MATH3307P Probability & Statistics 概率论与统计/TD/TD3.pdf`
参考校对：`/Users/moweile/Obsidian/Knowledge/Course/25-26-2/MATH3307P Probability & Statistics 概率论与统计/TD/TD3_c.pdf`

说明：本笔记中凡用到公式，均补充来源/推导，不默认已知。

## 目录
- [Ex1 10 件中 3 件次品，已知两件里至少一件次品](#ex1-10-件中-3-件次品已知两件里至少一件次品)
- [Ex2 一般化版本（n 件中 m 件次品）](#ex2-一般化版本n-件中-m-件次品)
- [Ex3 条件概率（原题符号有疑似缺失）](#ex3-条件概率原题符号有疑似缺失)
- [Ex4 黑球增殖过程](#ex4-黑球增殖过程)
- [Ex5 两个 urne 转移后抽白球](#ex5-两个-urne-转移后抽白球)
- [Ex6 n 个 urne 链式转移](#ex6-n-个-urne-链式转移)
- [Ex7 先选箱再连续抽两件](#ex7-先选箱再连续抽两件)
- [Ex8 QCM 贝叶斯反推“是否会做”](#ex8-qcm-贝叶斯反推是否会做)
- [Ex9 m 人传球回到 A 的概率](#ex9-m-人传球回到-a-的概率)
- [Ex10 A/B 轮流掷骰谁在第 n 次掷](#ex10-ab-轮流掷骰谁在第-n-次掷)
- [Ex11 二状态天气链](#ex11-二状态天气链)
- [Ex12 白球先于黑球出现](#ex12-白球先于黑球出现)

---

## Ex1 10 件中 3 件次品，已知两件里至少一件次品
设事件：
- $D$：两件里至少一件次品
- $E$：另一件也次品（即两件都次品）

所求：$P(E\mid D)=\dfrac{P(E\cap D)}{P(D)}=\dfrac{P(E)}{P(D)}$。

用组合数（超几何思路）：
$$
P(E)=\frac{\binom{3}{2}}{\binom{10}{2}}=\frac{3}{45}=\frac{1}{15},
$$
$$
P(D)=1-P(\text{两件都好})=1-\frac{\binom{7}{2}}{\binom{10}{2}}=1-\frac{21}{45}=\frac{24}{45}=\frac{8}{15}.
$$
因此
$$
\boxed{P(E\mid D)=\frac{1/15}{8/15}=\frac18.}
$$

---

## Ex2 一般化版本（n 件中 m 件次品）
总共 $n$ 件，次品 $m$ 件，良品 $n-m$ 件。抽两件。

条件事件：至少一件是良品。目标事件：另一件也良品（即两件都良）。

$$
P(\text{两件都良})=\frac{\binom{n-m}{2}}{\binom{n}{2}},
$$
$$
P(\text{至少一件良})=1-P(\text{两件都次})=1-\frac{\binom{m}{2}}{\binom{n}{2}}.
$$

故
$$
P=\frac{\binom{n-m}{2}}{\binom{n}{2}-\binom{m}{2}}
=\frac{(n-m)(n-m-1)}{(n-m)(n+m-1)}
=\boxed{\frac{n-m-1}{n+m-1}}.
$$

---

## Ex3 条件概率（原题符号有疑似缺失）
`TD3_c` 给出的最终结果是 $0.25$。该题 PDF 文本抽取有缺失上划线现象（补事件符号可能丢失），这里按更正稿结论写为：
$$
\boxed{P=0.25.}
$$

如果你愿意，我可以在你上传 Ex3 清晰截图后把这一题改成“完全按原题符号重写”的版本。

---

## Ex4 黑球增殖过程
初始：1 白 1 黑。若抽到黑，就放回并再加 1 黑；抽到白则停止。

设 $A_i$：第 $i$ 次抽到黑。

### (1) 第 $n$ 次时仍未结束
等价于前 $n$ 次全黑：
$$
P(A_1\cdots A_n)=\frac12\cdot\frac23\cdot\frac34\cdots\frac{n}{n+1}
=\boxed{\frac{1}{n+1}}.
$$

### (2) 恰好第 $n$ 次结束
等价于前 $n-1$ 次黑，第 $n$ 次白：
$$
\left(\frac12\cdot\frac23\cdots\frac{n-1}{n}\right)\cdot\frac{1}{n+1}
=\frac{1}{n}\cdot\frac{1}{n+1}
=\boxed{\frac{1}{n(n+1)}}.
$$

---

## Ex5 两个 urne 转移后抽白球
Urne A：$a$ 白 $b$ 黑；Urne B：$n$ 白 $m$ 黑。

记 $C$：最终从 B 抽到白。

### (1) 先转移 1 球（A→B），再从 B 抽 1 球
全概率：
$$
P(C)=\frac{a}{a+b}\cdot\frac{n+1}{n+m+1}
+\frac{b}{a+b}\cdot\frac{n}{n+m+1}.
$$

即
$$
\boxed{P(C)=\frac{a(n+1)+bn}{(a+b)(n+m+1)}}.
$$

### (2) 先转移 2 球（A→B），再从 B 抽 1 球
按“转移两球中白球数”分类（0,1,2）：
$$
P(C)=\frac{\binom{a}{2}}{\binom{a+b}{2}}\cdot\frac{n+2}{n+m+2}
+\frac{\binom{a}{1}\binom{b}{1}}{\binom{a+b}{2}}\cdot\frac{n+1}{n+m+2}
+\frac{\binom{b}{2}}{\binom{a+b}{2}}\cdot\frac{n}{n+m+2}.
$$

---

## Ex6 n 个 urne 链式转移
有 $n$ 个 urne，每个初始都 $a$ 白 $b$ 黑。依次把第 $i$ 个 urne 抽出的球放入第 $i+1$ 个，最后从第 $n$ 个抽一球，求白球概率。

设 $p_i$ 为“从第 $i$ 个 urne 抽到白”的概率。

显然 $p_1=\dfrac{a}{a+b}$。

由 Ex5(1) 的一球转移公式：
$$
p_i=p_{i-1}\cdot\frac{a+1}{a+b+1}+(1-p_{i-1})\cdot\frac{a}{a+b+1}
=\frac{a+p_{i-1}}{a+b+1}.
$$

若 $p_{i-1}=\dfrac{a}{a+b}$，则
$$
p_i=\frac{a+\frac{a}{a+b}}{a+b+1}=\frac{a}{a+b}.
$$
归纳得
$$
\boxed{p_n=\frac{a}{a+b}}.
$$

---

## Ex7 先选箱再连续抽两件
箱 1：50 件里 20 件优品；箱 2：30 件里 18 件优品。先等概率选箱，再无放回抽两件。

设 $Q_1,Q_2$ 表示选中箱 1/2，$A_1,A_2$ 表示第 1/2 件是优品。

### (1) 第一件优品概率
$$
P(A_1)=\frac12\cdot\frac{20}{50}+\frac12\cdot\frac{18}{30}=\boxed{0.5}.
$$

### (2) 已知第一件优品，第二件也优品
$$
P(A_2\mid A_1)=\frac{P(A_1\cap A_2)}{P(A_1)}.
$$
其中
$$
P(A_1\cap A_2)=\frac12\cdot\frac{20}{50}\cdot\frac{19}{49}
+\frac12\cdot\frac{18}{30}\cdot\frac{17}{29}\approx 0.253413.
$$
故
$$
\boxed{P(A_2\mid A_1)\approx 0.5068}.
$$

---

## Ex8 QCM 贝叶斯反推“是否会做”
设
- $K$：会做
- $C$：答对

已知：$P(C\mid K)=1$，若不会做则 4 选 1 猜中，$P(C\mid K^c)=1/4$。

目标：$P(K\mid C)$，用贝叶斯：
$$
P(K\mid C)=\frac{P(K)P(C\mid K)}{P(K)P(C\mid K)+P(K^c)P(C\mid K^c)}.
$$

### (1) $P(K)=0.5$
$$
P(K\mid C)=\frac{0.5}{0.5+0.5\cdot 0.25}=\boxed{0.8}.
$$

### (2) $P(K)=0.2$
$$
P(K\mid C)=\frac{0.2}{0.2+0.8\cdot 0.25}=\boxed{0.5}.
$$

---

## Ex9 m 人传球回到 A 的概率
初始球在 A。每次传给其余 $m-1$ 人中随机一人。

设 $p_n$：第 $n$ 次传球时球在 A 的概率（$p_1=1$）。

递推：
$$
p_n=P(\text{上一步不在 A})\cdot\frac{1}{m-1}
=\frac{1-p_{n-1}}{m-1},\quad n\ge2.
$$

令平衡点 $p_*=1/m$，再设 $q_n=p_n-p_*$，得
$$
q_n=-\frac{1}{m-1}q_{n-1}.
$$

解得
$$
\boxed{p_n=\frac1m+\frac{m-1}{m}\left(-\frac1{m-1}\right)^{n-1}}.
$$
且 $n\to\infty$ 时 $p_n\to 1/m$。

---

## Ex10 A/B 轮流掷骰谁在第 n 次掷
A 先掷。若当前人掷出 1 则换人，否则继续由同一人掷。

设 $p_n=P(\text{第 }n\text{ 次由 A 掷})$，$p_1=1$。

有
$$
p_n=\frac56p_{n-1}+\frac16(1-p_{n-1})=\frac23p_{n-1}+\frac16.
$$

令 $q_n=p_n-1/2$，则
$$
q_n=\frac23 q_{n-1},\quad q_1=\frac12.
$$

因此
$$
\boxed{p_n=\frac12\left(1+\left(\frac23\right)^{n-1}\right)}.
$$

---

## Ex11 二状态天气链
状态：雨/不雨。若知道今天，明天“同状态”概率 $p$，“切换”概率 $1-p$。第 1 天不下雨。

设 $p_n=P(\text{第 }n\text{ 天不下雨})$，$p_1=1$。

递推：
$$
p_n=p\,p_{n-1}+(1-p)(1-p_{n-1})=(2p-1)p_{n-1}+1-p.
$$

平衡点是 $1/2$。令 $q_n=p_n-1/2$，得
$$
q_n=(2p-1)q_{n-1},\quad q_1=1/2.
$$

故
$$
\boxed{p_n=\frac12\left(1+(2p-1)^{n-1}\right)}.
$$

---

## Ex12 白球先于黑球出现
Urne 含 $a$ 白、$b$ 黑、$n$ 红。无放回抽取。求“白先于黑出现”的概率。

### 核心思路（红球可忽略）
只看白黑顺序：红球只会“插空”，不会改变“第一颗非红球是白还是黑”。

把所有白黑球打乱后，第一颗出现的非红球在白黑总数 $a+b$ 中等可能落在任一球位；它是白的概率就是
$$
\boxed{\frac{a}{a+b}}.
$$
与红球数 $n$ 无关。

