---
name: error-handling-patterns
description: Master Kotlin error handling patterns including sealed classes, Result types, coroutine error propagation, and graceful degradation to build resilient Android/KMP applications. Use when implementing error handling, designing APIs, or improving application reliability.
---

# Error Handling Patterns

Build resilient Kotlin applications with strong error handling strategies that gracefully handle failures and provide excellent debugging experiences.

## When to use this skill

- Implementing error handling in new features
- Designing error-resilient APIs
- Debugging production issues
- Improving application reliability
- Creating better error messages for users and developers
- Implementing retry and circuit breaker patterns
- Handling coroutine errors
- Building fault-tolerant network layers

## Core Concepts

### 1. Error handling philosophies

**Exceptions vs Result Types:**

- **Exceptions**: Traditional try-catch, disrupts control flow
- **Result Types**: Explicit success/failure, functional approach
- **Sealed Classes**: Type-safe error hierarchies with exhaustive `when`
- **Nullable Types**: Kotlin's null safety for optional values

**When to use each:**

- Exceptions: Unexpected errors, exceptional conditions
- Result/Sealed Classes: Expected errors, validation failures
- `require`/`check`/`error`: Unrecoverable errors, programming bugs

### 2. Error categories

**Recoverable Errors:**

- Network timeouts
- Missing files
- Invalid user input
- API rate limits

**Unrecoverable Errors:**

- Out of memory
- Stack overflow
- Programming bugs (illegal state, etc.)

## Kotlin Error Handling Patterns

### Sealed class error hierarchy

```kotlin
// Sealed class for exhaustive error handling
sealed class AppError(
    val message: String,
    val code: String,
    val cause: Throwable? = null
) {
    class NotFound(
        resource: String,
        id: String
    ) : AppError("$resource not found", "NOT_FOUND")

    class Validation(
        message: String,
        val field: String
    ) : AppError(message, "VALIDATION_ERROR")

    class Network(
        message: String,
        cause: Throwable? = null
    ) : AppError(message, "NETWORK_ERROR", cause)

    class Unauthorized(
        message: String = "Authentication required"
    ) : AppError(message, "UNAUTHORIZED")
}

// Usage with when expression (compiler enforces exhaustiveness)
fun handleError(error: AppError) {
    when (error) {
        is AppError.NotFound -> showNotFoundScreen()
        is AppError.Validation -> showFieldError(error.field, error.message)
        is AppError.Network -> showRetryDialog()
        is AppError.Unauthorized -> navigateToLogin()
    }
}
```

### Result type with `runCatching`

```kotlin
// Kotlin's built-in Result type
fun parseUserJson(json: String): Result<User> = runCatching {
    Json.decodeFromString<User>(json)
}

// Chaining with map, recover, fold
fun fetchAndParseUser(userId: String): Result<UserProfile> {
    return runCatching { api.fetchUser(userId) }
        .map { user -> user.toProfile() }
        .recover { error ->
            when (error) {
                is HttpException -> cache.getCachedProfile(userId)
                else -> throw error
            }
        }
}

// Consuming Result
val result = parseUserJson(jsonString)
result.fold(
    onSuccess = { user -> displayUser(user) },
    onFailure = { error -> showError(error.message) }
)

// Or use getOrElse / getOrNull
val user = parseUserJson(jsonString).getOrElse { defaultUser }
val userOrNull = parseUserJson(jsonString).getOrNull()
```

### Custom Result with sealed class (domain errors)

```kotlin
// When you need typed errors instead of Throwable
sealed class DomainResult<out T> {
    data class Success<T>(val data: T) : DomainResult<T>()
    data class Failure(val error: AppError) : DomainResult<Nothing>()

    fun <R> map(transform: (T) -> R): DomainResult<R> = when (this) {
        is Success -> Success(transform(data))
        is Failure -> this
    }

    fun <R> flatMap(transform: (T) -> DomainResult<R>): DomainResult<R> =
        when (this) {
            is Success -> transform(data)
            is Failure -> this
        }

    fun getOrNull(): T? = when (this) {
        is Success -> data
        is Failure -> null
    }
}

// Usage in repository
class AttendeeRepository(private val api: ApiService) {
    suspend fun getAttendee(id: String): DomainResult<Attendee> {
        return try {
            val response = api.getAttendee(id)
            if (response.isSuccessful) {
                DomainResult.Success(response.body()!!)
            } else {
                DomainResult.Failure(
                    AppError.NotFound("Attendee", id)
                )
            }
        } catch (e: IOException) {
            DomainResult.Failure(
                AppError.Network("Connection failed", cause = e)
            )
        }
    }
}
```

### Coroutine error handling

