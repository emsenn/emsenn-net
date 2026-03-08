#!/usr/bin/env python3
"""infer-triage-frontmatter.py — Enrich triage frontmatter via local LLM.

Picks triage files (oldest-modified first), passes content to a local
model via Ollama with the frontmatter spec as context, and replaces the
frontmatter. Verifies that the body content is byte-identical before
writing.

Complements enrich-triage.py (mechanical fixes) with inference-based
enrichment: guessing type, tags, description, discipline, and defines.

Usage:
    python3 scripts/infer-triage-frontmatter.py [--dry-run] [--batch N] [--model MODEL]

Examples:
    python3 scripts/infer-triage-frontmatter.py --dry-run              # Preview with default model
    python3 scripts/infer-triage-frontmatter.py --batch 5              # Enrich 5 files
    python3 scripts/infer-triage-frontmatter.py --file path            # One specific file
    python3 scripts/infer-triage-frontmatter.py --model qwen3:4b       # Use a different model
"""

import argparse
import json
import os
import re
import sys
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent

sys.path.insert(0, str(SCRIPT_DIR))
import local_llm  # noqa: E402

for candidate in [REPO_ROOT / "content", REPO_ROOT.parent / "content"]:
    if candidate.is_dir() and (candidate / "triage").is_dir():
        CONTENT_DIR = candidate
        break
else:
    print("ERROR: Could not find content/triage/")
    sys.exit(1)

TRIAGE_DIR = CONTENT_DIR / "triage"
DEFAULT_MODEL = os.environ.get("OLLAMA_MODEL", "qwen2.5:3b")

SCRIPT_VERSION = "3"

# Token threshold for large-file summarization.
# Files above this approximate token count are summarized before enrichment
# using a long-context model, rather than truncated at a fixed char limit.
SUMMARY_THRESHOLD_TOKENS = 2000  # ≈ 8000 chars
SUMMARY_MODEL = "phi-3-mini-128k"  # long-context model for summarization

# Model trust ordering — higher index = more trusted for enrichment.
# When a file was enriched by a model at or above the current model's
# trust level, we skip it. When enriched by a lower-trust model, we
# re-enrich. Models not in this list get trust level 0 (lowest).
MODEL_TRUST_ORDER = [
    # Tiny/fast — acceptable for rapid first-pass
    "qwen2.5-0.5b",     # also matches qwen2.5-0.5b-instruct-vitis-npu:3
    "qwen3:1.7b",
    # Small — good general classification
    "qwen2.5:3b",
    "llama3.2:3b",
    # Mid — balanced quality/speed
    "qwen3:4b",
    "phi4-mini",        # also matches phi-4-mini-instruct-vitis-npu:2
    "gemma3:4b",
    "mistral-7b",       # also matches Mistral-7B-Instruct-v0-2-vitis-npu:1
    # 7B — solid quality
    "qwen2.5:7b",       # also matches qwen2.5-7b-instruct-vitis-npu:2
    "qwen3:8b",
    "deepseek-r1-7b",   # also matches DeepSeek-R1-Distill-Qwen-7B-vitis-npu:1
    # Large — high quality
    "gemma3:12b",
    "qwen2.5:14b",
    "qwen2.5:32b",
    "llama3.1:8b",
    "llama3.1:70b",
    # Cloud — highest trust (human-reviewed output)
    "claude-haiku-4",
    "claude-sonnet-4",
    "claude-opus-4",
]


def _normalize_model_name(model_name: str) -> str:
    """Normalize a model name for trust lookup.

    Strips Foundry-specific suffixes like '-instruct-vitis-npu:2' and
    collapses hyphens so 'phi-4-mini-instruct-vitis-npu:2' → 'phi4mini'.
    """
    # Strip version tag
    base = model_name.split(":")[0]
    # Strip -instruct, -generic, and hardware suffixes
    for suffix in ["-instruct", "-generic", "-vitis", "-npu", "-qnn"]:
        if suffix in base:
            base = base[:base.index(suffix)]
    # Collapse dashes: phi-4-mini → phi4mini
    return base.replace("-", "")


