#!/usr/bin/env python3
"""mcp-server.py — MCP server exposing ASR repository tools.

Exposes repository operations as native Claude Code tools with
structured input/output. This replaces Bash-script invocations
with typed, composable tool calls.

Usage (via Claude Code .claude/settings.json):
    "mcpServers": {
        "asr": {
            "command": "python3",
            "args": ["scripts/mcp-server.py"],
            "cwd": "."
        }
    }
"""

import json
import os
import re
import subprocess
import sys
from pathlib import Path

from mcp.server.fastmcp import FastMCP

# Find content directory
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent

for candidate in [REPO_ROOT / "content", REPO_ROOT.parent / "content"]:
    if candidate.is_dir() and (candidate / "technology").is_dir():
        CONTENT_DIR = candidate
        break
else:
    CONTENT_DIR = REPO_ROOT / "content"  # fallback

TRIAGE_DIR = CONTENT_DIR / "triage"
EXCLUDE_DIRS = {"triage", "slop", "private", ".obsidian", ".trash"}

# Initialize MCP server
mcp = FastMCP("asr", dependencies=["mcp"])


def parse_frontmatter(content: str) -> dict:
    """Extract YAML frontmatter as a dict."""
    if not content.startswith("---"):
        return {}
    end = content.find("---", 3)
    if end < 0:
        return {}

    fm_text = content[3:end].strip()
    result = {}
    current_key = None
    current_list = None

    for line in fm_text.split("\n"):
        if not line.strip():
            continue
        if line.startswith("  - ") or line.startswith("    - "):
            if current_key and current_list is not None:
                val = line.strip().lstrip("- ").strip().strip('"').strip("'")
                current_list.append(val)
            continue
        if ":" in line and not line.startswith(" "):
            if current_key and current_list is not None:
                result[current_key] = current_list
            key, _, val = line.partition(":")
            key = key.strip()
            val = val.strip().strip('"').strip("'")
            if val:
                result[key] = val
                current_key = key
                current_list = None
            else:
                current_key = key
                current_list = []

    if current_key and current_list is not None:
        result[current_key] = current_list

    return result


# ── Tool 1: find_in_repo ──────────────────────────────────────────

@mcp.tool()
def find_in_repo(
    query: str,
    discipline: str = "",
    content_type: str = "",
    limit: int = 20,
) -> str:
    """Search published repo for existing content by title, alias,
    filename, and body text. Use before creating new content to
    check if it already exists."""

    results = []
    query_lower = query.lower()
    query_words = query_lower.split()

    for root, dirs, files in os.walk(CONTENT_DIR):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]

        if discipline:
            rel_root = str(Path(root).relative_to(CONTENT_DIR))
            parts = rel_root.split("/")
            if parts[0] != "." and parts[0] != discipline:
                continue

        for f in files:
            if not f.endswith(".md"):
                continue

            filepath = Path(root) / f
            try:
                content = filepath.read_text(errors="replace")[:6000]
            except Exception:
                continue

            fm = parse_frontmatter(content)
            rel_path = str(filepath.relative_to(CONTENT_DIR))

            if content_type and fm.get("type") != content_type:
                continue

            title = fm.get("title", "").lower()
            aliases = fm.get("aliases", [])
            if isinstance(aliases, str):
                aliases = [aliases]
            aliases_lower = [a.lower() for a in aliases]
            filename_lower = Path(f).stem.lower().replace("-", " ")

            if query_lower in title:
                results.append({"path": rel_path, "title": fm.get("title", f),
                                "match": "title"})
            elif any(query_lower in a for a in aliases_lower):
                results.append({"path": rel_path, "title": fm.get("title", f),
                                "match": "alias"})
            elif query_lower in filename_lower:
                results.append({"path": rel_path, "title": fm.get("title", f),
                                "match": "filename"})
            elif all(w in f"{title} {filename_lower} {' '.join(aliases_lower)}"
                     for w in query_words):
                results.append({"path": rel_path, "title": fm.get("title", f),
                                "match": "words"})

            if len(results) >= limit:
                break
        if len(results) >= limit:
            break

    priority = {"title": 0, "alias": 1, "filename": 2, "words": 3}
    results.sort(key=lambda r: priority.get(r["match"], 4))
    return json.dumps({"count": len(results), "matches": results[:limit]})


# ── Tool 2: query_triage_index ────────────────────────────────────

@mcp.tool()
def query_triage_index(
    enrichment: str = "",
    discipline: str = "",
    content_type: str = "",
    status: str = "",
    limit: int = 50,
) -> str:
    """Query the triage index for files matching filters. Filters:
    enrichment (none/minimal/partial/complete), discipline (guess),
    content_type, status (triage-status)."""

    index_path = TRIAGE_DIR / ".triage-index.json"
    if not index_path.exists():
        return json.dumps({"error": "No triage index. Run index_triage first."})

    with open(index_path) as f:
        index = json.load(f)

    entries = index["entries"]

    if enrichment:
        entries = [e for e in entries if e.get("enrichment") == enrichment]
    if discipline:
        entries = [e for e in entries
                   if e.get("target-discipline") == discipline
                   or e.get("discipline_guess") == discipline]
    if content_type:
        entries = [e for e in entries
                   if e.get("type") == content_type
                   or e.get("type_guess") == content_type]
    if status:
        entries = [e for e in entries if e.get("triage-status") == status]

    return json.dumps({
        "count": len(entries),
        "stats": index["stats"],
        "entries": entries[:limit],
    })


