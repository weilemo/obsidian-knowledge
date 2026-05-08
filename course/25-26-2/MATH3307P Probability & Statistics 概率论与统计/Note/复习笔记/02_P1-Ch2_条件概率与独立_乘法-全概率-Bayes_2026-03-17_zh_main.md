# 02_P1-Ch2 条件概率与独立（知识点总结）

## 1. 本讲定位
- 课程框架位置：Part 1 的核心桥梁章节。
- 目标：把“信息更新”与“事件关联”形式化。

## 2. 关键公式

### 2.1 条件概率定义

$$
P(A\mid B)=\frac{P(A\cap B)}{P(B)},\quad P(B)>0
$$

### 2.2 乘法公式

$$
P(A\cap B)=P(B)P(A\mid B)=P(A)P(B\mid A)
$$

更一般地（链式法则）：

$$
P\!\left(\bigcap_{i=1}^{n}A_i\right)=P(A_1)\prod_{k=2}^{n}P\!\left(A_k\mid \bigcap_{j=1}^{k-1}A_j\right)
$$

### 2.3 全概率公式
若 $\{B_i\}$ 是样本空间划分，且 $P(B_i)>0$，则

$$
P(A)=\sum_i P(B_i)P(A\mid B_i)
$$

### 2.4 Bayes 公式

$$
P(B_j\mid A)=\frac{P(B_j)P(A\mid B_j)}{\sum_i P(B_i)P(A\mid B_i)}
$$

### 2.5 独立性判别

$$
A\perp B\iff P(A\cap B)=P(A)P(B)
$$

若 $P(B)>0$，等价于

$$
P(A\mid B)=P(A)
$$

## 3. 关键性质
- 对固定 $B$（且 $P(B)>0$），映射 $A\mapsto P(A\mid B)$ 本身是一个概率。
- 两两独立不一定推出相互独立。
- 相互独立要求任意子族交集概率都等于边际概率乘积。
- 独立性可与补事件联动：$A\perp B\Rightarrow A^c\perp B$ 等。

## 4. 重要证明

### 证明 1：$P(\cdot\mid B)$ 是概率测度
1) 非负性：

$$
P(A\mid B)=\frac{P(A\cap B)}{P(B)}\ge 0
$$

2) 规范性：

$$
P(\Omega\mid B)=\frac{P(\Omega\cap B)}{P(B)}=1
$$

3) 可列可加性：若 $A_i$ 两两不交，则 $(A_i\cap B)$ 也两两不交，故

$$
P\!\left(\bigcup_i A_i\mid B\right)
=\frac{P\!\left(\bigcup_i(A_i\cap B)\right)}{P(B)}
=\frac{\sum_i P(A_i\cap B)}{P(B)}
=\sum_i P(A_i\mid B)
$$

### 证明 2：全概率公式
若 $\Omega=\bigsqcup_i B_i$，则

$$
A=A\cap\Omega=A\cap\left(\bigsqcup_i B_i\right)=\bigsqcup_i (A\cap B_i)
$$

因此

$$
P(A)=\sum_i P(A\cap B_i)=\sum_i P(B_i)P(A\mid B_i)
$$

### 证明 3：Bayes 公式
由乘法公式：

$$
P(B_j\mid A)=\frac{P(B_j\cap A)}{P(A)}=\frac{P(B_j)P(A\mid B_j)}{P(A)}
$$

再用全概率公式替换分母：

$$
P(A)=\sum_i P(B_i)P(A\mid B_i)
$$

代入即得 Bayes 公式。

## 5. 易错点
- 不能把 $P(A\mid B)$ 和 $P(B\mid A)$ 混淆。
- 使用 Bayes 前先确认分母 $P(A)>0$。
- “两两独立”与“相互独立”是不同层级结论。
