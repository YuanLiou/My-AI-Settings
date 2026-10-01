---
name: getting-pr-review-comments
description: Gets GitHub PR review comments and prepares them for review or fixing. Use when the user says "幫我看這個 PR 的 comments" or "修正 PR comments", asks to inspect pull request comments, or wants PR comments turned into actionable fixes.
---

# Getting PR Review Comments

## When to use this skill

- The user says "幫我看這個 PR 的 comments".
- The user says "修正 PR comments".
- The user asks to fetch, review, summarize, or fix GitHub Pull Request comments.

## Required tools

- Use `gh` for GitHub API calls.
- Use `jq` for JSON validation and extraction.
- Prefer the Skill helper script when present: `.agents/skills/getting-pr-review-comments/scripts/fetch_pr_comments.sh`.

## PR and ticket detection

Follow this priority order:

1. If the user provides a PR number, use it directly. Do not search for another PR number.
2. If the user provides a PR URL, extract the PR number from the URL.
3. If the user does not provide a PR number, inspect recent `git log` output for patterns like `#801`, `PR 801`, `pull request #801`, or `Pull Request #801`.
4. If a PR number is found from `git log`, automatically fetch ticket metadata from the PR.
5. If no PR number can be found, ask the user for the PR number.

To infer a ticket number from a PR, inspect the PR title, body, branch name, and commit messages. Look for ticket patterns like `ABC-123`, `EC-1234`, or other uppercase project keys followed by digits.

Suggested command:

```bash
gh pr view "$PR_NUMBER" \
  --json number,title,body,headRefName,commits,url \
  --jq '{
    number,
    url,
    title,
    body,
    headRefName,
    commitMessages: [.commits[]?.messageHeadline]
  }'
```

## Fetch comments workflow

Use this checklist:

```markdown
- [ ] Determine PR number
- [ ] Infer ticket number when possible
- [ ] Fetch PR comments
- [ ] Validate JSON output
- [ ] Summarize comments by type, author, file, and action needed
```

When `.agents/skills/getting-pr-review-comments/scripts/fetch_pr_comments.sh` exists, run:

```bash
bash .agents/skills/getting-pr-review-comments/scripts/fetch_pr_comments.sh "$PR_NUMBER" "ai-knowledge/pr_${PR_NUMBER}_all_comments.json"
```

If the output path should live with a feature-specific folder, use that folder instead:

```bash
bash .agents/skills/getting-pr-review-comments/scripts/fetch_pr_comments.sh "$PR_NUMBER" "ai-knowledge/<topic>/pr_${PR_NUMBER}_all_comments.json"
```

Validate the result:

```bash
jq '{
  is_array: (type == "array"),
  total: length,
  types: (group_by(.type) | map({type: .[0].type, count: length}))
}' "ai-knowledge/pr_${PR_NUMBER}_all_comments.json"
```

## Review comments workflow

When the user asks to inspect comments:

- Read the generated JSON.
- Lead with blocking or correctness-related comments.
- Group repeated comments into one action item.
- Include `html_url`, `file`, and `line` when available.
- Distinguish between `general_discussion`, `code_review`, and `review_summary`.

Use this output shape:

```markdown
## PR comments

Ticket: `<ticket-number or unknown>`
PR: `<PR number>`

- `<severity>` `<file>`: <what the comment asks for>
  Comment: <short quote or summary>
  Link: <html_url>

## Suggested next steps

- <action 1>
- <action 2>
```

## Fix comments workflow

When the user asks to fix PR comments (or to act on subagent review findings):

1. Fetch and read comments first. Inspect referenced files before proposing edits.
2. Report proposed fixes before editing, including wording-only fixes. Existing approval of the same concrete scope remains valid; newly discovered or expanded changes need approval. For each blocking / correctness item, complete the **兩端證明** template below. This Skill maintains the detailed procedure; the approval gate is in `.agents/rules/workspace-rules.md`.

```markdown
### <short title of the comment>
- 查證結論: 成立 | 不成立 | 部分成立 — <evidence>
- 修正前: <how to reproduce; observation. If cannot reproduce, say so>
- 擬修法: <files + why this fixes the cause>
- 修正後證明: <execution plan; mutation if negative assertion>
- 不可達判定: <structural impossibility vs currently unreachable; suggest fix or finding note; do not close as "won't fix" without user OK>
```

If the item is a **守衛／防線類** fix (guard／re-check／stale／lifecycle／「now guarded」claims), also fill before approval to edit, and complete results before marking resolved:

```markdown
- 宣稱清單 (a): <one falsifiable claim per line>
- 分支／早退盤點 (b): <paths with suspend / side effect / return null / elvis; mark side-effect-then-exit>
- 驗證計畫／結果 (c): <each (a) mapped to proof; side-effect-then-exit paths must not rely on read-code alone>
```

Rule: **宣稱集合 ⊆ 已驗證集合**. "The guard function is called" alone is not proof. Before resolve, answer: does any claimed-covered path complete a side effect or early-return before the guard?

Prefer device reproduction or a targeted execution experiment. Step-by-step control-flow inspection must name the relevant branches and side effects; it is insufficient for a path that performs a side effect before an early return bypasses the guard. Such a path needs execution evidence, or a control-flow fix followed by verification. Keep currently unreachable branches in the table and distinguish structural guarantees from incidental state.

3. Fix only the comments tied to the PR unless the user expands scope. Do not treat "wrote a fix + green tests + review thread quiet" as resolved.
4. After approved edits, execute the **修正後證明** plan through the current tool's runtime and task authorization, or give the developer the exact command when agent execution is unavailable or unauthorized. Include guard-claim table results when applicable. Negative guards follow `.agents/rules/test-evidence.md`.
5. Report verified results and missing evidence separately. Draft "已修" only for behavior supported by those results; do not claim effectiveness from a green-only run. Closing an item, including recommending "不修" for an incidentally unreachable case, requires explicit user approval. Preparing reply text does not authorize posting it or resolving a GitHub thread.

## Fallback API calls

If `.agents/skills/getting-pr-review-comments/scripts/fetch_pr_comments.sh` is missing, use these `gh api` endpoints:

```bash
gh api --paginate --slurp "repos/{owner}/{repo}/issues/${PR_NUMBER}/comments"
gh api --paginate --slurp "repos/{owner}/{repo}/pulls/${PR_NUMBER}/comments"
gh api --paginate --slurp "repos/{owner}/{repo}/pulls/${PR_NUMBER}/reviews"
```

Normalize them into one JSON array with fields:

- `id`
- `type`
- `author`
- `date`
- `file`
- `line`
- `reply_to`
- `html_url`
- `body`
