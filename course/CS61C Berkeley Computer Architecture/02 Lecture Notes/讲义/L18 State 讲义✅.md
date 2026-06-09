# L18 State 讲义

来源：[[../Slides/L18 State.pdf]]

配套官方 notes：[[../Notes/L18 State - official notes.html]]

## 0. 本讲目标

L16-L17 讲了 synchronous digital system 和 combinational logic。组合逻辑没有记忆：

$$
y = f(x)
$$

同样输入总是得到同样输出。但真正的 CPU 必须保存信息：

```text
PC 当前是多少？
寄存器 x1..x31 当前保存什么？
上一拍流水线寄存器里保存了哪条 instruction？
cache/memory 里保存什么？
```

这些都需要 state elements。

本讲要掌握：

1. clock signal 如何协调同步系统。
2. propagation delay 是什么。
3. register/flip-flop 如何保存状态。
4. setup time、hold time、clk-to-q delay 的含义。
5. critical path 如何决定最小时钟周期和最大频率。
6. hold-time violation 是另一类 timing constraint。
7. FSM 如何由 combinational logic + register 实现。

对 CPU 项目来说，这讲直接对应：

```text
PC
RegFile
pipeline registers
clock
write enable
critical path
```

## 1. SDS 复习

processor 底层几乎都是 synchronous digital system。

拆开来看：

```text
synchronous: all operations coordinated by a central clock
digital: values represented by discrete binary values
system: many components connected together
```

在 SDS 中，组合逻辑负责“算”，状态元件负责“记”。

```text
registers/state elements
-> combinational logic computes
-> next registers/state elements capture
```

clock 负责规定什么时候 capture/update state。

## 2. Clock

clock 是系统的 heartbeat。它是一个周期性变化的 signal，通常在 0 和 1 之间来回切换。

clock period 记为 $T$：

$$
T = \text{time for one clock cycle}
$$

clock frequency 记为 $f$：

$$
f = \frac{1}{T}
$$

例如：

$$
T = 1\ \text{ns} = 10^{-9}\ \text{s}
$$

则：

$$
f = \frac{1}{10^{-9}} = 10^9\ \text{Hz} = 1\ \text{GHz}
$$

在 CS61C 里，通常以 rising edge 到下一个 rising edge 作为一个 clock cycle。

## 3. Signal 和 Waveform

wire 上的 signal 随时间变化。用 waveform 可以画出一个 signal 在不同时间的值。

binary signal 通常这样解释：

```text
low voltage  -> 0
high voltage -> 1
```

clock waveform 是规则的 square wave：

```text
0 -> 1 -> 0 -> 1 -> ...
```

rising edge 是从 0 到 1 的边沿；falling edge 是从 1 到 0 的边沿。

在本课中，很多 state elements 默认是 rising-edge triggered：

```text
on rising edge: capture input
otherwise: hold old output
```

## 4. Propagation Delay

combinational logic 不会瞬间得到输出。输入变化以后，电荷需要经过 wires/transistors，最后输出才稳定。

这段时间叫 propagation delay：

```text
propagation delay = input changes -> output becomes valid 的时间
```

例如一个 4-bit adder：

```text
A[3:0], B[3:0] -> add -> C[3:0]
```

当 A 或 B 改变时，C 不会立刻稳定。它要等加法器内部逻辑传播完。

对 CPU 来说，ALU、ImmGen、control logic、branch comparator 都有 propagation delay。

## 5. State Elements

state elements 是能保存信息的电路。

例子：

```text
registers
caches
main memory
PC
pipeline registers
```

state elements 的作用不只是“存值”，还控制信息在 combinational logic blocks 之间有序流动。

典型同步系统结构：

```text
Register -> Combinational Logic -> Register
```

每个 clock cycle：

1. 前一个 register 的输出作为组合逻辑输入。
2. 组合逻辑经过 delay 后产生结果。
3. 下一个 clock edge 到来时，后一个 register 捕获结果。

