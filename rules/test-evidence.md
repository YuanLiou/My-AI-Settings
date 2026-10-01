# Test evidence（負向斷言必須能變紅）

本檔維護測試效力門檻。操作與回報格式見 `.agents/skills/running-android-unit-tests-via-studio/references/mutation-verification.md`；constitution 保留案例，不另定本項規範。

## 何時強制

本 commit 或本輪改動若含下列任一，就適用：

- `assertDoesNotExist`、`assertFalse`、`verify(exactly = 0)`、`never()` 等負向斷言
- 測試名稱／註解宣稱「不會落到 placeholder」「不會發生 X」「守衛某類回歸」

## 硬門檻（不可跳）

1. **通過證明**：目標測試綠燈，並證明前置狀態、分支或節點確實成立。誰執行由目前工具的 runtime 與任務授權決定，不固定要求使用者代跑。
2. **效力證明（mutation）**：先保存改壞前的檔案內容與狀態；暫時改壞被測行為，保持目標 assertion 不變；同一組測試必須在預期 assertion 變紅。編譯失敗、測試環境失敗、跑到其他測試都不算。還原後逐檔比對 mutation 前的快照或雜湊，包含原本未提交的改動；不能以工作目錄相對 index 的差異是否為空代替。
3. 缺效力證明 → **不准**草擬 commit message、不准在 progress／回覆寫「測試有效／已修正守衛」。
4. 使用者明確同意跳過時，回覆明寫「未經 mutation 驗證」，英文 commit body 使用 `.agents/rules/git-commit.md` 的揭露文字。

mutation 沒變紅時先查目標測試是否真的重跑、前置是否成立、改壞的路徑是否可達，再查觀測盲點、等效改動與替代觸發點。沒有變紅只代表尚未證明效力，不能直接判成死碼並刪除。不同 lifecycle 事件要分開驗證，避免合併改壞使前置條件互相抵消。

## 紅旗：硬停問使用者

測試或註解出現「必須避開 X，否則不會通過／不會 emit／拿不到節點」→ 先問 X 在正式環境會不會發生、使用者看到什麼；不准當測試技巧直接繞過。

## 修 review／subagent 測試缺陷

同樣要兩端證明：修正前重現 + 修正後效力。「寫了修正 + 綠燈」不夠，結案須使用者明示核准。守衛／防線類修正另有「宣稱 ⊆ 已驗證」的分支對表要求，完整模板見 `.agents/skills/getting-pr-review-comments/SKILL.md`。

## 測試要驗證什麼

先回答「失敗代表哪個行為或外部約束被破壞」。不複製宣告清單與自己比對，不重複其他 assertion 或編譯器已保證的條件。宣稱涵蓋所有 case 時，列舉要對應完整來源；只比數量不能證明沒有重複或漏項。為真實性質建立完整性檢查，不為測試而改型別設計、加無法抓到目標缺陷的抽象。

## Compose 速記

`hasTestTag(t) and hasText(s)` 套在**同一節點**。tag 在容器、文字在子層時永遠匹配不到；負向斷言會無條件綠燈。跨層用 `hasText(s) and hasAnyAncestor(hasTestTag(t))`。
