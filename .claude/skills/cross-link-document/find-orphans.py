#!/usr/bin/env python3
"""Find orphan pages in an Obsidian vault — files with no incoming links.

Walks all .md files in content/ (excluding private/, meta/, slop/, triage/,
.obsidian/), extracts their identity (path, stem, title, aliases), then scans
all files for wikilinks and markdown links to build an incoming-link count.

Reports files with 0 incoming links, grouped by directory type.

Usage:
    python .claude/skills/cross-link-document/find-orphans.py [--vault-root PATH] [--json]
"""

import argparse
import json
import os
import re
import sys
from collections import defaultdict
from pathlib import Path


# Directories to skip (relative to vault root)
SKIP_DIRS = {"private", "meta", "slop", "triage", ".obsidian"}


def should_skip(rel_path: str) -> bool:
    """Check if a path should be skipped based on directory exclusions."""
    parts = rel_path.replace("\\", "/").split("/")
    for part in parts:
        if part in SKIP_DIRS or part.startswith("."):
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
                full = os.path.join(dirpath, fname)
                rel = os.path.relpath(full, vault_root).replace("\\", "/")
                if not should_skip(rel):
                    md_files.append(full)
    return md_files


def parse_frontmatter(content: str) -> dict:
    """Extract YAML frontmatter from a markdown file.

    Uses simple regex parsing instead of PyYAML to avoid external dependencies.
    Only extracts 'title' and 'aliases' fields.
    """
    if not content.startswith("---"):
        return {}
    end_match = re.search(r"\n---\s*\n", content[3:])
    if end_match is None:
        return {}
    fm_text = content[3:3 + end_match.start()]

    result = {}

    # Extract title
    title_match = re.search(r'^title:\s*["\']?(.+?)["\']?\s*$', fm_text, re.MULTILINE)
    if title_match:
        result["title"] = title_match.group(1).strip().strip("\"'")

    # Extract aliases - can be a YAML list (block or flow style)
    aliases = []

    # Flow style: aliases: [a, b, c]
    flow_match = re.search(r'^aliases:\s*\[([^\]]*)\]\s*$', fm_text, re.MULTILINE)
    if flow_match:
        raw = flow_match.group(1)
        for item in raw.split(","):
            item = item.strip().strip("\"'")
            if item:
                aliases.append(item)
    else:
        # Block style: aliases:\n  - a\n  - b
        block_match = re.search(r'^aliases:\s*\n((?:\s+-\s+.+\n?)*)', fm_text, re.MULTILINE)
        if block_match:
            for line in block_match.group(1).strip().split("\n"):
                line = line.strip()
                if line.startswith("- "):
                    item = line[2:].strip().strip("\"'")
                    if item:
                        aliases.append(item)
        else:
            # Single value: aliases: something
            single_match = re.search(r'^aliases:\s+(.+)$', fm_text, re.MULTILINE)
            if single_match:
                val = single_match.group(1).strip().strip("\"'")
                if val and not val.startswith("["):
                    aliases.append(val)

    if aliases:
        result["aliases"] = aliases

    return result


def build_file_registry(vault_root: str, md_files: list[str]) -> dict:
    """Build a registry of all files with their identifiers.

    Returns a dict mapping file_rel_path -> {
        "path": rel_path,
        "stem": filename without .md,
        "title": from frontmatter,
        "aliases": list from frontmatter,
        "is_index": bool,
        "dir_type": the immediate parent directory name (terms, concepts, etc.),
        "discipline": top-level discipline directory,
    }
    """
    registry = {}
    for filepath in md_files:
        rel_path = os.path.relpath(filepath, vault_root).replace("\\", "/")
        stem = Path(filepath).stem
        parts = rel_path.split("/")

        try:
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
        except (OSError, UnicodeDecodeError):
            continue

        fm = parse_frontmatter(content)
        title = fm.get("title", "")
        aliases = fm.get("aliases", [])
        if isinstance(aliases, str):
            aliases = [aliases]
        if not isinstance(aliases, list):
            aliases = []

        # Determine directory type and discipline
        is_index = (stem == "index")
        dir_type = parts[-2] if len(parts) >= 2 else "root"
        discipline = parts[0] if len(parts) >= 1 else "root"

        registry[rel_path] = {
            "path": rel_path,
            "abs_path": filepath,
            "stem": stem,
            "title": title if title else stem,
            "aliases": aliases,
            "is_index": is_index,
            "dir_type": dir_type,
            "discipline": discipline,
        }

    return registry


