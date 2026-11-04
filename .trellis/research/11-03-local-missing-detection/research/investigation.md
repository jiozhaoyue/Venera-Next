# 调查：本地文件缺失检测现状

## 现状

- 本地列表直接读 SQLite：`lib/features/local_comics/local_repository.dart:256`，不校验目录是否存在。
- 打开漫画时 `LocalManager.getImages` 直接 `directory.list()`：`lib/features/local_comics/local.dart:545`，目录缺失会抛 `FileSystemException`。
- 阅读器把异常包装为 `LocalComicFilesUnavailable`：`lib/features/reader/chapter_loader.dart:11`；下载漫画会尝试在线回退，纯本地漫画直接报错。
- 封面读取失败显示 `Error: Comic not found.`：`lib/features/local_comics/local_comic_image.dart:37`。
- 没有任何主动扫描或「移除记录」入口。

## 现有可复用能力

- `LocalManager.batchDeleteComics(comics, removeFileOnDisk, removeFavoriteAndHistory)` 支持只删记录：`local.dart:862`。
- Android SAF 分支判断方式：`Directory(value) is AndroidDirectory`，参考 `local.dart:956`。
- 本地页卡片已有徽标机制（`isIncomplete`）：`local_comics_page.dart:362`。

## 约束

- 必须异步 `Directory.exists()`，兼容 SAF；不能同步阻塞 UI。
- 扫描限并发，页面销毁后停止更新。
- 只删记录，不删文件，不影响收藏与历史。
