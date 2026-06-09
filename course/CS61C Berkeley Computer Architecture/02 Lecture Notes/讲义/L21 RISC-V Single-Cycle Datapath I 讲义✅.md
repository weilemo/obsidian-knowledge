# L21 RISC-V Single-Cycle Datapath I 讲义

来源：[[../Slides/L21 RISC-V Single-Cycle Datapath I.pdf]]

配套官方 notes：

- [[../Notes/L21 Datapath Introduction - official notes.html]]
- [[../Notes/L21 State Elements on the Datapath - official notes.html]]
- [[../Notes/L21 R-Type Datapath ALU - official notes.html]]
- [[../Notes/L21 Supporting Immediates - official notes.html]]

## 0. 本讲目标

前面几讲已经把 CPU 的主要零件讲过了：

```text
instruction format
register
MUX
adder
ALU
state element
clock
```

L21 开始把这些零件连成一条完整的数据通路，也就是 single-cycle datapath。

本讲要掌握：

1. datapath 和 control 的区别。
2. 一条指令执行的五个逻辑阶段：IF / ID / EX / MEM / WB。
3. PC、instruction memory、RegFile、ALU、ImmGen 如何连接。
4. R-type 指令如何走数据通路。
5. `addi` 为什么只是在 R-type 基础上把 ALU 的第二个输入改成 immediate。
6. 当前 CPU 项目 Part A 的 `addi_single` 应该连通哪些模块。

对当前项目来说，这讲直接对应：

```text
cpu.circ
imm_gen.circ
regfile.circ
alu.circ
```

Part A 的目标不是“只会做一个 addi 小功能”，而是用 `addi` 打通完整 CPU 的最小闭环。

## 1. CPU 不是一个单一黑盒

从软件视角看，CPU 好像是在执行一条指令：

```asm
addi t0, x0, 5
```

但从硬件视角看，这条指令会变成一连串数据流：

```text
PC
-> instruction memory
-> instruction bits
-> decode fields
-> read register file
-> generate immediate
-> ALU compute
-> write back
-> update PC
```

这条路上的硬件叫 datapath。

决定每个 MUX 选谁、每个 register 是否写入、ALU 做什么的信号叫 control。

## 2. Datapath 和 Control

datapath 是数据实际流过的硬件：

```text
PC
Instruction Memory
RegFile
ImmGen
ALU
Data Memory
MUXes
Adders
```

control 是控制 datapath 行为的信号：

```text
RegWEn
ImmSel
ASel
BSel
ALUSel
MemRW
WBSel
PCSel
```

可以用一句话区分：

```text
datapath = 路和设备
control = 开关和选择信号
```

例如 `add` 和 `addi` 可以共用同一个 ALU，但它们的 `BSel` 不同：

```text
add:  ALU B = R[rs2]
addi: ALU B = imm
```

所以 datapath 没变，control 变了。

## 3. Single-cycle CPU 是什么

single-cycle CPU 的含义是：

```text
每条指令在一个 clock cycle 内完成
```

更准确地说：

1. 一个 rising edge 后，PC / RegFile 等 state element 输出当前状态。
2. 指令在组合逻辑里经过取指、译码、执行、访存、写回选择。
3. 下一个 rising edge 到来时，PC 和 RegFile 捕获新值。

中间这段组合逻辑必须在一个周期内稳定。

如果把 clock period 记为 $T$，则需要：

$$
T \geq t_{clk\to q} + t_{comb} + t_{setup}
$$

这里：

```text
t_clk->q: 前一个 register 在 clock edge 后输出稳定的时间
t_comb: 组合逻辑传播延迟
t_setup: 下一个 register 在 clock edge 前需要输入稳定的时间
```

今天不要求精确算 timing，但要知道：single-cycle CPU 的周期必须长到足够让最慢的指令也跑完。

## 4. 五个逻辑阶段

RISC-V 指令通常可以用五个逻辑阶段理解：

```text
IF  = Instruction Fetch
ID  = Instruction Decode
EX  = Execute
MEM = Memory Access
WB  = Write Back
```

注意：single-cycle CPU 不是说它真的有五个 clock cycle，而是说一条指令在一个周期内经历这五类逻辑工作。

## 5. IF: Instruction Fetch

IF 阶段要做：

```text
用 PC 作为地址，从 instruction memory 取出 instruction
```

数据流：

```text
PC -> Instruction Memory -> instruction
```