这样系统就不会因为信号连续乱跑而失控。

## 6. Register

register 是一种保存信息一段时间的电路。

抽象接口：

```text
Input
LOAD / CLK
Output
```

行为：

```text
on trigger:
    sample input
    transfer sampled value to output
otherwise:
    ignore input, keep old output
```

如果是一个 32-bit register，它能保存 32 bits：

$$
\text{register width} = 32\ \text{bits}
$$

CPU 里的 PC 就可以看成一个保存当前 instruction address 的 register。

## 7. Clocked Register

clocked rising-edge triggered register 的 trigger 是：

```text
CLK goes from 0 to 1
```

也就是 rising edge。

在每个 clock cycle 的 rising edge：

```text
register loads input value
```

在其他时间：

```text
register output stays the same
```

课件中提到，block 上的 triangle symbol 通常表示 clocked state element。

这对 Logisim 很重要：看到带 clock triangle 的 register/flip-flop，就要意识到它不是普通组合逻辑，而是只在 clock edge 更新。

## 8. D Flip-Flop 和 n-bit Register

常规 register 内部由 flip-flops 组成。

D flip-flop 的接口：

```text
D: data input
Q: output
CLK: clock
```

一个 flip-flop 保存 1 bit，因此一个 n-bit register 可以看成 n 个 flip-flops 并排：

$$
n\text{-bit register} = n\ \text{1-bit flip-flops}
$$

例如 32-bit register：

$$
32\text{-bit register} = 32\ \text{flip-flops}
$$

每个 flip-flop 在同一个 clock edge 捕获自己那一位 input。

## 9. 同步系统的一般模型

同步系统可以抽象为：
![[Pasted image 20260526174410.png]]

```text
registers + combinational logic blocks
```

结构上：

```text
Register -> CL block -> Register -> CL block -> Register
```

也可以有：

```text
back-to-back registers
back-to-back CL blocks
feedback paths
```

但关键规则是：

```text
clock signal connects only to clock inputs of registers/state elements
```

不要把 clock 当作普通 data/control signal 到处 AND/OR。这也是 CPU 项目里常说的：

```text
不要 gate clock
```

如果需要控制是否写入，应该使用 write enable，而不是把 enable 和 clock 做 AND。

## 10. Register Timing 术语

physical register 不是理想瞬时元件。它有 timing constraints。

三个重要术语：

```text
setup time
hold time
clk-to-q delay
```

这些约束都围绕 rising edge 来定义。

## 11. Setup Time

setup time 指的是：在 rising edge 到来之前，input D 必须保持稳定多久。

记为 $t_{setup}$。

如果 D 在 clock edge 前太晚才稳定，flip-flop 可能捕获错误值或进入不稳定状态。

定义：

$$
t_{setup} = \text{time D must be stable before clock edge}
$$

直觉：

```text
clock edge 之前，输入要提前准备好
```

## 12. Hold Time

hold time 指的是：在 rising edge 之后，input D 还必须继续保持稳定多久。

记为 $t_{hold}$。

定义：

$$
t_{hold} = \text{time D must remain stable after clock edge}
$$

直觉：

```text
clock edge 刚过，输入不能立刻乱变
```

否则 flip-flop 可能还没完成采样，输入就已经变了。

## 13. CLK-to-Q Delay

clk-to-q delay 指的是：clock rising edge 到来后，output Q 需要多久才改变并稳定。

记为 $t_{clk\to q}$。

定义：

$$
t_{clk\to q} = \text{time from clock edge to valid Q output}
$$

直觉：

```text
register 收到 clock edge 后，不是立刻把新值出现在 Q 上
```

它需要一段物理延迟。

## 14. Input 必须在 setup + hold 窗口内稳定

对 rising-edge triggered flip-flop 来说，D input 必须在 clock edge 附近保持稳定：

```text
before edge: setup time
after edge: hold time
```

可以想成 clock edge 附近有一个禁止乱动的窗口：

