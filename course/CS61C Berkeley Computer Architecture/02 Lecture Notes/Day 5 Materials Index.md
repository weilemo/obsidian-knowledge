# Day 5 Materials Index

## 本地课件

今天主看：

1. [[Slides/L21 RISC-V Single-Cycle Datapath I.pdf]]

配套讲义：

1. [[L21 RISC-V Single-Cycle Datapath I 讲义✅]]

## 本地官方 Notes

按这个顺序看：

1. [[Notes/L21 Datapath Introduction - official notes.html]]
2. [[Notes/L21 State Elements on the Datapath - official notes.html]]
3. [[Notes/L21 R-Type Datapath ALU - official notes.html]]
4. [[Notes/L21 Supporting Immediates - official notes.html]]

## 练习材料

今天只做 Discussion 8 的前半部分即可，重点看 single-cycle CPU 和 control signal 表：

1. [[Practice/Discussion 08 Datapath.pdf]]
2. [[Practice/Discussion 08 Datapath Solutions.pdf]]

## 今日阅读顺序

### Step 1: Datapath vs Control

重点看：

```text
datapath
control
single-cycle processor
state elements
combinational logic
```

对应项目：

```text
cpu.circ 里大部分连线是 datapath
control_logic.circ 负责输出选择信号和写使能
```

### Step 2: Five steps

重点看：

```text
IF  = instruction fetch
ID  = instruction decode
EX  = execute
MEM = memory access
WB  = write back
```

对应项目 Part A：

```text
addi 不用 MEM
但仍然要经过 IF / ID / EX / WB
```

### Step 3: R-type datapath

重点看：

```text
instruction -> rs1 / rs2 / rd
RegFile read
ALU execute
RegFile writeback
```

### Step 4: Supporting immediates

重点看：

```text
I-type immediate
ImmGen
ALU B input MUX
addi datapath
```

这一步直接对应你的项目：

```text
addi rd, rs1, imm
-> R[rd] = R[rs1] + SignExt(imm)
```

## 今日最小闭环

看完后，至少能解释：

1. `datapath` 和 `control` 的区别。
2. `addi` 为什么需要 `ImmGen` 和 ALU B MUX。
3. `add` 和 `addi` 的数据通路差别只在 ALU B 来源。
4. 单周期 CPU 为什么一个周期内要完成 IF/ID/EX/MEM/WB。
