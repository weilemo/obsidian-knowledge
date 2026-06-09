# Git Worktree 多分支隔离工作流

## 适用场景

当一个项目里同时推进多个互不相干的方向时，不要在同一个目录里反复 `git checkout`。这样很容易把未提交改动带到别的分支，或者让多个 agent 互相切走当前分支。

更稳的做法是：原仓库只做管理入口，每个真实开发分支都有自己的独立目录。

## videoquant 当前布局

服务器上的项目现在是：

```text
/mnt/workspace/caipeiliang/code/moweile/
  videoquant/          # 原目录，detached HEAD，只做 worktree 管理入口
  videoquant-main/     # main 分支
  videoquant-prompt/   # HWQ_prompt_router 分支
  videoquant-online/   # hwq_online_calibration 分支
  videoquant-hrq/      # feature/hwq-residual-quant 分支
```

对应关系：

```text
videoquant-main    -> main
videoquant-prompt  -> HWQ_prompt_router
videoquant-online  -> hwq_online_calibration
videoquant-hrq     -> feature/hwq-residual-quant
```

以后做 prompt router：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant-prompt
```

做 online calibration：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant-online
```

做 HRQ residual quant：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant-hrq
```

看 main：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant-main
```

## 基本命令

查看当前仓库有哪些 worktree：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant
git worktree list
```

查看分支和对应 worktree：

```bash
git branch -vv
```

新增一个分支的 worktree：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant
git worktree add ../videoquant-new-idea new-idea-branch
```

如果分支还不存在：

```bash
git worktree add -b new-idea-branch ../videoquant-new-idea main
```

删除某个 worktree：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant
git worktree remove ../videoquant-new-idea
```

清理失效记录：

```bash
git worktree prune
```

## 日常快捷管理

核心习惯：

```text
先选目录，再开工；一个方向，一个 worktree。
```

不要把“分支”只想成 `git branch` 里的名字，而要同时想成三件套：

```text
方向名 -> 分支名 -> worktree 目录
```

例如：

```text
prompt router      -> HWQ_prompt_router          -> videoquant-prompt/
online calibration -> hwq_online_calibration     -> videoquant-online/
residual quant     -> feature/hwq-residual-quant -> videoquant-hrq/
```

### 每天开工检查

先看所有 worktree：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant
git worktree list
```

再进入对应目录：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant-prompt
git status --short --branch
```

判断原则：

```text
在 videoquant-prompt 里，只应该看到 prompt router 相关改动。
在 videoquant-online 里，只应该看到 online calibration 相关改动。
在 videoquant-hrq 里，只应该看到 residual quant 相关改动。
实验结果、缓存、._* 不应该出现。
```

### 新想法：创建新 worktree

如果新方向还没有分支，从 `main` 开一个独立 worktree：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant
git worktree add -b feature/my-new-idea ../videoquant-my-new-idea main
```

如果分支已经存在，只是要补一个独立目录：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant
git worktree add ../videoquant-my-new-idea feature/my-new-idea
```

命名建议：

```text
分支名：feature/xxx、experiment/xxx、fix/xxx
目录名：videoquant-xxx
```

分支名可以带 `/`，但目录名尽量别带 `/`，否则路径会变复杂。

### 废弃旧方向：删除 worktree

先确认目录里没有要保留的改动：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant-my-new-idea
git status --short --branch
```

如果干净，删除 worktree：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant
git worktree remove ../videoquant-my-new-idea
git worktree prune
```

如果这个分支以后也不要了：

```bash
git branch -D feature/my-new-idea
```

注意：

```text
git worktree remove 只是删除那个工作目录。
git branch -D 才是删除分支指针。
```

如果只是暂时不做，建议只删 worktree，不删分支。以后可以重新：

```bash
git worktree add ../videoquant-my-new-idea feature/my-new-idea
```

### 成熟方向：合并回 main

在功能 worktree 里先收干净：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant-prompt
git status --short --branch
git add <changed-files>
git commit -m "Add prompt router policy variants"
```

然后切到 main 的独立目录合并：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant-main
git status --short --branch
git merge --no-ff HWQ_prompt_router
```

合并后检查：

```bash
git status --short --branch
git log --oneline --decorate -5
```

如果要推到 GitHub：

```bash
git push origin main
```

如果功能分支也要保留远端备份：

```bash
cd /mnt/workspace/caipeiliang/code/moweile/videoquant-prompt
git push -u origin HWQ_prompt_router
```

## 推荐快捷函数

可以把下面这一段放到服务器的 `~/.bashrc` 或 `~/.zshrc`。它不会改变 git 行为，只是减少重复输入。

```bash
export VQ_ROOT=/mnt/workspace/caipeiliang/code/moweile
export VQ_MGR=$VQ_ROOT/videoquant

