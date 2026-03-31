# UI 元素與 Layout 對照表

## UI 元素對應表

| 分析結果          | Compose 元件                                              |
|---------------|---------------------------------------------------------|
| `text`        | `Text`                                                  |
| `text_field`  | `OutlinedTextField`                                     |
| `button`      | `Button` / `OutlinedButton` / `TextButton`              |
| `icon_button` | `IconButton`                                            |
| `image`       | `AsyncImage` (Coil)                                     |
| `card`        | `Card` / `ElevatedCard`                                 |
| `list_item`   | `ListItem`                                              |
| `checkbox`    | `Checkbox`                                              |
| `switch`      | `Switch`                                                |
| `radio`       | `RadioButton`                                           |
| `slider`      | `Slider`                                                |
| `progress`    | `LinearProgressIndicator` / `CircularProgressIndicator` |
| `divider`     | `HorizontalDivider`                                     |
| `spacer`      | `Spacer`                                                |
| `top_app_bar` | `TopAppBar` / `CenterAlignedTopAppBar`                  |
| `bottom_nav`  | `NavigationBar`                                         |
| `fab`         | `FloatingActionButton`                                  |
| `chip`        | `AssistChip` / `FilterChip` / `InputChip`               |
| `dropdown`    | `ExposedDropdownMenuBox`                                |

---

## Layout 對應表

| 分析結果          | Compose 元件   |
|---------------|--------------|
| `column`      | `Column`     |
| `row`         | `Row`        |
| `box`         | `Box`        |
| `lazy_column` | `LazyColumn` |
| `lazy_row`    | `LazyRow`    |
| `scaffold`    | `Scaffold`   |

---

## strings.xml 命名規則

中文文字轉換為英文翻譯的 snake_case：

```xml
<!-- 「登入」→ login -->
<string name="login">登入</string>

<!-- 「電子郵件」→ email -->
<string name="email">電子郵件</string>

<!-- 「請輸入密碼」→ please_enter_password -->
<string name="please_enter_password">請輸入密碼</string>

<!-- 「歡迎回來」→ welcome_back -->
<string name="welcome_back">歡迎回來</string>
```
