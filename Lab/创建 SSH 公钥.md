---
created: 2026-05-11
tags: [ssh, github, server, lab]
source: "personal"
---

# 创建 SSH 公钥

## 一句话摘要

如果服务器还没有 SSH 公钥，就生成一对 `ed25519` key，再把公钥加到 GitHub。

## 1. 先看有没有现成公钥

```bash
ls -la ~/.ssh
cat ~/.ssh/id_ed25519.pub
```

如果能正常看到 `id_ed25519.pub` 的内容，就说明已经有公钥了。

## 2. 如果没有，就生成一对

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

一路回车即可，默认会生成到：

```text
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```

## 3. 查看公钥内容

```bash
cat ~/.ssh/id_ed25519.pub
```

会得到一整行，形如：

```text
ssh-ed25519 AAAA... your_email@example.com
```

## 4. 加到 GitHub

打开：

- [GitHub SSH keys](https://github.com/settings/keys)

然后：

1. 点击 `New SSH key`
2. `Title` 填机器名，比如 `forcing_1` 或 `lyg0311`
3. `Key type` 选 `Authentication Key`
4. `Key` 粘贴 `id_ed25519.pub` 的整行内容
5. 保存

## 5. 测试是否成功

```bash
ssh -T git@github.com
```

如果成功，通常会看到：

```text
Hi <yourname>! You've successfully authenticated, but GitHub does not provide shell access.
```

## 常见问题

### `Permission denied (publickey)`

通常表示：

- 这台机器的公钥还没加到 GitHub
- 或者当前连接没用到正确的私钥

优先检查：

```bash
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
```

### 第一次连 GitHub 提示主机指纹

如果看到：

```text
The authenticity of host 'github.com (...)' can't be established.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

确认这是你主动在连 GitHub 后，输入：

```text
yes
```

它会把 GitHub 主机指纹写入 `~/.ssh/known_hosts`。

## 最短流程

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
```

## 相关笔记

- [[开工/Git 与双机同步工作流]]
