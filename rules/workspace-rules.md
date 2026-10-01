- You don't have to perform Test-Driven Development (TDD) in this project.
- If a file become orphans after a change, you can remove it.
- If I use voice to talk to with you, please output my words in Traditional Chinese (zh-tw).
- 不要用縮寫，直接當成我不了解這是什麼縮寫，說全名。
- 分支名尾碼 _ff／_stack／_wip-on-P<number> 這是意圖標記。這是 stack 在未 merge 的 branch 上，禁止對 develop 開 PR、收尾用 rebase --onto

## For Edit

When modifying code, prefer direct patch-based edits that produce clear diffs.

Do not use Python, shell scripts, sed, perl, or other bulk-editing commands to modify source files unless the change is mechanical, repetitive, and spans multiple files.

If you believe a script is necessary:
1. Explain why direct edits are not sufficient.
2. List the files or glob patterns that will be touched.
3. Show the script before running it.
4. After running it, show the resulting git diff.
5. Run the relevant tests, type checks, or linters.
6. Do not delete the script/output until the diff has been reviewed, unless explicitly asked.

Never perform blind global replacements across the repository without checking context.
Prefer AST-aware or structure-aware modifications when possible.

## 註解克制

預設不寫註解。非必要不新增、不擴寫。

- **不要**寫：重述程式在做什麼、票號故事、review 對話摘要、長篇設計獨白、或為了給 AI／本機筆記留痕的註解。
- **不要**在註解裡放只有本機文件才解析得了的代號，例如決策編號（`D-5`）、rubric 條目編號（`R-A11`）、規劃文件的章節名。要寫的是**為什麼**，不是這個決定登記在哪一份文件的第幾條。違規的是那個代號，不是整段解釋——刪代號、留解釋。
- **單元測試的必要例外**：所有單元測試必須在函式內以 Given／When／Then 說明前置情境、實際操作與驗證，每個區塊一行即可。Then 說明失敗代表哪個行為被破壞，不重述斷言。不要改成函式上方的 KDoc；本規則不授權批次補改本輪範圍外的測試。
- **允許**：極少數「若不寫，下一個正常人會改錯」的 **why**（已驗證的陷阱、不可直觀的約束）。
- 不要為了「註解完整」而補一堆 KDoc；能靠命名與結構說清楚就不寫。

寫入註解的框架行為主張，須有對應版本的原始碼、官方文件或足以證明該主張的執行觀測。「沒有觀察到」不能直接寫成「不會發生」。查證過程留在工作筆記，註解只保留必要結論；檢查方式見專案根目錄下的 `.agents/skills/reflecting-on-comments/SKILL.md`。

## Development loop

先寫計畫並請使用者確認，再執行小範圍、可檢視的變更。已核准的範圍不需重複確認。

需要停下來、取得核准或把知識寫到另一份文件的要求，必須各自列入待辦清單。清單要寫出觸發條件、要交付的結果與核准狀態；不要只放在背景說明。尚未授權的 commit、push、對外留言與結案，待辦停在「回報並等待」。已取得的明確授權持續有效，不重問同一件事。

開工前說明本次改動檔案、影響範圍與驗證方式；依 `.agents/rules/blast-radius.md` 把受影響的既有測試一併列入計畫。遇到新事實超出核准範圍，先補計畫並釐清，不能因舊計畫沒列就忽略。

review 意見先查證、報告再修；已核准的具體修正範圍不重複請示。兩端證明與守衛分支對照見 `.agents/skills/getting-pr-review-comments/SKILL.md`，結案仍須使用者明示核准。執行驗證與核准 commit 是兩件事，前者通過不授權後者；commit 順序見 `.agents/rules/git-commit.md`。

文件在開工與取得結果時同步更新；「已實作」「已驗證」「待核准」「已提交」分開記錄。只有實際提交後才補 commit hash；不能因文件已寫「待外溢」就宣稱知識已落地。觀測與預期不符時，記錄它對原判斷的影響及下一個查證步驟。

1. 未核准前不下場寫業務 code
2. 有疑慮就停下來問使用者
3. commit／push 先給草稿，等使用者確認
4. 依目前工具的驗證邊界完成 app-level verification
5. 寫／改測試時遵守 `test-evidence` rule
6. 實作寫完、啟動 code review 前做 Change Risk Anti-Patterns 掃描（訊號不是閘門）。操作見 `.agents/skills/change-risk-anti-patterns/SKILL.md`
7. 每一輪實作寫完、回報完成或草擬 commit message 前，依「註解克制」檢查本次新增或修改的註解（含未提交的改動與新檔，測試的 Given／When／Then 照樣要有），逐條寫出保留或刪除的理由，跟驗證結果一起回報；不等 code review 才抓。操作見 `.agents/skills/reflecting-on-comments/SKILL.md`。交給子代理的實作，交辦內容也要寫明這項檢查
