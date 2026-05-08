---
created: 2026-04-08
type: note
status: active
tags: ["FastVideo", "video-generation", "inference-acceleration", "post-training", "distillation", "VSA"]
aliases: ["FastVideo 总结", "FastVideo 仓库总结"]
summary: "按官方 README/Docs/Blog 梳理 FastVideo 在做的事情：统一视频生成加速框架（后训练+实时推理）。"
source-url:
  - https://github.com/hao-ai-lab/FastVideo
  - https://raw.githubusercontent.com/hao-ai-lab/FastVideo/main/README.md
  - https://hao-ai-lab.github.io/FastVideo/
  - https://haoailab.com/blogs/fastvideo/
  - https://haoailab.com/blogs/fastvideo_post_training/
---

# FastVideo 仓库做了什么（按官方结构整理）

## 1) README 定位（What is FastVideo）
- 官方定位：FastVideo 是一个“统一的后训练 + 实时推理”框架，目标是加速视频生成，而不是只发布某个单模型。
- 核心对象：开源 Video DiT 生态（如 Wan 系列、Hunyuan 等），强调从训练配方到推理部署的完整链路。

## 2) NEWS（近期在做的事）
- 2026-03-17：发布 Dreamverse 在线演示（Vibe Directing）。
- 2026-03-13：发布“单卡 4.5 秒生成 5 秒 1080p 视频”在线演示。
- 2025-11-19：发布 CausalWan2.2 I2V A14B Preview 模型与推理代码。
- 2025-08-04：发布 FastWan 模型与 Sparse Distillation 方案。
- 2025-02-18 到 2025-06-14：持续发布 STA/VSA 相关推理与训练支持。

## 3) Key Features（仓库主要做的事情）
### 3.1 端到端后训练（Post-training）
- 支持全参微调与 LoRA 微调。
- 提供视频、图像、文本数据预处理流水线。
- 提供 DMD2 分布匹配蒸馏（step-wise distillation）。
- 提供 Sparse Distillation（将稀疏注意力与少步蒸馏结合）。
- 支持 Self-Forcing 的因果蒸馏路径。
- 支持大规模训练基础设施：FSDP2、Sequence Parallel、Selective Activation Checkpointing。

### 3.2 推理加速（Inference Optimizations）
- 分布式推理下的 Sequence Parallel。
- 多种注意力后端与内核优化（官方文档含 VSA/STA 路线）。
- CLI + Python API 双入口，降低接入成本。
- 支持实时/流式生成相关能力（仓库含 serving 与 openai-style API 入口）。

### 3.3 工程可用性（Hardware & OS）
- 面向 H100、A100、4090 等硬件做了兼容策略。
- 跨 Linux、Windows、macOS。
- 官方给出支持矩阵和优化组合说明，强调“模型-硬件-优化”的兼容关系。

## 4) Getting Started（如何快速跑起来）
- 推荐用 `uv` 建环境并安装 `fastvideo`。
- 最小可运行路径：`VideoGenerator.from_pretrained(...)` + `generate_video(...)`。
- 官方示例默认会引导到 attention backend（如 VSA）与模型配置。

## 5) Distillation / FastWan（从“能跑”到“跑得快”）
- FastVideo 不只做推理脚本，还提供了从数据到配方到模型发布的后训练闭环。
- 在 FastWan 博文中，核心路线是：
  - 用可训练稀疏注意力（VSA）；
  - 结合 DMD 做少步蒸馏；
  - 让 student 用稀疏注意力，score 网络保持全注意力监督。
- 官方公开了对应模型、配方与合成数据集，目标是可复现实验与社区复用。

## 6) 按仓库定位给一句“实话版”结论
FastVideo 本质上是在做“视频版的统一加速框架基础设施”：
不是单点 SOTA 论文复现仓库，而是把训练后加速、推理优化、工程部署和模型发布打通的一整套系统。

## 7) 关键原文摘录（短引）
> “FastVideo is a unified post-training and real-time inference framework for accelerated video generation.”  
来源：README

> “A simple, consistent API that’s easy to use and integrate.”  
来源：FastVideo V1 Blog

> “jointly train sparse attention and denoising step distillation in a unified framework.”  
来源：FastWan Blog

## 8) 参考链接
- GitHub: https://github.com/hao-ai-lab/FastVideo
- 文档主页: https://hao-ai-lab.github.io/FastVideo/
- FastVideo V1 博文: https://haoailab.com/blogs/fastvideo/
- FastWan / Sparse Distillation 博文: https://haoailab.com/blogs/fastvideo_post_training/
- VSA 论文（README 引用）: https://arxiv.org/pdf/2505.13389
- STA 论文（README 引用）: https://arxiv.org/pdf/2502.04507
