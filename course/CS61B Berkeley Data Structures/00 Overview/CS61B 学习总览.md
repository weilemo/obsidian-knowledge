# CS61B 学习总览

## 课程定位

CS61B: Data Structures 是 UC Berkeley 的数据结构与软件工程入门课。它接在 CS61A 之后，使用 Java 把抽象数据类型、测试、复杂度分析和大型项目串起来；也为 CS61C 之前的系统课补上“会写可靠程序、会实现核心数据结构”的地基。

一句话：CS61A 让你会想，CS61B 让你会写可维护的程序，CS61C 让你知道程序如何落到机器上。

## 为什么暑假学它

1. 补 Java 和面向对象：class、interface、inheritance、generics、exceptions。
2. 补数据结构基本功：list、deque、tree、hash table、heap、graph、trie。
3. 补工程习惯：unit testing、debugging、style、版本管理、项目拆解。
4. 为后续算法、系统、coding agent 工具链打底：能读懂并改动中型代码库。

## 推荐主线

公开自学建议以 `Spring 2021` 为主线，因为它保留了较完整的公开网站、skeleton、autograder 和项目说明；同时把 `Spring 2026` / 当前 `cs61b.org` 当作新讲义、lecture code 和课程更新的参考。

| 资源 | 用途 |
|---|---|
| <https://sp21.datastructur.es/> | 主线课程页面 |
| <https://github.com/Berkeley-CS61B/skeleton-sp21> | Spring 2021 作业 / 实验 skeleton |
| <https://github.com/Berkeley-CS61B/library-sp21> | Spring 2021 支撑库 |
| <https://cs61b.org/> | 当前课程入口 |
| <https://github.com/Berkeley-CS61B> | Berkeley CS61B GitHub 组织 |

## 暑假 8 周学习路径

| 周次 | 主线 | 核心内容 | 产出 |
|---|---|---|---|
| Week 0 | 环境准备 | Java、IntelliJ、Git、JUnit、课程 repo | 环境记录 + 第一个测试跑通 |
| Week 1 | Java 与 OOP | class、static、reference、inheritance、interface | Java 速查 + Lab 1/2 |
| Week 2 | Lists / Deques | linked list、array list、generic、iterator | Project 0 / Project 1 启动 |
| Week 3 | Testing / Debugging | JUnit、randomized testing、debugger、style | Project 1 完成复盘 |
| Week 4 | Trees / BST / B-Trees | recursion、tree invariant、balanced tree | Tree 模块笔记 |
| Week 5 | Hashing / Heaps / Priority Queue | hash table、heap、PQ、amortized analysis | Hash + Heap 实现笔记 |
| Week 6 | Graphs / Algorithms | graph traversal、shortest path、MST、topological sort | Graph 算法速查 |
| Week 7 | 大项目与考试复盘 | Gitlet / BYOW 选做、past exams、薄弱点回炉 | Final Review Packet |

## 学习节奏

每周至少做四件事：

1. 看 lecture / guide：只看懂主概念，不被细节卡死。
2. 写一页 Obsidian 笔记：把 invariant、API、复杂度表整理出来。
3. 做 lab / project：CS61B 的核心在项目，不在看课。
4. 复盘一次 bug：记录 bug 现象、原因、修复方式和以后如何提前发现。

## 与现有课程的关系

| 已有课程 | CS61B 能补什么 |
|---|---|
| `CS61A` | 从 Python / Scheme 的抽象思维过渡到 Java 工程实现 |
| `CS61C Berkeley Computer Architecture` | 在进入 C、RISC-V 和机器层之前补齐软件结构能力 |
| `25-26-2/ICE3402P Data Structure 数据结构` | 可作为英文公开课主线和项目实践补充 |
| `Coding Agent / Agent Memory` 研究方向 | 帮助理解中型 repo、测试反馈、API 设计和代码修改闭环 |

## 文件夹结构

| 路径 | 用途 |
|---|---|
| `00 Overview` | 总览、暑假路线、启动清单 |
| `01 Syllabus` | 课程政策、主题清单、公开版本对照 |
| `02 Units` | 按知识模块整理的概念笔记 |
| `03 Lecture Notes` | 逐讲笔记 |
| `04 Labs` | Lab 说明、实现记录、debug 复盘 |
| `05 Projects` | Project 0/1/2/3 记录与复盘 |
| `06 Discussions` | Discussion / worksheet 练习 |
| `07 Exams` | Past exams、错题、期末速查 |
| `08 Code` | 本地代码、repo 链接、环境说明 |
| `99 Resources` | 官方链接、下载记录、资料索引 |

