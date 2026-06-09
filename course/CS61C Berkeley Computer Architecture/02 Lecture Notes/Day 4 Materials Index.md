# Day 4 Materials Index

## 本地课件

今天主看这一份：

1. [[Slides/L19-L20 FSM Blocks ALU.pdf]]

配套讲义：

1. [[L19-L20 FSM Blocks ALU 讲义✅]]

这份课件覆盖 L19 的 FSM / blocks，也覆盖 L20 的 ALU: Adder/Subtractor。今天可以轻看 FSM，把精力放在 blocks、MUX、adder/subtractor、ALU。

## 本地官方 Notes

按这个顺序看：

1. [[Notes/L19-L20 Data Multiplexors - official notes.html]]
2. [[Notes/L20 Adder Subtractor - official notes.html]]
3. [[Notes/L20 Arithmetic Logic Unit - official notes.html]]
4. [[Notes/L19-L20 Blocks Summary - official notes.html]]

## 实操参考

1. [[Labs/Lab 5 Logisim.html]]
2. [[Labs/Project 3 CS61CPU.html]]
3. [[Practice/Discussion 07 Boolean Algebra SDS FSM.pdf]]
4. [[Practice/Discussion 07 Boolean Algebra SDS FSM Solutions.pdf]]

Lab 5 重点看 Logisim 的 subcircuit、register、splitter、tunnel、extender。Project 3 是你当前 CPU 项目的原型说明。

## 今日阅读顺序

### Step 1: MUX

重点看：

```text
2-to-1 MUX
4-to-1 MUX
select signal
wide MUX
```

对应项目：

```text
ALUSel 选择 ALU 最终输出
WBSel 选择写回来源
PCSel 选择 PC + 4 还是 branch/jump target
```

### Step 2: Adder/Subtractor

重点看：

```text
full adder
ripple-carry adder
two's complement subtraction
conditional inversion by XOR
SUB control bit
```

核心关系：

$$
A - B = A + \sim B + 1
$$

对应项目：

```text
ALU 的 add / sub
PC + 4
rs1 + immediate 计算地址
branch target = PC + immediate
```

### Step 3: ALU

重点看：

```text
parallel computation
ALU operation select
output MUX
add / sub / and / or / xor / shift / slt
```

对应项目：

```text
ALU 输入 A/B 同时送入多个运算模块
每个模块都算出结果
最后用 ALUSel 选择一个 Result
```

## 今日最小闭环

看完后，至少能解释：

1. 为什么 ALU 可以让所有运算并行算，再用 MUX 选输出。
2. 为什么减法可以复用加法器。
3. 为什么 `ALUSel` 本质上是 ALU 内部大 MUX 的选择信号。
4. 为什么当前项目 Part A 可以先只把 `addi` 的控制信号硬连成常量。
