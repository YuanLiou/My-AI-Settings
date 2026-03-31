# 程式碼模板

## UDF 架構（Route + Screen 分離）

Route 與 Screen 分別在不同階段產生：

### Step 4A：Screen 架構（可預覽）

```kotlin
// {功能名}Screen.kt - Step 4A 產生

/**
 * Screen：純 UI，易於測試與預覽（Stateless）
 *
 * 參數皆有預設值，方便 @Preview 使用
 */
@Composable
fun {功能名}Screen(
    uiState: {功能名}UiState = {功能名}UiState(),
    onEvent: ({功能名}Event) -> Unit = {},
    modifier: Modifier = Modifier
) {
    // UI 實作
}

/**
 * Preview：用於 Android Studio 預覽 UI 佈局
 */
@Preview(showBackground = true)
@Composable
fun {功能名}ScreenPreview() {
    RealtimeAssistantTheme {
        {功能名}Screen()
    }
}
```

### Step 4B：Route 架構（連接 ViewModel）

```kotlin
// {功能名}Screen.kt - Step 4B 補充 Route

/**
 * Route：連接 ViewModel，處理導航邏輯（Stateful）
 */
@Composable
fun {功能名}Route(
    onNavigateUp: () -> Unit,
    onNavigateTo{目的地}: () -> Unit,
    viewModel: {功能名}ViewModel = viewModel(factory = /* factory */)
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    // 處理一次性導航事件
    val currentOnNavigateUp by rememberUpdatedState(onNavigateUp)
    LaunchedEffect(Unit) {
        viewModel.effect.collect { effect ->
            when (effect) {
                {功能名}Effect.NavigateUp -> currentOnNavigateUp()
            }
        }
    }

    {功能名}Screen(
        uiState = uiState,
        onEvent = viewModel::onEvent
    )
}

// Screen 函式保持不變（已在 Step 4A 產生）
```

---

## UiState 定義

```kotlin
// {功能名}UiState.kt
import kotlinx.collections.immutable.ImmutableList
import kotlinx.collections.immutable.persistentListOf

data class {功能名}UiState(
    val isLoading: Boolean = false,
    val error: String? = null,
    // 根據 state_requirements.fields 產生
    // List 類型必須使用 ImmutableList
)
```

---

## Event 定義

```kotlin
// {功能名}Event.kt

/**
 * 使用者事件定義
 */
sealed interface {功能名}Event {
    // 根據 ui_elements 的 action 產生
    data object OnBackClick : {功能名}Event
    data class OnInputChange(val value: String) : {功能名}Event
}
```

---

## Effect 定義

```kotlin
// {功能名}Effect.kt

/**
 * 一次性副作用定義
 */
sealed interface {功能名}Effect {
    data object NavigateUp : {功能名}Effect
    data class ShowSnackbar(val message: String) : {功能名}Effect
}
```

---

## ViewModel 定義（手動 DI）

```kotlin
// {功能名}ViewModel.kt
class {功能名}ViewModel(
    // 注入 UseCase
    private val get{功能名}UseCase: Get{功能名}UseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow({功能名}UiState())
    val uiState: StateFlow<{功能名}UiState> = _uiState.asStateFlow()

    // 使用 Channel 處理一次性事件
    private val _effect = Channel<{功能名}Effect>(Channel.BUFFERED)
    val effect = _effect.receiveAsFlow()

    fun onEvent(event: {功能名}Event) {
        when (event) {
            // 處理各種 Event
        }
    }
}

// {功能名}ViewModelFactory.kt
class {功能名}ViewModelFactory(
    // 依賴參數
    private val get{功能名}UseCase: Get{功能名}UseCase
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        return {功能名}ViewModel(get{功能名}UseCase) as T
    }
}
```

---

## Repository 定義

```kotlin
// domain/repository/{功能名}Repository.kt
interface {功能名}Repository {
    suspend fun get{功能名}(): Result<{Model}>
}

// data/repository/{功能名}RepositoryImpl.kt
class {功能名}RepositoryImpl : {功能名}Repository {
    override suspend fun get{功能名}(): Result<{Model}> {
        // 實作
    }
}
```

---

## UseCase 定義

```kotlin
// domain/usecase/Get{功能名}UseCase.kt
class Get{功能名}UseCase(
    private val repository: {功能名}Repository
) {
    suspend operator fun invoke(): Result<{Model}> {
        return repository.get{功能名}()
    }
}
```
