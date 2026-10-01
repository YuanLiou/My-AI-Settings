---
name: running-android-unit-tests-via-studio
description: >-
  Runs Android JVM unit tests (Gradle testDebugUnitTest) through Android Studio
  MCP (user-studio), including compile probes, mutation red/green loops, and
  JUnit XML diagnosis. Use when the agent must verify unit tests itself, run
  targeted --tests filters, prove negative-assertion mutation efficacy, or when
  the user asks to run unit tests via Android Studio / Studio MCP instead of
  only handing a Gradle command back.
---

# Running Android unit tests via Studio MCP

## Android Studio Gemini

在 Android Studio 內建 Gemini 執行時，先讀
[Gemini Android 驗證流程](../../adapters/android-studio/workflows/android-validation.md)，
使用「共用執行方式」與「單元測試」段落。

該流程取代下方外部 Studio 連線門檻、工具參數與執行器選擇。
保留測試環境、單類別隔離、結果查核、mutation 與還原要求。
Gemini 原生工具可完成任務時，不要求另接外部 Studio 伺服器。
其他工具沿用下方原流程。

Before using tool names or readiness gates below, read [the local-tool mapping](../../adapters/studio-tools.md). `GetMcpTools`, `user-studio`, and `ready` are Cursor examples; resolve the equivalent capability from Codex's live tool catalog when running in Codex.

## When to use

- Agent needs pass/fail evidence for JVM unit tests (including mutation red/green loops).
- User asks to run unit tests, `--tests` filters, or verify a test class/method.
- Cursor Shell Gradle is too slow or blocked; Studio MCP is the preferred runner.

Use this path when the current tool's runtime and task authorization allow agent-run unit tests. Available Studio tools do not themselves grant execution authorization. Otherwise provide the exact command to the developer.

## Relation to project rules

- Apply only the current tool's runtime adapter: [Cursor](../../adapters/cursor/rules/runtime.mdc), [Codex](../../adapters/codex/runtime.md), or [Claude Code](../../adapters/claude/rules/runtime.md). Keep their full-build and execution differences.
- For this workflow, Spotless / unit tests use **Android Studio** or an exact command handed to the developer. If Studio is unavailable or execution is unauthorized, use the manual fallback; do not bypass the current runtime policy.
- Device / emulator journeys belong to `smoke-testing-android`, not this skill.
- Quiet the **agent command** (`--console=plain` + summary pipe + JUnit XML). Do not change `testLogging` in Gradle. Do not use `-q`.

## Tooling model

| Layer | Tool | Role |
|---|---|---|
| Required gate | Current client's tool discovery; Cursor: `GetMcpTools` on `user-studio` | Confirm required Studio capability is connected and callable; Cursor uses `ready` |
| Preferred runner | `execute_terminal_command` (`executeInShell: true`) | Narrow Gradle + `--console=plain` + summary pipe |
| Optional compile probe | `build_project` (`filesToRebuild`) | Fast compile check after edits |
| Optional pass/fail smoke | `execute_run_configuration` (`filePath` + `line`) | Exit code only; often empty `output` |
| Failure detail | Shell `cat` of JUnit XML | Stack traces. Do not dump full Gradle into the parent chat |

## Hard stop

Stop Studio execution, report the limitation, and provide the manual command when:

- The current client's Studio connection is unavailable (Cursor examples: `needsAuth`, `error`, or `loading`)
- Discovery only exposes `mcp_auth` / auth fails
- Probe calls fail because Android Studio is closed

Do **not** claim tests passed without evidence. Do **not** assume Cursor Shell Gradle is an equivalent substitute.

## Progress checklist

```markdown
Unit Test Progress:
- [ ] Confirm current runtime authorization and live Studio capability
- [ ] Resolve module + fully-qualified test filter
- [ ] Check source set, Runner and initialization; lifecycle work needs a harness probe
- [ ] Optional: compile probe via build_project
- [ ] Run via execute_terminal_command (executeInShell true)
- [ ] Read PASSED/FAILED/BUILD summary
- [ ] On failure: read JUnit XML via shell cat
- [ ] Report exact command + verdict
```

## Step 1: Probe Studio MCP

1. Resolve the required operation through [the local-tool mapping](../../adapters/studio-tools.md). In Cursor, call `GetMcpTools` for `user-studio` and require `ready`; other clients use their live catalog and connection evidence.
2. Confirm the task permits the intended execution. Do not start a build merely to check configuration discovery.
3. Read the live tool schema before invoking it; only use `GetMcpTools` on clients that expose that API.
4. Always pass `projectPath` when known (repo root).

