---
name: generate-week
description: Use when generating a complete week of materials (learning sheet + tests) through adversarial writer-vs-reviewer debate
argument-hint: "[week-number]"
---

# Generate Week

Week number N = `$ARGUMENTS`.

Generates all materials for a week:
1. Learning sheet — via adversarial writer/reviewer debate
2. Tests (test, test.B, validation) — via writer + reviewer

## Pre-Work

1. Read `weekN/*` — if good materials exist, confirm with user before regenerating
2. Read `weekN/plan.md` if it exists
3. Read `week{N-1}/*` — note content to avoid overlap
4. **Pick a motivating task** — the writer agent internally generates 3 candidate task framings, then picks the one that is most interesting, real-world-connected, and suited for group discussion

---

## Phase 1: Learning Sheet

### Round 1

**Step 1a — Writer**: Spawn a general-purpose agent:

> You are a course materials writer for this course. Read CLAUDE.md for design principles.
> Follow the instructions in `.claude/skills/write-learning-sheet/SKILL.md`.
> Generate `weekN/N.learning-sheet.typ` for week N.

**Step 1b — Reviewer**: Spawn a separate general-purpose agent:

> You are a course materials reviewer for this course. Read CLAUDE.md for quality criteria.
> Follow the instructions in `.claude/skills/review-learning-sheet/SKILL.md`.
> Review `weekN/N.learning-sheet.typ`.
> End your review with exactly one of:
> - `APPROVED` — all must-have criteria pass, good-to-have ≥ 5
> - `REVISE: <numbered list of issues with file:line references>`
> - `ESCALATE: <blocker requiring human decision>`

### Rounds 2-3 (if REVISE)

Feed the reviewer's critique back to the writer:

> Here is the reviewer's feedback. Revise `weekN/N.learning-sheet.typ` to address each issue.
> Do NOT remove content that wasn't criticized. Only fix what was flagged.

Re-run the reviewer. Max 3 rounds total.

### After APPROVED — Fact-check

Spawn a verification agent:

> Verify `weekN/N.learning-sheet.typ` for correctness:
> - Fact-check theorem numbers, dates, citations via web search
> - Verify each proof step-by-step against the textbook (`textbook/*.md`)
> - Check logical flow and consistency
> Output: `VERIFIED` or `ISSUES: <list with file:line, type, fix>`

If ISSUES, feed back to writer for one more revision, then re-verify.

Compile: `typst compile weekN/N.learning-sheet.typ`

---

## Phase 2: Tests

### Step 2a — Writer

Spawn a general-purpose agent:

> You are a test writer for this course. Read CLAUDE.md for design principles.
> Follow the instructions in `.claude/skills/write-tests/SKILL.md`.
> The learning sheet `weekN/N.learning-sheet.typ` is finalized.
> Generate `weekN/N.test.typ`, `weekN/N.test.B.typ`, and `weekN/N.validation.typ`.

### Step 2b — Reviewer

Spawn a separate general-purpose agent:

> You are a test reviewer for this course.
> Follow the instructions in `.claude/skills/review-tests/SKILL.md`.
> Review `weekN/N.test.typ`, `weekN/N.test.B.typ`, and `weekN/N.validation.typ`.
> End with: `APPROVED`, `REVISE: <issues>`, or `ESCALATE: <blocker>`.

### Round 2 (if REVISE)

Feed critique back to test writer. Re-run reviewer. Max 2 rounds for tests.

### Final

Compile all files:
```
typst compile weekN/N.test.typ
typst compile weekN/N.test.B.typ
typst compile weekN/N.validation.typ
```

---

## Escalation Triggers

Stop and present to user when:
- 3 learning sheet debate rounds without APPROVED
- 2 test debate rounds without APPROVED
- Ambiguous textbook content
- Unverifiable facts or proof errors
