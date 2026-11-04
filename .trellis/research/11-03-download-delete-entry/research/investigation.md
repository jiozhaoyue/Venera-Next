# 调查：下载删除入口现状

## 已存在的能力

- 本地页单本菜单删除：`lib/features/local_comics/local_comics_page.dart:466`。
- 长按多选批量删除：同文件 `:149` 起，执行 `batchDeleteComics`。
- 删除确认对话框：同文件 `:523`，含「同时移除本地收藏与历史」「同时删除磁盘文件」两个勾选项。
- 删除章节弹窗：同文件 `:758`，调用 `LocalManager.deleteComicChapters`。

## 缺口

- 漫画详情页下载按钮在已下载时只提示 `The comic is downloaded`（`lib/features/comic_details/actions.dart:292`），没有管理或删除入口。
- 章节列表没有按章节删除入口。
- 删除确认与章节选择逻辑目前内嵌在 `LocalComicsPage`，详情页无法直接复用。

## 约束

- `LocalManager.deleteComic` / `batchDeleteComics` / `deleteComicChapters` 已有完整事务、删除日志和目录归属保护，必须复用，不能另写删除实现。
- 默认保留收藏与历史，符合上游 #420/#421 的修复意图。
- 正在下载的任务不可被删除，需提示先取消。
