# L10 RISC-V Data Transfer 讲义

来源：[[Slides/L10 RISC-V Data Transfer.pdf]]

配套官方 notes：[[Notes/L10 RISC-V Data Transfer - official notes.html]]

## 0. 本讲目标

上一讲已经建立了 RV32I 的最小算术模型：

```asm
add rd rs1 rs2
sub rd rs1 rs2
addi rd rs1 imm
```

对应语义是：

$$
R[\text{rd}] \leftarrow R[\text{rs1}] + R[\text{rs2}]
$$

$$
R[\text{rd}] \leftarrow R[\text{rs1}] - R[\text{rs2}]
$$

$$
R[\text{rd}] \leftarrow R[\text{rs1}] + \text{imm}
$$

这里 $R[\text{rs1}]$ 表示编号为 `rs1` 的寄存器中保存的数据。幻灯片特别提醒：这个写法不是说 RISC-V 里真的有一个叫 `R` 的数组，而是用 Verilog/体系结构记号描述“读某个寄存器”的操作。

这一讲从“寄存器内部算术”走到“寄存器和内存之间传数据”。核心问题是：

```text
如果数据不在 register 里，而在 memory 里，RISC-V 怎么访问它？
```

本讲要掌握：

1. `x0` 和 pseudoinstruction `li` 的关系。
2. RISC-V 为什么叫 load-store architecture。
3. `lw` 和 `sw` 的语法、方向、地址计算。
4. byte-level transfer：`lb`、`lbu`、`sb`。
5. sign extension 和 zero extension 的区别。
6. stack pointer `sp` 和 register convention。
7. 用 load/store 翻译局部变量、字符串、数组访问。

## 1. 复习 immediate、`x0` 和 `li`

Immediate 是直接编码在指令里的数字常量。例如：

```asm
addi x3 x4 10
```

含义是：

$$
R[x3] \leftarrow R[x4] + 10
$$

如果 `f -> x3`，`g -> x4`，它对应：

```c
f = g + 10;
```

RISC-V 没有专门的 subtract immediate 指令。因为：

$$
g - 10 = g + (-10)
$$

所以：

```asm
addi x3 x4 -10
```

就可以表达：

```c
f = g - 10;
```

这体现 RISC 哲学：如果一个操作能由已有简单操作表达，就不一定要把它加入 ISA。

## 2. Register Zero `x0`

RISC-V 把 `x0` 硬连为 0：

$$
R[x0] = 0
$$

任何对 `x0` 的写入都会被丢弃，读 `x0` 永远得到 0。

假设：

```text
f -> x3
g -> x4
```

则：

```asm
addi x3 x0 0xff
```

表示：

$$
R[x3] \leftarrow R[x0] + 0xff = 0xff
$$

对应：

```c
f = 0xff;
```

再看：

```asm
sub x3 x0 x4
```

表示：

$$
R[x3] \leftarrow R[x0] - R[x4] = -R[x4]
$$

对应：

```c
f = -g;
```

而：

```asm
add x0 x3 x4
```

虽然形式上是在计算：

$$
R[x0] \leftarrow R[x3] + R[x4]
$$

但结果写入 `x0` 会被丢掉，所以它是 no-op：

```c
// no operation
```

## 3. Pseudoinstruction: `li`

因为“把一个常数放进寄存器”太常用了，RISC-V assembly 允许写一个更方便的伪指令：

```asm
li x3 0xff
```

`li` 是 load immediate。它不是这里真正要强调的 base hardware instruction，而是 assembler 提供的 convenient instruction。

assembler 会把它替换成真实指令，例如：

```asm
addi x3 x0 0xff
```

再组装成 machine code bits。

所以要区分：

```text
pseudoinstruction: 程序员写起来方便
real instruction: ISA 真正编码和硬件执行的指令
```

这对后面看反汇编和 CPU 项目很重要：你在源码里看到 `li`，但硬件实现时可能只需要支持对应的真实指令组合。

