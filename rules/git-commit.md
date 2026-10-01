# Git Commit Rules

Every commit in this repository is read by other AI agents and developers to understand the project history. Write commit messages in English, keep them focused, and follow this format.

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

- `<type>` is one of `feat`, `fix`, `docs`, `style`, `refactor`, `test`, or `chore`
- `<scope>` is the Jira ticket number (for example, `APACAUCAND-13764`); required when work is tied to a ticket
- `<subject>` is a short, imperative, lowercase description without a trailing period
- Keep the subject line under 50 characters
- Wrap the `<body>` at 72 characters if extra context is needed

## Language

Write commit messages in English only. Do not mix Chinese, Japanese, or Korean in the subject or body unless the change itself concerns those strings.

## Examples

Good:

- `feat(APACAUCAND-13764): add MegaSmash serialize module with tests`
- `fix(APACAUCAND-13724): correct ko-KR plural key for coins`
- `docs(APACAUCAND-13764): update deployment instructions`
- `test(APACAUCAND-13724): cover share id validation`

Avoid:

- `update` (missing type and scope)
- `fix bug` (not imperative, missing scope)
- `feat: 新增功能` (wrong language)
- `feat(share): add MegaSmash serialize module` (scope must be a Jira ticket, not a module name)
- `feat(APACAUCAND-13764): Added MegaSmash serialize module.` (past tense and trailing period)

## Atomic Commits

One commit should contain one logical change. Do not bundle unrelated refactoring, feature work, and dependency updates in a single commit.

## Pre-Commit Validation

Follow the current tool's validation policy in `.agents/rules/workspace-rules.md`. Only stage files that are part of the change. Do not commit generated build outputs or local IDE files unless the user explicitly asks.

For each commit-sized change, finish the approved work and applicable formatting, review, and verification first. The current tool's runtime adapter and task authorization decide whether the agent or developer runs those checks. Report the diff, exact validation results, and unresolved gaps; wait for the user's acceptance of verification before drafting the commit message. An agent-run passing check does not authorize a commit.

Negative assertions and regression-guard claims must satisfy `.agents/rules/test-evidence.md` before drafting. If the user explicitly waives mutation, disclose `未經 mutation 驗證` in the response and `Mutation efficacy not verified (user-approved waiver).` in the English commit body.

Present the proposed message and staging list. Run `git commit` only after approval of that concrete commit; push requires separate explicit authorization. Keep implementation and validation progress current while working, and record the commit hash only after the commit succeeds. Do not mark uncommitted work as committed.

Before drafting a commit message, and again before running `git commit`, use the installed `cleaning-agent-tmp` skill when available: list agent `/tmp` session leftovers, wait for user confirmation, then `trash` approved paths. Never use `rm`. Skip only when the user explicitly says there is nothing to clean. Resolve the skill from the current tool's skill catalog; it is not a project-local skill.

## Restrictions

- Do not commit secrets, API keys, or environment-specific values
- Do not run `git push` unless the user explicitly asks for it
- Do not run destructive commands such as `git reset --hard` or force pushes without explicit confirmation

## Attribution

When an agent contributes to this project, proper attribution helps track the evolving role of AI in the development process. Contributions should include an Assisted-by tag in the following format:
```
Assisted-by: AGENT_NAME:MODEL_VERSION [TOOL1] [TOOL2]
```

Where:
- AGENT_NAME is the name of the AI tool or framework
- MODEL_VERSION is the specific model version used
- [TOOL1] [TOOL2] are optional specialized analysis tools used (e.g., coccinelle, sparse, smatch, clang-tidy)

Basic development tools (git, gcc, make, editors) should not be listed.

Examples:
```
Assisted-by: Claude:<model id of the current session>
Assisted-by: Claude:<model id> clang-tidy
```
