---
created: 2026-01-27
type: paper
status: unread
tags: ["video-generation", "streaming", "motion-control", "distillation", "real-time"]
aliases: ["MOTIONSTREAM: REAL-TIME VIDEO GENERATION WITH INTERACTIVE MOTION CONTROLS", "MotionStream"]
summary: "交互式轨迹控制的实时流式视频生成"
pdf-url: "Attachments/arxiv_2511.01266.pdf"
github-url: ""
---

# MotionStream
## 一句话摘要
通过运动控制教师蒸馏+滑窗因果注意力，实现可交互的实时流式视频生成（29 FPS）。

## PDF
[[Attachments/arxiv_2511.01266.pdf]]

## ABSTRACT
- 将运动控制的双向扩散教师蒸馏为因果学生，支持实时交互。
- 关键挑战：长程外推、误差累积、固定计算成本。
- 提出滑窗因果注意力 + attention sinks + KV rolling。

## INTRODUCTION
- 现有运动控制视频生成速度慢且非因果，难以交互。
- MotionStream 以“导演式交互”为目标：实时拖拽/轨迹/相机控制。

## 2 RELATED WORK
- 运动控制扩散、流式 AR 生成、Self-Forcing 类方法。

## 3 MOTIONSTREAM: STREAMING GENERATION MEETS MOTION CONTROLS
### 3.1 Teacher with Motion Control
- 使用轻量级正弦轨迹嵌入（避免 ControlNet 级别开销）。
- 联合文本与运动条件，平衡轨迹一致性与次级自然运动。

### 3.2 Distillation to Causal Student
- 采用 Self Forcing + 分布匹配蒸馏。
- 训练模拟推理期长程漂移（self-rollout）。

### 3.3 Sliding-Window Causal Attention + Attention Sinks
- 固定窗口大小，成本不随时长增长。
- Attention sinks 保留全局锚点，防止长期漂移。

### 3.4 Joint Text-Motion Guidance
- 线性插值噪声：
$$
z_t = (1-t)z_0 + t z_1
$$
- 联合引导：
$$
\hat v = v_{base} + w_t\big(v(c_t,c_m)-v(\varnothing,c_m)\big) + w_m\big(v(c_t,c_m)-v(c_t,\varnothing)\big)
$$
$$
v_{base} = \alpha v(\varnothing,c_m) + (1-\alpha)v(c_t,\varnothing),\quad \alpha=\frac{w_t}{w_t+w_m}
$$
- Flow matching：
$$
L_{FM}=\mathbb{E}\|v_\theta(z_{t'},t',c_t,c_m)-(z_1-z_0)\|^2
$$

## 4 EXPERIMENTS
- 实时性能：单 GPU 23–29 FPS，亚秒延迟。
- 任务：实时拖拽、轨迹绘制、相机控制、运动迁移。
- 结果：在运动跟随与画面质量上超过既有实时方案。

## 5 CONCLUSION
- MotionStream 将高质量运动控制与实时交互统一到可扩展的流式生成框架中。

## 相关链接（双向）
- [[Self Forcing]]
- [[Streaming Video Generation]]
- [[Motion Control]]
