# Day 7 Materials Index

## 本地课件

按这个顺序看：

1. [[Slides/L24 Pipeline I 5-Stage Pipeline.pdf]]
2. [[Slides/L25 Pipeline II Hazards.pdf]]

配套讲义：

1. [[L24-L25 Pipeline Hazards 讲义✅]]

## 本地官方 Notes

### L24 Pipeline I

1. [[Notes/L24 Pipeline Performance Metrics - official notes.html]]
2. [[Notes/L24 Pipelining Laundry - official notes.html]]
3. [[Notes/L24 RISC-V 5-Stage Pipeline - official notes.html]]

### L25 Pipeline II

1. [[Notes/L25 Pipeline Hazards Intro - official notes.html]]
2. [[Notes/L25 Structural Hazards - official notes.html]]
3. [[Notes/L25 Data Hazards Forwarding - official notes.html]]
4. [[Notes/L25 Control Hazards - official notes.html]]
5. [[Notes/L25 Pipeline Hazards Summary - official notes.html]]

## 练习材料

1. [[Practice/Discussion 09 Pipelining Hazards.pdf]]
2. [[Practice/Discussion 09 Pipelining Hazards Solutions.pdf]]
3. [[Labs/Lab 6 CPU Pipelining.html]]

## 今日阅读顺序

### Step 1: Why Pipeline

重点看：

```text
latency
throughput
pipeline register
```

### Step 2: 5-stage Pipeline

重点看：

```text
IF
ID
EX
MEM
WB
pipeline registers
```

当前项目是两级流水线：

```text
Stage 1: IF
Stage 2: ID + EX + MEM + WB
```

所以不要被完整五级流水线吓到，先抓“阶段之间要保存 instruction/PC”。

### Step 3: Hazards

重点看：

```text
structural hazard
data hazard
control hazard
bubble / nop
flush / kill
```

### Step 4: Connect to Project Presentation

把项目汇报收束到三句话：

```text
datapath decides where data flows
control decides which path is active
pipeline lets different instructions overlap, but branch/jump may need killing wrong-path instruction
```

## 今日最小闭环

看完后，至少能解释：

1. pipeline 提升的是 throughput，不是单条指令 latency。
2. 为什么阶段之间要有 pipeline register。
3. 为什么 branch/jump 会带来 control hazard。
4. 当前项目为什么用 `nop = 0x00000013` kill 错误取到的指令。
