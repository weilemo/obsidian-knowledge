
## 方式一：API 导入（保留数据库/公式）
- 打开 Notion Integrations：https://www.notion.so/profile/integrations/
- 新建 Integration，选择 workspace 并保存
- 在 Configuration 复制 `Internal Integration Secret`
- 在 Access 授权要导入的 pages/databases
- Obsidian 安装并启用 Importer 插件
- Importer → File format 选 **Notion (API)**
- 粘贴 API token → Load 选择内容 → Import

## 方式二：文件导入（不保留数据库，无需 Token）
- Notion：Settings → Workspace → General
- Export all workspace content
- Export format 选 **HTML**（不要选 Markdown）
- 勾选 Include everything + Create folders for subpages
- 下载 `.zip`
- Obsidian Importer → File format 选 **Notion (.zip)**
- 选择 `.zip` → 可选指定导入文件夹
- 可选开启 “Save parent pages in subfolders”
- Import

## 常见问题
- 大型 workspace 导入慢：Notion API 有限速，耐心等待
- 导入卡住：暂时禁用其他插件再试
- 报错 `Import failed {id}.zip/...`：先解压外层 zip，再导入内部分包 zip
