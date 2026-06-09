# Day 2 Materials Index

## 本地课件

按这个顺序看：

1. [[Slides/L10 RISC-V Data Transfer.pdf]]
2. [[Slides/L13 RISC-V Instruction Formats I.pdf]]
3. [[Slides/L14 RISC-V Instruction Formats II.pdf]]

## 本地讲义

1. [[L10 RISC-V Data Transfer 讲义✅]]
2. [[L13 RISC-V Instruction Formats I 讲义✅]]
3. [[L14 RISC-V Instruction Formats II 讲义✅]]

## 本地官方 Notes

Slides 用来建立直觉，Notes 用来查字段和细节。

1. [[Notes/L10 RISC-V Data Transfer - official notes.html]]
2. [[Notes/L13 RISC-V Instruction Formats I - official notes.html]]
3. [[Notes/L14 RISC-V Instruction Formats II - official notes.html]]
4. [[Notes/RV32I Green Card.html]]

## 练习材料

今天如果看完还有力气，做这一份就够：

1. [[Practice/Discussion 06 Instruction Translation CALL.pdf]]
2. [[Practice/Discussion 06 Instruction Translation CALL Solutions.pdf]]

其中和今天最相关的是 instruction translation，不必深挖 CALL / calling convention。

## 今日阅读顺序

### Step 1: L10 Data Transfer

只抓这些：

```text
load from memory
store to memory
offset(base)
byte / halfword / word
```

对应项目：

```text
ALU 计算地址
WRITE_ADDRESS = R[rs1] + offset
load 通过 READ_DATA 写回 rd
store 通过 WRITE_DATA / WRITE_ENABLE 写内存
```

### Step 2: L13 Instruction Formats I

重点看：

```text
R-type
I-type
S-type
opcode
rd / rs1 / rs2
funct3 / funct7
immediate
```

对应项目：

```text
Splitter 拆 instruction
RegFile 读 rs1 / rs2
ImmGen 处理 I/S immediate
control_logic 根据 opcode/funct3/funct7 决定控制信号
```

### Step 3: L14 Instruction Formats II

重点看：

```text
B-type
U-type
J-type
PC-relative addressing
branch / jump immediate
```

对应项目：

```text
branch target = PC + branch immediate
jump target = PC + jump immediate
branch taken / jump 后要 kill 下一条错误取到的指令
```

## 今日最小闭环

看完后，至少能解释这三件事：

1. 为什么 `lw` 和 `sw` 都需要 `rs1 + offset`。
2. 为什么 `sw` 没有 `rd`，但有 `rs2`。
3. 为什么 branch immediate 不能简单取 `inst[31:20]`。
