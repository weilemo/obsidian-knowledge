---
created: 2026-05-29
type: resources
status: 在用
tags: [course, llm-serving, resources, kv-cache, gpu-systems]
aliases: [LLM Serving 资源索引]
summary: LLM Serving Systems 课程的课程、论文、系统文档和实践资源索引。
---

# LLM Serving Systems 资源索引

## 1. 基础课程

### 并行计算 / GPU 系统

- Stanford CS149 Parallel Computing  
  重点：parallel thinking、locality、GPU、performance analysis。

- CMU 15-418/15-618 Parallel Computer Architecture and Programming  
  重点：CUDA、GPU memory hierarchy、parallel deep learning、同步与通信。

### 数据库 / 缓存 / IO

- CMU 15-445 Database Systems  
  重点：storage、buffer pool、page、concurrency、query execution。

- 操作系统课程中的 virtual memory / page replacement / IO scheduling  
  重点：把 KV Cache offload 理解成一种分层存储管理。

## 2. LLM Serving 系统

- vLLM  
  重点：PagedAttention、continuous batching、KV block 管理。

- SGLang  
  重点：RadixAttention、prefix cache、HiCache、PD disaggregation、quantized KV cache。

- TensorRT-LLM  
  重点：kernel fusion、inflight batching、多 GPU serving。

- LMCache  
  重点：KV Cache reuse、offload、跨请求/跨会话缓存。

- Mooncake  
  重点：KV-centric serving、prefill/decode disaggregation、KV transfer。

- AMD MoRI / MoRI-IO / MoRI-EP  
  重点：RDMA primitives、KV transfer、MoE expert parallel communication、网络优先级。

## 3. 论文主题清单

### KV Cache 管理

- vLLM / PagedAttention。
- SGLang / RadixAttention。
- CacheGen。
- ChunkAttention。

### 分层缓存与 IO

- LMCache。
- Mooncake。
- HiCache。
- Strata。
- KVFlow。

### KV Cache 量化

- KIVI。
- KVQuant。
- GEAR。
- ZipCache。
- MiniCache。
- QServe / Atom / SmoothQuant 作为权重量化和激活量化背景。

### Prefill-Decode Disaggregation

- DistServe。
- Splitwise。
- SGLang PD disaggregation。
- Mooncake。

### MoE Serving 与通信

- MegaBlocks。
- Tutel。
- DeepSpeed MoE。
- DeepEP。
- MoRI-EP。

### Speculative Decoding / MTP

- Speculative decoding。
- Medusa。
- EAGLE。
- MTP。
- ROCm Specv2 MTP。

## 4. 实践任务索引

### Task 1: KV Cache 大小估算器

输入模型参数：

- $L$：层数。
- $B$：batch size。
- $S$：上下文长度。
- $H_{kv}$：KV head 数。
- $D_{head}$：head dim。
- $\text{bytes\_per\_elem}$：每个元素字节数。

输出：

$$
\text{KV bytes}
=
2 \times L \times B \times S \times H_{kv} \times D_{head} \times \text{bytes\_per\_elem}
$$

### Task 2: Attention benchmark

目标：

- 比较不同 $S$ 下 decode attention 的时间。
- 观察显存带宽是否成为瓶颈。
- 比较 FP16、FP8、INT4/FP4 KV 的读写差异。

### Task 3: vLLM/SGLang 源码阅读

目标：

- 找到 KV block allocator。
- 找到 scheduler。
- 找到 prefix cache 或 radix cache。
- 找到 quantized KV cache 的 kernel/backend 调用路径。

### Task 4: 简化版 KV Cache 后端设计

设计：

- GPU cache。
- CPU cache。
- transfer queue。
- eviction policy。
- prefetch policy。
- metadata table。

目标：

> 能解释一个 KV block 从生成、命中、淘汰、远端迁移、再读回的完整生命周期。

## 5. 和本地研究的连接

这门课可以和以下方向连接：

- 长视频生成中的 rolling KV cache。
- KV Cache quantization。
- head-wise mixed precision。
- long context serving。
- DeepSeek-R1 / MoE serving。
- SGLang、MoRI、ROCm、AMD MI 系列 GPU 推理优化。
