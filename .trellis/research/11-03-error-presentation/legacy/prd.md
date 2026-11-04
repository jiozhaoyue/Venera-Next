# 报错展示层可读化

## Goal

统一 UI 错误出口：把 JS 运行时、网络超时/连接、HTTP 状态、文件缺失、取消等原始报错映射为用户可读文案；日志保留原始错误。最小侵入，不改底层错误类型体系。

## Requirements

1. 新增 `lib/foundation/failure_presentation.dart`，提供 `String presentFailure(Object error)` 与 `String presentFailureMessage(String message)`，分类至少覆盖：
   - 源脚本运行时错误（ReferenceError / TypeError / SyntaxError / JSException）
   - 网络超时（Dio receive/connection/send timeout、RhttpTimeoutException）
   - 网络连接 / TLS（RhttpConnectionException、handshake、reset by peer）
   - HTTP 状态错误与 Cloudflare 验证
   - 本地文件缺失 / 存储不可用
   - 存储忙 / 迁移恢复中
   - 用户取消
   - 不支持的能力
   - 未知兜底
2. 只在展示边界使用：`LoadingState` 的错误赋值、`DownloadingPage` 的任务消息、全局 `ErrorWidget.builder`。
3. 不修改 `Log`、`Res`、`FailureDetails`、`FailureKind` 或底层异常类型；日志内容保持原文。
4. 原始错误必须仍可查看：日志页、下载任务「Error details」弹窗、导出日志。详情弹窗保留原文。
5. 文案通过 `.tl` 输出；中文翻译使用现有 translation 机制（缺失时回退英文）。
6. 不调整 15 秒超时与重试策略。

## Acceptance Criteria

- [ ] 源脚本 `ReferenceError: ...` 在主界面显示为可读提示，不直接露出堆栈、脚本文件名和行号。
- [ ] `DioException [receive timeout]`、`RhttpTimeoutException`、`RhttpConnectionException` 显示为「网络超时 / 连接失败」类提示。
- [ ] 下载任务失败的三行摘要显示可读提示；点「Error details」仍看到完整原文并可复制。
- [ ] 本地文件缺失显示为「下载文件已丢失」类提示。
- [ ] 取消类错误不弹出失败提示。
- [ ] 新增映射函数单元测试；相关现有测试通过。

## Notes

- 上游没有公开的报错规范化路线图；本 PR 只做展示层，不建设完整类型体系。
- 后续如需类型化，另开 PR 扩展 `FailureDetails` 的 reason 字段。