```text
[edge - setup, edge + hold]
```

如果 D 在这个窗口里变化，就可能违反 timing constraint。

这就是为什么同步电路不能随便提高 clock frequency：组合逻辑必须有足够时间把稳定结果送到下一个 register。

## 15. 高带宽电路和 Clock Frequency

我们希望电路 high-bandwidth，也就是每秒产生更多有效输出。

提高 clock frequency 等价于缩短 clock period：

$$
f = \frac{1}{T}
$$

但如果 clock 太快，组合逻辑还没算完，下一个 register 就采样了错误/不稳定的值。

所以目标是找：

```text
minimum safe clock period
maximum safe clock frequency
```

## 16. Critical Path

critical path 是从一个 state element 输出，经组合逻辑，到下一个 state element 输入的最慢路径。

换句话说：

```text
critical path = path with maximum delay
```

最小时钟周期由 critical path 决定：

$$
T_{min} = t_{clk\to q} + t_{CL,max} + t_{setup}
$$

其中：

```text
t_clk->q: source register clock edge 后 Q 有效的时间
t_CL,max: combinational logic worst-case propagation delay
t_setup: destination register 所需 setup time
```

如果：

$$
T < T_{min}
$$

电路可能不能正确工作。

最大频率：

$$
f_{max} = \frac{1}{T_{min}}
$$

## 17. 为什么 minimum clock period 不包含 hold time

常见误区：把 hold time 也加进 minimum clock period。

但 setup constraint 对应的是“这一拍的数据能不能在下一拍前到达”，所以：

$$
T_{min} = t_{clk\to q} + t_{CL,max} + t_{setup}
$$

hold time 是另一条独立约束，检查的是“新数据会不会太快到达，破坏同一个 edge 附近的采样”。

所以：

```text
setup constraint -> clock period too short 的问题
hold constraint  -> data path too fast 的问题
```

## 18. 最大频率练习

课件练习给定：

```text
clk-to-q delay = 1 ns
setup time     = 1 ns
hold time      = 1 ns
AND delay      = 1 ns
```

要找 maximum clock frequency。

关键是先找 critical path。图中最长路径经过 3 个 AND gates。

所以：

$$
t_{CL,max} = 3\ \text{ns}
$$

最小时钟周期：

$$
T_{min} = t_{clk\to q} + t_{CL,max} + t_{setup}
$$

代入：

$$
T_{min} = 1\ \text{ns} + 3\ \text{ns} + 1\ \text{ns} = 5\ \text{ns}
$$

最大频率：

$$
f_{max} = \frac{1}{5\ \text{ns}}
$$

因为：

$$
1\ \text{ns}^{-1} = 1\ \text{GHz}
$$

所以：

$$
f_{max} = 0.2\ \text{GHz} = 200\ \text{MHz}
$$

答案是：

```text
200 MHz
```

## 19. Hold-Time Violation

除了 setup constraint，还有 hold constraint。

hold constraint 要求新数据不能太快到达 destination register 的 input，否则它可能在同一个 clock edge 的 hold window 内改变。

约束是：

$$
t_{clk\to q} + t_{CL,min} \ge t_{hold}
$$

其中 $t_{CL,min}$ 是 best-case combinational delay，也就是最快路径延迟。

如果：

$$
t_{clk\to q} + t_{CL,min} < t_{hold}
$$

就会发生 hold-time violation。

解决思路通常是给太快的路径增加延迟：

```text
add delay so that data does not arrive too early
```

这听起来反直觉，但 timing design 不只是“越快越好”。有时太快也会破坏正确性。

## 20. Timing Constraints 总结

setup 相关：

$$
T \ge t_{clk\to q} + t_{CL,max} + t_{setup}
$$

因此：

$$
T_{min} = t_{clk\to q} + t_{CL,max} + t_{setup}
$$

$$
f_{max} = \frac{1}{T_{min}}
$$

hold 相关：

$$
t_{clk\to q} + t_{CL,min} \ge t_{hold}
$$