If unavailable, tell the user to open Android Studio, restart / reconnect Studio MCP, then retry. Meanwhile provide the exact Gradle command for manual Terminal use.

## Step 2: Resolve what to run

Read [Android test environments](references/android-test-environments.md) for Runner, Theme, default-parameter and Fragment lifecycle preflight. Keep the existing class-isolation gate below. Callers affected through shared helpers belong in the filter plan even if their test files were not edited.

Prefer the narrowest filter that still covers the claim:

```bash
# Whole class
./gradlew :<module>:testDebugUnitTest --console=plain --tests "com.example.FooTest"

# Single method
./gradlew :<module>:testDebugUnitTest --console=plain --tests "com.example.FooTest.methodName"

# Method name prefix / pattern
./gradlew :<module>:testDebugUnitTest --console=plain --tests "com.example.FooTest.newArrivals*"
```

Common modules in this repo: `:iom-core`, `:auc-core`, app modules as needed.

Optional cache bust when a rerun must actually execute:

```bash
./gradlew :<module>:testDebugUnitTest --console=plain --tests "…" --rerun-tasks
```

### CI isolation gate

After changing or adding a JVM test, run every changed test class once in
its own Gradle invocation before treating a combined filter as evidence:

```bash
./gradlew :<module>:testDebugUnitTest --console=plain --rerun-tasks \
  --tests "com.example.ChangedTest"
```

This catches test-order dependencies: another test class can initialize a
global singleton, context, Firebase, or test runner state first and make a
combined local run green while CI runs the changed class in an uninitialized
worker.

Before adding a default parameter to a composable, ViewModel, or helper used
by tests, trace whether evaluating the default reaches an application-scoped
dependency. Keep production defaults at the public boundary. Internal
overloads called directly from tests must receive an explicit dependency or
use a deterministic test-safe default.

## Step 3: Optional compile probe

After editing Kotlin sources, optionally compile only touched files:

- Tool: `build_project`
- Args: `filesToRebuild: ["relative/path/Foo.kt", …]`, `projectPath`, generous `timeout` (e.g. 180000)
- Prefer this over a full rebuild (`rebuild: true`) unless the user asks for a full rebuild

Use `get_file_problems` for IDE inspection noise on a single file when useful.

## Step 4: Run tests (preferred path)

Always `--console=plain`. Never `-q` / `--quiet`: quiet mode drops task names and compiler breadcrumbs the agent needs on failure.

Do **not** change module `testLogging` in `build.gradle.kts` so the AI stays quiet. Humans and CI still want passed / skipped / stdout.

Use `execute_terminal_command`:

| Arg | Value |
|---|---|
| `command` | summary pipe below (`executeInShell` required) |
| `executeInShell` | **`true` (required)** |
| `projectPath` | Absolute repo root |
| `timeout` | `240000`–`300000` once Gradle is warm; **`900000`+ for the first run of a session** (see pitfall 4) |
| `maxLinesCount` | `40`–`80` for summaries; raise only when debugging a **compile** failure |

