# Jetpack Compose UI 規範

## 功能與版本對照表

| 功能                            | 最低版本要求                           | 備註                              |
|-------------------------------|----------------------------------|---------------------------------|
| `collectAsStateWithLifecycle` | lifecycle-runtime-compose 2.6.0+ | 取代 `collectAsState`             |
| Type-Safe Navigation          | navigation-compose 2.8.0+        | 需 kotlinx-serialization         |
| `animateItem` (LazyColumn)    | compose-foundation 1.7.0+        | 1.6 及之前用 `animateItemPlacement` |
| Shared Element Transitions    | compose-animation 1.7.0+         | 需 navigation-compose 2.8.0+     |
| `Modifier.Node`               | compose-ui 1.3.0+                | 取代 `Modifier.composed`          |
| Strong Skipping Mode          | Compose Compiler 2.0.0+          | 預設啟用                            |

## 架構模式：單向資料流 (UDF)

```
 ViewModel (StateFlow) → Route (Stateful) → Screen (Stateless)
         ↑                                        │
         └────────── Event ───────────────────────┘
```

## Composable 參數順序

```kotlin
@Composable
fun UserCard(
    // 1. 必要資料
    user: User,
    // 2. 必要回調
    onClick: () -> Unit,
    // 3. Modifier
    modifier: Modifier = Modifier,
    // 4. 可選回調
    onLongClick: (() -> Unit)? = null,
    // 5. 可選設定
    showAvatar: Boolean = true
) { }
```

## Modifier 建議順序

1. **佈局約束**：`fillMaxWidth`、`size`、`weight`
2. **外部裝飾**：`shadow`、`border`
3. **背景與形狀**：`clip`、`background`
4. **內邊距**：`padding`
5. **互動**：`clickable`、`selectable`

## Side Effects 選擇指南

| 情境                     | 使用                                 |
|------------------------|------------------------------------|
| 初始載入資料                 | ViewModel `init`                   |
| key 變化時執行              | `LaunchedEffect(key)`              |
| 訂閱一次性事件                | `LaunchedEffect(Unit)` + `collect` |
| 需要清理資源                 | `DisposableEffect`                 |
| 長期 effect 中引用最新 Lambda | `rememberUpdatedState`             |
| 監聽 State 變化            | `snapshotFlow`                     |

## 禁止事項（Critical）

| 禁止項目                         | 正確做法                                        |
|------------------------------|---------------------------------------------|
| 硬編碼字串                        | `stringResource(R.string.xxx)`              |
| 在 Composable 內建構 ViewModel   | `hiltViewModel()` 或 `viewModel()`           |
| 使用 GlobalScope               | `viewModelScope` 或 `rememberCoroutineScope` |
| SharedFlow(replay=0) 發送一次性事件 | 使用 `Channel`                                |
| derivedStateOf 追蹤函式參數        | 使用 `remember(keys)`                         |
| @Immutable 標註可變類別            | 只對不可變類別使用                                   |

## 禁止事項（High）

| 禁止項目                       | 正確做法                                |
|----------------------------|-------------------------------------|
| 硬編碼顏色                      | `MaterialTheme.colorScheme.xxx`     |
| collectAsState 訂閱 Flow     | `collectAsStateWithLifecycle`       |
| collect 中直接使用外部 Lambda     | `rememberUpdatedState`              |
| UiState 使用 List            | `ImmutableList`                     |
| LazyColumn 沒有 key          | `key = { it.id }`                   |
| 功能性圖示缺少 contentDescription | 提供無障礙描述                             |
| 觸控區域小於 48dp                | `minimumInteractiveComponentSize()` |

## 必要檢查清單

- [ ] 無硬編碼字串、顏色
- [ ] 使用 `collectAsStateWithLifecycle`
- [ ] 一次性事件使用 `Channel`
- [ ] LazyColumn items 有穩定 key
- [ ] 初始載入在 ViewModel `init`
- [ ] 功能性圖示有 contentDescription
- [ ] Modifier 預設值為 `Modifier`
- [ ] Screen 層是 Stateless
