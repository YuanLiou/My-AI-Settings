---
name: running-adversarial-code-review
description: Runs a two-pass adversarial branch code review for a Jira ticket and writes an evidence-bound report to ai-review/. Pass 1 reviews the diff blind, Pass 2 reconciles it against the ticket's ai-knowledge planning docs and names the plan's own blind spots. Use when the user asks for a hostile, aggressive, or adversarial code review, a review report for a ticket branch, or a second opinion before merge. Review only, never edits code.
---

# Running an adversarial code review

## Android Studio Gemini

在 Android Studio 內建 Gemini 執行時，先讀
[Gemini 兩階段審查流程](../../adapters/android-studio/workflows/adversarial-review.md)。

本 Skill 的唯讀限制、票號與資料夾要求、develop 比較基準、
八項檢查、嚴重度及報告要求仍適用。
Gemini 流程補充盲審前置、階段保存、驗證紀錄查核順序，
並提供專用交接提示，取代本檔的 subagent-prompt 入口。
其他工具沿用原流程。

## Inputs

- **Current ticket**（必填）：例如 `APACAUCAND-14071`。
- **Parent ticket**（選填）：例如 `APACAUCAND-13434`。沒有 parent 的任務只給 current 即可。

使用者沒給票號就先問，不要從分支名猜。

## Context 資料夾解析

Context 資料夾是這張票的規劃文件所在，Pass 2 對帳的對象。依下列順序解析：

1. 有 parent：`ai-knowledge/<PARENT>/<TICKET>/`
2. 無 parent 或上一步不存在：`ai-knowledge/<TICKET>/`

兩種形狀在本 repo 都有前例，先確認實際存在的那一種。**兩個位置都不存在時，停下來問使用者「Context 資料夾位置在哪裡？」並等待回答。** 不要猜、不要建立資料夾、不要略過 Pass 2 自行往下做。

資料夾存在但沒有任何規劃文件時可以繼續，並在報告裡寫明 Pass 2 沒有可對帳的計畫——這件事本身就是一則發現。

## Hard rules

- **Review only。** 不改任何 production code、測試、設定，也不改 `ai-knowledge/` 的文件。唯一可以寫入的檔案是報告本身。
- 不 stage、不 commit、不 push、不動 Jira。
- 不在對話裡貼報告全文，完成後只回檔名與路徑。
- **在一個沒有規劃脈絡的全新工作階段執行。** 寫過這張票計畫或程式的 agent 來跑，Pass 1 的盲審是假的。
- 不跑完整 Gradle build。需要執行層證據時，把指令與預期結果寫進報告交給人類跑。

## Workflow

```text
- [ ] 0. 解析票號與 context 資料夾（不存在就停下來問）
- [ ] 1. 解析審查範圍
- [ ] 2. Pass 1 盲審
- [ ] 3. Pass 2 對帳
- [ ] 4. 寫報告
- [ ] 5. 只回檔名與路徑
```

### 1. 解析審查範圍

目前分支對 `develop` 取 merge base（本 repo 的主線是 `develop`，不是 `main` 或 `staging`）。記錄分支名、HEAD、base SHA、範圍內的 commits 與檔案清單，並納入屬於這個功能的未提交或未追蹤檔案。

用 [managing-jira-tickets](../managing-jira-tickets/SKILL.md) 讀 current 與 parent 票。**票可以在 Pass 1 讀**，它是對外的契約，任何 reviewer 都看得到；`ai-knowledge/` 是本機的自家計畫，那才是要盲的東西。

### 2. Pass 1 盲審

**這一段禁止讀 `ai-knowledge/` 底下任何檔案。** 只讀 diff、被改檔案的完整內容、它們的呼叫端與既有測試。列出你自己獨立發現的問題。

必查八項，逐項在報告裡給結論，不適用就寫不適用：

