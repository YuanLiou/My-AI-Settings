# Android 測試環境與前置檢查

先辨識 module、source set、Runner、Application 與被測行為。`src/test`、裝置上的 `androidTest`、Preview 是不同環境，不能把其中一次初始化失敗改寫成所有 Compose 或 Fragment 測試的限制。

## Runner 與 Theme

| 情況 | 先確認的事 |
| --- | --- |
| 純 Kotlin 測試 | 是否需要 Android 或全域環境；不需要就保持純 JUnit |
| Robolectric 的 `src/test` | 實際 Runner、測試 Application、全域依賴與建立順序 |
| 裝置 `androidTest` | instrumentation／Application 是否初始化被測 Theme 或元件所需的服務 |
| Theme／顏色整合測試 | 必須涵蓋要驗證的 Theme 行為，不能拿掉 Theme 後仍宣稱驗到了它 |
| 純畫面／callback 測試 | 依同類測試選擇明確狀態、依賴或必要的 CompositionLocal，避免無關 app 初始化 |

2026-09-16 讀碼確認：`auc-core` 與 `iom-core` 的 `src/test/java/com/yahoo/mobile/client/android/base/AuctionTestRunner.kt` 都在 `AuctionTestLifecycle` 設定 Debug 並呼叫 `ECSuperEnvironment.setup(config)`。這不代表 Firebase、帳號或所有其他服務也已初始化。Runner 與 mock 要依測試目標選，不一律禁止或強制使用 AuctionTestRunner。

AuctionTheme 會讀取 `ECSuperEnvironment`；`createComposeRule()` 使用 ComponentActivity 本身不證明 Application 已完成初始化。包 Theme 前查實際測試設定與堆疊，不因單次初始化失敗就認定所有測試都不能包 Theme。

## Fragment lifecycle preflight

門檻見 [fragment-lifecycle-tests](../../../rules/fragment-lifecycle-tests.md)。要驗證離頁清理、暫停、隱藏或曝光前，先用最小 probe 建 Activity、attach Fragment，推進到目標 lifecycle；尚不驗產品行為。

失敗時追出 Fragment → ViewModel → default parameter → constructor → init 的求值順序。constructor mock 攔不住呼叫前已求值的 default parameter。依同 module 既有前例，在建物件前設置所需 mock，並在結束時清理；不要只處理 stacktrace 最後一個服務。

到不了目標 lifecycle 屬於測試環境失敗，不能據此判定產品有錯，也不能為了讓 probe 跑過而擅改正式行為。到達目標且正向前置已成立後，才加入行為 assertion；true → false 與 default false → false 不同。負向 assertion 另做 [mutation](mutation-verification.md)。

2026-09-16 可查的前例已有 `auc-core/src/test/java/com/yahoo/mobile/client/android/ecauction/fragments/landingpage/AucLandingPageFragmentV2LifecycleTest.kt` 及 `iom-core/src/test/java/com/yahoo/mobile/client/android/iopenmall/fragments/landingpage/IomLandingPageFragmentLifecycleTest.kt`。兩者在建立 Fragment 前 mock ECSuperCrashReportTracker、帳號、ApiClient 與 LandingPageStore；AUC 版本另外處理 FeatureControlUtils。此為讀碼確認，本次沒有重跑測試，也不保證所有 Fragment 可直接套用這組 mock。

## 共用分支與測試隔離

Debug Runner 的 build type 短路可能替既有測試擋住 Remote Config。移除短路會讓原呼叫端走到原先不會求值的依賴，即使那些測試已 mock Crashlytics 也可能失敗。先依 [blast-radius](../../../rules/blast-radius.md) 搜尋 constructor、init 與所有呼叫端，將受影響的既有測試加入計畫。

新增／修改的測試類別依主 Skill 分別獨立執行，再把組合執行當額外結果。前一個類別初始化過 singleton 不代表下一個類別可獨立跑。default parameter、全域 Wi-Fi flow、Theme 與尺寸 helper 都要檢查這條相依鏈。

## 回報欄位

| 欄位 | 記錄內容 |
| --- | --- |
| 環境 | module、source set、Runner／Application |
| 目標 | lifecycle、正式路徑與正向前置 |
| 依賴 | 求值順序、mock 設置與清理 |
| probe | 實際命令／工具與到達位置 |
| 判讀 | 測試環境失敗、行為失敗或通過；保留未驗證部分 |
| 後續 | 行為 assertion、mutation 與單類別隔離結果 |
