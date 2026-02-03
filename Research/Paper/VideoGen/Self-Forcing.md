---
created: 2026-01-25
type: paper
status: unread
tags: [SelfForcing, Autoregressive, ExposureBias, Streaming]
aliases: [Self-Forcing]
summary: "自回归自滚动训练缓解曝光偏差"
pdf-url: "Attachments/arxiv_2506.08009.pdf"
github-url: ""
---

# Autoregressive Video Diffusion (Self Forcing)
## PDF
- [[Attachments/arxiv_2506.08009.pdf]]
## 一句话摘要
Self Forcing 在训练时执行自回归自滚动，并用视频级分布匹配损失监督，从而缓解曝光偏差并提升长序列稳定性。

## 核心贡献
- 训练阶段引入与推理一致的自回归 rollout，减少 train-test 分布差异。
- 在训练时使用 KV 缓存（不仅推理时），实现高效自回归监督。
- 提出 rolling KV cache 机制，支持长视频外推且不需重算缓存。

## 方法/模型（实现细节）
### 1) Self Forcing 训练流程
与 Teacher/Diffusion Forcing 不同，Self Forcing 在训练时生成自身上下文：
1. 初始化 KV 缓存为空。
2. 逐步生成当前片段的噪声预测与去噪结果。
3. 将生成的 KV 嵌入写入缓存，用作下一步上下文。
4. 对最终生成的整段视频应用分布匹配损失（DMD/SiD/GAN）。

### 2) 分布匹配损失
论文强调：自生成上下文 + 视频级损失能够直接对“推理分布”进行监督，缓解曝光偏差。
实践中使用 DMD、SiD 或 GAN 损失均可，Self Forcing 在多个损失下均稳定优于基线。

### 3) Rolling KV Cache
常规因果模型在滑动窗口时需要重算 KV。
Rolling KV 方案：维护固定长度缓存，满时丢弃最旧 KV，避免重复计算。
为防止长序列质量退化，训练中显式模拟 rolling KV，使模型适配推理状态。

## 实验与结果
- 在 VBench 与用户偏好评测上优于 Teacher/Diffusion Forcing。
- 1-step/2-step/3-step 训练下均表现稳定，训练效率不劣于基线。

## 局限与注意事项
- 训练需严格同步推理流程，否则难以获得稳定收益。
- rolling KV 需合理窗口长度，过短会损失长期一致性。

## 相关链接（双向）
- [[自回归视频]]
- [[曝光偏差]]
- [[流式视频生成]]
