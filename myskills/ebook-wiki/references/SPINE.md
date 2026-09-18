# Spine — the fixed part of every source page

Every `wiki/sources/<chapter>.md` has these blocks, in this order, whatever cores the book declares:

1. **Identity** — frontmatter (`publish:`, `cores:` only when overriding the book) plus a `- source:` line naming `raw/book-info.md` and the chapter id.
2. **读法** — one line saying how to use this page ("先看骨架，再按需下钻某个论证").
3. **§ 记录** — `### §n <节名>` for every section of the chapter, one to three lines each. **This is the anchor contract** (below).
4. **Cores** — in the order the book declared them. See [cores](cores/).
5. **金句** — verbatim quotes with 出处. Required for `argue` and `trace`; optional otherwise.
6. **疑问** — open questions. Every `[我的发挥]` in the page is claimed here.
7. **引文核对** — the verification table for every verbatim quote (below).

## Anchor contract

`### §n <节名>` is the only anchor other pages may link to.

- Headings match the book's own section numbering and titles, in the book's language.
- Section numbers are the *page's* decomposition of the chapter; once written they are **frozen**. Renaming one breaks inbound links.
- Every link from `wiki/concepts/`, `wiki/persons/`, `index.md`, `00-overview.md` targets `#§n <节名>` — never a core block anchor.
- Block anchors (`#论证 3`, `#机制 2`) are for navigation inside the page only, where a re-refine rewrites both sides together.

## Quote protocol

The rule that makes the wiki trustworthy: **a quote is verbatim if and only if it appears as `✓` in `## 引文核对`.** Everything else is 转述, written as ordinary prose with no `>` block.

**Location.** `〈章名〉§节名` — never file paths, never sigils. The retrieval key is the first 8 characters of the quoted sentence: search that in any EPUB reader and you land on the passage.

**Before writing, verify each quote against the raw chapter text:**

1. Check the **whole span** first. If it is found verbatim, it is `✓` with 省略 0 — regardless of any `……` inside it, because an ellipsis that belongs to the source's own phrasing (`“免于……的自由”`) is part of the quote, not an elision.
2. Only if the whole span misses, split on elision markers (`……`, `...`) and check each surviving fragment; 省略 = the number of split boundaries. Prefer rewriting a heavy span as several short verbatim quotes — a short exact span carries no elision count and no ambiguity.
3. Move editorial apparatus out of the quoted span:
   - framing the agent added (`赫尔岑之问：`, `艾希曼例：`, `拜伦式个人 vs 集体超我：`) belongs in the grounds label, not inside the quote;
   - editorial notes (`（编注：…）`) go outside the `>` block as `出处` annotations.
4. Normalize for matching: whitespace and 全角/半角 width only. **Wording and punctuation marks are never normalized** — quote marks stay exactly as printed. Rewriting `“”` as `''` to nest inside a quote block is a transcription defect, and the check will flag it as `⚠ 未命中`.

**Failure classes** — a `⚠` must say which:

| Mark | Meaning |
|---|---|
| `✓` | every fragment found verbatim |
| `⚠ 拼接` | the span joins text that is not contiguous in the source and was not marked with `……` |
| `⚠ 框词` | the span contains the agent's own framing rather than the source's words |
| `⚠ 未命中` | a fragment cannot be found at all |

A quote that fails verification is **rewritten**, not shipped: either fix the elision and scope, or demote it to 转述. Never carry a quote forward from memory or from an earlier draft.

**Table format** (`## 引文核对`):

```md
| 原句首 8 字 | 出处 | 省略 | 结果 |
|---|---|---|---|
| 最流行的观点是 | §证实主义 | 0 | ✓ |
| 如果我说“所有 | §证实主义 | 1 | ✓ |
| 多数革命者公开 | §多元论 | 2 | ✓ |
| 这种粉红（色 | §证实主义 | 0 | ⚠ 拼接（原为两句，已补 ……） |
```

A page with no verbatim quotes writes `（无逐字引用）` under the heading and keeps the heading.

## Honesty tags

Every warrant and inference step carries exactly one tag:

- `[原文直撑]` — the source states this outright.
- `[合理重构]` — the source implies it; the step is the agent's reconstruction.
- `[我的发挥]` — the step is the agent's own addition, beyond the source.

Every `[我的发挥]` additionally appears as a `> [!warning] 我的发挥` block at the point of use **and** is claimed in `疑问`, so a reader can see exactly where the source stopped and the agent started.

## Empty slots

A core slot with no material is **omitted**, never padded with filler. Only two spine blocks are unconditional: `### §n` record and `## 引文核对`.
