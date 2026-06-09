# L17 Combinational Logic 讲义

来源：[[../Slides/L17 Combinational Logic.pdf]]

配套官方 notes：[[../Notes/L17 Combinational Logic - official notes.html]]

## 0. 本讲目标

上一讲 L16 建立了 synchronous digital system 的基本框架：

```text
SDS = combinational logic + state elements + clock
```

这一讲专门展开 combinational logic。组合逻辑的核心性质是：

```text
output depends only on current inputs
```

可以写成数学函数：

$$
y = f(x_1, x_2, \ldots, x_n)
$$

本讲要掌握：

1. 如何从 gate diagram 写出 truth table。
2. majority circuit 是什么。
3. Boolean algebra 为什么能描述和化简电路。
4. 常用 Boolean algebra laws。
5. 如何验证两个电路等价。
6. 如何用 sum-of-products 从 truth table 设计电路。
7. 为什么复杂电路要模块化，例如 32-bit equality compare。

## 1. 三种表示：Truth Table、Gate Diagram、Boolean Expression

一个 combinational logic block 可以用三种方式表示：

```text
Truth Table
Gate Diagram
Boolean Expression
```

truth table 最直接定义功能：列出所有输入组合和对应输出。对于 $n$ 个 binary inputs，truth table 有：

$$
2^n
$$

行。

gate diagram 是硬件结构图，说明 AND/OR/NOT 等 logic gates 怎样连接。

Boolean expression 是代数表达式，例如：

$$
y = ab + ac + bc
$$

同一个 truth table 对应的功能是唯一的；但 gate diagram 和 Boolean expression 可以有很多等价写法。Boolean algebra 的价值就在于可以在这些等价表示之间转换和化简。

## 2. 从 Gate Diagram 到 Truth Table

课件一开始给了一个三输入电路，输入是 `a`、`b`、`c`，输出是 `y`。

分析电路时，最稳的方法是：

1. 给每个中间 wire 命名。
2. 从输入到输出逐层计算。
3. 枚举所有输入组合。

三个输入共有：

$$
2^3 = 8
$$

种组合：

```text
a b c
0 0 0
0 0 1
0 1 0
0 1 1
1 0 0
1 0 1
1 1 0
1 1 1
```

课件里的电路最后得到的 truth table 是：

```text
a b c | y
0 0 0 | 0
0 0 1 | 0
0 1 0 | 0
0 1 1 | 1
1 0 0 | 0
1 0 1 | 1
1 1 0 | 1
1 1 1 | 1
```

也就是说，只有当至少两个输入为 1 时，输出才为 1。

## 3. Majority Circuit

这个电路叫 majority circuit。

对于三个输入 `a`、`b`、`c`：

```text
y = 1 iff at least two of a, b, c are 1
```

也可以说：

```text
y is the majority bit among a, b, c
```

对应 Boolean expression 是：

$$
y = ab + ac + bc
$$

为什么？

1. $ab=1$ 表示 `a=1` 且 `b=1`。
2. $ac=1$ 表示 `a=1` 且 `c=1`。
3. $bc=1$ 表示 `b=1` 且 `c=1`。
4. 三者 OR 起来，表示“至少有一对输入同时为 1”。

所以：

$$
y = (a \land b) \lor (a \land c) \lor (b \land c)
$$

在数字电路记号里常简写成：

$$
y = ab + ac + bc
$$

这里乘法表示 AND，加法表示 OR。

## 4. Boolean Algebra 的历史意义

George Boole 在 19 世纪发展了用于逻辑的代数系统，也就是 Boolean algebra。它的 primitive functions 是：

```text
AND
OR
NOT
```

20 世纪，Claude Shannon 在硕士论文中把 Boolean algebra 和 relay/switching circuits 联系起来，说明：

```text
由 AND/OR/NOT gates 组成的电路
<-> Boolean algebra expressions
```

这件事非常重要。因为它让硬件设计可以使用数学方法：

