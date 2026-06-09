# Day 7 - Pipeline Hazards 与项目汇报收束

## 今天目标

Day 7 是这一轮项目导向学习的收束日：把 single-cycle CPU 推进到 pipeline，并把项目汇报主线整理出来。

学完今天内容后，要能回答：

1. pipeline 为什么能提升 throughput？
2. 五级流水线 IF/ID/EX/MEM/WB 和当前项目两级流水线是什么关系？
3. pipeline register 保存什么？
4. structural / data / control hazard 分别是什么？
5. 当前项目为什么 branch/jump 后要 kill 下一条错误取到的 instruction？

## 今天要看的 CS61C 内容

本地资料入口：[[../02 Lecture Notes/Day 7 Materials Index]]

官方课程页：<https://cs61c.org/sp26/>

### 1. Lecture 24: RISC-V 5-Stage Pipeline I

重点看：

```text
latency vs throughput
pipeline register
5-stage pipeline
IF / ID / EX / MEM / WB
```

### 2. Lecture 25: RISC-V 5-Stage Pipeline II

重点看：

```text
structural hazard
data hazard
control hazard
bubble
forwarding
flush / kill
```

## 1. Pipeline 的直觉

single-cycle CPU 一次完整做完一条指令。

pipeline 的思想是把执行过程切成阶段：

```text
IF -> ID -> EX -> MEM -> WB
```

不同指令可以同时处在不同阶段。

这提升的是 throughput：

```text
单位时间完成更多指令
```

不一定降低单条指令 latency。

## 2. 五级流水线

经典五级 RISC-V pipeline：

```text
IF:  fetch instruction
ID:  decode and read registers
EX:  ALU execute / branch compare
MEM: data memory access
WB:  write back
```

阶段之间要放 pipeline register：

```text
IF/ID
ID/EX
EX/MEM
MEM/WB
```

这些 register 保存的不只是 instruction，还包括后续阶段需要的值：

```text
PC
rs1/rs2 values
immediate
rd
control signals
ALU result
memory data
```

## 3. 当前项目的两级流水线

当前项目不是完整五级，而是两级：

```text
Stage 1: IF
Stage 2: ID + EX + MEM + WB
```

所以至少要在 IF 和 EX 之间保存：

```text
instruction
PC
```

也就是：

```text
IF/EX instruction register
IF/EX PC register
```

如果不保存 PC，branch/jump 在执行阶段就不知道自己对应的是哪条指令的 PC。

## 4. Hazards

pipeline 的难点是 hazard。

### 4.1 Structural Hazard

硬件资源冲突。

例如同一周期两个阶段都要用同一个 memory。

### 4.2 Data Hazard

后一条指令需要前一条指令还没写回的结果。

例如：

```asm
add  t0, t1, t2
addi t3, t0, 1
```

第二条需要 `t0`，但第一条可能还没写回。

### 4.3 Control Hazard

branch/jump 改变 PC，但 pipeline 已经取了下一条指令。

例如：

```asm
beq t0, t1, target
addi t2, x0, 5
target:
```

如果 branch taken，`addi t2, x0, 5` 是错误路径上的指令，不能执行。

## 5. 项目里的 kill / nop

当前项目要求：

```text
branch taken 或 jump 时，kill 下一条错误取到的 instruction
```

kill 的方式是把错误 instruction 替换成 `nop`。

RISC-V 常用 nop：

```asm
addi x0, x0, 0
```

机器码：

```text
0x00000013
```

它不会改变任何状态，因为：

```text
x0 永远是 0
写 x0 也无效
```

所以它可以安全地占一个周期。

## 6. 汇报主线

项目汇报建议按这个顺序收束：

```text
1. 目标：用 Logisim 搭一个简化 RISC-V CPU
2. ISA：软件和硬件之间的契约
3. Datapath：PC / RegFile / ImmGen / ALU / Memory / Writeback
4. Control：opcode/funct3/funct7 -> control signals
5. Pipeline：IF 与执行阶段重叠
6. Hazard：branch/jump 后需要 kill wrong-path instruction
7. 测试：ALU / RegFile / addi / pipelined / Part B
```

一句话总结：

```text
这个项目把 RISC-V 指令从 bit-level encoding 落到 CPU datapath 和 control logic 的实际电路执行。
```

## 今日练习

1. 用自己的话解释 throughput 和 latency。
2. 画出当前项目两级流水线。
3. 解释为什么 IF/EX 之间要保存 instruction 和 PC。
4. 解释 branch taken 后为什么要插入 `nop`。
5. 写一版 2 分钟项目汇报口头稿。

## 和当前 CPU 项目的连接

| Day 7 内容 | 项目模块 |
|---|---|
| pipeline register | IF/EX instruction register, IF/EX PC register |
| control hazard | branch/jump kill |
| nop | `0x00000013` |
| latency / startup delay | `addi_single` vs `addi_pipelined` 输出差别 |
| hazards | Part B 分支跳转测试 |

## 今天的输出

今天结束时写 4 个小总结：

```text
1. pipeline 提升的到底是什么？
2. 当前项目两级流水线和五级流水线有什么关系？
3. branch/jump 为什么会产生 control hazard？
4. 我的项目汇报最核心的 3 页应该是哪 3 页？
```

