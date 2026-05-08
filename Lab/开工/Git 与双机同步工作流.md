---
created: 2026-05-08
tags: [git, github, ssh, workflow, server, lab]
source: "personal"
---

# Git 与双机同步工作流

## 一句话摘要

两台服务器之间同步工作，默认采用这套组合：**Git 管代码，SSH 管认证，`rsync` 管大文件和运行产物，必要时再处理子模块。**

## 这套方案解决什么问题

- 代码可以在两台服务器之间稳定同步。
- 改动有历史，出问题能回溯。
- 不把数据集、日志、模型权重一股脑塞进 Git。
- 第一次在服务器上连 GitHub 时，知道 SSH 公钥怎么配。
- 遇到“子模块想改成普通目录一起传”时，有明确做法。

## 推荐的目录分层

建议项目目录里把“代码”和“运行产物”分开：

```text
project/
├── src/
├── configs/
├── scripts/
├── data/
├── checkpoints/
├── outputs/
├── logs/
└── README.md
```

其中：

- `src/`、`configs/`、`scripts/`、`README.md` 适合进 Git。
- `data/`、`checkpoints/`、`outputs/`、`logs/` 默认不进 Git。

## 起步：把项目放进 Git

在项目目录里执行：

```bash
cd /path/to/your/project
git init
git status
```

建议先写 `.gitignore`，避免把环境、数据和大文件直接提交上去：

```gitignore
__pycache__/
*.pyc

.env
.venv/
venv/

data/
datasets/
outputs/
logs/
checkpoints/
runs/

*.pt
*.pth
*.ckpt
*.bin
*.safetensors

.DS_Store
```

然后提交第一版：

```bash
git add .
git commit -m "Initial commit"
```

如果提交时报“没有设置用户名邮箱”，先配置：

```bash
git config --global user.name "moweile"
git config --global user.email "your_email@example.com"
```

## 连接 GitHub 远程仓库

在 GitHub 上新建空仓库后，把本地仓库连上远程：

```bash
git remote add origin git@github.com:yourname/your-repo.git
git remote -v
```

如果希望默认分支叫 `main`：

```bash
git branch -M main
```

首次推送：

```bash
git push -u origin main
```

## 第二台服务器的 Git 初始化

第二台服务器分两种情况：**新拉一个已有项目**，或者**接手一个本地已经存在但还没接远程的目录**。

### 情况 1：第二台服务器从 GitHub 直接拉项目

这是最推荐的方式：

```bash
cd /path/to/workspace
git clone git@github.com:yourname/your-repo.git
cd your-repo
git branch
git remote -v
```

如果远程仓库默认分支已经是 `main`，克隆后通常会自动在 `main` 上。

### 情况 2：第二台服务器本地已经有目录，要接到已有远程仓库

如果这个目录原本不是从 GitHub `clone` 下来的，而是自己拷过去的，就按下面做：

```bash
cd /path/to/your/project
git init
git remote add origin git@github.com:yourname/your-repo.git
git fetch origin
git checkout -b main origin/main
```

如果本地已经有内容，而且你想保留这些文件，同时让它接上远程历史，先确认目录内容不会覆盖远程，再执行：

```bash
git init
git remote add origin git@github.com:yourname/your-repo.git
git fetch origin
git branch -M main
```

然后根据实际情况选择 `git pull --rebase origin main`，或者先手工处理冲突。

### 第二台服务器也需要单独配置 SSH key

GitHub 的 SSH 授权是按“机器上的 key”来的，不是按“你这个人已经在别的机器配过一次”自动继承。

所以第二台服务器也要检查：

```bash
ls -la ~/.ssh
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
```

如果没有 key，就生成；如果有 key 但没授权，就把这台机器的公钥也加到 GitHub。

## 常见报错：`src refspec main does not match any`

这通常表示以下两种情况之一：

- 本地还没有任何 commit。
- 当前分支不叫 `main`。

修复顺序通常是：

```bash
git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main
```

## GitHub SSH 公钥配置

### 1. 查看服务器上的公钥

先检查本机有没有 SSH 公钥：

```bash
ls -la ~/.ssh
cat ~/.ssh/id_ed25519.pub
```

如果没有，就生成一对：

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

一路回车使用默认路径即可。生成后再次查看：

```bash
cat ~/.ssh/id_ed25519.pub
```

### 2. 把公钥加到 GitHub

打开：

