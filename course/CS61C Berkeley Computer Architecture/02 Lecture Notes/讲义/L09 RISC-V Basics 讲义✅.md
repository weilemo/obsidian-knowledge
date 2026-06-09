# L09 RISC-V Basics 讲义

来源：[[Slides/L09 RISC-V Basics.pdf]]

## 0. 本讲目标

这一讲从“程序怎样真的跑在硬件上”切入 RISC-V。前面课程已经讲过数字表示、C 语言和浮点数；从这里开始，课程进入更低一层的抽象：assembly language、machine code、CPU register 和指令执行。

本讲要抓住五件事：

1. 什么是 ISA，为什么 ISA 是软件和硬件之间的接口。
2. 为什么 CS61C 选择 RISC-V，而不是 x86-64。
3. RV32I 的 register model：有多少寄存器，每个寄存器多宽。
4. `add`、`sub` 这类三操作数算术指令如何对应 C 表达式。
5. immediate 和 zero register `x0` 为什么能让指令集保持简单。

幻灯片一开始还列了上一讲浮点数遗留主题：special numbers、overflow、underflow。这份 L09 的主体没有展开浮点数细节，只是作为 agenda 的承接；本讲真正的新内容是 RISC-V。

## 1. 从固定电路到可编程 CPU

早期计算机如 ENIAC 更像“可重接线的电路”：要改变计算任务，需要物理 rewiring。这种方式很受限制。后来 stored-program computer 的思想成熟，程序和数据都可以存进内存，CPU 的基本工作就变成：

```text
fetch instruction -> decode instruction -> execute instruction -> repeat
```

也就是说，CPU 不需要为每个程序重新接线，而是不断执行一条条指令。

EDSAC 是早期 general stored-program computer 的代表。它体现的核心转变是：计算机硬件提供一组通用机制，具体行为由存储在内存中的指令序列决定。

## 2. Great Idea #1: Abstraction

CS61C 反复强调的第一个 great idea 是 abstraction。计算机系统不是一整团不可分的硬件，而是分层解释的：

```text
High-level language, such as C
-> Assembly language
-> Machine code bits
-> CPU datapath and control
-> Logic gates
-> Transistors
```

每一层都有清晰接口。上层只需要知道下层提供了什么能力，不必知道所有实现细节。ISA 就位在软件和硬件之间，是这一段最关键的接口。

学习 assembly 的意义也在这里：平时我们很少手写 assembly，但理解 assembly 能让人知道高级语言最后怎样被硬件执行。编译器不是魔法，它把 C/Java/Python 等高层表达逐步翻译到机器可以执行的低层指令。

## 3. ISA 是什么

ISA 是 Instruction Set Architecture。它定义“某一类计算机支持什么操作，以及这些操作如何被软件表达、如何被硬件理解”。

一个 ISA 通常至少定义三类内容：

1. Fundamental architectural features and design：例如寄存器个数、寄存器宽度、内存访问模型。
2. Assembly language：人能读写的低层指令形式，例如 `add x18 x19 x20`。
3. Machine language：同一条指令在机器中怎样编码成 bit string。

例如：

```asm
add x18 x19 x20
```

这行 assembly 表示一条加法指令。它最终会被编码成一串 machine code bits，例如：

```text
00000000101010011000100100110011
```

核心关系是：

```text
one assembly instruction
= one machine instruction
= one CPU action described by the ISA
```

这里的“one CPU action”不是说 CPU 内部只发生一个晶体管动作，而是说从 ISA 视角看，这是一条完整的架构级指令。

## 4. RISC vs. CISC

不同 CPU 可以实现不同 ISA。常见 ISA 包括 ARM、Intel x86、PowerPC、MIPS、RISC-V 等。

早期一条路线是 CISC，即 Complex Instruction Set Computer。它倾向于把越来越复杂的操作加入指令集，让单条指令能做更多事。Intel x86 系列就带有明显 CISC 历史包袱。

另一条路线是 RISC，即 Reduced Instruction Set Computer。RISC 的哲学是：

1. 指令集尽量小而规则。
2. 每条指令做简单清楚的事情。
3. 复杂软件通过组合简单指令来完成。
4. 规则、简单的 ISA 更容易做出高速硬件。

这条路线和 Berkeley 的计算机体系结构传统关系很深。David Patterson 和 John Hennessy 因 RISC 等体系结构贡献获得了 2017 年图灵奖。

## 5. 为什么用 RISC-V

RISC-V 是一个较新的 open-source、license-free ISA specification。它在 2010 年夏天从 UC Berkeley 的研究和教学需求中开始，后来迁移到 RISC-V Foundation。它的血统可以追溯到 1980s 的 RISC-I / RISC-II 项目。

课程选择 RISC-V，而不是 Intel x86-64，主要因为：

