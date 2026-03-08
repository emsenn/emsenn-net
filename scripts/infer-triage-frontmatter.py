#!/usr/bin/env python3
"""infer-triage-frontmatter.py — Enrich triage frontmatter via local LLM.

Picks triage files (oldest-modified first), passes content to a local
model via Ollama with the frontmatter spec as context, and replaces the
frontmatter. Verifies that the body content is byte-identical before
writing.

Complements enrich-triage.py (mechanical fixes) with inference-based
enrichment: guessing type, tags, description, discipline, and defines.

Usage:
    python3 scripts/infer-triage-frontmatter.py [--dry-run] [--batch N]

Examples:
    python3 scripts/infer-triage-frontmatter.py --dry-run     # Preview
    python3 scripts/infer-triage-frontmatter.py --batch 5      # Enrich 5
    python3 scripts/infer-triage-frontmatter.py --file path    # One file
"""

import argparse
import json
import os
import re
import sys
import urllib.request
import urllib.error
from datetime import datetime, timezone
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent

for candidate in [REPO_ROOT / "content", REPO_ROOT.parent / "content"]:
    if candidate.is_dir() and (candidate / "triage").is_dir():
        CONTENT_DIR = candidate
        break
else:
    print("ERROR: Could not find content/triage/")
    sys.exit(1)

TRIAGE_DIR = CONTENT_DIR / "triage"
OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
DEFAULT_MODEL = os.environ.get("OLLAMA_MODEL", "qwen2.5:7b")

SCRIPT_VERSION = "2"

# Model trust ordering — higher index = more trusted for enrichment.
# When a file was enriched by a model at or above the current model's
# trust level, we skip it. When enriched by a lower-trust model, we
# re-enrich. Models not in this list get trust level 0 (lowest).
MODEL_TRUST_ORDER = [
    "qwen2.5:3b",
    "qwen2.5:7b",
    "qwen2.5:14b",
    "qwen2.5:32b",
    "llama3.1:8b",
    "llama3.1:70b",
    "claude-haiku-4",
    "claude-sonnet-4",
    "claude-opus-4",
]


def get_model_trust_level(model_name: str) -> int:
    """Return the trust level for a model (index in MODEL_TRUST_ORDER).

    Models not in the list get trust level 0. Models in the list get
    their 1-based index (so even the lowest listed model outranks
    unlisted models).
    """
    try:
        return MODEL_TRUST_ORDER.index(model_name) + 1
    except ValueError:
        return 0


def parse_enrichment_provenance(fm_text: str) -> tuple[str, int]:
    """Extract the enriching model name and its trust level from provenance.

    Parses triage-enriched-by field which has format:
      infer-triage-frontmatter-v<N>-by-<model>

    Returns (model_name, trust_level). Returns ("", 0) if no provenance.
    """
    match = re.search(
        r'^triage-enriched-by:\s*["\']?infer-triage-frontmatter-v\d+-by-(.+?)["\']?\s*$',
        fm_text, re.MULTILINE
    )
    if match:
        model_name = match.group(1).strip()
        return model_name, get_model_trust_level(model_name)
    # Legacy: old-style "triage-status: enriched" has no model info → trust 0
    if re.search(r'^triage-status:\s*enriched', fm_text, re.MULTILINE):
        return "unknown", 0
    return "", -1  # -1 means never enriched


# Valid type values from the semantic-frontmatter spec
VALID_TYPES = [
    "term", "topic", "index", "lesson", "person", "concept",
    "school", "text", "babble", "letter", "skill", "question",
]

# The prompt template sent to the local model
ENRICHMENT_PROMPT = """You are a frontmatter enrichment tool. Given a markdown file, produce improved YAML frontmatter for it.

Rules:
- Output ONLY the frontmatter block: start with --- and end with ---
- Do NOT output any body text or explanation
- Keep any existing correct frontmatter values (title, date-created, etc.)
- Add or improve these fields if you can determine them from the content:
  - title: a clear, concise title (required)
  - type: one of: {valid_types}
  - tags: 3-5 CamelCase tags, most-specific first, cross-cutting (not duplicating directory info)
  - description: one sentence summarizing what this file is about
  - defines: list of terms/concepts this file defines (if applicable)
  - target-discipline: which discipline this content belongs to (e.g. technology, philosophy, mathematics, sociology, medicine, games, writing, education)
- Tags MUST be CamelCase with no spaces or hyphens: Anarchism, PoliticalTheory, SettlerColonialism
- If the file has very little content, set type to "babble" and add minimal tags
- If you cannot determine a field, omit it rather than guess poorly
- Do NOT invent a date-created value. If no date-created exists, omit it entirely
- Preserve existing date-created, date-updated, authors, aliases fields exactly
- Do NOT add triage-status, triage-enriched-by, or date-triage-enriched fields — those are added by the script, not by you

Example output format:
---
title: "Example Title"
date-created: 2025-01-01T00:00:00
type: text
tags:
  - SpecificTag
  - BroaderTag
  - BroadestTag
description: "One sentence about what this file covers."
target-discipline: technology
---"""


