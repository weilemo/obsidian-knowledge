# 实验室设备预约系统（数据库课程大作业）

这个项目是为“数据库系统概论 Option 1”准备的可讲、可跑、可演示版本。
重点是把业务规则下沉到数据库层（表结构/约束/视图/触发器）。

## 1. 技术选型（你上台可以直接说）

- 使用语言：`SQL`
- 数据库引擎：`SQLite`
- 选择原因：
  - 本机可直接运行，零配置，适合课程演示
  - 支持关系模型、约束、索引、视图、触发器
  - 便于把业务逻辑放在 DB 层并现场展示

> 注：SQLite 不支持 `CREATE FUNCTION` 这种服务器端函数定义语法（像 PostgreSQL/MySQL 那样）。
> 本项目用“触发器 + 视图 + 约束”实现同等的业务规则控制，完全符合“逻辑下沉 DB 层”的目标。

## 2. 目录结构

- `00_数据库入门与汇报速读.md`：数据库引擎、SQL 基础语法、中期汇报讲法
- `01_项目需求与设计说明.md`：需求、业务规则、关系设计
- `02_ER图与关系映射.md`：E-R 图（Mermaid）+ 映射关系
- `03_中期汇报3-4分钟讲稿.md`：可直接照着讲
- `04_文件导读与抽查问答.md`：老师抽查时的快速回答模板
- `06_最终提交与海报说明.md`：期末提交检查清单与海报讲解结构
- `sql/01_schema.sql`：建表、主外键、约束、索引
- `sql/02_views.sql`：视图
- `sql/03_triggers.sql`：触发器（核心业务规则）
- `sql/04_seed_data.sql`：样例数据
- `sql/05_demo_queries.sql`：演示查询
- `sql/06_validation_cases.sql`：非法写入测试样例
- `sql/99_drop_all.sql`：清库重建
- `scripts/build_db.sh`：一键初始化数据库
- `scripts/run_demo.sh`：一键运行演示查询
- `scripts/run_validation.sh`：一键验证触发器拦截
- `scripts/udf_demo.py`：可选，演示 SQLite 函数注册（UDF）
- `poster/final_poster.html`：期末提交海报，可打印为 PDF

## 3. 快速开始（30 秒跑起来）

```bash
cd "/Users/moweile/Obsidian/Knowledge/Course/25-26-2/ICE3404P Database System Concepts 数据库系统概论/实验室设备预约系统项目"
bash scripts/build_db.sh
bash scripts/run_demo.sh
```

## 4. 抽查高频问题（你可以背）

1. 为什么这样分表？
- 降低冗余、避免更新异常，关系模式满足 3NF。

2. 如何防止预约冲突？
- 通过 `trg_reservation_overlap_ins/upd` 触发器，在写入时强制校验时间重叠。

3. 如何把业务逻辑下沉 DB 层？
- 通过 `CHECK + FK + VIEW + TRIGGER`，不依赖前端也能保证规则一致。

4. 为什么选 SQLite？
- 这次中期重点是“设计正确”，SQLite 足够支撑结构化设计和规则验证。