```kotlin
import kotlinx.coroutines.*

// SupervisorJob: child failure doesn't cancel siblings
val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

// CoroutineExceptionHandler for uncaught exceptions
val exceptionHandler = CoroutineExceptionHandler { _, throwable ->
    Logger.e("Coroutine failed", throwable)
    showErrorToUser(throwable.message)
}

scope.launch(exceptionHandler) {
    val user = async { fetchUser(userId) }
    val orders = async { fetchOrders(userId) }

    try {
        displayDashboard(user.await(), orders.await())
    } catch (e: CancellationException) {
        throw e // Never swallow CancellationException
    } catch (e: Exception) {
        handleError(e)
    }
}

// Structured concurrency with supervisorScope
suspend fun loadDashboard(userId: String): Dashboard {
    return supervisorScope {
        val userDeferred = async { fetchUser(userId) }
        val ordersDeferred = async {
            // This failure won't cancel userDeferred
            fetchOrders(userId)
        }

        val user = userDeferred.await()
        val orders = runCatching { ordersDeferred.await() }
            .getOrElse { emptyList() } // Graceful fallback

        Dashboard(user, orders)
    }
}
```

### Resource cleanup with `use` and `Closeable`

```kotlin
// Automatic resource cleanup via use extension
fun readConfig(path: String): Result<Config> = runCatching {
    File(path).bufferedReader().use { reader ->
        Json.decodeFromString<Config>(reader.readText())
    }
}

// Custom Closeable for cleanup
class DatabaseConnection(private val url: String) : Closeable {
    private val connection = DriverManager.getConnection(url)

    fun query(sql: String): ResultSet = connection.createStatement().executeQuery(sql)

    override fun close() {
        connection.close()
    }
}

// Usage
DatabaseConnection(dbUrl).use { db ->
    val results = db.query("SELECT * FROM users")
    // Connection auto-closes even if exception occurs
}
```

## Universal Patterns

### Pattern 1: Circuit breaker

Prevent cascading failures when calling external services.

```kotlin
import java.time.Duration
import java.time.Instant
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicReference

enum class CircuitState { CLOSED, OPEN, HALF_OPEN }

class CircuitBreaker(
    private val failureThreshold: Int = 5,
    private val timeout: Duration = Duration.ofSeconds(60),
    private val successThreshold: Int = 2
) {
    private val failureCount = AtomicInteger(0)
    private val successCount = AtomicInteger(0)
    private val state = AtomicReference(CircuitState.CLOSED)
    private var lastFailureTime: Instant? = null

    fun <T> call(block: () -> T): T {
        if (state.get() == CircuitState.OPEN) {
            val elapsed = Duration.between(lastFailureTime, Instant.now())
            if (elapsed > timeout) {
                state.set(CircuitState.HALF_OPEN)
                successCount.set(0)
            } else {
                throw IllegalStateException("Circuit breaker is OPEN")
            }
        }

        return try {
            val result = block()
            onSuccess()
            result
        } catch (e: Exception) {
            onFailure()
            throw e
        }
    }

    private fun onSuccess() {
        failureCount.set(0)
        if (state.get() == CircuitState.HALF_OPEN) {
            if (successCount.incrementAndGet() >= successThreshold) {
                state.set(CircuitState.CLOSED)
                successCount.set(0)
            }
        }
    }

    private fun onFailure() {
        lastFailureTime = Instant.now()
        if (failureCount.incrementAndGet() >= failureThreshold) {
            state.set(CircuitState.OPEN)
        }
    }
}

// Usage
val circuitBreaker = CircuitBreaker()

suspend fun fetchData(): Data {
    return circuitBreaker.call { externalApi.getData() }
}
```

### Pattern 2: Error aggregation

Collect multiple errors instead of failing on first error.

```kotlin
class ErrorCollector {
    private val errors = mutableListOf<AppError>()

    fun add(error: AppError) {
        errors.add(error)
    }

    fun hasErrors(): Boolean = errors.isNotEmpty()

    fun getErrors(): List<AppError> = errors.toList()

    fun throwIfErrors() {
        if (errors.isNotEmpty()) {
            throw ValidationException(errors.toList())
        }
    }
}

class ValidationException(
    val errors: List<AppError>
) : Exception("${errors.size} validation errors occurred")

// Usage: Validate multiple fields
fun validateUser(data: UserInput): User {
    val collector = ErrorCollector()

    if (data.email.isBlank()) {
        collector.add(AppError.Validation("Email is required", "email"))
    } else if (!data.email.isValidEmail()) {
        collector.add(AppError.Validation("Email is invalid", "email"))
    }

    if (data.name.length < 2) {
        collector.add(AppError.Validation("Name must be at least 2 characters", "name"))
    }

    if (data.age < 18) {
        collector.add(AppError.Validation("Age must be 18 or older", "age"))
    }

    collector.throwIfErrors()

    return data.toUser()
}
```

