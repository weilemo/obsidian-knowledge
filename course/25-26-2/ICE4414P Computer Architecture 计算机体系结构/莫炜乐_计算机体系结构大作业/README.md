# CS61CPU - 计算机体系结构大作业

本目录是一套可运行的 CS61C RISC-V Logisim CPU project 工程，保留了作业说明 `Project.pdf`，并包含 CPU 电路、测试框架、Logisim/Venus 工具与自定义测试。

## 交付文件

- `cpu/alu.circ`: ALU，支持 add、and、or、xor、srl、sra、sll、slt、mul、mulhu、sub、bsel、mulh。
- `cpu/regfile.circ`: 32 个 RISC-V 寄存器的寄存器堆，包含调试输出端口。
- `cpu/cpu.circ`: 两级流水线 CPU 主数据通路。
- `cpu/imm_gen.circ`: I/S/B/U/J 类型立即数生成。
- `cpu/branch_comp.circ`: 有符号/无符号分支比较器。
- `cpu/control_logic.circ`: 指令译码与控制信号生成。
- `cpu/csr.circ`: `tohost = 0x51E` CSR 写入逻辑。
- `harnesses/`: 作业测试框架。
- `tests/`: Part A、Part B 以及自定义测试。
- `logisim-evolution.jar`、`venus-cs61c-fa20-proj3.jar`: 测试所需工具。

## 运行测试

在本目录执行：

```bash
python3 test_runner.py part_a alu
python3 test_runner.py part_a regfile
python3 test_runner.py part_a addi_pipelined
python3 test_runner.py part_b pipelined
python3 test_runner.py part_b custom
```

如果需要重新生成自定义测试电路，建议使用带完整 XML 支持的 Python：

```bash
/Users/moweile/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3 tests/part_b/custom/create-test.py tests/part_b/custom/inputs/*.s
```

## 当前验证结果

已在 2026-05-20 于本机运行：

- Part A ALU: 7/7 passed
- Part A RegFile: 4/4 passed
- Part A addi pipelined: 1/1 passed
- Part B pipelined: 8/8 passed
- Part B custom: 29/29 passed

## 来源备注

该工程整理自公开的 CS61C RISC-V CPU Logisim project 文件，并按本课程目录结构放入当前作业文件夹。提交前可以根据老师要求只上传 `cpu/` 中的电路文件，或上传整个工程压缩包。
