# Evidence — what makes a page trustworthy

## Quotes

A span is verbatim if and only if it was checked against the source text in the same run that wrote it. `>` means verbatim and nothing else; paraphrase is plain prose. A quote lives where it does work — a knowledge page's slot — and the source record holds none: it is navigation between pages, and reads `quotes_check: 0`.

**Location.** `〈Chapter〉§section`, plus `p.N` for PDFs. Never a file path — the page outlives the machine.

**Retrieval key.** The first 8 characters of the quoted sentence, extended until unique within its chapter. The key is how a human reaches the passage in any reader on any machine: search it and you land there. An ellipsis belonging to the source's own phrasing is part of the quote, not an elision.

**Check in this order.** The whole span first — found verbatim, it counts zero elisions, whatever `…` it contains. Only if the whole span misses, split on `……` / `...` and check each fragment; elisions = the number of split boundaries. Prefer several short spans over one spliced long one — a short exact span carries no count and no ambiguity. Normalise whitespace and full/half-width only; wording and punctuation stay exactly as printed. Framing the agent added (`Herzen's question:`) belongs in the label outside the block; an editorial note goes beside it as a source-line annotation.

Failure classes, so a miss says which: `⚠ splice` (the span joins non-contiguous text without an ellipsis) · `⚠ framing` (the agent's words inside the block) · `⚠ not found` (a fragment is not there).

A span that fails is rewritten or demoted to paraphrase in that run. A quote carried forward from memory or from an earlier draft is a defect, not a shortcut.

## One home per quote

A quote lives on the page where it does work, in the slot it supports, with its role: `[直引·判据]` / `[verbatim · criterion]`. A second page needing the same span cites it — `→ 见 [[命名]] G2` — instead of copying it. Copies drift; citations cannot.

Counts go into `quotes_check:` in the run that wrote them. A count written from memory is a defect.

## Honesty tags

Every warrant and inference step carries exactly one:

- `[stated]` — the source says it.
- `[reconstruction]` — the source implies it; the step is yours.
- `[mine]` — the step is the human's, beyond any source.

A close in EXPLORE carries the same warrant as the resolution it produces. `[mine]` also gets `> [!warning] 我的发挥` at the point of use, and a `take` page to live on. Every claim carries a **falsifier** — the evidence that would collapse it. A claim with no falsifier is unfinished, not strong.

## Anchors

`### §n <title>` inside a source record is the only anchor other pages link to, and it freezes once written: renaming it breaks inbound links. Numbers and titles quote the source, in the source's language. Block anchors (`## G`, `## 论证 3`) are for navigation inside a single page, where a rewrite moves both sides together.

A `Questions` row is not an anchor: a `live` copy into `index.md` carries the `Q` id, and a page citing a doubt cites that id.
