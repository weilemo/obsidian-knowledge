---
created: 2026-04-28
type: note
status: active
tags: [math, llm, month1, linear-algebra]
summary: "Month 1 的第一个任务块：建立线性代数最底层的符号系统。"
---

# 任务块 A：线性代数符号系统

## 目标
完成这个任务块时，希望你能做到：
- 区分标量、向量、矩阵
- 看懂矩阵乘法为什么能做
- 看懂线性方程组和矩阵形式的关系
- 不再把“矩阵乘法”只当成机械运算

## 两种推进方式
### 方式 1：7 天推进
适合最近节奏比较稳定的时候。

入口：
- [[第一周起步计划|第一周起步计划]]
- [[任务块A-关键概念笔记|任务块 A：关键概念笔记]]

### 方式 2：10-14 天推进
适合“以前学过一点，但不牢”的情况。

拆成 4 个子块：
1. 标量、向量、矩阵、维度
2. 矩阵乘法、线性方程组
3. 内积、范数
4. 投影 + 和 ML 公式连接

每个子块花 `2 - 3` 天：
- 第一天学概念
- 第二天手算和写小结
- 如果还不稳，第三天只复习和回忆

## 学习资源
### 主线资源
- MIT 18.06 Linear Algebra  
  [MIT OCW 18.06SC](https://ocw.mit.edu/courses/18-06sc-linear-algebra-fall-2011/)

### 直觉补充
- 3Blue1Brown 的线性代数主题页  
  [3Blue1Brown Linear Algebra](https://www.3blue1brown.com/topics/linear-algebra)

### 面向 ML 的过桥材料
- Stanford CS229 线性代数复习  
  [CS229 Linear Algebra Review](https://cs229.stanford.edu/notes2022fall/cs229-linear_algebra_review.pdf)

## 最低完成标准
如果你能做到下面这四件事，就说明这个任务块可以结束：
- 看公式时能先识别对象类型
- 不会再害怕矩阵乘法
- 能把一个线性方程组写成矩阵形式
- 能说出内积和范数在 ML 里的一个作用

## 自测题
不查资料，试着回答：
- 为什么 $A \in \mathbb R^{m \times n}$、$x \in \mathbb R^n$ 时，$Ax \in \mathbb R^m$？
- 为什么矩阵乘法可以看成线性变换？
- 内积为什么能表示相似度？
- 范数和“参数大小”之间是什么关系？

如果有 2 个以上答不顺，说明还不该急着进入任务块 B，先补一次复习。
