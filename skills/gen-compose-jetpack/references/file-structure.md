# Android 專案檔案放置規範

此文件為 AI 助手（Claude Code、Gemini 等）在此專案中建立檔案時的放置指引。

# 專案基礎路徑結構

```
├── BaseApplication.kt              # Application 入口
├── MainActivity.kt                 # 主 Activity
│
├── core/                          # 核心模組（共用基礎設施）
│   ├── common/                    # 通用工具類別
│   │   ├── DispatcherProvider.kt  # 協程 Dispatcher 提供者
│   │   └── DomainResult.kt        # 結果包裝類別
│   ├── constant/                  # 全域常數
│   ├── container/                 # 依賴注入容器（Manual DI）
│   │   ├── AppContainer.kt        # 依賴容器介面
│   │   └── DefaultAppContainer.kt # 依賴容器實作
│   ├── database/                  # Room 資料庫配置
│   ├── datastore/                 # DataStore 偏好設定
│   ├── navigation/                # 導航系統
│   ├── network/                   # 網路層配置
│   └── ui/                        # 共用 UI 元件
│       ├── screens/               # 共用畫面（Home、Detail、Settings）
│       └── theme/                 # 主題設定
│
└── feature/                       # 功能模組（按功能分組）
    └── sample/                    # Clean Architecture 範例       
        ├── data/                   # Data Layer（資料存取實作）
        │   ├── repository/        # Repository 實作
        │   ├── mapper/            # 資料映射
        │   ├── remote/            # 遠端資料來源（API）
        │   └── local/             # 本地資料來源（快取）
        │        
        ├── domain/                # Domain Layer（核心業務邏輯）
        │   ├── model/             # 領域模型
        │   ├── repository/        # Repository 介面
        │   └── usecase/           # 業務用例
        │
        └── ui/                    # Presentation Layer（UI）
            ├── screen/            # Composable 畫面
            ├── state/             # UI 狀態類別
            ├── viewmodel/         # ViewModel
            └── component/         # 功能專屬 UI 元件                     
```

---

## 快速決策指引

根據你要建立的檔案類型，快速找到正確位置：

| 如果是...                        | 放在...                                           |
|-------------------------------|-------------------------------------------------|
| 新功能模組（登入、購物車、個人資料等）           | `feature/{功能名}/`                                |
| 共用工具類別（Extension、Helper、Util） | `core/common/`                                  |
| 全域常數（API URL、Key、設定值）         | `core/constant/`                                |
| 依賴注入相關                        | `core/container/`                               |
| Room 資料庫（Database、Dao、Entity） | `core/database/`                                |
| DataStore 偏好設定                | `core/datastore/`                               |
| 網路客戶端設定（Ktor、OkHttp）          | `core/network/`                                 |
| 導航路由或導航元件                     | `core/navigation/`                              |
| Compose 顏色、主題、字型              | `core/ui/theme/`                                |
| 核心共用畫面（首頁、設定頁等）               | `core/ui/screens/`                              |
| UI 字串資源                       | `res/values/strings.xml`                        |
| 顏色資源（XML 格式）                  | `res/values/colors.xml`                         |
| 向量圖、圖片資源                      | `res/drawable/`                                 |
| 單元測試                          | `test/java/com/example/androidtemplate/`        |
| 整合測試（UI 測試）                   | `androidTest/java/com/example/androidtemplate/` |

---

## 核心層（core/）詳細規範

核心層存放可跨功能模組複用的共用程式碼。

### core/common/

**用途**：共用工具類別、擴充函式、通用型別

**應放入的檔案**：

- `*Extension.kt` - Kotlin 擴充函式
- `*Helper.kt` - 輔助工具類別
- `*Util.kt` - 工具函式
- `DomainResult.kt` - 通用結果封裝
- `DispatcherProvider.kt` - 協程 Dispatcher 提供者

**範例**：

```
core/common/
├── StringExtension.kt
├── DateHelper.kt
├── ValidationUtil.kt
├── DomainResult.kt
└── DispatcherProvider.kt
```

---

### core/constant/

**用途**：全域常數定義

**應放入的檔案**：

- `GlobalConstants.kt` - 應用程式級常數
- `*Constants.kt` - 特定領域常數（如 `ApiConstants.kt`）

**範例**：

```kotlin
// GlobalConstants.kt
object GlobalConstants {
    const val DATABASE_NAME = "app_database"
    const val CONNECT_TIMEOUT = 30_000L
}
```

---

### core/container/

**用途**：手動依賴注入容器

**應放入的檔案**：

