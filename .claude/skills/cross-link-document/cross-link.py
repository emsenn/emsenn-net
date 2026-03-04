#!/usr/bin/env python3
"""Add wikilinks to an Obsidian vault by finding unlinked mentions.

For each link target defined in a JSON config, finds the first unlinked
mention in each .md file and replaces it with a [[wikilink]]. Skips
frontmatter, existing links, code blocks, and the target's own page.

Usage:
    python .claude/skills/cross-link-document/cross-link.py [CONFIG] [--dry-run] [--verbose]
    python .claude/skills/cross-link-document/cross-link.py --dry-run
    python scripts/cross-link.py --help
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path


# Directories to skip (relative to vault root)
SKIP_DIRS = {"private", "meta", "slop", "triage", ".obsidian"}

# Default config path relative to repo root
DEFAULT_CONFIG = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cross-link-config.json")


def load_config(config_path: str) -> list[dict]:
    """Load link targets from a JSON config file."""
    with open(config_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    if isinstance(data, dict) and "targets" in data:
        return data["targets"]
    if isinstance(data, list):
        return data
    raise ValueError(f"Config must be a JSON array or object with 'targets' key")


def should_skip_dir(dirpath: str, vault_root: str) -> bool:
    """Check if a directory should be skipped."""
    rel = os.path.relpath(dirpath, vault_root).replace("\\", "/")
    parts = rel.split("/")
    for part in parts:
        if part in SKIP_DIRS:
            return True
    return False


def find_md_files(vault_root: str) -> list[str]:
    """Walk the vault and collect all .md files, excluding skip dirs."""
    md_files = []
    for dirpath, dirnames, filenames in os.walk(vault_root):
        # Prune skip dirs in-place
        dirnames[:] = [
            d for d in dirnames
            if d not in SKIP_DIRS and not d.startswith(".")
        ]
        for fname in filenames:
            if fname.endswith(".md"):
                md_files.append(os.path.join(dirpath, fname))
    return md_files


def strip_frontmatter(content: str) -> tuple[str, int]:
    """Return the content after frontmatter and the line offset.

    Returns (body, frontmatter_end_index) where frontmatter_end_index is
    the character index where the body starts.
    """
    if not content.startswith("---"):
        return content, 0

    # Find the closing ---
    end_match = re.search(r"\n---\s*\n", content[3:])
    if end_match is None:
        return content, 0

    fm_end = 3 + end_match.end()
    return content[fm_end:], fm_end


def find_frontmatter_range(content: str) -> tuple[int, int]:
    """Return (start, end) character indices of YAML frontmatter, or (-1, -1)."""
    if not content.startswith("---"):
        return (-1, -1)
    end_match = re.search(r"\n---\s*\n", content[3:])
    if end_match is None:
        return (-1, -1)
    return (0, 3 + end_match.end())


def find_code_block_ranges(content: str) -> list[tuple[int, int]]:
    """Find all fenced code block ranges (``` ... ```)."""
    ranges = []
    # Fenced code blocks
    for m in re.finditer(r"^```[^\n]*\n.*?^```\s*$", content, re.MULTILINE | re.DOTALL):
        ranges.append((m.start(), m.end()))
    # Also match inline code `...`
    for m in re.finditer(r"`[^`\n]+`", content):
        ranges.append((m.start(), m.end()))
    return ranges


def find_indented_code_ranges(content: str) -> list[tuple[int, int]]:
    """Find indented code block ranges (4+ spaces or tab at line start)."""
    ranges = []
    for m in re.finditer(r"^(?:    |\t)[^\n]*(?:\n(?:    |\t)[^\n]*)*", content, re.MULTILINE):
        ranges.append((m.start(), m.end()))
    return ranges


def find_existing_link_ranges(content: str) -> list[tuple[int, int]]:
    """Find ranges of existing wikilinks and markdown links."""
    ranges = []
    # Wikilinks: [[...]]
    for m in re.finditer(r"\[\[[^\]]*\]\]", content):
        ranges.append((m.start(), m.end()))
    # Markdown links: [text](url)
    for m in re.finditer(r"\[[^\]]*\]\([^)]*\)", content):
        ranges.append((m.start(), m.end()))
    return ranges


def is_in_ranges(pos: int, length: int, ranges: list[tuple[int, int]]) -> bool:
    """Check if a span [pos, pos+length) overlaps with any protected range."""
    end = pos + length
    for r_start, r_end in ranges:
        if pos < r_end and end > r_start:
            return True
    return False


def is_adjacent_to_wikilink(content: str, pos: int, length: int) -> bool:
    """Check if the match is immediately preceded by [[ or followed by ]]."""
    # Check if preceded by [[
    if pos >= 2 and content[pos - 2:pos] == "[[":
        return True
    # Check if followed by ]]
    end = pos + length
    if end + 2 <= len(content) and content[end:end + 2] == "]]":
        return True
    return False


def build_search_pattern(term: str) -> re.Pattern:
    """Build a regex pattern for a search term with word boundaries.

    For multi-word terms, matches the exact phrase with word boundaries.
    For single words, matches the word with word boundaries.
    Case-sensitive matching (names are capitalized).
    """
    escaped = re.escape(term)
    # Use word boundaries
    pattern = rf"\b{escaped}\b"
    return re.compile(pattern)


def make_wikilink(matched_text: str, wikilink_target: str, display: str | None) -> str:
    """Construct the wikilink replacement string.

    If matched_text equals the wikilink target, use [[target]].
    If matched_text differs, use [[target|matched_text]] unless display is set.
    If display is set, use [[target|display]].
    """
    if display is not None:
        if display == wikilink_target:
            return f"[[{wikilink_target}]]"
        return f"[[{wikilink_target}|{display}]]"

    if matched_text == wikilink_target:
        return f"[[{wikilink_target}]]"
    else:
        return f"[[{wikilink_target}|{matched_text}]]"


def process_file(
    filepath: str,
    targets: list[dict],
    vault_root: str,
    dry_run: bool,
    verbose: bool,
) -> dict[str, int]:
    """Process a single file, adding wikilinks for all targets.

    Returns a dict mapping target wikilink -> number of links added (0 or 1).
    """
    rel_path = os.path.relpath(filepath, vault_root).replace("\\", "/")
    results = {}

    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except (OSError, UnicodeDecodeError) as e:
        if verbose:
            print(f"  SKIP {rel_path}: {e}", file=sys.stderr)
        return results

    original_content = content
    modified = False

    for target in targets:
        wikilink_target = target["wikilink"]
        search_terms = target["search_terms"]
        display = target.get("display")
        self_path = target.get("self_path", "")

        # Skip if this is the target's own file
        if self_path and rel_path == self_path.replace("\\", "/"):
            results[wikilink_target] = 0
            continue

        # Sort search terms longest first so "Karl Marx" matches before "Marx"
        sorted_terms = sorted(search_terms, key=len, reverse=True)

        link_added = False
        for term in sorted_terms:
            if link_added:
                break

            pattern = build_search_pattern(term)

            # Recompute protected ranges each time (content may have changed)
            fm_range = find_frontmatter_range(content)
            code_ranges = find_code_block_ranges(content)
            indented_ranges = find_indented_code_ranges(content)
            link_ranges = find_existing_link_ranges(content)
            protected = []
            if fm_range[0] != -1:
                protected.append(fm_range)
            protected.extend(code_ranges)
            protected.extend(indented_ranges)
            protected.extend(link_ranges)

            for match in pattern.finditer(content):
                pos = match.start()
                length = match.end() - match.start()
                matched_text = match.group()

                # Skip if in a protected range
                if is_in_ranges(pos, length, protected):
                    continue

                # Skip if adjacent to wikilink brackets
                if is_adjacent_to_wikilink(content, pos, length):
                    continue

                # Found a valid match -- replace it
                replacement = make_wikilink(matched_text, wikilink_target, display)

                content = content[:pos] + replacement + content[pos + length:]
                link_added = True
                modified = True

                if verbose or dry_run:
                    # Find the line number
                    line_num = content[:pos].count("\n") + 1
                    action = "WOULD ADD" if dry_run else "ADDED"
                    print(f"  {action} {replacement} in {rel_path}:{line_num}")

                break  # Only first occurrence

        results[wikilink_target] = 1 if link_added else 0

    if modified and not dry_run:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)

    return results


def main():
    parser = argparse.ArgumentParser(
        description="Add wikilinks to an Obsidian vault by finding unlinked mentions."
    )
    parser.add_argument(
        "config",
        nargs="?",
        default=None,
        help=f"Path to JSON config file (default: {DEFAULT_CONFIG})",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print what would be changed without modifying files",
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Print each link addition",
    )
    parser.add_argument(
        "--vault-root",
        default=None,
        help="Path to the vault root (default: content/ relative to script location)",
    )
    args = parser.parse_args()

    # Determine repo root (ancestor of .claude/skills/cross-link-document/)
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

    # Config path
    if args.config:
        config_path = os.path.abspath(args.config)
    else:
        config_path = os.path.join(repo_root, DEFAULT_CONFIG)

    if not os.path.isfile(config_path):
        print(f"Error: config file not found: {config_path}", file=sys.stderr)
        sys.exit(1)

    # Load config
    targets = load_config(config_path)
    if not targets:
        print("No link targets found in config.", file=sys.stderr)
        sys.exit(1)

    print(f"Loaded {len(targets)} link targets from {config_path}")
    if args.dry_run:
        print("DRY RUN -- no files will be modified\n")
    print()

    # Find all .md files
    md_files = find_md_files(vault_root)
    print(f"Found {len(md_files)} markdown files under {vault_root}\n")

    # Track results per target
    totals = {t["wikilink"]: {"files_linked": 0, "files_checked": 0} for t in targets}
    files_modified = set()

    for filepath in sorted(md_files):
        results = process_file(filepath, targets, vault_root, args.dry_run, args.verbose)
        for wikilink, count in results.items():
            totals[wikilink]["files_checked"] += 1
            if count > 0:
                totals[wikilink]["files_linked"] += count
                files_modified.add(filepath)

    # Print summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)

    total_links = 0
    for target in targets:
        wl = target["wikilink"]
        info = totals[wl]
        if info["files_linked"] > 0:
            total_links += info["files_linked"]
            print(f"  [[{wl}]]: {info['files_linked']} links added")

    print(f"\nTotal files modified: {len(files_modified)}")
    print(f"Total links added: {total_links}")

    targets_with_zero = [
        t["wikilink"] for t in targets if totals[t["wikilink"]]["files_linked"] == 0
    ]
    if targets_with_zero:
        print(f"\nTargets with no unlinked mentions found ({len(targets_with_zero)}):")
        for wl in targets_with_zero:
            print(f"  [[{wl}]]")


if __name__ == "__main__":
    main()