同时，为顺序执行准备下一个 PC：

$$
PC_{next} = PC + 4
$$

为什么是 $+4$？

RV32I 每条 instruction 是 32 bits：

$$
32\ \text{bits} = 4\ \text{bytes}
$$

而 PC 是 byte address，所以顺序执行下一条指令时：

$$
PC \leftarrow PC + 4
$$

这点和当前项目完全一致：`fetch_addr` 是 byte address，而不是 instruction index。

## 6. ID: Instruction Decode

ID 阶段要把 32-bit instruction 拆成字段。

例如 R-type：

```text
funct7 | rs2 | rs1 | funct3 | rd | opcode
```

CPU 需要知道：

```text
opcode: 这大概是哪类指令
funct3/funct7: 具体是哪种运算
rs1: 第一个源寄存器
rs2: 第二个源寄存器
rd: 目标寄存器
imm: 立即数
```

在 Logisim 里，这通常靠 Splitter 完成。

当前项目 Part A 的 `addi` 至少要拆出：

```text
rs1 = instruction[19:15]
rd  = instruction[11:7]
imm = instruction[31:20]
```

因为 `addi` 是 I-type。

## 7. RegFile 读寄存器

RegFile 有两个读端口和一个写端口。

读端口：

```text
Read Register 1 = rs1
Read Register 2 = rs2
```

输出：

```text
Read Data 1 = R[rs1]
Read Data 2 = R[rs2]
```

读取通常是组合逻辑：地址变了，读出的值随之变化。

写入是状态更新：只有在 clock edge 且 `RegWEn = 1` 时，才写入 `rd`。

所以：

```text
read: combinational
write: clocked
```

这就是 RegFile 比 ALU 更复杂的地方。

## 8. EX: Execute

EX 阶段通常由 ALU 完成。

ALU 的抽象接口是：

```text
A
B
ALUSel
-> Result
```

例如 R-type `add`：

```asm
add rd, rs1, rs2
```

对应：

$$
ALUResult = R[rs1] + R[rs2]
$$

对于 `sub`：

$$
ALUResult = R[rs1] - R[rs2]
$$

对于 `and`：

$$
ALUResult = R[rs1] \land R[rs2]
$$

所以 R-type 的基本模式是：

```text
RegFile -> ALU -> RegFile
```

## 9. WB: Write Back

WB 阶段把结果写回 `rd`。

对于 R-type arithmetic，写回来源是 ALU：

$$
R[rd] = ALUResult
$$

需要的控制信号：

```text
RegWEn = 1
WBSel = ALU
```

这里要注意：写回不是“ALU 直接修改 RegFile”。ALU 只是组合逻辑产生结果。真正写入寄存器发生在 clock edge。

## 10. R-type 数据通路

以：

```asm
add t0, t1, t2
```

为例。

语义：

$$
R[t0] = R[t1] + R[t2]
$$

数据流完整写出来：

```text
PC
-> instruction memory
-> instruction bits
-> split rs1=t1, rs2=t2, rd=t0
-> RegFile reads R[t1] and R[t2]
-> ALU A = R[t1]
-> ALU B = R[t2]
-> ALUSel = add
-> ALUResult = R[t1] + R[t2]
-> Writeback MUX selects ALUResult
-> RegFile write data = ALUResult
-> RegFile write register = t0
-> RegWEn = 1
-> next clock edge: R[t0] updated
```

同时 PC 顺序更新：

$$
PC \leftarrow PC + 4
$$

## 11. R-type 的控制信号

对 `add rd, rs1, rs2`，可以这样理解：

| 控制信号 | 值 | 原因 |
|---|---|---|
| `RegWEn` | 1 | 要写回 `rd` |
| `ASel` | `rs1` | ALU A 来自 `R[rs1]` |
| `BSel` | `rs2` | ALU B 来自 `R[rs2]` |
| `ALUSel` | add | 执行加法 |
| `WBSel` | ALU | 写回 ALU 结果 |
| `MemRW` | 0 | 不写数据内存 |
| `PCSel` | `PC + 4` | 顺序执行 |

这张表的本质是：control 把 datapath 调成适合 `add` 的状态。

## 12. Supporting Immediates

R-type 只用寄存器输入：

```text
ALU A = R[rs1]
ALU B = R[rs2]
```

但 I-type arithmetic 需要 immediate：

```asm
addi rd, rs1, imm
```

语义：

