# L14 RISC-V Instruction Formats II 讲义

来源：[[../Slides/L14 RISC-V Instruction Formats II.pdf]]

配套官方 notes：[[../Notes/L14 RISC-V Instruction Formats II - official notes.html]]

## 0. 本讲目标

上一讲讲了 RV32I 的前三种 instruction format：

```text
R-Type: register-register arithmetic
I-Type: immediate arithmetic, load, jalr
S-Type: store
```

这一讲继续补完控制流和大立即数相关格式：

1. PC 如何更新，什么是 PC-relative addressing。
2. B-Type：conditional branch，例如 `beq`、`bne`、`blt`。
3. J-Type：unconditional jump and link，例如 `jal` 和伪指令 `j`。
4. `jalr`：I-Type jump register，用于返回函数和更远跳转。
5. U-Type：`lui`、`auipc`，用来构造 upper immediate 和 PC-relative 大地址。

这讲的核心是：**labels 在 machine code 里不存在，最终必须变成 immediate offset 或寄存器中的地址。**

## 1. 复习：为什么 S-Type 拆 immediate

上一讲的关键设计原则是：RISC-V 尽量让 register fields 固定在相同 bit range。

```text
rs1: inst[19:15]
rs2: inst[24:20] when present
rd:  inst[11:7]  when present
```

S-Type 没有 `rd`，因为 store 的目标是 memory，不是 register。所以它把 immediate 拆成两段：

```text
imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode
```

这样可以保留 `rs1`、`rs2` 的位置，让硬件 decode 和 register file 连接更简单。L14 的 B/J/U 型 immediate 也会继续体现这个思想：**寄存器字段和 opcode 尽量稳定，immediate 可以被拆得比较奇怪，再由 ImmGen 重新拼起来。**

## 2. PC 的默认更新

Program Counter，简称 PC，保存当前正在执行的 instruction address。

程序执行时，每一轮大致是：

```text
fetch instruction from memory using PC
execute instruction
update PC to next instruction
```

RV32I 指令长度是 32 bits：

$$
1\ \text{instruction} = 32\ \text{bits} = 4\ \text{bytes}
$$

所以默认情况下，如果没有 branch 或 jump，PC 更新为下一条顺序指令：

$$
\text{PC}_{next} = \text{PC} + 4
$$

例如当前 PC 是 `0x00000008`，下一条顺序指令地址就是：

$$
0x00000008 + 4 = 0x0000000C
$$

## 3. Addressing Modes：PC-relative vs absolute

addressing mode 指的是 instruction 怎样使用 operand 或 encoded address 来得到真正的地址。

之前 load/store 使用的是 base/displacement addressing：

$$
\text{address} = R[\text{rs1}] + \text{imm}
$$

本讲关注的是“怎样更新 PC”。RISC-V 主要有两种方式。

第一种是 PC-relative addressing：

$$
\text{PC}_{next} = \text{PC} + \text{offset}
$$

branch 和大多数 jump 都使用这种方式。默认顺序执行其实也可以看成 offset 是 $+4$。

第二种是 absolute addressing，或者更准确地说是 register-indirect absolute target：

$$
\text{PC}_{next} = R[\text{rs1}] + \text{imm}
$$

`jalr` 使用这种方式。

## 4. 为什么偏向 PC-relative addressing

RISC-V 大多数控制流使用 PC-relative addressing，是为了 position-independent code。

假设整段代码从内存地址 `0x1000` 搬到 `0x8000`，如果 branch/jump 使用的是相对偏移：

```text
target address - current PC
```

那么这段距离不变，machine code 里的 offset 也不需要变。

如果使用 absolute address，代码搬家后目标地址就变了，binary 更脆弱。

所以：

```text
PC-relative: robust when code moves
absolute: position-dependent, use sparingly
```

## 5. Label 到 offset

assembly 里可以写 label：

```asm
Loop:
    beq  x19 x10 End
    add  x18 x18 x10
    addi x19 x19 -1
    j    Loop
End:
    # target instruction
```

但 label 本身不进入 machine code。assembler 要把 label 翻译成数字 offset。

假设地址如下：

```text
0x0C  Loop: beq  x19 x10 End
0x10        add  x18 x18 x10
0x14        addi x19 x19 -1
0x18        j    Loop
0x1C  End:  ...
```

