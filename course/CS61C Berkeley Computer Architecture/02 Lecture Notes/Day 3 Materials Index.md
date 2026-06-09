# Day 3 Materials Index

## 本地课件

按这个顺序看：

1. [[Slides/L16 Intro to SDS.pdf]]
2. [[Slides/L17 Combinational Logic.pdf]]
3. [[Slides/L18 State.pdf]]

## 本地讲义

1. [[L16 Intro to SDS 讲义✅]]
2. [[L17 Combinational Logic 讲义✅]]
3. [[L18 State 讲义✅]]

## 本地官方 Notes

Slides 用来建立直觉，Notes 用来查概念和细节。

1. [[Notes/L16 Intro to SDS - official notes.html]]
2. [[Notes/L17 Combinational Logic - official notes.html]]
3. [[Notes/L18 State - official notes.html]]

## 练习材料

今天如果看完还有力气，做这一份里和 Boolean Algebra / SDS 有关的题：

1. [[Practice/Discussion 07 Boolean Algebra SDS FSM.pdf]]
2. [[Practice/Discussion 07 Boolean Algebra SDS FSM Solutions.pdf]]

FSM 可以先轻看，当前 CPU 项目更急的是组合逻辑和寄存器。

## 今日阅读顺序

### Step 1: L16 Intro to SDS

只抓这些：

```text
synchronous digital system
wire / signal / bus
combinational logic
state element
clock
propagation delay
```

对应项目：

```text
Logisim 里的线就是 signal / bus
ALU / ImmGen / control_logic 大多是组合逻辑
PC / RegFile / pipeline register 是状态元件
```

### Step 2: L17 Combinational Logic

重点看：

```text
truth table
Boolean algebra
AND / OR / NOT / XOR
MUX
decoder
combinational circuit has no memory
```

对应项目：

```text
ALUSel 通过 MUX 选择 ALU 输出
RegFile 写入目标可以用 decoder / enable 控制
control_logic 用 opcode / funct3 / funct7 组合地产生控制信号
```

### Step 3: L18 State

重点看：

```text
register
clock
rising edge
setup time / hold time 只需知道概念
state update
```

对应项目：

```text
RegFile 在时钟上升沿写入
PC 在时钟上升沿更新
IF/EX pipeline register 在时钟上升沿保存 instruction 和 PC
不要 gate clock
```

## 今日最小闭环

看完后，至少能解释这四件事：

1. 为什么 ALU 是组合逻辑。
2. 为什么 RegFile 不是纯组合逻辑。
3. 为什么 `RegWEn` 应该控制写使能，而不是和 clock 做 AND。
4. 为什么流水线阶段之间必须放 register。