```text
manipulate equations
-> reason about circuits
-> verify equivalence
-> simplify implementation
```

换句话说，我们可以先在纸上化简表达式，再把更简单的表达式实现成更少的 gates。

## 5. Boolean Operators：AND、OR、NOT

Boolean algebra 的三个基础操作：

### AND

$$
y = a \cdot b = ab
$$

truth table：

```text
a b | y
0 0 | 0
0 1 | 0
1 0 | 0
1 1 | 1
```

### OR

$$
y = a + b
$$

truth table：

```text
a b | y
0 0 | 0
0 1 | 1
1 0 | 1
1 1 | 1
```

### NOT

$$
y = \bar{a}
$$

truth table：

```text
a | y
0 | 1
1 | 0
```

在 Boolean algebra 中，变量只取 0 或 1，所以这些运算不是普通整数加乘，而是逻辑运算。比如：

$$
1 + 1 = 1
$$

因为 OR 中 `1 OR 1 = 1`。

## 6. NAND、NOR、XOR 可以由基础操作组成

课件强调 NAND、NOR、XOR 都可以由 AND/OR/NOT 组合出来。

NAND：

$$
\text{NAND}(a,b)=\overline{ab}
$$

NOR：

$$
\text{NOR}(a,b)=\overline{a+b}
$$

XOR：

$$
a \oplus b = a\bar{b} + \bar{a}b
$$

也就是说，只用 AND/OR/NOT 就能表达这些常见 gates。

补充一个硬件直觉：NAND 和 NOR 叫 universal gates，因为只用 NAND 或只用 NOR 也能实现任意 combinational logic function。课程这里不要求深入证明，但知道它们很重要就够了。

## 7. Boolean Algebra Laws

课件给了一页 Boolean algebra laws。重点不是死背，而是会用它们化简电路。

### Commutativity

AND：

$$
xy = yx
$$

OR：

$$
x+y = y+x
$$

### Associativity

AND：

$$
(xy)z = x(yz)
$$

OR：

$$
(x+y)+z = x+(y+z)
$$

### Identity

AND：

$$
x \cdot 1 = x
$$

OR：

$$
x + 0 = x
$$

### Laws of 0's and 1's

AND：

$$
x \cdot 0 = 0
$$

OR：

$$
x + 1 = 1
$$

### Uniting Theorem

AND form：

$$
xy + x = x
$$

OR form：

$$
(x+y)x = x
$$

这条在化简中很常用。例如：

$$
ab + a = a
$$

因为如果 $a=1$，无论 $b$ 是什么，结果都是 1；如果 $a=0$，两项都是 0。

### Distributivity

AND distributes over OR：

$$
x(y+z)=xy+xz
$$

OR 也有对应形式：

$$
x+yz=(x+y)(x+z)
$$

第二个形式在 Boolean algebra 中成立，但和普通代数不一样，是数字逻辑里很有用的对偶形式。

### Idempotence

AND：

$$
x \cdot x = x
$$

OR：

$$
x + x = x
$$

### Inverse / Complement

AND：

$$
x \cdot \bar{x} = 0
$$

OR：

$$
x + \bar{x} = 1
$$

### DeMorgan's Laws

AND form：

$$
\overline{xy} = \bar{x} + \bar{y}
$$

OR form：

$$
\overline{x+y} = \bar{x}\bar{y}
$$

DeMorgan's Laws 是从 NAND/NOR 转成 AND/OR/NOT 时最常用的规则。

## 8. 为什么用 Boolean Algebra

Boolean algebra 的核心价值是：

```text
manipulate equations instead of directly manipulating circuits
```

直接改 gate diagram 很难，也容易漏 wire 或接错；但表达式可以用代数规则推导。

主要用途：

1. Verify circuits：证明两个电路功能等价。
2. Simplify circuits：化简表达式，减少 gates。

减少 gates 的意义：

```text
fewer gates
-> fewer transistors
-> less area
-> less energy
-> often less delay
```

