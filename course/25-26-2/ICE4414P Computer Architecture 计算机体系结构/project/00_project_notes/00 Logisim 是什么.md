# Logisim 是什么

## 1. 一句话

Logisim 是一个数字逻辑电路模拟器。它让你用图形界面拖拽 wires、gates、MUX、register、ALU、memory 等组件，搭出一个可以被时钟驱动和测试的电路。

当前项目用的是：

```text
logisim-evolution.jar
```

也就是 Logisim Evolution，一个维护得更现代的版本。

## 2. 它和写代码有什么不同

写普通程序时，你写的是顺序执行的代码：

```text
step 1
step 2
step 3
```

在 Logisim 里，你画的是硬件连接：

```text
input signal -> combinational logic -> output signal
```

很多东西是同时发生的。例如 ALU 里可以同时计算：

```text
add_result
and_result
or_result
xor_result
shift_result
```

然后用 `ALUSel` 通过 MUX 选择一个输出。

## 3. Logisim 中常见对象

| 对象 | 作用 | 项目中例子 |
|---|---|---|
| Wire | 连接信号 | 连接 ALU、RegFile、MUX |
| Pin | 电路输入/输出接口 | `A`, `B`, `ALUSel`, `Result` |
| Tunnel | 给线命名，减少交叉线 | `rs1`, `rd`, `imm` |
| Splitter | 拆分或合并 bit fields | 从 instruction 拆 `rs1/rs2/rd/opcode` |
| MUX | 多路选择 | `WBSel`, `BSel`, `PCSel`, `ALUSel` |
| Register | 保存状态 | PC、pipeline register |
| Clock | 驱动状态更新 | RegFile 写入、PC 更新 |
| Subcircuit | 子电路模块 | `alu.circ`, `regfile.circ`, `cpu.circ` |

## 4. 组合逻辑 vs 状态元件

Logisim 项目里最重要的区分是：

```text
组合逻辑：输入一变，输出随之变化，不记历史。
状态元件：保存值，通常在 clock edge 更新。
```

组合逻辑例子：

```text
ALU
ImmGen
Branch Comparator
Control Logic
MUX
```

状态元件例子：

```text
PC register
RegFile
IF/EX pipeline register
CSR
```

## 5. 当前项目里 Logisim 要做什么

本项目不是写一个 RISC-V 模拟器，而是在 Logisim 里实现一个简化 CPU。

最终目标：

```text
输入 RISC-V machine instruction
-> CPU 数据通路执行
-> 更新 PC / RegFile / Memory / CSR
```

你会逐步实现：

```text
alu.circ
regfile.circ
imm_gen.circ
branch_comp.circ
control_logic.circ
csr.circ
cpu.circ
```

## 6. 最小理解闭环

以：

```asm
addi t0, x0, 5
```

为例。

在 CPU 里它会变成：

```text
PC -> instruction memory -> instruction bits
instruction bits -> rs1 / rd / imm
RegFile reads x0
ImmGen outputs 5
ALU computes 0 + 5
RegFile writes t0
PC updates to PC + 4
```

这条路径就是本项目 Part A 的核心。

