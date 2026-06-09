# Day 1 Materials Index

## 本地课件

按这个顺序看：

1. [[Slides/L01 Course Introduction.pdf]]
2. [[Slides/L02 Number Representation.pdf]]
3. [[Slides/L09 RISC-V Basics.pdf]]

## 本地讲义

1. [[L09 RISC-V Basics 讲义✅]]

## 本地官方 Notes

Slides 用来建立直觉，Notes 用来查细节。

1. [[Notes/L02 Number Representation - official notes.html]]
2. [[Notes/L09 RISC-V Intro - official notes.html]]
3. [[Notes/RV32I Green Card.html]]

## 今日重点

今天只抓和 CPU 项目直接相关的内容：

```text
bits / bytes / hex
two's complement
sign extension
RISC-V register
addi
rd / rs1 / rs2 / imm
```

尤其要把这条路径看懂：

```text
addi rd, rs1, imm
-> read R[rs1]
-> sign extend imm
-> ALU add
-> write R[rd]
-> PC + 4
```
