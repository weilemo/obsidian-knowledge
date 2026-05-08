# 02_P1-Ch2 法语补充讲义（知识点总结）

## 1. 本讲补充定位
- 对主讲义 Chapter 2 的严格化补充。
- 强调：定义、公式推导逻辑、独立性的层级区分。

## 2. 关键公式（补充版）

### 2.1 条件概率

$$
P(A\mid B)=\frac{P(A\cap B)}{P(B)},\quad P(B)>0
$$

### 2.2 乘法公式（两事件与多事件）

$$
P(A\cap B)=P(A\mid B)P(B)
$$

$$
P\!\left(\bigcap_{k=1}^{n}A_k\right)=P(A_1)\prod_{k=2}^{n}P\!\left(A_k\mid \bigcap_{j=1}^{k-1}A_j\right)
$$

### 2.3 全概率与 Bayes

$$
P(A)=\sum_i P(B_i)P(A\mid B_i)
$$

$$
P(B_j\mid A)=\frac{P(B_j)P(A\mid B_j)}{\sum_i P(B_i)P(A\mid B_i)}
$$

## 3. 关键性质（法语稿强调点）
- 已知 $B$ 发生后，新的样本空间可以视作“缩减空间” $\Omega_B=B$。
- 条件概率是“在缩减空间内重新归一化”的概率。
- 独立的本质是“知道 $B$ 是否发生，不改变 $A$ 的概率”。

## 4. 重要证明（补充版）

### 证明 1：缩减空间解释与定义一致
在等可能有限样本空间中，若 $B$ 已发生，则只在 $B$ 内计数：

$$
P(A\mid B)=\frac{|A\cap B|}{|B|}
$$

将分子分母同除以 $|\Omega|$：

$$
P(A\mid B)=\frac{|A\cap B|/|\Omega|}{|B|/|\Omega|}=\frac{P(A\cap B)}{P(B)}
$$

故与一般定义一致。

### 证明 2：独立条件的等价
当 $P(B)>0$ 时，

$$
A\perp B
\iff P(A\cap B)=P(A)P(B)
\iff \frac{P(A\cap B)}{P(B)}=P(A)
\iff P(A\mid B)=P(A)
$$

### 证明 3：两两独立不推出相互独立（经典反例）
设独立抛两枚公平硬币，定义

$$
A=\{\text{第一枚正面}\},\quad B=\{\text{第二枚正面}\},\quad C=\{\text{两枚同面}\}
$$

可验证

$$
P(A\cap B)=P(A)P(B),\;P(A\cap C)=P(A)P(C),\;P(B\cap C)=P(B)P(C)
$$

即两两独立；但

$$
P(A\cap B\cap C)=\frac14\ne \frac18=P(A)P(B)P(C)
$$

故不相互独立。

## 5. 复习建议
- 先“画划分”再套全概率/Bayes，最不易错。
- 做题先判断是“前向概率”（全概率）还是“反推概率”（Bayes）。
