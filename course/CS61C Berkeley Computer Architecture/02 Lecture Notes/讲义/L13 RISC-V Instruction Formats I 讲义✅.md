# L13 RISC-V Instruction Formats I 讲义

来源：[[../Slides/L13 RISC-V Instruction Formats I.pdf]]

配套官方 notes：[[../Notes/L13 RISC-V Instruction Formats I - official notes.html]]

## 0. 本讲目标

前面几讲已经会读一些 RISC-V assembly：

```asm
add  x18 x19 x10
addi x15 x1 -50
lw   x14 8(x2)
sw   x14 36(x2)
```

但 CPU 不认识这些文本。硬件真正看到的是 0 和 1：

```text
add x18, x19, x10
-> 00000000101010011000100100110011
```

这一讲要回答的问题是：

```text
一条 assembly instruction 怎么被编码成 32-bit machine instruction？
```

本讲覆盖 RV32I 六种 instruction format 中的前三种：

1. R-Type：register-register arithmetic，例如 `add`、`sub`、`xor`。
2. I-Type：register-immediate arithmetic、load、`jalr` 等，例如 `addi`、`lw`。
3. S-Type：store，例如 `sb`、`sh`、`sw`。

下一讲会继续讲 B-Type、U-Type、J-Type。

## 1. Stored-Program Computer 的意义

stored-program computer 的核心思想是：instructions 和 data 一样，都可以表示成 bit pattern，也都可以放在 memory 里。

这意味着：

```text
instruction = a number stored in memory
program = a sequence of instruction numbers stored in memory
```

这就是为什么现代计算机不需要为每个程序重新接线。只要把新的 machine code 放进内存，CPU 就能按 Program Counter 指向的位置一条条取指令执行。

Program Counter，简称 PC，保存“当前正在执行的指令地址”。它本质上是一个指向 instruction memory 的指针：

$$
\text{PC} = \text{address of current instruction}
$$

因为 instruction 也有内存地址，所以 branch 和 jump 本质上都是改变 PC。

## 2. Machine Code 和 ISA 绑定

程序通常以 binary 形式发布，也就是 assembled machine code。这个 binary 不是跨 ISA 通用的。

例如：

```text
RISC-V executable != x86 executable
```

同一串 bits 在 RISC-V 上可能是一条合法指令，在 x86 上可能完全是另一种含义，或者根本非法。ISA 定义了：

1. 有哪些 assembly instructions。
2. 每条 instruction 的 machine encoding。
3. 寄存器、内存访问、PC 等基础架构规则。

所以 machine code 是 ISA-dependent 的。历史上很多 ISA 会保持 backward compatibility，例如现代 x86 机器仍能运行很老的 x86 程序，但这仍然是在同一 ISA 家族内的兼容。

## 3. RV32I 指令都是 32-bit word

RISC-V 的一个简化设计是：RV32I instruction 固定为 32 bits，也就是一个 word。

$$
1\ \text{instruction} = 32\ \text{bits} = 4\ \text{bytes}
$$

这和前面学过的 RV32I register word 大小一致：

$$
1\ \text{word} = 32\ \text{bits}
$$

固定长度的好处是 CPU 取指令、切字段、译码都更规则。PC 正常顺序执行时通常每条指令后加 4：

$$
\text{PC}_{next} = \text{PC} + 4
$$

RISC-V ISA 定义了六种基本 instruction formats。每种格式把 32-bit instruction word 切成若干 fields，每个 field 告诉 CPU 一部分信息：

```text
opcode: 这是什么大类指令
rd: destination register
rs1: source register 1
rs2: source register 2
funct3/funct7: 进一步区分具体操作
imm: immediate constant
```

## 4. 为什么要有 instruction format

假设 CPU 看到一串 32 bits：

```text
00000000101010011000100100110011
```

CPU 需要知道：

1. 这是加法、减法、load、store 还是 branch？
2. 哪些 bits 表示寄存器编号？
3. 哪些 bits 表示 immediate？
4. 结果写回哪里？
5. 需要读几个寄存器？

instruction format 就是这套切分规则。RISC-V 的设计倾向是：相似指令使用相同格式、相同字段位置。

