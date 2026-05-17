# Weekly Materials Design Guide

This guide is for **instructors reviewing** and **AI agents designing** weekly course materials for this course.

## Overview

Each week requires 4 files in `weekN/`:

| File | Purpose | Used In |
|------|---------|---------|
| `N.learning-sheet.typ` | AI-assisted learning guide | Session 2 |
| `N.test.typ` | Closed-book assessment | Session 1 of Week N+1 |
| `N.test.B.typ` | Make-up / alternative test | Make-up sessions |
| `N.validation.typ` | Self-validation practice | Session 3 |

## Before You Start

1. **Check existing materials** — The current week may already have good materials. Review before regenerating.
2. **Check `plan.md`** — Each week directory may have a `plan.md` with specific requirements.
3. **Check previous week** — Ensure NO content overlap with previous week's materials.
4. **Brainstorm first** — Discuss the motivating task and hook with the user before taking action.

## Templates

All templates live in `templates/`:
- `templates/week-template/` — copy this directory to `weekN/` to start a new week (learning-sheet, test, test.B, validation)
- `templates/learning-sheet.typ` — shared lib (imported by week templates, do not copy)
- `templates/test.typ` — shared lib (imported by week templates, do not copy)

**Rule**: Follow the template structure exactly, no overlap with previous week.

## Pedagogical Principles

| Principle | Rule |
|-----------|------|
| **FIDS Mindset** | Feel (problem) → Image (solution) → Do (practice) → Share (summary). This is a *mindset*, NOT to be explicitly added to materials. |
| **Textbook coverage** | Include all key definitions and theorems from the assigned textbook sections |
| **Narrative flow** | Blog-like prose, not fragmented bullets. Smooth transitions between topics. |
| **AI prompts** | Motivate students to think `broader` (frontier/applications), and `deeper` |
| **Self-contained** | Each file readable without external context |

## Quality Control

| Rule | Description |
|------|-------------|
| **Define before use** | All symbols and concepts must be introduced before using |
| **No forward references** | Don't reference theorems/definitions not yet covered, theorems must be proved carefully |
| **Consistent notation** | Use same symbol for same concept throughout |
| **High standard** | Think deeper on motivating task, search web for real-world connections |
| **Ensure correctness** | Ensure every fact is verified, including proofs, references, etc |
| **No author footnotes** | Don't add author footnotes unless explicitly asked |

---

## Per-File-Type Content Guidelines

### learning-sheet.typ (AI-Assisted Learning)

**Purpose**: Self-paced exploration with AI assistance

**Content requirements**:
- Task box at top — the motivating problem must be:
  - **Interesting and challenging** enough to engage students
  - **Connected to real-world** applications
  - **Suited for discussion** in groups
- Learning objectives (numbered list, 3-5 items)
- Resource links (YouTube lectures, textbook sections)
- Parts organized by concept (typically 3-5 parts)
- **No page breaks between parts** (only first page has a page break)
- Each part contains:
  - Prose explanation building intuition (blog-like style)
  - Formal definition/theorem from textbook (with textbook reference, e.g., "Def. 1.5")
  - Worked example with step-by-step trace
  - 2-4 AI prompts (`deeper` and `broader` mixed)
- Summary section with concept relationship diagram

**What NOT to include**:
- ~~Explicit FIDS boxes~~ — FIDS is a mindset, not visible structure
- ~~Author footnotes~~ — Unless explicitly requested

**Reference**: `week1/1.learning-sheet.typ` Part 1 (lines 101-242)

---

### test.typ (Closed-Book Tests)

**Purpose**: 30-min assessment of previous week's content

**Content requirements**:
- Total 130 points (allows 100/130 as passing threshold)
- Part A: Multiple choice (15-20 pts)
- Part B-F: Mixed format (definitions, proofs, design problems)
- Questions should cover all key definitions/theorems from learning sheet
- **Scope rule**: Test content must not go beyond validation set

**Reference**: `week1/1.test.typ`

---

### test.B.typ (Make-up / Alternative Test)

**Purpose**: Alternative version for make-up tests or parallel sessions

**Content requirements**:
- Same structure and point distribution as test.typ
- Same difficulty level as test.typ
- **Different specific questions** (not identical to test.typ)
- Covers the same concepts and theorems
- Used for:
  - Students who missed the original test
  - Parallel sessions to prevent cheating

**Reference**: `week1/1.test.B.typ`

---

### validation.typ (Self-Validation Practice)

**Purpose**: Pre-test practice with AI allowed

**Content requirements**:
- Same structure and point distribution as test.typ
- Similar difficulty level to test
- Different specific questions (not identical)
- **Defines the test boundary**: Validation set establishes the full scope of testable content

**Reference**: `week1/1.validation.typ`

---

## Review Checklists

### Learning Sheet Checklist

```
[ ] Pre-work
    [ ] Checked existing materials in current week
    [ ] Checked plan.md if present
    [ ] Verified no overlap with previous week's content
    [ ] Brainstormed motivating task with user

[ ] FIDS mindset (implicit, not explicit)
    [ ] Feel: Motivating problem in task box — interesting, real-world, discussion-worthy
    [ ] Image: Solution concept introduced in opening prose
    [ ] Do: AI prompts distributed throughout
    [ ] Share: Summary section with diagram at end

[ ] Textbook coverage
    [ ] All definitions from assigned sections included
    [ ] All theorems from assigned sections included
    [ ] Definition/theorem numbering matches the textbook (e.g., "Def. 1.5")
    [ ] Content has no overlap with the previous week

[ ] Quality control
    [ ] Every symbol defined before first use
    [ ] Every concept explained before referenced
    [ ] Theorems are proved clearly
    [ ] No forward references to future weeks
    [ ] The motivating task is interesting, motivating and challenging enough
    [ ] Ensure every fact is verified, including proofs, references, etc
    [ ] No author footnotes (unless requested)

[ ] AI prompts
    [ ] Prompts are actionable (can paste directly to AI)

[ ] Formatting
    [ ] No page breaks between parts (only first page has page break)
    [ ] Blog-like prose, not fragmented bullet lists
    [ ] Smooth transitions between sections
    [ ] No explicit FIDS boxes
```

### Test/Validation Checklist

```
[ ] Format
    [ ] Total points = 130
    [ ] hide-solution toggle present
    [ ] Solutions provided for all questions

[ ] Coverage
    [ ] Questions cover all key definitions from learning sheet
    [ ] Questions cover all key theorems from learning sheet
    [ ] Mix of question types (MC, short answer, proofs, design)

[ ] Scope alignment
    [ ] Test does not exceed validation set scope
    [ ] Validation set covers all testable content
    [ ] Difficulty levels are comparable

[ ] Test.B alignment
    [ ] Same structure as test.typ
    [ ] Same difficulty as test.typ
    [ ] Different specific questions from test.typ

[ ] Quality control
    [ ] All symbols used are defined in learning sheet
    [ ] No concepts beyond assigned learning sheet
```

## References

- `week1/*` — Canonical examples for all file types
- `coursedesign/instructor-guide.typ` — Session structure and teaching tips
- `coursedesign/schedule.typ` — Weekly topic assignments and textbook sections
- `coursedesign/templates/*` — Template files for each material type
