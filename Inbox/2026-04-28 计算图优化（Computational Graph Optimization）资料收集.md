---
created: 2026-04-28
type: inbox
status: open
tags: [inbox, ml-systems, compiler, computational-graph, optimization]
summary: "收集“计算图优化”这个概念的直觉解释、关键关键词、代表论文与课程入口，后续可继续扩成系统综述。"
---

# 计算图优化（Computational Graph Optimization）资料收集

## 起因
想先收集一下“优化计算图 / computational graph optimization”这个概念到底在说什么，以及有哪些值得顺着读的论文和课程。

## 这个概念在说什么
这里的“计算图优化”通常不是指图论里的最短路/最大流，也不是单纯指数值优化里的梯度下降。

它更常见的含义是：
- 把模型的计算过程表示成一张图
- 在不改变语义的前提下，对这张图做等价变换
- 目标通常是让运行更快、占用更少内存、更适合某种硬件，或者更便于继续下游编译

一个比较实用的理解是：
- 高层：对子图做重写，例如 fusion、constant folding、dead code elimination、layout rewrite、common subexpression elimination
- 中层：把图逐步 lowering 到更适合优化的 IR
- 低层：围绕 kernel、loop、memory layout、bufferization、schedule 做进一步优化

所以“计算图优化”有狭义和广义两层：
- 狭义：图级 rewrite / graph substitution
- 广义：从图表示一路到 tensor IR、schedule、codegen 的整条编译链优化

## 可以先抓住的关键词
- computation graph
- graph rewrite
- graph substitution
- operator fusion
- constant folding
- dead code elimination
- shape inference
- memory planning
- lowering
- tensor IR
- schedule search
- cost model

## 工程上为什么重要
- 同一个模型，图怎么改写，往往会直接影响延迟、吞吐和显存/内存占用。
- 很多框架表面上是在“跑模型”，底层其实是在“编译一张图”。
- 到了 LLM / 推理系统语境里，这个概念通常会继续延伸到 kernel fusion、layout 选择、图捕获、AOT/JIT 编译。

## 入门直觉资料
### 1. TensorFlow Grappler
- [TensorFlow graph optimization with Grappler](https://www.tensorflow.org/guide/graph_optimization)
- 适合先建立“图优化到底在优化什么”的直觉。
- 官方文档里强调：Grappler 会在 graph mode 下自动应用图优化，以改进执行性能。

### 2. OpenXLA / XLA
- [XLA: Optimizing Compiler for Machine Learning](https://openxla.org/xla/tf2xla)
- 适合理解“图优化”如何进一步走向 compiler pipeline。
- 官方介绍里把 XLA 描述成会把 TensorFlow graph 编译成面向当前模型的 computation kernels。

## 值得顺着读的论文
### 1. TVM: An Automated End-to-End Optimizing Compiler for Deep Learning
- 链接：
  [USENIX 页面](https://www.usenix.org/conference/osdi18/presentation/chen)
  /
  [arXiv](https://arxiv.org/abs/1802.04799)
- 为什么值得读：
  这是把“图级优化 + 算子级优化 + 自动调优 + 多硬件部署”连成一条线的代表性工作。
- 我会重点看：
  graph-level optimization、operator-level optimization、cost model、hardware portability

### 2. TASO: Optimizing Deep Learning Computation with Automatic Generation of Graph Substitutions
- 链接：
  [论文 PDF](https://www.cs.cmu.edu/~zhihaoj2/papers/sosp19.pdf)
- 为什么值得读：
  这是更贴近“狭义计算图优化”本身的一篇代表作，核心是自动生成 graph substitutions，而不是只靠人工手写规则。
- 我会重点看：
  graph substitution、equivalence、search space、formal verification

### 3. MLIR: A Compiler Infrastructure for the End of Moore's Law
- 链接：
  [arXiv](https://arxiv.org/abs/2002.11054)
- 为什么值得读：
  它不只是“一个图优化算法”，而是解释为什么现代 ML 编译需要多层 IR，以及不同抽象层上的优化该怎么组织。
- 我会重点看：
  multi-level IR、dialect、progressive lowering、不同层级上的 optimizer 设计

### 4. Learning to Optimize Tensor Programs
- 链接：
  [arXiv](https://arxiv.org/abs/1805.08166)
- 为什么值得读：
  这篇更偏图优化下游的 tensor program / schedule 优化，但能帮我看清楚“图优化之后，性能优化真正落到哪里”。
- 我会重点看：
  learned cost model、search over tensor programs、auto-tuning

## 课程 / 教程入口
### 1. MLC: Machine Learning Compilation
- 链接：
  [课程主页](https://mlc.ai/courses.html)
- 为什么值得学：
  这是目前最系统、最贴近“ML 编译全栈”的公开课程之一，课程介绍里明确说它是这个新领域的 first systematic treatment。
- 适合放在：
  已经知道一点深度学习系统，但想系统理解 graph -> IR -> optimization -> runtime 的时候

### 2. Deep Learning Systems
- 链接：
  [课程主页](https://dlsyscourse.org/)
- 为什么值得学：
  这门课不只讲编译，但它把 automatic differentiation、算子效率、GPU 实现、系统视角放在一起，对建立“计算图为何重要”很有帮助。
- 适合放在：
  想从 framework internals 角度理解 computation graph、autodiff 与性能问题的时候

### 3. MLIR Tutorials
- 链接：
  [MLIR Tutorials](https://mlir.llvm.org/docs/Tutorials/)
- 为什么值得学：
  适合真正动手；官方教程里直接提供了 graph rewrite、Toy tutorial、Transform dialect tutorial 等入口。
- 适合放在：
  想从“读概念”走到“自己写 pass / rewrite”时

## 一个推荐阅读顺序
1. 先看 Grappler 和 XLA 文档，建立“图优化”最朴素的工程直觉。
2. 再看 TVM，理解为什么图优化不能孤立看，而要和 operator optimization、runtime、hardware target 一起看。
3. 再读 TASO，专门盯住“graph substitution 自动化”这个核心问题。
4. 最后补 MLIR 和 MLC，把前面的图优化直觉放进更一般的编译基础设施里。

## 我现在的理解
- 如果只从深度学习框架用户视角看，计算图优化像是“框架自动把图改写得更快”。
- 如果从编译器视角看，它本质上是在做语义保持的程序变换，只不过程序表示恰好是 tensor computation graph。
- 如果继续往下钻，就会发现“图优化”往往只是入口，真正决定性能上限的还包括 lowering、schedule、memory layout、kernel codegen。

## 关键原文摘录
- TVM: “graph-level and operator-level optimizations”
  来源：[TVM (OSDI 2018)](https://www.usenix.org/conference/osdi18/presentation/chen)
- TASO: “graph substitutions”
  来源：[TASO (SOSP 2019)](https://www.cs.cmu.edu/~zhihaoj2/papers/sosp19.pdf)
- XLA: “compiles the TensorFlow graph into a sequence of computation kernels”
  来源：[OpenXLA XLA 文档](https://openxla.org/xla/tf2xla)

## 后续可以继续补的方向
- 补一张“Grappler / XLA / TVM / MLIR / TensorRT / ONNX Runtime”之间的关系图
- 单独整理 `operator fusion` 的常见模式
- 单独整理“图优化”和“tensor program optimization”之间的边界
- 结合 [[任务块B-关键概念笔记]] 里的“反向传播与计算图”部分，一起看前向图优化和反向图构造的关系
