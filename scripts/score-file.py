#!/usr/bin/env python3
"""score-file.py — Compute file quality scores for repository files.

Measures observable relational density across three dimensions:
  1. Frontmatter completeness (0-7)
  2. Body structure (0-4)
  3. Integration (0-3, requires --with-integration flag and full scan)

See: concepts/file-quality-score.md for the formal definition.

Usage:
    python3 scripts/score-file.py <path>              # Score one file
    python3 scripts/score-file.py <directory>          # Score all .md in dir
    python3 scripts/score-file.py <directory> --weakest # Show weakest file
    python3 scripts/score-file.py <directory> --summary # Distribution summary
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent

for candidate in [REPO_ROOT / "content", REPO_ROOT.parent / "content"]:
    if candidate.is_dir():
        CONTENT_DIR = candidate
        break
else:
    CONTENT_DIR = REPO_ROOT / "content"

VALID_TYPES = {
    "term", "topic", "index", "lesson", "person", "concept",
    "school", "text", "babble", "letter", "skill", "question",
    # Domain-specific
    "theorem", "proof", "axiom", "definition", "conjecture",
    "lemma", "corollary", "proposition",
    "claim", "argument", "objection", "position", "tradition",
    "curriculum", "transmission-mode", "specification",
}

SEMANTIC_RELATION_FIELDS = {
    "defines", "cites", "requires", "teaches",
    "part-of", "extends", "questions", "addresses",
    # Domain-specific
    "proven-by", "proves", "notation",
    "argued-by", "supports", "targets", "contested-by",
    "school", "integrates", "produces", "sustains", "contests",
    "uses-concepts", "emerges-under",
    "uses-mechanic", "classifies", "boundary-with", "models",
    "practiced-through", "scaffolds", "builds-on",
}

SKIP_DIRS = {".trash", ".obsidian", "node_modules", ".git", "private"}


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


def get_body(content: str) -> str:
    """Return body content after frontmatter."""
    if not content.startswith("---"):
        return content
    end = content.find("---", 3)
    if end < 0:
        return content
    return content[end + 3:]


def score_frontmatter(fm: dict) -> dict:
    """Score frontmatter completeness (0-7)."""
    details = {}

    # title
    details["title"] = 1 if fm.get("title") else 0

    # date-created
    details["date-created"] = 1 if fm.get("date-created") else 0

    # type (valid value)
    type_val = fm.get("type", "")
    details["type"] = 1 if type_val in VALID_TYPES else 0

    # tags (3-5, CamelCase)
    tags = fm.get("tags", [])
    if isinstance(tags, str):
        tags = [tags]
    tags_ok = (
        isinstance(tags, list)
        and 3 <= len(tags) <= 10
        and all(re.match(r"^[A-Z][a-zA-Z0-9]+$", str(t)) for t in tags)
    )
    details["tags"] = 1 if tags_ok else 0

    # description
    details["description"] = 1 if fm.get("description") else 0

    # authors
    details["authors"] = 1 if fm.get("authors") else 0

    # semantic relation field
    has_relation = any(fm.get(field) for field in SEMANTIC_RELATION_FIELDS)
    details["semantic-relation"] = 1 if has_relation else 0

    return details


def score_body(body: str) -> dict:
    """Score body structure (0-4)."""
    details = {}
    stripped = body.strip()

    # non-empty body
    details["non-empty"] = 1 if len(stripped) > 10 else 0

    # at least one heading
    details["has-heading"] = 1 if re.search(r"^#{1,6}\s+.+$", stripped, re.MULTILINE) else 0

    # at least one markdown link
    details["has-link"] = 1 if re.search(r"\[.+?\]\(.+?\)", stripped) else 0

    # no wikilinks (all resolved)
    has_wikilinks = bool(re.search(r"\[\[.+?\]\]", stripped))
    details["no-wikilinks"] = 0 if has_wikilinks else 1

    return details


def score_file(filepath: Path) -> dict:
    """Compute the full quality score for a file."""
    try:
        content = filepath.read_text(encoding="utf-8", errors="replace")
    except Exception as e:
        return {"error": str(e), "total": 0}

    fm = parse_frontmatter(content)
    body = get_body(content)

    fm_scores = score_frontmatter(fm)
    body_scores = score_body(body)

    fm_total = sum(fm_scores.values())
    body_total = sum(body_scores.values())
    total = fm_total + body_total  # integration not included without full scan

    # Determine label
    if total <= 3:
        label = "weak"
    elif total <= 7:
        label = "developing"
    elif total <= 11:
        label = "established"
    else:
        label = "strong"

    try:
        rel_path = str(filepath.relative_to(CONTENT_DIR))
    except ValueError:
        rel_path = str(filepath)

    return {
        "path": rel_path,
        "total": total,
        "max": 11,  # without integration
        "label": label,
        "frontmatter": {"score": fm_total, "max": 7, "details": fm_scores},
        "body": {"score": body_total, "max": 4, "details": body_scores},
    }


def score_directory(dirpath: Path, weakest: bool = False, summary: bool = False) -> dict:
    """Score all .md files in a directory."""
    results = []

    for root, dirs, files in os.walk(dirpath):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for f in sorted(files):
            if not f.endswith(".md"):
                continue
            filepath = Path(root) / f
            result = score_file(filepath)
            if "error" not in result:
                results.append(result)

    results.sort(key=lambda r: r["total"])

    if weakest and results:
        return {"weakest": results[0], "total_files": len(results)}

    if summary:
        dist = {"weak": 0, "developing": 0, "established": 0, "strong": 0}
        for r in results:
            dist[r["label"]] += 1
        avg = sum(r["total"] for r in results) / len(results) if results else 0
        return {
            "total_files": len(results),
            "average_score": round(avg, 1),
            "distribution": dist,
            "weakest": results[0] if results else None,
            "strongest": results[-1] if results else None,
        }

    return {"total_files": len(results), "files": results}


def main():
    parser = argparse.ArgumentParser(description="Compute file quality scores")
    parser.add_argument("path", help="File or directory to score")
    parser.add_argument("--weakest", action="store_true",
                        help="Show only the weakest file")
    parser.add_argument("--summary", action="store_true",
                        help="Show distribution summary")
    parser.add_argument("--json", action="store_true",
                        help="Output raw JSON")
    args = parser.parse_args()

    target = Path(args.path)
    if not target.is_absolute():
        target = CONTENT_DIR / args.path

    if not target.exists():
        print(f"ERROR: Not found: {target}")
        sys.exit(1)

    if target.is_file():
        result = score_file(target)
    else:
        result = score_directory(target, weakest=args.weakest,
                                 summary=args.summary)

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        # Human-readable output
        if "weakest" in result and "total_files" in result:
            if args.weakest:
                w = result["weakest"]
                print(f"Weakest of {result['total_files']} files:")
                print(f"  {w['path']}  score={w['total']}/{w['max']} ({w['label']})")
                print(f"  frontmatter: {w['frontmatter']['score']}/7  body: {w['body']['score']}/4")
                fm_gaps = [k for k, v in w["frontmatter"]["details"].items() if v == 0]
                body_gaps = [k for k, v in w["body"]["details"].items() if v == 0]
                if fm_gaps:
                    print(f"  fm gaps: {', '.join(fm_gaps)}")
                if body_gaps:
                    print(f"  body gaps: {', '.join(body_gaps)}")
            elif args.summary:
                print(f"Files: {result['total_files']}  avg score: {result['average_score']}/{11}")
                d = result["distribution"]
                print(f"  weak: {d['weak']}  developing: {d['developing']}  "
                      f"established: {d['established']}  strong: {d['strong']}")
                if result.get("weakest"):
                    w = result["weakest"]
                    print(f"  weakest: {w['path']} ({w['total']}/{w['max']})")
                if result.get("strongest"):
                    s = result["strongest"]
                    print(f"  strongest: {s['path']} ({s['total']}/{s['max']})")
        elif "total" in result:
            print(f"{result['path']}  score={result['total']}/{result['max']} ({result['label']})")
            print(f"  frontmatter: {result['frontmatter']['score']}/7  body: {result['body']['score']}/4")
            fm_gaps = [k for k, v in result["frontmatter"]["details"].items() if v == 0]
            body_gaps = [k for k, v in result["body"]["details"].items() if v == 0]
            if fm_gaps:
                print(f"  fm gaps: {', '.join(fm_gaps)}")
            if body_gaps:
                print(f"  body gaps: {', '.join(body_gaps)}")
        else:
            # Full listing
            for r in result.get("files", []):
                print(f"  {r['total']:2d}/{r['max']}  {r['label']:12s}  {r['path']}")


if __name__ == "__main__":
    main()
