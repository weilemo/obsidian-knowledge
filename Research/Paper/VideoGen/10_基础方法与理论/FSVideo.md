---
created: 2026-05-11
published: 2026-02-02
type: paper
status: 已读
tags:
  - FSVideo
  - VideoGeneration
  - ImageToVideo
  - VideoAutoencoder
  - DiT
  - Acceleration
aliases:
  - FSVideo
  - "FSVideo: Fast Speed Video Diffusion Model in a Highly-Compressed Latent Space"
summary: FSVideo 是 ByteDance 的高速 I2V 扩散框架，核心是把视频压到极高压缩 latent space：FSAE 使用 64×64×4 时空下采样和 128 latent channels，把信息量压到 1:384；DiT 端加入 Layer Memory 让每层动态访问前面所有层的表示；再用 latent upsampler + 8-step refiner 恢复细节。最终在 VBench I2V 上保持竞争质量，同时 2 张 H100 上生成 720p 5s 视频的 DiT 推理比 Wan2.1-I2V-14B 快 42.3×。
pdf-url: Attachments/arxiv_2602.02092.pdf
github-url: ""
source-url:
  - https://arxiv.org/abs/2602.02092
  - https://doi.org/10.48550/arXiv.2602.02092
  - https://kingofprank.github.io/fsvideo/
---

# FSVideo: Fast Speed Video Diffusion Model in a Highly-Compressed Latent Space

## PDF
- [[Attachments/arxiv_2602.02092.pdf]]

## 一句话摘要
FSVideo 的核心是减少每次 DiT forward 的 token 量：用 `64×64×4` 的高压缩视频自编码器把视频压到很小的 latent space，再通过 Layer Memory 和高分辨率 latent refiner 补回容量与细节。

## Abstract
FSVideo 是一个 fast image-to-video diffusion framework。它没有主要依赖 step distillation 把采样步数压到极低，而是从“每一步算得太贵”入手：先设计 `FSAE` 视频自编码器，把输入视频从 $3\times T\times H\times W$ 压到 $128\times (T/4)\times (H/64)\times (W/64)$ 的 latent，整体信息量约压缩到 `1:384`；再训练一个 14B DiT base model 在这个高度压缩 latent space 中生成低分辨率 latent；最后用 latent upsampler 和 14B refiner DiT 做高分辨率细化。

为了弥补高压缩 latent 带来的容量损失，论文在 DiT 里加入 `Layer Memory`：每层 self-attention 的 key/value 不只来自上一层 hidden state，而是由动态 router 对所有先前层表示做加权融合。最终 FSVideo 在 `720×1280` I2V VBench 上达到 `Total = 88.12%`，质量接近主流开源 I2V 模型；在两张 H100 上生成 `5s / 720p / 24fps` 视频时，DiT 推理 `19.4s`，比 Wan2.1-I2V-14B-720P 的 `822.1s` 快 `42.3×`。

## 1 Introduction
视频扩散模型慢有两个来源：
- 采样步数多；
- 每一步 DiT forward 的 token 数和计算量巨大。

很多加速方法关注第一点，例如 solver、cache、sparse attention、step distillation。FSVideo 更关注第二点：如果能把视频 latent 压得足够小，每一步 DiT 的计算量就会大幅下降；再配合适度步数和 refiner，就可能在质量不崩的情况下获得数量级加速。

作者选择做 `image-to-video` 而不是完整 text-to-video，有三个原因：
- I2V 有第一帧作为外观条件，训练更容易，DiT 可以更专注建模 motion。
- 资源有限，I2V 对高质量视频-文本数据依赖更低。
- 很多实际应用本来就是 photo reenactment / visual effects，天然从图像出发。

## 2 Overall Design
FSVideo pipeline：
1. 输入图像经 FSAE encoder 得到第一帧 latent condition。
2. base DiT 在低分辨率、高压缩 latent space 中做第一轮扩散生成。
3. 生成 latent 送入 convolutional latent upsampler，空间上放大 `2×`。
4. 高分辨率 refiner DiT 以 upsampled latent 和第一帧 latent 为条件，再做一次扩散修复。
5. FSAE decoder 输出最终视频。

核心组件：
- `FSAE`: highly-compressed asymmetric video autoencoder。
- `Base DiT`: 14B I2V diffusion transformer with Layer Memory。
- `Latent Upsampler`: CNN latent upscaler。
- `Refiner DiT`: 14B high-resolution DiT，经过 step distillation 降到 `8 NFE`。

## 3 FSAE: Highly-Compressed Video Autoencoder

### 3.1 Compression
给定视频：
$$
V \in \mathbb{R}^{3\times T\times H\times W}
$$