如果 `beq` taken，从 `0x0C` 跳到 `0x1C`：

$$
\text{offset} = 0x1C - 0x0C = 0x10 = 16
$$

如果 `j Loop`，从 `0x18` 跳到 `0x0C`：

$$
\text{offset} = 0x0C - 0x18 = -0x0C = -12
$$

如果 `beq` not taken，则顺序执行下一条：

$$
\text{offset} = +4
$$

注意：taken/not taken 是运行时决定的；但 label 的 target offset 是汇编时可计算的。

## 6. B-Type 总览

B-Type 用于 conditional branch。语法：

```asm
branchop rs1 rs2 Label
```

例如：

```asm
beq x19 x10 End
```

语义：

```text
if R[x19] == R[x10]:
    PC = address of End
else:
    PC = PC + 4
```

PC-relative 写法是：

$$
\text{PC}_{next} = \text{PC} + \text{offset}
$$

B-Type instruction format：

```text
31             25 24   20 19   15 14  12 11              7 6      0
+----------------+-------+-------+------+------------------+---------+
| imm[12|10:5]   |  rs2  |  rs1  |funct3| imm[4:1|11]     | opcode  |
+----------------+-------+-------+------+------------------+---------+
       7 bits     5 bits  5 bits 3 bits       5 bits        7 bits
```

字段含义：

```text
rs1, rs2: 两个比较输入
funct3: 决定 beq/bne/blt/bge 等比较类型
opcode: branch opcode, 1100011
imm: PC-relative signed offset, 但被拆开编码
```

## 7. B-Type immediate 怎么拼

B-Type 的 offset 是一个 13-bit signed immediate：

```text
imm[12:0]
```

但是 `imm[0]` 永远是 0：

```text
imm[0] = 0
```

原因是 branch target 至少按 2-byte 对齐；在普通 RV32I 中指令是 4 bytes，但 RISC-V 还考虑了 16-bit compressed instruction extension，所以低 1 bit 可以省掉。

B-Type 在 instruction 中只存 12 个 bits，解码时补回 `imm[0]=0`：

```text
encoded bits -> imm[12], imm[10:5], imm[4:1], imm[11], plus imm[0]=0
```

拼接顺序是：

```text
imm[12]   = inst[31]
imm[10:5] = inst[30:25]
imm[4:1]  = inst[11:8]
imm[11]   = inst[7]
imm[0]    = 0
```

也就是：

```text
imm[12:0] = {inst[31], inst[7], inst[30:25], inst[11:8], 0}
```

这个顺序看起来绕，是为了保持 S-Type/I-Type 的 immediate bit 位置尽量相似，降低硬件连线成本。

## 8. B-Type 例子：`beq x19 x10 End`

例子：

```asm
Loop:
    beq  x19 x10 End
    add  x18 x18 x10
    addi x19 x19 -1
    j    Loop
End:
    ...
```

假设 `beq` 在 `0x0C`，`End` 在 `0x1C`：

$$
\text{offset} = 0x1C - 0x0C = 16
$$

十进制 16 的 13-bit immediate：

```text
imm[12:0] = 0000000010000
```

字段：

```text
rs1 = x19 = 10011
rs2 = x10 = 01010
funct3 for beq = 000
opcode for branch = 1100011
```

把 immediate 拆到 B-Type：

```text
imm[12|10:5] rs2    rs1    funct3 imm[4:1|11] opcode
0000000      01010  10011  000    10000        1100011
```

所以关键不是把 `16` 直接写进连续字段，而是先把 offset 变成 `imm[12:0]`，再按 B-Type 的奇怪顺序分发到 instruction bits。

## 9. Branch range

B-Type offset 是 13-bit two's complement，且最低 bit 固定为 0。按 bytes 看，它覆盖：

$$
[-2^{12},\ 2^{12}-2]\ \text{bytes}
$$

也就是：

```text
[-4096, 4094] bytes, step = 2 bytes
```

因为 RV32I 普通 instruction 是 4 bytes，如果换算成 32-bit instruction 数量，大约是：

$$
\pm 2^{10}\ \text{instructions}
$$

