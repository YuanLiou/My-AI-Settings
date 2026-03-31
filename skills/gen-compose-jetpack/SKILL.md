---
name: gemini-gen-jetpack-compose
description: 將 UI 截圖轉換為符合專案規範的 Jetpack Compose 程式碼
argument-hint: {圖片路徑} [--feature {功能名稱}]
---

# Gemini 產生 Jetpack Compose Skill

將 UI 設計截圖轉換為符合專案規範的 Jetpack Compose 程式碼。

## 使用方式

```
/gen-compose-jetpack {圖片路徑}
/gen-compose-jetpack {圖片路徑} --feature {功能名稱}
/gen-compose-jetpack {圖片1} {圖片2} --feature {功能名稱}
```

**圖片存放位置**：`doc/designs/` 目錄下

## 參數說明

| 參數 | 必填 | 說明 |
|------|------|------|
| `{圖片路徑}` | 是 | UI 截圖檔案路徑（支援 png, jpg, jpeg, webp） |
| `--feature` | 否 | 指定功能名稱，覆蓋建議的名稱 |

## 工作流程

```
驗證圖片路徑 → 分析 UI → 詢問 Navigation → 產生核心 UI（含 @Preview）
                                                   ↓
                                           編譯驗證（自動修復）
                                                   ↓
                                           [確認點] 預覽 UI
                                                   ↓
                             ┌──────────────────────┼──────────────────────┐
                             ↓                      ↓                      ↓
                        選項 1                  選項 2                  選項 3
                     繼續生成後續            重新分析圖片          自行輸入調整
                             ↓                      ↓                      ↓
                    產生完整架構            回到 Gemini 分析       重新生成 → 回到確認點
                             ↓
                       編譯驗證（最終）
```

---

## Step 1: 驗證圖片路徑

**驗證規則**：
1. 圖片路徑必須存在
2. 圖片必須位於 `doc/designs/` 目錄下
3. 支援的圖片格式：.png, .jpg, .jpeg, .webp

### 錯誤處理

**圖片不存在**：
```
錯誤：找不到圖片檔案

請確認圖片路徑正確：{圖片路徑}

預期圖片位置：
doc/designs/
├── login.png
├── profile.png
└── ...
```

**圖片格式不支援**：
```
錯誤：不支援的圖片格式

支援的圖片格式：.png, .jpg, .jpeg, .webp

請提供正確格式的設計圖。
```

**圖片不在 doc/designs/ 目錄**：
```
錯誤：圖片必須放在 doc/designs/ 目錄下

請將設計圖移至 doc/designs/ 目錄後再執行。
```

---

## Step 2: 分析 UI 截圖

> **模型指定**：使用 `gemini-3-pro` 模型進行圖片分析

使用 `prompts/image-analysis-prompt.md` 分析圖片，輸出 JSON 格式的 UI 描述，包含：

- `screen_type`: 畫面類型
- `suggested_feature_name`: 建議的功能名稱
- `suggested_screen_name`: 建議的畫面名稱
- `ui_elements`: UI 元素列表
- `layout_structure`: 佈局結構
- `state_requirements`: 狀態需求
- `complexity_level`: 複雜度等級
- `split_recommendation`: 元件拆分建議

---

## Step 3: Navigation 詢問

**詢問使用者**：

問題：`是否需要產生 Navigation 相關程式碼？`

選項：
1. **是，產生 Type-Safe Route** - 會更新 NavRoute.kt 和 NavGraph.kt
2. **否，只產生 UI 程式碼** - 僅產生 Screen、ViewModel 等 UI 相關檔案

---

## Step 4A: 產生核心 UI（可預覽）

僅產生以下檔案，讓使用者可以先預覽 UI 佈局：

### UI 層（核心檔案）

> **注意**：Step 4A **不產生 Route**，只產生 Stateless 的 Screen。
> Route 與 ViewModel 將在 Step 4B 一起產生。

```
app/src/main/java/com/example/realtimeassistant/feature/{功能名}/ui/
├── screen/{功能名}Screen.kt      # Stateless Screen（含 @Preview）
├── state/{功能名}UiState.kt      # UI 狀態資料類別
├── state/{功能名}Event.kt        # 使用者事件定義
├── state/{功能名}Effect.kt       # 一次性副作用定義
└── component/{元件名}.kt         # 拆分的元件（如有）
```

### 資源（必定更新）

```
app/src/main/res/values/strings.xml  # 新增字串資源
app/src/main/java/.../core/ui/theme/Color.kt  # 如有新顏色
```

