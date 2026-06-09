---
created: 2026-05-29
type: concept-map
status: 在用
tags: [course, llm-serving, terminology, kv-cache, multi-gpu]
aliases: [KV Cache 术语地图, 多 GPU 推理术语地图]
summary: 多 GPU LLM 推理、KV Cache 后端、通信、缓存、IO 和调度相关术语的学习地图。
---

# 多 GPU 推理与 KV Cache 后端术语地图

## 1. 推理阶段术语

| 术语 | 含义 | 为什么重要 |
|---|---|---|
| Prefill | 一次性处理 prompt，生成初始 KV Cache | 计算密集，影响 TTFT |
| Decode | 每次生成一个或少量 token，并读取历史 KV | 内存/带宽密集，影响 TPOT |
| TTFT | Time To First Token | 用户感知的首 token 延迟 |
| TPOT | Time Per Output Token | 长输出时的核心延迟指标 |
| Continuous batching | 动态把不同请求合并执行 | 提高 GPU 利用率 |
| Admission control | 控制哪些请求进入 batch | 避免显存爆掉或 tail latency 失控 |

## 2. KV Cache 术语

| 术语 | 含义 | 对应优化 |
|---|---|---|
| KV Cache | 每层 attention 保存的历史 Key/Value | 避免重复计算历史 token |
| Cache length | 当前可见历史 token 数 | 决定 decode 读 KV 的规模 |
| KV block/page | KV Cache 的固定大小管理单元 | 减少碎片，支持动态分配 |
| Block table | 逻辑 token 到物理 KV block 的映射表 | 类似 page table |
| Prefix cache | 复用相同 prompt prefix 的 KV | 减少 prefill |
| RadixAttention | 用 radix tree 管理 prefix cache | SGLang 代表机制 |
| PagedAttention | 分页管理 KV Cache 的 attention 机制 | vLLM 代表机制 |
| KV offloading | 把 KV 从 GPU 移到 CPU/SSD/远端 | 支持更长上下文 |
| KV prefetch | 提前把将要用到的 KV 搬回快存储 | 降低 decode 等待 |

## 3. 显存与 IO 术语

| 术语 | 含义 | 在 KV 后端中的作用 |
|---|---|---|
| HBM | GPU 高带宽显存 | decode 读 KV 的主要带宽来源 |
| Pinned memory | 不可换页的 CPU 内存 | GPU/CPU 高效拷贝常用 |
| SSD offload | 把 KV 写到 SSD | 支持超长上下文，但延迟高 |
| RDMA | 绕过 CPU 的远程内存访问 | 跨节点 KV transfer |
| GPUDirect RDMA | NIC 直接访问 GPU memory | 减少 CPU 中转 |
| Fragmentation | 显存碎片 | 降低有效 batch/context 容量 |
| Eviction | 淘汰暂时不用的 KV | 给新请求腾空间 |
| Cache hit rate | cache 命中率 | 决定 offload/prefix cache 是否有效 |

## 4. 多 GPU 通信术语

| 术语 | 含义 | 典型通信 |
|---|---|---|
| Tensor Parallelism | 把单层矩阵计算切到多 GPU | all-reduce / all-gather |
| Pipeline Parallelism | 把不同层放在不同 GPU | 层间 activation 传递 |
| Expert Parallelism | MoE expert 分布在不同 GPU | all-to-all |
| Data Parallelism | 不同 GPU 处理不同请求或 batch | serving 中常配合 routing |
| All-reduce | 多卡求和并广播结果 | TP 常见 |
| All-gather | 收集各卡分片 | TP/sequence parallel 常见 |
| Reduce-scatter | 先 reduce 再分片 | 大模型训练/推理通信优化常见 |
| All-to-all | 每张卡都向其他卡发不同数据 | MoE expert dispatch/combine 常见 |
| RCCL | AMD ROCm 通信库 | 对应 NVIDIA NCCL |

## 5. 量化术语

| 术语 | 含义 | 对 KV Cache 的意义 |
|---|---|---|
| FP16/BF16 | 16-bit 浮点 | 常规推理精度 |
| FP8 | 8-bit 浮点 | 降低显存和带宽 |
| FP4 | 4-bit 浮点 | 更激进压缩，精度风险更高 |
| INT4/INT2 | 低 bit 整数量化 | 常用于极限压缩 |
| Per-token quantization | 每个 token 单独量化 | 适应 token 间尺度变化 |
| Per-channel quantization | 每个 channel 单独量化 | 适应维度间尺度变化 |
| Outlier | 数值特别大的元素 | 低 bit 量化时容易破坏精度 |
| Residual cache | 为误差保留残差或高精度部分 | 改善低 bit 精度 |
| Fused dequant attention | dequant 和 attention 融合 | 降低额外 kernel/访存开销 |

## 6. MoRI-IO 相关术语

| 术语 | 可以怎样理解 |
|---|---|
| MoRI | 面向 RDMA/通信/IO 的模块化推理基础设施 |
| MoRI-IO | 面向 KV Cache transfer、offload、prefetch 的 IO 后端 |
| MoRI-EP | 面向 MoE expert parallelism 的通信优化 |
| Mixed FP4/FP8 communication | 用不同低精度格式压缩通信数据 |
| Network priority | 给 KV transfer、expert traffic 等不同流量分配优先级 |
| Transfer queue | 管理跨 GPU/节点 KV 搬运请求的队列 |

## 7. 常见瓶颈判断

| 现象 | 可能瓶颈 | 优先检查 |
|---|---|---|
| GPU 利用率低，但请求很多 | scheduler / communication wait | trace、batch 组成、通信时间 |
| decode 很慢，HBM 带宽高 | KV read memory-bound | KV layout、quantization、attention kernel |
| 显存很快爆 | KV Cache 过大或碎片严重 | block size、paging、offload |
| TTFT 很高 | prefill 太慢或排队太久 | prefill worker、prefix cache、admission control |
| TPOT 很高 | decode 读 KV/通信慢 | HBM、RCCL/NCCL、KV locality |
| 长上下文 tail latency 高 | offload/prefetch 不稳 | cache hit rate、transfer queue、eviction |
| MoE 模型波动大 | expert load imbalance | router 分布、all-to-all 时间 |

## 8. 看到一个优化方法时的定位模板

用下面五问快速定位它：

1. 它发生在 prefill、decode、cache、communication、IO 还是 scheduler？
2. 它减少了哪个量：显存、HBM 读写、网络字节、重复计算、等待时间？
3. 它改变了哪个数据结构：block table、radix tree、transfer queue、eviction list？
4. 它会不会引入精度损失、metadata 开销或额外 kernel？
5. 它最应该看哪个指标：TTFT、TPOT、throughput、cache hit rate、GPU utilization、TCO？
