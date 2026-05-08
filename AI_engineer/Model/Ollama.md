---
created: 2026-02-03
type: tool
status: unread
tags: [tool, llm, local, inference]
aliases: ["Ollama"]
summary: "本地运行与管理大语言模型的工具，提供 CLI 与 REST API。"
source-url: "https://docs.ollama.com/"
version: ""
license: ""
platforms: [macOS, Windows, Linux, Docker]
pricing: ""
---

# Ollama
## 一句话摘要
Ollama 用于在本地快速运行与管理大语言模型，并通过 CLI 与 REST API 提供集成入口。

## 原文结构（按标题层级）
- Ollama's documentation
  - Quickstart
  - Download
  - Cloud
  - API reference
  - Libraries
  - Community
- Quickstart
  - Run a model
  - Coding
  - Supported integrations
  - Launch with a specific model
  - Configure without launching
- API Reference
  - Introduction
  - Authentication
  - Generate a chat message
- More information
  - macOS
  - Windows
  - Linux
  - Docker

## Quickstart（官方入门）
### Run a model
- 运行模型：`ollama run gemma3`
- Quickstart 提供 CLI / cURL / Python / JavaScript 示例

### Coding
- 推荐 coding 模型：`glm-4.7-flash`
- 该模型需要 23GB VRAM（64k 上下文）
- 云端模型：`glm-4.7:cloud`
- 快速配置 coding 工具：`ollama launch`

### Supported integrations
- OpenCode
- Claude Code
- Codex
- Droid

### Launch with a specific model
- `ollama launch claude --model glm-4.7-flash`

### Configure without launching
- `ollama launch claude --config`

## Download（安装）
### macOS
- 系统要求：macOS Sonoma (v14) 或更新；Apple M 系列或 x86（仅 CPU）
- 安装方式：挂载 `ollama.dmg` 并拖入 `Applications`
- 启动时若未在 PATH 中检测到 `ollama`，会提示创建 `/usr/local/bin` 链接
- 文件位置：`~/.ollama`（模型与配置），`~/.ollama/logs`（日志）

### Windows
- 系统要求：Windows 10 22H2 或更新（Home/Pro）
- GPU 要求：NVIDIA 452.39+ 驱动或 AMD Radeon 驱动
- 安装：`OllamaSetup.exe`（无需管理员权限，默认安装在用户目录）
- 安装后在后台运行；`ollama` CLI 可在 cmd/powershell 中使用；本地 API 默认 `http://localhost:11434`
- 二进制安装至少需要 4GB 空间
- 改变安装目录：`OllamaSetup.exe /DIR="d:\\some\\location"`\n- 改变模型目录：设置 `OLLAMA_MODELS` 环境变量
- CLI + GPU 依赖包：`ollama-windows-amd64.zip`
- AMD GPU 额外 ROCm 包：`ollama-windows-amd64-rocm.zip`
- 作为服务运行：`ollama serve`（可配合 NSSM）

### Linux
- 快速安装：`curl -fsSL https://ollama.com/install.sh | sh`
- 启动：`ollama serve`
- 验证：`ollama -v`
- AMD GPU：额外安装 ROCm 包
- ARM64：使用 ARM64 包
- 可选：systemd 启动服务与自定义环境变量（`systemctl edit ollama`）
- 手动安装（升级时清理旧库后再下载 tar.zst 解压到 `/usr`）
  - `curl -fsSL https://ollama.com/download/ollama-linux-amd64.tar.zst | sudo tar x -C /usr`
  - `curl -fsSL https://ollama.com/download/ollama-linux-arm64.tar.zst | sudo tar x -C /usr`

## Cloud
- Cloud 模型会自动下沉到 Ollama 云端运行，可在不具备强 GPU 的情况下运行更大模型，同时保留本地模型的使用方式
- 需要登录：`ollama signin`
- 示例：`ollama run gpt-oss:120b-cloud`
- 云端 API Base URL：`https://ollama.com/api`
- Cloud API 访问会把 ollama.com 当作远程 Ollama host 使用

## API Reference
### Introduction
- 本地默认 Base URL：`http://localhost:11434/api`
- 示例：`POST /api/generate`
- API 预期保持稳定与向后兼容

### Authentication
- 本地访问无需认证
- 云端运行、发布模型、下载私有模型需要认证
- 方式：`ollama signin` 或 API key（`OLLAMA_API_KEY`）

### Generate a chat message
- 端点：`POST /api/chat`
- 字段：`model`, `messages`
- 返回包含 created_at、done、done_reason、计数与耗时字段

## Libraries（官方与社区）
- 官方库：Python / JavaScript
- 官方博客给出安装与示例代码（`pip install ollama`, `npm install ollama`），并强调与 REST API 一致的体验
- 社区库列表在官方 GitHub 组织与主仓库

## Community
- Discord
- Reddit

## More information
### CLI Reference
- 常用命令：`ollama run <model>`、`ollama launch`
- 支持的 integrations：OpenCode / Claude Code / Codex / Droid
- 多行输入：使用 `\"\"\"` 包裹

### Docker
- CPU 运行：`docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama`
- NVIDIA GPU：安装 NVIDIA Container Toolkit 后 `--gpus=all`
- AMD GPU：使用 `ollama/ollama:rocm` 并挂载 `/dev/kfd` 与 `/dev/dri`
- 运行模型：`docker exec -it ollama ollama run llama3.2`

## 经典教程/参考（优先官方）
- 官方 Quickstart：https://docs.ollama.com/quickstart
- API Introduction：https://docs.ollama.com/api/introduction
- Authentication：https://docs.ollama.com/api/authentication
- Chat API：https://docs.ollama.com/api/chat
- macOS 安装：https://docs.ollama.com/macos
- Windows 安装：https://docs.ollama.com/windows
- Linux 安装：https://docs.ollama.com/linux
- Docker：https://docs.ollama.com/docker
- 官方 Python/JS 库介绍：https://www.ollama.com/blog/python-javascript-libraries
- GitHub 仓库：https://github.com/ollama/ollama

## 关键原文摘录
- “Ollama is the easiest way to get up and running with large language models…”
- “This quickstart will walk your through running your first model with Ollama.”
- “Ollama’s API allows you to run and interact with models programatically.”
- “After installation, Ollama’s API is served by default at: http://localhost:11434/api”

## 相关链接（双向）
- Codex Prompting
- Codex Workflows
