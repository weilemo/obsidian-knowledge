# 机器重启后恢复 Claude Code 工作流

## 最短流程

```bash
ssh forcing_1

which tmux || conda install -c conda-forge tmux -y
which claude || export PATH="/mnt/workspace/caipeiliang/miniconda3/envs/claude-code/bin:$PATH"

source /root/.secrets/claude.env

tmux new -s cc
cd /mnt/workspace/caipeiliang/code/moweile
claude
```

## 如果已有 tmux 会话

```bash
tmux ls
tmux attach -t cc
```

如果提示已被占用：

```bash
tmux attach -d -t cc
```

退出但不关闭：

```text
Ctrl-b 然后 d
```

## 启动后第一句话

```text
机器刚重启，先不要直接跑实验。请先读取 STATUS.md、HANDOFF.md、MEMORY.md 和 git status，确认上次进展、未提交改动和下一步建议。不要删除结果文件，不要 push，先汇报状态。
```

## 常见问题

SSH 不通：

```bash
ssh -G forcing_1 | grep -E '^(hostname|user|port|identityfile|proxyjump|proxycommand) '
```

Claude Code `not login`：

```bash
env | grep -E 'ANTHROPIC|DEEPSEEK|CLAUDE'
source /root/.secrets/claude.env
```

`tmux` 没了：

```bash
conda install -c conda-forge tmux -y
```

`claude` 没了：

```bash
export PATH="/mnt/workspace/caipeiliang/miniconda3/envs/claude-code/bin:$PATH"
which claude
```

## Mac / 手机代发检查

Mac 上：

```bash
cc-read 40
cc-send "先读 STATUS.md、HANDOFF.md、MEMORY.md，恢复上下文"
```

手机上直接说：

```text
看一下 cc 现在在干嘛
```