这对硬件很重要。比如 `rs1` 如果在多种格式中总在 `inst[19:15]`，那么 register file 的读端口连接就更简单。CPU 不必先复杂判断格式再到处找 `rs1`。

## 5. R-Type 总览

R-Type 用于 register-register arithmetic。语法：

```asm
opname rd rs1 rs2
```

语义通常是：

$$
R[\text{rd}] \leftarrow R[\text{rs1}]\ \text{op}\ R[\text{rs2}]
$$

R-Type instruction format：

```text
31        25 24   20 19   15 14  12 11    7 6      0
+-----------+-------+-------+------+-------+---------+
|  funct7   |  rs2  |  rs1  |funct3|  rd   | opcode  |
+-----------+-------+-------+------+-------+---------+
    7 bits   5 bits  5 bits 3 bits 5 bits   7 bits
```

字段含义：

```text
opcode: 指令大类。R-Type arithmetic 的 opcode 是 0110011。
rd: destination register，保存结果。
rs1: source register 1。
rs2: source register 2。
funct3 + funct7: 在同一 opcode 内区分 add/sub/xor/sll 等具体操作。
```

## 6. Register 字段为什么是 5 bits

RV32I 有 32 个寄存器：

$$
\text{register count} = 32
$$

要编码 $0$ 到 $31$，需要 5 bits：

$$
2^5 = 32
$$

所以每个 register field 都是 5-bit unsigned integer。

例子：

```text
a0 -> x10 -> 0b01010
```

因此在 instruction 中看到 `01010`，如果它位于 `rs2` 字段，就表示 `rs2 = x10`；如果它位于 `rd` 字段，就表示 `rd = x10`。

## 7. R-Type 例子：`add x18 x19 x10`

目标指令：

```asm
add x18 x19 x10
```

语义：

$$
R[x18] \leftarrow R[x19] + R[x10]
$$

查 reference card 可得：

```text
opcode = 0110011
funct3 = 000
funct7 = 0000000
```

寄存器编号：

```text
rd  = x18 = 10010
rs1 = x19 = 10011
rs2 = x10 = 01010
```

填入 R-Type fields：

```text
funct7   rs2    rs1    funct3 rd     opcode
0000000  01010  10011  000    10010  0110011
```

连起来：

```text
00000000101010011000100100110011
```

这就是 `add x18 x19 x10` 的 32-bit machine code。

编码步骤可以固定成：

1. 由 opcode 判断/确认 format。
2. 查表得到 `funct3`、`funct7`。
3. 把寄存器名翻译成 5-bit register number。
4. 按字段位置拼回 32 bits。
5. 可选：转换成 hex。

## 8. 从 Hex 解码 R-Type

幻灯片练习：

```text
0x01B342B3
```

先写成 binary：

```text
0000 0001 1011 0011 0100 0010 1011 0011
```

按 R-Type 切字段：

```text
funct7   rs2    rs1    funct3 rd     opcode
0000000  11011  00110  100    00101  0110011
```

先看 opcode：

```text
opcode = 0110011
```

这是 R-Type arithmetic。

再看 `funct3 = 100`、`funct7 = 0000000`，查表是 `xor`。

寄存器：

```text
rd  = 00101 = x5  = t0
rs1 = 00110 = x6  = t1
rs2 = 11011 = x27 = s11
```

所以指令是：

```asm
xor t0 t1 s11
```

也可以写成：

```asm
xor x5 x6 x27
```

注意 assembly operand 顺序是：

```asm
opname rd rs1 rs2
```

不是字段从左到右的顺序。字段从左到右是 `funct7 rs2 rs1 funct3 rd opcode`。

## 9. RV32I R-Type 指令表

R-Type arithmetic 都共享同一个 opcode：

```text
opcode = 0110011
```

常见 RV32I R-Type 指令：

```text
funct7   funct3 opcode   instruction
0000000  000    0110011  add
0100000  000    0110011  sub
0000000  111    0110011  and
0000000  110    0110011  or
0000000  100    0110011  xor
0000000  001    0110011  sll
0000000  101    0110011  srl
0100000  101    0110011  sra
0000000  010    0110011  slt
0000000  011    0110011  sltu
```

