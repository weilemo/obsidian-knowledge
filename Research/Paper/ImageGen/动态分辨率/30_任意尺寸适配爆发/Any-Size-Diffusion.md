---
created: 2026-04-09
published: 2023-08-31
type: paper
status: 未读
tags: [AnySizeDiffusion, DynamicResolution, HDGeneration]
aliases: [Any-Size-Diffusion, ASD]
summary: "两阶段框架（比例适配 + 无缝 tiled 放大）把任意尺寸 HD 生成系统化，并兼顾速度。"
pdf-url: "https://arxiv.org/pdf/2308.16582.pdf"
source-url:
  - https://arxiv.org/abs/2308.16582
  - https://arxiv.org/pdf/2308.16582.pdf
---

# Any-Size-Diffusion: Toward Efficient Text-Driven Synthesis for Any-Size HD Images

## Abstract
Any-Size-Diffusion（ASD）提出两阶段框架：先做比例适配（ARAD），再做无缝分块放大（FSTD），实现任意尺寸 HD 图像生成，并尽量保持推理效率。

## Introduction
作者关注“任意尺寸 + 高分辨率 + 低成本”三目标的同时满足。核心思路是将问题解耦：先保证布局与比例，再保证细节与无缝性。

## Related Work
论文把工作置于三类方法之间：
- 重新训练多分辨率模型；
- 推理期拼接/裁切；
- 条件超分链路。
ASD 目标是在不重训基础模型下获得更好可控性。

## Method
整体 pipeline 分两步：
1. ARAD 先在目标比例上建立稳定语义布局；
2. FSTD 再在更高分辨率上分块细化并处理块间一致性。

## Pipeline
论文给出完整推理流程、分块覆盖方式与融合策略，重点是把全局语义与局部细节分阶段优化。

## Any Ratio Adaptability Diffusion (ARAD)
ARAD 通过比例感知采样与条件重参数化，缓解非常规长宽比下的主体变形与构图坍塌。

## Fast Seamless Tiled Diffusion (FSTD)
FSTD 在 tiled 推理中引入重叠与融合规则，降低拼接缝与纹理断裂，并兼顾速度。

## Experiments
## Experimental Settings
说明评测数据、提示词集合与硬件设置。

## Baseline Comparisons
相较直接高分辨率采样和常规 tiled 方案，ASD 在任意尺寸场景下质量更稳定。

## ARAD Analysis
消融显示 ARAD 对布局稳定性贡献最大。

## FSTD Analysis
消融显示 FSTD 主要改善局部细节与块边界一致性。

## Conclusion
ASD 的价值在于把“任意尺寸”从临时技巧变成系统化流程，是 2023 年动态分辨率方向的重要工程化方案。

## 相关链接（双向）
- [[图像生成中的动态分辨率-研究背景与科研历程]]