### Pattern 3: Graceful degradation

Provide fallback functionality when errors occur.

```kotlin
// Try primary, fall back on error
suspend fun <T> withFallback(
    primary: suspend () -> T,
    fallback: suspend () -> T,
    logError: Boolean = true
): T {
    return try {
        primary()
    } catch (e: Exception) {
        if (logError) {
            Logger.e("Primary function failed: ${e.message}", e)
        }
        fallback()
    }
}

// Usage
suspend fun getUserProfile(userId: String): UserProfile {
    return withFallback(
        primary = { fetchFromCache(userId) },
        fallback = { fetchFromDatabase(userId) }
    )
}

// Multiple fallbacks with runCatching
suspend fun getExchangeRate(currency: String): Double {
    return runCatching { apiProvider1.getRate(currency) }
        .recoverCatching { apiProvider2.getRate(currency) }
        .recoverCatching { cache.getRate(currency) }
        .getOrDefault(DEFAULT_RATE)
}
```

### Pattern 4: Retry with exponential backoff

```kotlin
import kotlinx.coroutines.delay
import kotlin.math.pow

suspend fun <T> retry(
    maxAttempts: Int = 3,
    backoffFactor: Double = 2.0,
    shouldRetry: (Exception) -> Boolean = { true },
    block: suspend () -> T
): T {
    var lastException: Exception? = null
    repeat(maxAttempts) { attempt ->
        try {
            return block()
        } catch (e: Exception) {
            lastException = e
            if (!shouldRetry(e) || attempt == maxAttempts - 1) throw e
            val sleepTime = (backoffFactor.pow(attempt) * 1000).toLong()
            delay(sleepTime)
        }
    }
    throw lastException!!
}

// Usage
suspend fun fetchData(url: String): Response {
    return retry(
        maxAttempts = 3,
        shouldRetry = { it is IOException }
    ) {
        api.get(url)
    }
}
```

## Workflow

- [ ] Identify the error category (recoverable vs unrecoverable)
- [ ] Choose sealed class vs Result vs Exception
- [ ] Define custom error types with meaningful context
- [ ] Add retry/circuit breaker for external service calls
- [ ] Add graceful degradation where appropriate
- [ ] Validate error messages are actionable
- [ ] Ensure resources are cleaned up (use `use`, `finally`)

## Best practices

1. **Fail Fast**: Validate input early with `require`, `check`, `error`
2. **Preserve Context**: Include stack traces, metadata, timestamps
3. **Meaningful Messages**: Explain what happened and how to fix it
4. **Log Appropriately**: Error = log, expected failure = don't spam logs
5. **Handle at Right Level**: Catch where you can meaningfully handle
6. **Clean Up Resources**: Use `use` extension, `finally`, or `Closeable`
7. **Don't Swallow Errors**: Log or re-throw, don't silently ignore
8. **Never Swallow CancellationException**: Always re-throw it in coroutines
9. **Type-Safe Errors**: Use sealed classes for exhaustive handling

```kotlin
// Good error handling example
suspend fun processOrder(orderId: String): DomainResult<Order> {
    // Validate input early
    require(orderId.isNotBlank()) { "Order ID is required" }

    // Fetch order
    val order = orderRepository.getOrder(orderId)
        ?: return DomainResult.Failure(AppError.NotFound("Order", orderId))

    // Process payment with wrapped error
    val paymentResult = runCatching {
        paymentService.charge(order.total)
    }.getOrElse { e ->
        Logger.e("Payment failed for order $orderId", e)
        return DomainResult.Failure(
            AppError.Network("Payment processing failed", cause = e)
        )
    }

    // Update order
    order.status = OrderStatus.COMPLETED
    order.paymentId = paymentResult.id
    orderRepository.save(order)

    return DomainResult.Success(order)
}
```

## Common pitfalls

- **Catching Too Broadly**: `catch (e: Exception)` hides bugs
- **Swallowing CancellationException**: Breaks structured concurrency
- **Empty Catch Blocks**: Silently swallowing errors
- **Logging and Re-throwing**: Creates duplicate log entries
- **Not Cleaning Up**: Forgetting to close streams and connections
- **Poor Error Messages**: "Error occurred" is not helpful
- **Ignoring Coroutine Errors**: Unhandled exceptions in `launch`

## Resources

- **references/exception-hierarchy-design.md**: Designing error class hierarchies
- **references/error-recovery-strategies.md**: Recovery patterns for different scenarios
- **references/coroutine-error-handling.md**: Handling errors in coroutine code
- **assets/error-handling-checklist.md**: Review checklist for error handling
- **assets/error-message-guide.md**: Writing helpful error messages