- `AppContainer.kt` - 容器介面
- `DefaultAppContainer.kt` - 容器實作
- `*Module.kt` - 模組化的依賴提供者

---

### core/database/

**用途**：Room 資料庫相關

**應放入的檔案**：

- `AppDatabase.kt` - Room 資料庫定義
- `*Dao.kt` - 資料存取物件
- `*Entity.kt` - 資料庫實體
- `Converters.kt` - 型別轉換器

**範例**：

```
core/database/
├── AppDatabase.kt
├── UserDao.kt
├── UserEntity.kt
├── OrderDao.kt
├── OrderEntity.kt
└── Converters.kt
```

---

### core/datastore/

**用途**：DataStore 偏好設定儲存

**應放入的檔案**：

- `PreferencesManager.kt` - 偏好設定管理
- `*DataStore.kt` - 特定資料儲存

---

### core/network/

**用途**：網路客戶端設定

**應放入的檔案**：

- `KtorClient.kt` - Ktor HTTP 客戶端
- `*ApiService.kt` - 共用 API 服務介面
- `*Interceptor.kt` - 請求攔截器
- `NetworkConfig.kt` - 網路設定

---

### core/navigation/

**用途**：應用程式導航

**應放入的檔案**：

- `NavRoute.kt` - 導航路由定義（類型安全）
- `NavGraph.kt` - 導航圖建立
- `*NavigationBar.kt` - 導航列元件

---

### core/ui/theme/

**用途**：Compose UI 主題定義

**應放入的檔案**：

- `Color.kt` - 顏色定義（Compose 格式）
- `Theme.kt` - 主題設定
- `Type.kt` - 文字樣式

**顏色命名規則**：

```kotlin
// Color.kt - 使用 Color色碼 格式
val ColorFf7d5260 = Color(0xFF7D5260)
val ColorFf625b71 = Color(0xFF625B71)
```

---

### core/ui/screens/

**用途**：核心共用畫面

**應放入的檔案**：

- `HomeScreen.kt` - 首頁
- `SettingsScreen.kt` - 設定頁
- `DetailScreen.kt` - 詳情頁
- 其他跨功能的共用畫面

---

## 功能層（feature/）詳細規範

每個功能模組遵循 Clean Architecture 三層結構。

### 功能模組結構

```
feature/{功能名}/
├── domain/                 # Domain Layer（核心業務邏輯）
│   ├── model/             # 領域模型
│   ├── repository/        # Repository 介面
│   └── usecase/           # 業務用例
│
├── data/                   # Data Layer（資料存取實作）
│   ├── repository/        # Repository 實作
│   ├── mapper/            # 資料映射
│   ├── remote/            # 遠端資料來源（API）
│   └── local/             # 本地資料來源（快取）
│
└── ui/                     # Presentation Layer（UI）
    ├── screen/            # Composable 畫面
    ├── state/             # UI 狀態類別
    ├── viewmodel/         # ViewModel
    └── component/         # 功能專屬 UI 元件
```

### 各層檔案命名規則

#### domain/model/

```kotlin
// {功能名}.kt 或 {實體名}.kt
// 範例：User.kt, Product.kt, Order.kt
data class User(
    val id: String,
    val name: String
)
```

#### domain/repository/

```kotlin
// {功能名}Repository.kt
// 範例：UserRepository.kt, ProductRepository.kt
interface UserRepository {
    suspend fun getUser(id: String): DomainResult<User>
}
```

#### domain/usecase/

```kotlin
// {動作}{實體}UseCase.kt
// 範例：GetUserUseCase.kt, UpdateProfileUseCase.kt
class GetUserUseCase(private val repository: UserRepository) {
    suspend operator fun invoke(id: String): DomainResult<User>
}
```

#### data/repository/

```kotlin
// {功能名}RepositoryImpl.kt
// 範例：UserRepositoryImpl.kt
class UserRepositoryImpl(
    private val api: UserApiService
) : UserRepository
```

#### data/mapper/

```kotlin
// {功能名}Mapper.kt
// 範例：UserMapper.kt
object UserMapper {
    fun UserEntity.toDomain(): User
    fun User.toEntity(): UserEntity
}
```

#### ui/screen/

```kotlin
// {功能名}Screen.kt
// 範例：LoginScreen.kt, ProfileScreen.kt
@Composable
fun LoginScreen(viewModel: LoginViewModel) { }
```

#### ui/state/

```kotlin
// {功能名}UiState.kt
// 範例：LoginUiState.kt
data class LoginUiState(
    val isLoading: Boolean = false,
    val error: String? = null
)
```

#### ui/viewmodel/

