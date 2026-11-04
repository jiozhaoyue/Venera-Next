# 本地文件缺失检测与移除记录

## Goal

进入本地页后台限并发检查漫画目录是否存在；缺失漫画显示徽标并提供仅删除数据库记录的移除操作，不删除文件、不影响收藏与历史。

## Requirements

1. `LocalManager` 增加只读检测方法（如 `Future<Set<...>> missingComicIds()`），使用异步 `Directory.exists()`；Android SAF 走现有 `Directory(value) is AndroidDirectory` 分支。
2. 本地页进入 / 刷新时后台扫描，限制并发（建议 4），带 generation 与 `mounted` 守卫；不阻塞列表首帧。
3. 缺失漫画卡片显示徽标（如 `Files missing`），菜单增加「移除记录」。
4. 「移除记录」只删除本地数据库记录（`batchDeleteComics([comic], false, false)`），不写磁盘、不删除收藏与历史。
5. 不自动删除、不自动重建目录；扫描失败不改变列表或记录。
6. 打开缺失漫画仍显示现有可读错误（PR1），并可从列表移除。

## Acceptance Criteria

- [ ] 外部删除漫画目录后进入本地页，对应卡片出现缺失徽标。
- [ ] 「移除记录」后列表立即更新，磁盘无写操作，收藏与历史保留。
- [ ] 扫描限并发，页面销毁后不再 `setState`。
- [ ] 正常漫画无徽标、无额外行为变化。
- [ ] 单元或组件测试覆盖「目录存在」与「目录缺失」两种情况。

## Notes

- 纯本地漫画缺失时阅读器无在线回退；下载漫画缺失时现有逻辑会回退在线，本 PR 不改变阅读路径。
