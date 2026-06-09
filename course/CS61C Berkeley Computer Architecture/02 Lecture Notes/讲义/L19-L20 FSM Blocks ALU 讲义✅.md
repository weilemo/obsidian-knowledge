# L19-L20 FSM Blocks ALU 讲义

来源：[[../Slides/L19-L20 FSM Blocks ALU.pdf]]

配套官方 notes：

- [[../Notes/L19-L20 Data Multiplexors - official notes.html]]
- [[../Notes/L20 Adder Subtractor - official notes.html]]
- [[../Notes/L20 Arithmetic Logic Unit - official notes.html]]
- [[../Notes/L19-L20 Blocks Summary - official notes.html]]

## 0. 本讲目标

L16-L18 已经建立了 synchronous digital system 的基本框架：

```text
state elements 负责记
combinational logic 负责算
clock 负责让状态按拍更新
```

本讲开始把组合逻辑做成更大的 reusable blocks，尤其是 CPU 项目马上要用到的：

```text
MUX
adder/subtractor
ALU
```

对当前 CPU 项目来说，这讲直接对应 Part A 的 `alu.circ`：

```text
A, B, ALUSel -> ALU -> Result
```

要掌握：

1. 为什么 CPU 里到处都是 MUX。
2. MUX 如何把多个候选数据源合成一条数据路径。
3. full adder 如何级联成 32-bit adder。
4. 为什么减法可以复用加法器。
5. ALU 为什么可以“所有运算并行算，再用 MUX 选结果”。
6. `ALUSel` 在当前项目里到底控制什么。

## 1. 从 gates 到 blocks

前面 L17 讲的 gates 是很小的 building blocks：

```text
AND
OR
NOT
XOR
```

但真正的 CPU 不可能只靠手工看一堆 gates。工程上会把常用逻辑封装成更大的 block：

```text
MUX
decoder
adder
shifter
comparator
register file
ALU
```

这些 block 本身可能由很多 gates 组成，但在上层数据通路图里，我们把它们当成一个功能单元。

例如：

```text
ALU(A, B, ALUSel) -> Result
```

这就是 abstraction 的作用：上层只关心 ALU 的输入输出和行为，不必每次都看里面每个 gate 怎么连。

## 2. MUX 的核心直觉

MUX 是 multiplexer，多路选择器。

它解决的问题是：

```text
有多个可能的输入
但这一拍只能让其中一个成为输出
```

最简单的是 2-to-1 MUX：

```text
inputs: A, B
select: S
output: Y
```

行为是：

$$
Y =
\begin{cases}
A, & S = 0 \\
B, & S = 1
\end{cases}
$$

如果用 Boolean expression 写，可以写成：

$$
Y = (\overline{S} \land A) \lor (S \land B)
$$

这句话的意思是：

```text
S = 0 时，打开 A 的路径，关掉 B 的路径
S = 1 时，关掉 A 的路径，打开 B 的路径
```

## 3. Wide MUX

CPU 里的数据通常不是 1 bit，而是 32 bits。

所以 32-bit MUX 可以理解成：

```text
32 个 1-bit MUX 并排放
它们共享同一个 select signal
```

例如 32-bit 2-to-1 MUX：

```text
A[31:0]
B[31:0]
S
-> Y[31:0]
```

行为还是：

$$
Y =
\begin{cases}
A[31:0], & S = 0 \\
B[31:0], & S = 1
\end{cases}
$$

只是一次选的是一整条 32-bit bus。

这对 Logisim 特别重要：很多组件都有 `Data Bits` 属性。如果两边 bit width 不一致，线就会变橙色，表示 width mismatch。

## 4. CPU 里为什么到处都是 MUX

因为同一套硬件要服务不同指令。

例如 ALU 的第二个输入，有时应该来自 `rs2`：

```asm
add t0, t1, t2
```

对应：

```text
ALU A = R[t1]
ALU B = R[t2]
```

但有时应该来自 immediate：

```asm
addi t0, t1, 5
```

对应：

