# 扩散模型采样器（ODE / SDE）研究地图与主流论文

## 这属于 AI 研究的什么部分？

这条线更准确地属于：

- 生成式模型（Generative Models）
- 扩散模型（Diffusion Models）
- 采样 / 推理算法（Sampling / Inference Algorithms）

如果再细一点，它处在 **扩散模型推理加速** 与 **数值微分方程求解** 的交叉位置。  
也可以把它理解成：

- 机器学习侧：如何用更少步数、更稳定地从扩散模型中采样
- 数值计算侧：如何更好地求解扩散模型对应的 ODE 或 SDE

因此，这个主题不应只归到 `ImageGen` 或 `VideoGen`，因为它本质上是 **跨模态的扩散推理基础设施**，图像、视频、音频、3D 都会复用。

## 推荐目录结构

```text
DiffusionSampler/
  00_地图与综述/
  10_基础理论/
  20_ODE采样器/
  30_SDE采样器/
  40_高阶与工程常用采样器/
```

## 一张总图

扩散模型采样器大致可以分成两层：

1. 理论母类
   - Reverse-time SDE
   - Probability Flow ODE
2. 具体采样器家族
   - DDPM / ancestral sampling
   - DDIM
   - PNDM / PLMS
   - Euler / Euler ancestral / Heun
   - DEIS
   - DPM-Solver / DPM-Solver++
   - UniPC

可以把这条发展线理解为：

$$
\text{DDPM} \rightarrow \text{Score SDE / Probability Flow ODE} \rightarrow \text{DDIM / PNDM / Euler / DPM-Solver / UniPC}
$$

## 基础理论母类

### 1. DDPM：离散扩散采样起点

