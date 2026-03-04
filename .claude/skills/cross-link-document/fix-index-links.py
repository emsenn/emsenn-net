#!/usr/bin/env python3
"""Fix orphan pages by adding missing links to index.md files.

Walks all directories in content/ and for each index.md:
  1. Lists sibling .md files in the same directory
  2. Lists immediate subdirectories with their own index.md
  3. Detects which are already linked from the index.md
  4. Appends wikilinks for any unlinked siblings/children

Usage:
    python .claude/skills/cross-link-document/fix-index-links.py [--dry-run] [--verbose]
    python .claude/skills/cross-link-document/fix-index-links.py --vault-root PATH
"""

import argparse
import os
import re
import sys
from collections import defaultdict
from pathlib import Path


# Directories to skip entirely (relative to vault root)
SKIP_DIRS = {"private", "meta", "slop", "triage", ".obsidian"}

# Directory paths to skip (relative to vault root, using forward slashes)
# Babbles and letters are navigated by date, not index
SKIP_PATHS = {
    "personal/writing/babbles",
    "personal/writing/letters-to-the-web",
}


def should_skip_dir(rel_dir: str) -> bool:
    """Check if a directory should be skipped based on exclusion rules."""
    parts = rel_dir.replace("\\", "/").split("/")
    for part in parts:
        if part in SKIP_DIRS or part.startswith("."):
            return True
    # Check full path prefixes
    normalized = rel_dir.replace("\\", "/")
    for skip_path in SKIP_PATHS:
        if normalized == skip_path or normalized.startswith(skip_path + "/"):
            return True
    return False


def parse_title_from_frontmatter(content: str) -> str:
    """Extract title from YAML frontmatter."""
    if not content.startswith("---"):
        return ""
    end_match = re.search(r"\n---\s*\n", content[3:])
    if end_match is None:
        return ""
    fm_text = content[3:3 + end_match.start()]
    title_match = re.search(r'^title:\s*["\']?(.+?)["\']?\s*$', fm_text, re.MULTILINE)
    if title_match:
        return title_match.group(1).strip().strip("\"'")
    return ""


def extract_linked_targets(content: str) -> set[str]:
    """Extract all link targets from an index.md, normalized to lowercase stems.

    Detects:
    - Wikilinks: [[target]], [[target|display]]
    - Markdown links: [text](path), [text](./path)
    """
    targets = set()

    # Wikilinks: [[target]] or [[target|display]] or [[target#heading]]
    for m in re.finditer(r"\[\[([^\]]+)\]\]", content):
        raw = m.group(1)
        # Strip display text after |
        if "|" in raw:
            raw = raw.split("|")[0]
        # Strip heading reference after #
        if "#" in raw:
            raw = raw.split("#")[0]
        raw = raw.strip()
        if raw:
            # Normalize: take just the stem (last path component, no extension)
            stem = raw.replace("\\", "/").rstrip("/")
            if "/" in stem:
                stem = stem.rsplit("/", 1)[-1]
            if stem.endswith(".md"):
                stem = stem[:-3]
            # Also handle index references -- if stem is "index", use the
            # parent directory name from the raw path
            if stem == "index" and "/" in raw.replace("\\", "/"):
                parts = raw.replace("\\", "/").rstrip("/").split("/")
                if len(parts) >= 2:
                    stem = parts[-2]
            targets.add(stem.lower())
            # Also add the full raw lowered (for path-based matching)
            targets.add(raw.lower().replace("\\", "/"))

    # Markdown links: [text](path) -- skip external URLs
    for m in re.finditer(r"\[[^\]]*\]\(([^)]+)\)", content):
        raw = m.group(1)
        if raw.startswith("http://") or raw.startswith("https://") or raw.startswith("mailto:"):
            continue
        # Strip anchors and query params
        if "#" in raw:
            raw = raw.split("#")[0]
        if "?" in raw:
            raw = raw.split("?")[0]
        raw = raw.strip().lstrip("./")
        if raw:
            # Normalize path
            normalized = raw.replace("\\", "/").rstrip("/")
            # Extract stem
            stem = normalized
            if "/" in stem:
                stem = stem.rsplit("/", 1)[-1]
            if stem.endswith(".md"):
                stem = stem[:-3]
            # Handle index.md references -> use parent dir name
            if stem == "index":
                parts = normalized.rstrip("/").split("/")
                if len(parts) >= 2:
                    stem = parts[-2]
                elif len(parts) == 1 and parts[0] != "index.md":
                    stem = parts[0]
            targets.add(stem.lower())
            targets.add(normalized.lower())

    return targets


