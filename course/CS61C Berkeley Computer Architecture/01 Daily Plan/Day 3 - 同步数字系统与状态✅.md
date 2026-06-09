# Day 3 - 同步数字系统与状态

## 今天目标

前两天已经从软件侧走到了 RISC-V 指令：

```text
Day 1: bit / number representation / addi
Day 2: load-store / instruction formats / immediate
```

Day 3 开始进入硬件侧：**CPU 里的电路分成两类，一类负责“算”，一类负责“记”。**

学完今天内容后，要能回答：

1. 什么是 synchronous digital system？
2. 组合逻辑和状态元件有什么区别？
3. 为什么 ALU、ImmGen、control_logic 多数是组合逻辑？
4. 为什么 PC、RegFile、pipeline register 必须由 clock 控制？
5. 为什么项目文档反复说不要 gate clock？

## 今天要看的 CS61C 内容

本地资料入口：[[../02 Lecture Notes/Day 3 Materials Index]]

官方课程页：<https://cs61c.org/>

### 1. Lecture 16: Intro to SDS

重点看：

```text
synchronous digital system
digital signal
wire
bus
combinational logic
stateful circuit
clock
propagation delay
```

今天先抓一句话：

```text
CPU = 组合逻辑 + 状态元件 + 时钟协调
```

### 2. Lecture 17: Combinational Logic

重点看：

```text
truth table
Boolean algebra
logic gates
MUX
decoder
```

组合逻辑的本质是：

$$
\text{output}(t) = f(\text{input}(t))
$$

也就是说，它不记得过去，只根据当前输入产生当前输出。

项目里的典型组合逻辑：

| 模块 | 为什么是组合逻辑 |
|---|---|
| `ALU` | 输入 `A/B/ALUSel` 变了，结果随之变化 |
| `ImmGen` | 输入 instruction 和 `ImmSel`，输出 immediate |
| `Branch Comparator` | 输入 `rs1/rs2/BrUn`，输出 `BrEq/BrLt` |
| `control_logic` | 输入 opcode / funct3 / funct7，输出控制信号 |

### 3. Lecture 18: State

重点看：

```text
register
clock
rising edge
state update
setup / hold time 的直觉
```

状态元件的本质是：

$$
\text{state}_{next} = f(\text{state}_{current}, \text{input})
$$

但真正更新通常发生在时钟边沿：

```text
clock rising edge -> register captures input
```

项目里的典型状态元件：

| 模块 | 记住什么 |
|---|---|
| PC register | 当前取指地址 |
| RegFile | 32 个通用寄存器的值 |
| IF/EX pipeline register | 从 IF 传给 EX 的 instruction 和 PC |
| CSR tohost | 测试平台观察的输出状态 |

## 今天的核心图像

把 CPU 想成这样：

```text
state registers
      |
      v
combinational logic
      |
      v
next state
      |
      v
clock edge updates registers
```

对应到当前项目：

```text
PC / RegFile / IF-EX register
      |
      v
decode / ImmGen / control / ALU / branch compare
      |
      v
new PC / writeback data / memory signals
      |
      v
next clock edge commits changes
```

## 今天的练习

### 练习 1：给模块分类

判断下面模块是组合逻辑还是状态元件：

| 模块 | 组合逻辑 or 状态元件 | 原因 |
|---|---|---|
| ALU |  |  |
| ImmGen |  |  |
| PC register |  |  |
| RegFile |  |  |
| Branch Comparator |  |  |
| IF/EX pipeline register |  |  |
| control_logic |  |  |

参考答案：

| 模块 | 类型 | 原因 |
|---|---|---|
| ALU | 组合逻辑 | 不保存历史，只根据当前输入算结果 |
| ImmGen | 组合逻辑 | 根据当前 instruction 生成 immediate |
| PC register | 状态元件 | 保存当前 PC |
| RegFile | 状态元件 | 保存寄存器值，写入受 clock 控制 |
| Branch Comparator | 组合逻辑 | 根据当前两个寄存器值比较 |
| IF/EX pipeline register | 状态元件 | 保存跨周期的 instruction 和 PC |
| control_logic | 组合逻辑 | 根据当前指令字段生成控制信号 |

### 练习 2：解释不要 gate clock

项目文档说 RegFile 里不要把 clock 和 `RegWEn` 做 AND。

错误想法：

```text
clock_to_register = clock AND RegWEn
```

正确想法：

```text
clock 直接连寄存器
RegWEn 连写使能 / enable
```

用自己的话解释：为什么控制写入应该用 enable，而不是改 clock？

### 练习 3：把 `addi` 分成组合逻辑和状态更新

对这条指令：

```asm
addi t0, x0, 5
```

组合逻辑部分：

```text
decode instruction
read x0
sign extend imm = 5
ALU computes 0 + 5
prepare writeback data
prepare next PC = PC + 4
```

状态更新部分：

```text
on clock edge:
  t0 <- 5
  PC <- PC + 4
```

## 今天暂时不用深挖

今天可以先不深挖：

```text
transistor-level CMOS details
Karnaugh map
full FSM design
critical path precise timing calculation
```

这些对完整数字逻辑课有用，但当前 CPU 项目最需要的是：能区分组合逻辑和状态元件，并知道 clock 如何提交状态变化。

## 和当前 CPU 项目的连接

今天内容直接对应这些模块：

| Day 3 内容 | 项目模块 |
|---|---|
| combinational logic | `alu.circ`, `imm_gen.circ`, `branch_comp.circ`, `control_logic.circ` |
| MUX | ALU 输出选择、writeback 选择、PC 选择 |
| decoder / enable | RegFile 写寄存器选择 |
| register / clock | PC、RegFile、IF/EX pipeline register |
| no gated clock | RegFile 和 CPU 时钟连接规则 |

尤其要记住：

```text
组合逻辑负责“算出下一步该是什么”。
状态元件负责“在时钟边沿把下一步变成事实”。
```

## 今天的输出

今天结束时，在下面追加自己的 4 个小总结：

```text
1. 我如何区分组合逻辑和状态元件？
2. 为什么 ALU 不需要 clock？
3. 为什么 RegFile 写入需要 clock？
4. 当前 CPU 项目里哪些地方最容易因为时钟理解错而出 bug？
```

