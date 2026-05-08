---
created: 2026-04-09
published: 2023-11-24
type: paper
status: 未读
tags: [DemoFusion, DynamicResolution, TuningFree]
aliases: [DemoFusion]
summary: "通过渐进上采样与采样策略改造，让开源模型以较低门槛生成更高分辨率图像。"
pdf-url: "https://arxiv.org/pdf/2311.16973.pdf"
source-url:
  - https://arxiv.org/abs/2311.16973
  - https://arxiv.org/pdf/2311.16973.pdf
---

# DemoFusion: Democratising High-Resolution Image Generation With No $$$

## Abstract
DemoFusion 通过 progressive upscaling、skip residual、dilated sampling 等推理策略，让开源模型在较低资源条件下生成更高分辨率图像，强调“可负担的高分辨率”。

## 1 Introduction
论文目标是降低高分辨率生成门槛：无需昂贵重训，通过推理流程改造提升开源模型上限。

## 2 Related Work
对比了级联超分、分块推理与其他 training-free 方法，指出资源占用与画质之间仍存在明显工程缺口。

## 3 Methodology
### 3.1 Preliminaries
定义基础扩散采样流程与高分辨率外推场景。

### 3.2 Progressive Upscaling
采用渐进分辨率提升，先稳住全局再补局部细节，减少一次性上采样导致的崩坏。

### 3.3 Skip Residual
跨尺度残差跳连保留低分阶段语义与结构锚点，抑制高分阶段漂移。

### 3.4 Dilated Sampling
在采样中引入扩张式覆盖，提升大画布细节一致性并减少局部重复。

## 4 Experiments
### 4.1 Comparison
在高分辨率任务上相较基线展现更好视觉质量/资源开销比。

### 4.2 Ablation Study
消融显示三项策略叠加后效果最好，尤其对极高分辨率场景收益明显。

## 5 Limitations and Opportunities
论文承认极端大尺寸下仍有耗时问题，并提出与蒸馏/加速模型结合的机会。

## 6 Conclusion
DemoFusion 的贡献是把“高分辨率可用性”带到开源社区常规硬件环境中，强化了 dynamic resolution 的实际落地价值。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