```kotlin
// {功能名}ViewModel.kt
// {功能名}ViewModelFactory.kt（如果使用手動 DI）
// 範例：LoginViewModel.kt
class LoginViewModel : ViewModel() { }
```

---

## 資源層（res/）詳細規範

### res/values/strings.xml

**用途**：所有 UI 顯示文字

**命名規則**：直接使用英文翻譯，snake_case

```xml
<!-- 「設定」→ setting -->
<string name="setting">設定</string>

<!-- 「這是設定頁面」→ this_is_the_settings_page -->
<string name="this_is_the_settings_page">這是設定頁面</string>

<!-- 「登入」→ login -->
<string name="login">登入</string>
```

### res/values/colors.xml

**用途**：XML 格式顏色定義（用於非 Compose 元件）

**命名規則**：`color_色碼`，全小寫

```xml
<!-- 不透明色碼 -->
<color name="color_ffffff">#FFFFFFFF</color>
<color name="color_000000">#FF000000</color>

<!-- 透明色碼（需包含透明度） -->
<color name="color_80000000">#80000000</color>
```

### res/drawable/

**用途**：向量圖、圖片資源

**檔案類型**：

- `ic_*.xml` - 圖示（icon）
- `bg_*.xml` - 背景（background）
- `img_*.png/webp` - 圖片（image）

### res/xml/

**用途**：配置檔案

**常見檔案**：

- `network_security_config.xml` - 網路安全設定
- `backup_rules.xml` - 備份規則
- `data_extraction_rules.xml` - 資料擷取規則

---

## 測試層詳細規範

### 單元測試 (test/)

**路徑**：`app/src/test/java/com/example/androidtemplate/`

**結構**：鏡像對應主程式結構

```
test/java/com/example/androidtemplate/
├── feature/
│   └── login/
│       ├── domain/usecase/
│       │   └── LoginUseCaseTest.kt
│       └── ui/viewmodel/
│           └── LoginViewModelTest.kt
└── core/
    └── common/
        └── ValidationUtilTest.kt
```

**命名規則**：`{被測試類別名}Test.kt`

### 整合測試 (androidTest/)

**路徑**：`app/src/androidTest/java/com/example/androidtemplate/`

**命名規則**：`{被測試畫面}Test.kt` 或 `{功能}IntegrationTest.kt`

---

## 常見場景範例

### 場景 1：新增「登入」功能

需要建立的檔案：

```
feature/login/
├── domain/
│   ├── model/
│   │   └── LoginResult.kt
│   ├── repository/
│   │   └── AuthRepository.kt
│   └── usecase/
│       └── LoginUseCase.kt
├── data/
│   ├── repository/
│   │   └── AuthRepositoryImpl.kt
│   └── mapper/
│       └── AuthMapper.kt
└── ui/
    ├── screen/
    │   └── LoginScreen.kt
    ├── state/
    │   └── LoginUiState.kt
    └── viewmodel/
        ├── LoginViewModel.kt
        └── LoginViewModelFactory.kt
```

額外修改：

- `core/navigation/NavRoute.kt` - 新增登入路由
- `core/container/DefaultAppContainer.kt` - 註冊依賴
- `res/values/strings.xml` - 新增登入相關字串

---

### 場景 2：新增 API 服務

僅供單一功能使用：

```
feature/{功能名}/data/remote/
└── {功能名}ApiService.kt
```

跨功能共用：

```
core/network/
└── {服務名}ApiService.kt
```

---

### 場景 3：新增資料庫表格

```
core/database/
├── {表格名}Dao.kt
└── {表格名}Entity.kt
```

並修改 `AppDatabase.kt` 新增 Dao 和 Entity。

---

### 場景 4：新增共用 UI 元件

僅供單一功能使用：

```
feature/{功能名}/ui/component/
└── {元件名}.kt
```

跨功能共用：

```
core/ui/component/
└── {元件名}.kt
```

---

## 禁止事項

1. **禁止**在 `feature/` 外直接建立功能程式碼
2. **禁止**將功能專屬程式碼放入 `core/`
3. **禁止**在 Kotlin 程式碼中硬編碼顏色值或字串
4. **禁止**將 Repository 實作放在 `domain/` 層
5. **禁止**將 UseCase 放在 `data/` 或 `ui/` 層

## 禁止事項

1. ❌ 禁止在 `feature/` 外直接建立功能程式碼
2. ❌ 禁止將功能專屬程式碼放入 `core/`
3. ❌ 禁止在 Kotlin 程式碼中硬編碼顏色值或字串
4. ❌ 禁止將 Repository 實作放在 `domain/` 層
5. ❌ 禁止將 UseCase 放在 `data/` 或 `ui/` 層

