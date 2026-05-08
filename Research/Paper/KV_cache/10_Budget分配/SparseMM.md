---
created: 2026-04-09
published: 2025-06-05
type: paper
status: 未读
tags: [SparseMM, KVCache, MLLM, VisionLanguage]
aliases: [SparseMM]
summary: "揭示 MLLM 视觉头稀疏性，并据此做头级非对称 KV 预算，提升多模态推理效率。"
pdf-url: Attachments/arxiv_2506.05344.pdf
source-url:
  - https://arxiv.org/abs/2506.05344
  - Attachments/arxiv_2506.05344.pdf
  - https://github.com/CR400AF-A/SparseMM
---

# SparseMM: Head Sparsity Emerges from Visual Concept Responses in MLLMs

## PDF
- [[Attachments/arxiv_2506.05344.pdf]]

## Abstract
论文研究 MLLM 的一个核心事实：并非所有注意力头都真正参与视觉理解。作者通过头级响应分析发现，视觉相关头（visual heads）在 LLM 内部高度稀疏，通常不到 5%。基于这一发现，SparseMM 提出按视觉分数为不同头分配非对称 KV cache 预算，在保持视觉语义的同时压缩冗余缓存。论文报告其在多模态基准上取得更优的精度-效率折中，并给出 1.38x 实时加速和约 52% 内存下降。

## 1 Introduction
SparseMM 的出发点是：现有 MLLM 多由 LLM 加视觉编码器/适配器扩展而来，但“LLM 在视觉指令微调后到底学到了什么”并不清楚。作者认为，这种机制不透明会直接影响 KV 压缩策略设计。

论文提出两个关键观察：
- `Sparsity`：真正处理视觉语义的注意力头只占极少数（<5%）。
- `Universality`：该现象在不同骨干和不同注意力机制（MHA/GQA）下都存在。

在此基础上，论文将问题转化为一个部署导向目标：既然视觉头稀疏，就不该给所有头平均分配 KV 预算，而应优先保障视觉关键头。

## 2 Related Works
作者把相关工作分为三类：
- MLLM 架构线：ViT/CLIP/SigLIP + Adapter + LLM 的主流方案。
- 长上下文/推理加速线：LLM 侧 KV 压缩方法（StreamingLLM、H2O、SnapKV、PyramidKV、AdaKV 等）。
- 多模态加速线：如视觉 token 剪枝、弹性缓存策略。

SparseMM 的差异化点是：不是只在 token 维度或层维度压缩，而是显式引入“头级视觉相关性”来指导 KV 预算。

## 3 Visual Heads are Sparse in MLLMs

### 3.1 What is Learned during Visual Instruct Tuning
论文先重述 MLLM 的条件语言建模形式：
$$
p_{\theta}(\mathbf{x})=\prod_{i=1}^{N}p_{\theta}(\mathbf{x}_i\mid \mathbf{x}_{<i}, \mathbf{v}),\quad \mathbf{v}=H(E(\text{Image}))
$$
训练目标为标准条件交叉熵：
$$
\mathcal{L} = -\frac{1}{N-P}\sum_{i=P+1}^{N}\log p_{\theta}(\mathbf{x}_i\mid \mathbf{x}_{<i}, \mathbf{v})
$$

作者的核心问题是：视觉能力是否平均分布在所有头上？实验结论是否定的，只有少数头在视觉对齐中持续活跃。

### 3.2 Chasing Visual Heads in MLLMs
论文设计了一个训练免费的 visual head 识别流程（基于 OCR 对齐）：
1. 对每个输出 token $y_i$，用 OCR 的 `(text, bbox)` 找到对应图像区域。
2. 将 bbox 映射到输入 image tokens 集合 $I_{y_i}$。
3. 检查某头注意力矩阵 $A_h$ 的 argmax 是否落在 $I_{y_i}$。

