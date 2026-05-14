#!/usr/bin/env python3
"""Extract course metadata from converted reference materials.

Usage:
    python -m scripts.extract_metadata reference/

Scans all .md and .txt files in the directory, extracts course metadata
using regex heuristics, and outputs structured JSON.

The output is a best-effort extraction — the AI agent should present
results to the user for confirmation and fill in gaps.
"""

import json
import re
import sys
from dataclasses import dataclass, field, asdict
from pathlib import Path


@dataclass
class Extraction:
    value: str
    source: str  # filename where found
    confidence: str = "high"  # high, medium, low


@dataclass
class Metadata:
    course_code: list[Extraction] = field(default_factory=list)
    course_name: list[Extraction] = field(default_factory=list)
    textbook: list[Extraction] = field(default_factory=list)
    instructor: list[Extraction] = field(default_factory=list)
    institution: list[Extraction] = field(default_factory=list)
    num_weeks: list[Extraction] = field(default_factory=list)
    semester: list[Extraction] = field(default_factory=list)
    weekly_topics: list[Extraction] = field(default_factory=list)


# Patterns for course codes: "MATH 1234", "CS-101", "PHYS2071", etc.
COURSE_CODE_RE = re.compile(
    r"\b([A-Z]{2,5}\s*[-]?\s*\d{3,5}[A-Z]?)\b"
)

# Patterns for semester/term references (potentially outdated)
SEMESTER_RE = re.compile(
    r"\b((?:Fall|Spring|Summer|Winter|Autumn)\s+\d{4})\b", re.IGNORECASE
)

# Patterns for week counts: "13 weeks", "Week 1-13", "weeks 1 through 12"
WEEK_COUNT_RE = re.compile(
    r"\b(\d{1,2})\s*weeks\b|\bweeks?\s*\d+\s*[-–to]+\s*(\d{1,2})\b", re.IGNORECASE
)

# Textbook patterns: "Textbook: ...", "Required text: ...", "ISBN ..."
TEXTBOOK_RE = re.compile(
    r"(?:textbook|required\s+text|course\s+text(?:book)?|reference\s+book)\s*[:\-–]\s*(.+)",
    re.IGNORECASE,
)

# ISBN pattern
ISBN_RE = re.compile(r"\bISBN[-:\s]*(\d[\d\-]{9,}[\dXx])\b")

# Instructor patterns
INSTRUCTOR_RE = re.compile(
    r"(?:instructor|professor|lecturer|taught\s+by|faculty)\s*[:\-–]\s*(.+)", re.IGNORECASE
)

# Institution from email domains or explicit mentions
EMAIL_DOMAIN_RE = re.compile(r"@([\w.]+\.edu)\b", re.IGNORECASE)
UNIVERSITY_RE = re.compile(
    r"\b((?:University|Institute|College|School)\s+of\s+[\w\s]+?"
    r"|[\w\s]+?(?:University|Institute|College|School))\b",
    re.IGNORECASE,
)