```text
ALU A = R[t1]
ALU B = SignExt(5)
```

于是 CPU 不会给 `add` 和 `addi` 各搭一套 ALU，而是在 ALU 输入 B 前放一个 MUX：

```text
        R[rs2]
          |
          v
        -----
       | MUX | -> ALU B
        -----
          ^
          |
       immediate
```

控制信号 `BSel` 决定选谁。

类似地：

| MUX | 在选什么 |
|---|---|
| ALU input A MUX | 选 `rs1` 还是 `PC` |
| ALU input B MUX | 选 `rs2` 还是 `imm` |
| Writeback MUX | 选 ALU result / memory data / `PC + 4` |
| PC MUX | 选 `PC + 4` 还是 branch/jump target |
| ALU output MUX | 选 add/sub/and/or/shift/slt/... |

所以 MUX 是 CPU 数据通路复用的核心。

## 5. Adder 的问题

ALU 里最基础的运算是加法。

CPU 中很多地方都需要加法：

```text
add 指令: R[rs1] + R[rs2]
addi 指令: R[rs1] + imm
load/store 地址: R[rs1] + offset
branch target: PC + branch immediate
PC 顺序更新: PC + 4
```

所以理解 adder，就是理解 CPU 里最常见的算术模块。

## 6. 1-bit adder

先看一位加法。

最低位如果没有 carry-in：

```text
a0 + b0 -> y0, c1
```

truth table：

| $a_0$ | $b_0$ | $y_0$ | $c_1$ |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |

所以：

$$
y_0 = a_0 \oplus b_0
$$

$$
c_1 = a_0 \land b_0
$$

但一般位置需要考虑 carry-in：

```text
ai + bi + ci -> yi, c_{i+1}
```

这就是 full adder。

sum bit 是三个输入的 XOR：

$$
y_i = a_i \oplus b_i \oplus c_i
$$

carry-out 是三者中至少两个为 1：

$$
c_{i+1} = (a_i \land b_i) \lor (a_i \land c_i) \lor (b_i \land c_i)
$$

这个公式可以这样理解：

```text
三个输入里只要有两个或三个是 1，就会产生进位
```

## 7. Ripple-carry adder

把很多个 1-bit full adder 串起来，就得到 n-bit adder。

例如 4-bit：

```text
bit 0 full adder -> carry c1
bit 1 full adder -> carry c2
bit 2 full adder -> carry c3
bit 3 full adder -> carry c4
```

carry 像水波一样从低位传到高位，所以叫 ripple-carry adder。

对 32-bit adder：

```text
carry 从 bit 0 一直传到 bit 31
```

它简单、直观，但 propagation delay 会比较长，因为高位结果要等低位 carry 传上来。

不过在当前 Logisim 项目里，你通常可以直接用 Logisim Arithmetic 里的 Adder 组件，不需要手搓 32 个 full adder。理解它的行为就够了。

## 8. Overflow 和当前项目的关系

对于 signed addition，overflow 发生在结果超出可表示范围时。

例如 4-bit two's complement 范围是：

$$
[-8, 7]
$$

如果：

$$
7 + 1 = 8
$$

但 4-bit signed 里没有 8，所以 bit pattern 会 wrap around 成负数。

不过当前项目文档明确说：

```text
像 RISC-V unsigned 指令那样处理 overflow：ignore overflow
```

所以实现 ALU 时，重点不是 overflow flag，而是输出低 32 bits。

对 `add`：

$$
Result = (A + B)[31:0]
$$

对 `sub`：

$$
Result = (A - B)[31:0]
$$

## 9. 减法为什么能复用加法器

减法：

$$
A - B
$$

可以写成：

$$
A + (-B)
$$

two's complement 中：

$$
-B = \sim B + 1
$$

所以：

$$
A - B = A + \sim B + 1
$$

这就意味着硬件不需要单独做一个 subtractor。只要：

1. 把 $B$ 每一位取反。
2. 在最低位 carry-in 加 1。

就可以用同一个 adder 实现减法。