- 论文：[[Denoising Diffusion Probabilistic Models]]
- 原文：[arXiv:2006.11239](https://arxiv.org/abs/2006.11239)
- 作者：Jonathan Ho, Ajay Jain, Pieter Abbeel
- 时间：2020

意义：

- 奠定了离散扩散模型的标准采样过程
- 很多后来的“ancestral / stochastic”采样都可以追溯到它

### 2. Score SDE：把扩散统一到 SDE / ODE 视角

- 论文：[[Score-Based Generative Modeling through Stochastic Differential Equations]]
- 原文：[arXiv:2011.13456](https://arxiv.org/abs/2011.13456)
- 作者：Yang Song, Jascha Sohl-Dickstein, Diederik P. Kingma, Abhishek Kumar, Stefano Ermon, Ben Poole
- 时间：2020，ICLR 2021

意义：

- 给出 **reverse-time SDE**
- 给出与之等价的 **probability flow ODE**
- 提出 **predictor-corrector sampler**
- 后续大量 ODE sampler 都是在更高效地解这条 ODE

## ODE 采样器主线

### 3. DDIM

- 论文：[[Denoising Diffusion Implicit Models]]
- 原文：[OpenReview](https://openreview.net/forum?id=St1giarCHLP)
- 作者：Jiaming Song, Chenlin Meng, Stefano Ermon
- 时间：ICLR 2021

关键词：

- deterministic sampling
- non-Markovian diffusion
- fast sampling

意义：

- 最经典的 ODE-like 快速采样器之一
- 让扩散采样首次大幅减少步数，成为后续快速采样工作的关键起点

### 4. DEIS

- 论文：[[Fast Sampling of Diffusion Models with Exponential Integrator]]
- 原文：[arXiv:2204.13902](https://arxiv.org/abs/2204.13902)
- 作者：Qinsheng Zhang, Yongxin Chen
- 时间：2022

关键词：

- exponential integrator
- probability flow ODE

意义：

- 把扩散 ODE 写成更适合指数积分器处理的形式
- 是少步数高质量 ODE 采样的重要路线

### 5. DPM-Solver

- 论文：[[DPM-Solver-A-Fast-ODE-Solver-for-Diffusion-Probabilistic-Model-Sampling-in-Around-10-Steps]]
- 原文：[arXiv:2206.00927](https://arxiv.org/abs/2206.00927)
- 作者：Cheng Lu, Yuhao Zhou, Fan Bao, Jianfei Chen, Chongxuan Li, Jun Zhu
- 时间：NeurIPS 2022

关键词：

- high-order ODE solver
- 10-step sampling

意义：

- 现在最核心的高阶 ODE sampler 家族之一
- 很多工程实现中的 `DPM` 系列采样器都可以追到它

### 6. DPM-Solver++

- 论文：[[DPM-Solver++-Fast-Solver-for-Guided-Sampling-of-Diffusion-Probabilistic-Models]]
- 原文：[arXiv:2211.01095](https://arxiv.org/abs/2211.01095)
- 作者：Cheng Lu, Yuhao Zhou, Fan Bao, Jianfei Chen, Chongxuan Li, Jun Zhu
- 时间：2022

关键词：

- guided sampling
- classifier-free guidance

意义：

- 面向 guided diffusion 的实用增强版
- 很多 WebUI / A1111 / ComfyUI 里的 `DPM++ 2M`、`DPM++ SDE` 都属于这条家族

### 7. UniPC

- 论文：[[UniPC-A-Unified-Predictor-Corrector-Framework-for-Fast-Sampling-of-Diffusion-Models]]
- 原文：[arXiv:2302.04867](https://arxiv.org/abs/2302.04867)
- 作者：Wenliang Zhao, Lujia Bai, Yongming Rao, Jie Zhou, Jiwen Lu
- 时间：2023

关键词：

- unified predictor-corrector
- arbitrary-order solver

意义：

- 少步数场景下很强
- 可以看作对现有 ODE sampler 的统一提升框架

## SDE 采样器主线

### 8. Reverse-time SDE sampler

- 核心论文：[[Score-Based Generative Modeling through Stochastic Differential Equations]]
- 原文：[arXiv:2011.13456](https://arxiv.org/abs/2011.13456)

关键词：

- VE-SDE
- VP-SDE
- sub-VP SDE

意义：

- 这是最正统的 **SDE sampler** 来源
- 如果一个库里直接写 `ScoreSdeVe`、`ScoreSdeVp`，大概率就是这条路线

### 9. Predictor-Corrector sampler

- 核心论文：同上 [Score SDE](https://arxiv.org/abs/2011.13456)

意义：

- predictor 负责推进反向过程
- corrector 通常用 Langevin-like 修正步骤减小误差
- 是最经典的 SDE 采样框架之一

## 高阶与工程常用采样器

### 10. PNDM / PLMS

- 论文：[[Pseudo Numerical Methods for Diffusion Models on Manifolds]]
- 原文：[OpenReview](https://openreview.net/forum?id=PlKWVd2yBkY)
- 作者：Luping Liu, Yi Ren, Zhijie Lin, Zhou Zhao
- 时间：ICLR 2022

意义：

- 早期非常主流的快速采样方法
- 把扩散采样视作流形上的伪数值方法

### 11. Euler / Heun / Karras 风格采样

- 代表论文：[[Elucidating the Design Space of Diffusion-Based Generative Models]]
- 原文：[arXiv:2206.00364](https://arxiv.org/abs/2206.00364)
- 作者：Tero Karras, Miika Aittala, Timo Aila, Samuli Laine
- 时间：NeurIPS 2022

意义：

- 这篇没有“发明”Euler 或 Heun 这些经典数值方法本身
- 但它系统化了扩散模型里的 **sigma schedule + sampler design**
- 工程里大量常见的 `Euler`、`Heun`、`Karras` 变体，基本都绕不开这篇

### 12. Euler ancestral（Euler a）

归类建议：

- 更适合作为 **EDM / k-diffusion 工程家族** 下的实用变体来理解
- 它是现在图像生成 UI 中非常常见的 stochastic sampler
- 但通常不把它单独当作“一篇新论文首次提出的理论方法”来记

## 一张对照表

| 名称 | 类型 | 是否随机 | 代表论文 |
| --- | --- | --- | --- |
| DDPM | 离散扩散 | 是 | [DDPM](https://arxiv.org/abs/2006.11239) |
| DDIM | ODE-like | 否，可扩展 | [DDIM](https://openreview.net/forum?id=St1giarCHLP) |
| Reverse SDE | SDE | 是 | [Score SDE](https://arxiv.org/abs/2011.13456) |
| Predictor-Corrector | SDE | 是 | [Score SDE](https://arxiv.org/abs/2011.13456) |
| PNDM / PLMS | 高阶离散 / ODE风格 | 通常否 | [PNDM](https://openreview.net/forum?id=PlKWVd2yBkY) |
| Euler | ODE | 否 | [EDM](https://arxiv.org/abs/2206.00364) |
| Euler a | SDE-like / ancestral | 是 | [EDM](https://arxiv.org/abs/2206.00364) |
| Heun | ODE | 否 | [EDM](https://arxiv.org/abs/2206.00364) |
| DEIS | ODE | 否 | [DEIS](https://arxiv.org/abs/2204.13902) |
| DPM-Solver | 高阶 ODE | 否 | [DPM-Solver](https://arxiv.org/abs/2206.00927) |
| DPM-Solver++ | 高阶 ODE | 可含 SDE 变体 | [DPM-Solver++](https://arxiv.org/abs/2211.01095) |
| UniPC | 统一 PC / 高阶 ODE | 通常否 | [UniPC](https://arxiv.org/abs/2302.04867) |

## 研究脉络总结

如果按科研脉络来理解，这条线大致是：

1. **DDPM** 建立离散扩散采样范式
2. **Score SDE** 把问题统一到反向 SDE 与 probability flow ODE
3. **DDIM** 首次显著加速 deterministic sampling
4. **PNDM / DEIS / DPM-Solver** 开始系统引入高阶数值求解器
5. **EDM** 把工程中最好用的 sampler 设计系统化
6. **DPM-Solver++ / UniPC** 成为当前最常见、最实用的快速采样路线

## 如果要继续拆成单篇笔记，建议优先顺序

### 基础必读

- [[Denoising Diffusion Probabilistic Models]]
- [[Score-Based Generative Modeling through Stochastic Differential Equations]]
- [[Denoising Diffusion Implicit Models]]

### 快速采样主线

- [[Pseudo Numerical Methods for Diffusion Models on Manifolds]]
- [[Elucidating the Design Space of Diffusion-Based Generative Models]]
- [[DPM-Solver-A-Fast-ODE-Solver-for-Diffusion-Probabilistic-Model-Sampling-in-Around-10-Steps]]
- [[DPM-Solver++-Fast-Solver-for-Guided-Sampling-of-Diffusion-Probabilistic-Models]]
- [[UniPC-A-Unified-Predictor-Corrector-Framework-for-Fast-Sampling-of-Diffusion-Models]]

## 一个简短结论

扩散模型采样器研究，属于 **生成式 AI 中的扩散模型推理加速与数值采样方法**。  
它的理论核心是：

$$
\text{How to solve the reverse diffusion process more accurately and with fewer steps?}
$$

而当前最值得重点跟踪的主线，是：

$$
\text{DDIM} \rightarrow \text{PNDM / EDM} \rightarrow \text{DPM-Solver / DPM-Solver++ / UniPC}
$$