alias vq-mgr='cd $VQ_MGR'
alias vq-main='cd $VQ_ROOT/videoquant-main'
alias vq-prompt='cd $VQ_ROOT/videoquant-prompt'
alias vq-online='cd $VQ_ROOT/videoquant-online'
alias vq-hrq='cd $VQ_ROOT/videoquant-hrq'

vq-list() {
  cd "$VQ_MGR" &&
  git worktree list &&
  git branch -vv
}

vq-new() {
  branch="$1"
  dir="$2"
  base="${3:-main}"

  if [ -z "$branch" ] || [ -z "$dir" ]; then
    echo "usage: vq-new <branch> <dir-name> [base]"
    echo "example: vq-new feature/my-new-idea videoquant-my-new-idea main"
    return 1
  fi

  cd "$VQ_MGR" &&
  git worktree add -b "$branch" "../$dir" "$base"
}

vq-add-existing() {
  branch="$1"
  dir="$2"

  if [ -z "$branch" ] || [ -z "$dir" ]; then
    echo "usage: vq-add-existing <branch> <dir-name>"
    echo "example: vq-add-existing feature/my-new-idea videoquant-my-new-idea"
    return 1
  fi

  cd "$VQ_MGR" &&
  git worktree add "../$dir" "$branch"
}

vq-remove-tree() {
  dir="$1"

  if [ -z "$dir" ]; then
    echo "usage: vq-remove-tree <dir-name>"
    echo "example: vq-remove-tree videoquant-my-new-idea"
    return 1
  fi

  cd "$VQ_MGR" &&
  git worktree remove "../$dir" &&
  git worktree prune
}

vq-merge-to-main() {
  branch="$1"

  if [ -z "$branch" ]; then
    echo "usage: vq-merge-to-main <branch>"
    echo "example: vq-merge-to-main HWQ_prompt_router"
    return 1
  fi

  cd "$VQ_ROOT/videoquant-main" &&
  git status --short --branch &&
  git merge --no-ff "$branch"
}
```

用法示例：

```bash
vq-list
vq-prompt
vq-new feature/head-rank-ablation videoquant-head-rank-ablation main
vq-remove-tree videoquant-head-rank-ablation
vq-merge-to-main HWQ_prompt_router
```

这些函数故意要求你同时写 `branch` 和 `dir-name`，因为这样最不容易把 `feature/a/b` 这类分支名误当成目录路径。

## 工作规则

1. 原目录 `/mnt/workspace/caipeiliang/code/moweile/videoquant` 只用来管理 worktree，不在里面开发。
2. 每个 agent 只进入自己负责的 worktree 目录。
3. 不要在一个 worktree 里切到另一个长期分支。
4. 开始任务前先确认：

```bash
git status --short --branch
```

5. 如果状态不干净，先弄清楚改动是谁产生的，不要直接 reset。
6. 实验结果、缓存、Mac `._*` 文件不要进 git。

当前本地 exclude 已经忽略：

```text
HeadWiseKVQuant/results/
HeadWiseKVQuant/tmp/
**/._*
HeadWiseKVQuant/docs/*.pdf
```

## 为什么这样做

普通 `git checkout` 只切换分支指针和工作区内容。如果有未提交改动，这些改动会跟着工作区漂移到新分支。多个 agent 共用一个目录时，还可能出现一个 agent 正在工作，另一个 agent 把分支切走。

`git worktree` 的好处是每个分支有自己的目录：

```text
一个分支 = 一个工作目录 = 一套独立未提交改动
```

这样 prompt router、online calibration、HRQ residual quant 可以并行推进，互不污染。

## 推荐给 agent 的开工提示

如果要让 agent 做 prompt router：

```text
请在 /mnt/workspace/caipeiliang/code/moweile/videoquant-prompt 工作。不要切换分支。开始前读取 STATUS.md 和 HANDOFF.md，如需查看其它方向，只读对应 worktree，不要修改。
```

如果要让 agent 做 online calibration：

```text
请在 /mnt/workspace/caipeiliang/code/moweile/videoquant-online 工作。不要切换分支。开始前读取 STATUS.md 和 HANDOFF.md，如需查看其它方向，只读对应 worktree，不要修改。
```

如果要让 agent 做 HRQ residual quant：

```text
请在 /mnt/workspace/caipeiliang/code/moweile/videoquant-hrq 工作。不要切换分支。开始前读取 STATUS.md 和 HANDOFF.md，如需查看其它方向，只读对应 worktree，不要修改。
```