def find_frontmatter_end_line(lines: list[str]) -> int:
    """Return the line index after the closing --- of YAML frontmatter.

    Returns 0 if no frontmatter is found.
    """
    if not lines or lines[0].strip() != "---":
        return 0
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            return i + 1
    return 0


def find_last_list_section(content: str) -> tuple[int, str | None]:
    """Find the position to insert new links.

    Strategy:
    1. Skip YAML frontmatter entirely.
    2. If there's a section (## header) followed by a bullet list, find the
       last such section and return the position after its last bullet item.
    3. If there are bare bullet lists (no header), return the position after
       the last bullet.
    4. If no list sections exist, return -1 (meaning we need to add a new section).

    Returns (insert_position, section_header_or_none).
    """
    lines = content.split("\n")
    fm_end = find_frontmatter_end_line(lines)

    last_bullet_line_idx = -1
    last_section_header = None

    # Track section headers and bullet positions
    current_section = None
    in_bullet_block = False

    for i in range(fm_end, len(lines)):
        line = lines[i]
        stripped = line.strip()
        if stripped.startswith("## "):
            current_section = stripped
            in_bullet_block = False
        elif stripped.startswith("- "):
            in_bullet_block = True
            last_bullet_line_idx = i
            if current_section:
                last_section_header = current_section
        elif stripped == "":
            # Blank line might end a bullet block, but we track the last
            # bullet regardless
            pass
        elif in_bullet_block and not stripped.startswith("- "):
            # Non-bullet, non-blank line ends the bullet block
            in_bullet_block = False

    if last_bullet_line_idx >= 0:
        # Find the character position at the end of the last bullet line
        pos = 0
        for i, line in enumerate(lines):
            if i == last_bullet_line_idx:
                pos += len(line)
                return pos, last_section_header
            pos += len(line) + 1  # +1 for newline

    return -1, None


def stem_to_title(stem: str) -> str:
    """Convert a filename stem to a readable title.

    E.g., 'food-sovereignty' -> 'Food Sovereignty'
    """
    return stem.replace("-", " ").title()


def process_directory(
    dir_path: str,
    vault_root: str,
    dry_run: bool,
    verbose: bool,
) -> tuple[int, list[str]]:
    """Process a single directory's index.md.

    Returns (links_added_count, list_of_link_descriptions).
    """
    index_path = os.path.join(dir_path, "index.md")
    if not os.path.isfile(index_path):
        return 0, []

    rel_dir = os.path.relpath(dir_path, vault_root).replace("\\", "/")
    if rel_dir == ".":
        rel_dir = ""

    # Read the index.md
    try:
        with open(index_path, "r", encoding="utf-8") as f:
            content = f.read()
    except (OSError, UnicodeDecodeError):
        return 0, []

    # Find all linked targets (normalized to lowercase stems)
    linked = extract_linked_targets(content)

    # Collect unlinked siblings and children
    unlinked_files = []  # (stem, kind) where kind is 'file' or 'dir'
    unlinked_dirs = []

    # 1. Sibling .md files in the same directory (not in subdirs)
    try:
        entries = os.listdir(dir_path)
    except OSError:
        return 0, []

    for entry in sorted(entries):
        full = os.path.join(dir_path, entry)

        if os.path.isfile(full) and entry.endswith(".md") and entry != "index.md":
            stem = entry[:-3]  # Remove .md
            # Check if this stem is already linked
            if stem.lower() not in linked:
                unlinked_files.append(stem)

        elif os.path.isdir(full) and not entry.startswith("."):
            # Check if this subdirectory has its own index.md
            sub_index = os.path.join(full, "index.md")
            if os.path.isfile(sub_index):
                # Check if the subdirectory name is already linked
                if entry.lower() not in linked:
                    # Also check if it's linked via path like "subdir/index.md"
                    path_variants = [
                        entry.lower(),
                        f"{entry}/index".lower(),
                        f"{entry}/index.md".lower(),
                        f"./{entry}/index.md".lower(),
                        f"./{entry}/".lower(),
                        f"./{entry}".lower(),
                    ]
                    if not any(v in linked for v in path_variants):
                        unlinked_dirs.append(entry)

    if not unlinked_files and not unlinked_dirs:
        return 0, []

    # Build the new links text
    new_links = []
    descriptions = []

    for stem in sorted(unlinked_files):
        link = f"- [[{stem}]]"
        new_links.append(link)
        descriptions.append(f"  + [[{stem}]] (file)")

    for dirname in sorted(unlinked_dirs):
        # Try to read the subdirectory index.md title
        sub_index_path = os.path.join(dir_path, dirname, "index.md")
        sub_title = ""
        try:
            with open(sub_index_path, "r", encoding="utf-8") as f:
                sub_content = f.read()
            sub_title = parse_title_from_frontmatter(sub_content)
        except (OSError, UnicodeDecodeError):
            pass

        if sub_title:
            link = f"- [[{dirname}|{sub_title}]]"
        else:
            link = f"- [[{dirname}]]"
        new_links.append(link)
        descriptions.append(f"  + [[{dirname}]] (dir)")

    total_new = len(new_links)
    links_block = "\n".join(new_links)

    # Determine where to insert
    insert_pos, section_header = find_last_list_section(content)

    if insert_pos >= 0:
        # Append to existing list section
        # Make sure there's a newline before our new links
        before = content[:insert_pos]
        after = content[insert_pos:]
        new_content = before + "\n" + links_block + after
    else:
        # No existing list section -- add a new "## Entries" section at the end
        # Ensure trailing newline before new section
        if content and not content.endswith("\n"):
            content += "\n"
        new_content = content + "\n## Entries\n\n" + links_block + "\n"

    if verbose or dry_run:
        action = "WOULD MODIFY" if dry_run else "MODIFYING"
        print(f"{action}: {rel_dir}/index.md (+{total_new} links)")
        for desc in descriptions:
            print(desc)

    if not dry_run:
        with open(index_path, "w", encoding="utf-8") as f:
            f.write(new_content)

    return total_new, descriptions


