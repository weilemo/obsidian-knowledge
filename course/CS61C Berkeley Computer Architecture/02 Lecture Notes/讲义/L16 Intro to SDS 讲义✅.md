# L16 Intro to Synchronous Digital Systems 讲义

来源：[[../Slides/L16 Intro to SDS.pdf]]

配套官方 notes：[[../Notes/L16 Intro to SDS - official notes.html]]

## 0. 本讲目标

前面 L09-L14 已经从 C/assembly 走到了 RISC-V machine code：

```text
C program
-> RISC-V assembly
-> 32-bit machine instructions
```

这一讲开始往更低一层走：

```text
machine code
-> processor hardware
-> wires, gates, registers, clock
```

核心问题是：

```text
怎样设计能执行 RISC-V 指令的硬件？
```

本讲要掌握：

1. 为什么要学 hardware design。
2. 什么是 synchronous digital system，简称 SDS。
3. SDS 由哪两类基本电路组成：combinational logic 和 state elements。
4. wire/signal/binary voltage 的直觉。
5. logic gate 和 truth table 的关系。
6. 如何把小逻辑块组合成更大的功能块，例如 32-bit equality compare。

对 CPU 项目来说，这讲是从“指令语义”进入“Logisim 电路”的入口。

## 1. 为什么学硬件设计

课程的 Great Idea #1 是 abstraction。我们之前已经看过：

```text
High-level language
-> Assembly language
-> Machine code
```

现在要继续往下：

```text
Machine code
-> Datapath and control
-> Logic gates
-> Transistors and wires
```

学习硬件设计不是为了让所有人都去造芯片，而是为了真正理解计算机为什么有这些能力和限制。例如：

```text
为什么我的电脑慢？
为什么电池耗得快？
为什么有些任务需要 GPU / NPU / custom hardware？
为什么 CPU 不能无限加速？
```

如果只停留在 programming 层，就只能看到软件接口；理解硬件后，才能知道 processor 实际上怎样执行机器码，以及为什么某些设计选择会影响性能、能耗和成本。

## 2. 从现代芯片看硬件复杂度

现代 integrated chip，简称 IC，由大量 wires 和 transistors 组成。

课件以 Apple A14 Bionic 为例：

```text
11.8 billion transistors
5W power consumption
six CPU cores up to 3.0 GHz
64-bit CPU support
GPU
Neural Engine / NPU
AMX matrix accelerator
L2 cache: 4-8 MB
```

这说明现代处理器不是一个单一计算单元，而是多个 domain-specific processors 和 memory hierarchy 组成的系统。

但不管规模多复杂，底层基本元素仍然是：

```text
wires + transistors
```

CS61C 这里不深入晶体管物理，而是从能构造 processor 的数字逻辑抽象开始。

## 3. Transistor 的角色

transistor 是现代电子系统的关键器件。它可以放大或切换信号。

在数字电路视角下，可以先把 transistor 理解成一种受控开关：

```text
control signal decides whether a path conducts
```

在 transistor 出现之前，早期计算机用 vacuum tubes。transistor 和 integrated circuit 的出现让电路规模、可靠性、成本和功耗都发生了质变，最终才有现代 microprocessor。

本讲后面不会要求你画 CMOS transistor-level 电路；重点是知道 logic gate 可以由 transistors 实现，而更大的 CPU 电路可以由 logic gates 和 state elements 组合出来。

## 4. Moore's Law

Moore's Law 通常描述为：单个芯片上的 transistor 数量会随时间快速增长，早期大致每隔一段时间翻倍。

课件展示了从早期 Intel 8008、Pentium 到更现代 processor 的 transistor count 增长。它背后的意义不只是“芯片越来越强”，还包括：

```text
more transistors per die
-> more complex functions on one chip
-> lower cost per function
-> more cache, more cores, more accelerators
```

但近年这种增长趋势开始放缓，也就是课件中 “Moore's Law seems to be tapering?” 的问题。

