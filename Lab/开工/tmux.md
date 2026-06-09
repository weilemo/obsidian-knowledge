回到刚才那个 Claude Code 的 tmux 窗口，用这个：

`ssh forcing_1 tmux attach -t cc`

或者在你 Mac 本机一条命令：

`cc-attach`

我们之前已经给你配了别名，所以也可以用短命令：

`cca`

如果提示已经 attached，也可以强制接管：

`tmux attach -d -t cc`

如果不确定窗口还在不在，先查：

`ssh forcing_1 'tmux ls'`

看到类似：

`cc: 1 windows ...`

就说明可以 attach 回去。