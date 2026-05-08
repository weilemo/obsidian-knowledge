---
created: 2026-02-04
tags: [slurm, hpc, scheduler, cluster]
source: "personal"
---

# Slurm 作业监控指南

## 一句话摘要
从提交作业到排队/运行/结束，用 `squeue` + 日志跟随 + `scontrol` 实现“看状态—看输出—定位问题—必要时取消”的最小闭环。

## 原文结构（按标题层级）
- 提交任务（sbatch）
- 看任务状态（squeue）
- 实时看标准输出日志（less +F / tail -f）
- 实时看错误日志（less +F）
- 看任务详细信息（scontrol show job）
- 取消任务（scancel）

## 1) 提交任务
```bash
sbatch /path/to/your_job.sh
```
返回类似：
```text
Submitted batch job 12345
```
- 记住这个 `JobID=12345`，后面所有操作都用它。

看你当前所有 Slurm 任务，用这条：

squeue -u moweile-20251213 -o "%.18i %.9P %.30j %.8u %.2t %.10M %.10l %.6D %R"

持续监控（每5秒刷新）：

`watch -n 5 'squeue -u moweile-20251213 -o "%.18i %.9P %.30j %.8u %.2t %.10M %.10l %.6D %R"'`

## 2) 看任务是否在排队或运行
```bash
squeue -j 12345
```
你会看到类似状态列（不同集群显示列可能不同）：
- `PD`：排队（Pending）
- `R`：运行（Running）
- 没有输出：作业已结束（或 JobID 不存在/被清理）

常见排队原因（会出现在 `NODELIST(REASON)` 或 `Reason`）：
- `Resources`：资源不足
- `Priority`：优先级不够

## 3) 实时看日志输出（标准输出）
`less +F` 类似 `tail -f`，适合长日志并可随时暂停浏览：
```bash
less +F /path/to/logs/your_job_12345.out
```
操作：
- `Ctrl+C`：暂停跟随（进入可滚动查看模式）
- `Shift+F`：继续跟随

如果你只想持续刷最后几行：
```bash
tail -f /path/to/logs/your_job_12345.out
```

## 4) 看错误日志（有报错时）
```bash
less +F /path/to/logs/your_job_12345.err
```

## 5) 看任务详细信息
```bash
scontrol show job 12345
```
建议优先扫这些字段（不同集群配置可能略有差异）：
- `JobState`：最终状态判断
- `Reason`：排队原因
- `RunTime` / `TimeLimit`：已运行时间/时间上限
- `NodeList`：分配到的节点
- `NumNodes` / `NumCPUs` / `TRES`：资源分配概览
- `StdOut` / `StdErr`：日志路径（若集群配置会回填）

## 6) 取消任务（如果需要）
```bash
scancel 12345
```

## 小贴士（让监控更省心）
- 建议在脚本里固定 stdout/stderr 路径：
```bash
#SBATCH -o /path/to/logs/%x_%j.out
#SBATCH -e /path/to/logs/%x_%j.err
```
说明：
- `%j` 是 JobID，`%x` 常用作 job name（不同集群可能略有差异，以本集群文档为准）。
- 如果 `squeue` 没输出但你怀疑失败：尝试 `sacct -j 12345`（前提是集群启用了 accounting），查看退出码与最终状态。

## 相关链接（双向）
- [[Slurm]]
