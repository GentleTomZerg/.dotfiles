---
name: conventional-commit
description: Write commit messages following the Conventional Commits v1.0.0 spec. Use when the user wants to commit, or mentions "commit message", "cc:", or "conventional commit".
---

# Conventional Commit

Generate commit messages matching the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/#specification) spec — a structured `<type>[scope][!]: <description>` format with optional body and footers.

## Steps

The user says "commit this", "write a commit message", or otherwise triggers the skill.

1. **Analyze the diff**
   - Run `git diff --cached` (staged) or `git diff` (unstaged) to inspect the changes
   - If nothing is staged, run `git status` and ask whether to stage all or select files
   - **Completion**: you understand what changed and why

2. **Pick the type** — this is the leading word of the whole commit message.
   The **type** sets the reader's expectation for what kind of change this is.

   | Type | Use when |
   |---|---|
   | `feat` | A new feature |
   | `fix` | A bug fix |
   | `docs` | Documentation only changes |
   | `style` | Formatting, missing semicolons (not code meaning) |
   | `refactor` | Neither fixes a bug nor adds a feature |
   | `perf` | Improves performance |
   | `test` | Adding or correcting tests |
   | `build` | Build system or external dependencies |
   | `ci` | CI configuration and scripts |
   | `chore` | Other changes, no src/test modification |
   | `revert` | Reverts a previous commit |

   **Completion**: one type selected from the table

3. **Add optional scope** — a noun for the affected area, e.g. `feat(parser):`, `fix(api):`. Omit when the change is broad or cross-cutting.
   **Completion**: scope chosen or explicitly omitted

4. **Check for breaking changes**
   If the change breaks API or behaviour, append `!` after type/scope (`feat!:`, `feat(api)!:`) and add a `BREAKING CHANGE:` footer.
   **Completion**: `!` decision made; footer noted if needed

5. **Write the description**
   - Imperative mood, present tense: "add" not "added" or "adds"
   - No trailing period
   - Lowercase after the colon
   - Max ~50 characters, concise but descriptive
   **Completion**: description written and verified against all four rules above

6. **Add body (optional)**
   - Blank line after description, then body text
   - Explain the *why* and *what*, not the *how*
   - Wrap at 72 characters
   **Completion**: body written, or explicitly omitted when the description alone suffices

7. **Add footers (optional)**
   - Blank line after body
   - `BREAKING CHANGE: <description>` for breaking changes
   - Common footers: `Reviewed-by:`, `Refs:`, `Closes:`, `Fixes:`
   **Completion**: all required footers in place; optional ones added where relevant

8. **Propose and confirm**
   - Show the assembled message to the user
   - Ask for confirmation or adjustments
   - Execute `git commit -m "..."` or save to `.git/COMMIT_EDITMSG`
   **Completion**: commit made or user has confirmed the message

## Format

```
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

## Examples

```
feat: add sort functionality to the table component
```

```
fix(api): handle empty response from payment gateway

The payment gateway returns an empty body on 204 responses,
which caused a JSON parse error.

Fixes: #142
```

```
feat!: drop support for Node 14

BREAKING CHANGE: the minimum required Node version is now 18.
```

```
refactor(core): extract validation logic into dedicated module
```

```
docs: add API usage guide for the webhook endpoint
```
