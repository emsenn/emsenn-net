#!/usr/bin/env python3
"""Add type/ tags to documents based on their directory location.

Mapping:
  */terms/         -> type/term
  */people/        -> type/person
  */concepts/      -> type/concept
  */schools/       -> type/school
  */topics/        -> type/topic
  */curricula/     -> type/lesson
  */text/          -> type/text
  personal/writing/babbles/          -> type/babble
  personal/writing/letters-to-the-web/  -> type/letter
  index.md (any)   -> type/index

Does NOT touch files that already have the correct type tag.
Does NOT touch files in private/, meta/, .obsidian/.
Preserves all existing frontmatter; only adds to the tags array.
"""

import os
import re
import sys
import io

# Fix Windows console encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

CONTENT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "content")

# Directories to skip entirely
SKIP_DIRS = {"private", "meta", ".obsidian"}


def determine_type_tag(filepath, filename):
    """Determine the appropriate type/ tag for a file based on its path.

    Returns a type tag string, or None if no type applies.
    A file can match multiple rules; we return a list of all applicable type tags.
    """
    tags = []

    # Normalize path separators
    norm_path = filepath.replace(os.sep, "/")
    rel_path = os.path.relpath(filepath, CONTENT_DIR).replace(os.sep, "/")

    # index.md gets type/index
    if filename == "index.md":
        tags.append("type/index")

    # Directory-based type tags (check the directory the file is IN)
    dir_path = os.path.dirname(norm_path)
    dir_parts = dir_path.replace(os.sep, "/").split("/")

    # Check for specific personal/writing paths first (more specific)
    if "personal/writing/babbles" in rel_path:
        tags.append("type/babble")
    elif "personal/writing/letters-to-the-web" in rel_path:
        tags.append("type/letter")

    # Check directory-based types
    # We check if any ancestor directory matches
    dir_type_map = {
        "terms": "type/term",
        "people": "type/person",
        "concepts": "type/concept",
        "schools": "type/school",
        "topics": "type/topic",
        "curricula": "type/lesson",
        "text": "type/text",
    }

    for part in dir_parts:
        if part in dir_type_map:
            type_tag = dir_type_map[part]
            if type_tag not in tags:
                tags.append(type_tag)

    return tags


def parse_frontmatter(content):
    """Parse frontmatter from markdown content.

    Returns (before_body, fm_lines, body, has_frontmatter).
    """
    if not content.startswith("---"):
        return None, None, content, False
    end_idx = content.find("\n---", 3)
    if end_idx < 0:
        return None, None, content, False
    fm_str = content[4:end_idx]  # skip "---\n"
    body = content[end_idx + 4:]  # skip "\n---"
    fm_lines = fm_str.split("\n")
    return "---\n", fm_lines, body, True


def get_existing_tags(fm_lines):
    """Extract existing tags from frontmatter lines.

    Returns (tags_start_idx, tags_end_idx, tags_list, indent, is_inline).
    If no tags section exists, returns (None, None, [], "  ", False).
    """
    tags_start = None
    tags = []
    indent = "  "
    is_inline = False

    for i, line in enumerate(fm_lines):
        stripped = line.strip()
        if stripped.startswith("tags:"):
            tags_start = i
            rest = stripped[5:].strip()
            if rest.startswith("["):
                # Inline array format: tags: [a, b, c]
                is_inline = True
                inner = rest.strip("[]")
                if inner:
                    tags = [t.strip().strip('"').strip("'") for t in inner.split(",")]
                return tags_start, i + 1, tags, indent, is_inline
            continue

        if tags_start is not None and i > tags_start:
            if stripped.startswith("- "):
                leading = len(line) - len(line.lstrip())
                indent = line[:leading]
                tag_val = stripped[2:].strip().strip('"').strip("'")
                tags.append(tag_val)
            elif stripped == "" or stripped.startswith("#"):
                continue
            else:
                return tags_start, i, tags, indent, is_inline

    if tags_start is not None:
        return tags_start, len(fm_lines), tags, indent, is_inline

    return None, None, [], indent, False


def build_tags_lines(tags, indent="  "):
    """Build YAML lines for a tags section."""
    if not tags:
        return ["tags: []"]
    lines = ["tags:"]
    for tag in tags:
        if any(c in tag for c in ":#{}[]&*?|>!%@`"):
            lines.append(f'{indent}- "{tag}"')
        else:
            lines.append(f"{indent}- {tag}")
    return lines


def process_file(filepath, filename):
    """Process a single file. Returns list of type tags added, or empty list."""
    needed_type_tags = determine_type_tag(filepath, filename)
    if not needed_type_tags:
        return []

    with open(filepath, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()

    prefix, fm_lines, body, has_fm = parse_frontmatter(content)

    if not has_fm:
        # No frontmatter — skip (we don't add frontmatter to files that lack it)
        return []

    tags_start, tags_end, existing_tags, indent, is_inline = get_existing_tags(fm_lines)

    # Determine which type tags are actually needed
    tags_to_add = []
    for tt in needed_type_tags:
        if tt not in existing_tags:
            tags_to_add.append(tt)

    if not tags_to_add:
        return []

    # Add the type tags
    new_tags = existing_tags + tags_to_add

    if tags_start is not None:
        # Replace existing tags section
        new_tag_lines = build_tags_lines(new_tags, indent)
        new_fm_lines = fm_lines[:tags_start] + new_tag_lines + fm_lines[tags_end:]
    else:
        # No tags section exists — add one after the last frontmatter line
        new_tag_lines = build_tags_lines(new_tags, "  ")
        new_fm_lines = fm_lines + new_tag_lines

    new_fm_str = "\n".join(new_fm_lines)
    new_content = "---\n" + new_fm_str + "\n---" + body

    with open(filepath, "w", encoding="utf-8", newline="\n") as f:
        f.write(new_content)

    return tags_to_add


def main():
    counts = {}  # type_tag -> count of files updated
    total_files = 0

    for root, dirs, files in os.walk(CONTENT_DIR):
        # Skip excluded directories
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]

        for f in files:
            if not f.endswith(".md"):
                continue
            filepath = os.path.join(root, f)
            added = process_file(filepath, f)
            if added:
                total_files += 1
                rel = os.path.relpath(filepath, CONTENT_DIR)
                for tag in added:
                    counts[tag] = counts.get(tag, 0) + 1

    print("Type tags added:")
    print(f"{'=' * 50}")
    for tag in sorted(counts.keys()):
        print(f"  {tag}: {counts[tag]} files")
    print(f"{'=' * 50}")
    print(f"Total files updated: {total_files}")
    print(f"Total type tags added: {sum(counts.values())}")


if __name__ == "__main__":
    main()