> **重要**：Screen 檔案必須包含 `@Preview` 函式，讓使用者可以在 Android Studio 預覽 UI 佈局。

---

## Step 4A.5: 編譯驗證（核心 UI）

**驗證指令**：

```bash
./gradlew clean compileDebugSources
```

> **說明**：使用 `clean compileDebugSources` 而非 `compileDebugKotlin`，
> 以解決 Android Studio 增量編譯導致的 R.class 緩存同步問題
> （`NoSuchFieldError` 或 `Resources$NotFoundException`）。
> 此指令比 `assembleDebug` 更快，因為只編譯不打包。

### 失敗處理機制

1. 編譯失敗時，讀取錯誤訊息
2. 嘗試自動修復並重新編譯
3. 紀錄失敗次數
4. **連續 5 次失敗時**，詢問使用者：

問題：`編譯驗證連續失敗 5 次，請選擇下一步：`

選項：

1. **再次執行驗證流程** - 繼續嘗試修復
2. **流程取消，重頭再來一次** - 清除產生的檔案，從頭開始
3. **讓我輸入調整內容** - 使用者提供修正指引

---

## Step 4A.6: 確認 UI 預覽

編譯成功後，詢問使用者：

問題：`核心 UI 已產生並通過編譯，請在 Android Studio 預覽 @Preview 確認佈局是否正確：`

選項：

1. **繼續生成後續** - 產生 ViewModel、Repository、UseCase 等完整架構
2. **重新分析圖片再次生成** - 刪除已產生檔案，重新執行分析（回到 Step 2）
3. **讓我輸入調整內容** - 輸入調整指示，重新生成 UI，再次回到此確認點

### 選項處理邏輯

- **選項 1**：繼續執行 Step 4B
- **選項 2**：刪除 Step 4A 產生的檔案，回到 Step 2 重新分析圖片
- **選項 3**：根據使用者輸入的調整內容，重新生成核心 UI 檔案，然後回到 Step 4A.5 編譯驗證

---

## Step 4B: 產生完整架構

> 僅在 Step 4A.6 選擇「繼續生成後續」時執行

補充以下檔案：

### UI 層（Route + ViewModel）

- **更新** `screen/{功能名}Screen.kt` - 新增 `{功能名}Route` Composable
- **新增** `viewmodel/{功能名}ViewModel.kt`
- **新增** `viewmodel/{功能名}ViewModelFactory.kt`

### Domain 層

```
app/src/main/java/com/example/realtimeassistant/feature/{功能名}/domain/
├── model/{Model}.kt              # 領域模型（如有需要）
├── repository/{功能名}Repository.kt    # Repository 介面
└── usecase/Get{功能名}UseCase.kt       # 業務邏輯封裝
```

### Data 層

```
app/src/main/java/com/example/realtimeassistant/feature/{功能名}/data/
└── repository/{功能名}RepositoryImpl.kt  # Repository 實作
```

### Navigation（如果 Step 3 選擇「是」）

```
app/src/main/java/com/example/realtimeassistant/core/navigation/
├── NavRoute.kt   # 新增路由定義
└── NavGraph.kt   # 新增 composable
```

---

## Step 5: 編譯驗證（最終）

**驗證指令**：
```bash
./gradlew compileDebugKotlin
```

### 失敗處理機制

1. 編譯失敗時，讀取錯誤訊息
2. 嘗試自動修復並重新編譯
3. 紀錄失敗次數
4. **連續 5 次失敗時**，詢問使用者：

問題：`編譯驗證連續失敗 5 次，請選擇下一步：`

選項：
1. **再次執行驗證流程** - 繼續嘗試修復
2. **流程取消，重頭再來一次** - 清除產生的檔案，從頭開始
3. **讓我輸入調整內容** - 使用者提供修正指引

---

## Step 6: 輸出結果

執行完成後，輸出以下格式的結果：

