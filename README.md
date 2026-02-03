# Obsidian Knowledge Vault (Cloud-Ready)

这个仓库用于将 Obsidian vault 同步到 GitHub 私有仓库，并支持 Codex Cloud 在云端执行笔记整理任务。

## 目录约定
- `Attachments/` 不纳入版本控制（见 `.gitignore`）
- `Templaters/` 存放笔记模板
- `course/` 存放课程相关笔记

## Codex Cloud 使用方式
1. 在 Codex App 的 Environments 中创建环境
- 选择本仓库 `obsidian-knowledge`
- 容器镜像使用默认 `universal`
- 容器缓存开启
- Setup script 留空（除非需要安装依赖）

2. 创建 Cloud 线程运行任务
- 在 Codex App 新建线程，选择 `Cloud` 模式
- 选择上一步创建的环境

3. 网络访问（如需抓取网页）
- 代理网络访问：启用
- 允许域：按需加入，如 `stanford-cs336.github.io`

## 注意事项
- Secrets 仅在 setup 阶段可用，agent 阶段会被移除
- 环境变量在整个任务生命周期内可用
- 每次云端任务完成后请在 Codex 中审阅 diff 再应用

## 常见错误排查
- 云端任务无法访问网站：确认代理网络访问已启用，并把目标域名加入允许列表
- 任务中提示缺少依赖：在环境中添加 setup script 安装依赖，或改用包含依赖的镜像
- 任务运行但未产生改动：检查任务提示是否包含明确的输出目标与文件路径
- 仓库拉取失败或无权限：确认 GitHub 仓库是私有但已正确绑定到 Codex 环境
- 推送失败（本地）：检查 SSH key 是否已添加到 GitHub，或改用 HTTPS + PAT

## 示例任务提示
```
读取仓库内 /course/CS336-2025-Spring 下的课程网站链接，生成或更新：
1) 章节主题列表
2) 作业清单详解
3) 课程概览（若有新信息）
输出为中文，遵循 vault 模板风格。
```
