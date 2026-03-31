# 顏色對照表

## 顏色角色對應表

| 分析結果            | Compose 顏色                               |
|-----------------|------------------------------------------|
| `primary`       | `MaterialTheme.colorScheme.primary`      |
| `secondary`     | `MaterialTheme.colorScheme.secondary`    |
| `tertiary`      | `MaterialTheme.colorScheme.tertiary`     |
| `error`         | `MaterialTheme.colorScheme.error`        |
| `surface`       | `MaterialTheme.colorScheme.surface`      |
| `background`    | `MaterialTheme.colorScheme.background`   |
| `on_primary`    | `MaterialTheme.colorScheme.onPrimary`    |
| `on_surface`    | `MaterialTheme.colorScheme.onSurface`    |
| `on_background` | `MaterialTheme.colorScheme.onBackground` |

---

## 顏色轉換對照表

### Material Color Role → Compose

| 分析結果 color_role          | Compose                                          |
|--------------------------|--------------------------------------------------|
| `primary`                | `MaterialTheme.colorScheme.primary`              |
| `on_primary`             | `MaterialTheme.colorScheme.onPrimary`            |
| `primary_container`      | `MaterialTheme.colorScheme.primaryContainer`     |
| `on_primary_container`   | `MaterialTheme.colorScheme.onPrimaryContainer`   |
| `secondary`              | `MaterialTheme.colorScheme.secondary`            |
| `on_secondary`           | `MaterialTheme.colorScheme.onSecondary`          |
| `tertiary`               | `MaterialTheme.colorScheme.tertiary`             |
| `on_tertiary`            | `MaterialTheme.colorScheme.onTertiary`           |
| `surface`                | `MaterialTheme.colorScheme.surface`              |
| `on_surface`             | `MaterialTheme.colorScheme.onSurface`            |
| `on_surface_variant`     | `MaterialTheme.colorScheme.onSurfaceVariant`     |
| `surface_container`      | `MaterialTheme.colorScheme.surfaceContainer`     |
| `surface_container_high` | `MaterialTheme.colorScheme.surfaceContainerHigh` |
| `surface_container_low`  | `MaterialTheme.colorScheme.surfaceContainerLow`  |
| `background`             | `MaterialTheme.colorScheme.background`           |
| `on_background`          | `MaterialTheme.colorScheme.onBackground`         |
| `outline`                | `MaterialTheme.colorScheme.outline`              |
| `outline_variant`        | `MaterialTheme.colorScheme.outlineVariant`       |
| `error`                  | `MaterialTheme.colorScheme.error`                |
| `on_error`               | `MaterialTheme.colorScheme.onError`              |

### Hex Color → Compose

| 分析結果                      | Compose                                |
|---------------------------|----------------------------------------|
| `#RRGGBB`                 | `Color(0xFFRRGGBB)`                    |
| `#RRGGBB` + opacity `0.5` | `Color(0xFFRRGGBB).copy(alpha = 0.5f)` |

---

## 顏色使用規則

1. **優先使用 color_role**：確保深色模式相容
2. **僅在必要時使用 hex**：品牌色或設計指定的特殊色
3. **處理 opacity**：使用 `.copy(alpha = X)`
