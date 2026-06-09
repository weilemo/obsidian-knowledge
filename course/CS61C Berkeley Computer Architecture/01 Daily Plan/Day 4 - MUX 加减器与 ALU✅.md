# Day 4 - MUX 加减器与 ALU

## 今天目标

前三天已经建立了：

```text
Day 1: bit / number representation / addi
Day 2: load-store / instruction formats / immediate
Day 3: combinational logic / state / clock
```

Day 4 开始把这些拼成真正能用的 CPU 零件：**MUX、加减器、ALU**。

学完今天内容后，要能回答：

1. MUX 为什么是 CPU 数据通路里最常见的选择器？
2. 加法器如何从 1-bit full adder 扩展成 32-bit adder？
3. 为什么减法可以用加法器实现？
4. ALU 为什么通常是“多个运算模块并行 + 最后 MUX 选结果”？
5. 当前项目 `alu.circ` 里 `ALUSel` 到底在控制什么？

## 今天要看的 CS61C 内容

本地资料入口：[[../02 Lecture Notes/Day 4 Materials Index]]

官方课程页：<https://cs61c.org/sp26/>

### 1. Lecture 19: FSM, Blocks

今天轻看 FSM，重点看 blocks 和 MUX。

重点抓：

```text
MUX
select signal
wide datapath block
combinational block
```

MUX 的直觉是：

```text
有多条候选数据线
由 select signal 决定最终让哪一条通过
```

比如 2-to-1 MUX：

$$
Y =
\begin{cases}
A, & S = 0 \\
B, & S = 1
\end{cases}
$$

在 CPU 里，MUX 到处都是：

| MUX | 在选什么 |
|---|---|
| ALU input B MUX | 选 `rs2` 还是 `imm` |
| Writeback MUX | 选 ALU result / memory data / `PC + 4` |
| PC MUX | 选 `PC + 4` 还是 branch/jump target |
| ALU output MUX | 根据 `ALUSel` 选 add/sub/and/or/... 的结果 |

### 2. Lecture 20: ALU: Adder/Subtractor

重点看：

```text
1-bit full adder
ripple-carry adder
adder/subtractor
XOR conditional inverter
ALU
```

加法器从 1-bit full adder 串起来：

```text
bit 0 carry out -> bit 1 carry in
bit 1 carry out -> bit 2 carry in
...
```

这叫 ripple-carry adder。

减法复用加法器，靠补码：

$$
A - B = A + (-B)
$$

而二补码里：

$$
-B = \sim B + 1
$$

所以：

$$
A - B = A + \sim B + 1
$$

硬件上就是：

```text
SUB = 0: B 原样进入 adder, carry-in = 0 -> A + B
SUB = 1: B 取反进入 adder, carry-in = 1 -> A + ~B + 1
```

## 今天的核心图像

ALU 可以这样理解：

```text
          A, B
           |
  ---------------------
  | add result        |
  | sub result        |
  | and result        |
  | or result         |
  | xor result        |
  | shift result      |
  | slt result        |
  ---------------------
           |
        big MUX
           |
        Result
```

`ALUSel` 控制最后的大 MUX：

```text
ALUSel = 0  -> add
ALUSel = 1  -> and
ALUSel = 2  -> or
ALUSel = 3  -> xor
ALUSel = 12 -> sub
...
```

这就是为什么项目文档建议：**可以让所有模块都并行计算，然后选择想要的输出。**

## 今天的练习

### 练习 1：解释 MUX

用自己的话解释这个 2-to-1 MUX：

```text
input A = 10
input B = 99
S = 0 -> output = ?
S = 1 -> output = ?
```

再回答：CPU 里为什么不能每条指令都重新连线，而要靠 MUX？

### 练习 2：解释减法器

解释为什么：

$$
A - B = A + \sim B + 1
$$

然后对应到硬件：

```text
SUB 控制 B 是否取反
SUB 同时作为 carry-in
```

### 练习 3：规划当前项目 ALU

按照项目 `ALUSel` 表，给每个运算写一句实现思路：

| ALUSel | 操作 | 实现思路 |
|---|---|---|
| 0 | add | adder |
| 1 | and | bitwise AND |
| 2 | or | bitwise OR |
| 3 | xor | bitwise XOR |
| 4 | srl | logical right shifter |
| 5 | sra | arithmetic right shifter |
| 6 | sll | left shifter |
| 7 | slt | signed compare |
| 10 | mul | multiplier low 32 bits |
| 11 | mulhu | unsigned multiply high 32 bits |
| 12 | sub | adder/subtractor |
| 13 | bsel | output B |
| 14 | mulh | signed multiply high 32 bits |

### 练习 4：连接到 `addi`

解释 `addi t0, x0, 5` 在 ALU 里的输入：

```text
ALU A = R[x0]
ALU B = SignExt(5)
ALUSel = add
Result = 5
```

这就是 Part A 只支持 `addi` CPU 的执行阶段。

## 今天暂时不用深挖

今天可以先不深挖：

```text
FSM 完整设计
carry-lookahead adder
乘法器内部实现
浮点 ALU
精确 overflow 处理
```

当前项目更需要的是会搭一个能通过测试的 ALU，而不是从晶体管层设计最快的 ALU。

## 和当前 CPU 项目的连接

今天内容直接对应：

| Day 4 内容 | 项目模块 |
|---|---|
| MUX | `ALUSel`, `WBSel`, `PCSel`, ALU input select |
| adder/subtractor | `alu.circ` 的 add / sub |
| bitwise logic | `and`, `or`, `xor` |
| shift | `sll`, `srl`, `sra` |
| compare | `slt`, branch comparator 的基础 |
| ALU output MUX | `alu.circ` 的最终 Result |

尤其要记住：

```text
ALU 是组合逻辑。
RegFile 才是状态。
ALU 不需要 clock。
```

## 今天的输出

今天结束时，在下面追加自己的 4 个小总结：

```text
1. 我如何理解 MUX 在 CPU 里的作用？
2. 为什么减法能复用加法器？
3. ALUSel 是在控制哪个选择？
4. 如果我要开始做 alu.circ，我会先搭哪几个运算？
```

