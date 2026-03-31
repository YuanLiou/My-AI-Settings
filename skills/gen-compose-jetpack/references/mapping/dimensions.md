# 尺寸轉換對照表

## Width

| 分析結果                    | Compose               |
|-------------------------|-----------------------|
| `match_parent` / `100%` | `.fillMaxWidth()`     |
| `wrap_content`          | 不加 modifier           |
| `50%`                   | `.fillMaxWidth(0.5f)` |
| `200`                   | `.width(200.dp)`      |

---

## Height

| 分析結果                | Compose                  |
|---------------------|--------------------------|
| `match_parent`      | `.fillMaxHeight()`       |
| `56`                | `.height(56.dp)`         |
| aspect_ratio `16:9` | `.aspectRatio(16f / 9f)` |

---

## Corner Radius

| 分析結果       | Compose                                                   |
|------------|-----------------------------------------------------------|
| `all = 0`  | `RectangleShape`                                          |
| `all = 12` | `RoundedCornerShape(12.dp)`                               |
| `pill`     | `CircleShape`                                             |
| 不同角落       | `RoundedCornerShape(topStart = X.dp, topEnd = Y.dp, ...)` |

---

## Elevation

| 分析結果             | Compose                        |
|------------------|--------------------------------|
| `none` / `0`     | 不加 shadow                      |
| `low` / `1-2`    | `Modifier.shadow(2.dp, shape)` |
| `medium` / `4-6` | `Modifier.shadow(4.dp, shape)` |
| `high` / `8-12`  | `Modifier.shadow(8.dp, shape)` |
| 具體 dp 值          | `Modifier.shadow(X.dp, shape)` |

---

## Spacing

| 分析結果                               | Compose                                                        |
|------------------------------------|----------------------------------------------------------------|
| `margin_top: 16`                   | `Modifier.padding(top = 16.dp)`                                |
| `margin_start: 16, margin_end: 16` | `Modifier.padding(horizontal = 16.dp)`                         |
| `padding_horizontal: 16`           | 元件內部 `contentPadding` 或 `Modifier.padding(horizontal = 16.dp)` |