1. RISC-V 简单、规则，适合教学。
2. 它是开放 ISA，可以自由用于 CPU 设计。
3. 它有不断增长的软件生态。
4. 它覆盖范围很广，从 microcontroller 到 supercomputer 都能使用。

对 CS61C 来说，RISC-V 的价值是：它足够真实，又不会让学生过早陷入历史兼容性和复杂编码细节。

## 6. CPU、Memory 和 Register

一台简化计算机可以先分成两个大部分：

1. CPU / Processor：负责计算。
2. Main memory：负责长期存储数据和程序。

CPU 需要非常快，因此不能每次操作都去慢得多的 main memory 里取数据。CPU 内部会放少量非常快的存储位置，这就是 registers。

可以把数据位置分成两类：

```text
registers: inside CPU, very fast, small number
memory: outside CPU core, larger, slower
```

RISC-V 的很多整数运算只能直接作用在 register operand 上。也就是说，算术指令通常不会直接对内存里的值做加减，而是先把数据放到寄存器，再执行运算。

## 7. RV32I 的寄存器规格

RV32I 表示 RISC-V 32-bit Integer ISA。这里：

1. `RV` 表示 RISC-V。
2. `32` 表示 register 和 address 等基础架构宽度是 32-bit。
3. `I` 表示 base integer instruction set。

在 RV32I 中：

$$
\text{number of registers} = 32
$$

$$
\text{width of each register} = 32\ \text{bits}
$$

所以每个 register 能保存一个 32-bit word：

$$
1\ \text{word} = 32\ \text{bits} = 4\ \text{bytes}
$$

寄存器名字可以写成 `x0` 到 `x31`。例如 `x10`、`x19`、`x20` 都是具体寄存器。

编译器会把 C 变量映射到 RISC-V registers。比如某段代码中可以约定：

```text
a -> x10
b -> x1
c -> x2
d -> x3
e -> x4
```

这种映射不是固定由变量名决定的，而是编译器根据 calling convention、活跃变量、优化策略等规则安排出来的。因为 register 很少，编译器必须小心管理哪些值放 register，哪些值临时写回 memory。

## 8. Assembly 和 Machine Code 的一一对应

ISA 既定义 assembly，也定义 machine language。

以一条加法为例：

```asm
add x18 x19 x20
```

它包含：

```text
operation name: add
register operands: x18, x19, x20
```

同一条指令会有一个机器编码：

```text
00000000101010011000100100110011
```

在这一讲只需要先理解大方向：assembly 是人类可读的指令文本，machine code 是 CPU 实际读取的 bit encoding。后面的 instruction formats 会具体讲这些 bit 如何分成 opcode、rd、rs1、rs2 等字段。

## 9. RISC-V 算术指令的基本语法

RISC-V 算术指令语法非常规则：

```asm
opname rd rs1 rs2
```

含义是：

```text
opname: operation name
rd: destination register, receives the result
rs1: source register 1
rs2: source register 2
```

更像公式写法：

$$
R[\text{rd}] \leftarrow R[\text{rs1}]\ \text{op}\ R[\text{rs2}]
$$

其中 $R[x]$ 表示 register $x$ 里存的值。

这种格式有一个很重要的硬件动机：regularity。指令格式越规则，CPU 的 decode 和 datapath 控制越简单。

## 10. `add` 和 `sub`

加法指令：

```asm
add x1 x2 x3
```

含义是：

$$
R[x1] \leftarrow R[x2] + R[x3]
$$

如果 C 变量映射为：

```text
a -> x1
b -> x2
c -> x3
```

那么它对应：

```c
a = b + c;
```

减法指令：

```asm
sub x4 x5 x6
```

含义是：

$$
R[x4] \leftarrow R[x5] - R[x6]
$$

如果 C 变量映射为：

```text
d -> x4
e -> x5
f -> x6
```

那么它对应：

```c
d = e - f;
```

注意减法 operand order 很重要。`sub x4 x5 x6` 是 $x5 - x6$，不是 $x6 - x5$。

## 11. C 表达式到多条 RISC-V 指令

C 的一条语句可能包含多个操作，但 RISC-V 一条算术指令只做一个简单操作。因此 C statement 常常会翻译成多条 assembly instructions。

例子：

```c
a = b + c + d - e;
```

假设变量和寄存器映射为：

```text
a -> x10
b -> x1
c -> x2
d -> x3
e -> x4
```

可以翻译为：

```asm
add x10  x1 x2   # a_temp = b + c
add x10 x10 x3   # a_temp = a_temp + d
sub x10 x10 x4   # a = a_temp - e
```

过程是：

$$
R[x10] \leftarrow R[x1] + R[x2]
$$

$$
R[x10] \leftarrow R[x10] + R[x3]
$$

$$
R[x10] \leftarrow R[x10] - R[x4]
$$

最后 `x10` 中保存的就是 $b+c+d-e$。