## 4. 课程公告页

幻灯片中间有一页 announcements，包括 discussion 调整、holiday、quest 练习等。这些是课程行政信息，不影响 RISC-V 技术内容。作为讲义只记住：本讲技术主线从这里正式进入 data transfer instructions。

## 5. RISC-V 是 Load-Store Architecture

RISC-V 是 load-store architecture。意思是：

1. 算术/逻辑操作只直接作用在 registers 上。
2. 如果数据在 memory 中，要先 load 到 register。
3. 如果 register 里的结果需要保存到 memory，要执行 store。

基本流程是：

```text
load from memory into register
-> operate on registers inside CPU
-> store result back to memory if needed
```

方向要从 CPU/processor 的视角理解：

```text
load from memory: memory -> register
store to memory: register -> memory
```

这句话非常关键：

```text
Load from memory, store to memory.
```

不要说反。load 是把数据从 memory 读进处理器；store 是把处理器里的数据写到 memory。

## 6. `lw`: Load Word

`lw` 是 load word，语法：

```asm
lw rd imm(rs1)
```

含义分两步：

1. 计算地址：

$$
\text{addr} = R[\text{rs1}] + \text{imm}
$$

2. 从该地址开始加载 4 bytes 到 `rd`：

$$
R[\text{rd}] \leftarrow \text{Memory}[\text{addr}:\text{addr}+3]
$$

其中 `rs1` 常叫 base register，`imm` 常叫 offset。`imm` 是 assembly time 已知的常数偏移。

因为 `lw` 加载一个 32-bit word，所以地址必须 word-aligned。也就是：

$$
\text{addr} \equiv 0 \pmod{4}
$$

如果地址不是 4 的倍数，就不是 word-aligned。

## 7. `lw` 例子

指令：

```asm
lw x10 12(x5)
```

假设：

$$
R[x5] = 0x100
$$

则计算地址：

$$
\text{addr} = 0x100 + 12 = 0x10C
$$

从 `0x10C` 开始读 4 bytes。幻灯片给出的内存行是：

```text
address   +3    +2    +1    +0
0x10C     0x00  0x56  0x42  0x53
```

注意右侧 `+0` 是最低地址 byte，也就是地址 `0x10C` 的内容为 `0x53`。这一页按 little endian 组织成 32-bit word：

```text
byte at addr+0 = 0x53
byte at addr+1 = 0x42
byte at addr+2 = 0x56
byte at addr+3 = 0x00
```

因此加载到 `x10` 的 word 是：

$$
R[x10] = 0x00564253
$$

这里容易错的点是把表格从左到右直接拼成 `0x00564253` 还是 `0x53425600`。RISC-V 通常采用 little endian：低地址保存 least significant byte。

## 8. `sw`: Store Word

`sw` 是 store word，语法：

```asm
sw rs2 imm(rs1)
```

注意 `sw` 没有 `rd`。因为 store 的目标不是 register，而是 memory address。

含义分两步：

1. 计算地址：

$$
\text{addr} = R[\text{rs1}] + \text{imm}
$$

2. 把 `rs2` 中的 4 bytes 写到该地址开始的内存：

$$
\text{Memory}[\text{addr}:\text{addr}+3] \leftarrow R[\text{rs2}]
$$

同样，`sw` 写入一个 word，所以地址必须 word-aligned：

$$
\text{addr} \equiv 0 \pmod{4}
$$

## 9. `sw` 例子

指令：

```asm
sw x10 0(x5)
```

假设：

$$
R[x5] = 0x100
$$

$$
R[x10] = 0x12345678
$$

地址计算：

$$
\text{addr} = 0x100 + 0 = 0x100
$$

因为是 little endian，最低有效 byte `0x78` 写入最低地址：

```text
address   byte
0x100     0x78
0x101     0x56
0x102     0x34
0x103     0x12
```

所以内存表按 `+3 +2 +1 +0` 显示时会看到：