1. **負向斷言效力**：diff 含 `assertFalse`、`assertEquals(false, ...)`、`verify(exactly = 0)`、`never()`、`assertDoesNotExist` 時，逐顆判斷有沒有可能無條件為真。鑑別力沒有被 mutation 證明過就是 must-fix，並寫出你建議的 mutation 步驟（你不要自己跑）。
2. **炸射範圍**：改到既有共用函式、常數、分支，或 Fragment／ViewModel 的 `init` 路徑時，用 `rg` 盤點呼叫端，**跨模組**盤點——`auc-core`、`iom-core`、`devtool`、`iom-devtool`、`shp-core` 的 `src/test` 都算。找出計畫或 commit 沒列到的求值點。
3. **雙副本**：`auc-core` 與 `iom-core`、`devtool` 與 `iom-devtool` 各有獨立副本。檢查有沒有誤植到另一側，以及原本宣稱「兩邊一致」的註解會不會因這次改動變成假的。
4. **註解克制**：有沒有重述程式在做什麼、票號故事，或只有本機文件才解析得了的代號（`D-5`、`C1`、`task_plan`、`findings.md`）出現在正式碼註解、KDoc、commit message 或 PR 描述。
5. **Commit 衛生**：Conventional Commits、scope 是 Jira 票號、英文、原子性。特別驗證每一顆是不是真的能單獨 revert。
6. **測試品質**：有沒有把宣告抄一份的 pin test；Given／When／Then 有沒有說清楚「這顆失敗代表什麼被破壞」；宣稱涵蓋「每一個 X」的測試是不是真的每一個。
7. **harness 與產品行為的界線**：有沒有為了讓測試通過而改動 production 行為。
8. **宣稱 ⊆ 已驗證**：KDoc、commit message 與 PR 描述裡的宣稱，有沒有超出實際跑過的驗證。守衛／防線類的宣稱要逐句對到證據。

diff 含 Jetpack Compose 時，另外依 [using-chrisbanes-skills](../using-chrisbanes-skills/SKILL.md) 挑對應的 Compose 專項檢查。

### 3. Pass 2 對帳

**現在才讀** context 資料夾裡的 `task_plan.md`、`findings.md`、`progress.md`、`decision.md`，以及 parent 資料夾裡的共用知識文件（例如 `share_rules.md`）。分成兩塊：

- **(a) 實作與計畫的分歧**：計畫要求了但沒做、做了但計畫沒要求、計畫寫的事實與程式碼不符。
- **(b) 計畫本身的盲點**：計畫沒要求、但你在 Pass 1 抓到的東西。**這塊最有價值**，它指出的是這套規劃流程漏掉的種類，不只是這次的缺陷。

不要把 Pass 1 的發現重寫一遍到 Pass 2。報告裡兩段分開呈現，讓人看得出哪些是盲審抓到的。

### 4. 寫報告

命名、位置與骨架依 [writing-code-review-docs](../writing-code-review-docs/SKILL.md)：`ai-review/code_review_<slug>_<timestamp>.md`，`slug` 用票號，例如 `code_review_apacaucand_14071_20260911_175037.md`。繁體中文。

本 skill 額外要求四個區塊，缺一不可：

- **第一行是判決**：`Block` / `Approve with must-fix` / `Approve`。
- **Pass 1 與 Pass 2 分開成兩大節**，Pass 2 底下再分 (a)、(b)。
- **必查八項的逐項結論**。
- **「我無法驗證的部分」**：誠實列出沒跑過、看不到、需要實機或需要人類執行才能確認的東西。如果是空的，寫清楚為什麼是空的。

### 5. 回覆

只回檔名與路徑，不要摘要、不要貼內容。

## 敵意的定義

敵意是「主動嘗試證明這份改動是錯的」，不是語氣兇。品質閘門有三條：

**每一則 finding 必須附觸發條件**——使用者路徑、測試情境，或具體的 build variant。舉不出觸發條件的標成「未證實的疑慮」放進低優先，不准包裝成缺陷。

**禁止「整體看起來沒問題」「品質良好」這類結論。** 判決那一行就是結論。

**「我無法驗證的部分」不准留白帶過。** 一份宣稱什麼都查過、卻在這節寫「無」的報告，通常是最不可信的那種。

## 嚴重度

- **Must-fix**：說得出具體的使用者可見後果、資料錯誤，或讓某顆測試失去鑑別力。
- **Should-fix**：目前正確但脆弱，下一個人有高機率改錯。
- **Note**：命名、可讀性、風格。

直覺、Change Risk Anti-Patterns 分數或「感覺怪怪的」不能升級嚴重度。CRAP 掃描只是注意力地圖，不是合併閘門。

## 交給另一個 agent 執行

要在新的工作階段或 subagent 跑這份 review 時，用 [references/subagent-prompt.md](references/subagent-prompt.md) 的模板，填入票號、context 資料夾與分支後整段貼過去。

## 報告回來之後

**不要進入修正流程。** 依專案規則，review 意見要先報告、等使用者核准才動手，而且每一則的處理都要交出「修正前怎麼重現」與「修正後怎麼證明」兩端。這個 skill 的產出是報告，不是待辦清單。