这里有两个重要设计点。

第一，`add` 和 `sub` 共享 `funct3 = 000`，用 `funct7` 区分：

```text
add: funct7 = 0000000
sub: funct7 = 0100000
```

第二，`srl` 和 `sra` 共享 `funct3 = 101`，也用 `funct7` 区分：

```text
srl: funct7 = 0000000
sra: funct7 = 0100000
```

这种“相似操作使用相似字段模式”的设计能让 CPU 控制逻辑更简单。例如 `add/sub` 都进入 ALU 加法相关路径，只是 `sub` 需要对 `rs2` 做二补码取负；`srl/sra` 都是右移，只是高位填充规则不同。

## 10. I-Type 总览

I-Type 用于 register-immediate arithmetic，也用于 load、`jalr` 等。基本 arithmetic 语法：

```asm
opname rd rs1 imm
```

典型语义：

$$
R[\text{rd}] \leftarrow R[\text{rs1}]\ \text{op}\ \text{imm}
$$

I-Type instruction format：

```text
31              20 19   15 14  12 11    7 6      0
+----------------+-------+------+-------+---------+
|   imm[11:0]    |  rs1  |funct3|  rd   | opcode  |
+----------------+-------+------+-------+---------+
      12 bits     5 bits 3 bits 5 bits   7 bits
```

I-Type 和 R-Type 故意保持相似：

```text
rs1:    still inst[19:15]
funct3: still inst[14:12]
rd:     still inst[11:7]
opcode: still inst[6:0]
```

变化是：原来 R-Type 的 `funct7 + rs2` 位置，被合并成 12-bit immediate。

## 11. Immediate 范围和 sign extension

I-Type immediate 是 12 bits：

$$
\text{imm width} = 12\ \text{bits}
$$

它按 signed two's complement 解释，所以范围是：

$$
-2^{11} \le \text{imm} \le 2^{11}-1
$$

也就是：

$$
-2048 \le \text{imm} \le 2047
$$

CPU 使用这个 immediate 前，会把它 sign-extend 到 32 bits：

$$
\text{sign-extend}_{12 \to 32}(\text{imm})
$$

如果 immediate 大于 12-bit 可表示范围，需要用其他指令组合处理，后面会讲更大的 immediate 如何构造。

## 12. I-Type 例子：`addi x15 x1 -50`

目标指令：

```asm
addi x15 x1 -50
```

语义：

$$
R[x15] \leftarrow R[x1] + (-50)
$$

查表：

```text
opcode = 0010011
funct3 = 000
```

寄存器：

```text
rd  = x15 = 01111
rs1 = x1  = 00001
```

现在编码 immediate `-50`。先看 $+50$：

$$
50_{10} = 0b000000110010
$$

12-bit two's complement 的 `-50` 是：

```text
111111001110
```

所以字段为：

```text
imm[11:0]     rs1    funct3 rd     opcode
111111001110  00001  000    01111  0010011
```

这就是 `addi x15 x1 -50` 的 I-Type 编码结构。

## 13. 为什么 I-Type immediate 要比 5 bits 宽

如果直接沿用 R-Type，把 `rs2` 的 5-bit 位置改成 immediate，那 immediate 只能表示 32 种值：

$$
2^5 = 32
$$

这太少了。程序中常数偏移、栈偏移、数组访问、立即数加法都经常超过 5-bit 范围。

所以 I-Type 把 R-Type 左侧的 `funct7` 和 `rs2` 合并起来，形成 12-bit immediate：

```text
R-Type left part: funct7 + rs2 = 7 + 5 = 12 bits
I-Type left part: imm[11:0] = 12 bits
```

同时，`rs1/funct3/rd/opcode` 的位置仍然保持不变。这是 RISC-V 格式设计里非常重要的折中：给 immediate 更多位，同时尽量保持常用寄存器字段位置稳定。

## 14. I-Type 指令族

I-Type 不只有 arithmetic immediate。RV32I 中常见 I-Type opcode 包括：

```text
Arithmetic immediate: 0010011
Load:                 0000011
jalr:                 1100111
System/other:          1110011
```

