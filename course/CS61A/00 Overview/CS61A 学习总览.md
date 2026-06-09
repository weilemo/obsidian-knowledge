# CS61A 学习总览

## 课程定位

CS61A: Structure and Interpretation of Computer Programs 是 UC Berkeley 的编程抽象入门课。它不只是 Python 入门，而是用 Python、Scheme 和 SQL 训练三件事：

1. 如何把问题分解成函数、数据和抽象。
2. 如何理解递归、环境、求值规则和程序执行。
3. 如何从“写代码”过渡到“设计语言和解释器”。

一句话：CS61A 让你学会用抽象思考程序，CS61B 再把这种抽象落到 Java 和数据结构工程里。

## 为什么暑假学它

1. 补编程基本功：函数、递归、对象、迭代、数据抽象。
2. 补计算思维：环境图、higher-order function、tree recursion。
3. 补语言直觉：Scheme、interpreter、macro 的入门视角。
4. 为后续 CS61B、CS61C、coding agent 研究打地基：更容易读懂程序状态和执行轨迹。

## 推荐主线

自学时优先使用当前 `cs61a.org` 公开页面和教材 `Composing Programs`。如果某一学期的作业链接不稳定，可以切换到历史归档学期，但核心顺序不变：

1. Python basics
2. Functions and environment diagrams
3. Recursion and tree recursion
4. Data abstraction
5. Object-oriented programming
6. Scheme
7. Interpreters
8. SQL

## 官方资源

| 资源 | 用途 |
|---|---|
| <https://cs61a.org/> | 当前课程入口 |
| <https://www.composingprograms.com/> | 主教材 |
| <https://cs61a.org/articles/about/> | 课程介绍与历史入口 |
| <https://github.com/Cal-CS-61A-Staff> | Berkeley CS61A staff GitHub |

## 暑假 6 周学习路径

| 周次 | 主线 | 核心内容 | 产出 |
|---|---|---|---|
| Week 0 | 环境准备 | Python、编辑器、OK / pytest、课程文件 | 环境记录 + 第一个 lab 跑通 |
| Week 1 | Python 与函数 | expression、function、environment diagram | `Python 与环境图.md` |
| Week 2 | Recursion | recursion、tree recursion、higher-order function | Hog 项目复盘 |
| Week 3 | Data Abstraction / OOP | abstraction barrier、class、inheritance | Cats / Ants 项目记录 |
| Week 4 | Scheme | Scheme syntax、recursion、lists、higher-order function | `Scheme 速查.md` |
| Week 5 | Interpreter / SQL / Review | eval/apply、interpreter、SQL basics | Scheme project 复盘 + final packet |

## 学习节奏

每周至少做四件事：

1. 看 lecture / textbook：先抓求值规则和抽象边界。
2. 写一页 Obsidian 笔记：尤其记录环境图、递归模板和抽象接口。
3. 做 lab / homework / project：CS61A 的项目很能训练“拆问题”。
4. 复盘一次卡点：写清楚是语法问题、递归问题、抽象设计问题还是测试问题。

## 与现有课程的关系

| 后续课程 | CS61A 能补什么 |
|---|---|
| `CS61B Berkeley Data Structures` | 从 Python 抽象过渡到 Java 数据结构实现 |
| `CS61C Berkeley Computer Architecture` | 先理解程序求值和状态，再进入机器层 |
| `CS285 Deep Reinforcement Learning` | 为递归、函数式抽象、状态转移和 agent 执行轨迹打底 |
| `Coding Agent / Agent Memory` 研究方向 | 帮助理解函数调用、环境、执行 trace 和解释器式 agent loop |

## 文件夹结构

| 路径 | 用途 |
|---|---|
| `00 Overview` | 总览、学习路线、启动清单 |
| `01 Syllabus` | 课程主题和版本选择 |
| `02 Units` | 按知识模块整理的概念笔记 |
| `03 Lecture Notes` | 逐讲笔记 |
| `04 Labs` | Lab 说明、实现记录、debug 复盘 |
| `05 Homework` | Homework 记录与错题 |
| `06 Projects` | Hog、Cats、Ants、Scheme 等项目 |
| `07 Discussions` | Discussion / worksheet 练习 |
| `08 Code` | 本地代码、repo 链接、环境说明 |
| `09 Exams` | Past exams、错题、复习包 |
| `99 Resources` | 官方链接、资料索引 |