FSAE 编码为：
$$
Z \in \mathbb{R}^{128\times (T/4)\times (H/64)\times (W/64)}
$$

也就是：
- spatial downsample：$64\times 64$
- temporal downsample：$4\times$
- latent channels：`128`
- total compression：`1:384`

论文中总压缩率写成：
$$
\mathrm{Total\_Compression}
=
f_h\cdot f_w\cdot f_t\cdot \frac{3}{c}
$$

这张图里提到的“信息量减少 384 倍”就是这里来的。

### 3.2 Architecture
FSAE 基于 `DC-AE` 改造：
- 从 `dc-ae-f32c32-sana-1.0` 起步；
- 增加 transformer blocks，把 spatial compression 从 `32×32` 提到 `64×64`；
- latent channel 提到 `128`；
- 2D conv 扩展成 causal 3D conv；
- downsample / upsample 使用时空到通道的 sub-pixel 风格操作；
- encoder/decoder 外层 block 加入 temporal reduction，实现 `4×` temporal compression；
- autoencoder attention 只在 height/width 上做，方便 temporal splitting 和 3D tiling。

### 3.3 Training
FSAE 多阶段训练：
- Stage 1：`256×256`，图像 + `17` 帧视频，使用 $L_1$ 和 LPIPS。
- Stage 2：加入 GAN loss，分辨率到 `512×512`，视频到 `61` 帧。
- Stage 3：扩展到 `121` 帧、`1024×1024`。

基本损失：
$$
\mathcal{L}_{ae}
=
\mathcal{L}_1
+0.1\mathcal{L}_{lpips}
+0.1\mathcal{L}_{GAN}
$$

高分辨率阶段使用 mixed-resolution training、decoder patch loss、LPIPS temporal slicing 降低显存。

### 3.4 Video VF Loss
高压缩 latent 不只要重建好，还要适合 DiT 生成。作者提出 `Video Vision Foundation model alignment Loss (Video VF Loss)`，把 latent feature 对齐到 DINOv2 提取的视频视觉特征。

对齐流程：
1. 用 learnable linear 把 latent channel 映射到 DINO feature channel；
2. 空间插值到 DINO feature 分辨率；
3. 对 DINO feature 的 temporal dimension 做 kernel size `4` 的 average pooling，以匹配 FSAE 的时间压缩。

损失包括 Video Marginal Cosine Similarity：
$$
\mathcal{L}_{v\text{-}mcos}
=
\frac{1}{t h' w'}
\sum_{i,j,k}
\mathrm{ReLU}
\left(
1-m_1-
\frac{z_{ijk}\cdot f_{ijk}}{\|z_{ijk}\|\|f_{ijk}\|}
\right)
$$

以及 Video Marginal Distance Matrix Similarity：
$$
\mathcal{L}_{v\text{-}mdms}
=
\frac{1}{(t h'w')^2}
\sum_{p,q}
\mathrm{ReLU}
\left(
\left|
\frac{z_p\cdot z_q}{\|z_p\|\|z_q\|}
-
\frac{f_p\cdot f_q}{\|f_p\|\|f_q\|}
\right|-m_2
\right)
$$

总损失：
$$
\mathcal{L}_{total}
=
\mathcal{L}_{ae}
+
\alpha
\left(
\mathcal{L}_{v\text{-}mcos}
+
\mathcal{L}_{v\text{-}mdms}
\right)
$$

其中 $m_1=0.5$，$m_2=0.25$，$\alpha=0.5$。

实验显示，Video VF Loss 能降低 latent intrinsic dimension，说明 latent manifold 更简单，更适合生成模型学习。

### 3.5 Decoder Improvement
高压缩带来的问题是重建 artifacts 和 decoder 计算开销。作者做了 asymmetric decoder finetune：
- decoder convolution 从 causal 改为 non-causal，减少 frame flickering；
- 从 encoder 的最后 `5` 个 block 提取 first-frame features，通过 cross-attention 注入 decoder；
- 每个 convolution block 注入固定权重 `0.05` 的 Gaussian noise，增强高频细节。

最终有两个版本：
- `FSAE-Standard`: 重建质量最好。
- `FSAE-Lite`: 降低 decoder 后两层 channel，并用 group-causal convolution，显存和推理时间降低约 `1.75-2×`。

### 3.6 VAE Reconstruction
在 `256×256×17` 视频上：
- `FSAE-Standard`, `64×64×4`, `1:384`
  - Inter-4K: `SSIM = 0.806`, `PSNR = 28.96`, `LPIPS = 0.107`, `FVD = 256.62`
  - WebVid-10M: `SSIM = 0.872`, `PSNR = 30.91`, `LPIPS = 0.058`, `FVD = 203.19`