$$
R[rd] = R[rs1] + \operatorname{SignExt}(imm)
$$

这时 ALU B 不能再来自 `R[rs2]`，而要来自 ImmGen。

所以 datapath 需要新增两个东西：

```text
ImmGen
ALU B MUX
```

## 13. ImmGen

ImmGen 的作用是从 instruction 中抽取 immediate，并扩展成 32-bit。

对 I-type：

```text
imm[11:0] = instruction[31:20]
```

然后做 sign extension：

$$
imm_{32} = \operatorname{SignExt}(instruction[31:20])
$$

例如：

```asm
addi t0, x0, -1
```

12-bit immediate 是：

```text
1111_1111_1111
```

扩展到 32-bit：

```text
1111_1111_1111_1111_1111_1111_1111_1111
```

也就是：

$$
\operatorname{SignExt}(0b111111111111) = -1
$$

## 14. ALU B MUX

为了同时支持 R-type 和 I-type，ALU B 前要放一个 MUX：

```text
R[rs2] ----\
           MUX -> ALU B
imm    ----/
```

控制信号是 `BSel`：

```text
BSel = 0 -> ALU B = R[rs2]
BSel = 1 -> ALU B = imm
```

于是：

```text
add:  BSel = 0
addi: BSel = 1
```

这就是 MUX 在 datapath 里的典型用途：让同一套 ALU 服务不同指令。

## 15. addi 数据通路

以：

```asm
addi t0, x0, 5
```

为例。

语义：

$$
R[t0] = R[x0] + \operatorname{SignExt}(5)
$$

由于：

$$
R[x0] = 0
$$

所以：

$$
R[t0] = 5
$$

完整数据流：

```text
PC
-> instruction memory
-> instruction bits
-> split rs1=x0, rd=t0, imm=5
-> RegFile reads R[x0]
-> ImmGen outputs SignExt(5)
-> ALU A = R[x0]
-> ALU B = SignExt(5)
-> ALUSel = add
-> ALUResult = 5
-> Writeback MUX selects ALUResult
-> RegFile write data = 5
-> RegFile write register = t0
-> RegWEn = 1
-> next clock edge: R[t0] updated to 5
```

PC 同时：

$$
PC \leftarrow PC + 4
$$

## 16. add 和 addi 的对比

| 项目 | `add` | `addi` |
|---|---|---|
| 指令格式 | R-type | I-type |
| 读 `rs1` | yes | yes |
| 读 `rs2` | yes | no |
| 使用 immediate | no | yes |
| ALU A | `R[rs1]` | `R[rs1]` |
| ALU B | `R[rs2]` | `SignExt(imm)` |
| ALU 操作 | add | add |
| 写回 | `rd` | `rd` |

结论：

```text
add 和 addi 最大差别不是 ALU，而是 ALU B 的来源。
```

所以 datapath 用 MUX 解决这个问题。

## 17. 当前项目 Part A 的最小 CPU

项目 Part A 任务 3 要先支持 `addi`。

这其实是最小完整 CPU，因为它用到了：

```text
PC
Instruction fetch
Instruction decode
RegFile read
ImmGen
ALU
RegFile writeback
PC + 4
```

它暂时不用：

```text
Data memory
Branch comparator
PC branch/jump target
复杂 control logic
```

但五阶段里的核心路径已经完整出现了。

## 18. Part A 可以硬连控制信号

因为 Part A 只支持 `addi`，所以 control logic 可以先用常量。

对 `addi`：

| 控制信号 | 值 | 原因 |
|---|---|---|
| `RegWEn` | 1 | `addi` 要写回 `rd` |
| `ImmSel` | I-type | 立即数来自 `instruction[31:20]` |
| `ASel` | `rs1` | ALU A 来自 `R[rs1]` |
| `BSel` | imm | ALU B 来自 immediate |
| `ALUSel` | add | 做加法 |
| `WBSel` | ALU | 写回 ALU result |
| `MemRW` | 0 | 不写 memory |
| `PCSel` | `PC + 4` | 没有 branch/jump |

等到 Part B 要支持多种指令时，这些常量就必须变成真正的 `control_logic.circ` 输出。

## 19. cpu.circ 里可以按这个顺序连

对 `addi_single`，推荐思路：

### 19.1 先确认 PC 到 instruction

```text
PC register -> fetch_addr
INSTRUCTION input -> instruction splitter
```

PC 初始为 0，然后每周期加 4。

