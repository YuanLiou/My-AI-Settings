# Fragment lifecycle Unit Test gate

適用於任何在 `src/test` 推進 Fragment `onResume()`、`onPause()`、`onStop()`、
`onDestroyView()` 或 `onDestroy()` 的測試。

1. 先跑最小 harness probe，只確認 Fragment 到達目標 lifecycle；probe 通過前，
   不准把失敗當 production bug。
2. 失敗時沿 stacktrace 追 `Fragment` → `ViewModel` → default parameter →
   constructor → `init`。mock constructor 攔不住已先求值的 default parameter。
3. 在建立 Fragment/ViewModel 前，依 repo 既有前例 mock 全域服務。不可只 mock
   stacktrace 最後一個服務。
4. 行為測試先證明正向前置狀態成立，再驗 lifecycle 轉換；禁止從預設 `false`
   直接斷言 `false`。
5. 有負向 assertion 時，沿用 `.agents/rules/test-evidence.md` 的 mutation 規則；改壞 lifecycle
   寫入後，目標測試必須變紅。

完整流程、Runner／Theme 限定與回報格式見
`.agents/skills/running-android-unit-tests-via-studio/references/android-test-environments.md`。
constitution 保留歷史觀測，不把某次 Firebase 初始化失敗當成所有 Fragment 測試都不可行。
