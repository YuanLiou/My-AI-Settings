# Compose 效能優化

## Compose 三個執行階段

1. **Composition（組合）** - 執行 @Composable 函式，State 變化觸發重組
2. **Layout（佈局）** - 測量大小、決定位置
3. **Drawing（繪製）** - `graphicsLayer` 在此階段執行，效能最佳

## 穩定性 (Stability)

### 解決 List 不穩定問題

```kotlin
// ✓ 使用 ImmutableList
import kotlinx.collections.immutable.ImmutableList
import kotlinx.collections.immutable.persistentListOf

data class UserListState(
    val users: ImmutableList<User> = persistentListOf()
)
```

### @Immutable vs @Stable

| 註解           | 語意       | 使用時機                    |
|--------------|----------|-------------------------|
| `@Immutable` | 建構後永不改變  | data class、值物件          |
| `@Stable`    | 可變但變化可追蹤 | 包含 `mutableStateOf` 的類別 |

## LazyColumn/LazyRow 優化

```kotlin
LazyColumn {
    items(
        items = users,
        key = { user -> user.id },           // 必須提供
        contentType = { "user_item" }        // 異質列表時使用
    ) { user ->
        UserItem(user = user, modifier = Modifier.animateItem())
    }
}
```

## Lambda 穩定性

```kotlin
// build.gradle.kts - Strong Skipping Mode (Compose Compiler 2.0+ 預設啟用)
android {
    composeCompiler {
        enableStrongSkipping = true
    }
}
```

## 使用 graphicsLayer 做動畫

```kotlin
// ✓ 正確：在繪製階段執行，不觸發重組
Box(modifier = Modifier.graphicsLayer {
    scaleX = scale
    scaleY = scale
    alpha = alphaValue
})

// ❌ 避免：每次都觸發重組
Box(modifier = Modifier.scale(scale).alpha(alphaValue))
```

## Compose Compiler Reports

```kotlin
// build.gradle.kts
android {
    composeCompiler {
        reportsDestination = layout.buildDirectory.dir("compose_compiler")
        metricsDestination = layout.buildDirectory.dir("compose_compiler")
    }
}
```

執行 `./gradlew assembleRelease` 後查看報告，目標讓所有參數都是 `stable`。

## 效能檢查清單

- [ ] LazyColumn/LazyRow 有穩定 key
- [ ] 異質列表使用 `contentType`
- [ ] 複雜計算使用 `remember` 快取
- [ ] UiState 使用 `ImmutableList`
- [ ] Transform 動畫使用 `graphicsLayer`
- [ ] 高頻 Modifier 使用 `Modifier.Node`