### 19.2 拆指令字段

对 I-type `addi`：

```text
rs1 = instruction[19:15]
rd  = instruction[11:7]
imm = instruction[31:20]
```

### 19.3 接 RegFile

```text
Read Register 1 = rs1
Write Register = rd
Write Data = writeback data
RegWEn = 1
Clock = CLOCK
```

Part A 的 `addi` 不用 `rs2`，但 RegFile 的读端口 2 可以接合理值，避免 floating。

### 19.4 接 ImmGen

```text
inst = INSTRUCTION
ImmSel = I-type constant
imm = SignExt(instruction[31:20])
```

### 19.5 接 ALU

```text
A = RegFile rs1 data
B = ImmGen output
ALUSel = add constant
Result = ALU result
```

### 19.6 接写回

```text
Write Data = ALU result
```

如果提前放了 Writeback MUX，也可以：

```text
WBSel = ALU
```

### 19.7 接 PC + 4

```text
PC_next = PC + 4
```

下一个 clock edge：

```text
PC <- PC_next
```

## 20. 单周期测试为什么看起来直接

`addi_single` 测试期待的是：

```text
每个 clock cycle 完成一条 addi
```

例如程序：

```asm
addi t0, x0, 5
addi t1, t0, 7
addi s0, t0, 9
```

单周期理解是：

```text
cycle 1: t0 <- 5
cycle 2: t1 <- t0 + 7 = 12
cycle 3: s0 <- t0 + 9 = 14
```

后面做两级流水线时，测试结果会有延迟，这就是为什么项目会区分 `addi_single` 和 `addi_pipelined`。

## 21. 常见错误

### 21.1 PC 加 1 而不是加 4

PC 是 byte address。RV32I 指令长度是 4 bytes。

正确：

$$
PC_{next} = PC + 4
$$

不是：

$$
PC_{next} = PC + 1
$$

### 21.2 `addi` 的 immediate 没有 sign extension

`addi` immediate 是 12-bit signed immediate。

必须：

$$
imm_{32} = \operatorname{SignExt}(imm_{12})
$$

否则负数 immediate 会错。

### 21.3 把 `rs2` 接给 ALU B

`addi` 是 I-type，没有真正的 `rs2` 源操作数。

正确：

```text
ALU B = imm
```

### 21.4 忘记写 `rd`

`addi` 要写回：

```text
RegWEn = 1
Write Register = rd
Write Data = ALU result
```

### 21.5 写入 x0

RegFile 里 `x0` 必须始终为 0。

即使指令写：

```asm
addi x0, x0, 5
```

结果也应该是：

```text
x0 remains 0
```

### 21.6 control 还没做就想支持所有指令

Part A 先服务 `addi`，控制信号可以硬连。

不要一上来就把所有 opcode 都塞进 control logic，容易把最小闭环搞乱。

## 22. 和五阶段流水线的关系

今天讲的是 single-cycle datapath，但五个阶段的概念会直接通向 pipeline。

single-cycle：

```text
一条指令在一个长 cycle 里完成 IF/ID/EX/MEM/WB
```

pipeline：

```text
不同指令同时处在不同 stage
stage 之间用 pipeline register 隔开
```

当前项目 Part A 后面要求两级流水线：

```text
Stage 1: IF
Stage 2: ID + EX + MEM + WB
```

所以今天看懂：

```text
IF 和后面阶段分别需要哪些信号
```

对下一步很重要。

## 23. 本讲一句话总结

Single-cycle datapath 把 PC、instruction memory、RegFile、ImmGen、ALU、writeback 和 PC+4 串成一条完整路径；`add` 和 `addi` 共享大部分硬件，区别主要是 ALU 第二个输入来自 `rs2` 还是 immediate。

对当前项目：

```text
addi_single = 用 addi 打通完整 CPU 数据通路
```

## 24. 自查问题

1. datapath 和 control 分别是什么？
2. 为什么 PC 顺序执行是 $PC + 4$？
3. `add` 的 ALU A/B 分别来自哪里？
4. `addi` 的 ALU A/B 分别来自哪里？
5. 为什么 `addi` 需要 ImmGen？
6. 为什么 `addi` 需要写回 `rd`？
7. Part A 为什么可以把 `ALUSel`、`RegWEn`、`WBSel` 先硬连？
8. 如果 `addi_single` 测试里寄存器全是 `xxxx`，可能是哪几条路径没连好？

