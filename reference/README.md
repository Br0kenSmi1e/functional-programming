# Reference Materials

Place your existing course materials here before running `/bootstrap`. They help auto-populate course configuration and inform weekly material generation.

## Valuable References

The more you provide, the better the generated materials. Roughly in order of usefulness:

| Material | Why it helps |
|---|---|
| **Course syllabus** | Extracts course code, name, textbook, instructor, institution, weekly schedule |
| **Textbook PDF** | Primary source for definitions, theorems, proofs, and examples (goes in `textbook/` after ingestion) |
| **Past lecture slides** (PPT/PPTX) | Reveals which topics get emphasis, preferred examples, notation conventions |
| **Past exams or assignments** | Shows expected difficulty level and question style for test generation |
| **Course proposal / description** | Provides learning objectives and prerequisite assumptions |
| **Lecture notes or handouts** (PDF/DOCX) | Supplements textbook with instructor-specific explanations |
| **Weekly schedule or calendar** | Directly maps topics to weeks, saving manual configuration |

## Information Needed

The bootstrap process extracts the following from your materials. Anything not found will be asked manually.

**Required** (must be provided one way or another):
- Course code (e.g., `MATH 2071`)
- Course name (e.g., `Discrete Mathematics`)
- Textbook title and author
- Number of teaching weeks
- Instructor name
- Institution name

**Optional but helpful** (improves generated materials):
- Weekly topic breakdown with textbook section mappings
- Learning objectives per week
- Prerequisite knowledge assumptions
- Preferred notation or conventions
- Past exam questions (for calibrating difficulty)

## Supported Formats

Files are automatically converted to markdown during bootstrap:

- **PDF** (.pdf) — via `pymupdf`
- **PowerPoint** (.pptx) — via `python-pptx`
- **Word** (.docx) — via `python-docx`
- **Markdown** (.md) / **Text** (.txt) — used directly, no conversion needed

Legacy formats (.ppt, .doc) are not reliably supported. Convert them to .pptx/.docx first.

## What Happens During Bootstrap

1. You place files here
2. `scripts/scan_references.py` reports what was found
3. `scripts/convert_references.py` converts everything to markdown
4. `scripts/extract_metadata.py` extracts course info from the markdown
5. You confirm or correct the extracted values
6. The textbook is ingested separately into `textbook/`
