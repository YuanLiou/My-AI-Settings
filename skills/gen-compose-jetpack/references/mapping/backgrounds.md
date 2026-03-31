# 背景處理策略

背景只有兩種類型：**單色** 或 **漸層**

---

## 1. 單色背景

直接使用 `Modifier.background(color)` 即可。

```kotlin
// 使用 Material color role（優先）
Box(
    modifier = Modifier
        .fillMaxSize()
        .background(MaterialTheme.colorScheme.surface)
)

// 使用精確 hex 色碼
Box(
    modifier = Modifier
        .fillMaxSize()
        .background(Color(0xFFF5F5F5))
)
```

---

## 2. 漸層背景

在 `res/drawable/` 建立漸層 XML 檔案，然後使用 `painterResource` 引用。

### 資源命名規則

```
res/drawable/
├── bg_gradient_{功能名}_{描述}.xml    # 漸層背景
```

### 漸層 XML 範例

**線性漸層** (`bg_gradient_login_header.xml`)：

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient
        android:type="linear"
        android:angle="90"
        android:startColor="#FF6B6B"
        android:endColor="#4ECDC4" />
</shape>
```

**多色線性漸層** (`bg_gradient_home_banner.xml`)：

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient
        android:type="linear"
        android:angle="135"
        android:startColor="#667eea"
        android:centerColor="#764ba2"
        android:endColor="#f953c6" />
</shape>
```

**放射狀漸層** (`bg_gradient_splash_radial.xml`)：

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient
        android:type="radial"
        android:gradientRadius="300dp"
        android:centerX="50%"
        android:centerY="50%"
        android:startColor="#FFFFFF"
        android:endColor="#E0E0E0" />
</shape>
```

### Compose 使用漸層

```kotlin
// ⚠️ 重要：painterResource 不支援 XML Shape Drawable（漸層、形狀）
// 只支援 VectorDrawables 和點陣圖資源（PNG, JPG, WebP）

// ✅ 正確做法：使用 Compose Brush API
Box(
    modifier = Modifier
        .fillMaxSize()
        .background(
            brush = Brush.linearGradient(
                colors = listOf(
                    Color(0xFF667eea),
                    Color(0xFF764ba2)
                )
            )
        )
)

// ✅ 垂直漸層範例
Box(
    modifier = Modifier
        .fillMaxSize()
        .background(
            brush = Brush.verticalGradient(
                colors = listOf(
                    Color(0xFFFFFFFF),
                    Color(0xFFE8F5E9)
                )
            )
        )
) {
    // 內容
    Column { ... }
}

// ❌ 錯誤做法：XML Shape Drawable 無法用 painterResource 載入
// Image(painter = painterResource(id = R.drawable.bg_gradient_xxx), ...)
// 會拋出 IllegalArgumentException: Only VectorDrawables and rasterized asset types are supported
```

---

## ⚠️ Drawable XML 在 Compose 中的限制

**重要：`painterResource()` 不支援 XML Shape Drawable**

| Drawable 類型               | painterResource 支援 | 建議做法                                    |
|---------------------------|--------------------|-----------------------------------------|
| VectorDrawable (.xml 向量圖) | ✅ 支援               | `Image(painter = painterResource(...))` |
| 點陣圖 (PNG, JPG, WebP)      | ✅ 支援               | `Image(painter = painterResource(...))` |
| Shape Drawable (漸層、形狀)    | ❌ 不支援              | 改用 `Modifier.background(Brush.xxx())`   |

若設計需要 XML Drawable 中的漸層效果，請使用 Compose 原生的 Brush API 重新實作。

---

## Compose 對照表

| 分析結果                         | Compose 實作                                              |
|------------------------------|---------------------------------------------------------|
| `solid_color` + `color_role` | `Modifier.background(MaterialTheme.colorScheme.{role})` |
| `solid_color` + `color_hex`  | `Modifier.background(Color(0xFF{hex}))`                 |
| `gradient`                   | `Modifier.background(Brush.linearGradient(...))`        |

---

## 何時建立 Drawable XML（僅供參考用途）

Drawable XML 檔案**僅適用於傳統 View 系統**，在 Compose 中需轉換為 Brush API：

- 漸層超過 2 個顏色 → 使用 `Brush.linearGradient(colorStops = ...)`
- 需要圓角配合漸層 → 使用 `Modifier.clip(RoundedCornerShape(...)).background(Brush.xxx())`
- 放射狀漸層 → 使用 `Brush.radialGradient(...)`
- 需要重複使用的漸層樣式 → 建立 Brush 工廠函式或常數
