---
name: researching-topics
description: Research a topic given by the user, confirm readiness, and wait for the next task.
---

# Researching Topics Skill

## When to use this skill
- The user asks you to "research" a specific topic.
- The user mentions "do a study" or "check" something before giving a task.
- The user explicitly triggers this skill for a research phrase.

## Workflow
- [ ] **Analyze the Request**: Identify the topic or subject the user wants you to research.
- [ ] **Conduct Research**:
    - Use `search_web` to find latest information, documentation, or articles.
    - Use `view_file` to check local project files if the research is internal.
    - Use `mcp_context7_query-docs` if it relates to a specific library documentation.
- [ ] **Synthesize Findings**: Gather the key points, but **do not** start implementing or proposing a complex plan yet unless asked.
- [ ] **Confirm Readiness**:
    - Once you have enough information, reply to the user with **exactly**: `I'm ready!`
    - You may include a *very brief* summary of what you found (1-2 sentences) to prove you have the context, but keep it minimal.
- [ ] **Wait**: Stop and wait for the user's next instruction.

## Instructions
1.  **Do not over-engineer**: The goal is to get context, not to build the solution yet.
2.  **Be concise**: The user wants to know you act on the "ready" signal.
3.  **State**: "I'm ready!" must be the clear signal.
