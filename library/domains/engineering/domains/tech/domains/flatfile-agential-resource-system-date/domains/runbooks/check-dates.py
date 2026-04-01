#!/usr/bin/env python3
"""Report unit .md files missing date-created or date-modified frontmatter."""
import argparse
import re
import sys
from pathlib import Path
from typing import Annotated
from pydantic import Field


def check_dates(
    directory: Annotated[str, Field(description="Directory to scan recursively")],
) -> str:
    missing = []
    for path in sorted(Path(directory).rglob("*.md")):
        # Skip context files
        if path.name in {"AGENTS.md", "PLANS.md", "IDEAS.md", "MEMORY.md",
                         "INBOX.md", "SOUL.md"}:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        if not text.startswith("---"):
            continue
        try:
            end = text.index("---", 3)
        except ValueError:
            continue
        frontmatter = text[3:end]
        issues = []
        if "date-created:" not in frontmatter:
            issues.append("missing date-created")
        if "date-modified:" not in frontmatter:
            issues.append("missing date-modified")
        if issues:
            missing.append(f"{path}: {', '.join(issues)}")

    if missing:
        print("\n".join(missing))
        sys.exit(1)
    print(f"ok: all unit files in {directory} have date frontmatter")
    return "ok"


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=description)
    p.add_argument("--directory", required=True)
    args = p.parse_args()
    check_dates(args.directory)