```text
address   +3    +2    +1    +0
0x100     0x12  0x34  0x56  0x78
```

`lw` 和 `sw` 的对称关系可以记为：

```text
lw rd imm(rs1):  memory -> rd
sw rs2 imm(rs1): rs2 -> memory
```

## 10. Byte-Level Data Transfer

除了 4-byte word，程序也常常要操作 1-byte 数据，例如 `char`、`uint8_t`、字符串字符等。

相关指令包括：

```asm
lb  rd imm(rs1)   # load byte, signed
lbu rd imm(rs1)   # load byte, unsigned
sb  rs2 imm(rs1)  # store byte
```

terminology：

```text
base register: rs1
offset: imm
effective address: R[rs1] + imm
```

这里的 `imm` 必须是 assembly time 已知的常数。如果数组下标是运行时变量，不能直接把变量塞进 `imm`，需要先用算术指令算出地址。

## 11. `sb`: Store Byte

`sb` 只存 `rs2` 的 least significant byte。

指令：

```asm
sb x10 0(x5)
```

假设：

$$
R[x5] = 0x100
$$

$$
R[x10] = 0x123456EF
$$

地址：

$$
\text{addr} = 0x100 + 0 = 0x100
$$

`sb` 只取最低 8 bits：

$$
R[x10] \& 0xff = 0xEF
$$

所以写入：

```text
Memory[0x100] = 0xEF
```

高位的 `0x123456` 不会被写入。

这也解释了为什么 store byte 只有一个 `sb`，没有 signed/unsigned 两个版本。store 只是把低 8 bits 原样写进内存，不需要解释符号。

## 12. `lb` 和 `lbu`: 为什么 load byte 有两个版本

load byte 的问题是：memory 中只读出 8 bits，但 register 是 32 bits。

所以必须决定高 24 bits 怎么填：

```text
8-bit byte -> 32-bit register
```

如果这 8 bits 表示 signed 8-bit integer，就要 sign-extend：

```asm
lb x10 0(x5)
```

如果这 8 bits 表示 unsigned 8-bit integer，就要 zero-extend：

```asm
lbu x10 0(x5)
```

以 `0xEF` 为例。8-bit 中：

```text
0xEF = 1110 1111
```

最高 bit 是 1。

### `lb`: sign-extend

`lb` 把它当作 signed 8-bit integer。因为最高 bit 是 1，所以它表示负数：

$$
0xEF = -17 \quad \text{as signed 8-bit}
$$

sign extension 会把符号位 1 复制到高位：

```text
0xEF -> 0xFFFFFFEF
```

所以：

$$
R[x10] = 0xFFFFFFEF
$$

### `lbu`: zero-extend

`lbu` 把它当作 unsigned 8-bit integer：

$$
0xEF = 239 \quad \text{as unsigned 8-bit}
$$

zero extension 会把高位补 0：

```text
0xEF -> 0x000000EF
```

所以：

$$
R[x10] = 0x000000EF
$$

这就是为什么 load byte 需要两个版本，而 store byte 只需要一个版本：

```text
load: 8 bits -> 32 bits, must decide extension rule
store: 32 bits -> 8 bits, just keep low byte
```

## 13. Assembly 中 register 没有类型

高级语言里，变量类型由声明决定：

```c
uint8_t x, *y;
x = *y;
x = 4 * x;
```

但在 RISC-V 里，register 本身没有类型。`x4` 或 `t0` 只是 32 bits。

具体解释由 instruction 决定：

```asm
lb  x4 0(x3)
add x2 x3 x4
```

第一条 `lb` 暗示从内存取一个 signed byte 并 sign-extend。第二条 `add` 把两个 register 内容当作整数加法输入。

因此：

```text
C/Java: variable declaration carries type
RISC-V: instruction opname determines interpretation
```

这一点对 `lb` vs `lbu` 很重要。你要根据源语言里的类型，比如 `char`、`int8_t`、`uint8_t`，选择 sign-extend 还是 zero-extend。