def get_model_trust_level(model_name: str) -> int:
    """Return the trust level for a model (index in MODEL_TRUST_ORDER).

    Models not in the list get trust level 0. Models in the list get
    their 1-based index (so even the lowest listed model outranks
    unlisted models). Foundry model names are normalized before lookup.
    """
    # Try exact match first
    try:
        return MODEL_TRUST_ORDER.index(model_name) + 1
    except ValueError:
        pass
    # Try normalized (handles Foundry names like phi-4-mini-instruct-vitis-npu:2)
    normalized = _normalize_model_name(model_name)
    for i, known in enumerate(MODEL_TRUST_ORDER):
        if _normalize_model_name(known) == normalized:
            return i + 1
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
- Field names MUST NOT contain spaces: write "date-created" not "date- created"
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


def count_tokens(text: str) -> int:
    """Approximate token count (4 chars per token)."""
    return len(text) // 4


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


def call_llm(prompt: str, model: str = "", temperature: float = 0.3) -> tuple[str, str]:
    """Call local LLM (Ollama or Foundry) and return (response_text, actual_model_used)."""
    result = local_llm.complete(
        messages=[{"role": "user", "content": prompt}],
        model=model or DEFAULT_MODEL,
        temperature=temperature,
    )
    if result["error"]:
        raise RuntimeError(result["error"])
    return result["response"], result["model"]


def _clean_yaml_keys(fm_text: str) -> str:
    """Remove lines where the YAML key portion contains whitespace.

    Catches model errors like 'date- created: ...' where the key has a
    space inserted. Only applies to top-level key lines (not list items).
    """
    lines = fm_text.split("\n")
    clean = []
    for line in lines:
        # Top-level key lines look like: word-or-words: ...
        # List items start with "  - " and are fine
        m = re.match(r'^([^:\n#]+):', line)
        if m:
            key = m.group(1)
            if re.search(r'\s', key):
                # Key has whitespace — drop this line
                continue
        clean.append(line)
    return "\n".join(clean)


def extract_frontmatter_from_response(response: str) -> str | None:
    """Extract the YAML frontmatter block from the model's response.

    The model should return a block starting with --- and ending with ---.
    """
    # Find the frontmatter block in the response
    match = re.search(r"^---\s*\n(.*?)\n---", response, re.DOTALL | re.MULTILINE)
    if match:
        return _clean_yaml_keys(match.group(1).strip())

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
        return _clean_yaml_keys("\n".join(yaml_lines))

    return None


def validate_frontmatter(fm_text: str) -> list[str]:
    """Check the generated frontmatter for obvious problems."""
    warnings = []

    if "title" not in fm_text:
        warnings.append("missing title field")

    # Check for whitespace in YAML keys
    for line in fm_text.split("\n"):
        m = re.match(r'^([^:\n#]+):', line)
        if m:
            key = m.group(1)
            if re.search(r'\s', key):
                warnings.append(f"whitespace in key: {repr(key)}")

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
    # Note: model may be a Foundry name like "phi-4-mini-instruct-vitis-npu:2"
    # We use whatever name was actually used for inference
    provenance_tag = f"infer-triage-frontmatter-v{SCRIPT_VERSION}-by-{model}"
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S")
    cleaned.append(f'triage-enriched-by: "{provenance_tag}"')
    cleaned.append(f"date-triage-enriched: {now}")

    return "\n".join(cleaned)


def summarize_for_enrichment(content: str, filepath_hint: str = "") -> str:
    """Summarize a large file using a long-context model.

    Used when a file is too large to send directly to the enrichment model.
    Falls back to truncation if the summary model is unavailable or fails.
    """
    hint = f" (file: {filepath_hint})" if filepath_hint else ""
    try:
        result = local_llm.complete(
            messages=[
                {
                    "role": "user",
                    "content": (
                        f"Summarize the following document in 200-300 words{hint}. "
                        "Preserve key topics, named entities, vocabulary, and structure. "
                        "Output only the summary, no preamble.\n\n"
                        f"{content}"
                    ),
                }
            ],
            model=SUMMARY_MODEL,
            max_tokens=512,
            temperature=0.2,
        )
        if not result["error"] and result["response"]:
            token_count = count_tokens(content)
            return f"[Summary of ~{token_count}-token file]\n{result['response']}"
    except Exception:
        pass
    # Fallback: truncate
    return content[:8000] + "\n...[truncated at 8000 chars]"