def build_lookup_tables(registry: dict) -> dict:
    """Build lookup tables mapping possible link targets to file paths.

    A file can be linked to by:
    - Its stem (filename without .md)
    - Its title
    - Any of its aliases
    - Its full relative path (without .md)
    - Its full relative path (with .md)
    """
    lookup = defaultdict(set)  # link_target -> set of rel_paths

    for rel_path, info in registry.items():
        stem = info["stem"]
        title = info["title"]
        aliases = info["aliases"]

        # Stem (case-insensitive matching)
        lookup[stem.lower()].add(rel_path)

        # Title
        if title:
            lookup[title.lower()].add(rel_path)

        # Aliases
        for alias in aliases:
            if alias:
                lookup[str(alias).lower()].add(rel_path)

        # Full path without .md
        path_no_ext = rel_path.rsplit(".md", 1)[0]
        lookup[path_no_ext.lower()].add(rel_path)

        # Full path with .md
        lookup[rel_path.lower()].add(rel_path)

    return lookup


def extract_link_targets(content: str) -> list[str]:
    """Extract all link targets from a markdown file's content.

    Finds:
    - Wikilinks: [[target]], [[target|display]], [[target#heading]]
    - Markdown links: [text](path.md), [text](path)
    """
    targets = []

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
            targets.append(raw)

    # Markdown links: [text](path)
    for m in re.finditer(r"\[[^\]]*\]\(([^)]+)\)", content):
        raw = m.group(1)
        # Skip external URLs
        if raw.startswith("http://") or raw.startswith("https://") or raw.startswith("mailto:"):
            continue
        # Strip anchors
        if "#" in raw:
            raw = raw.split("#")[0]
        # Strip query params
        if "?" in raw:
            raw = raw.split("?")[0]
        raw = raw.strip()
        if raw:
            targets.append(raw)

    return targets


def resolve_link(target: str, source_path: str, lookup: dict) -> set[str]:
    """Resolve a link target to file path(s) using the lookup tables.

    Tries multiple resolution strategies:
    1. Exact match on target (case-insensitive)
    2. Target with .md appended
    3. Relative path resolution from source file's directory
    """
    resolved = set()
    target_lower = target.lower()

    # Direct lookup
    if target_lower in lookup:
        resolved.update(lookup[target_lower])

    # With .md
    target_md = target_lower + ".md" if not target_lower.endswith(".md") else target_lower
    if target_md in lookup:
        resolved.update(lookup[target_md])

    # Without .md
    target_no_md = target_lower.rsplit(".md", 1)[0] if target_lower.endswith(".md") else target_lower
    if target_no_md in lookup:
        resolved.update(lookup[target_no_md])

    # Relative path resolution
    source_dir = os.path.dirname(source_path)
    if source_dir:
        rel_target = os.path.normpath(os.path.join(source_dir, target)).replace("\\", "/")
        rel_lower = rel_target.lower()
        if rel_lower in lookup:
            resolved.update(lookup[rel_lower])
        rel_md = rel_lower + ".md" if not rel_lower.endswith(".md") else rel_lower
        if rel_md in lookup:
            resolved.update(lookup[rel_md])
        rel_no_md = rel_lower.rsplit(".md", 1)[0] if rel_lower.endswith(".md") else rel_lower
        if rel_no_md in lookup:
            resolved.update(lookup[rel_no_md])

    return resolved


def count_incoming_links(vault_root: str, md_files: list[str], registry: dict, lookup: dict) -> dict:
    """Count incoming links for each file.

    Returns a dict mapping rel_path -> count of unique files linking to it.
    """
    incoming = defaultdict(set)  # rel_path -> set of source rel_paths

    for filepath in md_files:
        source_rel = os.path.relpath(filepath, vault_root).replace("\\", "/")

        try:
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
        except (OSError, UnicodeDecodeError):
            continue

        targets = extract_link_targets(content)

        for target in targets:
            resolved = resolve_link(target, source_rel, lookup)
            for dest_rel in resolved:
                if dest_rel != source_rel:  # Don't count self-links
                    incoming[dest_rel].add(source_rel)

    return {path: len(sources) for path, sources in incoming.items()}