# ── Tool 3: rebuild_triage_index ──────────────────────────────────

@mcp.tool()
def rebuild_triage_index() -> str:
    """Rebuild the triage index from scratch. Run after enrichment
    or classification changes."""

    result = subprocess.run(
        [sys.executable, str(SCRIPT_DIR / "index-triage.py")],
        capture_output=True, text=True, timeout=120,
    )
    if result.returncode != 0:
        return json.dumps({"error": result.stderr})

    # Return the stats
    index_path = TRIAGE_DIR / ".triage-index.json"
    with open(index_path) as f:
        stats = json.load(f)["stats"]
    return json.dumps({"success": True, "stats": stats})


# ── Tool 4: enrich_triage ────────────────────────────────────────

@mcp.tool()
def enrich_triage(
    path_filter: str = "",
    batch: int = 50,
    dry_run: bool = False,
) -> str:
    """Mechanically enrich triage frontmatter (title, date-created,
    deprecated field fixes). No inference needed."""

    cmd = [sys.executable, str(SCRIPT_DIR / "enrich-triage.py")]
    if dry_run:
        cmd.append("--dry-run")
    if batch:
        cmd.extend(["--batch", str(batch)])
    if path_filter:
        cmd.append(path_filter)

    result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    return json.dumps({
        "success": result.returncode == 0,
        "output": result.stdout[-2000:] if result.stdout else "",
        "errors": result.stderr[-500:] if result.stderr else "",
    })


# ── Tool 5: list_plans ───────────────────────────────────────────

@mcp.tool()
def list_plans(
    status: str = "",
    priority: str = "",
) -> str:
    """List all ASR plans with their status and priority."""

    plans_dir = (CONTENT_DIR / "technology" / "specifications"
                 / "agential-semioverse-repository" / "plans")
    if not plans_dir.exists():
        return json.dumps({"error": "Plans directory not found"})

    plans = []
    for f in sorted(plans_dir.glob("[0-9]*.md")):
        content = f.read_text(errors="replace")[:2000]
        fm = parse_frontmatter(content)

        plan = {
            "number": f.stem.split("-")[0],
            "filename": f.name,
            "title": fm.get("title", f.stem),
            "status": fm.get("status", "unknown"),
            "priority": fm.get("priority", "unknown"),
        }

        if status and plan["status"] != status:
            continue
        if priority and plan["priority"] != priority:
            continue

        plans.append(plan)

    return json.dumps({"count": len(plans), "plans": plans})


# ── Tool 6: list_skills ──────────────────────────────────────────

@mcp.tool()
def list_skills(
    kind: str = "",
    search: str = "",
) -> str:
    """List all skills with their triggers, runtime, and path.
    Optionally filter by kind or search in descriptions."""

    skills = []
    for skill_file in CONTENT_DIR.rglob("**/skills/*/SKILL.md"):
        content = skill_file.read_text(errors="replace")[:2000]
        fm = parse_frontmatter(content)

        skill = {
            "id": fm.get("id", skill_file.parent.name),
            "description": fm.get("description", ""),
            "kind": fm.get("kind", "unknown"),
            "runtime": fm.get("runtime", "unknown"),
            "triggers": fm.get("triggers", []),
            "path": str(skill_file.relative_to(CONTENT_DIR)),
        }

        if kind and skill["kind"] != kind:
            continue
        if search and search.lower() not in skill["description"].lower():
            continue

        skills.append(skill)

    skills.sort(key=lambda s: s["id"])
    return json.dumps({"count": len(skills), "skills": skills})


# ── Tool 7: validate_frontmatter ─────────────────────────────────

@mcp.tool()
def validate_frontmatter(path: str) -> str:
    """Validate a file's frontmatter against semiotic markdown spec.
    Returns structured errors and warnings."""

    filepath = CONTENT_DIR / path
    if not filepath.exists():
        return json.dumps({"error": f"File not found: {path}"})

    content = filepath.read_text(errors="replace")
    fm = parse_frontmatter(content)

    errors = []
    warnings = []

    # Required fields
    if "title" not in fm:
        errors.append("Missing required field: title")
    if "date-created" not in fm:
        errors.append("Missing required field: date-created")

    # Recommended fields
    if "aliases" not in fm:
        warnings.append("Missing recommended field: aliases")
    if "description" not in fm:
        warnings.append("Missing recommended field: description")

    # Type field
    if "type" not in fm:
        warnings.append("Missing field: type")

    # Deprecated fields
    deprecated = {
        "date": "date-created", "created": "date-created",
        "updated": "date-updated", "author": "authors",
        "id": "remove (identity from path)", "kind": "type",
    }
    for old, new in deprecated.items():
        if old in fm:
            errors.append(f"Deprecated field '{old}' → use '{new}'")

    # Date format
    date = fm.get("date-created", "")
    if date and not re.match(r"\d{4}-\d{2}-\d{2}", str(date)):
        errors.append(f"date-created format should be ISO 8601: {date}")

    # Tags format
    tags = fm.get("tags", [])
    if isinstance(tags, list):
        for tag in tags:
            if not re.match(r"^[A-Z][a-zA-Z0-9]+$", str(tag)):
                warnings.append(f"Tag '{tag}' should be CamelCase")

    return json.dumps({
        "path": path,
        "valid": len(errors) == 0,
        "errors": errors,
        "warnings": warnings,
        "fields_present": list(fm.keys()),
    })


# ── Run ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    mcp.run()