这就是课件选择题的答案：conditional branch 大约能 reach $\pm 2^{10}$ 条 32-bit instructions from PC。

为什么不是按 word offset 编码，从而扩大范围？因为 RISC-V 要兼容 compressed 16-bit instructions，所以 branch offset 以 2-byte 为粒度，而不是 4-byte。

## 10. B-Type 指令表

B-Type branch 共享 opcode：

```text
opcode = 1100011
```

用 `funct3` 区分比较方式：

```text
funct3 opcode   instruction meaning
000    1100011  beq   branch if equal
001    1100011  bne   branch if not equal
100    1100011  blt   branch if less than, signed
101    1100011  bge   branch if greater/equal, signed
110    1100011  bltu  branch if less than, unsigned
111    1100011  bgeu  branch if greater/equal, unsigned
```

这里 signed/unsigned 的差别和之前的 `slt/sltu` 类似：register 里的 bits 相同，但比较解释不同。

## 11. J-Type：`jal`

J-Type 用于 `jal`，即 jump and link。

语法：

```asm
jal rd Label
```

含义：

```text
R[rd] = PC + 4
PC = address of Label
```

用 PC-relative 形式写：

$$
R[\text{rd}] \leftarrow \text{PC} + 4
$$

$$
\text{PC}_{next} \leftarrow \text{PC} + \text{offset}
$$

为什么要写 `PC + 4` 到 `rd`？因为这是 return address。函数调用时，跳到函数入口前，需要记住“调用结束后回到哪里继续执行”。

常见调用写法：

```asm
jal ra function
```

其中 `ra` 是 return address register，也就是 `x1`。

如果只是无条件跳转、不需要返回地址，可以用伪指令：

```asm
j Label
```

它等价于：

```asm
jal x0 Label
```

因为写入 `x0` 的返回地址会被丢弃。

## 12. J-Type instruction format

J-Type format：

```text
31                         12 11    7 6      0
+----------------------------+-------+---------+
| imm[20|10:1|11|19:12]      |  rd   | opcode  |
+----------------------------+-------+---------+
             20 bits          5 bits  7 bits
```

`jal` 的 opcode：

```text
opcode = 1101111
```

J-Type 的 offset 是 21-bit signed immediate：

```text
imm[20:0]
```

并且：

```text
imm[0] = 0
```

在 instruction 中的拼接方式：

```text
imm[20]    = inst[31]
imm[10:1]  = inst[30:21]
imm[11]    = inst[20]
imm[19:12] = inst[19:12]
imm[0]     = 0
```

即：

```text
imm[20:0] = {inst[31], inst[19:12], inst[20], inst[30:21], 0}
```

同样，这是 bit swirling：看起来绕，但有利于硬件复用 immediate 生成逻辑。

## 13. Jump 相关指令和伪指令

常见 jump：

```text
jal rd Label       # jump and link
j Label            # pseudo, jal x0 Label
jalr rd rs1 imm    # jump and link register
jr rs1             # pseudo, jalr x0 rs1 0
ret                # pseudo, jalr x0 ra 0
```

分类：

```text
J-Type: jal, j
I-Type: jalr, jr, ret
```

用途：

```text
call function: jal, jalr
return from function: ret, jr, jalr
break out of loops: j or conditional branch
```

PC addressing：

```text
jal/j: PC-relative
jalr/jr/ret: PC = R[rs1] + imm
```

## 14. `jalr`

`jalr` 是 jump and link register，使用 I-Type format。

语法：

```asm
jalr rd rs1 imm
```

含义：

$$
R[\text{rd}] \leftarrow \text{PC} + 4
$$

$$
\text{PC}_{next} \leftarrow R[\text{rs1}] + \text{imm}
$$

它和 `jal` 的区别是：

```text
jal:  target = PC + offset
jalr: target = R[rs1] + imm
```

所以 `jalr` 用于：

1. 从函数返回：

```asm
ret
```

等价于：

```asm
jalr x0 ra 0
```

2. 跳到寄存器中保存的地址。
3. 配合 `auipc` 做更远的跳转。

`jalr` 的 I-Type format：

```text
31              20 19   15 14  12 11    7 6      0
+----------------+-------+------+-------+---------+
|   imm[11:0]    |  rs1  |funct3|  rd   | opcode  |
+----------------+-------+------+-------+---------+
```