def categorize_dir_type(rel_path: str) -> str:
    """Categorize a file by its directory type for grouping."""
    parts = rel_path.split("/")

    # Check for known directory types in the path
    known_types = [
        "terms", "concepts", "topics", "schools", "text", "people",
        "disciplines", "curricula", "history", "specifications",
        "objects", "languages", "events", "times",
    ]

    for part in reversed(parts[:-1]):  # Exclude the filename
        if part in known_types:
            return part

    # Fall back to the parent directory
    if len(parts) >= 2:
        return parts[-2]
    return "root"


def main():
    parser = argparse.ArgumentParser(
        description="Find orphan pages (files with no incoming links) in an Obsidian vault."
    )
    parser.add_argument(
        "--vault-root",
        default=None,
        help="Path to the vault root (default: content/ relative to script location)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output results as JSON",
    )
    parser.add_argument(
        "--include-index",
        action="store_true",
        help="Include index.md files in orphan report (excluded by default)",
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

    # Step 1: Find all .md files
    md_files = find_md_files(vault_root)
    print(f"Found {len(md_files)} markdown files", file=sys.stderr)

    # Step 2: Build file registry
    registry = build_file_registry(vault_root, md_files)
    print(f"Registered {len(registry)} files with metadata", file=sys.stderr)

    # Step 3: Build lookup tables
    lookup = build_lookup_tables(registry)
    print(f"Built lookup table with {len(lookup)} entries", file=sys.stderr)

    # Step 4: Count incoming links
    incoming_counts = count_incoming_links(vault_root, md_files, registry, lookup)
    print(f"Counted incoming links for {len(incoming_counts)} files", file=sys.stderr)

    # Step 5: Find orphans
    orphans = []
    for rel_path, info in registry.items():
        # Skip index files unless requested
        if info["is_index"] and not args.include_index:
            continue

        count = incoming_counts.get(rel_path, 0)
        if count == 0:
            orphans.append({
                "path": rel_path,
                "title": info["title"],
                "stem": info["stem"],
                "dir_type": categorize_dir_type(rel_path),
                "discipline": info["discipline"],
            })

    # Group by dir_type
    grouped = defaultdict(list)
    for orphan in orphans:
        grouped[orphan["dir_type"]].append(orphan)

    # Sort groups by count (most orphans first)
    sorted_groups = sorted(grouped.items(), key=lambda x: -len(x[1]))

    if args.json:
        output = {
            "total_files": len(registry),
            "total_non_index": sum(1 for v in registry.values() if not v["is_index"]),
            "total_orphans": len(orphans),
            "files_with_links": len(incoming_counts),
            "groups": {
                group: [o["path"] for o in items]
                for group, items in sorted_groups
            },
            "orphans": orphans,
        }
        print(json.dumps(output, indent=2))
    else:
        print(f"\n{'=' * 70}")
        print(f"ORPHAN REPORT")
        print(f"{'=' * 70}")
        print(f"Total files scanned: {len(registry)}")
        print(f"Total non-index files: {sum(1 for v in registry.values() if not v['is_index'])}")
        print(f"Files with at least 1 incoming link: {len(incoming_counts)}")
        print(f"Orphans (0 incoming links): {len(orphans)}")
        print(f"Orphan rate: {len(orphans) / max(1, sum(1 for v in registry.values() if not v['is_index'])) * 100:.1f}%")

        for group, items in sorted_groups:
            print(f"\n--- {group} ({len(items)} orphans) ---")
            # Sort by discipline then path
            items.sort(key=lambda x: x["path"])
            for item in items:
                print(f"  {item['path']}")
                if item["title"] != item["stem"]:
                    print(f"    title: {item['title']}")

        # Print a summary table of groups
        print(f"\n{'=' * 70}")
        print(f"SUMMARY BY DIRECTORY TYPE")
        print(f"{'=' * 70}")
        print(f"{'Type':<20} {'Count':>6}")
        print(f"{'-' * 20} {'-' * 6}")
        for group, items in sorted_groups:
            print(f"{group:<20} {len(items):>6}")
        print(f"{'-' * 20} {'-' * 6}")
        print(f"{'TOTAL':<20} {len(orphans):>6}")


if __name__ == "__main__":
    main()
