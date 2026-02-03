---
created: 2026-01-25
type: paper
status: unread
tags: [LongVideo, TextToVideo, Consistency, Autoregressive]
aliases: [StreamingT2V]
summary: "通过短期/长期记忆实现长视频稳定生成"
pdf-url: "Attachments/arxiv_2403.14773.pdf"
github-url: ""
---

# StreamingT2V: Consistent, Dynamic, and Extendable Long Video Generation from Text
## PDF
- [[Attachments/arxiv_2403.14773.pdf]]
## 一句话摘要
StreamingT2V 通过短期/长期记忆条件与随机混合增强，把短视频模型扩展到分钟级长视频，并显著降低跨片段断裂与漂移。

## 核心贡献
- 提出三阶段流水线：初始化短片段 → 自回归长视频生成 → 自回归高分辨率增强。
- CAM 提供短期记忆，APM 提供长期记忆，解决跨片段一致性与遗忘问题。
- 随机混合增强（randomized blending）改善重叠片段的一致性并可无限延展。

## 方法/模型（实现细节）
### 1) 扩散建模与基础训练
模型在 VQ-GAN 潜空间中进行扩散。给定视频 $V \in \mathbb{R}^{F\times H\times W\times 3}$，逐帧编码得到潜变量 $x_0 \in \mathbb{R}^{F\times h\times w\times c}$：
$$x_0^f = E(V^f), \quad f=1,\dots,F$$
前向扩散：
$$q(x_t\mid x_{t-1}) = \mathcal{N}(x_t; \sqrt{1-\beta_t}x_{t-1}, \beta_t I)$$
反向扩散：
$$p_\theta(x_{t-1}\mid x_t) = \mathcal{N}(x_{t-1}; \mu_\theta(x_t,t), \Sigma_\theta(x_t,t))$$
训练时预测噪声：
$$\min_\theta \; \mathbb{E}_{t,(x_0,\tau),\epsilon}\; \|\epsilon-\epsilon_\theta(x_t,t,\tau)\|_2^2$$

### 2) Streaming T2V 阶段（长视频生成）
初始化阶段用短视频模型（如 Modelscope）生成首段 16 帧。随后进入自回归生成：
- **CAM（短期记忆）**：使用前一段 $F_{cond}=8$ 帧作为条件，注入到 Video-LDM 的 UNet 跳连处。
- **特征注入细节**：对跳连特征 $x_{SC}$ 施加时序多头注意力（T-MHA），以 CAM 特征作为 K/V：
$$Q=P_Q(x'_{SC}),\; K=P_K(x_{CAM}),\; V=P_V(x_{CAM})$$
$$x''_{SC}=\mathrm{T\text{-}MHA}(Q,K,V)$$
最终用可学习映射 $P_{out}$ 融合：
$$x'''_{SC} = x_{SC} + R(P_{out}(x''_{SC}))$$
其中 $P_{out}$ 零初始化，避免初期破坏基模输出。

### 3) APM（长期记忆）
为保持首段场景/对象，APM 从首段 anchor frame 提取 CLIP 图像 token，并与文本 token 融合：
- 图像 token 通过 MLP 扩展为 $k=16$ 个 token，与文本 token 拼接。
- 在每一层 cross-attention 注入混合特征：
$$x_{cross} = \mathrm{SiLU}(\alpha_l)\,x_{mixed} + x_{text}$$
其中 $\alpha_l$ 可学习且初始化为 0。

### 4) Streaming Refinement 阶段（高分辨率增强）
使用高分辨率短视频模型（如 MS-Vid2Vid-XL）对 24 帧块进行 SDEdit 风格增强，块间重叠 $O=8$。
为消除拼接断裂，引入 **shared noise + randomized blending**：
- 噪声拼接：
$$\epsilon_i = \mathrm{concat}([\epsilon^{i-1}_{F-O:F}, \hat\epsilon_i], \mathrm{dim}=0)$$
- 随机混合重叠区：
$$x_{LR}=\mathrm{concat}([x^L_{1:F-f_{thr}},\;x^R_{f_{thr}+1:F}])$$
通过随机阈值 $f_{thr}$ 混合两段重叠潜变量，显著提升一致性。

## 实验与结果（关键设置）
- 生成长度：240 帧与 1200 帧测试。
- 评估指标：SCuts（场景切换次数）、MAWE（运动与一致性联合误差）、CLIP 文本对齐。
- 相比多种开源基线（OpenSora/FreeNoise/SEINE 等），在 MAWE 与 CLIP 上最佳，SCuts 次优。

## 局限与注意事项
- 仍依赖高质量短视频基础模型与 CLIP 表征。
- CAM/APM 引入额外模块与注意力计算，推理速度受限于基础模型规模。

## 相关链接（双向）
- [[长视频生成]]
- [[文本到视频]]
- [[自回归视频]]
