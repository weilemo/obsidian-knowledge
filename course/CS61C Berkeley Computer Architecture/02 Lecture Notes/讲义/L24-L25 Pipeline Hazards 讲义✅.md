# L24-L25 Pipeline Hazards 讲义

来源：

- [[../Slides/L24 Pipeline I 5-Stage Pipeline.pdf]]
- [[../Slides/L25 Pipeline II Hazards.pdf]]

配套官方 notes：

- [[../Notes/L24 Pipeline Performance Metrics - official notes.html]]
- [[../Notes/L24 Pipelining Laundry - official notes.html]]
- [[../Notes/L24 RISC-V 5-Stage Pipeline - official notes.html]]
- [[../Notes/L25 Pipeline Hazards Intro - official notes.html]]
- [[../Notes/L25 Structural Hazards - official notes.html]]
- [[../Notes/L25 Data Hazards Forwarding - official notes.html]]
- [[../Notes/L25 Control Hazards - official notes.html]]
- [[../Notes/L25 Pipeline Hazards Summary - official notes.html]]

## 0. 本讲目标

single-cycle CPU 简单，但 clock period 被最慢指令限制。

pipeline 的目标是：

```text
把一条长路径切成多个阶段
让多条指令重叠执行
提高 throughput
```

当前 CPU 项目要求的是两级流水线：

```text
Stage 1: IF
Stage 2: ID + EX + MEM + WB
```

CS61C 讲的是经典五级流水线：

```text
IF / ID / EX / MEM / WB
```

本讲要掌握：

1. latency 和 throughput 的区别。
2. pipeline register 为什么必要。
3. 五级流水线每一级做什么。
4. structural/data/control hazard 分别是什么。
5. 当前项目为什么 branch/jump 后要 kill wrong-path instruction。
6. 为什么 `nop = 0x00000013` 可以安全插入流水线。

## 1. Latency vs Throughput

latency 是单个任务从开始到完成的时间。

throughput 是单位时间完成多少任务。

pipeline 通常主要提升 throughput，而不是单条指令 latency。

洗衣服类比：

```text
洗衣
烘干
折叠
收纳
```

如果一批衣服完整做完再做下一批，throughput 很低。

如果第一批进入烘干时，第二批开始洗衣，多个任务就重叠了。

CPU pipeline 也是这样。

## 2. Single-cycle 到 Pipeline

single-cycle：

```text
一条指令在一个长 cycle 内完成 IF/ID/EX/MEM/WB
```

pipeline：

```text
每个 stage 做一部分
不同指令同时处在不同 stage
```

理想情况下，五级流水线填满后：

```text
每个 cycle 完成一条指令
```

但每条指令自身仍要经过多个 cycle 才完成。

## 3. 五级流水线

经典五级：

| Stage | 做什么 |
|---|---|
| IF | 根据 PC 取 instruction，计算 PC + 4 |
| ID | decode，读 RegFile，生成 immediate/control |
| EX | ALU 计算，branch compare/target |
| MEM | data memory read/write |
| WB | 写回 RegFile |

阶段之间需要 pipeline register：

```text
IF/ID
ID/EX
EX/MEM
MEM/WB
```

这些 register 的作用是保存本条指令后面还要用的信息。

## 4. Pipeline Register 保存什么

不是只保存 instruction。

例如 ID/EX register 可能要保存：

```text
PC
R[rs1]
R[rs2]
immediate
rd
control signals
```

EX/MEM register 可能保存：

```text
ALU result
store data
rd
memory control signals
writeback control signals
```

MEM/WB register 可能保存：

```text
memory read data
ALU result
rd
RegWEn
WBSel
```

一句话：

```text
后面 stage 还需要什么，就必须在 pipeline register 里带过去
```

## 5. 当前项目的两级流水线

项目不是完整五级，而是两级：

```text
Stage 1: IF
Stage 2: ID + EX + MEM + WB
```

所以 IF 和执行阶段之间至少要保存：

```text
instruction
PC
```

也就是：

```text
IF/EX instruction register
IF/EX PC register
```

为什么要保存 PC？

因为 branch/jump target 要用“正在执行的那条指令”的 PC，而不是 IF 阶段刚取下一条指令时的 PC。

如果 PC 搞混，branch target 会错。

## 6. Pipeline Startup Delay

流水线刚开始时，不是立刻每个 stage 都有有效指令。

例如两级流水线：

```text
cycle 1: IF 取第一条，EX 里还是空/nop
cycle 2: EX 执行第一条，IF 取第二条
```

所以输出会比 single-cycle 晚。

这也是项目里：

```text
addi_single
addi_pipelined
```

测试输出不一样的原因。

## 7. Hazards 总览

pipeline 的问题是：多条指令重叠后，可能互相打架。

三类 hazard：

```text
structural hazard: 硬件资源冲突
data hazard: 数据还没准备好
control hazard: 下一条 PC 不确定或取错
```

## 8. Structural Hazard

structural hazard 是硬件资源不够。

例如：

```text
IF stage 要读 instruction memory
MEM stage 要读/write data memory
```

如果 instruction memory 和 data memory 是同一个单端口 memory，就会冲突。

