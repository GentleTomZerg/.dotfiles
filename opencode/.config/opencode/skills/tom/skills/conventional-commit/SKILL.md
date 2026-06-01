---
name: conventional-commit
description: Write commit messages following the Conventional Commits v1.0.0 spec using type, scope, body, and footer conventions. Use when user wants to write a commit message, compose a git commit, or mentions "conventional commit", "commit message", or "cc:".
---

# Conventional Commit

Generate commit messages matching the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/#specification) spec.

## Quick start

The user says "commit this" or "write a commit message".

1. **Analyze the changes**
   - Run `git diff --cached` (staged) or `git diff` (unstaged) to see the diff
   - If nothing is staged, run `git status` and ask whether to stage all or select files
   - Scan the diff to understand what changed and why

2. **Determine the type**
   - `feat` — A new feature
   - `fix` — A bug fix
   - `docs` — Documentation only changes
   - `style` — Changes that do not affect the meaning of the code (formatting, missing semicolons, etc.)
   - `refactor` — A code change that neither fixes a bug nor adds a feature
   - `perf` — A code change that improves performance
   - `test` — Adding missing or correcting existing tests
   - `build` — Changes that affect the build system or external dependencies
   - `ci` — Changes to CI configuration files and scripts
   - `chore` — Other changes that don't modify src or test files
   - `revert` — Reverts a previous commit

3. **Determine scope (optional)**
   - A noun describing the affected module/area, e.g. `feat(parser):`, `fix(api):`
   - Omit when the change is broad or cross-cutting

4. **Check for breaking changes**
   - If the change breaks API/behavior, append `!` after type/scope: `feat!:`, `feat(api)!:`
   - Also include a `BREAKING CHANGE:` footer with explanation

5. **Write the description**
   - Imperative mood, present tense: "add" not "added" or "adds"
   - No period at the end
   - Lowercase after the colon
   - Max ~50 characters, concise but descriptive

6. **Add body (optional)**
   - Blank line after description
   - Explain the *why* and *what*, not the *how*
   - Wrap at 72 characters

7. **Add footers (optional)**
   - Blank line after body
   - `BREAKING CHANGE: <description>` for breaking changes
   - `Reviewed-by:`, `Refs:`, `Closes:`, etc.

## Full format

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

## Workflow

1. User asks to commit → analyze the diff
2. Propose a commit message and show it to the user
3. Ask for confirmation or adjustments
4. Run `git commit -m "..."` or save to `.git/COMMIT_EDITMSG`
