# Part A 开工讲义

## 0. 今天要完成什么

Part A 的目标不是一下子做完整 CPU，而是先把最小闭环跑起来：

```text
ALU -> RegFile -> addi single-cycle CPU -> addi two-stage pipeline CPU
```

你应该先做到能清楚解释这条数据流：

```asm
addi t0, x0, 5
```

在硬件里对应：

```text
PC 取指 -> 拆 instruction -> 读 x0 -> 生成立即数 5 -> ALU 相加 -> 写回 t0 -> PC + 4
```

也就是：

$$
R[rd] = R[rs1] + \mathrm{SignExt}(imm)
$$

对 `addi t0, x0, 5` 来说：

$$
R[x5] = R[x0] + 5 = 0 + 5 = 5
$$

## 1. 不要先看现成电路

当前项目目录的 `README.md` 写过所有测试已经通过，所以 `cpu/*.circ` 大概率是完成版。

学习时先看这些：

```text
Project.pdf
00_project_notes/
tests/**/inputs/*.s
test_runner.py 的命令用法
```

暂时不要人工打开这些：

```text
tests/**/reference_output/
tests/**/student_output/ 中的历史输出
实现思路说明.md
../莫炜乐_计算机体系结构大作业.zip
```

## 2. Task 1: ALU

文件：

```text
cpu/alu.circ
```

输入输出：

| 信号 | 位宽 | 含义 |
|---|---:|---|
| `A` | 32 | 第一个操作数 |
| `B` | 32 | 第二个操作数 |
| `ALUSel` | 4 | 选择执行哪种运算 |
| `Result` | 32 | 运算结果 |

核心做法：

1. 每种运算都并行算出一个候选结果。
2. 用 MUX 根据 `ALUSel` 选择最终 `Result`。
3. 不移动输入输出 pin。

必须实现的常用选择：

| `ALUSel` | 运算 | 结果 |
|---:|---|---|
| `0` | `add` | $A + B$ |
| `1` | `and` | $A \mathbin{\&} B$ |
| `2` | `or` | $A \mathbin{|} B$ |
| `3` | `xor` | $A \oplus B$ |
| `4` | `srl` | 逻辑右移 |
| `5` | `sra` | 算术右移 |
| `6` | `sll` | 左移 |
| `7` | `slt` | 有符号小于则为 $1$ |
| `10` | `mul` | 乘法低 32 位 |
| `11` | `mulhu` | 无符号乘法高 32 位 |
| `12` | `sub` | $A - B$ |
| `13` | `bsel` | 直接输出 $B$ |
| `14` | `mulh` | 有符号乘法高 32 位 |

测试：

```bash
cd "/Users/moweile/Obsidian/Knowledge/Course/25-26-2/ICE4414P Computer Architecture 计算机体系结构/project"
python3 test_runner.py part_a alu
```

你汇报时可以这样说：

```text
ALU 是执行阶段的组合逻辑核心。它不保存状态，只根据 A、B 和 ALUSel 立即产生 Result。
```

## 3. Task 2: RegFile

文件：

```text
cpu/regfile.circ
```

RegFile 要做三件事：

1. 根据 `rs1` 和 `rs2` 同时读两个寄存器。
2. 在时钟上升沿，如果 `RegWEn = 1`，把 `Write Data` 写入 `rd`。
3. `x0` 永远保持 0。

最关键的约束：

$$
R[x0] = 0
$$

无论写入什么，`x0` 都不能变。并且不要对 clock 做门控，clock 应直接接到寄存器时钟端。

测试：

```bash
python3 test_runner.py part_a regfile
```

汇报表达：

```text
RegFile 是 CPU 的通用寄存器堆。它是状态元件，读是组合的，写发生在 clock edge。
```

## 4. Task 3A: addi 单周期 CPU

先不考虑流水线，只做单周期版本，目的是把取指、译码、执行、写回串起来。

需要的数据通路：

```text
PC
-> instruction memory
-> instruction bits
-> rs1 / rd / imm
-> RegFile read rs1
-> ImmGen sign-extend imm
-> ALU add
-> RegFile write rd
```

`addi` 是 I-type 指令：

| 字段 | 位段 |
|---|---|
| `imm` | `[31:20]` |
| `rs1` | `[19:15]` |
| `funct3` | `[14:12]` |
| `rd` | `[11:7]` |
| `opcode` | `[6:0]` |

立即数生成：

$$
imm_{32} = \mathrm{SignExt}(inst[31:20])
$$

ALU 输入：

$$
A = R[rs1]
$$

$$
B = imm_{32}
$$

写回：

$$
R[rd] = ALUResult
$$

PC 更新：

$$
PC_{next} = PC + 4
$$

测试：

```bash
python3 test_runner.py part_a addi_single
```

## 5. Task 3B: addi 两级流水线

项目最终要求 Part A 是两级流水线：

| 阶段 | 做什么 |
|---|---|
| IF | 根据 PC 取 instruction |
| EX | 译码、读寄存器、执行、访存、写回 |

中间需要一个 pipeline register 保存从 IF 传给 EX 的信息。至少要保存：

```text
instruction
PC
```

为什么要保存 `PC`：后面 Part B 的 branch、jump、auipc、jal 都需要“当前执行指令自己的 PC”，不能只看正在取指的新 PC。

流水线启动时，指令寄存器初始为 0，相当于：

```asm
addi x0, x0, 0
```

也就是 `nop`。

测试：

```bash
python3 test_runner.py part_a addi_pipelined
```

## 6. Part A 和课程章节的关系

| 项目任务 | 对应课程内容 |
|---|---|
| ALU | 组合逻辑、算术逻辑单元、RISC-V 运算指令 |
| RegFile | 状态元件、寄存器、时钟边沿 |
| addi 单周期 CPU | datapath、instruction format、control signal |
| addi 两级流水线 | pipeline register、IF/EX 分段、启动延迟 |

这个项目本质上是在把课堂里的 CPU 数据通路图变成一个能跑测试的 Logisim 电路。

## 7. 今日建议顺序

1. 读 `Project.pdf` 第 1 到 14 页。
2. 打开 `00 Logisim 是什么.md` 复习 Logisim 对象。
3. 在纸上画出 `addi` 数据通路。
4. 只跑测试命令确认环境，不人工看 `reference_output`。
5. 如果要开始动手，先从 ALU 的 `ALUSel` 表做起。

最小检查命令：

```bash
cd "/Users/moweile/Obsidian/Knowledge/Course/25-26-2/ICE4414P Computer Architecture 计算机体系结构/project"
python3 test_runner.py part_a alu
python3 test_runner.py part_a regfile
python3 test_runner.py part_a addi_pipelined
```
