---
name: change-risk-anti-patterns
description: >-
  Scans a commit-sized Kotlin diff for Change Risk Anti-Patterns
  (complex, under-attended functions) and produces a ranked review
  attention map. Use after finishing a code implementation and before
  starting a code-review subagent, when reviewing uncommitted or
  branch diffs, or when the user mentions Change Risk Anti-Patterns
  or CRAP analysis. This is a review signal only: never block commit
  or promote a score to Must-fix by itself.
---

# Change Risk Anti-Patterns

每一顆 commit 實作寫完、啟動 code review 子代理之前，對這次 diff 做一次掃描。產出「先看這裡」的函式排名，交給審查子代理。

這是 review 訊號，不是閘門。分數再高也不准擋 commit，不准把分數本身升級成 Must-fix，不准為了壓分數而加無意義測試。

權威順序見 `ai-knowledge/share/constitution.md` 的「When you finish every code implementations」。本檔只寫操作。

## 何時做

- 這顆 commit 的生產 Kotlin 已寫完，尚未叫 Compose／Kotlin 審查子代理。
- 使用者要求 code review，而這次範圍還沒有這份排名。
- 分支收尾 review：對整個 `develop...HEAD`（或呼叫者指定的 base）再掃一次。

純文件、純資源、純測試提交：寫「無生產程式碼」，不要硬估分數，審查照常進行。

## 不要做的事

- 不要跑 Gradle、JaCoCo、完整 build，或為了這項檢查去產測試覆蓋率。第一段只看循環複雜度。
- 不要因為排名就改程式碼。有真正的正確性問題，走既有「Code review 回報後才修」。
- 不要寫只為覆蓋率或分數存在的測試。無意義測試判定仍適用。
- 不要把 Jetpack Compose 畫面組裝函式的分支數當成判決。

## 掃描範圍

只看這次 diff 裡 `src/main` 的 `.kt` 生產檔。對每個被改到的函式，讀**變更後的完整函式**來估循環複雜度，不要只看 hunk。函式變更前就存在的話，一併估變更前的數字，用來標「變複雜了」。

排除：

- `src/test`、`src/androidTest`
- 產生碼、Preview
- 以 `Column`／`Row`／`Box`、條件 modifier、`if (visible)` 包內容為主的 `@Composable` 組裝函式。狀態機、解析、導轉、reducer、use case 仍要掃，即使標了 `@Composable`。

## 怎麼估循環複雜度

從 1 起算，每個決策點 +1：`if`、`else if`、`when` 的每個分支、`for`／`while`／`do`、`catch`、條件裡的 `&&`／`||`、`?:`。不必追求與靜態分析工具逐點相符；方向對、同一次 diff 內尺度一致即可。

列出排名的門檻（符合任一就進表）：

- 變更後循環複雜度 ≥ 10
- 比變更前增加 ≥ 3
- 變更前就 ≥ 10，這次又改到它

最差的排前面，最多 8 筆。都不符合就寫「無顯著訊號」。

## 輸出（交給審查子代理，並出現在 review 報告）

```markdown
### Change Risk Anti-Patterns 訊號

這是注意力地圖，不是 Must-fix。分數本身不得升級成 Must-fix，也不得擋 commit。

- `<path>` `<FunctionName>`（約 L<line>）— 循環複雜度變更前 `<m>` → 變更後 `<n>` — `<一句為什麼值得盯>`
```

沒有列項時寫「無顯著訊號」。呼叫審查子代理時，把這整段貼進提示，並寫明「先看這些函式；Verdict 仍只依正確性、契約與既有 skill，不依分數」。

## 和既有閘門的分工

- 本項：這次是不是把更難改的函式送進去了（注意力）
- Compose／Kotlin 審查：行為、生命週期、狀態與契約對不對
- 範圍稽核：有沒有踩到明確不做
- mutation：負向斷言有沒有鑑別力

四件事不要互相取代。某個高分函式同時有可重現的正確性問題時，Must-fix 依據是那個問題，不是分數。
