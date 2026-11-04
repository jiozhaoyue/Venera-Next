# 执行计划：本地文件缺失检测与移除记录

- [x] `LocalManager.missingComicIds` 异步限并发（4）检查漫画目录是否存在
- [x] Android SAF 使用 `AndroidDirectory.exists()`，其他平台使用异步 `Directory.exists()`
- [x] 本地页进入时后台扫描，带 generation 与 `mounted` 守卫
- [x] 缺失漫画显示「Files missing」徽标
- [x] 卡片菜单增加「移除记录」，确认后只删数据库记录（`batchDeleteComics(false, false)`）
- [x] 不删除磁盘文件，不影响收藏与历史
- [x] 补充 zh_CN / zh_TW 翻译
- [x] 新增缺失检测单元测试，通过
- [x] `dart analyze` 改动文件无问题