## 10. SUB 控制信号

adder/subtractor 通常有一个控制信号 `SUB`：

```text
SUB = 0 -> A + B
SUB = 1 -> A - B
```

怎么实现？

对 $B$ 的每一位做：

$$
B'_i = B_i \oplus SUB
$$

如果 `SUB = 0`：

$$
B'_i = B_i \oplus 0 = B_i
$$

如果 `SUB = 1`：

$$
B'_i = B_i \oplus 1 = \overline{B_i}
$$

也就是说 XOR 可以当 conditional inverter。

然后把 `SUB` 接到 adder 的 initial carry-in：

```text
SUB = 0 -> carry-in = 0 -> A + B
SUB = 1 -> carry-in = 1 -> A + ~B + 1
```

这就是 adder/subtractor 的核心。

## 11. ALU 是什么

ALU 是 arithmetic logic unit。

它不是只做加法，而是统一处理 CPU 执行阶段常见的算术/逻辑运算：

```text
add
sub
and
or
xor
shift left
shift right logical
shift right arithmetic
set less than
multiply
```

抽象接口：

```text
input A
input B
input ALUSel
output Result
```

当前项目里：

```text
A: 32 bits
B: 32 bits
ALUSel: 4 bits
Result: 32 bits
```

## 12. ALU 的基本实现思路

最容易理解、也最适合当前项目的做法是：

```text
所有运算模块并行计算
最后用一个大 MUX 选择输出
```

结构像这样：

```text
                    A, B
                     |
      --------------------------------
      | add_result                  |
      | and_result                  |
      | or_result                   |
      | xor_result                  |
      | srl_result                  |
      | sra_result                  |
      | sll_result                  |
      | slt_result                  |
      | mul_result                  |
      | sub_result                  |
      | bsel_result                 |
      --------------------------------
                     |
                  MUX(ALUSel)
                     |
                  Result
```

这就是为什么 ALU 是组合逻辑：

$$
Result = f(A, B, ALUSel)
$$

它不需要 clock。输入变了，经过 propagation delay，输出就变。

## 13. 当前项目的 ALUSel 表

项目里的 ALU 操作大致是：

| ALUSel | 操作    | 语义                             |
| ------ | ----- | ------------------------------ |
| 0      | add   | $A + B$                        |
| 1      | and   | $A \land B$                    |
| 2      | or    | $A \lor B$                     |
| 3      | xor   | $A \oplus B$                   |
| 4      | srl   | unsigned logical right shift   |
| 5      | sra   | signed arithmetic right shift  |
| 6      | sll   | left shift                     |
| 7      | slt   | signed less-than               |
| 10     | mul   | signed multiply low 32 bits    |
| 11     | mulhu | unsigned multiply high 32 bits |
| 12     | sub   | $A - B$                        |
| 13     | bsel  | output $B$                     |
| 14     | mulh  | signed multiply high 32 bits   |

所以 `ALUSel` 的本质是：

```text
告诉 ALU 最后那个大 MUX 选择哪一个运算结果
```

它不是 clock，也不是 write enable。

## 14. `add` 和 `sub`

`add`：

$$
Result = A + B
$$

`sub`：

$$
Result = A - B = A + \sim B + 1
$$

在 Logisim 中，你可以：

1. 直接用 Adder/Subtractor 或 Arithmetic 组件。
2. 或用一个 Adder 加上 XOR 条件反转 $B$ 和 carry-in。

对项目来说，直接使用允许的 Logisim Arithmetic 组件通常更稳。

## 15. bitwise logic

`and`、`or`、`xor` 都是 bitwise 操作。

也就是说每一位独立计算：

$$
Result_i = A_i \land B_i
$$

$$
Result_i = A_i \lor B_i
$$

$$
Result_i = A_i \oplus B_i
$$

这类操作没有 carry，不会从低位影响高位。

例如：

```text
A = 1010
B = 1100
```

则：

```text
A & B = 1000
A | B = 1110
A ^ B = 0110
```