- `FSAE-Lite`
  - Inter-4K: `SSIM = 0.788`, `PSNR = 28.48`, `LPIPS = 0.151`, `FVD = 342.66`
  - WebVid-10M: `SSIM = 0.861`, `PSNR = 30.42`, `LPIPS = 0.075`, `FVD = 240.03`

对比很关键：FSAE 的压缩率是 `1:384`，但重建质量接近或超过一些更低压缩率 VAE。

## 4 DiT with Layer Memory

### 4.1 Motivation
在高度压缩 latent space 中训练 DiT 时，token 数少了，但每个 token 承载的信息更重。为了提升模型容量利用率，FSVideo 沿用 Wan2.1-14B-I2V 的 DiT 结构，并加入 `Layer Memory`。

标准 transformer 第 $l$ 层 self-attention 只用上一层 hidden state：
$$
h_l = \mathrm{SelfAttention}(h_{l-1})
$$

Layer Memory 让每层的 key/value 来自所有前层表示的动态融合。

### 4.2 Inter-Layer Dynamic Router
第 $l$ 层维护一个 router，对 $h_0,\ldots,h_{l-1}$ 输出权重：
$$
R_l(h_{l-1,t})
=
\mathrm{Router}_l(h_{l-1,t})
$$

其中 $h_{l-1,t}$ 是用 diffusion time embedding 调制后的 hidden state。融合表示：
$$
\hat{h}_{l-1}
=
\mathrm{softmax}(R_l(h_{l-1,t}))
\cdot
h_{0:l-1}
$$

然后 self-attention 改成：
$$
Q_l = h_{l-1}W_Q
$$

$$
K_l = \hat{h}_{l-1}W_K
$$

$$
V_l = \hat{h}_{l-1}W_V
$$

也就是说 query 仍来自上一层，但 key/value 可以从所有过去层的加权记忆中生成。

### 4.3 Effect
Layer Memory 的作用：
- 增强 inter-layer information flow；
- 让深层可以直接取回早期低层/高频特征；
- 减少表示塌缩；
- 几乎不增加推理开销，兼容 FlashAttention。

训练曲线显示，加入 Layer Memory 后从头训练 loss 更低；对 Wan2.1 pretrained DiT 做 finetune 时，约 `100` steps 内快速收敛，`1000` steps 后相对 baseline 有最高 `4.7%` 稳定增益。

## 5 Latent Upsampler and Refiner

### 5.1 Latent Upsampler
base DiT 在极压缩 latent 中生成，细节仍会不足。FSVideo 不在 RGB 空间插值，而是在 latent 空间放大：
- 低分辨率视频 $V_{\mathrm{low}}$ 和高分辨率视频 $V_{\mathrm{high}}$ 分别编码为 $Z_{\mathrm{low}}$ 和 $Z_{\mathrm{high}}$；
- latent upsampler 从 $Z_{\mathrm{low}}$ 预测 $\hat{Z}_{\mathrm{high}}$；
- 结构是 projection + pixel shuffle + `16` residual blocks。

训练损失：
$$
\mathcal{L}_{upsampler}
=
\alpha_1\mathcal{L}_{latent\text{-}l1}
+
\alpha_2\mathcal{L}_{l1}
+
\alpha_3\mathcal{L}_{lpips}
$$

其中 $\alpha_1=0.1$，$\alpha_2=0.1$，$\alpha_3$ 从 `0.1` 逐渐增到 `1`。

### 5.2 High-Resolution Refiner
refiner 是一个 video-to-video DiT：以 low-resolution upsampled latent 和 high-resolution first-frame latent 为条件，修复细节和 artifacts。

训练 tricks：
- `Dynamic Masking`: mask 不再是纯 `0/1`，而是根据低分辨率 latent 与 upsampled latent 的偏差估计 confidence。
- `Deviation-Based Latent Estimation`: 构造带控制偏差的 latent condition，避免 refiner 直接复制低质量输入。
- `Condition Dropout`: 随机去掉 low-resolution latent，保留 text-to-video 能力。
- `Frame Shuffle`: 以 `50%` 概率打乱局部相邻帧、非相邻帧或整段 clip，比例 `6:3:1`，让 refiner 学会修 temporal degradation。

refiner 还做了轻量蒸馏：
- 先做 CFG distillation；
- 再 progressive distillation 到 `32` steps；
- 最后用 SiDA 到 `8` steps；
- 推理时间降低 `87%`。

RL 阶段使用 GRPO + MixGRPO sliding window，reward model 是 fine-tuned VideoAlign。

## 6 Experiments