这也说明：高级语言的一行代码不是硬件的一条原子动作。编译器要把复杂表达式拆成 ISA 支持的简单指令序列。

## 12. 为什么 assembly 要写注释

幻灯片专门插入了 Margaret Hamilton 和 Apollo Guidance Computer 的例子，提醒 assembly code 必须认真注释。

原因很直接：assembly 很接近机器执行过程，变量名、类型信息和复杂结构都被压扁到 register、immediate 和 instruction sequence 里了。如果没有注释，几行看似简单的 `add/sub` 很快就会变得难以维护。

好的 assembly 注释应该说明“这一行在原程序语义里代表什么”，而不是只重复指令本身。例如：

```asm
add x10 x1 x2   # a_temp = b + c
```

这个注释有用，因为它把 `x10/x1/x2` 重新连回了 C 变量。

## 13. 临时寄存器与编译器优化

第二个例子：

```c
f = (g + h) - (i + j);
```

变量映射：

```text
f -> x19
g -> x20
h -> x21
i -> x22
j -> x23
```

一种直观翻译是使用 temporary registers：

```asm
# a_temp: x5, b_temp: x6
add x5  x20 x21   # a_temp = g + h
add x6  x22 x23   # b_temp = i + j
sub x19 x5  x6    # f = a_temp - b_temp
```

公式化地看：

$$
R[x5] \leftarrow R[x20] + R[x21]
$$

$$
R[x6] \leftarrow R[x22] + R[x23]
$$

$$
R[x19] \leftarrow R[x5] - R[x6]
$$

这个版本清晰，但会覆盖 `x5` 和 `x6` 原来的内容。如果这些寄存器里有仍然需要的值，就必须由编译器或程序员保证不会出错。

另一种更聪明的翻译可以不用额外 temporary registers：

```asm
# f = g + h - i - j
add x19 x20 x21
sub x19 x19 x22
sub x19 x19 x23
```

这个版本依次计算：

$$
R[x19] \leftarrow R[x20] + R[x21]
$$

$$
R[x19] \leftarrow R[x19] - R[x22]
$$

$$
R[x19] \leftarrow R[x19] - R[x23]
$$

因为：

$$
(g+h)-(i+j)=g+h-i-j
$$

所以它和原表达式等价。

这里可以看出编译器优化的空间：同一个 C 表达式可能有多种合法 assembly translation。好的编译器会尽量少用 register、少产生 instruction，且保持语义正确。

## 14. Immediate

Immediate 是直接写在 assembly instruction 里的数字常量。它的 bits 会被编码进 instruction 本身。

例如：

```asm
addi x3 x4 10
```

含义是：

$$
R[x3] \leftarrow R[x4] + 10
$$

如果变量映射为：

```text
f -> x3
g -> x4
```

那么对应：

```c
f = g + 10;
```

为什么要有单独的 immediate instruction？因为普通 `add` 的两个输入都来自 registers：

```asm
add rd rs1 rs2
```

而 immediate 版本的第二个输入来自 instruction encoding：

```asm
addi rd rs1 imm
```

也就是：

$$
R[\text{rd}] \leftarrow R[\text{rs1}] + \text{imm}
$$

其中 $\text{imm}$ 是 instruction 里携带的常数。

## 15. 为什么没有 `subi`

幻灯片提出 “Subtract Immediate?”，然后给出 RISC 哲学下的答案：不需要单独加入 `subi`。

例如 C 代码：

```c
f = g - 10;
```

可以写成：

```asm
addi x3 x4 -10
```

因为：

$$
g - 10 = g + (-10)
$$

所以 `addi` 加一个负 immediate 就能表达 subtract immediate。

这正体现 RISC philosophy：

> 如果一个操作能由已有的简单操作等价组合出来，就不要把它作为新指令加入 ISA。

少一条指令，意味着硬件 decode、控制逻辑和 specification 都可以更简单。

## 16. Zero Register `x0`

RISC-V 把 `x0` 硬连成常数 0：

$$
R[x0] = 0
$$

无论你试图往 `x0` 写什么，`x0` 读出来永远都是 0。

这个设计很有用，因为 0 在程序中出现极其频繁。它让很多操作不用额外加载常数 0。

假设：

```text
f -> x3
g -> x4
```

看三条例子。

第一条：

```asm
addi x3 x0 0xff
```

含义：

$$
R[x3] \leftarrow R[x0] + 0xff = 0 + 0xff
$$

对应：

```c
f = 0xff;
```

第二条：

```asm
sub x3 x0 x4
```

含义：

$$
R[x3] \leftarrow R[x0] - R[x4] = -R[x4]
$$

对应：

```c
f = -g;
```

第三条：

```asm
add x0 x3 x4
```

从公式看像是：

$$
R[x0] \leftarrow R[x3] + R[x4]
$$

