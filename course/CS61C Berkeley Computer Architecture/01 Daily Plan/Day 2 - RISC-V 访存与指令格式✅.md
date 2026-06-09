# Day 2 - RISC-V 访存与指令格式

## 今天目标

Day 1 已经建立了：

```text
bit / hex / two's complement
register
addi
CPU 执行一条指令的最小闭环
```

Day 2 要往项目最需要的方向推进：**RISC-V 指令到底如何编码成 32-bit 机器码，以及 CPU 如何从机器码里拆出 `rs1`、`rs2`、`rd`、`imm`。**

学完今天内容后，要能回答：

1. `lw` / `sw` 和普通 ALU 指令有什么不同？
2. RISC-V 为什么是 load-store architecture？
3. R/I/S/B/U/J 这几种 instruction format 分别服务什么指令？
4. `opcode`、`funct3`、`funct7`、`rd`、`rs1`、`rs2` 分别在 32-bit instruction 的哪些位置？
5. 为什么项目里的 `ImmGen` 要根据 `ImmSel` 生成不同 immediate？

## 今天要看的 CS61C 内容

本地资料入口：[[../02 Lecture Notes/Day 2 Materials Index]]

官方课程页：<https://cs61c.org/>

### 1. Lecture 10: RISC-V Data Transfer

重点看：

```text
load / store
byte / halfword / word
address
offset(base)
lw / sw
lb / lh
sb / sh
```

今天先抓直觉：

```asm
lw rd, offset(rs1)
```

意思是：

$$
R[rd] = \operatorname{Mem}[R[rs1] + \operatorname{SignExt}(offset)]
$$

而：

```asm
sw rs2, offset(rs1)
```

意思是：

$$
\operatorname{Mem}[R[rs1] + \operatorname{SignExt}(offset)] = R[rs2]
$$

和当前项目的关系：

```text
ALU 不只做加法结果，也负责计算内存地址
Data memory 的 WRITE_ADDRESS 来自 rs1 + offset
load 的结果来自 READ_DATA
store 的写入值来自 rs2
```

### 2. Lecture 13: RISC-V Instruction Formats I

重点看：

```text
R-type
I-type
S-type
instruction field
opcode
rd
funct3
rs1
rs2
funct7
immediate
```

这三类先记住：

| Format | 常见指令 | 数据通路直觉 |
|---|---|---|
| R-type | `add rd, rs1, rs2` | 两个寄存器进 ALU，结果写回 `rd` |
| I-type | `addi rd, rs1, imm`, `lw rd, offset(rs1)` | 一个寄存器加一个 immediate |
| S-type | `sw rs2, offset(rs1)` | `rs1 + imm` 算地址，把 `rs2` 写入内存 |

### 3. Lecture 14: RISC-V Instruction Formats II

重点看：

```text
B-type
U-type
J-type
branch immediate
jump immediate
PC-relative addressing
```

这三类先抓用途：

| Format | 常见指令 | 数据通路直觉 |
|---|---|---|
| B-type | `beq`, `bne`, `blt` | 比较 `rs1` 和 `rs2`，条件满足就改 PC |
| U-type | `lui`, `auipc` | 构造高位 immediate，或和 PC 相加 |
| J-type | `jal` | 写回 `PC + 4`，同时跳转 |

今天不用把所有 immediate 位拼接背下来，但要明白：**不同格式的 immediate 位不总是连续排列，所以 CPU 需要 ImmGen。**

## 今天的核心图像

一条 32-bit RISC-V 指令不是一整块神秘数字，而是由字段组成：

```text
[ instruction: 32 bits ]
       |
       v
opcode / rd / funct3 / rs1 / rs2 / funct7 / imm
       |
       v
control signals + datapath inputs
```

项目里的 `cpu.circ` 要做的事情就是：

```text
INSTRUCTION
-> Splitter 拆字段
-> RegFile 读 rs1 / rs2
-> ImmGen 生成 32-bit imm
-> Control Logic 根据 opcode/funct3/funct7 生成控制信号
-> ALU / Memory / WriteBack
```

## 今天的练习

### 练习 1：区分 R-type 和 I-type

解释这两条指令的数据来源：

```asm
add  t0, t1, t2
addi t0, t1, 5
```

应该能说出：

```text
add:
  ALU A = R[t1]
  ALU B = R[t2]

addi:
  ALU A = R[t1]
  ALU B = SignExt(5)
```

### 练习 2：解释 load/store 的地址

看这两条：

```asm
lw t0, 8(sp)
sw t1, 12(sp)
```

写出它们的地址计算：

$$
\text{addr}_{lw} = R[sp] + 8
$$

$$
\text{addr}_{sw} = R[sp] + 12
$$

并回答：

```text
lw 写回寄存器吗？
sw 写回寄存器吗？
lw 读内存还是写内存？
sw 读内存还是写内存？
```

### 练习 3：把格式和项目模块对应起来

填这个表：

| 指令 | Format | 需要 RegFile 读 rs1? | 需要 RegFile 读 rs2? | 需要 ImmGen? | 写回 rd? |
|---|---|---|---|---|---|
| `add t0, t1, t2` |  |  |  |  |  |
| `addi t0, t1, 5` |  |  |  |  |  |
| `lw t0, 8(sp)` |  |  |  |  |  |
| `sw t1, 12(sp)` |  |  |  |  |  |
| `beq t0, t1, label` |  |  |  |  |  |

参考答案先不要看，自己填完再对：

| 指令 | Format | 读 rs1 | 读 rs2 | ImmGen | 写回 rd |
|---|---|---|---|---|---|
| `add t0, t1, t2` | R | yes | yes | no | yes |
| `addi t0, t1, 5` | I | yes | no | yes | yes |
| `lw t0, 8(sp)` | I | yes | no | yes | yes |
| `sw t1, 12(sp)` | S | yes | yes | yes | no |
| `beq t0, t1, label` | B | yes | yes | yes | no |

## 今天暂时不用深挖

今天可以先不深挖：

```text
calling convention
stack frame
function call
linker / loader
cache
pipeline hazard
```

这些后面会用到，但现在最重要的是把 **指令格式 -> 数据通路输入 -> 控制信号** 这条线打通。

## 和当前 CPU 项目的连接

今天内容直接对应这些模块：

| Day 2 内容 | 项目模块 |
|---|---|
| R/I/S/B/U/J formats | `cpu.circ` 里的 Splitter 和译码 |
| immediate extraction | `imm_gen.circ` |
| load/store address | `ALU` + data memory interface |
| `opcode/funct3/funct7` | `control_logic.circ` |
| branch offset | `branch_comp.circ` + PC update |

尤其要记住：

```text
ImmGen 不是只给 addi 用。
Part B 里 I/S/B/U/J 都需要不同形式的 immediate。
```

## 今天的输出

今天结束时，在下面追加自己的 4 个小总结：

```text
1. 我如何理解 load-store architecture？
2. R-type / I-type / S-type 最大区别是什么？
3. 为什么 branch immediate 要交给 ImmGen，而不是随便取 inst[31:20]？
4. 如果我要做 control_logic，我需要从 instruction 里看哪些字段？
```
