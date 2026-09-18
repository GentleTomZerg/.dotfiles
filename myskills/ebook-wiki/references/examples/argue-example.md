# Worked example — `argue` core

Trimmed from a real source page: 以赛亚·伯林〈我的学术之路〉, book cores `[argue, record]`. The full page holds twelve `### §n` entries, seven argument blocks, a `条目`/`术语表` pair, six 金句, and a 39-row verification table. Everything quoted below is copied verbatim from it — copy the machinery, not the judgments.

## Spine head (identity + 读法 + the § record)

```md
---
publish: true
---

# 我的学术之路

- source: `raw/book-info.md` + `OEBPS/Text/Section0001_split_000.xhtml#sigil_toc_id_6`
- status: migrated 2026-09-18；全部逐字引文已机器核对，见 [[#引文核对]]
- 读法：§ 记录 是章节层（每节 1-3 行），跨页链接只指到这里；论证区给每个结论 C/G/W/I/R/S；条目/术语表 是查找层。

## § 记录

### §5 维柯
维柯是第一个提出文化观念的哲学家。石头可解释，人须理解；问题清单随文化而变。人性共通，故跨时代可理解——柏林取其方法，不取其教会答案。
```

## One argument block (from the `argue` core)

Note: `G` entries each carry a role, a kind (`直引`/`转述`), and a location; `S` says which grounds actually carry the argument; `R` is mandatory. The `[我的发挥]` in W2 is both warned at the point of use and claimed in 疑问.

```md
## 论证 3：宽容可能

- 所涉§： §5 维柯 · §6 赫尔德 | 类型： 双向推论（破 + 立）
- **C**： 普遍答案不可能（破），普遍宽容可能（立）——一元论从提问方式上就错了。
- G：
  - G1 [直引·维柯方法]（〈我的学术之路〉§维柯）：
    > 我们知道石头或桌子如何运动……但是我们不知道，这块石头为什么想成为现在这副模样……荷马时代的希腊人所提出的问题，不同于罗马人所提出的问题
  - G2 [直引·维柯之锚]（〈我的学术之路〉§维柯）：
    > 当然，人性是共通的，否则这个时代的人就不能理解另一个时代的文学、艺术或法律
  - G3 [直引·赫尔德重心]（〈我的学术之路〉§赫尔德）：
    > 每一种文化都有自己的“重心”
  - G4 [直引·赫尔德推论]（〈我的学术之路〉§赫尔德）：
    > 这些文化没有任何理由互相攻击——普遍的宽容一定是可能的——但是统一必然导致毁灭。
  - G5 [直引·非相对主义]（〈我的学术之路〉§赫尔德）：
    > 赫尔德不是相对主义者……他认为，人类拥有一些基本目标和行为准则，但是在不同文化中，它们呈现出完全不同的形式。
- **W**：
  - W1 [原文直撑]：问题清单本身随文化而变，不存在跨时空恒定的考题（G1 直接给出）。
  - W2 [我的发挥]：G2 的「人性共通」强到足以支撑跨文化理解与「共通目标」。这是全章最脆的一环。
    > [!warning] 我的发挥
    > G2 只说「能理解另一时代的文学、艺术或法律」，未说「目标共通」——后者已认领为赌注，见 [[#疑问]]
- **I**： 由 G1 + W1，「唯一答案」连对应的「唯一问题」都没有 → 普遍答案不可能；由 G2 + G3 + G4 + G5，理解可能且目标共通、形式各异 → 普遍宽容可能。
- **S**： 双结论。破（C1）← G1 + W1，联合；立（C2）← G2 + G3 + G4 + G5，联合。破与立互相独立。
- **R**： 若找到「无共通目标却可理解」的反例，或跨文化理解系统性失败的案例，立的那一半塌，整条路滑向相对主义。W2 已认领为赌注。
```

## The verification table

Every `直引` above appears here. `省略` counts split boundaries; a source-internal `……` (`“免于……的自由”`) verifies under the whole-span check and counts 0.

```md
## 引文核对

| 原句首 8 字 | 出处 | 省略 | 结果 |
|---|---|---|---|
| 我们知道石头或桌 | §维柯 | 2 | ✓ |
| 当然，人性是共通 | §维柯 | 0 | ✓ |
| 每一种文化都有自 | §赫尔德 | 0 | ✓ |
| 这些文化没有任何 | §赫尔德 | 0 | ✓ |
| 赫尔德不是相对主 | §赫尔德 | 1 | ✓ |
```

## What transferred, and what did not

- **Transferred**: the spine order, `§n` titles frozen as anchors, per-ground roles and locations, `[原文直撑]` / `[合理重构]` / `[我的发挥]`, `+` and `;` in `S`, a mandatory `R`, the verification table.
- **Not transferred**: the number of arguments, their titles, that W1 is a reconstruction, that this chapter needs `record` at all. Those are this book's judgments.
- **Cost check**: this chapter is one of twelve from the book; each page runs about 20 KB because the chapter is argument-dense end to end. A `record`-only chapter of the same book runs two to four KB — that difference is the point of declaring cores rather than one template.
