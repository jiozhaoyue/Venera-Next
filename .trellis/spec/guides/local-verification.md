# 本地全环境验证（Windows）

本机跑 CI 等价的 `analyze` / `test` 时必须遵守的约束。基线数据见 `.trellis/research/full-env-test-baseline.md`。

## 规则

1. **只用仓库内工具链**：`bash .toolchain/fl --no-version-check <cmd>`，并设 `PUB_CACHE=<repo>/.pub-cache`。不要调用系统 Flutter。
2. **传给 Windows 子进程的 PATH 条目写成 `/d/...` 形式**。写 `D:/...` 会被 Git Bash 拼成 `D;C:\Program Files\Git\...`，导致 CMake `find_program(nuget)` 失败并回退到联网下载（代理下 TLS 握手会失败）。
3. **`timeout` 不能直接调用 shell 函数**：写成 `timeout 900 bash "$FL" --no-version-check analyze ...`，否则整条命令以 127 退出。
4. **`flutter analyze` 前先在 `tool/code_audit` 执行 `dart pub get --enforce-lockfile`**。这一步由 CI 的 analyze job 负责；漏掉会把该独立工具的依赖缺失报成 38 个 analyzer 错误。
5. **测试前把两个目录加入 PATH**：
   - `.toolchain/flutter-3.41.4/bin/cache/dart-sdk/bin` —— 子进程测试需要按名字调用 `dart`
   - `build/windows/x64/runner/Release` —— FFI 需要按名字加载 `rhttp.dll`、`flutter_qjs_plugin.dll` 等
6. **同一时刻只允许一轮流程操作工作区**。并发跑会互相 `git checkout`，结果作废。脚本已用 `.toolchain/.run-full-tests.lock` 加锁。
7. **不要删除 `build/windows`**：测试依赖其中的原生库，增量构建即可。
