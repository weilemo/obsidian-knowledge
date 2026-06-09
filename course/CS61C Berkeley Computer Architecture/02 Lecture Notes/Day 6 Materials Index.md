# Day 6 Materials Index

## 本地课件

按这个顺序看：

1. [[Slides/L22 RISC-V Single-Cycle Datapath II.pdf]]
2. [[Slides/L23 Control Logic Instruction Timing.pdf]]

配套讲义：

1. [[L22-L23 Datapath II Control Timing 讲义✅]]

## 本地官方 Notes

### L22 Datapath II

1. [[Notes/L22 Supporting Loads and Stores - official notes.html]]
2. [[Notes/L22 Supporting Branches - official notes.html]]
3. [[Notes/L22 Supporting Jumps - official notes.html]]
4. [[Notes/L22 Supporting U-Type - official notes.html]]

### L23 Control and Timing

1. [[Notes/L23 Control Logic Design - official notes.html]]
2. [[Notes/L23 Instruction Timing - official notes.html]]
3. [[Notes/L23 Datapath Summary - official notes.html]]

## 练习材料

1. [[Practice/Discussion 08 Datapath.pdf]]
2. [[Practice/Discussion 08 Datapath Solutions.pdf]]
3. [[Labs/Lab 6 CPU Pipelining.html]]

Lab 6 的 Exercise 1/2 对项目很有用：immediate construction 和 `BrUn` control signal。

## 今日阅读顺序

### Step 1: Load / Store Datapath

重点看：

```text
load address = R[rs1] + offset
store address = R[rs1] + offset
load writes rd
store writes memory, not rd
byte/half/word write mask
```

### Step 2: Branch / Jump Datapath

重点看：

```text
branch comparator
BrEq / BrLt / BrUn
PCSel
branch target = PC + imm
jal writes PC + 4 and jumps
jalr uses rs1 + imm as target
```

### Step 3: Control Logic

重点看：

```text
opcode / funct3 / funct7
control signals
truth table
hardwired control
```

### Step 4: Instruction Timing

只抓直觉：

```text
critical path
single-cycle clock period must fit the slowest instruction
```

## 今日最小闭环

看完后，至少能解释：

1. `lw` 为什么写回来自 memory，而不是 ALU。
2. `sw` 为什么不写 `rd`，但要写 memory。
3. branch 为什么需要 comparator 和 `PCSel`。
4. control logic 如何从 instruction field 产生 datapath 控制信号。
