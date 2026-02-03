---
created: 2026-01-25
type: paper
status: unread
tags: [RollingForcing, Autoregressive, AttentionSink, Streaming]
aliases: [Rolling-Forcing]
summary: "联合去噪与attention sink降低误差累积"
pdf-url: "Attachments/arxiv_2509.25161.pdf"
github-url: ""
---

# Rolling Forcing: Autoregressive Long Video Diffusion in Real Time
## PDF
- [[Attachments/arxiv_2509.25161.pdf]]
## 一句话摘要
Rolling Forcing 通过“滚动窗口联合去噪 + attention sink + 扩展窗口蒸馏”实现实时长视频流式生成并抑制误差累积。

## 核心贡献
- 用滚动窗口联合去噪替代逐帧去噪，降低误差在长序列中的传播。
- 将 attention sink 引入流式长视频任务，保留初始帧 KV 作为全局锚点。
- 设计扩展窗口的少步蒸馏训练，使模型在自生成历史上稳定训练。

## 方法/模型（实现细节）
### 1) 滚动窗口联合去噪
不同于逐帧 AR，Rolling Forcing 在一个窗口内同时去噪多帧，并赋予逐帧递增的噪声级别。
这种“局部双向、全局因果”的设计允许帧间互相纠错，减少早期误差向后扩散。

### 2) Attention Sink 作为全局锚点
将初始帧的 KV 状态固定为“全局锚点”，并调整 RoPE 使其相对位置稳定：
- 既保留长期一致性（场景/主体不漂移），
- 又维持流式生成的低延迟。

### 3) 扩展窗口蒸馏训练
训练时使用非重叠的长窗口进行少步蒸馏：
- 每个窗口覆盖一段完整时序，避免单帧噪声的累积偏差。
- 训练过程中始终使用自生成历史作为上下文，缓解曝光偏差。

## 实验与结果
- 单 GPU 实时生成约 16 FPS，多分钟视频误差累积显著降低。
- 相比 Self Forcing 与 CausVid，长期一致性更好。

## 局限与注意事项
- 联合去噪窗口越大，计算成本越高，需要在速度和一致性间折中。
- attention sink 的锚点选择影响长期一致性。

## 相关链接（双向）
- [[流式视频生成]]
- [[长视频生成]]
- [[视频扩散]]
