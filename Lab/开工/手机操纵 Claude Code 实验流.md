# 手机操纵 Claude Code 实验流

## 目标

用手机给本机 Codex 发指令，让 Mac 代发命令到实验室服务器上的 Claude Code。

实际链路：

```text
手机 Codex -> Mac 本机 Codex -> ssh forcing_1 -> 服务器 tmux cc -> Claude Code
```

当前服务器连接：

```bash
ssh forcing_1
```

当前 Claude Code 的 tmux 会话：

```bash
cc
```

## 本机已配置命令

脚本位置：

```bash
/Users/moweile/.local/bin/
```

`.zshrc` 中已配置：

```bash
export CC_HOST="${CC_HOST:-forcing_1}"
export CC_SESSION="${CC_SESSION:-cc}"
export CC_WORKDIR="${CC_WORKDIR:-/mnt/workspace/caipeiliang/code/moweile}"

alias ccs='cc-send'
alias ccr='cc-read'
alias cca='cc-attach'
alias ccc='cc-start'
alias ccy='cc-yes'
alias ccn='cc-no'
alias cce='cc-allow-edits'
```

## 最常用操作

查看 Claude Code 当前屏幕：

```bash
cc-read
```

或只看最近 40 行：

```bash
cc-read 40
```

发送一句话给 Claude Code：

```bash
cc-send "继续推进实验，先看当前日志和 GPU 状态"
```

进入同一个远程 tmux 会话手动操作：

```bash
cc-attach
```

如果会话不存在，启动一个新的 Claude Code 会话：

```bash
cc-start
```

## 手机上怎么说

可以直接对 Codex 说：

```text
看一下 cc 现在在干嘛
```

等价于：

```bash
cc-read
```

也可以说：

```text
发给 cc：继续跑 VBench，先检查 logs 里最新结果，如果报错就定位错误原因
```

等价于：

```bash
cc-send "继续跑 VBench，先检查 logs 里最新结果，如果报错就定位错误原因"
```

## Claude Code 卡 permission 时

先读屏：

```bash
cc-read 80
```

如果 Claude Code 显示：

```text
1. Yes
2. Yes, allow all edits during this session
3. No
```

只允许这一次：

```bash
cc-yes
```

拒绝：

```bash
cc-no
```

允许本 session 后续 edits：

```bash
cc-allow-edits
```

手机上可以说：

```text
给 cc 点 Yes
```

或：

```text
给 cc 选 2，允许这个 session 的编辑
```

注意：`cc-allow-edits` 权限更大，只在确定 Claude Code 正在做可信任务时使用。

## 当前状态检查

确认本机能连到服务器：

```bash
ssh forcing_1 'hostname && whoami'
```

确认 tmux 会话存在：

```bash
ssh forcing_1 'tmux ls'
```

确认能读 Claude Code 屏幕：

```bash
cc-read 20
```

## 常见问题

### `ssh forcing` 不通，但 Cursor 能连

不要用 `forcing`。Cursor 实际使用的是：

```bash
forcing_1
```

`forcing` 会裸连另一个目标，可能在 SSH 握手阶段直接断开。

### 手机发命令没有反应

先读屏：

```bash
cc-read 80
```

常见原因：

- Claude Code 正卡在 permission 选择。
- tmux 会话名不是 `cc`。
- 服务器重启后 tmux 会话没了。
- Claude Code 正在执行长任务，暂时没有新输出。

### 需要临时换服务器或会话名

可以临时覆盖环境变量：

```bash
CC_HOST=forcing_1 CC_SESSION=cc cc-read
```

或：

```bash
CC_HOST=forcing_1 CC_SESSION=cc cc-send "继续实验"
```

## 推荐手机工作流

1. 先说：`看一下 cc 现在在干嘛`
2. 根据输出决定下一步。
3. 如果在 permission，明确说：`给 cc 点 Yes` 或 `给 cc 选 No`
4. 如果在实验执行中，说：`发给 cc：检查最新日志，总结当前进展，然后继续下一步`
5. 每次关键操作后再读一次屏幕确认。

