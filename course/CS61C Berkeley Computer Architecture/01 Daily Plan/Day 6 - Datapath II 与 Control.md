# Day 6 - Datapath II 与 Control

## 今天目标

Day 5 已经打通了 R-type 和 `addi`：

```text
PC -> instruction -> RegFile / ImmGen -> ALU -> writeback -> PC + 4
```

Day 6 要把 single-cycle datapath 扩展到更完整的指令类型，并开始真正理解 `control_logic.circ`。

学完今天内容后，要能回答：

1. `lw` / `sw` 在 datapath 上比 `addi` 多了什么？
2. branch / jump 如何改变 PC？
3. `BrUn`、`BrEq`、`BrLt` 分别是什么？
4. control logic 如何根据 `opcode/funct3/funct7` 产生控制信号？
5. 为什么 single-cycle CPU 的 clock period 被最慢指令限制？

## 今天要看的 CS61C 内容

本地资料入口：[[../02 Lecture Notes/Day 6 Materials Index]]

官方课程页：<https://cs61c.org/sp26/>

### 1. Lecture 22: RISC-V Single-Cycle Datapath II

重点看：

```text
load/store datapath
branch datapath
jump datapath
U-type datapath
```

### 2. Lecture 23: Control Logic, Instruction Timing

重点看：

```text
control signal table
hardwired control
instruction timing
critical path
```

## 1. Load Datapath

以：

```asm
lw t0, 8(sp)
```

为例。

语义：

$$
R[t0] = \operatorname{Mem}[R[sp] + \operatorname{SignExt}(8)]
$$

数据流：

```text
RegFile reads R[sp]
ImmGen generates offset
ALU computes address = R[sp] + offset
Data Memory reads address
Writeback MUX selects memory data
RegFile writes rd = t0
```

关键控制：

```text
BSel = imm
ALUSel = add
WBSel = memory
RegWEn = 1
MemRW = read
```

和 `addi` 的区别：

```text
addi: writeback = ALU result
lw:   writeback = memory read data
```

## 2. Store Datapath

以：

```asm
sw t1, 12(sp)
```

为例。

语义：

$$
\operatorname{Mem}[R[sp] + \operatorname{SignExt}(12)] = R[t1]
$$

数据流：

```text
RegFile reads R[sp] as base
RegFile reads R[t1] as store data
ImmGen generates offset
ALU computes address = R[sp] + offset
Data Memory writes R[t1] to address
```

关键控制：

```text
BSel = imm
ALUSel = add
RegWEn = 0
MemRW = write
Write_En = byte mask
```

注意：

```text
store 不写 rd
store 写 memory
```

## 3. Branch Datapath

以：

```asm
beq t0, t1, label
```

为例。

语义：

$$
\text{if } R[t0] = R[t1],\quad PC \leftarrow PC + \operatorname{BranchImm}
$$

否则：

$$
PC \leftarrow PC + 4
$$

branch 需要两个东西：

```text
branch comparator
PC MUX
```

comparator 输出：

```text
BrEq: rs1 == rs2
BrLt: rs1 < rs2
BrUn: unsigned compare?
```

control logic 根据 branch 类型和比较结果决定 `PCSel`。

## 4. Jump Datapath

`jal` 做两件事：

```text
rd = PC + 4
PC = PC + jump immediate
```

也就是：

$$
R[rd] = PC + 4
$$

$$
PC_{next} = PC + \operatorname{JumpImm}
$$

所以 jump 需要：

```text
writeback MUX 能选 PC + 4
PC MUX 能选 jump target
```

`jalr` 类似，但 target 来自：

$$
R[rs1] + \operatorname{SignExt}(imm)
$$

## 5. Control Logic

control logic 的输入通常来自 instruction fields：

```text
opcode
funct3
funct7
```

输出是一组控制信号：

```text
RegWEn
ImmSel
ASel
BSel
ALUSel
MemRW
WBSel
PCSel
BrUn
CSR_WE
```

本质是：

```text
instruction bits -> control signals
```

例如：

```text
opcode = load -> WBSel = memory, RegWEn = 1
opcode = store -> MemRW = write, RegWEn = 0
opcode = branch -> RegWEn = 0, PCSel depends on comparator
```

## 6. Instruction Timing

single-cycle CPU 的 clock period 必须足够长，让最慢指令走完整条路径。

例如 `lw` 可能很慢：

```text
PC
-> instruction memory
-> decode
-> RegFile
-> ALU address
-> data memory
-> writeback MUX
-> RegFile setup
```

所以 single-cycle 的问题是：

```text
简单，但所有指令都被最慢指令拖慢
```

这也为下一天 pipeline 做铺垫。

## 今日练习

1. 写出 `lw t0, 8(sp)` 的完整数据流。
2. 写出 `sw t1, 12(sp)` 为什么 `RegWEn = 0`。
3. 解释 `beq` 如何决定 `PCSel`。
4. 从 `opcode/funct3` 出发，列出 `lw/sw/beq/jal` 的关键控制信号。

## 和当前 CPU 项目的连接

| Day 6 内容 | 项目模块 |
|---|---|
| load/store | data memory interface, `WRITE_ADDRESS`, `WRITE_DATA`, `WRITE_ENABLE` |
| branch | `branch_comp.circ`, `BrUn`, `BrEq`, `BrLt` |
| jump | PC MUX, writeback `PC + 4` |
| control | `control_logic.circ` |
| timing | single-cycle vs pipeline 的动机 |

## 今天的输出

今天结束时写 4 个小总结：

```text
1. lw 和 addi 的 writeback 来源有什么不同？
2. sw 为什么读两个寄存器但不写 rd？
3. branch 为什么需要 comparator 和 PC MUX？
4. control_logic 至少要看 instruction 的哪些字段？
```