## 14. Register Convention 和 Stack Pointer

RISC-V 有 32 个寄存器，除了 `x0` 这种硬件特殊寄存器外，很多寄存器还有 ABI 约定名称。

常见例子：

```text
t0, t1, t2: temporary registers
sp: stack pointer
```

`sp` 是 stack pointer，指向栈上一块可用内存区域的起点。局部变量太多、数组太大、或者 register 不够用时，就需要把数据放到 memory 中，常见位置就是 stack frame。

可以把 stack frame 理解为当前函数在栈上分配的一小块区域：

```text
sp + offset -> local variable
```

例如：

```text
a: 0(sp)
b: 4(sp)
c: 12(sp)
d: 52(sp)
```

意思是：

```text
a starts at address R[sp] + 0
b starts at address R[sp] + 4
c starts at address R[sp] + 12
d starts at address R[sp] + 52
```

## 15. Stack Frame 大例子

幻灯片的大例子是把下面 C 代码翻译到 RISC-V：

```c
int a = 5;
char b[] = "string";
int c[10];
uint8_t d = b[3];
c[4] = a + d;
c[a] = 20;
```

变量在 stack frame 中的布局：

```text
a: 0(sp)
b: 4(sp)
c: 12(sp)
d: 52(sp)
```

这个布局的大小来自各变量需要的空间：

1. `a` 是 `int`，占 4 bytes。
2. `b[] = "string"` 包含 6 个字符加 `'\0'`，共 7 bytes；为了对齐，后面会留 padding。
3. `c[10]` 是 10 个 `int`，占：

$$
10 \times 4 = 40\ \text{bytes}
$$

4. `d` 是 `uint8_t`，占 1 byte。

`c` 从 `12(sp)` 开始，`c[10]` 占 40 bytes，所以 `d` 放在：

$$
12 + 40 = 52
$$

也就是 `52(sp)`。

## 16. Line 1: `int a = 5;`

初始化整数 `a`：

```asm
li t0 5       # R[t0] = 5
sw t0 0(sp)   # store int a on stack
```

第一条是 pseudoinstruction，先把常数 5 放进临时寄存器：

$$
R[t0] \leftarrow 5
$$

第二条把这个 word 写到 `a` 的位置：

$$
\text{Memory}[R[sp]+0 : R[sp]+3] \leftarrow R[t0]
$$

如果写成 32-bit 值：

```text
a = 0x00000005
```

在 little endian 内存里，最低地址保存 `0x05`。

## 17. Line 2: `char b[] = "string";`

字符串 `"string"` 的 ASCII byte 是：

```text
's'  't'  'r'  'i'  'n'  'g'  '\0'
0x73 0x74 0x72 0x69 0x6E 0x67 0x00
```

最直观但低效的写法是逐字节 store：

```asm
li t0 0x73
sb t0 4(sp)
li t0 0x74
sb t0 5(sp)
li t0 0x72
sb t0 6(sp)
li t0 0x69
sb t0 7(sp)
li t0 0x6E
sb t0 8(sp)
li t0 0x67
sb t0 9(sp)
sb x0 10(sp)
```

这能工作，但指令太多。

更好的写法是按 word 打包后 `sw`：

```asm
li t0 0x69727473   # ASCII stri
sw t0 4(sp)        # little endian
li t1 0x0000676E   # ASCII ng\0\0
sw t1 8(sp)
```

为什么第一个 word 是 `0x69727473`？因为 little endian 里最低地址放 least significant byte：

```text
address   byte
4(sp)     0x73  's'
5(sp)     0x74  't'
6(sp)     0x72  'r'
7(sp)     0x69  'i'
```

如果作为一个 32-bit register value 来写，就是：

```text
0x69727473
```

第二个 word：

```text
address   byte
8(sp)     0x6E  'n'
9(sp)     0x67  'g'
10(sp)    0x00  '\0'
11(sp)    0x00  padding
```

