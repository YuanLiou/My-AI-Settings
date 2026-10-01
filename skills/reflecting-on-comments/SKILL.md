---
name: reflecting-on-comments
description: >-
  Reviews comments and KDoc added or edited during an implementation for
  (a) length and (b) necessity, trimming ticket-story narration, restated
  logic, decision-code citations, and repeated boilerplate down to only
  durable non-obvious "why" explanations. Use immediately after finishing
  a coding task or implementation, before marking a todo done or drafting
  a commit message.
---

# Reflecting on Comments

Run this right after finishing an implementation, before calling the task
done or drafting a commit message — every time code was written or edited
this session, not just when asked.

The maintained policy is [workspace-rules](../../rules/workspace-rules.md),
section "註解克制". Keep necessary non-obvious explanations and the required
Given/When/Then comments inside unit tests. Historical cases remain in
`ai-knowledge/share/constitution.md`; it is not a second policy source.

## Workflow

```
Comment Reflection Progress:
- [ ] Identify this task's files and review baseline, including any relevant committed changes
- [ ] Inspect staged and unstaged changes and untracked new files as well; do not rely on a committed-only comparison
- [ ] List every comment/KDoc block new or edited within that scope, including the content of new files
- [ ] For each: apply the Necessary? then Right-sized? questions below
- [ ] Check required unit-test comments and substantiate framework behavior claims
- [ ] Compare against the content immediately before comment cleanup to confirm that cleanup changed no behavior
- [ ] Apply the current tool's validation policy for formatting or lint checks on the affected files
```

The task diff identifies what to review. A separate before-cleanup snapshot
identifies what this comment pass changed; do not expect the whole task diff
to contain only comments. Preserve pre-existing and concurrent edits, do not
stage files to make them visible to the review, and do not clean unrelated
files. Check changed comments in any relevant file type, not only Kotlin.

For each framework behavior claim, check the applicable version's source,
official documentation, or an execution observation that supports that exact
claim. An observation limited to one setup cannot prove the callback never
runs. Record the version, conditions, and source in the task notes; keep the
code comment self-contained without local note paths. If the claim remains
unverified, report the uncertainty and investigate before relying on it to
justify a behavior change. Do not remove a guard merely because its comment
could not be verified.

## Question 1: Necessary?

Preserve the required unit-test Given/When/Then structure. For other comments,
keep information the code cannot communicate on its own, including necessary
constraints. Remove:

- Restates what the code already says (`// increment counter`, `// return the result`)
- Narrates ticket numbers, decision codes (e.g. "D-3", "Bundle B2"), or "left
  for ticket X" bookkeeping — that belongs in `ai-knowledge/` or the PR
  description, not in code
- Repeats the same boilerplate sentence verbatim across many similar files
- Summarizes a review conversation, a design monologue, or an AI-authoring
  aside

Keep it when it is:

- A verified trap: a bug someone actually hit, with enough detail that
  removing the guard would silently reintroduce it
- A non-obvious constraint the code's shape doesn't communicate on its own
  (e.g. "must compare by equality, never by magnitude")
- The required one-line Given/When/Then comments inside a unit test, where
  "Then" states which behavior a failure would violate
- A documented, deliberate difference from a reference implementation that a
  future refactor could accidentally "fix" back to the wrong behavior

## Question 2: Right-sized?

For every comment that survives Question 1, cut it to the shortest wording
that still carries the "why". A multi-paragraph KDoc citing several tickets
or decisions usually shrinks to 2-4 sentences focused on the one non-obvious
point — everything else is noise competing with it for the reader's
attention.

## Worked example

A typical cleanup deletes every "Tracking gap (APACAUCAND-13739)" paragraph,
every "APACAUCAND-13738 D-6" style decision-code citation, and a verbatim
"same as every other reset-on-refresh module" sentence repeated across six
files, and keeps the one comment documenting a verified trap (a
refresh-counter-vs-flag bug found by an earlier ticket) almost unchanged,
because losing it would let a future edit reintroduce that exact bug.
