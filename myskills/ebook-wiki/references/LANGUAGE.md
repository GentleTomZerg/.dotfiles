# Language — the book's language governs what the reader reads

Write the wiki in the book's language: the prose **and** the fixed vocabulary. Block names, table headers and inline notation each have a Chinese form and an English form, and one page uses one pair throughout — the one matching the book.

- Chinese book → Chinese prose. Gloss each key term once on first use: `一元论 (monism)`, `赫尔德 (Herder)`.
- English book → English prose. Gloss terms that aid understanding: `negative liberty (消极自由)`.

Reuse the same gloss everywhere after the first use; never re-translate a term two ways in one wiki.

## Fixed vocabulary

**Block names**

| Spine block | Chinese book | English book |
|---|---|---|
| § record | `## § 记录` + `### §n 节名` | `## § Record` + `### §n Section name` |
| core opening | `## 骨架` | `## Skeleton` |
| one argument (`argue`) | `## 论证 n：标题` | `## Argument n: Title` |
| mechanism (`explain`) | `## 它解决什么问题` · `## 机制` · `## 图` · `## 代码` · `## 取舍表` | `## What it solves` · `## Mechanism` · `## Diagram` · `## Code` · `## Trade-offs` |
| sequence (`trace`) | `## 时间线` · `## 人物与立场表` · `## 因果链` · `## 与其他章的接口` | `## Timeline` · `## Positions` · `## Causal chain` · `## Links to other chapters` |
| lookup (`record`) | `## 条目` · `## 术语表` | `## Entries` · `## Terms` |
| recall hooks | `## 金句` | `## Key quotes` |
| open questions | `## 疑问` | `## Open questions` |
| verification | `## 引文核对` | `## Quote check` |
| book conventions | `## 读法` (in `AGENTS.md`) | `## How to read` |

**Table headers**

| Table | Chinese book | English book |
|---|---|---|
| verification | `检索键 / 出处 / 省略 / 结果` | `key / source / elisions / result` |
| trade-offs | `场景 / 好处 / 代价 / 何时别用` | `scenario / benefit / cost / when not to use` |
| positions | `人物 / 主张 / 与谁对立 / 出处` | `person / position / opposed by / source` |

**Inline notation**

| Notion | Chinese book | English book |
|---|---|---|
| ground kind | `[直引·角色]` / `[转述·角色]` | `[verbatim · role]` / `[paraphrase · role]` |
| honesty tag | `[原文直撑]` / `[合理重构]` / `[我的发挥]` | `[stated]` / `[reconstruction]` / `[mine]` |
| flagging my own step | `> [!warning] 我的发挥` | `> [!warning] My own addition` |
| verification result | `✓` / `⚠ 拼接` / `⚠ 框词` / `⚠ 未命中` | `✓` / `⚠ splice` / `⚠ framing` / `⚠ not found` |
| no verbatim quotes | `（无逐字引用）` | `(no verbatim quotes)` |

## Never translated

- **Core identifiers** — `argue` / `explain` / `trace` / `record`, in frontmatter `cores:` and in the conventions block.
- **`### §n <title>`** — the book's own numerals and title, quoted: `### §8 多元论`, never `### §8 Pluralism`.
- **The `- source:` line** and chapter ids — machine keys, not prose.

Rule of thumb: the book's language governs everything a reader reads; English governs the keys the agent greps for.