def needs_enrichment(filepath: Path, current_trust: int) -> bool:
    """Fast check (no LLM) whether a file needs enrichment.

    Reads only the frontmatter portion (first 2KB) of each file for
    speed when pre-scanning thousands of candidates.
    """
    try:
        with open(filepath, encoding="utf-8", errors="replace") as f:
            head = f.read(2048)
    except Exception:
        return False

    if not head.strip():
        return False

    if not head.startswith("---"):
        return True  # No frontmatter → needs enrichment

    end_idx = head.find("---", 3)
    if end_idx < 0:
        return True  # Malformed or frontmatter extends beyond 2KB → try to enrich

    fm_text = head[3:end_idx].strip()

    # 30-day recency check
    date_match = re.search(r'^date-triage-enriched:\s*(.+)$', fm_text, re.MULTILINE)
    if date_match:
        try:
            enriched_at = datetime.fromisoformat(date_match.group(1).strip())
            if enriched_at.tzinfo is None:
                enriched_at = enriched_at.replace(tzinfo=timezone.utc)
            age = datetime.now(timezone.utc) - enriched_at
            if age < timedelta(days=30):
                return False
        except (ValueError, AttributeError):
            pass

    # Trust check: skip if already enriched by equal or higher trust
    _, prev_trust = parse_enrichment_provenance(fm_text)
    if prev_trust >= 0 and prev_trust >= current_trust:
        return False

    return True


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
        # Skip if recently enriched (within 30 days) — regardless of trust level
        date_match = re.search(r'^date-triage-enriched:\s*(.+)$', original_fm, re.MULTILINE)
        if date_match:
            try:
                enriched_at = datetime.fromisoformat(date_match.group(1).strip())
                if enriched_at.tzinfo is None:
                    enriched_at = enriched_at.replace(tzinfo=timezone.utc)
                age = datetime.now(timezone.utc) - enriched_at
                if age < timedelta(days=30):
                    return {
                        "status": "skipped",
                        "message": f"recently enriched {age.days}d ago by {prev_model}",
                    }
            except (ValueError, AttributeError):
                pass
        # Skip if enriched by a model with equal or higher trust
        if prev_trust >= 0 and prev_trust >= current_trust:
            return {
                "status": "skipped",
                "message": f"already enriched by {prev_model} (trust {prev_trust} >= {current_trust})",
            }

    # Build the prompt
    prompt = ENRICHMENT_PROMPT.format(valid_types=", ".join(VALID_TYPES))

    # Determine file content to send: summarize large files, send small ones whole
    file_tokens = count_tokens(content)
    if file_tokens > SUMMARY_THRESHOLD_TOKENS:
        file_content = summarize_for_enrichment(
            content, str(filepath.relative_to(TRIAGE_DIR))
        )
    else:
        file_content = content

    full_prompt = f"{prompt}\n\nFile path: {filepath.relative_to(TRIAGE_DIR)}\n\nFile content:\n{file_content}"

    try:
        response, actual_model = call_llm(full_prompt, model=model)
    except Exception as e:
        return {"status": "error", "message": f"LLM error: {e}"}

    new_fm_text = extract_frontmatter_from_response(response)
    if not new_fm_text:
        return {"status": "error", "message": "could not parse frontmatter from response",
                "response": response[:500]}

    # Validate the generated frontmatter
    warnings = validate_frontmatter(new_fm_text)

    # Stamp provenance using actual model used (may differ from requested if
    # Foundry resolved to a different name or fell back to Ollama)
    new_fm_text = stamp_provenance(new_fm_text, actual_model)

    # Reconstruct the file: new frontmatter + original body
    # The body must be EXACTLY the same as the original
    # Note: body already includes leading whitespace from after the closing ---
    if original_fm is not None:
        # Had frontmatter before — body starts after closing ---
        new_content = f"---\n{new_fm_text}\n---{body}"
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
            "summarized": file_tokens > SUMMARY_THRESHOLD_TOKENS,
        }

    filepath.write_text(new_content, encoding="utf-8")
    return {
        "status": "enriched",
        "new_frontmatter": new_fm_text,
        "warnings": warnings,
        "summarized": file_tokens > SUMMARY_THRESHOLD_TOKENS,
    }