## 16. shift

shift 有三种：

```text
sll: shift left logical
srl: shift right logical
sra: shift right arithmetic
```

### 16.1 sll

左移：

$$
Result = A \ll B
$$

空出来的低位补 0。

例如：

```text
0000_1011 << 2 = 0010_1100
```

### 16.2 srl

逻辑右移：

$$
Result = A >> B
$$

空出来的高位补 0。

例如：

```text
1000_0000 >> 2 = 0010_0000
```

### 16.3 sra

算术右移保留符号位。

如果最高位是 1，右移时高位补 1；如果最高位是 0，高位补 0。

例如 8-bit：

```text
1000_0000 sra 2 = 1110_0000
```

它的目的通常是让 signed negative number 右移后仍保持负号。

项目里要注意 `srl` 和 `sra` 的区别：一个 unsigned / logical，一个 signed / arithmetic。

## 17. slt

`slt` 是 set less than：

```text
slt rd, rs1, rs2
```

语义是：

$$
Result =
\begin{cases}
1, & A < B \text{ as signed integers} \\
0, & \text{otherwise}
\end{cases}
$$

注意输出不是 true/false 的 1 bit，而是 32-bit 值：

```text
0x00000001
```

或：

```text
0x00000000
```

当前项目的 `slt` 是 signed comparison。

## 18. bsel

`bsel` 很简单：

$$
Result = B
$$

为什么 ALU 里会有这个？

有些数据通路中，ALU 被用来传递 immediate 或某个输入，不一定总是做复杂运算。`bsel` 可以让 ALU 输出直接等于 B。

在项目里，按 ALUSel 表实现即可。

## 19. multiply

项目要求：

```text
mul
mulhu
mulh
```

它们都来自 32-bit 乘法得到的 64-bit 结果。

### 19.1 mul

`mul` 取低 32 bits：

$$
Result = (A \times B)[31:0]
$$

### 19.2 mulhu

`mulhu` 是 unsigned multiply high：

$$
Result = (A \times B)[63:32]
$$

这里把 $A$ 和 $B$ 都当 unsigned。

### 19.3 mulh

`mulh` 是 signed multiply high：

$$
Result = (A \times B)[63:32]
$$

这里把 $A$ 和 $B$ 都当 signed。

注意 `mulhu` 和 `mulh` 的 bit slice 都是高 32 bits，但 signedness 不同。

## 20. ALU 和 `addi`

回到当前项目 Part A 的最小 CPU：`addi`。

```asm
addi t0, x0, 5
```

执行语义：

$$
R[t0] = R[x0] + \operatorname{SignExt}(5)
$$

在 ALU 里：

```text
A = R[x0]
B = SignExt(5)
ALUSel = add
Result = A + B = 5
```

所以只要 `add` 路径正确，`addi` 的执行阶段就能工作。

但项目先让你做完整 ALU，是因为 Part B 会复用同一个 ALU 来支持更多指令：

```text
R-type arithmetic
I-type arithmetic
load/store address
branch target
jump target
```

## 21. 当前项目 `alu.circ` 的推荐实现策略

最稳的实现顺序：

### 21.1 先实现简单 bitwise

```text
and
or
xor
bsel
```

这些没有 signedness、carry、shift amount 的坑。

### 21.2 再实现 add/sub

```text
add
sub
```

用 Arithmetic 组件时要确认：

```text
Data Bits = 32
输出接到对应 MUX 输入
```

### 21.3 再实现 shift

```text
sll
srl
sra
```

注意 shift amount 通常只需要 $B[4:0]$，因为 32-bit word 最多移 0 到 31 位。

$$
0 \leq \text{shift amount} \leq 31
$$

### 21.4 再实现 compare

```text
slt
```

确认是 signed compare。

### 21.5 最后实现 multiply

```text
mul
mulhu
mulh
```

注意低 32 bits / 高 32 bits 的 splitter。

## 22. ALU 的大 MUX

所有结果都接到一个大 MUX：

