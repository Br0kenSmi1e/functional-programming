---
name: bootstrap
description: Use when setting up a new course from a forked template repo — ingests existing reference materials (syllabus/slides/notes), writes config.toml, fills HTML/workflow placeholders, ingests textbook PDFs, creates the weekly schedule, and enables GitHub Pages deployment when possible
---

# Bootstrap Course

Run once after forking the template repo. Produces:

1. `reference/*.md` (existing course materials converted to markdown, used to pre-fill metadata)
2. `config.toml` (course metadata; the checked-in `config.typ` shim loads it and re-exports the fields for Typst templates)
3. Substituted placeholders in `.github/templates/*.html` (the release-materials workflow reads `config.toml` at runtime; no workflow substitution needed)
4. `textbook/*.md` (extracted chapters)
5. `coursedesign/schedule.typ` (weekly section assignments)
6. GitHub Pages configured to use the included `deploy-pages.yml` workflow, when the repository is already on GitHub and the authenticated user has permission

## Step 1: Collect reference materials

Ask the user (via `AskUserQuestion`) whether they have existing course materials such as:
- Course proposal or syllabus
- Past lecture slides (PPT/PPTX)
- Past lecture notes or handouts (PDF/DOCX)
- Past exams or assignments

If yes, instruct them to place the files in the `reference/` directory and wait for confirmation. See `reference/README.md` for the list of valuable inputs.

Scan the directory and report what was found:

```bash
uv sync
uv run python -m scripts.scan_references reference/
```

Convert non-markdown files to markdown in place:

```bash
uv run python -m scripts.convert_references reference/
```

After conversion, report converted count and any errors. The `.md` files stay in `reference/` alongside the originals (binaries are gitignored, `.md` is checked in).

If the user has no reference materials, skip to Step 2 and ask for every field manually.

## Step 2: Gather metadata

If reference materials exist, extract metadata first:

```bash
uv run python -m scripts.extract_metadata reference/
```

This pulls course code, course name, textbook (incl. ISBN), instructor, institution, num-weeks, semester, and weekly topics from the converted markdown — each tagged with its source file and a confidence level (`high`, `medium`, `uncertain`, or `possibly outdated`).