### 6.1 VBench I2V
在 `720×1280` I2V VBench：
- `FSVideo`: `Total = 88.12%`, `I2V = 95.39%`, `Quality = 80.85%`
- `Step-Video-TI2V`: `Total = 88.36%`, `I2V = 95.50%`, `Quality = 81.22%`
- `Wan2.1-I2V-14B-720P`: `Total = 86.86%`, `I2V = 92.90%`, `Quality = 80.82%`
- `DC-VideoGen-Wan-2.1-14B`: `Total = 87.73%`, `I2V = 94.08%`, `Quality = 81.39%`
- `HunyuanVideo-I2V`: `Total = 86.82%`, `I2V = 95.10%`, `Quality = 78.54%`

FSVideo 的质量不是最强，但在开源 I2V 模型里有竞争力，且压缩率远高于其他方法。

### 6.2 Human Evaluation
作者做了 GSB human evaluation：
- FSVideo 大幅优于 HunyuanVideo 和 LTX-Video；
- 与 Wan2.1-14B 基本持平；
- 弱于 Wan2.2-14B/28B MoE。

作者认为 FSVideo 训练数据和训练 compute 仍偏不足，因此还有 scaling 空间。

### 6.3 Inference Speed
评估设置：生成 `5s / 720×1280 / 24fps` 视频，BFloat16，H100，主要统计 DiT inference。

单 GPU：
- `Wan2.1-I2V-14B-720P`: OOM
- `FSVideo`: `76.6s`，需要 parameter offloading

两张 H100：
- `Wan2.1-I2V-14B-720P`: `822.1s`, `60 NFE`
- `FSVideo`: `19.4s`, `68 NFE = 60 base DiT + 8 refiner`
- speedup: `42.3×`

如果不受显存限制的单卡估算：
- `Wan`: `1607.5s`
- `FSVideo`: `27.4s`
- speedup: `58.7×`

这组数字说明：FSVideo 的速度优势不是靠 NFE 更少，而是靠每个 NFE 的 token 和计算量小很多。后续如果再叠加 cache、sparse attention 或更激进 step distillation，理论上可以乘法式加速。

## 7 关键洞察
FSVideo 最值得记住的是它把视频生成加速从“少采样几步”转向“每一步少算很多 token”。

传统视频 VAE 多是 `8×8×4` 或最多 `32×32` 级别压缩；FSVideo 直接上 `64×64×4`，这会极大降低 DiT token 数，但也把压力转移到三个地方：
- autoencoder 必须在高压缩下还能重建；
- latent 必须适合生成，而不只是适合重建；
- DiT 必须有足够容量在小 token 数上建模运动和细节。

FSAE、Video VF Loss、Layer Memory、Refiner 正好分别对应这三个问题。

## 8 和相邻方法的关系

### vs Wan2.1
FSVideo 借鉴 Wan2.1-I2V 的 DiT 结构，但不沿用 Wan VAE 的低压缩 latent。它牺牲一部分架构简单性，换取极大 token reduction。

### vs LTX-Video
LTX-Video 也强调速度和高压缩 latent，但 FSVideo 的 `FSAE-Standard` 在同类高压缩设置下重建指标更好，并且有 Layer Memory 和 refiner 体系。

### vs DC-VideoGen
DC-VideoGen 也探索 deep compression video autoencoder。FSVideo 更进一步尝试从 scratch 在 `64×64×4` highly-compressed latent space 中训练 DiT，并通过 Layer Memory 改善训练。

### vs Step Distillation 路线
Step distillation 减少 NFE；FSVideo 减少每个 NFE 的成本。两者是正交方向，可以叠加。

## 9 Limitations
- 当前主要是 I2V，不是完整 T2V；T2V 可以通过 text-to-image-to-video fallback，但这不是原生 T2V。
- 使用两个 `14B` DiT，单卡显存压力仍高，需要 offloading；真正端到端部署还要继续优化。
- 高压缩 latent 虽然快，但细节依赖 refiner 补回，pipeline 比单模型更复杂。
- 论文承认 FSVideo 训练数据和 compute 不如一些顶级模型，因此质量仍弱于 Wan2.2。

## 10 我的评价
FSVideo 是视频生成系统方向很值得跟的路线：它不是只在 sampler 上挤牙膏，而是重构了 latent space 的计算尺度。`64×64×4` 压缩听起来很激进，但配合 Video VF Loss、Layer Memory 和 refiner 后，确实能把质量拉回可用区间。

这篇对后续视频模型的启发是：VAE/latent design 不只是前处理模块，而是决定 DiT 算力曲线的核心系统设计。未来高速视频生成很可能是“高压缩 latent + 小步数蒸馏 + cache/sparse attention + refiner”的组合拳。

## 相关链接（双向）
- [[Wan2.1]]
- [[LTX-Video]]
- [[Distribution Matching Distillation]]
- [[Video Autoencoder]]
- [[Diffusion Transformer]]
