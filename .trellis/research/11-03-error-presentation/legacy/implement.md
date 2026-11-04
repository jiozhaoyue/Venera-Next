# 执行计划：报错展示层可读化

- [x] 新增 `lib/foundation/failure_presentation.dart`，提供分类、`presentFailure`、`presentFailureMessage`、`presentTechnicalFailureMessage`
- [x] 在 `NetworkError` 统一替换展示文案，保留 `Cloudflare` 特判
- [x] 在下载任务摘要与“继续跳过失效图片”错误弹窗应用可读文案；`Error details` 保留原文
- [x] 在全局 toast 只改写技术性消息；`ErrorWidget.builder` 使用可读文案
- [x] `sourceFailureMessage` 回退到统一映射，覆盖源管理界面
- [x] 补充 zh_CN / zh_TW 翻译
- [x] 新增 `test/foundation/failure_presentation_test.dart`，14 项通过
- [x] `test/foundation/translations_test.dart` 通过
- [x] `dart analyze` 对改动文件无新增问题（`main.dart` 的 webview 依赖问题已通过修复本地 pub cache 排除）
- [ ] 下载页/阅读器回归：本机 Flutter 3.47.8 与项目固定 3.41.4 不一致，`pdfrx_engine 0.4.5` 编译失败，未完成；需在项目固定 SDK 上复跑
