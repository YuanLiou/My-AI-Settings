# 文字樣式與字體對照表

## 文字樣式對應表

| 分析結果              | Compose 樣式                                |
|-------------------|-------------------------------------------|
| `display_large`   | `MaterialTheme.typography.displayLarge`   |
| `headline_large`  | `MaterialTheme.typography.headlineLarge`  |
| `headline_medium` | `MaterialTheme.typography.headlineMedium` |
| `title_large`     | `MaterialTheme.typography.titleLarge`     |
| `title_medium`    | `MaterialTheme.typography.titleMedium`    |
| `body_large`      | `MaterialTheme.typography.bodyLarge`      |
| `body_medium`     | `MaterialTheme.typography.bodyMedium`     |
| `label_large`     | `MaterialTheme.typography.labelLarge`     |
| `label_medium`    | `MaterialTheme.typography.labelMedium`    |

---

## 字體轉換對照表

### Material Typography → Compose

| 分析結果 text_style   | Compose                                   |
|-------------------|-------------------------------------------|
| `display_large`   | `MaterialTheme.typography.displayLarge`   |
| `display_medium`  | `MaterialTheme.typography.displayMedium`  |
| `display_small`   | `MaterialTheme.typography.displaySmall`   |
| `headline_large`  | `MaterialTheme.typography.headlineLarge`  |
| `headline_medium` | `MaterialTheme.typography.headlineMedium` |
| `headline_small`  | `MaterialTheme.typography.headlineSmall`  |
| `title_large`     | `MaterialTheme.typography.titleLarge`     |
| `title_medium`    | `MaterialTheme.typography.titleMedium`    |
| `title_small`     | `MaterialTheme.typography.titleSmall`     |
| `body_large`      | `MaterialTheme.typography.bodyLarge`      |
| `body_medium`     | `MaterialTheme.typography.bodyMedium`     |
| `body_small`      | `MaterialTheme.typography.bodySmall`      |
| `label_large`     | `MaterialTheme.typography.labelLarge`     |
| `label_medium`    | `MaterialTheme.typography.labelMedium`    |
| `label_small`     | `MaterialTheme.typography.labelSmall`     |

---

## 精確字體尺寸 → Compose

當分析結果提供精確的 font_size_sp 且與 text_style 偏差 > 2sp：

```kotlin
Text(
    text = "...",
    style = MaterialTheme.typography.bodyLarge.copy(
        fontSize = 18.sp,      // 覆蓋預設的 16sp
        lineHeight = 26.sp,    // 覆蓋預設的 24sp
        fontWeight = FontWeight.W600  // 覆蓋預設的 400
    )
)
```

---

## Font Weight 對照

| 分析結果 font_weight | Compose                 |
|------------------|-------------------------|
| 100              | `FontWeight.Thin`       |
| 200              | `FontWeight.ExtraLight` |
| 300              | `FontWeight.Light`      |
| 400              | `FontWeight.Normal`     |
| 500              | `FontWeight.Medium`     |
| 600              | `FontWeight.SemiBold`   |
| 700              | `FontWeight.Bold`       |
| 800              | `FontWeight.ExtraBold`  |
| 900              | `FontWeight.Black`      |

---

## 字體樣式組合範例

```kotlin
// 使用 Material Typography
Text(
    text = stringResource(R.string.title),
    style = MaterialTheme.typography.headlineMedium,
    color = MaterialTheme.colorScheme.onSurface
)

// 使用精確值覆蓋
Text(
    text = stringResource(R.string.subtitle),
    style = MaterialTheme.typography.bodyLarge.copy(
        fontSize = 18.sp,
        fontWeight = FontWeight.SemiBold,
        letterSpacing = 0.5.sp
    ),
    color = MaterialTheme.colorScheme.onSurfaceVariant
)

// 使用 hex 顏色
Text(
    text = stringResource(R.string.brand_text),
    style = MaterialTheme.typography.titleMedium,
    color = Color(0xFF6B4EE6)  // 品牌色
)
```