对应 register value：

```text
0x0000676E
```

## 18. Line 3: `int c[10];`

这行只是声明数组：

```c
int c[10];
```

如果没有初始化，就不需要执行任何 load/store。内存中原来是什么就还是什么，幻灯片用 gray/random garbage 表示。

这一点很贴近 C 的语义：局部未初始化数组的内容是未定义/垃圾值；声明本身只是分配 stack frame 空间，不一定会清零。

## 19. Line 4: `uint8_t d = b[3];`

`b` 从 `4(sp)` 开始，`b[3]` 的地址是：

$$
R[sp] + 4 + 3 = R[sp] + 7
$$

`b[3]` 是字符 `'i'`：

```text
'i' = 0x69
```

幻灯片代码：

```asm
lb t0 7(sp)     # 4(sp) from b, 3(sp) from [3]
sb t0 52(sp)    # store into d
```

因为 `d` 是 `uint8_t`，更严格地说，用 `lbu` 读 byte 会更贴近 unsigned 语义：

```asm
lbu t0 7(sp)
sb  t0 52(sp)
```

但这里读取的是 `0x69`，最高 bit 是 0，所以 `lb` 和 `lbu` 得到的 32-bit 结果相同：

$$
0x69 \rightarrow 0x00000069
$$

最后：33

```text
d = 0x69
```

存到 `52(sp)` 的低 1 byte。

## 20. Line 5: `c[4] = a + d;`

这行涉及 constant array index。

先算 `c[4]` 的地址。`c` 从 `12(sp)` 开始，每个 `int` 占 4 bytes：

$$
\text{offset}(c[4]) = 12 + 4 \times \text{sizeof(int)}
$$

因为：

$$
\text{sizeof(int)} = 4
$$

所以：

$$
\text{offset}(c[4]) = 12 + 4 \times 4 = 28
$$

因此 `c[4]` 在：

```text
28(sp)
```

代码：

```asm
lw  t0 0(sp)     # load a
lbu t1 52(sp)    # load d
add t2 t0 t1     # R[t2] = a + d
sw  t2 28(sp)    # 12(sp) from c, 16(sp) from [4]
```

数值上：

$$
a = 5 = 0x00000005
$$

$$
d = 0x69 = 105
$$

所以：

$$
a+d = 5+105 = 110 = 0x6E
$$

因此 `c[4]` 被写成：

```text
0x0000006E
```

注意这里必须用 `lbu` 读取 `d`。因为 `d` 是 `uint8_t`，应该 zero-extend。

## 21. Line 6: `c[a] = 20;`

这一行是 variable array index。和 `c[4]` 不同，`a` 的值要运行时从内存读出来，不能直接写进 `imm`。

目标地址：

$$
\&c[a] = R[sp] + 12 + a \times \text{sizeof(int)}
$$

因为：

$$
\text{sizeof(int)} = 4 = 2^2
$$

所以乘 4 可以用左移 2 位：

$$
a \times 4 = a \ll 2
$$

代码：

```asm
li   t0 20       # R[t0] = 20
lw   t1 0(sp)    # R[t1] = a
slli t1 t1 2     # a * sizeof(int) = a * 4 = a << 2
addi t1 t1 12    # offset from c base
add  t1 t1 sp    # compute &c[a]
sw   t0 0(t1)    # c[a] = 20
```

逐步看：

1. `li t0 20`：

$$
R[t0] \leftarrow 20 = 0x14
$$

2. `lw t1 0(sp)`：

$$
R[t1] \leftarrow a = 5
$$

3. `slli t1 t1 2`：

$$
R[t1] \leftarrow 5 \ll 2 = 20
$$

4. `addi t1 t1 12`：

$$
R[t1] \leftarrow 20 + 12 = 32
$$

5. `add t1 t1 sp`：

$$
R[t1] \leftarrow R[sp] + 32
$$

6. `sw t0 0(t1)`：

