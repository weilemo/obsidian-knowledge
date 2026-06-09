# CS61C 学习总览

## 课程定位

CS61C: Great Ideas in Computer Architecture 是 UC Berkeley 的计算机组成 / 体系结构入门课。它从 C 程序如何落到机器执行开始，逐步进入 RISC-V 汇编、数字逻辑、CPU 数据通路、流水线、Cache 和并行性能。

对当前计算机体系结构项目来说，最相关的主线是：

1. 数字表示：二进制、十六进制、补码、符号扩展、位运算。
2. RISC-V：寄存器、指令格式、立即数、load/store、branch/jump。
3. 同步数字系统：组合逻辑、寄存器、时钟、状态。
4. 单周期 CPU：PC、取指、译码、执行、访存、写回。
5. 流水线 CPU：pipeline register、control hazard、flush / nop。

## 官方资源

- 课程主页：<https://cs61c.org/>
- 课程笔记：<https://notes.cs61c.org/>
- Venus RISC-V 工具：<https://venus.cs61c.org/>
- RV32I Green Card：<https://notes.cs61c.org/references/rv32i-green-card/>

## 当前项目对应 CS61C 内容

| 当前项目模块 | CS61C 对应内容 | 学习目的 |
|---|---|---|
| ALU | L17-L20 Synchronous Digital Systems / ALU | 会用组合逻辑实现算术、逻辑、移位和比较 |
| RegFile | L18 State / L21 Datapath | 理解寄存器、写使能、时钟上升沿 |
| ImmGen | L13-L14 RISC-V Instruction Formats | 会从机器码中抽取不同类型的立即数 |
| control_logic | L23 Control | 根据 opcode / funct3 / funct7 生成控制信号 |
| cpu.circ | L21-L23 Single-Cycle CPU | 打通取指、译码、执行、访存、写回 |
| 两级流水线 | L24-L25 Pipelining | 理解流水线寄存器、分支 kill、nop |
| load/store | L10 RISC-V Data Transfer / L26-L29 Caches | 理解地址、字节、半字、字、符号扩展、写掩码 |

## 学习节奏

第一阶段先服务项目，不完整刷课：

1. Day 1：数字表示 + RISC-V 最小入门。
2. Day 2：RISC-V 访存 + 指令格式与立即数。
3. Day 3：同步数字系统、组合逻辑、状态元件与寄存器。
4. Day 4：MUX、加减器与 ALU。
5. Day 5：单周期 CPU 数据通路 I：R-type 与 `addi`。
6. Day 6：Datapath II、load/store、branch/jump、控制逻辑与 timing。
7. Day 7：Pipeline、hazards、branch kill 与项目汇报收束。