def parse_frontmatter_and_body(content: str) -> tuple[str | None, str]:
    """Split content into (frontmatter_text, body).

    Returns (None, content) if no frontmatter block exists.
    """
    if not content.startswith("---"):
        return None, content

    end = content.find("---", 3)
    if end < 0:
        return None, content

    # Include the newline after closing ---
    fm_text = content[3:end].strip()
    body = content[end + 3:]
    return fm_text, body


def call_ollama(prompt: str, model: str = "", temperature: float = 0.3) -> str:
    """Call Ollama and return the response text."""
    model = model or DEFAULT_MODEL

    payload = json.dumps({
        "model": model,
        "prompt": prompt,
        "stream": False,
        "options": {"temperature": temperature},
    }).encode()

    req = urllib.request.Request(
        f"{OLLAMA_URL}/api/generate",
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    with urllib.request.urlopen(req, timeout=120) as resp:
        body = json.loads(resp.read())
        return body.get("response", "")


def extract_frontmatter_from_response(response: str) -> str | None:
    """Extract the YAML frontmatter block from the model's response.

    The model should return a block starting with --- and ending with ---.
    """
    # Find the frontmatter block in the response
    match = re.search(r"^---\s*\n(.*?)\n---", response, re.DOTALL | re.MULTILINE)
    if match:
        return match.group(1).strip()

    # Try without leading ---
    lines = response.strip().split("\n")
    # Filter out lines that are clearly not YAML
    yaml_lines = []
    for line in lines:
        stripped = line.strip()
        if stripped == "---":
            continue
        if stripped.startswith("```"):
            continue
        if not stripped:
            continue
        # Looks like YAML if it has key: value or is a list item
        if ":" in stripped or stripped.startswith("- "):
            yaml_lines.append(line)

    if yaml_lines:
        return "\n".join(yaml_lines)

    return None


def validate_frontmatter(fm_text: str) -> list[str]:
    """Check the generated frontmatter for obvious problems."""
    warnings = []

    if "title" not in fm_text:
        warnings.append("missing title field")

    # Check for invalid type values
    type_match = re.search(r"^type:\s*(.+)$", fm_text, re.MULTILINE)
    if type_match:
        type_val = type_match.group(1).strip().strip('"').strip("'")
        if type_val not in VALID_TYPES:
            warnings.append(f"invalid type: {type_val}")

    # Check tags are CamelCase
    tag_section = False
    for line in fm_text.split("\n"):
        if line.strip().startswith("tags:"):
            tag_section = True
            continue
        if tag_section and line.strip().startswith("- "):
            tag = line.strip().lstrip("- ").strip().strip('"').strip("'")
            if not re.match(r"^[A-Z][a-zA-Z0-9]+$", tag):
                warnings.append(f"tag not CamelCase: {tag}")
        elif tag_section and not line.startswith(" "):
            tag_section = False

    return warnings


def stamp_provenance(fm_text: str, model: str) -> str:
    """Add provenance fields and strip any model-generated triage-status.

    Injects triage-enriched-by and date-triage-enriched into the
    frontmatter. Strips triage-status if the model included it despite
    being told not to.
    """
    # Strip any triage-status, triage-enriched-by, or date-triage-enriched
    # the model may have generated (we control these, not the model)
    lines = fm_text.split("\n")
    cleaned = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("triage-status:"):
            continue
        if stripped.startswith("triage-enriched-by:"):
            continue
        if stripped.startswith("date-triage-enriched:"):
            continue
        cleaned.append(line)

    # Append provenance fields
    provenance_tag = f"infer-triage-frontmatter-v{SCRIPT_VERSION}-by-{model}"
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S")
    cleaned.append(f'triage-enriched-by: "{provenance_tag}"')
    cleaned.append(f"date-triage-enriched: {now}")

    return "\n".join(cleaned)


def get_triage_files_oldest_first() -> list[Path]:
    """Get all triage .md files, sorted by modification time (oldest first)."""
    skip_dirs = {".trash", ".obsidian", "node_modules", ".git"}
    files = []

    for root, dirs, filenames in os.walk(TRIAGE_DIR):
        dirs[:] = [d for d in dirs if d not in skip_dirs]
        for f in filenames:
            if not f.endswith(".md"):
                continue
            filepath = Path(root) / f
            files.append(filepath)

    # Sort by modification time, oldest first
    files.sort(key=lambda p: p.stat().st_mtime)
    return files


def enrich_file(filepath: Path, dry_run: bool = False, model: str = "") -> dict:
    """Enrich one triage file's frontmatter via local LLM.

    Returns a result dict with status and details.
    """
    try:
        content = filepath.read_text(encoding="utf-8", errors="replace")
    except Exception as e:
        return {"status": "error", "message": f"read failed: {e}"}

    if not content.strip():
        return {"status": "skipped", "message": "empty file"}

    original_fm, body = parse_frontmatter_and_body(content)

    # Model-aware skip logic: check enrichment provenance
    current_model = model or DEFAULT_MODEL
    current_trust = get_model_trust_level(current_model)
    if original_fm:
        prev_model, prev_trust = parse_enrichment_provenance(original_fm)
        if prev_trust >= 0 and prev_trust >= current_trust:
            return {
                "status": "skipped",
                "message": f"already enriched by {prev_model} (trust {prev_trust} >= {current_trust})",
            }

    # Build the prompt
    prompt = ENRICHMENT_PROMPT.format(valid_types=", ".join(VALID_TYPES))

    # Truncate very long files — the model only needs enough to classify
    file_content = content[:4000]
    full_prompt = f"{prompt}\n\nFile path: {filepath.relative_to(TRIAGE_DIR)}\n\nFile content:\n{file_content}"

    try:
        response = call_ollama(full_prompt, model=model)
    except urllib.error.URLError as e:
        return {"status": "error", "message": f"Ollama connection failed: {e}"}
    except Exception as e:
        return {"status": "error", "message": f"Ollama error: {e}"}

    new_fm_text = extract_frontmatter_from_response(response)
    if not new_fm_text:
        return {"status": "error", "message": "could not parse frontmatter from response",
                "response": response[:500]}

    # Validate the generated frontmatter
    warnings = validate_frontmatter(new_fm_text)

    # Stamp provenance (strip any model-generated triage-status, add our fields)
    new_fm_text = stamp_provenance(new_fm_text, current_model)

    # Reconstruct the file: new frontmatter + original body
    # The body must be EXACTLY the same as the original
    if original_fm is not None:
        # Had frontmatter before — body starts after closing ---
        new_content = f"---\n{new_fm_text}\n---\n{body}"
    else:
        # No frontmatter before — body is the entire original content
        new_content = f"---\n{new_fm_text}\n---\n\n{content}"

    # CRITICAL: verify body is unchanged
    _, new_body = parse_frontmatter_and_body(new_content)
    if original_fm is not None:
        expected_body = body
    else:
        expected_body = "\n\n" + content

    if new_body != expected_body:
        return {"status": "error", "message": "body content changed — refusing to write",
                "expected_len": len(expected_body), "got_len": len(new_body)}

    if dry_run:
        return {
            "status": "would_enrich",
            "new_frontmatter": new_fm_text,
            "warnings": warnings,
        }

    filepath.write_text(new_content, encoding="utf-8")
    return {
        "status": "enriched",
        "new_frontmatter": new_fm_text,
        "warnings": warnings,
    }


def main():
    parser = argparse.ArgumentParser(
        description="Enrich triage frontmatter via local LLM")
    parser.add_argument("--dry-run", action="store_true",
                        help="Preview changes without writing")
    parser.add_argument("--batch", type=int, default=1,
                        help="Number of files to process (default: 1)")
    parser.add_argument("--file", type=str, default="",
                        help="Process a specific file (relative to triage/)")
    parser.add_argument("--model", type=str, default="",
                        help="Ollama model to use")
    args = parser.parse_args()

    if args.file:
        target = TRIAGE_DIR / args.file
        if not target.exists():
            print(f"ERROR: File not found: {target}")
            sys.exit(1)
        files = [target]
    else:
        files = get_triage_files_oldest_first()

    if args.dry_run:
        print("DRY RUN — no files will be modified\n")

    enriched = 0
    skipped = 0
    errors = 0

    for filepath in files:
        if enriched >= args.batch:
            break

        rel = str(filepath.relative_to(TRIAGE_DIR))
        result = enrich_file(filepath, dry_run=args.dry_run, model=args.model)

        if result["status"] == "skipped":
            skipped += 1
            continue

        if result["status"] == "error":
            errors += 1
            print(f"  ERROR {rel}: {result['message']}")
            if "response" in result:
                print(f"    Response preview: {result['response'][:200]}")
            continue

        enriched += 1
        prefix = "[DRY] " if args.dry_run else ""
        print(f"  {prefix}{rel}:")
        # Show the new frontmatter compactly
        fm_lines = result["new_frontmatter"].split("\n")
        for line in fm_lines:
            print(f"    {line}")
        if result.get("warnings"):
            for w in result["warnings"]:
                print(f"    WARNING: {w}")

    print(f"\nProcessed: {enriched} enriched, {skipped} skipped, {errors} errors")


if __name__ == "__main__":
    main()
