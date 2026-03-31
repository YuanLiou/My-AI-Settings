# Compose 無障礙性

## contentDescription 規則

```kotlin
// 功能性元素必須有描述
Icon(
    imageVector = Icons.Default.Favorite,
    contentDescription = stringResource(R.string.add_to_favorites)
)

// 裝飾性元素設為 null
Icon(
    imageVector = Icons.Default.Star,
    contentDescription = null  // 純裝飾，不需要朗讀
)
```

## 合併語意

```kotlin
// 清除子元素語意，只保留此層級描述
Row(
    modifier = modifier
        .clickable(onClick = onClick)
        .clearAndSetSemantics {
            contentDescription = "${user.name}, ${user.title}"
            role = Role.Button
        }
) {
    Avatar(user.avatarUrl)
    Text(user.name)
}
```

## 狀態描述

```kotlin
Row(
    modifier = Modifier.semantics {
        stateDescription = if (expanded) "已展開" else "已收合"
        role = Role.Button
    }
)
```

## Live Region（動態更新通知）

```kotlin
// 錯誤訊息：立即朗讀
Text(
    text = errorMessage,
    modifier = Modifier.semantics {
        liveRegion = LiveRegionMode.Assertive
    }
)

// 倒數計時：等待當前朗讀完成
Text(
    text = "剩餘 $seconds 秒",
    modifier = Modifier.semantics {
        liveRegion = LiveRegionMode.Polite
    }
)
```

## 觸控目標大小

```kotlin
// 確保至少 48dp x 48dp
IconButton(
    onClick = {},
    modifier = Modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)
) {
    Icon(Icons.Default.Close, contentDescription = stringResource(R.string.close))
}

// 或使用 minimumInteractiveComponentSize
Icon(
    modifier = Modifier
        .minimumInteractiveComponentSize()
        .clickable(onClick = onClick)
)
```

## 檢查清單

| 類型        | 要求                                   |
|-----------|--------------------------------------|
| **圖示/圖片** | 功能性必須有 contentDescription；裝飾性設為 null |
| **按鈕**    | 清楚描述動作（「刪除項目」而非「刪除」）                 |
| **狀態**    | 使用 stateDescription 描述開關、展開等狀態       |
| **列表項目**  | 使用 clearAndSetSemantics 合併描述         |
| **錯誤訊息**  | 使用 liveRegion 立即通知                   |
| **觸控區域**  | 至少 48dp x 48dp                       |
| **顏色對比**  | 文字與背景對比度至少 4.5:1                     |
