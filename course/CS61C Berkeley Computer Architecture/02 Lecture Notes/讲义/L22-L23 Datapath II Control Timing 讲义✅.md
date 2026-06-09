# L22-L23 Datapath II Control Timing 讲义

来源：

- [[../Slides/L22 RISC-V Single-Cycle Datapath II.pdf]]
- [[../Slides/L23 Control Logic Instruction Timing.pdf]]

配套官方 notes：

- [[../Notes/L22 Supporting Loads and Stores - official notes.html]]
- [[../Notes/L22 Supporting Branches - official notes.html]]
- [[../Notes/L22 Supporting Jumps - official notes.html]]
- [[../Notes/L22 Supporting U-Type - official notes.html]]
- [[../Notes/L23 Control Logic Design - official notes.html]]
- [[../Notes/L23 Instruction Timing - official notes.html]]
- [[../Notes/L23 Datapath Summary - official notes.html]]

## 0. 本讲目标

L21 已经讲了 R-type 和 `addi` 的 single-cycle datapath：

```text
PC -> instruction -> RegFile / ImmGen -> ALU -> writeback -> PC + 4
```

L22-L23 要把这条路径扩展成比较完整的 CPU：

```text
load/store
branch
jump
U-type
control logic
instruction timing
```

对当前 CPU 项目来说，这两讲直接对应 Part B：

```text
mem.circ interface
branch_comp.circ
control_logic.circ
csr.circ
PC update logic
```

要掌握：

1. `lw/lh/lb` 如何通过 ALU 计算地址，再从 memory 写回寄存器。
2. `sw/sh/sb` 为什么读两个寄存器但不写 `rd`。
3. branch 如何由 comparator 和 `PCSel` 决定下一条 PC。
4. `jal/jalr` 为什么既要写回 `PC + 4`，又要改 PC。
5. control logic 如何从 `opcode/funct3/funct7` 生成控制信号。
6. single-cycle CPU 为什么被最慢指令限制 clock period。

## 1. 先复习 datapath 的本质

datapath 是数据流经的硬件：

```text
PC
Instruction Memory
RegFile
ImmGen
ALU
Data Memory
Branch Comparator
MUXes
```