```markdown
## Gemini 產生 Jetpack Compose 執行結果

### 功能名稱
{功能名}

### 產生的檔案

**UI 層**
- `app/src/main/java/.../feature/{功能名}/ui/screen/{功能名}Screen.kt`
- `app/src/main/java/.../feature/{功能名}/ui/state/{功能名}UiState.kt`
- `app/src/main/java/.../feature/{功能名}/ui/state/{功能名}Event.kt`
- `app/src/main/java/.../feature/{功能名}/ui/state/{功能名}Effect.kt`
- `app/src/main/java/.../feature/{功能名}/ui/viewmodel/{功能名}ViewModel.kt`
- `app/src/main/java/.../feature/{功能名}/ui/viewmodel/{功能名}ViewModelFactory.kt`

**Domain 層**
- `app/src/main/java/.../feature/{功能名}/domain/model/{Model}.kt`
- `app/src/main/java/.../feature/{功能名}/domain/repository/{功能名}Repository.kt`
- `app/src/main/java/.../feature/{功能名}/domain/usecase/Get{功能名}UseCase.kt`

**Data 層**
- `app/src/main/java/.../feature/{功能名}/data/repository/{功能名}RepositoryImpl.kt`

### 新增的字串資源
| 鍵值 | 內容 |
|------|------|
| xxx | 對應文字 |

### Navigation
{是否產生 Navigation 程式碼：是/否}

### 編譯驗證
✓ 編譯成功
```

---

## 必須遵循的規範檔案

### 核心規範

- `references/compose/guidelines.md` - UI 規範
- `references/compose/navigation.md` - 導航規範
- `references/compose/performance.md` - 效能規範
- `references/compose/accessibility.md` - 無障礙規範
- `references/file-structure.md` - 檔案放置規範

### 對照表（分析結果 → Compose 實作）

- `references/mapping/ui-elements.md` - UI 元素與 Layout 對照
- `references/mapping/colors.md` - 顏色角色與轉換對照
- `references/mapping/typography.md` - 文字樣式與字體對照
- `references/mapping/dimensions.md` - 尺寸轉換對照
- `references/mapping/backgrounds.md` - 背景處理策略

### 程式碼模板

- `references/templates/code-templates.md` - UDF 架構與各層模板

---

## 禁止事項

| 禁止項目 | 正確做法 |
|---------|---------|
| 硬編碼字串 | `stringResource(R.string.xxx)` |
| 硬編碼顏色 | `MaterialTheme.colorScheme.xxx` |
| `collectAsState` | `collectAsStateWithLifecycle` |
| SharedFlow(replay=0) 發送一次性事件 | 使用 `Channel` |
| LazyColumn 沒有 key | `key = { it.id }` |
| 觸控區域小於 48dp | `minimumInteractiveComponentSize()` |
| 功能性圖示缺少 contentDescription | 提供無障礙描述 |
| UiState 使用 List | 使用 `ImmutableList` |

---

## 批次處理策略

### 同一 Feature 多張圖片

```
/gen-compose-jetpack doc/designs/login_step1.png doc/designs/login_step2.png --feature auth
```

產生結構：
```
feature/auth/
├── ui/
│   ├── screen/
│   │   ├── LoginStep1Screen.kt
│   │   └── LoginStep2Screen.kt
│   ├── state/
│   │   ├── AuthUiState.kt
│   │   ├── AuthEvent.kt
│   │   └── AuthEffect.kt
│   ├── viewmodel/
│   │   ├── AuthViewModel.kt
│   │   └── AuthViewModelFactory.kt
│   └── component/
│       └── {共用元件}.kt
├── domain/
│   ├── model/
│   ├── repository/AuthRepository.kt
│   └── usecase/GetAuthUseCase.kt
└── data/
    └── repository/AuthRepositoryImpl.kt
```

### 不同 Feature 多張圖片

```
/gen-compose-jetpack doc/designs/login.png doc/designs/profile.png doc/designs/cart.png
```

產生結構：
```
feature/login/...
feature/profile/...
feature/cart/...
```

---

## 範例執行

```bash
# 單一畫面
/gen-compose-jetpack doc/designs/login.png

# 指定功能名稱
/gen-compose-jetpack doc/designs/user_form.png --feature user_profile

# 批次處理同一功能
/gen-compose-jetpack doc/designs/checkout_1.png doc/designs/checkout_2.png --feature checkout
```

---

## 驗證清單

產生程式碼後，確認：

- [ ] 無硬編碼字串（使用 `stringResource`）
- [ ] 無硬編碼顏色（使用 `MaterialTheme.colorScheme`）
- [ ] 使用 `collectAsStateWithLifecycle`
- [ ] 一次性事件使用 `Channel`
- [ ] LazyColumn items 有穩定 key
- [ ] Route 層是 Stateful，Screen 層是 Stateless
- [ ] 功能性圖示有 contentDescription
- [ ] 觸控區域至少 48dp
- [ ] UiState 的 List 使用 `ImmutableList`
- [ ] strings.xml 已更新
- [ ] 檔案放置符合 `references/file-structure.md`
- [ ] 編譯驗證通過 (`./gradlew compileDebugKotlin`)
