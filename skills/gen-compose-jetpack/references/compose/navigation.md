# Compose Navigation

## Type-Safe Navigation（推薦）

需要依賴：Navigation Compose 2.8.0+、kotlinx-serialization

### 定義路由

```kotlin
@Serializable
data object Home

@Serializable
data class Detail(val itemId: String)

@Serializable
data class Profile(val userId: String, val showSettings: Boolean = false)
```

### NavHost 使用

```kotlin
NavHost(navController, startDestination = Home) {
    composable<Home> {
        HomeRoute(onNavigateToDetail = { itemId -> navController.navigate(Detail(itemId)) })
    }

    composable<Detail> { backStackEntry ->
        val detail: Detail = backStackEntry.toRoute()
        DetailRoute(itemId = detail.itemId, onNavigateUp = { navController.popBackStack() })
    }
}
```

## 一次性導航事件處理

### ViewModel 設定

```kotlin
// 使用 Channel 確保事件不遺失
private val _navigationEvent = Channel<NavigationEvent>(Channel.CONFLATED)
val navigationEvent = _navigationEvent.receiveAsFlow()
```

### Route 訂閱

```kotlin
val currentOnNavigateUp by rememberUpdatedState(onNavigateUp)

LaunchedEffect(Unit) {
    viewModel.navigationEvent.collect { event ->
        when (event) {
            is NavigationEvent.NavigateUp -> currentOnNavigateUp()
        }
    }
}
```

## 為什麼用 Channel？

| 問題               | SharedFlow(replay=0) | Channel |
|------------------|----------------------|---------|
| 沒有 collector 時發送 | 事件**永久遺失**           | 事件被緩衝   |
| 畫面重建（旋轉）         | 事件消失                 | 事件保留    |

## Route vs Screen 分離

- **Route (Stateful)**：連接 ViewModel，處理導航邏輯
- **Screen (Stateless)**：純 UI，易於測試與預覽

## 檢查清單

- [ ] 優先使用 Type-Safe Navigation
- [ ] 一次性事件使用 `Channel`
- [ ] 導航用 `Channel.CONFLATED`
- [ ] collect 中使用 `rememberUpdatedState`
- [ ] Route 負責導航邏輯，Screen 保持 Stateless