其中：

```text
rd: receives return address PC + 4
rs1: base register for target address
imm: offset added to rs1
```

## 15. Branch、J-Type、jalr 的距离

branch 的范围相对较小：

```text
B-Type: about +/- 2^10 32-bit instructions
```

但一般 if/else、loop 的控制流都很局部，通常够用。

`jal` 的范围更大：

```text
J-Type: about +/- 2^18 32-bit instructions
```

适合跳到更远的代码位置，例如函数或库附近。

如果还不够，可以用 `jalr`，因为它的目标来自 register，可以先构造更大的地址：

```text
auipc + jalr
```

不过 `jalr` 更接近 absolute addressing，代码位置变化时更脆弱，所以要谨慎使用。

## 16. U-Type：`lui` 和 `auipc`

U-Type 用于 upper immediate instructions：

```asm
lui   rd immu
auipc rd immu
```

其中 `immu` 是 upper immediate，即 32-bit immediate 的高 20 bits。

U-Type format：

```text
31                    12 11    7 6      0
+-----------------------+-------+---------+
|      imm[31:12]       |  rd   | opcode  |
+-----------------------+-------+---------+
          20 bits        5 bits  7 bits
```

真正参与计算的 immediate 是：

$$
\text{imm} = \text{immu} \ll 12
$$

也就是把 `immu` 放到高 20 bits，低 12 bits 清零。

## 17. `lui`

`lui` 是 load upper immediate。

语法：

```asm
lui rd immu
```

含义：

$$
R[\text{rd}] \leftarrow \text{immu} \ll 12
$$

也就是：

```text
upper 20 bits = immu
lower 12 bits = 0
```

例子：

```asm
lui x10 0x87654
```

结果：

$$
R[x10] = 0x87654000
$$

因为：

$$
0x87654 \ll 12 = 0x87654000
$$

## 18. `auipc`

`auipc` 是 add upper immediate to PC。

语法：

```asm
auipc rd immu
```

含义：

$$
R[\text{rd}] \leftarrow \text{PC} + (\text{immu} \ll 12)
$$

它常用于构造 PC-relative 大地址。比如一段代码整体移动后，`PC` 和目标都一起移动，用 `PC + offset` 的方式仍然更容易保持位置无关。

直觉上：

```text
lui:   build large constant from zero base
auipc: build large PC-relative address from PC base
```

## 19. 用 `lui + addi` 构造 32-bit 常数

`addi` 只有 12-bit immediate，不能单独构造任意 32-bit 常数。`lui` 可以设置高 20 bits，`addi` 可以补低 12 bits。

例如：

```asm
li x10 0x87654321
```

可以展开成：

```asm
lui  x10 0x87654
addi x10 x10 0x321
```

第一步：

$$
R[x10] = 0x87654 \ll 12 = 0x87654000
$$

第二步：

$$
R[x10] = 0x87654000 + 0x321 = 0x87654321
$$

所以 `li` 是 pseudoinstruction：当常数较小时可能变成一条 `addi`，当常数较大时 assembler 会展开成 `lui + addi` 或其他组合。

## 20. `lui + addi` 的边界问题：`addi` 会 sign-extend

问题：

```asm
li x10 0xB0BACAFE
```

直觉上你可能想写：

```asm
lui  x10 0xB0BAC
addi x10 x10 0xAFE
```

但是这是错的。

原因是 `addi` 的 12-bit immediate 会 sign-extend。`0xAFE` 作为 12-bit 数：

```text
0xAFE = 1010 1111 1110
```

最高 bit 是 1，所以它作为 signed 12-bit immediate 是负数：

$$
0xAFE_{12-bit} = -1282
$$

sign-extend 到 32 bits 后是：

```text
0xFFFFFAFE
```

所以：

```asm
lui  x10 0xB0BAC
addi x10 x10 0xAFE
```

实际得到：

$$
0xB0BAC000 + 0xFFFFFAFE = 0xB0BABAFE
$$

低 12 bits 看起来是 `0xAFE`，但因为它是负数，相当于从 upper 20 bits 借走了 1：

```text
0xB0BAC000 - 0x502 = 0xB0BABAFE
```