def format_duration(seconds: float) -> str:
    """Format seconds into a human-readable duration."""
    if seconds < 60:
        return f"{seconds:.1f}s"
    minutes = int(seconds // 60)
    secs = seconds % 60
    return f"{minutes}m {secs:.0f}s"


def format_size(bytes_count: int) -> str:
    """Format byte count into human-readable size."""
    if bytes_count < 1024:
        return f"{bytes_count}B"
    if bytes_count < 1024 * 1024:
        return f"{bytes_count / 1024:.1f}KB"
    return f"{bytes_count / (1024 * 1024):.1f}MB"


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
                        help="Ollama model to use (default: %s)" % DEFAULT_MODEL)
    args = parser.parse_args()

    active_model = args.model or local_llm.suggest_model("classification")
    trust_level = get_model_trust_level(active_model)

    if not local_llm.is_available():
        print("ERROR: No local LLM backend available. Install Ollama or Foundry Local.")
        sys.exit(1)

    if args.file:
        target = TRIAGE_DIR / args.file
        if not target.exists():
            print(f"ERROR: File not found: {target}")
            sys.exit(1)
        files = [target]
        eligible_count = 1
        total_count = 1
    else:
        files = get_triage_files_oldest_first()
        total_count = len(files)
        # Pre-scan to count files that will actually trigger LLM calls.
        # Reads only the first 2KB (frontmatter) of each file — no LLM calls.
        print(f"Pre-scanning {total_count} files...", end="\r", flush=True)
        eligible_count = sum(1 for f in files if needs_enrichment(f, trust_level))

    # Header
    mode = "DRY RUN" if args.dry_run else "ENRICHING"
    candidates_label = (
        f"{eligible_count} of {total_count}"
        if not args.file else "1"
    )
    print(f"{mode} | model: {active_model} (trust {trust_level}) | batch: {args.batch} | candidates: {candidates_label}")
    print()

    enriched = 0
    skipped = 0
    errors = 0
    file_times: list[float] = []
    run_start = time.monotonic()

    for filepath in files:
        if enriched >= args.batch:
            break

        rel = str(filepath.relative_to(TRIAGE_DIR))
        file_size = filepath.stat().st_size

        file_start = time.monotonic()
        result = enrich_file(filepath, dry_run=args.dry_run, model=active_model)
        file_elapsed = time.monotonic() - file_start

        if result["status"] == "skipped":
            skipped += 1
            continue

        if result["status"] == "error":
            errors += 1
            print(f"  ERROR {rel} ({format_size(file_size)}, {format_duration(file_elapsed)})")
            print(f"    {result['message']}")
            if "response" in result:
                print(f"    Response preview: {result['response'][:200]}")
            continue

        enriched += 1
        file_times.append(file_elapsed)
        prefix = "[DRY] " if args.dry_run else ""
        summarized_flag = " [summarized]" if result.get("summarized") else ""
        print(f"  {prefix}{rel} ({format_size(file_size)}, {format_duration(file_elapsed)}{summarized_flag})")

        # Show key fields compactly
        fm_lines = result["new_frontmatter"].split("\n")
        for line in fm_lines:
            print(f"    {line}")
        if result.get("warnings"):
            for w in result["warnings"]:
                print(f"    WARNING: {w}")
        print()

    # Summary
    total_elapsed = time.monotonic() - run_start
    print("---")
    print(f"Done: {enriched} enriched, {skipped} skipped, {errors} errors")
    print(f"Time: {format_duration(total_elapsed)} total", end="")
    if file_times:
        avg = sum(file_times) / len(file_times)
        print(f", {format_duration(avg)} avg/file", end="")
        if len(file_times) > 1:
            fastest = min(file_times)
            slowest = max(file_times)
            print(f" (fastest {format_duration(fastest)}, slowest {format_duration(slowest)})", end="")
    print()


if __name__ == "__main__":
    main()
