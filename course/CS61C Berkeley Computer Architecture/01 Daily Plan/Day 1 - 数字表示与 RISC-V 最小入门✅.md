# Day 1 - 数字表示与 RISC-V 最小入门

## 今天目标

今天不追求完整学完 CS61C，而是先为计算机体系结构项目铺地基。

学完今天内容后，要能回答：

1. 为什么 CPU 里一切都是 bit？
2. 一个 32-bit 数如何表示 signed / unsigned？
3. 为什么立即数要做 sign extension？
4. RISC-V 程序里的 register、instruction、memory address 分别是什么？
5. `addi rd, rs1, imm` 为什么足够作为最小 CPU 闭环？

## 今天要看的 CS61C 内容

本地资料入口：[[../02 Lecture Notes/Day 1 Materials Index]]

### 1. Lecture 1: Intro, Great Ideas

官方页面：<https://cs61c.org/>

只需要快速看，重点抓 CS61C 的层次观：

```text
High-level program
-> C
-> Assembly
-> Machine code
-> Digital logic
-> Hardware
```

这能帮助你理解当前项目为什么不是“写 RISC-V 程序”，而是“搭一个能执行 RISC-V 程序的 CPU”。

### 2. Lecture 2: Number Representation

课程笔记：<https://notes.cs61c.org/>

今天重点看：

```text
binary / hexadecimal
unsigned integer
two's complement
sign bit
sign extension
bitwise operations
shift
```

与项目直接相关的地方：

| 知识点 | 项目中出现的位置 |
|---|---|
| 二进制 / 十六进制 | 测试里的机器码，例如 `0x00500293` |
| 补码 | `slt`、`sra`、signed immediate |
| 符号扩展 | `addi`、`lb`、`lh`、branch offset |
| 位移 | `sll`、`srl`、`sra` |
| bit mask | store byte/half 的 `Write_En` |

### 3. Lecture 9: RISC-V Basics

课程主页中 2026 编排里，RISC-V Basics 是 Lecture 9。今天只看最基础部分，不看 calling convention。

重点抓：

```text
register
instruction
opcode
rd / rs1 / rs2
immediate
add / addi
load / store 的概念
```

今天最重要的一条指令：

```asm
addi rd, rs1, imm
```

它的语义是：

$$
R[rd] = R[rs1] + \operatorname{SignExt}(imm)
$$

如果按 CPU 数据通路理解，它会经过：

```text
取指 -> 译码 -> 读 rs1 -> 生成 immediate -> ALU 加法 -> 写回 rd -> PC + 4
```

这正好对应项目 Part A 的最小 CPU。

## 今天不用看的内容

先跳过：

```text
C pointer 细节
floating point
calling convention
cache
parallelism
virtual memory
```

这些对完整 CS61C 很重要，但不是第一天启动 CPU 项目的最短路径。

## 今日练习

### 练习 1：看懂机器码不是魔法

项目文档中出现过：

```text
0x00500293
```

它对应：

```asm
addi t0, x0, 5
```

今天只要理解它是一个 32-bit instruction：

$$
32\ \text{bits} = 8\ \text{hex digits}
$$

每个十六进制字符表示：

$$
1\ \text{hex digit} = 4\ \text{bits}
$$

### 练习 2：手写 `addi` 数据流

把这条指令写成数据流：

```asm
addi t0, x0, 5
```

应该得到：

```text
rs1 = x0 = 0
imm = 5
ALU result = 0 + 5 = 5
rd = t0
t0 <- 5
PC <- PC + 4
```

### 练习 3：理解符号扩展

如果 12-bit immediate 是：

```text
1111_1111_1111
```

它不是 unsigned 的 4095，而是 two's complement 里的 -1。

扩展到 32-bit 后：

```text
1111_1111_1111_1111_1111_1111_1111_1111
```

也就是：

$$
\operatorname{SignExt}(0b111111111111) = -1
$$

这就是为什么 `addi x1, x1, -1` 可以用 12-bit immediate 表示。

## 今天的输出

今天结束时，在本文件下面追加三段自己的话：

```text
1. 我现在如何理解 CPU 执行一条 addi？
2. signed / unsigned 最大的区别是什么？
3. 我觉得当前项目 Part A 最难的地方是什么？
```

## 和当前项目的连接

Day 1 对应项目的准备工作：

| 今天学的内容 | 之后会用在哪里 |
|---|---|
| binary / hex | 看测试输入、机器码、Logisim 常量 |
| two's complement | ALU 的 signed compare / arithmetic shift |
| sign extension | ImmGen、load byte/half、branch immediate |
| RISC-V register | RegFile |
| `addi` | Part A CPU |
| PC + 4 | 取指阶段 |
