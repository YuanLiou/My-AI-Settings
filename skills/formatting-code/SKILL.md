---
name: formatting-code
description: Automates code formatting and style enforcement using Spotless. Use when finishing a coding task, before committing, or when the user requests lint/style checks.
---

# Code Formatting and Style Enforcement

## When to use this skill
- After completing a coding task to ensure style compliance.
- When the user asks to "lint", "format", or "clean up" the code.
- Before running comprehensive tests to eliminate style-related noise.

## Workflow

- [ ] Run Spotless Apply
- [ ] Verify Clean Execution
- [ ] Handle Persistent Errors (if any)

## Instructions

### 1. Run Spotless Apply
Execute the Gradle task to automatically apply formatting rules:

```bash
./gradlew spotlessApply
```

### 2. Verify Execution
Check the command output.
- **SUCCESS**: If the build is successful, the code is formatted.
- **FAILURE**: If the build fails, analyze the error output.

### 3. Handle Errors
If `spotlessApply` fails:
1.  **Read the error log** to identify the specific file and violation.
2.  **Attempt a manual fix** if the tool cannot auto-correct it (e.g., parsing errors, severe syntax issues).
3.  **Re-run** `./gradlew spotlessApply` to verify the fix.

## troubleshooting
- If `./gradlew` is not executable, run `chmod +x gradlew` first.