一句话：

```text
critical path determines how slow the clock period must be;
hold constraint checks whether fastest path is too fast.
```

## 21. Finite State Machine

finite state machine，简称 FSM，是一种用有限状态描述行为的模型。

它有：

```text
present state
input
next state
output
```

状态转移通常由 clock 控制：

```text
on each clock cycle:
    read input and present state
    compute next state and output
    update state
```

任何 FSM 都可以用：

```text
combinational logic + registers
```

实现。

## 22. FSM 例子：检测连续三个 1

课件例子是检测输入中是否出现 3 consecutive 1s。

状态可以表示“目前连续看到几个 1”：

```text
state 00: 已连续看到 0 个 1
state 01: 已连续看到 1 个 1
state 10: 已连续看到 2 个 1
```

当在 state `10` 时再看到 input `1`，就检测到三个连续 1，output 为 1，并根据设计转到下一状态。

课件给的 transition table：

```text
PS input | NS output
00   0   | 00   0
00   1   | 01   0
01   0   | 00   0
01   1   | 10   0
10   0   | 00   0
10   1   | 00   1
```

每一行就是一个 edge/transition。

## 23. FSM 的硬件实现

FSM 硬件由两部分组成。

第一部分是 register，用来保存 present state：

```text
state register stores PS
```

每个 state 用一个 unique bit pattern 表示。例如：

```text
00, 01, 10
```

第二部分是 combinational logic：

```text
(PS, input) -> (NS, output)
```

完整结构：

```text
state register output PS
        + external input
        -> combinational logic
        -> NS and output
NS -> state register input
clock edge updates PS = NS
```

这就是同步系统的标准模式：

```text
state -> combinational logic -> next state
```

## 24. 和 CPU 项目的对应关系

### PC

PC 是 state element。它保存当前 instruction address。

每个 clock edge：

```text
PC <- next_PC
```

其中 `next_PC` 由组合逻辑计算：

```text
PC + 4
branch target
jump target
```

### RegFile

RegFile 保存 32 个 architectural registers。

读端口通常可以看成组合输出：

```text
rs1/rs2 address -> read data
```

写入通常发生在 clock edge，并受 `RegWEn` 控制：

```text
if RegWEn:
    R[rd] <- write_data
```

不要用 `RegWEn AND clock` 生成新 clock。正确思路是：

```text
clock 接 register clock input
RegWEn 接 write enable
```

### Pipeline Register

流水线阶段之间必须放 register，因为每一阶段的组合逻辑输出要在 clock edge 被固定下来，传给下一阶段。

例如：

```text
IF stage -> IF/ID register -> ID stage
ID stage -> ID/EX register -> EX stage
```

如果没有 pipeline register，信号会在多个 stage 的组合逻辑中连续传播，无法形成清晰的 cycle-by-cycle 执行。

### Critical Path

CPU 的 maximum clock frequency 由最长 combinational path 决定。

单周期 CPU 的 critical path 通常很长：

```text
PC -> instruction memory -> decode/register file -> ALU -> data memory -> writeback
```

流水线的动机之一就是把长组合路径切成多段，中间插入 registers，从而缩短每一拍的 critical path。

## 25. 本讲最小闭环

本讲最小闭环：

```text
Combinational logic computes.
Registers store.
Clock tells registers when to update.
Timing constraints determine how fast clock can run.
FSM = registers + combinational logic.
```

必须记住的 timing 公式：

$$
T_{min} = t_{clk\to q} + t_{CL,max} + t_{setup}
$$

$$
f_{max} = \frac{1}{T_{min}}
$$

$$
t_{clk\to q} + t_{CL,min} \ge t_{hold}
$$

必须记住的硬件模式：

```text
Register -> Combinational Logic -> Register
```

对 CPU 项目，一句话总结：

```text
ALU/control/ImmGen 负责算，PC/RegFile/pipeline registers 负责记，clock 只负责让 state elements 在正确时刻更新。
```
