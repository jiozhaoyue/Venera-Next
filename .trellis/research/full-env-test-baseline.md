# 全环境测试基线（三分支）

> 2026-11-04 本机实测。流程脚本：`.toolchain/run-full-tests.sh`。

## 范围

仓库内 Flutter 3.41.4 工具链（`.toolchain/flutter-3.41.4`，`PUB_CACHE=.pub-cache`），对三条在途分支各跑一遍 CI 等价的验证：Windows Release 构建 → `tool/code_audit` → `flutter analyze` → 全量 `flutter test` → TV 专项。

分支：`fix/download-delete-entry`、`fix/local-missing-detection`、`fix/user-facing-errors`。

## 实测结论

- `flutter build windows --release` 成功，产物在 `build/windows/x64/runner/Release/`（`VeneraNext.exe` + `rhttp.dll` + 22 个插件 DLL），测试阶段直接加载该目录。
- 三条分支的 `code_audit`、`analyze`、TV 专项退出码全部为 0。
- 全量 `flutter test` 通过数：5696 / 5696 / 5702，每支 2 个跳过。

## 已知 flaky（单独复跑 205/205 全绿）

| 用例 | 报错 |
| --- | --- |
| `test/features/comic_source/source_data_admission_test.dart`（多个用例） | `TimeoutException after 0:00:05`，teardown 报 `Application data is busy; retry after the current data operation completes` |
| `test/features/reader/current_image_viewport_test.dart` | `Reader images did not finish loading` |
| `test/features/reader/reader_exit_integration_test.dart` | 同上（图片未加载完） |

判定：满负载或残留状态下复现，单独跑不复现，属时序敏感，不是分支回归。三条分支都出现 `source_data_admission_test`，与该分支改动无关。

## 被否掉的做法

- **每次运行前 `rm -rf build/windows`**：测试要加载该目录下的 `rhttp.dll` 等原生库，删掉会让整批原生测试失败。已改为增量构建。

## 相关

- 本机执行约束见 `.trellis/spec/guides/local-verification.md`。
