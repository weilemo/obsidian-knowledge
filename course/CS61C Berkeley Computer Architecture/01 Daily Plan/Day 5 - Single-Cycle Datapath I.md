# Day 5 - Single-Cycle Datapath I

## 今天目标

前四天我们已经把 CPU 项目的零件补齐了很多：

```text
Day 1: bit / addi / RISC-V 最小闭环
Day 2: load-store / instruction formats / immediate
Day 3: combinational logic / state / clock
Day 4: MUX / adder-subtractor / ALU
```

Day 5 开始把这些零件真正串成 CPU 的 single-cycle datapath。今天重点不是完整支持所有指令，而是把 **R-type 和 `addi` 的数据流** 看懂。

学完今天内容后，要能回答：

1. datapath 和 control 分别是什么？
2. 一条 RISC-V 指令在 single-cycle CPU 里经过哪五步？
3. `add rd, rs1, rs2` 的数据如何从 RegFile 流到 ALU 再写回 RegFile？
4. `addi rd, rs1, imm` 为什么需要 ImmGen 和 ALU input MUX？
5. 当前项目 Part A 的 `addi_single` 到底要连通哪些模块？

## 今天要看的 CS61C 内容

本地资料入口：[[../02 Lecture Notes/Day 5 Materials Index]]

官方课程页：<https://cs61c.org/sp26/>

### 1. Lecture 21: RISC-V Single-Cycle Datapath I

重点看：

```text
datapath vs control
five steps to execute an instruction
state elements on datapath
R-type datapath
supporting immediates
```

今天先不急着看完整 load/store/branch/jump，那些放到下一天。

## 1. Datapath vs Control

CPU 可以分成两部分：

```text
datapath = 数据实际流动和计算的硬件
control  = 决定 datapath 怎么走的控制信号
```

datapath 包括：

```text
PC
Instruction Memory
RegFile
ImmGen
ALU
Data Memory
Writeback MUX
PC MUX
```

control 包括：

```text
RegWEn
ImmSel
ALUSel
ASel
BSel
MemRW
WBSel
PCSel
```

一句话：

```text
datapath 是路和设备
control 是红绿灯和开关
```

## 2. 五步执行流程

RISC-V 指令通常可以拆成五步：

```text
IF  Instruction Fetch
ID  Instruction Decode
EX  Execute
MEM Memory Access
WB  Write Back
```

### 2.1 IF

取指：

```text
PC -> Instruction Memory -> instruction
```

顺序执行时：

$$
PC_{next} = PC + 4
$$

因为 RV32I 一条指令是 32 bits，也就是 4 bytes。

### 2.2 ID

译码：

```text
instruction -> opcode / rd / rs1 / rs2 / funct3 / funct7 / imm
```

同时 RegFile 根据 `rs1` 和 `rs2` 读寄存器：

```text
R[rs1]
R[rs2]
```

### 2.3 EX

执行：

```text
ALU computes result
```

例如：

```asm
add t0, t1, t2
```

对应：

$$
ALUResult = R[t1] + R[t2]
$$

### 2.4 MEM

访存：

```text
load: read data memory
store: write data memory
```

今天先知道这一步存在即可。`add` 和 `addi` 不用数据内存。

### 2.5 WB

写回：

```text
write result back to rd
```

例如：

$$
R[rd] = ALUResult
$$

## 3. Single-cycle 的意思

single-cycle CPU 的意思是：一条指令在一个 clock cycle 内完成所有需要的步骤。

从一个 rising edge 开始：

```text
state elements 输出当前状态
组合逻辑开始传播
指令完成 IF/ID/EX/MEM/WB 的所有组合逻辑
结果在下一个 rising edge 写入 state elements
```

所以：

```text
RegFile 写入发生在 clock edge
PC 更新也发生在 clock edge
```

但 ALU / ImmGen / MUX / control logic 都是在这个周期中间组合地产生结果。

## 4. R-type datapath

以：

```asm
add t0, t1, t2
```

为例。

语义：

$$
R[t0] = R[t1] + R[t2]
$$

数据流：

