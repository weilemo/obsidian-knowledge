---
created: 2026-04-09
type: dashboard
status: active
tags: [dataview, paper, dashboard, visualization]
aliases: [Paper Dashboard, 论文看板]
summary: "Research/Paper 目录的 Dataview 可视化看板（纯 Dataview，无需 DataviewJS）。"
---

# Paper Dashboard

> 使用说明：本页全部使用 `dataview`（不是 `dataviewjs`），即使 Dataview JS 关闭也能正常显示。

## 总览
```dataview
TABLE WITHOUT ID
length(rows) AS "总论文",
length(filter(rows, (r) => r.status = "已读")) AS "已读",
length(filter(rows, (r) => r.status = "未读")) AS "未读",
round(100 * length(filter(rows, (r) => r.status = "已读")) / length(rows), 1) + "%" AS "已读率"
FROM "Research/Paper"
WHERE type = "paper"
GROUP BY "总览"
```

## 分类文件夹（一级目录）
```dataview
TABLE WITHOUT ID
key AS "一级目录",
length(rows) AS "总数",
length(filter(rows, (r) => r.status = "已读")) AS "已读",
length(filter(rows, (r) => r.status = "未读")) AS "未读",
round(100 * length(filter(rows, (r) => r.status = "已读")) / length(rows), 1) + "%" AS "已读率"
FROM "Research/Paper"
WHERE type = "paper"
GROUP BY split(file.folder, "/")[2]
SORT length(rows) DESC
```

## 分类文件夹（二级分类，重点）
```dataview
TABLE WITHOUT ID
split(key, "|||")[0] AS "一级目录",
split(key, "|||")[1] AS "二级分类",
length(rows) AS "总数",
length(filter(rows, (r) => r.status = "已读")) AS "已读",
length(filter(rows, (r) => r.status = "未读")) AS "未读",
round(100 * length(filter(rows, (r) => r.status = "已读")) / length(rows), 1) + "%" AS "已读率"
FROM "Research/Paper"
WHERE type = "paper"
GROUP BY split(file.folder, "/")[2] + "|||" + default(split(file.folder, "/")[3], "(无二级分类)")
SORT split(key, "|||")[0] ASC
SORT length(rows) DESC
```

## 分类文件夹（二级分类，仅未读 Backlog）
```dataview
TABLE WITHOUT ID
split(key, "|||")[0] AS "一级目录",
split(key, "|||")[1] AS "二级分类",
length(rows) AS "未读数"
FROM "Research/Paper"
WHERE type = "paper" AND status = "未读"
GROUP BY split(file.folder, "/")[2] + "|||" + default(split(file.folder, "/")[3], "(无二级分类)")
SORT length(rows) DESC
SORT split(key, "|||")[0] ASC
```

## 分类展开（逐篇）
```dataview
TABLE file.link AS "论文", file.folder AS "分类", status AS "状态", published AS "发表日期"
FROM "Research/Paper"
WHERE type = "paper"
SORT file.folder ASC
SORT published DESC
```

## 未读队列
```dataview
TABLE file.link AS "未读论文", file.folder AS "分类", published AS "发表日期", tags AS "标签"
FROM "Research/Paper"
WHERE type = "paper" AND status = "未读"
SORT file.folder ASC
SORT published DESC
```

## 最近新增
```dataview
TABLE file.link AS "最近新增", file.cday AS "创建时间", status AS "状态", file.folder AS "分类"
FROM "Research/Paper"
WHERE type = "paper"
SORT file.cday DESC
LIMIT 20
```

## 高频标签
```dataview
TABLE WITHOUT ID
key AS "高频标签", length(rows) AS "次数"
FROM "Research/Paper"
WHERE type = "paper"
FLATTEN tags AS tag
GROUP BY tag
SORT length(rows) DESC
LIMIT 20
```

## 元数据检查
```dataview
TABLE file.link AS "缺失 published 的论文"
FROM "Research/Paper"
WHERE type = "paper" AND !published
```

```dataview
TABLE file.link AS "状态异常论文", status
FROM "Research/Paper"
WHERE type = "paper" AND (status != "已读" AND status != "未读")
```