对体系结构来说，这意味着不能只依赖制程自动变好，还需要更好的 architecture、parallelism、cache、specialized accelerator 等设计。

## 5. 什么是 Synchronous Digital System

几乎所有 processor 底层都可以看成 synchronous digital system。

这个词拆开：

```text
synchronous: operations coordinated by a central clock
digital: values represented by discrete symbols, usually 0 and 1
system: many components connected together
```

### Synchronous

synchronous 意味着系统中关键状态更新由一个 clock 协调。

clock 像系统的 heartbeat。每个 clock cycle，状态元件在约定的时刻更新；在两个 clock edge 之间，组合逻辑根据当前输入计算输出。

直觉上：

```text
clock edge: save/update state
between edges: combinational logic computes
```

### Digital

digital 意味着信号只表示离散值。最常见就是 binary：

```text
low voltage  -> 0
high voltage -> 1
```

复杂信息不是通过让单根 wire 表示很多连续值，而是通过很多 binary signals 组合出来。

## 6. SDS 的两类电路

SDS 由两类基本电路组成。

第一类是 combinational logic circuits：

```text
output is a function of current inputs only
```

数学上像纯函数：

$$
y = f(x)
$$

更一般地：

$$
y = f(x_1, x_2, \ldots, x_n)
$$

它没有 memory，不会记住上一次输入发生了什么。

CPU 里的例子：

```text
ALU
ImmGen
branch comparator
control logic
mux
decoder
```

第二类是 state elements：

```text
circuits that store information
```

例子：

```text
register
PC
RegFile
pipeline register
```

state element 让系统能记住过去的信息。没有 state element，CPU 只能是一个巨大的纯函数，不能保存 PC、寄存器值、流水线阶段状态。

## 7. Wire、Signal、Bus

在 chip 或 PC board 上，wire，也就是 electrical node，用来传递 electrical signal。

一根 wire 在某个时间点可以表示一个 binary value：

```text
0 or 1
```

但一根 wire 只能表示 1 bit。如果要表示多位变量，就用一组 wires。

例如一个 8-bit 变量 $X$ 可以由 8 根 wire 表示：

$$
X = x_7x_6x_5x_4x_3x_2x_1x_0
$$

其中每个 $x_i$ 都是一根 1-bit wire 上的 signal。

在 Logisim 里，这就是你看到的 bus：

```text
1-bit wire: one signal
n-bit bus: bundle of n wires
```

例如 RV32I 的 register value 是 32 bits，因此 datapath 中很多 bus 都是 32-bit wide。

## 8. 为什么用 binary signal

现实电压不是完美的 0 或 1，会有噪声、干扰和非理想因素。

digital circuit 的思想是把电压划分成稳定区域：

```text
low enough  -> interpret as 0
high enough -> interpret as 1
```

这样系统不需要精确区分很多连续电压值，只需要可靠地区分两类。这让电路更容易设计、更抗干扰。

复杂性不放在“单根 wire 表示复杂值”里，而是放到“很多简单 binary signal 如何组合”里。

## 9. Combinational Logic Circuit

要用 binary signals 计算复杂函数，先定义 primitive operators，再组合它们。

这些 primitive operators 就是 logic gates。

最简单的 logic gate 通常是：

```text
one or two binary inputs
one binary output
```

例如：

```text
NOT: one input
AND, OR, XOR, NAND, NOR: two inputs
```

组合逻辑电路本质上就是由这些 gates 连接起来的函数。

## 10. Truth Table

truth table 枚举所有输入组合，并写出对应输出。

如果有 $n$ 个 binary inputs，那么输入组合数是：

$$
2^n
$$

例如 2-input gate 有：

$$
2^2 = 4
$$

种输入组合：

```text
00
01
10
11
```

truth table 是从“函数定义”到“电路行为”的桥梁。

## 11. AND Gate

2-input AND gate：