Success path (verdict lines only; `pipefail` so Gradle's exit code survives `grep`):

```bash
set -o pipefail
./gradlew :<module>:testDebugUnitTest --console=plain --tests "FQCN" \
  | grep -E "PASSED|FAILED|SKIPPED|BUILD SUCCESSFUL|BUILD FAILED|tests completed|FAILURE:|What went wrong"
```

Confirm the intended tests actually executed and the current result contains the expected methods/count. `BUILD SUCCESSFUL` with no `FAILED` lines alone does not exclude skipped tests, a wrong filter or stale results. Report the narrow verdict; do not paste the rest of Gradle into the parent chat.

If tests `FAILED`, go to Step 6 (JUnit XML). If `BUILD FAILED` without test names, grep compiler lines (`^e: `|`FAILURE:`|`What went wrong`) or raise `maxLinesCount` for that one rerun. Still skip progress bars and `UP-TO-DATE` spam.

When handing a command to the user (Studio MCP not ready), include `--console=plain` and the same `--tests` filter. Do not ask them to run `-q`.

### Critical pitfalls

1. **`executeInShell` must be true** whenever the command uses `|`, `>`, `2>&1`, `&&`, or shell globs. Without it, Gradle may treat `2>&1` / `|` as task names (`Task '2>&1' not found`).
2. Always pass absolute `projectPath`.
3. Do not default to Cursor Shell `./gradlew` for this workflow.
4. **Cold start is slow: budget 15 minutes for the first run.** Before the first `testDebugUnitTest` of a session, Gradle configures and compiles dozens of subprojects (`blendvision:*`, `glide`, `gemma3n`, `flipper`, …). Even when most are `UP-TO-DATE`, walking that graph takes several minutes on its own, so a 300000ms timeout returns `is_timed_out: true` on the first attempt. Give the first run `900000`+, or warm the daemon and config cache with a trivial task first, then run the real filter with the normal budget.
5. **`is_timed_out` does not mean the Gradle process died — wait before retrying.** The terminal accepts a new command immediately, but the previous Gradle run may still be writing under `build/intermediates/`. Firing the same command right away makes a second daemon delete a directory the first one is still writing to:

```text
java.io.IOException: Unable to delete directory '.../compileDebugKotlin/classes'
    Failed to delete some children. New files were found.
    This might happen because a process is still writing to the target directory.
```

This is two Gradle processes colliding, not a build or test failure. Wait ten to fifteen seconds for the previous run to settle, then retry. Do not go debugging the code.

6. **The Studio terminal may not expose `rg` on its PATH.** If a summary pipeline reports
`command not found: rg`, do not infer that Gradle never ran: it can continue running and still
report test results. Use the documented `grep` summary pipeline in this Studio-only workflow, or
run the narrow command without a pipeline and inspect the final verdict / JUnit XML.

## Step 5: Optional gutter-style smoke (secondary)

When you only need pass/fail bits:

1. `get_run_configurations` with `filePath` = test file relative to project root.
2. Pick a run point `line` for the class or method.
3. `execute_run_configuration` with `filePath` + `line`, `waitForExit: true`, large `timeout`, `projectPath`.

Treat empty `output` as normal. Use `exitCode` (`0` = pass). For stack traces, switch back to Step 4 or Step 6. Do **not** use this as the primary evidence path for mutation or failure diagnosis.

## Step 6: Diagnose failures

1. Take `FAILED` method names from the Step 4 summary.
2. Read the stack from JUnit XML, not from a second full Gradle dump:

```text
<module>/build/test-results/testDebugUnitTest/TEST-<FQCN>.xml
```

3. Read via Shell `cat` (Cursor `Read` may hit permission / sandbox issues on `build/`). Quote the exception and the failing assertion in the parent chat. Leave the rest of the XML out.
4. Optionally open the HTML report under `<module>/build/reports/tests/testDebugUnitTest/` for humans; agents should prefer XML.

## Step 7: Spotless (same runner)

When formatting is needed before claiming clean:

```bash
set -o pipefail
./gradlew :<module>:spotlessApply --console=plain \
  | grep -E "BUILD SUCCESSFUL|BUILD FAILED|FAILURE:|What went wrong"
```

Run through the same `execute_terminal_command` + `executeInShell: true` path. See also `formatting-code`.

## Mutation (negative assertion) loops

Follow [test-evidence](../../rules/test-evidence.md) and [mutation verification](references/mutation-verification.md). Save the pre-mutation working content, including uncommitted work; keep the assertion unchanged; require the expected assertion to fail; then compare restored files to that saved content. An empty marker search or a diff against Git alone cannot prove restoration. A mutation that stays green does not by itself prove dead code.

## Reporting template

Return a short verdict to the user:

```markdown
Studio MCP: <client + observed connection/capability>
Command: ./gradlew :<module>:testDebugUnitTest --console=plain --tests "…"
Result: PASS|FAIL (N tests)
Failed: <method names if any>
Evidence: console summary | JUnit XML
```

If Studio MCP was skipped, say so and paste the exact command for the user.

## Do not

- Use `execute_run_configuration` as the only evidence for failure root-cause.
- Pipe / redirect without `executeInShell: true`.
- Run the entire module test suite when a class/method filter is enough.
- Claim mutation efficacy from green-only runs.
- Confuse this skill with `smoke-testing-android` (device UI journeys).
- Use `-q` / `--quiet` on Gradle.
- Dump unfiltered Gradle, Logcat, or `connectedAndroidTest` output into the parent conversation.
- Change `testLogging` in `build.gradle.kts` to hide passed tests for the agent's sake.