头的视觉分数定义为：
$$
\text{Visual Score}(h)=\frac{1}{N}\sum_{i=1}^{N}\frac{\mathbb{I}_{hit(y_i,A_h)}}{\#\text{image\_tokens}}
$$
其中
$$
hit(y_i,A_h)=
\begin{cases}
1, & \arg\max(A_h)\in I_{y_i}\\
0, & \text{else}
\end{cases}
$$

作者在 1000 张 Synthdog 样本上聚合得分并可视化，显示高分头非常稀疏。

### 3.3 Exploring Head Sparsity for Acceleration
SparseMM 的预算分配是“三段式”：

1. `Local Window Cache`：每头先保留固定近邻窗口 $w$（默认 32）。
2. `Uniform-Based Cache`：从剩余预算中拿比例 $\rho$（默认 0.1）给所有头均分，保证每头都有最低预算。
3. `Score-Preferred Cache`：再按 visual score 比例分配其余预算，给视觉头更多缓存。

主要公式如下：
$$
B_{\text{remain1}} = B - N\cdot w
$$
$$
r = \frac{\rho\cdot(B-N\cdot w)}{N}
$$
$$
B_{\text{remain2}} = B - N\cdot w - \rho(B-N\cdot w)
$$
$$
b_{ij}^{\text{score}} = B_{\text{remain2}}\cdot \frac{s_{ij}}{\sum_{i=1}^{L}\sum_{j=1}^{H}s_{ij}}
$$
$$
b_{ij}=w+r+b_{ij}^{\text{score}}
$$

在具体筛选时，论文沿用 observation window 思路（受 SnapKV 启发），仅用末端窗口的 attention 做聚合评分并选 top-K。

## 4 Experiments

### 4.1 Experimental Settings
- 模型：LLaVA-NeXT-Vicuna-7B（MHA）、LLaVA-NeXT-Mistral-7B（GQA）、Qwen2-VL-7B（GQA）。
- 基线：SnapKV、PyramidKV、AdaKV，另设 Random Head 对照。
- 数据集：DocVQA、OCRBench、TextVQA、ChartQA、TextCaps，以及 MMBench/VQAv2 等。
- 预算：主实验 head budget 采用 `{64,128,256,512,1024,2048}`（通用视觉基准用更小预算段）。

### 4.2 Results on Multi-Modal Benchmarks
论文在多个模型上展示了“低预算保持性能”的优势，重点结论包括：
- 在 TextVQA（LLaVA-NeXT-Vicuna-7B）上，budget=256（约占平均输入 token 的 10.77%）可达到接近 full-cache 表现，而若干基线约有 3% 精度损失。
- 在 OCRBench（LLaVA-NeXT-Mistral-7B）上，budget=128（约占平均输入 token 的 7.5%）仅轻微退化，而对比方法可超过 10% 下降。
- 在 DocVQA（Qwen2-VL-7B）上，budget=256（约占平均输入 token 的 5.3%）仍能维持接近满缓存表现，其他方法下降约 5%–17%。

在多选题视觉基准上，论文报告 budget=96 时可在 MMBench 基本保持满性能，且在 GQA/VQAv2 上下降小于 1%。

### 4.3 Efficiency Evaluation
在 FlashAttention 下，固定输出长度并比较不同输入长度（2K 到 32K）：
- 解码速度：8K 输入约 1.16x 加速，32K 输入约 1.87x。
- 内存：以 LLaVA-NeXT-Vicuna-7B 为例，32K 输入从 32.87GB 降到 17.38GB，接近 50% 降幅。

论文还给出 accuracy-speed 对比（16K 输入，budget=256）：
- FullKV：52.9ms。
- SparseMM：37.1ms（约 -30%），且五项任务精度几乎与 FullKV 持平。
- 其他基线虽然延迟相近/更低，但精度掉点更明显。

### 4.4 Analysis
作者做了几组关键分析：
- `Masking`：屏蔽高分 visual heads 会引发显著性能下降，随机屏蔽同等比例头影响更小，证明 visual heads 的关键性。
- `Robustness`：在不同 OCR 数据上识别到的 visual heads 分布较稳定，跨任务迁移有效；相较目标检测式对齐，OCR 对齐更鲁棒。
- `Ablation of rho`：$\rho=0.1$ 通常最优；$\rho=0$ 容易让部分头无缓存可用，性能显著恶化，说明 Uniform-Based Cache 是必要组件。
- `Ablation of 3-part allocation`：三段式（Local + Uniform + Score-Preferred）优于任意删减版本。

## 5 Conclusion
SparseMM 的核心贡献是把“视觉头稀疏”从解释性观察转化为可部署的 KV 压缩策略：以头级视觉相关性驱动非对称预算分配，在多模态理解任务上显著改善低预算场景下的精度-效率折中。

## Appendix
附录补充了：
- GQA 下 visual score 与 KV 预算映射的实现细节。
- 更完整的可视化与数值结果。
- 超参数和预算分配消融（特别是 $\rho$）。

## 相关链接（双向）
- [[KV Cache]]
- [[SnapKV✅]]
- [[PyramidKV✅]]
- [[AdaKV]]