当然实际芯片优化还涉及 timing、fanout、layout 等问题；但在 CS61C 这个层次，先抓住“表达式越简单，电路通常越简单”。

## 9. 验证两个电路等价

课件给的例子是比较两个电路：

上面的复杂电路可以读成：

$$
y = ((ab) + a) + c
$$

利用 uniting theorem：

$$
ab + a = a
$$

所以：

$$
y = a + c
$$

下面的简单电路正是：

$$
y = a + c
$$

因此两个电路等价。

这个例子说明：一个复杂 gate diagram 不一定功能复杂。Boolean algebra 可以帮我们发现冗余 gate。

## 10. 化简的电路意义

如果原电路表达式是：

$$
y = ab + a + c
$$

化简后：

$$
y = a + c
$$

那么硬件上可以从：

```text
AND gate for ab
OR gate for ab + a
OR gate for final + c
```

变成：

```text
one OR gate for a + c
```

这减少了 gates，也减少了信号经过的逻辑层数。

这在 CPU 里很现实：control logic 可能根据 `opcode/funct3/funct7` 生成很多控制信号，如果不化简，电路会又大又慢。

## 11. Sum-of-Products Form

sum-of-products，简称 SOP，是一种 Boolean canonical form。

这里：

```text
product = AND term
sum = OR of product terms
```

例如：

$$
y = \bar{a}\bar{b}\bar{c} + \bar{a}\bar{b}c + a\bar{b}\bar{c} + ab\bar{c}
$$

就是 SOP。

它的构造规则很机械：

1. 找出 truth table 中所有 $y=1$ 的行。
2. 对每一行构造一个 product term。
3. 输入为 1 的变量用原变量，例如 $a$。
4. 输入为 0 的变量用取反变量，例如 $\bar{a}$。
5. 把所有 product terms OR 起来。

这样一定能得到实现该 truth table 的 Boolean expression。

## 12. 从 Truth Table 到 SOP

课件给的 truth table：

```text
a b c | y
0 0 0 | 1
0 0 1 | 1
0 1 0 | 0
0 1 1 | 0
1 0 0 | 1
1 0 1 | 0
1 1 0 | 1
1 1 1 | 0
```

找出 $y=1$ 的行：

```text
000
001
100
110
```

分别写 product term：

```text
000 -> \bar{a}\bar{b}\bar{c}
001 -> \bar{a}\bar{b}c
100 -> a\bar{b}\bar{c}
110 -> ab\bar{c}
```

所以 SOP 是：

$$
y = \bar{a}\bar{b}\bar{c} + \bar{a}\bar{b}c + a\bar{b}\bar{c} + ab\bar{c}
$$

这已经是一个可实现的电路：每个 product term 用 AND gate，最后用 OR gate 合并。

## 13. SOP 化简

上面的 SOP 可以化简。

先合并前两项：

$$
\bar{a}\bar{b}\bar{c} + \bar{a}\bar{b}c
$$

提取公共因子：

$$
= \bar{a}\bar{b}(\bar{c}+c)
$$

因为：

$$
\bar{c}+c=1
$$

所以：

$$
= \bar{a}\bar{b}
$$

再看后两项：

$$
a\bar{b}\bar{c} + ab\bar{c}
$$

提取公共因子：

$$
= a\bar{c}(\bar{b}+b)
$$

因为：

$$
\bar{b}+b=1
$$

所以：

$$
= a\bar{c}
$$

因此整体化简为：

$$
y = \bar{a}\bar{b} + a\bar{c}
$$

这就是课件图上最后画出的简化电路：两个 AND terms，最后 OR。

## 14. 从表达式画 Gate Diagram

化简后的表达式：

$$
y = \bar{a}\bar{b} + a\bar{c}
$$

对应电路：

1. 用 NOT gate 生成 $\bar{a}$、$\bar{b}$、$\bar{c}$。
2. 用一个 AND gate 计算 $\bar{a}\bar{b}$。
3. 用另一个 AND gate 计算 $a\bar{c}$。
4. 用 OR gate 合并两个 product terms。

