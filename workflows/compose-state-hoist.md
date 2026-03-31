---
description: Perform state hoisting for a Composable Screen. To make the main screen previewable.
---
Your task today is to state hoist this Composable Screen. Our goal is to make the Screen preview-able. That said, we should move out `ViewModel` from the screen implementation.
For example:

```kt
@Composable
fun ExampleScreen(
  viewModel: ExampleViewModel = koinViewModel()
) {
  Button(
    title = viewModel.title,
    onClick = viewModel.onButtonClick
  )
}
```

Would break the Preview. Even though, there are some Koin magic. It still not work. We should:

```kt
@Composable
fun ExampleScreen(
  viewModel: ExampleViewModel = koinViewModel()
) {
  ExampleScreenContent(
    buttonTitle = viewModel.title,
    onButtonClick = { viewModel.onButtonClick() }
  )
}

// Create a new Composable for main screen implementation
@Composable
fun ExampleScreenContent(
  buttonTitle: String,
  onButtonClick: () -> Unit
) {
  Button(
    title = buttonTitle,
    onClick = onButtonClick
  )
}
```

The ExampleScreenContent will be preview-able.