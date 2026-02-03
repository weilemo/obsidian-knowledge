---
created: <% tp.date.now("YYYY-MM-DD HH:mm") %>
type: paper
status: unread
---
# <% tp.file.title %>

## 元数据
- **抓取时间**: <% tp.date.now() %>
- **链接**: 

## 笔记内容
<% tp.file.cursor() %>  <-- 这是一个魔法命令