def extract_from_file(filepath: Path, meta: Metadata) -> None:
    """Extract metadata from a single file."""
    text = filepath.read_text(encoding="utf-8", errors="replace")
    name = filepath.name
    lines = text.split("\n")

    # Course code — skip ISBN and other false positives
    non_course_prefixes = {"ISBN", "ISSN", "HTTP", "HTTPS", "PAGE", "SLIDE"}
    for m in COURSE_CODE_RE.finditer(text):
        code = re.sub(r"\s+", " ", m.group(1).strip())
        prefix_word = code.split()[0] if " " in code else code.rstrip("0123456789- ")
        if prefix_word.upper() in non_course_prefixes:
            continue
        if not any(e.value == code for e in meta.course_code):
            meta.course_code.append(Extraction(code, name))

    # Course name: look for "CODE: Title" pattern in early lines
    for line in lines[:30]:
        line_stripped = line.strip().lstrip("#").strip()
        # Skip lines that look like ISBN or other non-title content
        if re.match(r"ISBN", line_stripped, re.IGNORECASE):
            continue
        # "MATH 1234: Introduction to Analysis" or "MATH 1234 — Topology"
        title_match = re.match(
            r"[A-Z]{2,5}\s*[-]?\s*\d{3,5}[A-Z]?\s*[:\-–—]\s*(.+)", line_stripped
        )
        if title_match:
            course_name = title_match.group(1).strip()
            # Filter out things that look like numbers (ISBN fragments, etc.)
            if course_name and not course_name.isdigit() and len(course_name) > 3:
                if not any(e.value == course_name for e in meta.course_name):
                    meta.course_name.append(Extraction(course_name, name))

    # Semester (flag as potentially outdated)
    for m in SEMESTER_RE.finditer(text):
        val = m.group(1)
        if not any(e.value == val for e in meta.semester):
            meta.semester.append(Extraction(val, name, confidence="low"))

    # Week count
    for m in WEEK_COUNT_RE.finditer(text):
        count = m.group(1) or m.group(2)
        if count and not any(e.value == count for e in meta.num_weeks):
            meta.num_weeks.append(Extraction(count, name))

    # Textbook
    for m in TEXTBOOK_RE.finditer(text):
        val = m.group(1).strip().rstrip(".")
        if val and not any(e.value == val for e in meta.textbook):
            meta.textbook.append(Extraction(val, name))

    # ISBN
    for m in ISBN_RE.finditer(text):
        val = f"ISBN {m.group(1)}"
        if not any(e.value == val for e in meta.textbook):
            meta.textbook.append(Extraction(val, name, confidence="medium"))

    # Instructor
    for m in INSTRUCTOR_RE.finditer(text):
        val = m.group(1).strip().rstrip(".")
        if val and not any(e.value == val for e in meta.instructor):
            meta.instructor.append(Extraction(val, name, confidence="low"))

    # Institution from email
    for m in EMAIL_DOMAIN_RE.finditer(text):
        domain = m.group(1)
        if not any(e.value == domain for e in meta.institution):
            meta.institution.append(Extraction(domain, name, confidence="medium"))

    # Institution from explicit mention
    for m in UNIVERSITY_RE.finditer(text):
        val = m.group(1).strip()
        if len(val) > 5 and not any(e.value == val for e in meta.institution):
            meta.institution.append(Extraction(val, name))

    # Weekly topics: look for "Week N: Topic" or "Week N - Topic" patterns
    week_topic_re = re.compile(r"[Ww]eek\s*(\d+)\s*[:\-–—]\s*(.+)")
    for m in week_topic_re.finditer(text):
        week_num = m.group(1)
        topic = m.group(2).strip().rstrip(".")
        if topic:
            val = f"Week {week_num}: {topic}"
            if not any(e.value == val for e in meta.weekly_topics):
                meta.weekly_topics.append(Extraction(val, name))


def format_field(extractions: list[Extraction], label: str) -> list[str]:
    """Format a metadata field for display."""
    if not extractions:
        return [f"  {label}: (not found)"]
    lines = []
    for e in extractions:
        conf = ""
        if e.confidence == "low":
            conf = " [possibly outdated]"
        elif e.confidence == "medium":
            conf = " [uncertain]"
        lines.append(f"  {label}: {e.value} (from {e.source}){conf}")
    return lines


def main():
    use_json = "--json" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]

    if not args:
        print(f"Usage: {sys.argv[0]} <directory> [--json]")
        sys.exit(1)

    ref_dir = Path(args[0])
    if not ref_dir.is_dir():
        print(f"Error: {ref_dir} is not a directory")
        sys.exit(1)

    meta = Metadata()
    files = sorted(ref_dir.glob("*.md")) + sorted(ref_dir.glob("*.txt"))
    files = [f for f in files if f.name.lower() != "readme.md"]

    if not files:
        print("No .md or .txt files found in reference/")
        sys.exit(0)

    for f in files:
        extract_from_file(f, meta)

    if use_json:
        print(json.dumps(asdict(meta), indent=2))
    else:
        print("Extracted course metadata:\n")
        for lines in [
            format_field(meta.course_code, "Course code"),
            format_field(meta.course_name, "Course name"),
            format_field(meta.textbook, "Textbook"),
            format_field(meta.instructor, "Instructor"),
            format_field(meta.institution, "Institution"),
            format_field(meta.num_weeks, "Weeks"),
            format_field(meta.semester, "Semester"),
        ]:
            for line in lines:
                print(line)
        if meta.weekly_topics:
            print("\n  Weekly topics found:")
            for e in meta.weekly_topics:
                print(f"    {e.value} (from {e.source})")


if __name__ == "__main__":
    main()