Present the extractions to the user via `AskUserQuestion`, clearly marking:
- **Extracted fields** — show value + source (e.g. `Course code: PHYS 2071 (from syllabus.md)`)
- **Missing fields** — ask the user to provide
- **Possibly-outdated fields** — items flagged from past semesters (old instructor names, last year's dates) need confirmation or update
- **Conflicting values** — when multiple sources disagree, show all and ask which is correct

If no reference materials are available, fall back to asking each field directly. One question per field, "Other" for free text:

| Field | Example |
|-------|---------|
| Course code | `DSAA 3071`, `PHYS 2071` |
| Course name (tagline) | `Theories in Computing`, `Quantum Physics` |
| Textbook author | `Sipser`, `Griffiths` |
| Textbook title | `Introduction to the Theory of Computation` |
| Textbook edition | `3rd ed.` |
| Number of weeks | `13` |
| Instructor | `Jane Doe` |
| Institution | `HKUST(GZ)` |
| Zulip stream (optional) | `DSAA3071-2026-Spring` — leave blank to skip the release workflow entirely (Step 7 then doesn't apply) |

The Zulip stream is the only optional field. If the user doesn't say they want Zulip drip-release, do not prompt for it — leave it blank and move on. It can be filled in later by editing `config.toml`; the workflow self-disables while it's empty.

## Step 3: Write `config.toml`

Copy `config.toml.example` to `config.toml` and fill in the values:

```toml
course-code      = "DSAA 3071"
course-name      = "Theories in Computing"
textbook-author  = "Sipser"
textbook-title   = "Introduction to the Theory of Computation"
textbook-edition = "3rd ed."
instructor       = "Jin-Guo Liu"
institution      = "HKUST(GZ)"
zulip-stream     = ""   # optional; "" disables the release workflow. Set only if user opted in.
textbook-short   = ""   # empty → falls back to textbook-author
```

Do **not** edit `config.typ` — it's a checked-in shim that just calls
`toml("config.toml")` and re-exports each field, so existing template imports
(`#import "../config.typ": course-code, ...`) keep working unchanged.

## Step 4: Substitute placeholders

Replace these tokens in `.github/templates/`:

| Token | Replace with | Files |
|-------|-------------|-------|
| `{{COURSE_CODE}}` | course code | `.github/templates/*.html` |
| `{{COURSE_NAME}}` | course name | `.github/templates/*.html` |
| `{{TEXTBOOK_SHORT}}` | textbook-short (or textbook-author) | `.github/templates/index.html` |
| `{{TEXTBOOK_INFO}}` | `<author>, <em>Title</em> (<edition>)` | `.github/templates/setup-guide.html` |
| `{{INSTITUTION}}` | institution | `.github/templates/*.html` |

The `release-materials.yml` workflow reads `zulip-stream` from `config.toml`
at runtime, so no substitution is needed there. Verify no course-level
`{{...}}` tokens remain in templates (placeholders like `{{WEEK}}`,
`{{TITLE}}`, `{{FILENAME}}`, `{{PAGES_JSON}}` are filled per-build by the
Makefile and should still be present):

```bash
grep -rE '\{\{(COURSE_CODE|COURSE_NAME|TEXTBOOK_INFO|TEXTBOOK_SHORT|INSTITUTION)\}\}' .github/ \
  && echo "ERROR: unfilled placeholders" || echo "OK"
```

## Step 5: Ingest textbook

Ask for the textbook PDF path(s). For each PDF, extract chapters into `textbook/NN.md`. Each file:

```markdown
# Chapter N: [Title]

## N.1 [Section Title]

**Definition N.1 ([Name])**
[formal statement]

**Theorem N.2 ([Name])**
[statement]

*Proof.* [proof text]

**Example N.3**
[worked example]
```

Rules:
- Preserve the textbook's numbering exactly (Definition 2.1, Theorem 3.4, etc.)
- Extract ALL definitions, theorems, lemmas, corollaries, proofs, and key examples
- Omit exercises, historical notes, and filler prose
- Keep mathematical notation in LaTeX-compatible form

After extraction, summarize for the user: chapters, definitions, theorems, proofs per chapter. Let them verify before proceeding.

## Step 6: Create schedule

Read all `textbook/*.md`. Propose a weekly schedule mapping textbook sections to weeks. Use `coursedesign/schedule.example.typ` as a structural reference.

Schedule format:

```typst
#show link: set text(blue)

= Course schedule

#align(center, text(10pt)[#table(columns: 4, inset: 7pt,
  table.header([*Week*], [*Sections*], [*Topics*], [*Resources*]),
  [1], [§1.1, §1.2], [Topic A], align(left)[- resource link],
  // ...
)])
```

Guidelines:
- Each week covers a coherent topic (don't split a concept across weeks)
- Earlier weeks build foundations; later weeks use them
- Balance content volume roughly evenly
- Group related sections

Present the schedule to the user, let them adjust ordering/grouping/week count, then write to `coursedesign/schedule.typ`.

## Step 7: (optional) Seed `coursedesign/release-schedule.json`

Skip this entire step if `zulip-stream` is blank in `config.toml` — the workflow self-disables and no schedule file is needed.

If the user enabled Zulip release, copy `coursedesign/release-schedule.example.json` to `coursedesign/release-schedule.json` and seed the first few entries. Format:

```json
[
  {"date": "2026-02-15", "time": "09:00", "week": 1, "action": "learning-sheet"},
  {"date": "2026-02-19", "time": "18:00", "week": 1, "action": "validation"},
  {"date": "2026-02-22", "time": "23:00", "week": 1, "action": "test-answer"}
]
```

Times are Beijing time. The hourly cron job picks up matching entries.

## Step 8: Configure GitHub Pages

The template already includes:
- `.github/templates/` — static website templates for the course index, PDF viewer, setup guide, and styles
- `.github/workflows/deploy-pages.yml` — a workflow that runs `make build`, uploads `_site/`, and deploys it to GitHub Pages

GitHub Pages itself still has to be enabled once for the course repository. If the repository has a GitHub `origin` remote and `gh` is authenticated, ask the user whether to enable Pages automatically. If they agree, first identify the repository:

```bash
gh repo view --json nameWithOwner -q .nameWithOwner
```

Then check whether Pages is already enabled:

```bash
gh api "repos/OWNER/REPO/pages" --jq '{html_url, build_type}'
```

In all `gh api` commands below, replace `OWNER/REPO` with the repository returned by `gh repo view`. If this returns an existing site whose `build_type` is `workflow`, report the Pages URL and continue. If Pages is not enabled, create it with the GitHub Actions workflow build type:

```bash
gh api --method POST "repos/OWNER/REPO/pages" -f build_type=workflow
```

If Pages exists but uses another build type, update it:

```bash
gh api --method PUT "repos/OWNER/REPO/pages" -f build_type=workflow
```

If any command fails because the repository is not on GitHub, `gh` is not authenticated, or the user lacks repository administrator / "manage GitHub Pages settings" permission, do not fail bootstrap. Report the manual fallback:

1. Push the repository to GitHub.
2. Open the repository page.
3. Go to `Settings -> Pages`.
4. Set `Source` to `GitHub Actions`.

After Pages is enabled, the included `deploy-pages.yml` workflow publishes on pushes to `main` that touch weekly Typst files, `.github/templates/**`, `config.toml`, the Makefile, or the workflow itself.

## After bootstrap

The repo is ready. The user can now run:
- `/generate-week N` — full pipeline for week N
- `/write-learning-sheet N` — single learning sheet
- `/review-learning-sheet N` — review against quality criteria

Verify the build works:

```bash
make build
```

For local preview, run `make serve`.