不是目标：

```text
0xB0BACAFE
```

## 21. 修正办法：低 12 bits 为负时，上 20 bits 加 1

如果低 12 bits 的最高位是 1，也就是：

$$
\text{low12} \ge 0x800
$$

那么 `addi` 会把它当负数。为了抵消这个影响，`lui` 的 upper immediate 要提前加 1。

目标：

```asm
li x10 0xB0BACAFE
```

正确展开：

```asm
lui  x10 0xB0BAD
addi x10 x10 0xAFE
```

第一步：

$$
R[x10] = 0xB0BAD000
$$

第二步 `0xAFE` sign-extend 后等于：

$$
0xFFFFFAFE = -0x502
$$

所以：

$$
0xB0BAD000 - 0x502 = 0xB0BACAFE
$$

这正好得到目标值。

可以记成 assembler 的修正规则：

```text
if low12 has sign bit 1:
    upper20 = upper20 + 1
```

这也是为什么手写 `lui + addi` 构造常数时不能简单把 32-bit hex 切成高 20 位和低 12 位，需要考虑 `addi` 的 sign extension。

## 22. U-Type 指令表

U-Type 只有两个核心指令：

```text
opcode   instruction
0010111  auipc
0110111  lui
```

字段：

```text
imm[31:12] rd opcode
```

语义：

$$
\text{lui}: R[\text{rd}] \leftarrow \text{immu} \ll 12
$$

$$
\text{auipc}: R[\text{rd}] \leftarrow \text{PC} + (\text{immu} \ll 12)
$$

## 23. 和 CPU 项目的关系

如果把 L14 放回 datapath/control 视角，它主要影响三块。

第一，PC update logic：

```text
default: PC + 4
branch taken: PC + B-imm
jal: PC + J-imm
jalr: R[rs1] + I-imm
```

第二，ImmGen：

```text
B-Type: {inst[31], inst[7], inst[30:25], inst[11:8], 0}
J-Type: {inst[31], inst[19:12], inst[20], inst[30:21], 0}
U-Type: {inst[31:12], 12'b0}
```

第三，writeback：

```text
jal/jalr: write PC + 4 to rd, unless rd = x0
lui: write immu << 12 to rd
auipc: write PC + (immu << 12) to rd
branch: no rd writeback
```

这也是为什么 instruction formats 不只是“背编码表”：它们直接决定 CPU 的 splitter、ImmGen、branch comparator、PC mux、writeback mux 和 control signals。

## 24. 本讲最小闭环

这一讲的最小闭环：

```text
PC normally += 4
labels disappear in machine code
labels become PC-relative offsets
B-Type encodes conditional branch offsets
J-Type encodes jal offsets and writes return address
jalr jumps through register + immediate
U-Type builds upper immediates
lui + addi can build 32-bit constants, but addi sign-extends
```

四种本讲关键格式：

```text
B-Type:
imm[12|10:5] | rs2 | rs1 | funct3 | imm[4:1|11] | opcode

J-Type:
imm[20|10:1|11|19:12] | rd | opcode

I-Type jalr:
imm[11:0] | rs1 | funct3 | rd | opcode

U-Type:
imm[31:12] | rd | opcode
```

最重要的语义：

$$
\text{branch taken}: \text{PC}_{next} = \text{PC} + \text{B-imm}
$$

$$
\text{jal}: R[\text{rd}] = \text{PC} + 4,\quad \text{PC}_{next} = \text{PC} + \text{J-imm}
$$

$$
\text{jalr}: R[\text{rd}] = \text{PC} + 4,\quad \text{PC}_{next} = R[\text{rs1}] + \text{imm}
$$

$$
\text{lui}: R[\text{rd}] = \text{immu} \ll 12
$$

$$
\text{auipc}: R[\text{rd}] = \text{PC} + (\text{immu} \ll 12)
$$

学完 L13/L14 后，RV32I 的六种基本格式已经基本齐了：

```text
R, I, S, B, U, J
```

接下来做 CPU 时，最关键的是把这些格式转成稳定的硬件模块：

```text
Instruction Splitter
Register File addresses
Immediate Generator
ALU input mux
Branch Comparator
PC selection logic
Writeback selection logic
```