- [GitHub SSH keys](https://github.com/settings/keys)

然后：

1. 点击 `New SSH key`
2. `Title` 填这台机器的名字，比如 `lyg0311`
3. `Key type` 选 `Authentication Key`
4. `Key` 粘贴 `id_ed25519.pub` 的整行内容
5. 保存

### 3. 首次连接 GitHub 的指纹确认

第一次 `git push` 时，如果看到：

```text
The authenticity of host 'github.com (...)' can't be established.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

这不是报错，而是在问是否信任 GitHub 主机。确认这是你主动连接 GitHub 后，输入：

```text
yes
```

然后 SSH 会把 GitHub 的主机指纹写入 `~/.ssh/known_hosts`。

### 4. 测试是否已经能用

```bash
ssh -T git@github.com
```

如果成功，通常会看到类似：

```text
Hi yourname! You've successfully authenticated, but GitHub does not provide shell access.
```

### 5. 常见报错：`Permission denied (publickey)`

这表示：

- 网络通常是通的。
- 仓库地址格式通常没问题。
- 卡在“这台机器没有被 GitHub 认可的 SSH 身份”。

优先检查：

```bash
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
```

如果还没把公钥加到 GitHub，就先去加；如果已经加了，确认当前推送用的是对应账户下的 key。

## 日常 Git 工作流

### 查看状态

```bash
git status
git diff
```

### 保存修改

```bash
git add .
git commit -m "update something"
```

### 推到 GitHub

```bash
git push
```

### 从 GitHub 拉最新

```bash
git pull
```

## 分支怎么选

## `origin`、`main`、`origin/main` 分别是什么意思

这三个名字很常一起出现，但它们不是一个层面的东西。

### `origin`

`origin` 是**远程仓库的别名**。它通常指向 GitHub 上的那个仓库地址。

例如：

```bash
git remote -v
```

可能看到：

```text
origin  git@github.com:yourname/your-repo.git (fetch)
origin  git@github.com:yourname/your-repo.git (push)
```

意思是：当执行 `git fetch origin`、`git pull origin ...`、`git push origin ...` 时，Git 知道你指的是这个远程仓库。

### `main`

`main` 是**分支名**，通常表示主分支。

它描述的是一条代码历史线，而不是一台服务器或一个仓库地址。

### `origin/main`

`origin/main` 是**远程跟踪分支**，可以理解为：

- 本地 Git 记录下来的“远程 `origin` 上的 `main` 最近一次已知状态”

它不是你真正站在远程机器上操作，而是你本地对远程主分支状态的一份镜像记录。

### 放在一起看

- `origin`：远程仓库是谁
- `main`：分支是哪条
- `origin/main`：远程仓库 `origin` 上的 `main` 在本地的跟踪记录

### 常见命令怎么理解

```bash
git fetch origin
```

从远程仓库 `origin` 拉取最新信息，但不直接改当前工作区文件。

```bash
git pull origin main
```

从远程仓库 `origin` 拉取它的 `main` 分支，并合并到当前本地分支。

```bash
git push origin main
```

把本地 `main` 分支推到远程仓库 `origin` 的 `main` 分支。

```bash
git checkout -B main origin/main
```

让本地 `main` 分支对齐远程 `origin/main` 指向的状态。

### 观察它们的常用命令

```bash
git remote -v
git branch -a
git remote show origin
```

分别用来查看：

- 远程别名和地址
- 本地分支和远程分支
- 远程默认分支、跟踪关系和同步信息

默认规则很简单：**主分支统一用 `main`，日常开发尽量在短生命周期功能分支上完成，再合回 `main`。**

### 什么时候直接用 `main`

适合以下场景：

- 只有你一个人在维护这个仓库。
- 这个仓库主要是个人实验、脚本、笔记型项目。
- 改动节奏快，分支管理成本比收益高。

这类项目里，两台服务器都直接同步 `main` 就够了：

```bash
git pull
git add .
git commit -m "update"
git push
```

### 什么时候开功能分支

适合以下场景：

- 你要做一批相对独立、可能失败或需要回退的实验性改动。
- 这个仓库会和别人协作。
- 你不想把半成品直接推到主分支。

示例：

```bash
git checkout -b feat/quant-debug
git add .
git commit -m "debug quant pipeline"
git push -u origin feat/quant-debug
```

做完后再合回 `main`。

### 如何查看远程默认分支

如果不确定远程仓库到底是 `main` 还是 `master`，先查：

```bash
git remote show origin
```

重点看输出里的 `HEAD branch`。

也可以直接看远程分支：

```bash
git branch -r
```

如果看到的是 `origin/master`，就不要强行推 `main`，而是按远程实际分支来：

```bash
git checkout -b master origin/master
```

或者把本地分支切到远程已有的默认分支。

### 我的默认分支策略

- 新仓库：直接统一为 `main`
- 个人小项目：大多数时候直接在 `main` 上推进
- 风险较大的改动：先开 `feat/...` 或 `fix/...` 分支
- 第二台服务器接手前：先确认远程默认分支，不靠猜

## 两台服务器同步的推荐方案

### 代码：用 Git

在服务器 A 上改代码后：

```bash
git add .
git commit -m "update experiment"
git push
```

在服务器 B 上更新：

```bash
git pull
```

### 数据、权重、日志：用 `rsync`

不建议把数据集、checkpoint、日志直接放进 Git。更稳的方式是：

```bash
rsync -avP /path/to/project/data/ server-b:/path/to/project/data/
rsync -avP /path/to/project/checkpoints/ server-b:/path/to/project/checkpoints/
```

如果已经配置了 SSH alias，比如：

```sshconfig
Host forcing_1
    HostName example.com
    Port 16100
    User root
    IdentityFile ~/.ssh/id_ed25519
```

也可以直接写：

```bash
rsync -avP /path/to/project/ forcing_1:/path/to/project/
```

## 子模块是什么

子模块本质上是：**主仓库里记录了另一个 Git 仓库的某个提交指针，而不是把里面的源代码文件直接并入主仓库。**

所以当主仓库里出现这种状态时：

```text
modified: Quant-VideoGen (modified content, untracked content)
```

通常说明：

- `Quant-VideoGen` 本身是一个独立 Git 仓库。
- 主仓库只知道“它指向哪个提交”，不知道它内部普通文件的细节。

## 子模块的常规工作方式

如果保留子模块结构，正确流程是两步：

1. 先进入子模块目录，单独提交并推送子模块。
2. 再回到主仓库，提交“子模块指针变化”。

示例：

```bash
cd Quant-VideoGen
git add .
git commit -m "update submodule"
git push

cd ..
git add Quant-VideoGen
git commit -m "update submodule pointer"
git push
```

## 把子模块改成普通目录一起提交

当需求不是“保留独立仓库”，而是“把里面所有代码都当主仓库普通文件一起推送”时，可以把子模块转成普通目录。

### 适用场景

- 不想维护两个仓库。
- 希望 `Quant-VideoGen` 里的文件跟主仓库一起 `git add`、`git commit`、`git push`。
- 这个目录不再需要单独的远程仓库生命周期。

### 推荐做法

先在主仓库根目录备份：

```bash
cp -R Quant-VideoGen /tmp/Quant-VideoGen-backup
```

然后删除该目录内部独立 Git 身份：

```bash
rm -rf Quant-VideoGen/.git
```

如果主仓库索引里仍把它当 `gitlink`，需要移除旧记录，再作为普通目录重新加入：

```bash
git rm --cached Quant-VideoGen
git add Quant-VideoGen
```

如果普通 `git add` 仍被忽略，可强制加入：

```bash
git add -f Quant-VideoGen
```

确认状态：

```bash
git status
git diff --cached --stat
```

如果看到很多 `new file: Quant-VideoGen/...`，说明已经成功变成普通目录。然后提交：

```bash
git commit -m "Track Quant-VideoGen as a regular directory"
git push -u origin main
```

### 判断当前是不是子模块

可以用这些命令辅助判断：

```bash
git status
git ls-files | grep '^Quant-VideoGen'
git submodule status
```

如果出现：

```text
fatal: Pathspec 'Quant-VideoGen/README.md' is in submodule 'Quant-VideoGen'
```

这说明主仓库索引还把它当子模块看，需要执行：

```bash
git rm --cached Quant-VideoGen
git add Quant-VideoGen
```

## 我的默认操作顺序

1. 项目先初始化 Git，并写好 `.gitignore`。
2. 在 GitHub 新建空仓库，配置 `origin`。
3. 服务器生成 SSH key，把公钥加到 GitHub。
4. 用 `ssh -T git@github.com` 测认证是否成功。
5. 代码改动通过 `git add`、`git commit`、`git push` 同步。
6. 数据和权重通过 `rsync` 同步，不进 Git。
7. 如果项目里出现嵌套仓库，先判断是保留子模块，还是改成普通目录。

## 自检清单

- 我现在推送失败，是分支名问题、没有 commit，还是 SSH 认证问题？
- 这台服务器的公钥是否已经加到 GitHub？
- `.gitignore` 有没有把我真正想提交的内容挡掉？
- 嵌套目录到底是普通目录，还是子模块？
- 我是在同步“代码”，还是在同步“数据/日志/权重”？

## 相关笔记

- [[服务器工作习惯]]
- [[项目记录目录模板]]
