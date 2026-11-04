# 执行计划：下载删除入口

- [x] 抽取 `local_comic_delete_dialog.dart`，复用本地页的删除确认与章节选择
- [x] `LocalComicsPage` 改用共享对话框，保持原有默认值与行为
- [x] 详情页已下载时，主按钮变为「Manage download」
- [x] 管理面板提供：下载章节、删除章节、删除全部下载、取消
- [x] 删除全部默认保留收藏与历史；文件始终删除
- [x] 正在下载时提示先取消，不执行删除
- [x] 删除后刷新详情页按钮状态
- [x] 补充 zh_CN / zh_TW 翻译
- [x] 新增对话框 widget 测试 3 项，全部通过
- [x] `dart analyze` 改动文件无问题
