# 全环境测试基线（三分支）

## Goal

用仓库内 Flutter 3.41.4 工具链，把 CI 的 analyze / test 验证在本地 Windows 上做成可重复执行的流程，覆盖三条在途修复分支。

## Requirements

1. 工具链与依赖全部留在仓库内（`.toolchain/`、`.pub-cache/`），不依赖仓库外的任何路径。
2. `run-full-tests.sh` 一条命令完成：Windows Release 构建 → 三条分支各自 `code_audit` → `analyze` → 全量 `test` → TV 专项，并输出可判读的退出码。
3. 构建阶段必须能用仓库内的 `nuget.exe`：CMake 的 `find_program(nuget)` 要命中，不得回退到联网下载。
4. 测试阶段必须能加载原生库（`rhttp.dll`、`flutter_qjs_plugin.dll` 等），并能解析 `dart` 可执行文件。
5. 单实例运行：同一时刻只允许一轮流程操作工作区，避免并发切分支互相污染。
6. 脚本结束后回到执行前所在分支，不改动业务代码。

## Acceptance Criteria

- [x] `flutter build windows --release` 成功，产物含 `VeneraNext.exe` 与 `rhttp.dll`。
- [x] 三条分支 `dart pub get --enforce-lockfile` + `dart analyze --fatal-infos` 均为 0。
- [x] 三条分支 `flutter analyze --fatal-infos --fatal-warnings` 均为 0。
- [x] 三条分支 TV 专项测试均为 0。
- [x] 全量 `flutter test` 无确定性失败；残留失败经单独复跑确认为 flaky。
- [x] 流程结束自动切回原分支。

## Notes

- 全量测试基线：`fix/download-delete-entry` 5696 通过、`fix/local-missing-detection` 5696 通过、`fix/user-facing-errors` 5702 通过。
- 已知 flaky：`source_data_admission_test`（5s 超时 + `Application data is busy`）、`current_image_viewport_test` 与 `reader_exit_integration_test`（图片未加载完）；三个文件单独复跑 205/205 全绿。