```text
y = AND(a, b)
```

定义：

```text
y = 1 iff both a and b are 1
otherwise y = 0
```

truth table：

```text
a b | y
0 0 | 0
0 1 | 0
1 0 | 0
1 1 | 1
```

也就是：

$$
y = a \land b
$$

在 CPU 中，AND gate 可以用来做 bit masking、控制信号组合、条件判断的一部分。

## 12. OR Gate

2-input OR gate：

```text
y = OR(a, b)
```

定义：

```text
y = 1 iff at least one of a and b is 1
```

truth table：

```text
a b | y
0 0 | 0
0 1 | 1
1 0 | 1
1 1 | 1
```

公式：

$$
y = a \lor b
$$

## 13. NOT Gate

NOT gate 只有一个输入：

```text
y = NOT(a)
```

truth table：

```text
a | y
0 | 1
1 | 0
```

公式：

$$
y = \lnot a
$$

NOT 用来反转条件。例如 branch comparator 得到 `equal` 后，`bne` 可以使用 `not equal`。

## 14. NAND、NOR、XOR

NAND 是 NOT of AND：

$$
\text{NAND}(a,b) = \lnot(a \land b)
$$

truth table：

```text
a b | y
0 0 | 1
0 1 | 1
1 0 | 1
1 1 | 0
```

NOR 是 NOT of OR：

$$
\text{NOR}(a,b) = \lnot(a \lor b)
$$

truth table：

```text
a b | y
0 0 | 1
0 1 | 0
1 0 | 0
1 1 | 0
```

XOR 是 exclusive OR：

```text
y = 1 iff exactly one input is 1
```

truth table：

```text
a b | y
0 0 | 0
0 1 | 1
1 0 | 1
1 1 | 0
```

公式：

$$
y = a \oplus b
$$

XOR 常用于 bitwise difference、加法器中的 sum bit、equality compare 的基础构造。

## 15. N-input Gates

很多 gates 可以推广到 $n$ 个输入。

N-input AND：

```text
y = 1 iff all inputs are 1
```

例如：

$$
y = \text{AND}(a,b,c,d)
$$

当且仅当：

$$
a=b=c=d=1
$$

时 $y=1$。

N-input NAND 是 N-input AND 后再 NOT：

$$
\text{NAND}(x_1,\ldots,x_n)=\lnot(x_1 \land \cdots \land x_n)
$$

N-input NOR 是 N-input OR 后再 NOT：

$$
\text{NOR}(x_1,\ldots,x_n)=\lnot(x_1 \lor \cdots \lor x_n)
$$

N-input XOR 的定义是：

```text
y = 1 iff number of 1s among all inputs is odd
```

也就是奇偶校验意义上的 odd parity。

## 16. 从 Circuit 到 Truth Table

一个 gate diagram 可以通过 truth table 理解。

课件给了一个两输入电路，最后得到 truth table：

```text
a b | y
0 0 | 1
0 1 | 0
1 0 | 0
1 1 | 1
```

这个函数的含义是：

```text
y = 1 iff a == b
```

也就是 1-bit equality compare。

公式可以写成：

$$
y = (a \land b) \lor (\lnot a \land \lnot b)
$$

也可以理解成 XNOR：

$$
y = \lnot(a \oplus b)
$$

这里的设计流程是：

```text
gate diagram
-> enumerate truth table
-> infer function
-> package as reusable combinational block
```

一旦确认这个电路实现了 1-bit compare，就可以把它抽象成一个模块：

```text
a, b -> ==1? -> y
```

以后设计更复杂电路时，不需要每次都重新展开内部 gates。

## 17. 32-bit Equality Compare

RISC-V 中的 `beq` 指令需要比较两个寄存器值：

```asm
beq rs1 rs2 label
```

语义：

```text
if R[rs1] == R[rs2]:
    PC = label
else:
    PC = PC + 4
```

所以 processor 中必须有一个电路，能比较两个 32-bit values 是否相等。

