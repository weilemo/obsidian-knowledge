---
created: 2026-04-08
published: 2020-05-22
type: paper
status: 已读
tags: [RAG, RetrievalAugmentedGeneration, DenseRetrieval, KnowledgeIntensiveNLP, Seq2Seq]
aliases: [Retrieval-Augmented Generation, RAG, Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks]
summary: "提出 RAG：将可微稠密检索器与生成模型联合训练，在开放域问答、摘要、事实验证等知识密集任务中显著提升表现。"
pdf-url: "Attachments/arxiv_2005.11401.pdf"
source-url:
  - https://arxiv.org/abs/2005.11401
  - https://arxiv.org/html/2005.11401v4
  - https://arxiv.org/pdf/2005.11401.pdf
---

# Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks

## PDF
- [[Attachments/arxiv_2005.11401.pdf]]

## Abstract
本文提出 Retrieval-Augmented Generation（RAG）框架，把参数化记忆（seq2seq 生成器参数）与非参数化记忆（外部文档库）结合起来。模型先对输入进行稠密检索，再基于检索文档生成答案；检索与生成可端到端联合优化。论文在开放域问答、抽象式问答、问题生成和事实验证等知识密集任务上验证了该方法的有效性，并显示出比纯参数化生成模型更好的事实性与可更新性。

## 1 Introduction
作者指出：仅依赖参数化记忆的大模型在知识密集任务上存在事实性不足、知识更新困难、可解释性弱的问题。RAG 的核心目标是：
- 在生成时动态访问外部知识；
- 同时保留生成模型在自然语言输出上的优势；
- 通过端到端训练让“检索什么”和“如何生成”共同适配下游任务。

## 2 Methods

### 2.1 Models
RAG 在输入 $x$ 下先检索 top-$K$ 文档，再做条件生成。论文给出两种变体。

RAG-Sequence（整段输出共享同一检索文档）可写为：
$$
p_{\text{RAG-Seq}}(y\mid x)=\sum_{z\in\text{top-}K\,p_\eta(\cdot\mid x)} p_\eta(z\mid x)\prod_{i=1}^{N}p_\theta(y_i\mid x,z,y_{1:i-1})
$$

RAG-Token（每个 token 可切换检索文档）可写为：
$$
p_{\text{RAG-Token}}(y\mid x)=\prod_{i=1}^{N}\sum_{z_i\in\text{top-}K\,p_\eta(\cdot\mid x)}p_\eta(z_i\mid x)p_\theta(y_i\mid x,z_i,y_{1:i-1})
$$

其中 $p_\eta$ 是检索分布，$p_\theta$ 是生成分布。

### 2.2 Retriever: DPR
检索器使用 DPR（Dense Passage Retriever）风格的双编码器：
- 查询编码器把输入 $x$ 映射为向量；
- 文档编码器把语料库文档映射为向量；
- 通过最大内积检索 top-$K$ 文档。

论文中为了效率通常固定文档向量索引，仅更新查询编码器参数，使检索器在下游任务上可学习地偏向“有助于生成”的文档。

### 2.3 Generator: BART
生成器基于 BART（seq2seq Transformer）。输入由“原始 query + 检索文档”拼接构成，输出目标序列。这样模型既可利用语言建模能力，也能借助检索到的事实证据。

### 2.4 Training
训练目标是最大化目标序列似然（负对数似然最小化），检索器与生成器联合学习。直观上，若某文档有助于更高似然生成正确答案，该文档在 $p_\eta$ 中权重会增大。

### 2.5 Decoding
推理阶段使用 beam search。RAG-Sequence 与 RAG-Token 在解码时的边际化方式不同：
- Sequence 版本更稳定、实现更简单；
- Token 版本更灵活，但计算与搜索更复杂。

## 3 Experiments

### 3.1 Open-domain Question Answering
任务覆盖 Natural Questions、TriviaQA、WebQuestions、CuratedTREC 等开放域 QA。核心比较对象包括 DPR、REALM 以及纯参数化生成模型。

### 3.2 Abstractive Question Answering
在 MS-MARCO NLG 等任务上评估生成式答案质量，关注语义覆盖与事实正确性，而非仅抽取式匹配。

### 3.3 Jeopardy Question Generation
把“答案”映射到“问题”的生成任务用于测试模型对知识的组织与表达能力。

### 3.4 Fact Verification
在 FEVER 上评估事实判断能力，观察检索增强是否能提高事实一致性与可验证性。

## 4 Results

### 4.1 Open-domain Question Answering
RAG 在多个开放域 QA 基准上优于当时强基线。论文结论强调：检索增强的生成模型相比纯参数化模型更擅长处理知识密集型问答。

### 4.2 Abstractive Question Answering
RAG 在抽象式问答上取得更好的自动指标和内容质量，显示“检索证据 + 生成表达”的组合优势。

### 4.3 Jeopardy Question Generation
RAG 能生成信息更充分、知识相关性更高的问题，体现外部记忆对生成多样性和准确性的帮助。

### 4.4 Fact Verification
在事实验证任务中，RAG 的证据检索能力帮助模型做出更可靠判断，整体优于不带检索的生成式方案。

### 4.5 Additional Results
论文还分析了：
- 不同检索文档数 $K$ 对性能的影响；
- 检索质量与生成质量之间的耦合关系；
- 检索增强对输出事实性的贡献。

## 5 Related Work
作者将 RAG 与三类方向关联：
- 稠密检索与开放域问答（如 DPR/REALM）；
- 预训练生成模型（如 BART/T5）；
- 非参数化记忆增强模型。

RAG 的贡献在于把检索与生成统一到一个可端到端优化框架中。

## 6 Discussion
论文强调 RAG 的实用价值：
- 知识可更新：更新索引即可注入新知识；
- 结果可解释：可回溯到检索文档；
- 泛化更强：在多类知识任务上受益。

同时也存在限制：检索误差会直接传递到生成阶段；索引构建与检索基础设施有额外工程成本。

## Broader Impact
正向影响：有助于提升知识密集任务质量，降低模型“幻觉”风险。潜在风险：若检索语料含偏见或错误，可能被放大到生成输出中。

## Acknowledgments
论文在该节致谢协作与支持团队。

## 相关链接（双向）
- [[RAG]]
- [[Dense Retrieval]]
- [[Open-domain QA]]
