#!/usr/bin/env python3
"""Fix broken/erroneous tags in vault frontmatter.

Handles:
1. Tags that are file paths (contain "/" or ".md") — removed
2. Tags that are YAML field names (start with "name:") — removed
3. Tags containing markdown links or LaTeX — removed
4. Near-duplicate normalization: "math" → "mathematics", "Babble" → "babble"
5. Case normalization for tags that should be lowercase

Preserves all other frontmatter and body content exactly.
"""

import os
import re
import sys
import io

# Fix Windows console encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

CONTENT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "content")

# Directories to skip entirely
SKIP_DIRS = {"private", ".obsidian"}

# Tags that are proper nouns or acronyms and should keep their casing
PRESERVE_CASE = {
    "covid-19", "lakota", "peirce", "saussure", "norse paganism",
    "norway", "christianization", "okaga", "teraum", "gnoponemacs",
    "org-mode", "mud", "tab", "ai",
}

# Normalization map: bad tag → good tag (or None to remove)
NORMALIZE = {
    "math": "mathematics",
    "Babble": "babble",
}


def is_bad_tag(tag):
    """Return a reason string if the tag is bad, else None."""
    # File paths
    if ".md" in tag:
        return "contains .md (file path)"
    # Slash in tag (but allow type/ prefix)
    if "/" in tag and not tag.startswith("type/"):
        return f"contains / (looks like path or compound: {tag})"
    # YAML field name leaked into tags
    if tag.startswith("name:"):
        return "starts with name: (YAML field)"
    # Markdown links
    if "[" in tag or "]" in tag:
        return "contains markdown link syntax"
    # LaTeX
    if "$" in tag or "\\" in tag:
        return "contains LaTeX"
    return None


def normalize_tag(tag):
    """Return normalized tag, or None if the tag should be removed."""
    # Check if it's outright bad
    reason = is_bad_tag(tag)
    if reason:
        return None, reason

    # Exact normalization matches
    if tag in NORMALIZE:
        return NORMALIZE[tag], f"normalized: {tag} → {NORMALIZE[tag]}"

    # Case normalization for tags that should be lowercase
    # Most tags should be lowercase; preserve acronyms/proper nouns
    lower = tag.lower()
    if tag != lower and lower not in PRESERVE_CASE:
        # It's a capitalized tag that isn't a known proper noun
        return lower, f"lowercased: {tag} → {lower}"

    return tag, None


def parse_frontmatter(content):
    """Parse frontmatter from markdown content.

    Returns (frontmatter_str, body_str, has_frontmatter).
    frontmatter_str does NOT include the --- delimiters.
    """
    if not content.startswith("---"):
        return None, content, False
    end = content.find("\n---", 3)
    if end < 0:
        return None, content, False
    fm = content[4:end]  # skip "---\n"
    body = content[end + 4:]  # skip "\n---"
    return fm, body, True


def extract_tags_from_frontmatter(fm_lines):
    """Find the tags section in frontmatter lines.

    Returns (tag_start_idx, tag_end_idx, tags_list, indent).
    tag_start_idx is the line with 'tags:', tag_end_idx is one past the last tag line.
    """
    tags_start = None
    tags = []
    indent = "  "

    for i, line in enumerate(fm_lines):
        stripped = line.strip()
        if stripped.startswith("tags:"):
            tags_start = i
            # Check for inline tags: tags: [a, b, c]
            rest = stripped[5:].strip()
            if rest.startswith("["):
                # Inline array format
                inner = rest.strip("[]")
                if inner:
                    tags = [t.strip().strip('"').strip("'") for t in inner.split(",")]
                return tags_start, i + 1, tags, indent
            continue

        if tags_start is not None and i > tags_start:
            if stripped.startswith("- "):
                # Detect indent
                leading = len(line) - len(line.lstrip())
                indent = line[:leading]
                tag_val = stripped[2:].strip().strip('"').strip("'")
                tags.append(tag_val)
            elif stripped == "" or stripped.startswith("#"):
                # Empty line or comment within tags — could be part of the block
                continue
            else:
                # We've left the tags section
                return tags_start, i, tags, indent

    if tags_start is not None:
        return tags_start, len(fm_lines), tags, indent

    return None, None, [], indent


def rebuild_tags_section(tags, indent="  "):
    """Build the YAML lines for a tags section."""
    if not tags:
        return ["tags: []"]
    lines = ["tags:"]
    for tag in tags:
        # Quote tags that contain special YAML characters
        if any(c in tag for c in ":#{}[]&*?|>!%@`"):
            lines.append(f'{indent}- "{tag}"')
        else:
            lines.append(f"{indent}- {tag}")
    return lines


def process_file(filepath):
    """Process a single file. Returns list of changes made, or empty list."""
    with open(filepath, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()

    fm_str, body, has_fm = parse_frontmatter(content)
    if not has_fm:
        return []

    fm_lines = fm_str.split("\n")
    tags_start, tags_end, tags, indent = extract_tags_from_frontmatter(fm_lines)

    if tags_start is None or not tags:
        return []

    changes = []
    new_tags = []
    seen = set()

    for tag in tags:
        normalized, reason = normalize_tag(tag)
        if normalized is None:
            changes.append(f"  REMOVED: \"{tag}\" ({reason})")
            continue
        if reason:
            changes.append(f"  CHANGED: \"{tag}\" → \"{normalized}\" ({reason})")

        # Deduplicate
        if normalized.lower() in seen:
            changes.append(f"  DEDUPED: \"{normalized}\" (duplicate after normalization)")
            continue
        seen.add(normalized.lower())
        new_tags.append(normalized)

    if not changes:
        return []

    # Rebuild the frontmatter
    new_tag_lines = rebuild_tags_section(new_tags, indent)
    new_fm_lines = fm_lines[:tags_start] + new_tag_lines + fm_lines[tags_end:]
    new_fm_str = "\n".join(new_fm_lines)
    new_content = "---\n" + new_fm_str + "\n---" + body

    with open(filepath, "w", encoding="utf-8", newline="\n") as f:
        f.write(new_content)

    return changes


def main():
    total_files = 0
    total_changes = 0
    changes_by_type = {
        "removed": 0,
        "changed": 0,
        "deduped": 0,
    }

    for root, dirs, files in os.walk(CONTENT_DIR):
        # Skip excluded directories
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]

        for f in files:
            if not f.endswith(".md"):
                continue
            filepath = os.path.join(root, f)
            changes = process_file(filepath)
            if changes:
                total_files += 1
                rel = os.path.relpath(filepath, CONTENT_DIR)
                print(f"\n{rel}:")
                for change in changes:
                    print(change)
                    total_changes += 1
                    if "REMOVED" in change:
                        changes_by_type["removed"] += 1
                    elif "CHANGED" in change:
                        changes_by_type["changed"] += 1
                    elif "DEDUPED" in change:
                        changes_by_type["deduped"] += 1

    print(f"\n{'=' * 60}")
    print(f"Summary:")
    print(f"  Files modified: {total_files}")
    print(f"  Total tag changes: {total_changes}")
    print(f"    Removed (bad tags): {changes_by_type['removed']}")
    print(f"    Changed (normalized): {changes_by_type['changed']}")
    print(f"    Deduped: {changes_by_type['deduped']}")


if __name__ == "__main__":
    main()