arithmetic immediate 的 `funct3` 和对应 R-Type 操作保持相似：

```text
R-Type  funct3       I-Type funct3
add     000          addi   000
and     111          andi   111
or      110          ori    110
xor     100          xori   100
slt     010          slti   010
sltu    011          sltiu  011
sll     001          slli   001
srl/sra 101          srli/srai 101
```

没有 `subi`，因为：

$$
x - c = x + (-c)
$$

用 `addi` 加负 immediate 就够了。

## 15. I*-Type: Shift by Immediate

幻灯片把 shift-by-immediate 指令称为 “I*-Type”。它们仍然使用 I-Type 的 12-bit immediate field，但内部解释更特殊。

相关指令：

```asm
slli rd rs1 shamt
srli rd rs1 shamt
srai rd rs1 shamt
```

其中 `shamt` 是 shift amount。

RV32I register 宽度是 32 bits，所以移动位数只需要表示 $0$ 到 $31$：

$$
0 \le \text{shamt} \le 31
$$

需要 5 bits：

$$
2^5 = 32
$$

因此 shift immediate 只使用：

```text
imm[4:0]
```

而 `imm[11:5]` 不再作为普通 immediate 高位，而是承担类似 R-Type `funct7` 的作用，用来区分 `srli` 和 `srai` 等：

```text
0000000 imm[4:0] rs1 001 rd 0010011  slli
0000000 imm[4:0] rs1 101 rd 0010011  srli
0100000 imm[4:0] rs1 101 rd 0010011  srai
```

重点是：I*-Type 是 I-Type 的一个特殊解释，不是新的第七种基本格式。

## 16. Load 为什么也是 I-Type

Load 指令语法：

```asm
loadop rd imm(rs1)
```

例如：

```asm
lw x14 8(x2)
```

load 需要计算 memory address：

$$
\text{address} = R[\text{rs1}] + \text{imm}
$$

这和 I-Type arithmetic 一样，需要一个 base register `rs1` 加一个 immediate offset。所以 load 很自然地使用 I-Type format：

```text
31              20 19   15 14  12 11    7 6      0
+----------------+-------+------+-------+---------+
|   imm[11:0]    |  rs1  |funct3|  rd   | opcode  |
+----------------+-------+------+-------+---------+
```

字段含义变成：

```text
rd:  receives value loaded from memory
rs1: base register
imm: offset
funct3: load size and signedness
opcode: load opcode, 0000011
```

## 17. Load 例子：`lw x14 8(x2)`

目标指令：

```asm
lw x14 8(x2)
```

含义：

$$
R[x14] \leftarrow \text{Memory}[R[x2] + 8]
$$

更准确地说，`lw` load 4 bytes，并写入 `x14`。

字段：

```text
imm[11:0] = 000000001000
rs1       = x2  = 00010
funct3    = 010
rd        = x14 = 01110
opcode    = 0000011
```

填入 I-Type：

```text
imm[11:0]     rs1    funct3 rd     opcode
000000001000  00010  010    01110  0000011
```

这里：

```text
base = x2
offset = 8
destination = x14
```

## 18. Load 指令表

RV32I load 指令共享 opcode：

```text
opcode = 0000011
```

用 `funct3` 区分大小和 signedness：

```text
funct3 opcode   instruction meaning
000    0000011  lb   load byte, sign-extend
100    0000011  lbu  load byte, zero-extend
001    0000011  lh   load halfword, sign-extend
101    0000011  lhu  load halfword, zero-extend
010    0000011  lw   load word
```

大小关系：

$$
1\ \text{byte} = 8\ \text{bits}
$$

$$
1\ \text{halfword} = 16\ \text{bits}
$$

$$
1\ \text{word} = 32\ \text{bits}
$$

`lb` 和 `lh` 会 sign-extend 到 32-bit register；`lbu` 和 `lhu` 会 zero-extend。

RV32I 没有 `lwu`，因为 `lw` 已经加载 32 bits 到 32-bit register：

$$
32\ \text{bits} \to 32\ \text{bits}
$$

没有高位需要扩展。

## 19. I-Type Reference: Arithmetic

