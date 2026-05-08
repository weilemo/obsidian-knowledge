---
created: 2026-04-10
tags: [railway, paas, deploy, infra]
source-url: https://docs.railway.com/
---

# Railway 使用说明（从 0 到可上线）

## 1. Railway 是什么
Railway 是一个一体化云部署平台，核心能力是：
- 部署应用（支持 GitHub、CLI、Docker Image）
- 配置运行环境（变量、域名、私网、卷、数据库）
- 提供可观测性（Logs、Metrics、Observability Dashboard）

参考：
- https://docs.railway.com/
- https://docs.railway.com/quick-start

## 2. 快速上手（官方 Quick Start 结构）
官方 Quick Start 将入门分成两类：
- 部署你的项目（GitHub / CLI / Docker Image）
- 部署模板（Template Marketplace）

### 2.1 从 GitHub 部署
1. 进入 Railway Dashboard，新建 Project。
2. 选择 `Deploy from GitHub repo`。
3. 选择仓库后可选：`Deploy Now` 或先 `Add Variables`。
4. 首次部署完成后，在服务设置里 `Generate Domain` 暴露公网访问地址。

参考：
- https://docs.railway.com/quick-start
- https://docs.railway.com/networking/domains/working-with-domains

### 2.2 用 CLI 部署
最简流程：
```bash
railway login
railway init
railway up
```

说明：
- `railway up` 会扫描并上传项目文件，构建后部署。
- 可在 Dashboard 或 `railway logs` 看部署日志。

参考：
- https://docs.railway.com/cli
- https://docs.railway.com/cli/deploying

## 3. CLI 实战要点
### 3.1 安装与认证
CLI 支持 Homebrew / npm / Scoop / shell script / binary 安装。
CI/CD 场景建议使用 token：
- `RAILWAY_TOKEN`：项目级动作
- `RAILWAY_API_TOKEN`：账号/工作区级动作

参考：
- https://docs.railway.com/cli

### 3.2 部署模式
`railway up` 支持三种典型模式：
- Attached（默认）：终端实时跟踪构建+部署日志
- Detached（`-d`）：上传后立即返回，后台继续部署
- CI（`-c`）：只输出构建日志并在构建完成后退出

参考：
- https://docs.railway.com/cli/deploying

## 4. 变量管理（Variables）
变量在 Railway 中会注入到：
- 构建阶段
- 运行阶段
- `railway run <COMMAND>`
- `railway shell`

关键点：
- 变量变更会形成 `staged changes`，需要 review + deploy 才生效。
- 支持 Service Variables 与 Shared Variables。
- 支持从仓库 `.env*` 自动建议导入。
- 支持 Sealed Variables（值对 UI/API 不可见，但构建/运行可用）。

参考：
- https://docs.railway.com/variables
- https://docs.railway.com/deployments

## 5. 网络与域名
### 5.1 公网域名
Railway 支持：
- 平台域名：`*.up.railway.app`
- 自定义域名（自动签发 SSL）

自定义域名流程：添加域名 -> 按提示配置 CNAME -> 等待校验（文档提示全球传播最长可到 72 小时）。

提示：
- 如果服务绑定了 TCP Proxy，可能看不到 `Generate Domain`，需先移除代理。
- Trial/Hobby/Pro 自定义域名配额不同，按当前计划限制执行。

参考：
- https://docs.railway.com/networking/domains/working-with-domains
- https://docs.railway.com/pricing/plans

### 5.2 私有网络（服务间通信）
同一项目环境下，服务可直接通过内部 DNS 通信：
- `SERVICE_NAME.railway.internal`

特性：
- 零配置发现
- Wireguard 加密
- 不暴露公网
- 环境隔离

参考：
- https://docs.railway.com/networking/private-networking

## 6. 数据与持久化
### 6.1 Volumes（持久卷）
Volume 绑定后，挂载路径会在容器内作为可读写目录。
例如应用写 `./data`，建议挂载到 `/app/data` 以持久化相对路径数据。

运行时自动提供：
- `RAILWAY_VOLUME_NAME`
- `RAILWAY_VOLUME_MOUNT_PATH`

参考：
- https://docs.railway.com/volumes

### 6.2 PostgreSQL
Railway PostgreSQL 模板可快速拉起数据库服务，应用通常通过以下变量连接：
- `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`, `DATABASE_URL`

说明：
- 跨项目外部连接可用 TCP Proxy（默认开启），但会产生 Network Egress 计费。
- 生产环境建议结合 Backups 与 Observability 做可靠性保障。

参考：
- https://docs.railway.com/databases/postgresql
- https://docs.railway.com/volumes
- https://docs.railway.com/observability

## 7. 构建、部署与可观测性
### 7.1 构建与部署
- Railway 默认零配置构建，但可自定义 build/start/pre-deploy。
- 构建引擎 Railpack 会自动识别语言框架并打包镜像。
- 若仓库已有 Dockerfile，Railway 可直接使用。

参考：
- https://docs.railway.com/builds
- https://docs.railway.com/builds/railpack
- https://docs.railway.com/deployments

### 7.2 日志与指标
Logs 支持三种入口：
- Deploy 面板
- Observability（Log Explorer）
- `railway logs`

Metrics 默认提供：
- CPU
- Memory
- Disk Usage
- Network

图表可看部署切换点，且支持多副本 Sum/Replica 两种视图。

参考：
- https://docs.railway.com/observability/logs
- https://docs.railway.com/observability/metrics
- https://docs.railway.com/observability

## 8. 定价理解（简版）
官方说明为“订阅费 + 用量计费”，常见计划：Free / Hobby / Pro / Enterprise。
文档示例订阅价：
- Free: $0/月
- Hobby: $5/月
- Pro: $20/月
- Enterprise: 定制

注意：配额（副本、CPU、内存、存储、域名上限）随计划变化，且可能更新，执行前以最新文档为准。

参考：
- https://docs.railway.com/pricing/plans

## 9. 建议的最小可上线流程
1. GitHub 连接仓库并首次部署。
2. 配置 Variables（先在 Staged Changes 检查，再 deploy）。
3. 生成域名并验证访问。
4. 接入 Postgres/Volume（如有状态数据）。
5. 配置 Healthcheck、重启策略与可观测面板。
6. 在 CI 中改用项目 token 自动部署。

## 10. 关键原文摘录（短引文）
- “The simplest way to deploy is with `railway up`.”
  - 来源：https://docs.railway.com/cli/deploying
- “Shared variables help reduce duplication of variables across multiple services.”
  - 来源：https://docs.railway.com/variables
- “Services communicate over encrypted Wireguard tunnels using internal DNS.”
  - 来源：https://docs.railway.com/networking/private-networking
- “Public domains expose your services to the internet.”
  - 来源：https://docs.railway.com/networking/domains/working-with-domains
- “Up to 30 days of data is available for each project.”
  - 来源：https://docs.railway.com/observability/metrics

## 11. 经典教程与参考
官方教程（推荐按需选择语言栈）：
- Quick Start: https://docs.railway.com/quick-start
- React: https://docs.railway.com/guides/react
- FastAPI: https://docs.railway.com/guides/fastapi
- Rails: https://docs.railway.com/guides/rails

官方工程与构建组件：
- Railway CLI（GitHub）：https://github.com/railwayapp/cli
- Railpack（GitHub）：https://github.com/railwayapp/railpack
