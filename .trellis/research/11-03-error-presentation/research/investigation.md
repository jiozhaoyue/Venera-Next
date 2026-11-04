# 调查：报错展示链路与类型

## 上游结论

- `CyrilPeng/Venera-Next` 没有公开的「报错规范化」issue/PR/路线图。
- 现有基础件：`FailureDetails`、`FailureKind`（failed/cancelled/unsupported）、`OperationFailure`、`SourceFailureCode`（仅源管理）。
- UI 层无统一出口：139 处 `toString()`（91 文件），47 处 `showMessage` 直接展示原始错误。

## 现有展示边界

- `lib/components/loading.dart`：`LoadingState._load` 把 `result.errorMessage!` / `exception.toString()` 赋给 `error`，`NetworkError` 原样显示。
- `lib/features/local_comics/downloading_page.dart`：任务三行摘要显示 `task.message`；「Error details」弹窗保留原文并可复制。
- `lib/main.dart`：`ErrorWidget.builder` 直接显示 `details.exception.toString()`。
- `lib/features/comic_source/source_failure_presentation.dart`：只处理 `SourceFailure`。

## 日志证据（`%APPDATA%\com.github.cyrilpeng\VeneraNext`）

- `logs.previous.txt`：87 次 `DioException [receive timeout]`；15 次 `DioException [unknown]`，底层为 `RhttpTimeoutException` / `RhttpConnectionException`（TLS handshake EOF）；2 次 `RequestCancelled`。
- `logs.txt` / `.log/log.txt`：4 次 `ReferenceError: res is not defined`，来自已安装 `copy_manga.js:714`；根因是拷贝漫画接口返回 210（要求更新官方 App），脚本用未定义的 `res` 掩盖了真实状态码。

## 分类依据

- 网络：`lib/network/app_dio.dart` 的 `MyLogInterceptor` 已改写 badResponse / connectionTimeout / receiveTimeout / 部分 unknown；未覆盖 Rhttp 超时与连接异常。
- 源：`lib/features/comic_source/source_parser_context.dart` 的 `failureResult` 把异常转成 `Res`；JS 异常文本为 `ReferenceError` / `JSException`。
- 文件：`LocalComicFilesUnavailable`、`FileSystemException`。
- 取消：`RequestCancelled`、`DioExceptionType.cancel`。