control 是让 datapath 走正确路径的开关：

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
```

一条指令的执行可以理解成：

```text
instruction bits -> control signals
control signals -> choose datapath routes
datapath routes -> compute next architectural state
```

## 2. Load Datapath

以：

```asm
lw t0, 8(sp)
```

为例。

语义是：

$$
R[t0] = \operatorname{Mem}[R[sp] + \operatorname{SignExt}(8)]
$$

load 做两件事：

1. 计算 memory address。
2. 从 memory 读出数据，写回 `rd`。

完整数据流：

```text
instruction
-> split rs1=sp, rd=t0, imm=8
-> RegFile reads R[sp]
-> ImmGen generates SignExt(8)
-> ALU computes address = R[sp] + SignExt(8)
-> Data Memory reads address
-> Writeback MUX selects memory data
-> RegFile writes rd=t0
```

关键控制信号：

| 控制信号 | 值 | 原因 |
|---|---|---|
| `RegWEn` | 1 | load 要写回 `rd` |
| `ImmSel` | I-type | offset 来自 I-type immediate |
| `ASel` | `rs1` | 地址基址来自 `R[rs1]` |
| `BSel` | imm | 地址偏移来自 immediate |
| `ALUSel` | add | 地址是 base + offset |
| `MemRW` | read | 读 memory |
| `WBSel` | memory | 写回 memory read data |
| `PCSel` | `PC + 4` | 顺序执行 |

和 `addi` 的关键区别：

```text
addi: ALU result 直接写回 rd
lw:   ALU result 是地址，memory data 才写回 rd
```

## 3. Byte / Halfword / Word Load

`lw` 读 32-bit word：

```text
R[rd] <- Mem[address][31:0]
```

`lh` 读 16-bit halfword，并符号扩展：

$$
R[rd] = \operatorname{SignExt}(\operatorname{Mem}_{16}[addr])
$$

`lb` 读 8-bit byte，并符号扩展：

$$
R[rd] = \operatorname{SignExt}(\operatorname{Mem}_{8}[addr])
$$

所以 load datapath 不只是 “memory read -> writeback”，还要根据 `funct3` 决定：

```text
取 word / halfword / byte
是否 sign extend
```

当前项目只列了 `lb/lh/lw`，没有 `lbu/lhu`，所以 byte/halfword load 需要 sign extension。

## 4. Store Datapath

以：

```asm
sw t1, 12(sp)
```

为例。

语义：

$$
\operatorname{Mem}[R[sp] + \operatorname{SignExt}(12)] = R[t1]
$$

store 做两件事：

1. 计算 memory address。
2. 把 `rs2` 的值写到 memory。

完整数据流：

```text
instruction
-> split rs1=sp, rs2=t1, imm=12
-> RegFile reads R[sp] and R[t1]
-> ImmGen generates SignExt(12)
-> ALU computes address = R[sp] + SignExt(12)
-> Data Memory writes R[t1] to address
```

关键控制信号：

| 控制信号 | 值 | 原因 |
|---|---|---|
| `RegWEn` | 0 | store 不写寄存器 |
| `ImmSel` | S-type | offset 是 S-type immediate |
| `ASel` | `rs1` | 地址基址来自 `R[rs1]` |
| `BSel` | imm | 地址偏移来自 immediate |
| `ALUSel` | add | 地址是 base + offset |
| `MemRW` | write | 写 memory |
| `WBSel` | don't care | 不写回 |
| `PCSel` | `PC + 4` | 顺序执行 |

注意：

```text
store 有 rs2，但没有 rd
rs2 是要写入 memory 的数据来源
```

## 5. Store Byte Mask

项目里的 memory 写使能是 4-bit：

```text
WRITE_ENABLE[3:0]
```

它表示一个 32-bit word 里哪几个 byte 要写。

例如：

```text
sw -> 写 4 bytes
sh -> 写 2 bytes
sb -> 写 1 byte
```

对 aligned `sw`，通常：

```text
WRITE_ENABLE = 1111
```

对 `sb/sh`，还要根据地址低两位决定写哪个 byte lane。

项目说明强调：不要求实现跨 word 的 unaligned access，所以不要为了非对齐访问引入复杂 stall。

## 6. Branch Datapath

以：

```asm
beq t0, t1, label
```

为例。

branch 做两件事：

1. 比较 `rs1` 和 `rs2`。
2. 根据比较结果决定下一条 PC。

语义：

$$
\text{if } R[t0] = R[t1],\quad PC \leftarrow PC + \operatorname{BranchImm}
$$

否则：

$$
PC \leftarrow PC + 4
$$

所以 branch datapath 需要：

```text
RegFile reads rs1 and rs2
Branch Comparator compares them
ImmGen generates B-type immediate
Adder computes PC + branch immediate
PC MUX selects PC + 4 or branch target
```

## 7. Branch Comparator

项目里的 `branch_comp.circ` 有输入：

```text
rs1
rs2
BrUn
```

输出：

```text
BrEq
BrLt
```

含义：

```text
BrEq = 1 if rs1 == rs2
BrLt = 1 if rs1 < rs2
BrUn = 1 means compare as unsigned
BrUn = 0 means compare as signed
```

不同 branch 指令根据 `funct3` 使用这些输出：

| 指令 | 条件 |
|---|---|
| `beq` | `BrEq = 1` |
| `bne` | `BrEq = 0` |
| `blt` | `BrLt = 1` signed |
| `bge` | `BrLt = 0` signed |
| `bltu` | `BrLt = 1` unsigned |
| `bgeu` | `BrLt = 0` unsigned |

所以 `control_logic` 要根据 branch 类型设置 `BrUn`，并根据 comparator 输出决定 `PCSel`。

## 8. Branch Immediate

B-type immediate 不是简单的 `instruction[31:20]`。

它分散在 instruction 的多个字段里：

```text
imm[12]
imm[10:5]
imm[4:1]
imm[11]
```

而且 branch target 是相对 PC 的偏移。

所以：

$$
PC_{target} = PC + \operatorname{BranchImm}
$$

这就是为什么需要 `ImmGen`，而不是随便取一段 bits。

## 9. Jump Datapath

`jal` 是 jump and link。

它做两件事：

$$
R[rd] = PC + 4
$$

$$
PC_{next} = PC + \operatorname{JumpImm}
$$

所以 `jal` 需要：

```text
PC + 4 写回 rd
PC + jump immediate 作为下一条 PC
```

关键控制：

```text
RegWEn = 1
WBSel = PC + 4
PCSel = jump target
ImmSel = J-type
```

`jalr` 的 target 不同：

$$
PC_{next} = R[rs1] + \operatorname{SignExt}(imm)
$$

所以它需要 ALU 或 adder 计算 `rs1 + imm`。

## 10. U-type Datapath

U-type 主要包括：

```asm
lui rd, imm
auipc rd, imm
```

`lui`：

$$
R[rd] = imm << 12
$$

`auipc`：

$$
R[rd] = PC + (imm << 12)
$$

所以 U-type 也会用到 ImmGen，但 immediate 形式和 I/S/B/J 都不同。

## 11. Control Logic 的任务

到这里，datapath 已经有很多 MUX 和 enable。

control logic 的任务就是生成这些信号：

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

输入来自 instruction fields：

```text
opcode
funct3
funct7
```

本质是一个 Boolean function：

$$
\text{control signals} = f(opcode, funct3, funct7, BrEq, BrLt)
$$

其中 `BrEq/BrLt` 会影响 branch 的 `PCSel`。

## 12. Hardwired Control

RISC-V 是 RISC ISA，指令格式规整，所以适合 hardwired control。

hardwired control 就是用组合逻辑：

```text
comparators
AND / OR / NOT
MUX
decoder
```

直接从 instruction fields 生成控制信号。

例如：

```text
opcode == 0x03 -> load
opcode == 0x23 -> store
opcode == 0x63 -> branch
opcode == 0x33 -> R-type
opcode == 0x13 -> I-type arithmetic
```

Part A 可以把控制信号硬连，因为只支持 `addi`。Part B 就必须把这些常量变成根据 instruction 改变的信号。

## 13. 一个控制信号表的直觉

| 指令 | RegWEn | BSel | WBSel | MemRW | PCSel |
|---|---|---|---|---|---|
| R-type | 1 | rs2 | ALU | read/no write | PC+4 |
| `addi` | 1 | imm | ALU | read/no write | PC+4 |
| `lw` | 1 | imm | Mem | read | PC+4 |
| `sw` | 0 | imm | don't care | write | PC+4 |
| branch taken | 0 | imm/unused | don't care | read/no write | target |
| `jal` | 1 | imm | PC+4 | read/no write | target |

这张表不是为了死背，而是看出规律：

```text
写寄存器的指令 RegWEn = 1
访存地址一般用 ALU add
load 写回 memory
普通算术写回 ALU
branch/jump 改 PC
```

## 14. Instruction Timing

single-cycle CPU 的周期必须让最慢指令跑完。

例如 `lw` 的路径很长：

```text
PC register
-> instruction memory
-> decode/control
-> RegFile read
-> ImmGen
-> ALU address
-> data memory read
-> writeback MUX
-> RegFile setup
```

clock period 至少要满足：

$$
T \geq t_{clk\to q} + t_{critical\ path} + t_{setup}
$$

所以 single-cycle CPU 的问题是：

```text
简单，但所有指令都要用同一个很长的 clock period
```

哪怕 `add` 比 `lw` 简单，也必须等同样长的 cycle。

这就是 pipeline 的动机：把长路径拆成多个阶段。

## 15. 和当前项目 Part B 的对应

| 项目文件/模块 | 对应内容 |
|---|---|
| `imm_gen.circ` | I/S/B/U/J immediate |
| `branch_comp.circ` | `BrEq`, `BrLt`, `BrUn` |
| `control_logic.circ` | opcode/funct3/funct7 -> control signals |
| `cpu.circ` | datapath + PC update + writeback |
| memory interface | load/store |
| CSR | `tohost` output for tests |

Part B 的核心不是“新搭很多 CPU”，而是让更多指令复用同一条 datapath。

## 16. 本讲一句话总结

L22-L23 把 single-cycle datapath 扩展到 load/store、branch/jump 和 U-type，并说明 control logic 如何根据 instruction fields 选择正确路径；single-cycle 的时钟周期由最慢的指令路径决定。

## 17. 自查问题

1. `lw` 的 ALU result 是最终写回值吗？
2. `sw` 为什么需要读 `rs2`？
3. branch target 为什么是 `PC + imm`？
4. `jal` 为什么要写回 `PC + 4`？
5. `BrUn` 什么时候应该是 1？
6. `control_logic.circ` 至少需要看哪些 instruction fields？
7. 为什么 single-cycle CPU 会被 `lw` 这类慢指令拖慢？