常见 arithmetic I-Type：

```text
imm[11:0] rs1 000 rd 0010011 addi
imm[11:0] rs1 111 rd 0010011 andi
imm[11:0] rs1 110 rd 0010011 ori
imm[11:0] rs1 100 rd 0010011 xori
0000000 imm[4:0] rs1 001 rd 0010011 slli
0000000 imm[4:0] rs1 101 rd 0010011 srli
0100000 imm[4:0] rs1 101 rd 0010011 srai
imm[11:0] rs1 010 rd 0010011 slti
imm[11:0] rs1 011 rd 0010011 sltiu
```

记忆方式：

1. 普通 immediate arithmetic 用完整 `imm[11:0]`。
2. shift immediate 用 `imm[4:0]` 做 shift amount。
3. `srai` 和 `srli` 通过高 7 bits 区分，类似 R-Type 中 `sra/srl` 通过 `funct7` 区分。

## 20. S-Type 总览

Store 指令不能使用普通 I-Type，因为 store 没有 destination register `rd`。store 的目标是 memory，数据来源是 `rs2`。

Store 语法：

```asm
storeop rs2 imm(rs1)
```

例如：

```asm
sw x14 36(x2)
```

语义：

$$
\text{Memory}[R[x2] + 36] \leftarrow R[x14]
$$

S-Type instruction format：

```text
31        25 24   20 19   15 14  12 11       7 6      0
+-----------+-------+-------+------+----------+---------+
| imm[11:5] |  rs2  |  rs1  |funct3| imm[4:0] | opcode  |
+-----------+-------+-------+------+----------+---------+
    7 bits   5 bits  5 bits 3 bits   5 bits    7 bits
```

字段含义：

```text
rs2: source register, data to be stored
rs1: base register
imm[11:0]: offset, but split into high and low parts
funct3: store size
opcode: store opcode, 0100011
```

地址计算仍然是：

$$
\text{address} = R[\text{rs1}] + \text{imm}
$$

## 21. S-Type 例子：`sw x14 36(x2)`

目标指令：

```asm
sw x14 36(x2)
```

含义：

$$
\text{Memory}[R[x2] + 36] \leftarrow R[x14]
$$

字段：

```text
rs2 = x14 = 01110
rs1 = x2  = 00010
funct3 = 010
opcode = 0100011
```

immediate 是 36：

$$
36_{10} = 0b000000100100
$$

拆成：

```text
imm[11:5] = 0000001
imm[4:0]  = 00100
```

填入 S-Type：

```text
imm[11:5] rs2    rs1    funct3 imm[4:0] opcode
0000001   01110  00010  010    00100    0100011
```

这里最容易漏的是：S-Type 的 immediate 不是连续放在一个字段中，而是高 7 bits 和低 5 bits 分开放。

## 22. 为什么 S-Type 要拆 immediate

问题：既然 store 需要 immediate offset，为什么不把 12-bit immediate 连续放一起？

答案：RISC-V 更优先保持 register fields 的位置稳定。

对比三种格式：

```text
R-Type:
31..25 funct7 | 24..20 rs2 | 19..15 rs1 | 14..12 funct3 | 11..7 rd | 6..0 opcode

I-Type:
31..20 imm    |             19..15 rs1 | 14..12 funct3 | 11..7 rd | 6..0 opcode

S-Type:
31..25 imm    | 24..20 rs2 | 19..15 rs1 | 14..12 funct3 | 11..7 imm | 6..0 opcode
```

可以看到：

```text
rs1 总是在 inst[19:15]
rs2 如果存在，总是在 inst[24:20]
rd  如果存在，总是在 inst[11:7]
opcode 总是在 inst[6:0]
funct3 总是在 inst[14:12]
```

store 没有 `rd`，所以 `inst[11:7]` 这块位置空出来。RISC-V 把 immediate 的低 5 bits 放到这里，保留 `rs1/rs2` 的位置。

这对简单硬件设计非常关键。寄存器读写字段位置稳定，CPU 的 decode path 和 register file 连接会更直接；immediate 拆开虽然需要 ImmGen 重新拼接，但这个代价比到处移动 register fields 更划算。