```text
PC
-> instruction memory
-> instruction
-> split rs1=t1, rs2=t2, rd=t0
-> RegFile reads R[t1], R[t2]
-> ALU A = R[t1]
-> ALU B = R[t2]
-> ALUSel = add
-> ALUResult
-> Writeback MUX selects ALUResult
-> RegFile writes rd=t0
```

控制信号可以理解为：

```text
RegWEn = 1
BSel = rs2
ALUSel = add
WBSel = ALU
MemRW = 0
PCSel = PC + 4
```

## 5. I-type arithmetic: addi

`addi` 和 `add` 很像，但第二个 ALU 输入不是 `rs2`，而是 immediate。

```asm
addi t0, t1, 5
```

语义：

$$
R[t0] = R[t1] + \operatorname{SignExt}(5)
$$

数据流：

```text
instruction
-> split rs1=t1, rd=t0, imm bits
-> RegFile reads R[t1]
-> ImmGen generates SignExt(imm)
-> ALU A = R[t1]
-> ALU B = imm
-> ALUSel = add
-> ALUResult
-> Writeback MUX selects ALUResult
-> RegFile writes rd=t0
```

关键差别：

```text
add:  ALU B = R[rs2]
addi: ALU B = immediate
```

所以 CPU 需要一个 ALU B MUX：

```text
R[rs2] ----\
           MUX -> ALU B
imm   ----/
```

控制信号 `BSel` 决定选哪个。

## 6. 和当前项目 Part A 的对应

你的项目 Part A 的 `addi_single` 本质上就是要打通这条路：

```text
fetch_addr / PC
-> INSTRUCTION
-> split rs1 / rd / imm
-> RegFile read rs1
-> ImmGen sign extend immediate
-> ALU add
-> RegFile write rd
-> PC + 4
```

因为 Part A 只要求 `addi`，很多控制信号可以先硬连成常量：

```text
RegWEn = 1
ALUSel = add
BSel = imm
WBSel = ALU
MemRW = 0
PCSel = PC + 4
ImmSel = I-type
```

这也是为什么项目说明会说：Part A 可以先用 constants，Part B 再做真正的 control logic。

## 7. 今日练习

### 练习 1：画出 `add` 数据流

对：

```asm
add t0, t1, t2
```

写出：

```text
rs1 =
rs2 =
rd =
ALU A =
ALU B =
WBSel =
RegWEn =
```

### 练习 2：画出 `addi` 数据流

对：

```asm
addi t0, t1, 5
```

写出：

```text
rs1 =
rd =
immediate =
ALU A =
ALU B =
ALUSel =
WBSel =
RegWEn =
```

### 练习 3：解释 `add` 和 `addi` 的共同点和差别

至少写出：

```text
共同点：都读 rs1，都用 ALU，都写回 rd
差别：add 的 ALU B 来自 rs2；addi 的 ALU B 来自 ImmGen
```

### 练习 4：连接到 Logisim 项目

列出 `addi_single` 至少需要哪些子模块：

```text
PC register
instruction splitter
RegFile
ImmGen
ALU
Writeback path
PC + 4 adder
```

## 今天暂时不用深挖

今天先不深挖：

```text
load/store datapath
branch datapath
jump datapath
full control truth table
pipeline
critical path 计算
```

这些留到下一天和再下一天。

## 和当前 CPU 项目的连接

| Day 5 内容 | 项目模块 |
|---|---|
| IF | `fetch_addr`, PC, `INSTRUCTION` |
| ID | splitter, instruction fields |
| RegFile read/write | `regfile.circ` |
| immediate | `imm_gen.circ` |
| EX | `alu.circ` |
| WB | writeback MUX / Write Data |
| control constants | Part A `addi` CPU |

尤其要记住：

```text
Part A 的 addi 不是小功能。
它是完整 CPU 数据通路的最小闭环。
```

## 今天的输出

今天结束时，在下面追加自己的 4 个小总结：

```text
1. 我如何区分 datapath 和 control？
2. single-cycle CPU 的一个 cycle 里发生了什么？
3. add 和 addi 在数据通路上差在哪里？
4. 我现在能不能从 PC 开始完整讲出 addi 的执行路径？
```