```text
add_result   -> input 0
and_result   -> input 1
or_result    -> input 2
xor_result   -> input 3
srl_result   -> input 4
sra_result   -> input 5
sll_result   -> input 6
slt_result   -> input 7
mul_result   -> input 10
mulhu_result -> input 11
sub_result   -> input 12
bsel_result  -> input 13
mulh_result  -> input 14
```

未使用的输入 8、9 可以接 0 或不用，但最好避免 floating wire。

`ALUSel` 是 4 bits，所以最多能选择 16 个输入：

$$
2^4 = 16
$$

这正好覆盖 0 到 15。

## 23. Logisim 易错点

### 23.1 wire width 不一致

如果线变橙色，通常是 bit width mismatch。

检查：

```text
input pin 是否 32 bits
output pin 是否 32 bits
MUX data bits 是否 32 bits
ALUSel 是否 4 bits
```

### 23.2 floating wire

蓝色线通常表示 unknown / floating。

如果某个 MUX 输入没接，可能导致输出 unknown。

稳妥做法：

```text
未使用输入接 0 常量
```

### 23.3 多个输出驱动同一根线

红色线通常表示 error，例如两个输出同时驱动同一根 wire。

ALU 多个运算模块不能直接短接到 Result。必须通过 MUX 选择。

错误：

```text
add_result ----\
and_result ----- Result
or_result  ----/
```

正确：

```text
add_result ----\
and_result ----- MUX -> Result
or_result  ----/
```

### 23.4 signed / unsigned 搞混

重点检查：

```text
sra: signed arithmetic right shift
srl: unsigned logical right shift
slt: signed compare
mulh: signed high
mulhu: unsigned high
```

### 23.5 移动输入输出 pin

项目测试 harness 依赖 pin 的位置和形状。

不要移动：

```text
A
B
ALUSel
Result
```

可以在内部重排电路，但外部接口要保持不变。

## 24. ALU 与 RegFile 的区别

这一点很重要：

```text
ALU 是组合逻辑
RegFile 是状态元件
```

ALU 不保存任何东西：

```text
A/B/ALUSel 一变，Result 也跟着变
```

RegFile 保存寄存器值：

```text
clock edge + RegWEn -> 写入某个 register
```

所以：

```text
ALU 不需要 clock
RegFile 需要 clock
```

如果在 ALU 里用了 register，通常就错了，因为 ALU 输出会多一个周期延迟。

## 25. 和完整 CPU 数据通路的关系

ALU 会出现在执行阶段：

```text
RegFile rs1 ----\
                 -> ALU -> ALU result
RegFile rs2/imm -/
```

不同指令复用 ALU：

| 指令类型 | ALU 做什么 |
|---|---|
| R-type | `rs1 op rs2` |
| I-type arithmetic | `rs1 op imm` |
| load | `rs1 + offset` 计算地址 |
| store | `rs1 + offset` 计算地址 |
| branch | 可能用于计算 `PC + offset` |
| jal / auipc | 计算 PC-relative result |

所以 ALU 不是只服务 `add`，而是执行阶段的通用计算核心。

## 26. 本讲一句话总结

MUX 让同一条数据通路可以服务不同指令；adder/subtractor 说明硬件会通过补码复用电路；ALU 则把多个算术/逻辑 block 组合起来，用 `ALUSel` 选择最终结果。

对当前项目来说：

```text
实现 ALU = 并行搭好运算模块 + 用 ALUSel 控制大 MUX 输出
```

## 27. 自查问题

1. 为什么多个运算结果不能直接连到同一个 `Result`？
2. 为什么 4-bit `ALUSel` 可以选择最多 16 种 ALU 输出？
3. 为什么 `A - B` 可以变成 `A + ~B + 1`？
4. 为什么 `srl` 和 `sra` 对负数结果不同？
5. `mulh` 和 `mulhu` 都取高 32 bits，区别在哪里？
6. 为什么 ALU 不应该有 clock？
7. 当前项目 Part A 的 `addi` 会用到 ALU 的哪一条路径？