def main():
    parser = argparse.ArgumentParser(
        description="Fix orphan pages by adding missing links to index.md files."
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print what would be changed without modifying files",
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Print details of each modification",
    )
    parser.add_argument(
        "--vault-root",
        default=None,
        help="Path to the vault root (default: content/ relative to script location)",
    )
    args = parser.parse_args()

    # Determine repo root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(os.path.dirname(os.path.dirname(script_dir)))

    # Vault root
    if args.vault_root:
        vault_root = os.path.abspath(args.vault_root)
    else:
        vault_root = os.path.join(repo_root, "content")

    if not os.path.isdir(vault_root):
        print(f"Error: vault root not found: {vault_root}", file=sys.stderr)
        sys.exit(1)

    print(f"Scanning vault at: {vault_root}", file=sys.stderr)
    if args.dry_run:
        print("DRY RUN -- no files will be modified\n", file=sys.stderr)

    # Walk all directories
    total_dirs_scanned = 0
    total_files_modified = 0
    total_links_added = 0
    dir_stats = []  # (rel_dir, links_added)

    for dirpath, dirnames, filenames in os.walk(vault_root):
        # Prune skip dirs in-place
        dirnames[:] = [
            d for d in dirnames
            if d not in SKIP_DIRS and not d.startswith(".")
        ]

        rel_dir = os.path.relpath(dirpath, vault_root).replace("\\", "/")
        if rel_dir == ".":
            rel_dir = ""

        # Check if this directory should be skipped by path
        if rel_dir and should_skip_dir(rel_dir):
            dirnames.clear()  # Don't descend further
            continue

        # Only process if there's an index.md
        if "index.md" not in filenames:
            continue

        total_dirs_scanned += 1
        links_added, descriptions = process_directory(
            dirpath, vault_root, args.dry_run, args.verbose
        )

        if links_added > 0:
            total_files_modified += 1
            total_links_added += links_added
            dir_stats.append((rel_dir if rel_dir else "(root)", links_added))

    # Sort by links added descending
    dir_stats.sort(key=lambda x: -x[1])

    # Report
    print(f"\n{'=' * 60}", file=sys.stderr)
    print(f"SUMMARY", file=sys.stderr)
    print(f"{'=' * 60}", file=sys.stderr)
    print(f"Directories with index.md scanned: {total_dirs_scanned}", file=sys.stderr)
    print(f"index.md files modified: {total_files_modified}", file=sys.stderr)
    print(f"New links added: {total_links_added}", file=sys.stderr)

    if dir_stats:
        print(f"\nTop directories by links added:", file=sys.stderr)
        for rel_dir, count in dir_stats[:10]:
            print(f"  {count:>4}  {rel_dir}/index.md", file=sys.stderr)

    if len(dir_stats) > 10:
        remaining = sum(c for _, c in dir_stats[10:])
        print(f"  ... and {len(dir_stats) - 10} more directories ({remaining} links)", file=sys.stderr)


if __name__ == "__main__":
    main()
