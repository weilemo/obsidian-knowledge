---
created: 2026-02-03
tags: [tool, hpc, scheduler, cluster]
source-url: "https://slurm.schedmd.com/quickstart.html"
---

# Slurm
## 一句话摘要
Slurm 是面向 Linux 集群的作业调度与资源管理系统，负责分配资源、启动/监控作业并仲裁资源争用。

## 原文结构（按标题层级）
- Quick Start User Guide
  - Overview
  - Architecture
  - Commands
  - Examples
  - Best Practices, Large Job Counts
  - MPI

## Overview（官方概览）
- Slurm 是开源、容错、高扩展的集群管理与作业调度系统，适用于大/小规模 Linux 集群。
- 作为 workload manager，核心职责：
  1) 为作业分配节点/处理器/内存等资源
  2) 提供作业启动、执行与监控框架
  3) 通过排队与优先级仲裁资源竞争

## Architecture（体系结构）
- 每个计算节点运行 `slurmd`，管理节点运行 `slurmctld`（可选双机容错）。
- 关键实体：
  - Node：计算资源
  - Partition：节点的逻辑分组（可视作队列）
  - Job：对资源的一次分配（allocation）
  - Job Step：同一作业内的任务集合
- 分区可设定作业大小/时间/用户等约束；作业按优先级被分配资源。作业获得资源后，可在 allocation 内启动一个或多个 job step。

## Commands（常用命令）
- 文档提示：Slurm 所有守护进程/命令/API 都有 man page；命令参数区分大小写；命令可在集群任意位置运行。
- 常用用户命令（节选）：
  - `sacct`：作业/作业步的计费与历史信息
  - `salloc`：实时申请资源并生成 shell
  - `sbatch`：提交批处理脚本
  - `sbcast`：把本地文件广播到作业节点的本地盘
  - `scancel`：取消作业或作业步
  - `scontrol`：查看/修改 Slurm 实体状态（需权限）
  - `sinfo`：查看分区与节点状态
  - `squeue`：查看排队/运行作业
  - `srun`：提交作业或在 allocation 内启动 job step

## Examples（用户视角）
### 0) sinfo / squeue：先看集群与队列
- `sinfo` 查看分区与节点状态（示例展示 debug 与 batch 分区、节点状态）。

示例：
```bash
sinfo
```

- `squeue` 查看作业队列；`NODELIST(REASON)` 显示运行位置或 pending 原因（常见为 Resources / Priority）。

示例：
```bash
squeue
```

### 0.5) scontrol：更详细状态
- `scontrol` 可查看更详细的分区/节点/作业信息，部分命令需要管理员权限。

示例：
```bash
scontrol show partition
scontrol show node <node>
scontrol show job <jobid>
```
### 1) srun：直接运行命令
- 在 3 个节点上运行 hostname，输出带序号：
```bash
srun -N3 -l /bin/hostname
```
- 在 4 个任务上运行 hostname：
```bash
srun -n4 -l /bin/hostname
```

### 2) sbatch：提交批处理脚本
示例脚本：
```bash
#!/bin/sh
#SBATCH --time=1
/bin/hostname
srun -l /bin/hostname
srun -l /bin/pwd
```

提交作业：
```bash
sbatch -n4 -w "adev[9-10]" -o my.stdout my.script
```
说明：
- `#SBATCH` 选项写在脚本顶部；命令行选项会覆盖脚本内的同名设置。

查看与取消：
```bash
squeue
scancel <JOBID>
```

### 3) salloc + sbcast：交互式资源 + 本地拷贝
```bash
salloc -N1024 bash
sbcast a.out /tmp/joe.a.out
srun /tmp/joe.a.out
srun rm /tmp/joe.a.out
exit
```
说明：
- Slurm 不会自动迁移可执行文件或数据文件；需要放在共享文件系统，或用 `sbcast` 分发到本地盘。

### 4) sbatch 文件结构（经典教程补充）
- `#!/bin/bash` 为 shebang
- `#SBATCH` 用于资源请求；以 `##` 开头的行被视为注释
- 脚本最后是具体执行命令（可包含模块加载/环境激活）

## Best Practices, Large Job Counts
- 相关工作尽量合并为单个作业，使用多个 job step，降低调度与管理开销。
- **Job Arrays** 适合大量同构任务；多数 Slurm 命令既可单元素管理，也可对整个数组操作。

## MPI
- MPI 使用依赖实现方式，官方列出三类模式：
  1) Slurm 直接启动任务，并通过 PMI2/PMIx 初始化通信（多数现代 MPI）。
  2) Slurm 分配资源，`mpirun` 通过 Slurm 基础设施启动（旧版 OpenMPI）。
  3) Slurm 分配资源，`mpirun` 用 SSH/RSH 启动（任务不受 Slurm 监控，需要额外清理与 adopt 机制）。

## 经典教程/参考
- 官方 Quick Start User Guide: https://slurm.schedmd.com/quickstart.html
- 官方文档总入口（含命令手册）: https://slurm.schedmd.com/documentation.html
- SchedMD GitHub 仓库: https://github.com/SchedMD/slurm
- University of Montana SLURM Tutorial（sbatch 脚本示例）: https://www.umt.edu/it/rci/getting-started/slurm/slurm-tutorial/
- MSU HPCC SLURM Commands（命令速查）: https://docs.icer.msu.edu/SLURM_commands/
 - MPI 实现说明（Intel MPI / MPICH2 / MVAPICH2 / Open MPI）：见 Quick Start 页面末尾链接

## 关键原文摘录
- “Slurm is an open source, fault-tolerant, and highly scalable cluster management and job scheduling system…”
  - 出处：https://slurm.schedmd.com/quickstart.html
- “As a cluster workload manager, Slurm has three key functions.”
  - 出处：https://slurm.schedmd.com/quickstart.html
- “The user commands include: sacct, sacctmgr, salloc, …, srun, sshare, sstat, strigger and sview.”
  - 出处：https://slurm.schedmd.com/quickstart.html
- “Job arrays are an efficient mechanism of managing a collection of batch jobs with identical resource requirements.”
  - 出处：https://slurm.schedmd.com/quickstart.html