解决方法：

```text
增加硬件资源
stall
调整 pipeline
```

很多 RISC-V pipeline 用 separate instruction memory / data memory，避免这类冲突。

## 9. Data Hazard

data hazard 是后一条指令需要前一条还没写回的结果。

例如：

```asm
add  t0, t1, t2
addi t3, t0, 1
```

第二条要读 `t0`，但第一条可能还没到 WB。

解决方式：

```text
stall / bubble
forwarding
compiler scheduling
```

forwarding 的意思是：结果虽然还没写回 RegFile，但已经在 EX/MEM 或 MEM/WB 阶段产生了，可以直接旁路给后面的 ALU 输入。

当前项目的两级流水线相对简化，重点不是做完整 forwarding，而是理解 pipeline register 和 branch kill。

## 10. Control Hazard

control hazard 来自 branch/jump。

因为下一条 PC 可能不是 `PC + 4`。

例如：

```asm
beq t0, t1, target
addi t2, x0, 5
target:
addi t3, x0, 9
```

当 `beq` 在执行阶段才判断 taken 时，IF 阶段可能已经取了：

```asm
addi t2, x0, 5
```

如果 branch taken，这条已经取到的指令是 wrong-path instruction，不能执行。

## 11. Flush / Kill / Nop

处理 control hazard 的一种方法是 flush 或 kill。

在当前项目中，要求：

```text
如果 branch taken 或 jump，就把错误取到的 instruction 替换成 nop
```

RISC-V 常用 nop：

```asm
addi x0, x0, 0
```

机器码：

```text
0x00000013
```

为什么安全？

因为：

```text
x0 永远是 0
写 x0 无效
addi x0, x0, 0 不改变任何 architectural state
```

所以 nop 可以占一个周期，但不影响程序结果。

## 12. 当前项目 branch kill 的时序

两级流水线中：

```text
Stage 1 IF: 正在取下一条指令
Stage 2 EX: 正在执行上一条指令
```

当 Stage 2 判断：

```text
branch taken 或 jump
```

这时 Stage 1 已经取了顺序下一条 `PC + 4` 的指令。

如果跳转发生，这条顺序指令错了。

所以要：

```text
PC_next = branch/jump target
IF/EX instruction input = nop
```

也就是把 wrong-path instruction kill 掉。

## 13. 为什么不要在 IF 阶段提前算 branch

项目说明强调不要通过在 IF 阶段计算分支偏移来绕开问题。

原因是当前设计假设：

```text
所有 decode/control/compare 都在执行阶段
```

IF 阶段只负责取指。

所以正确做法是在执行阶段知道 branch/jump 后，再 flush/kill 取错的指令。

## 14. Pipeline 和汇报怎么讲

汇报时不要陷入“我加了几个寄存器”。

建议讲成：

```text
single-cycle CPU 一条指令走完整路径
pipeline 把路径分段
不同指令可以重叠
但 branch/jump 会让 IF 取到错误指令
所以需要 kill/nop
```

项目的两级流水线可以画成：

```text
Cycle n:
  IF: fetch instruction i+1
  EX: execute instruction i

if instruction i jumps:
  instruction i+1 is wrong
  replace it with nop
```

## 15. 项目汇报主线

可以用 7 页：

1. 项目目标：用 Logisim 实现简化 RISC-V CPU。
2. ISA：软件和硬件之间的契约。
3. Datapath：PC、RegFile、ImmGen、ALU、Memory、Writeback。
4. Control：`opcode/funct3/funct7` 生成控制信号。
5. Single-cycle：一条指令如何完成 IF/ID/EX/MEM/WB。
6. Pipeline：IF 和执行阶段重叠。
7. Hazards：branch/jump 后用 `nop` kill wrong-path instruction。

一句话总结：

```text
这个项目把 RISC-V 指令从 bit-level encoding 落到 datapath 和 control logic 的电路执行。
```

## 16. 和当前项目的对应

| 概念 | 项目里对应 |
|---|---|
| IF stage | `fetch_addr`, `INSTRUCTION` |
| EX stage | decode + ALU + MEM + WB |
| IF/EX register | 保存 instruction 和 PC |
| startup delay | pipelined test 比 single-cycle 慢一拍 |
| control hazard | branch/jump 后顺序取到的指令错误 |
| kill/flush | MUX 插入 `0x00000013` |
| nop | `addi x0, x0, 0` |

## 17. 本讲一句话总结

Pipeline 通过阶段重叠提升 throughput，但重叠执行会引入 hazards；当前项目最关键的是在两级流水线中保存 IF/EX 的 instruction 和 PC，并在 branch/jump 后用 `nop` kill 错误取到的指令。

## 18. 自查问题

1. pipeline 提升的是 latency 还是 throughput？
2. 五级流水线每一级做什么？
3. 当前项目两级流水线和五级流水线有什么关系？
4. IF/EX register 至少要保存什么？
5. data hazard 和 control hazard 的区别是什么？
6. 为什么 branch taken 后已经取到的下一条指令可能是错的？
7. 为什么 `0x00000013` 是安全的 nop？
8. 汇报时你会如何解释 branch kill？