抽象接口：

```text
A[31:0], B[31:0] -> ==32? -> z
```

其中：

```text
z = 1 iff A == B
```

也就是：

$$
z = 1 \iff A = B
$$

## 18. 为什么 32-bit Compare 不能直接写完整 truth table

如果比较两个 32-bit 输入：

```text
A has 32 bits
B has 32 bits
```

总输入位数是：

$$
32 + 32 = 64
$$

truth table 行数是：

$$
2^{64}
$$

这太大了，无法手写，也不适合作为设计方法。

这正是 modular design 的动机：

```text
If truth tables are too big, define smaller blocks first.
```

## 19. Modular Design：把 32-bit Compare 分解

虽然完整 truth table 太大，但我们知道目标功能：

```text
A == B iff every bit matches
```

也就是：

$$
A = B \iff a_{31}=b_{31} \land a_{30}=b_{30} \land \cdots \land a_0=b_0
$$

先用 1-bit equality compare 比较每一位：

```text
eq31 = (a31 == b31)
eq30 = (a30 == b30)
...
eq0  = (a0  == b0)
```

再用 32-input AND 合并：

$$
z = eq_{31} \land eq_{30} \land \cdots \land eq_0
$$

这就是：

```text
32 个 1-bit compare
-> 1 个 32-input AND
-> 1-bit result z
```

这种方法把一个看似巨大的 truth table 问题，变成了可组合的小模块问题。

## 20. 32-input AND 怎么实现

功能上，32-input AND 可以看成：

$$
z = y_{31} \land y_{30} \land \cdots \land y_0
$$

实际电路中不一定画一个巨大 gate，而是可以递归组合多个小 AND gates。

例如：

```text
level 1: pairwise AND
level 2: AND results of level 1
...
final: one output z
```

这种树状结构也会影响 propagation delay。虽然 L16 还没有展开 timing，但直觉上 gate 层数越多，信号稳定需要的时间越长。

## 21. 和 CPU 项目的对应关系

这讲的概念可以直接映射到 Logisim CPU。

### Wire / bus

```text
Logisim 里的线 = signal
多位线束 = bus
```

例如：

```text
instruction[31:0]
rs1_data[31:0]
rs2_data[31:0]
alu_result[31:0]
```

都是 multi-bit bus。

### Combinational logic

这些模块通常是组合逻辑：

```text
ALU
ImmGen
control_logic
branch comparator
mux
decoder
```

它们的特点：

```text
same inputs -> same outputs
no memory
no clock needed for the pure combinational part
```

### State elements

这些模块保存状态：

```text
PC
RegFile
pipeline registers
instruction memory / data memory in simplified model
```

它们的特点：

```text
state changes on clock edge or under write enable
current output may depend on previously stored value
```

### Branch comparator

`beq` 需要 equality compare：

```text
rs1_data == rs2_data
```

这个比较器就是 L16 中 32-bit equality compare 的 CPU 应用。

## 22. 本讲最小闭环

这一讲最小要记住：

```text
CPU is a synchronous digital system.
SDS = combinational logic + state elements + clock coordination.
Wires carry binary signals.
Bundles of wires represent multi-bit values.
Logic gates implement Boolean functions.
Truth tables define behavior for small combinational circuits.
Large circuits are designed modularly from smaller blocks.
```

两类电路：

```text
Combinational logic:
output = function of current inputs only

State element:
stores information across time
```

最重要公式：

$$
y = f(x_1,x_2,\ldots,x_n)
$$

表示组合逻辑。

32-bit equality compare：

$$
z = 1 \iff A = B
$$

分解后：

$$
z = (a_{31}=b_{31}) \land (a_{30}=b_{30}) \land \cdots \land (a_0=b_0)
$$

下一讲 L17 会继续把 combinational logic 展开到 Boolean algebra、MUX、decoder 等更接近 CPU datapath 的组件。
