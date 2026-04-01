#!/usr/bin/env python3
"""Ensure a unit file has date-created and date-modified frontmatter.

Sets date-created if absent (to today). Updates date-modified to today.
Does not modify any other frontmatter.
"""
import argparse
import re
import sys
from pathlib import Path
from typing import Annotated
from pydantic import Field


def stamp_dates(
    unit_path: Annotated[str, Field(description="Path to the unit .md file")],
    today: Annotated[str, Field(description="Today's date as YYYY-MM-DD")],
) -> str:
    path = Path(unit_path)
    if not path.exists():
        print(f"error: {path} not found", file=sys.stderr)
        sys.exit(1)

    text = path.read_text(encoding="utf-8")

    # Check for frontmatter block
    if not text.startswith("---"):
        print(f"error: {path} has no frontmatter block", file=sys.stderr)
        sys.exit(1)

    end = text.index("---", 3)
    frontmatter = text[3:end]
    body = text[end + 3:]

    # Set date-created if absent
    if "date-created:" not in frontmatter:
        frontmatter = frontmatter.rstrip() + f"\ndate-created: {today}\n"

    # Update date-modified
    if "date-modified:" in frontmatter:
        frontmatter = re.sub(
            r"date-modified:\s*\S+",
            f"date-modified: {today}",
            frontmatter,
        )
    else:
        frontmatter = frontmatter.rstrip() + f"\ndate-modified: {today}\n"

    path.write_text(f"---{frontmatter}---{body}", encoding="utf-8")
    return f"ok: stamped {path}"


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=description)
    p.add_argument("--unit-path", required=True)
    p.add_argument("--today", required=True)
    args = p.parse_args()
    print(stamp_dates(args.unit_path, args.today))
