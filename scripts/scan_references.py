#!/usr/bin/env python3
"""Scan reference directory and report file types.

Usage:
    python -m scripts.scan_references reference/

Prints a grouped summary of files by type and outputs JSON to stdout
when --json flag is used.
"""

import json
import sys
from collections import defaultdict
from pathlib import Path

SUPPORTED_EXTENSIONS = {".pdf", ".pptx", ".ppt", ".docx", ".doc"}
PASSTHROUGH_EXTENSIONS = {".md", ".txt"}
ALL_EXTENSIONS = SUPPORTED_EXTENSIONS | PASSTHROUGH_EXTENSIONS

EXT_LABELS = {
    ".pdf": "PDF",
    ".pptx": "PPTX",
    ".ppt": "PPT (legacy)",
    ".docx": "DOCX",
    ".doc": "DOC (legacy)",
    ".md": "Markdown",
    ".txt": "Text",
}


def scan(ref_dir: Path) -> dict[str, list[str]]:
    """Group files by extension. Returns {ext: [filename, ...]}."""
    groups: dict[str, list[str]] = defaultdict(list)
    for f in sorted(ref_dir.iterdir()):
        if f.name.startswith("."):
            continue
        if f.name.lower() == "readme.md":
            continue
        ext = f.suffix.lower()
        if ext in ALL_EXTENSIONS:
            groups[ext].append(f.name)
    return dict(groups)


def print_summary(groups: dict[str, list[str]]) -> None:
    if not groups:
        print("  (empty — no supported files found)")
        return
    for ext in sorted(groups):
        label = EXT_LABELS.get(ext, ext)
        files = groups[ext]
        names = ", ".join(files)
        noun = "file" if len(files) == 1 else "files"
        note = ""
        if ext in PASSTHROUGH_EXTENSIONS:
            note = " (no conversion needed)"
        elif ext in {".ppt", ".doc"}:
            note = " (legacy format — convert to .pptx/.docx first if possible)"
        print(f"  {len(files)} {label} {noun}: {names}{note}")

    convertible = sum(len(v) for k, v in groups.items() if k in SUPPORTED_EXTENSIONS)
    already_md = sum(len(v) for k, v in groups.items() if k in PASSTHROUGH_EXTENSIONS)
    print(f"\n  Total: {convertible} to convert, {already_md} already readable")


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

    groups = scan(ref_dir)

    if use_json:
        print(json.dumps(groups, indent=2))
    else:
        print(f"Found in {ref_dir}/:")
        print_summary(groups)


if __name__ == "__main__":
    main()