## 23. S-Type 指令表

Store 指令共享 opcode：

```text
opcode = 0100011
```

用 `funct3` 区分 store size：

```text
funct3 opcode   instruction meaning
000    0100011  sb   store byte
001    0100011  sh   store halfword
010    0100011  sw   store word
```

store 只把指定大小的数据写入 memory，不需要 sign extension 或 zero extension：

```text
sb: write low 8 bits
sh: write low 16 bits
sw: write low 32 bits
```

这是因为 extension 只发生在“小数据加载进大 register”时。store 是从 32-bit register 中取低位写到 memory，不需要解释 signedness。

## 24. R/I/S 三种格式的共同设计

这讲最重要的不是死记每个 bit，而是理解 RISC-V 的字段设计。

固定字段：

```text
opcode = inst[6:0]
rd     = inst[11:7]   when present
funct3 = inst[14:12]
rs1    = inst[19:15]
rs2    = inst[24:20]  when present
```

R-Type 用 `rs1` 和 `rs2` 做寄存器运算：

```text
R[rd] = R[rs1] op R[rs2]
```

I-Type 用 `rs1` 和 immediate 做运算，或者用于 load address：

```text
R[rd] = R[rs1] op imm
```

```text
R[rd] = Memory[R[rs1] + imm]
```

S-Type 用 `rs1 + imm` 算地址，用 `rs2` 提供 store data：

```text
Memory[R[rs1] + imm] = R[rs2]
```

这三种格式已经覆盖了 CPU 项目里非常核心的一批路径：

```text
R-Type: RegFile -> ALU -> RegFile
I-Type arithmetic: RegFile + ImmGen -> ALU -> RegFile
Load: RegFile + ImmGen -> ALU address -> Memory -> RegFile
Store: RegFile + ImmGen -> ALU address, rs2 -> Memory
```

## 25. Extra Exercise: 编码 `add x4 x3 x2`

题目：

```asm
add x4 x3 x2
```

这是 R-Type。

查表：

```text
funct7 = 0000000
funct3 = 000
opcode = 0110011
```

寄存器：

```text
rd  = x4 = 00100
rs1 = x3 = 00011
rs2 = x2 = 00010
```

填字段：

```text
funct7   rs2    rs1    funct3 rd     opcode
0000000  00010  00011  000    00100  0110011
```

连成 32 bits：

```text
00000000001000011000001000110011
```

分成 hex nibbles：

```text
0000 0000 0010 0001 1000 0010 0011 0011
```

得到：

```text
0x00218233
```

所以答案是：

```text
0021 8233 hex
```

## 26. 本讲最小闭环

这一讲的最小闭环：

```text
assembly text
-> instruction format
-> fields
-> 32-bit machine instruction
-> CPU decode
```

三种格式：

```text
R-Type:
funct7 | rs2 | rs1 | funct3 | rd | opcode

I-Type:
imm[11:0] | rs1 | funct3 | rd | opcode

S-Type:
imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode
```

关键 opcode：

```text
R-Type arithmetic: 0110011
I-Type arithmetic: 0010011
Load:              0000011
Store:             0100011
```

关键直觉：

1. 所有 RV32I instruction 都是 32-bit。
2. `opcode` 决定大类和 format。
3. `funct3/funct7` 在同一大类中进一步决定具体操作。
4. register fields 尽量固定位置，是为了简化硬件。
5. S-Type 拆 immediate，是为了保留 `rs1/rs2` 的位置。
6. load 有 `rd`，store 没有 `rd`；store 的数据来自 `rs2`。

对 CPU 项目来说，这讲直接对应 instruction splitter、control logic、ImmGen：

```text
inst[6:0]   -> opcode
inst[11:7]  -> rd or imm[4:0]
inst[14:12] -> funct3
inst[19:15] -> rs1
inst[24:20] -> rs2 or imm[4:0] for shifts
inst[31:25] -> funct7 or imm[11:5]
```

后面 L14 的 B/U/J-Type 会继续展示同一个设计原则：寄存器字段和 opcode 尽量固定，immediate 可以被拆得更“奇怪”，再交给 ImmGen 重新拼起来。