也就是：

```text
not a, not b -> AND -> term1
a, not c     -> AND -> term2
term1, term2 -> OR  -> y
```

这就是从 truth table 到 gate diagram 的完整路径：

```text
Truth table
-> SOP expression
-> Boolean simplification
-> Gate diagram
```

## 15. 1-bit Equality Compare 复习

上一讲的 1-bit compare truth table：

```text
a b | y
0 0 | 1
0 1 | 0
1 0 | 0
1 1 | 1
```

含义：

```text
y = 1 iff a == b
```

Boolean expression：

$$
y = \bar{a}\bar{b} + ab
$$

也可以写成：

$$
y = \overline{a \oplus b}
$$

这就是 XNOR。

把这个电路打包成 block：

```text
a, b -> ==1? -> y
```

就可以继续构造更大的 compare circuit。

## 16. 32-bit Equality Compare

RISC-V 的 `beq` 需要比较两个 32-bit register values：

```asm
beq rs1 rs2 label
```

需要判断：

$$
R[\text{rs1}] = R[\text{rs2}]
$$

抽象成电路：

```text
A[31:0], B[31:0] -> ==32? -> z
```

其中：

$$
z = 1 \iff A = B
$$

如果直接写完整 truth table，输入有 64 bits：

$$
32 + 32 = 64
$$

所以行数是：

$$
2^{64}
$$

太大，不可行。

## 17. 32-bit Compare 的模块化设计

用 modular design：

```text
先做 1-bit compare
再组合成 32-bit compare
```

每一位比较：

$$
eq_i = 1 \iff a_i = b_i
$$

整体相等当且仅当每一位都相等：

$$
z = eq_{31} \land eq_{30} \land \cdots \land eq_0
$$

展开写：

$$
z = (a_{31}=b_{31}) \land (a_{30}=b_{30}) \land \cdots \land (a_0=b_0)
$$

电路结构：

```text
32 one-bit equality blocks
-> 32-input AND
-> z
```

这就是“用小模块搭大模块”的思想。

## 18. 和 CPU 项目的对应关系

L17 对 CPU 项目最直接的对应有三块。

### Branch Comparator

`beq` 需要：

```text
BrEq = (rs1_data == rs2_data)
```

这个 `BrEq` 可以用 32-bit equality compare 实现。

`bne` 可以用：

```text
not BrEq
```

### Control Logic

control logic 根据 instruction fields 产生控制信号：

```text
opcode, funct3, funct7 -> RegWEn, MemWEn, ALUSel, WBSel, PCSel, ...
```

这本质是组合逻辑：

```text
control_signals = f(opcode, funct3, funct7)
```

可以用 truth table 定义，再化成 Boolean expressions 或直接用 Logisim 组件实现。

### 简化电路

如果两个控制条件能化简，硬件就更简单。例如：

```text
某信号 = condition1 OR (condition1 AND condition2)
```

可以化简为：

$$
x + xy = x
$$

这能减少不必要的 gates。

## 19. 本讲最小闭环

这一讲的最小闭环：

```text
Gate diagram -> truth table -> Boolean expression
Truth table -> SOP -> gate diagram
Boolean algebra -> verify/simplify equivalent circuits
Small blocks -> large combinational circuits
```

必须会的表达：

```text
AND: x y
OR:  x + y
NOT: x-bar
```

必须会的化简：

$$
xy + x = x
$$

$$
x + x = x
$$

$$
x + \bar{x} = 1
$$

$$
x\bar{x}=0
$$

$$
\overline{xy}=\bar{x}+\bar{y}
$$

$$
\overline{x+y}=\bar{x}\bar{y}
$$

SOP 构造：

```text
每个 y=1 的 truth-table row
-> 一个 AND product term
所有 product terms
-> OR 起来
```

对 CPU 项目，先把这一讲理解成一句话：

```text
ALU/control/branch-compare 这些没有记忆的模块，都是 Boolean functions implemented as combinational logic.
```
