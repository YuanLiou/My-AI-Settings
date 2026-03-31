---
name: documenting-conversations
description: Creates comprehensive markdown documentation from technical conversations and research. Use when the user asks to document a conversation, create documentation from discussion, or save research findings as markdown files.
---

# Documenting Conversations Skill

## When to use this skill

- User asks to "document our conversation" or "save this as documentation"
- User wants to create reference documentation from technical discussions
- User requests to convert chat history into markdown files
- User wants to preserve research findings or learning sessions
- User mentions creating guides from conversations about libraries, frameworks, or tools

## Workflow

1. **Identify conversation scope**
   - Determine which parts of the conversation to document
   - Identify main topics and subtopics
   - Note if there are distinct sections that should be separate files

2. **Create documentation structure**
   - Create a `documentation/` folder if it doesn't exist
   - Plan file organization based on topics
   - Use descriptive filenames with kebab-case (e.g., `navigation3-overview.md`)

3. **Convert conversation to markdown**
   - Extract key information from the conversation
   - Organize content with clear headers and sections
   - Include code examples with proper syntax highlighting
   - Add tables for comparisons or feature matrices
   - Include links to external resources mentioned

4. **Format for readability**
   - Use GitHub-flavored markdown
   - Add table of contents for long documents (optional)
   - Use appropriate formatting: bold, italics, code blocks, quotes
   - Include warnings or notes using blockquotes with emojis
   - Add horizontal rules to separate major sections

5. **Notify user**
   - Provide paths to created documentation files
   - Offer brief summary of what was documented

## Documentation Structure Guidelines

### File Organization

```
documentation/
├── [topic]-overview.md          # High-level overview of main topic
├── [topic]-setup.md             # Setup and installation guides
├── [topic]-integration.md       # Integration with other systems
├── [topic]-examples.md          # Code examples and recipes
└── [topic]-troubleshooting.md   # Common issues and solutions
```

### Markdown Template

Use this structure for comprehensive technical documentation:

```markdown
# [Topic] - [Subtitle]

> **Source**: [Link to official docs or resources]
>
> ⚠️ [Any important warnings or status]

---

## What is [Topic]?

[High-level overview and introduction]

---

## Key Concepts

### Concept 1
[Explanation]

### Concept 2
[Explanation]

---

## Setup and Installation

### Dependencies

[Version catalog or package.json format]

### Configuration

[Build files or config examples]

---

## Usage Examples

### Basic Example

[Code block with explanation]

### Advanced Example

[Code block with explanation]

---

## Best Practices

1. **Practice 1** - Description
2. **Practice 2** - Description
3. **Practice 3** - Description

---

## Common Patterns

| Pattern | Use Case | Example |
|---------|----------|---------|
| [Name] | [When to use] | [Code snippet] |

---

## Resources

- [Official Documentation](link)
- [GitHub Repository](link)
- [Community Resources](link)
```

## Content Extraction Rules

When converting conversation to documentation:

### Include:
- ✅ Technical explanations and definitions
- ✅ Code examples discussed
- ✅ Configuration snippets
- ✅ Comparisons and feature matrices
- ✅ Best practices mentioned
- ✅ Links to external resources
- ✅ Warnings about alpha/beta status
- ✅ Migration guides if discussed
- ✅ Key differences between versions
- ✅ Setup instructions

### Exclude:
- ❌ Conversational filler ("Great question!", "Let me help you...")
- ❌ Meta-discussion about the conversation itself
- ❌ Repeated explanations of the same concept
- ❌ Uncertainty or speculation ("I think...", "Maybe...")
- ❌ Requests for clarification

### Transform:
- 🔄 First-person ("I'll show you") → Third-person or imperative ("The following shows...")
- 🔄 Questions → Declarative statements or headers
- 🔄 Conversational tone → Technical documentation tone
- 🔄 Scattered information → Organized sections

## Formatting Best Practices

### Code Blocks

Always specify the language for syntax highlighting:

```kotlin
// Use language identifier
@Serializable
data class User(val name: String)
```

### Warnings and Notes

Use blockquotes for emphasis:

```markdown
> ⚠️ **Warning**: This feature is in alpha
> 📝 **Note**: Remember to configure X before Y
> 💡 **Tip**: You can optimize by doing Z
```

### Tables

Use tables for comparisons:

```markdown
| Before | After |
|--------|-------|
| Old way | New way |
```

### Links

Make links descriptive:

```markdown
- ✅ [Navigation 3 Documentation](https://example.com)
- ❌ [Click here](https://example.com)
```

### Section Organization

Follow this hierarchy:
1. `#` - Document title (one per file)
2. `##` - Major sections
3. `###` - Subsections
4. `####` - Rare, only if absolutely needed

## File Naming Conventions

- Use **kebab-case**: `my-document-name.md`
- Be **descriptive**: `koin-navigation3-integration.md` not `doc1.md`
- Include **version** if relevant: `migration-guide-v2-to-v3.md`
- Group by **topic**: `navigation3-overview.md`, `navigation3-setup.md`

## Multi-File Documentation

When conversation covers multiple topics, create separate files:

1. **Identify natural boundaries** between topics
2. **Create one file per major topic**
3. **Cross-reference** between files when needed:
   ```markdown
   See [Navigation 3 Overview](./navigation3-overview.md) for setup instructions.
   ```
4. **Create index** if 3+ files:
   ```markdown
   # Documentation Index
   
   - [Navigation 3 Overview](./navigation3-overview.md)
   - [Koin Integration](./koin-navigation3-integration.md)
   - [Migration Guide](./migration-guide.md)
   ```

## Quality Checklist

Before completing documentation:

- [ ] All code blocks have language identifiers
- [ ] External links are working and properly formatted
- [ ] Headers follow logical hierarchy (H1 → H2 → H3)
- [ ] No conversational artifacts remain
- [ ] Warnings and important notes are highlighted
- [ ] Examples are complete and runnable
- [ ] File is properly formatted with consistent spacing
- [ ] Resources/references section is included
- [ ] Technical accuracy is maintained from conversation

## Example Usage

**User says**: "Can you document our conversation about dependency injection?"

**Agent should**:
1. Create `documentation/` folder
2. Create `dependency-injection-overview.md`
3. Extract DI concepts, setup, examples from conversation
4. Format as technical documentation
5. Notify user with file path

**User says**: "Document what we learned about React hooks and state management"

**Agent should**:
1. Identify two main topics: hooks and state management
2. Create `react-hooks-guide.md` and `state-management-patterns.md`
3. Extract relevant information for each
4. Cross-reference between files where needed
5. Notify user with both file paths

## Tips for Agent

- **Be comprehensive but concise** - Include all important information, but remove redundancy
- **Maintain technical accuracy** - Don't paraphrase technical terms incorrectly
- **Use consistent formatting** - Pick a style and stick with it throughout
- **Include context** - Add brief explanations where needed for future readers
- **Think about the audience** - Documentation should be useful to someone who wasn't in the conversation