$$
\text{Memory}[R[sp]+32 : R[sp]+35] \leftarrow 20
$$

因为 `a = 5`，这条语句实际写的是：

```c
c[5] = 20;
```

而 `c[5]` 的 offset 是：

$$
12 + 5 \times 4 = 32
$$

## 22. Full Code 汇总

把整个例子合起来：

```asm
li   t0 5            # R[t0] = 5
sw   t0 0(sp)        # store int a on stack

li   t0 0x69727473   # ASCII stri
sw   t0 4(sp)        # store first part of string
li   t1 0x0000676E   # ASCII ng\0\0
sw   t1 8(sp)        # store rest of string

lb   t0 7(sp)        # 4(sp) from b, 3(sp) from [3]
sb   t0 52(sp)       # store into d

lw   t0 0(sp)        # load a
lbu  t1 52(sp)       # load d
add  t2 t0 t1        # R[t2] = a + d
sw   t2 28(sp)       # c[4] = a + d

li   t0 20           # R[t0] = 20
lw   t1 0(sp)        # R[t1] = a
slli t1 t1 2         # a * 4 = a << 2
addi t1 t1 12        # add c base offset
add  t1 t1 sp        # compute &c[a]
sw   t0 0(t1)        # c[a] = 20
```

这里有几条非常值得记：

1. 常数数组下标可以直接折算成 immediate offset，例如 `c[4]` 是 `28(sp)`。
2. 变量数组下标必须运行时计算地址，例如 `c[a]` 要先算 `a * 4 + 12 + sp`。
3. byte load 进入 32-bit register 时必须决定 sign/zero extension。
4. byte store 只写 low 8 bits。
5. little endian 会影响你如何把字符串 byte 打包成 word。

## 23. 和 CPU 项目的接口关系

对 CPU 项目来说，L10 最重要的是把 `lw/sw/lb/lbu/sb` 变成 datapath 信号。

`lw` 大致需要：

```text
ALU computes address = R[rs1] + imm
Data memory reads from address
Read data writes back to rd
```

`sw` 大致需要：

```text
ALU computes address = R[rs1] + imm
Register file reads rs2 as write data
Data memory writes write data to address
No rd writeback
```

`sb` 还需要 byte write enable，只写目标 byte；`lb/lbu` 还需要从 memory read data 中抽出对应 byte，并做 sign extension 或 zero extension。

如果用一句话总结：

```text
load uses rd; store uses rs2.
```

因为：

```text
load: memory -> register destination rd
store: register source rs2 -> memory
```

## 24. 本讲最小闭环

最小必须掌握的指令：

```asm
lw  rd  imm(rs1)   # R[rd] = Memory[R[rs1] + imm], 4 bytes
sw  rs2 imm(rs1)   # Memory[R[rs1] + imm] = R[rs2], 4 bytes
lb  rd  imm(rs1)   # load 1 byte, sign-extend
lbu rd  imm(rs1)   # load 1 byte, zero-extend
sb  rs2 imm(rs1)   # store low 1 byte of R[rs2]
```

地址计算统一是：

$$
\text{addr} = R[\text{rs1}] + \text{imm}
$$

word 大小：

$$
1\ \text{word} = 4\ \text{bytes} = 32\ \text{bits}
$$

byte load 扩展：

$$
\text{lb}: \text{sign-extend}(8\ \text{bits}) \rightarrow 32\ \text{bits}
$$

$$
\text{lbu}: \text{zero-extend}(8\ \text{bits}) \rightarrow 32\ \text{bits}
$$

数组地址：

$$
\&a[i] = \text{base}(a) + i \times \text{sizeof(element)}
$$

对 `int` 数组：

$$
\&c[i] = \text{base}(c) + 4i
$$

这讲接到下一讲 instruction format 时，最关键的问题会变成：`lw` 的 `rd/rs1/imm` 和 `sw` 的 `rs2/rs1/imm` 分别编码在 instruction 的哪些 bit 里。
