# CS61CPU 项目前置工作入口

## 先读结论

你现在不要先打开 `cpu/*.circ`，也不要先看 `实现思路说明.md` 或 `参考答案_先不看/`。

正确入口是：

```text
00 Logisim 是什么 -> 01 项目前置工作 -> 02 参考答案先不看规则 -> 03 Part A 开工讲义
```

真正开工时，只盯住 Part A 的最小链路：

```text
ALU -> RegFile -> addi single-cycle CPU -> addi two-stage pipeline CPU
```

## 推荐阅读顺序

1. [[00 Logisim 是什么]]
2. [[01 项目前置工作]]
3. [[02 参考答案先不看规则]]
4. [[03 Part A 开工讲义]]
5. [[../Project.pdf]]

## 文件夹分区

| 区域 | 用途 | 当前策略 |
|---|---|---|
| `00_project_notes/` | 自己开工用的笔记 | 先看 |
| `Project.pdf` | 原始项目说明 | 配合讲义看 |
| `tests/**/inputs/*.s` | 测试程序输入 | 可以看，用来理解行为 |
| `test_runner.py` | 测试命令入口 | 会用即可 |
| `cpu/*.circ` | 最终电路文件 | 跟着讲义逐步打开/修改 |
| `tests/**/reference_output/` | 标准输出 | 先别看 |
| `tests/**/student_output/` | 历史输出 | 先别看 |
| `实现思路说明.md` | 完整实现解释 | 做完一轮后再对照 |
| `参考答案_先不看/` | 参考答案/对照工程 | 卡住或自查时再看 |

## 当前项目目录

```text
/Users/moweile/Obsidian/Knowledge/Course/25-26-2/ICE4414P Computer Architecture 计算机体系结构/project
```

## 打开 Logisim

```bash
cd "/Users/moweile/Obsidian/Knowledge/Course/25-26-2/ICE4414P Computer Architecture 计算机体系结构/project"
java -jar logisim-evolution.jar
```

## 跑测试

```bash
python3 test_runner.py part_a alu
python3 test_runner.py part_a regfile
python3 test_runner.py part_a addi_single
python3 test_runner.py part_a addi_pipelined
```

## 下一步

先按 [[03 Part A 开工讲义]] 做纸面推导和模块拆解。当前 `cpu/*.circ` 很可能已经是完成版，所以学习时不要直接打开现成实现照着看。

建议今天只做四件事：

1. 看懂 `addi t0, x0, 5` 的数据流。
2. 跑通 `python3 test_runner.py part_a alu`。
3. 跑通 `python3 test_runner.py part_a regfile`。
4. 再进入 `addi_single` 和 `addi_pipelined`。

## 暂时不要人工打开

```text
tests/**/reference_output/
tests/**/student_output/
实现思路说明.md
../莫炜乐_计算机体系结构大作业.zip
参考答案_先不看/
```