但 `x0` 永远是 0，写入会被丢弃。因此这条指令没有可观察效果，是 no-op：

```c
// no operation
```

这条例子很关键：`x0` 既能作为 source register 提供常数 0，也能作为 destination register 丢弃结果。

## 17. 高级语言变量 vs. Assembly Register

Backup slides 对比了 C/Java 和 RISC-V 的数据表示。

在 C 里，变量声明时带有类型：

```c
int x = 42;
int *p = ...;
```

变量类型决定了操作意义。例如：

```c
p = p + 2;
```

如果 `p` 是 `int *`，那么这里不是把地址数值加 2 bytes，而是向后移动 2 个 `int`。通常一个 `int` 是 4 bytes，所以地址实际增加：

$$
2 \times 4 = 8\ \text{bytes}
$$

在 assembly 里，register 本身没有类型。`x9` 只是 32 bits。它可以被某条指令当成整数，也可以被另一条指令当成地址。也就是说：

```text
C/Java: type is associated with declaration
RISC-V: interpretation is associated with instruction/operator
```

这就是为什么后面讲 load/store、pointer arithmetic 时，必须格外注意数据宽度。

## 18. 高级语言操作 vs. Assembly Instruction

C 的一行可以包含多个操作：

```c
a = b * 2 - (arr[2] + *p);
```

这里至少包含：

1. 乘法 `b * 2`
2. 数组索引 `arr[2]`
3. 指针解引用 `*p`
4. 加法 `arr[2] + *p`
5. 减法
6. 赋值

而 RISC-V assembly 一行最多是一条 instruction：

```asm
add x1 x2 x3
sub x4 x5 x6
```

每条 instruction 只执行一个短小、规则的动作。编译器的工作就是把高层语言中的复杂表达式拆成这些简单动作。

这也解释了为什么 RISC-V instructions 常常和 C/Java 的基础操作有密切关系：它们是编译器最常用的目标积木。

## 19. Concept Check

题目判断三句话真假：

1. Types are associated with declaration in C, but are associated with instructions/operators in RISC-V.
2. Since there are only 32 registers, we cannot write RISC-V for C expressions that contain more than 32 variables.
3. If `p`, stored in `x9`, were a pointer to an array of ints, then `p++` would be `addi x9, x9, 1`.

答案是：

```text
TFF
```

解释：

第一句为 True。C 变量通常在 declaration 中带类型；RISC-V register 本身只是 bits，具体解释由 instruction 决定。

第二句为 False。寄存器只有 32 个并不意味着程序只能处理 32 个变量。超过寄存器容量时，可以把部分值放在 memory，或者把复杂表达式拆成多个小步骤，重复利用寄存器。

第三句为 False。如果 `p` 是 `int *`，那么 `p++` 表示指向下一个 `int`。通常：

$$
\text{sizeof(int)} = 4\ \text{bytes}
$$

所以应该是：

```asm
addi x9 x9 4
```

而不是：

```asm
addi x9 x9 1
```

## 20. 本讲最小闭环

把这讲压缩成 CPU 项目需要的最小闭环，就是：

```text
ISA defines the contract
-> RV32I has 32 32-bit registers
-> arithmetic instructions use rd, rs1, rs2
-> add/sub operate on registers
-> addi embeds a constant immediate
-> x0 is always zero
-> C expressions compile into multiple simple RISC-V instructions
```

最重要的几条形式如下：

```asm
add  rd rs1 rs2   # R[rd] = R[rs1] + R[rs2]
sub  rd rs1 rs2   # R[rd] = R[rs1] - R[rs2]
addi rd rs1 imm   # R[rd] = R[rs1] + imm
```

对应数学语义：

$$
R[\text{rd}] \leftarrow R[\text{rs1}] + R[\text{rs2}]
$$

$$
R[\text{rd}] \leftarrow R[\text{rs1}] - R[\text{rs2}]
$$

$$
R[\text{rd}] \leftarrow R[\text{rs1}] + \text{imm}
$$

`x0` 的特殊语义：

$$
R[x0] = 0
$$

并且写入 `x0` 的结果会被丢弃。

## 21. 推荐配套资源

幻灯片最后给了三个 RISC-V 资源：

1. CS 61C Reference Card：列出 base architecture，适合查指令格式和寄存器约定。
2. Venus：在线 RISC-V simulator，可以直接运行小段 assembly。
3. RISC-V Technical Specifications：完整技术规范，尤其是 Volume I: unprivileged ISA。

本地已有配套资料：

1. [[Notes/L09 RISC-V Intro - official notes.html]]
2. [[Notes/RV32I Green Card.html]]

对当前 CPU 项目，先把 `add`、`sub`、`addi`、`x0` 和寄存器读写搞清楚，再进入后面的 load/store、instruction format 和 single-cycle datapath 会顺很多。
