#!/usr/bin/env python3
"""Generate RDF/Turtle from markdown frontmatter.

Reads YAML frontmatter from markdown files and produces colocated .ttl
files using the predicate mappings defined in semantic-frontmatter.md.

Usage:
  python generate-rdf.py <path>              # generate TTL for one page
  python generate-rdf.py --all               # generate TTL for all pages
  python generate-rdf.py --all --dry-run     # show what would be generated
  python generate-rdf.py --all --stats       # print statistics only
  python generate-rdf.py --all --combined    # also write combined graph

The script reuses the frontmatter parser and handle resolution from
predicate-graph.py. It maps frontmatter fields to RDF predicates per
the semantic-frontmatter specification.

Reference: semantic-frontmatter.md, predicate-graph.md.
"""

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent.parent.parent.parent
CONTENT_ROOT = REPO_ROOT / "content"
SCRIPTS_DIR = CONTENT_ROOT / "technology" / "specifications" / \
    "agential-semioverse-repository" / "scripts"

# Import the frontmatter parser from predicate-graph.py
sys.path.insert(0, str(SCRIPTS_DIR))
from importlib.util import spec_from_file_location, module_from_spec
_spec = spec_from_file_location("predicate_graph",
                                SCRIPTS_DIR / "predicate-graph.py")
_pg_mod = module_from_spec(_spec)
_spec.loader.exec_module(_pg_mod)
parse_frontmatter = _pg_mod.parse_frontmatter
is_handle = _pg_mod.is_handle
resolve_handle = _pg_mod.resolve_handle

# ---------------------------------------------------------------------------
# Namespace prefixes
# ---------------------------------------------------------------------------

PREFIXES = {
    "emsenn": "https://emsenn.net/",
    "schema": "https://schema.org/",
    "skos": "http://www.w3.org/2004/02/skos/core#",
    "dcterms": "http://purl.org/dc/terms/",
    "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
    "xsd": "http://www.w3.org/2001/XMLSchema#",
    "foaf": "http://xmlns.com/foaf/0.1/",
}

PREFIX_BLOCK = "\n".join(
    f"@prefix {k}: <{v}> ." for k, v in PREFIXES.items()
) + "\n"

# ---------------------------------------------------------------------------
# Type mapping: frontmatter type -> Schema.org @type
# ---------------------------------------------------------------------------

TYPE_MAP = {
    "term": ("skos:Concept", "schema:DefinedTerm"),
    "concept": ("skos:Concept", "schema:DefinedTerm"),
    "lesson": ("schema:LearningResource",),
    "person": ("schema:Person",),
    "question": ("schema:Question",),
    "text": ("schema:Article",),
    "letter": ("schema:Article",),
    "babble": ("schema:Article",),
    "index": ("schema:CollectionPage",),
    "topic": ("skos:Concept",),
    "school": ("skos:ConceptScheme",),
    "skill": ("schema:HowTo",),
    "curriculum": ("schema:Course",),
    # Math domain types
    "theorem": ("skos:Concept",),
    "proof": ("skos:Concept",),
    "axiom": ("skos:Concept",),
    "definition": ("skos:Concept", "schema:DefinedTerm"),
    "conjecture": ("skos:Concept",),
    "lemma": ("skos:Concept",),
    "corollary": ("skos:Concept",),
    "proposition": ("skos:Concept",),
    # Philosophy domain types
    "claim": ("schema:Claim",),
    "argument": ("schema:Article",),
    "objection": ("schema:Article",),
    "position": ("skos:Concept",),
    "tradition": ("skos:ConceptScheme",),
    # Game domain types
    "specification": ("schema:TechArticle",),
}

DEFAULT_TYPE = ("schema:Article",)

# ---------------------------------------------------------------------------
# Field -> predicate mapping (from semantic-frontmatter.md)
# ---------------------------------------------------------------------------

# Each entry: (predicate_curie, is_resource)
# is_resource=True means object is an IRI (resolved handle), False means literal
FIELD_MAP = {
    "defines":    ("skos:definition", False),
    "cites":      ("dcterms:references", True),
    "teaches":    ("schema:teaches", False),
    "requires":   ("dcterms:requires", True),
    "part-of":    ("dcterms:isPartOf", True),
    "extends":    ("schema:isBasedOn", True),
    "questions":  ("schema:about", False),
    "addresses":  ("schema:about", False),
    "mirrors":    ("rdfs:seeAlso", True),
    "references": ("dcterms:references", True),
    # Domain-specific
    "proven-by":  ("emsenn:provenBy", True),
    "proves":     ("emsenn:proves", True),
    "notation":   ("emsenn:notation", False),
    "argued-by":  ("emsenn:arguedBy", True),
    "supports":   ("emsenn:supports", True),
    "targets":    ("emsenn:targets", True),
    "contested-by": ("emsenn:contestedBy", True),
    "school":     ("emsenn:school", True),
    "integrates": ("emsenn:integrates", True),
    "produces":   ("emsenn:produces", True),
    "sustains":   ("emsenn:sustains", True),
    "contests":   ("emsenn:contests", True),
    "uses-concepts": ("emsenn:usesConcepts", True),
    "emerges-under": ("emsenn:emergesUnder", True),
    "uses-mechanic": ("emsenn:usesMechanic", True),
    "classifies": ("emsenn:classifies", True),
    "boundary-with": ("emsenn:boundaryWith", True),
    "models":     ("emsenn:models", True),
    "practiced-through": ("emsenn:practicedThrough", True),
    "scaffolds":  ("emsenn:scaffolds", True),
    "builds-on":  ("emsenn:buildsOn", True),
}

# Metadata fields — skip these when generating relation triples
METADATA_FIELDS = {
    "title", "aliases", "date-created", "date-updated", "status",
    "id", "kind", "description", "summary", "name", "version",
    "runtime", "region", "dependencies", "scopes", "inputs", "outputs",
    "skill-kind", "license", "compatibility", "metadata", "allowed-tools",
    "invocation", "tool", "triggers", "publish_to",
}

# Directories to skip
SKIP_DIRS = {"private", "meta", "slop", ".obsidian"}


# ---------------------------------------------------------------------------
# TTL generation
# ---------------------------------------------------------------------------

def escape_turtle_string(s: str) -> str:
    """Escape a string for use in Turtle literals."""
    return s.replace("\\", "\\\\").replace('"', '\\"')


def handle_to_iri(handle: str) -> str:
    """Convert a content-relative handle to a prefixed IRI."""
    # Strip .md extension, use forward slashes
    stem = handle.replace("\\", "/")
    if stem.endswith(".md"):
        stem = stem[:-3]
    return f"emsenn:{stem}"


def generate_ttl(md_path: Path, content_root: Path) -> str | None:
    """Generate Turtle content for a single markdown file.

    Returns the TTL string, or None if the file has no semantic content.
    """
    fm = parse_frontmatter(md_path)
    if fm is None:
        return None

    handle = str(md_path.relative_to(content_root)).replace("\\", "/")
    subject = handle_to_iri(handle)

    triples = []

    # --- Type ---
    content_type = fm.get("type")
    type_classes = TYPE_MAP.get(content_type, DEFAULT_TYPE) if content_type else DEFAULT_TYPE
    # Combine type declarations with comma separation per Turtle convention
    type_str = ", ".join(type_classes)
    triples.append(f"  a {type_str}")

    # --- Title ---
    title = fm.get("title", md_path.stem.replace("-", " ").title())
    triples.append(f'  schema:name "{escape_turtle_string(title)}"')
    triples.append(f'  rdfs:label "{escape_turtle_string(title)}"')

    # --- Date ---
    date_created = fm.get("date-created")
    if date_created:
        # Handle both string and datetime-like values
        date_str = str(date_created).split("T")[0] if "T" in str(date_created) else str(date_created)
        triples.append(f'  dcterms:created "{date_str}"^^xsd:date')

    # --- Authors ---
    authors = fm.get("authors", [])
    if isinstance(authors, str):
        authors = [authors]
    for author in authors:
        triples.append(f'  dcterms:creator "{escape_turtle_string(author)}"')

    # --- Tags ---
    tags = fm.get("tags", [])
    if isinstance(tags, str):
        tags = [tags]
    for tag in tags:
        triples.append(f'  schema:keywords "{escape_turtle_string(tag)}"')

    # --- Semantic relation fields ---
    has_relations = False
    for key, value in fm.items():
        if key in METADATA_FIELDS or key in ("type", "tags", "authors"):
            continue

        mapping = FIELD_MAP.get(key)
        if mapping is None:
            continue

        predicate, is_resource = mapping
        has_relations = True

        values = value if isinstance(value, list) else [value]
        for v in values:
            if isinstance(v, dict):
                # Notation entries: {symbol: X, for: Y}
                sym = v.get("symbol", "")
                if sym:
                    triples.append(
                        f'  {predicate} "{escape_turtle_string(sym)}"')
                continue

            v_str = str(v).strip()
            if not v_str:
                continue

            if is_resource and is_handle(v_str):
                resolved = resolve_handle(md_path.parent, v_str, content_root)
                try:
                    canonical = str(resolved.relative_to(content_root)).replace("\\", "/")
                    triples.append(f"  {predicate} {handle_to_iri(canonical)}")
                except ValueError:
                    # Can't resolve — use as literal
                    triples.append(
                        f'  {predicate} "{escape_turtle_string(v_str)}"')
            elif is_resource:
                # Value that looks like a name, not a path — keep as literal
                triples.append(
                    f'  {predicate} "{escape_turtle_string(v_str)}"')
            else:
                triples.append(
                    f'  {predicate} "{escape_turtle_string(v_str)}"')

    # Only generate TTL if there's something beyond the bare minimum
    if not has_relations and not tags and not authors:
        # Page has only title and type — skip unless explicitly requested
        if content_type is None:
            return None

    # Build the turtle document
    lines = [PREFIX_BLOCK, f"{subject}"]
    # Join triples with " ;\n" and end with " ."
    lines.append(" ;\n".join(triples) + " .")
    lines.append("")

    return "\n".join(lines)


def find_md_files(content_root: Path) -> list[Path]:
    """Find all publishable markdown files."""
    results = []
    for md_path in sorted(content_root.rglob("*.md")):
        # Skip non-content files
        rel = md_path.relative_to(content_root)
        parts = rel.parts
        if not parts:
            continue

        # Skip special directories
        if parts[0] in SKIP_DIRS:
            continue

        # Skip triage
        if parts[0] == "triage":
            continue

        # Skip SKILL.md files (they're skills, not content)
        if md_path.name == "SKILL.md":
            continue

        results.append(md_path)
    return results


def main():
    parser = argparse.ArgumentParser(
        description="Generate RDF/Turtle from markdown frontmatter")
    parser.add_argument("path", nargs="?",
                        help="Path to a markdown file (relative to content/ or absolute)")
    parser.add_argument("--all", action="store_true",
                        help="Generate TTL for all publishable pages")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would be generated without writing files")
    parser.add_argument("--stats", action="store_true",
                        help="Print statistics only")
    parser.add_argument("--combined", action="store_true",
                        help="Also write a combined knowledge-graph.ttl")
    parser.add_argument("--force", action="store_true",
                        help="Overwrite existing .ttl files")
    args = parser.parse_args()

    if not args.path and not args.all:
        parser.error("Specify a path or use --all")

    content_root = CONTENT_ROOT

    if args.all:
        md_files = find_md_files(content_root)
    else:
        # Resolve the path
        p = Path(args.path)
        if not p.is_absolute():
            # Try relative to content/
            candidate = content_root / p
            if candidate.exists():
                p = candidate
            else:
                # Try relative to repo root
                candidate = REPO_ROOT / p
                if candidate.exists():
                    p = candidate
        if not p.exists():
            print(f"Error: {args.path} not found", file=sys.stderr)
            sys.exit(1)
        md_files = [p]

    generated = 0
    skipped = 0
    errors = 0
    combined_ttl = [PREFIX_BLOCK] if args.combined else None

    for md_path in md_files:
        try:
            ttl = generate_ttl(md_path, content_root)
        except Exception as e:
            errors += 1
            if not args.stats:
                print(f"  ERROR {md_path.relative_to(content_root)}: {e}",
                      file=sys.stderr)
            continue

        if ttl is None:
            skipped += 1
            continue

        ttl_path = md_path.with_suffix(".ttl")

        if args.stats:
            generated += 1
            continue

        if args.dry_run:
            rel = md_path.relative_to(content_root)
            print(f"  WOULD WRITE {rel.with_suffix('.ttl')}")
            generated += 1
            continue

        if ttl_path.exists() and not args.force:
            skipped += 1
            continue

        ttl_path.write_text(ttl, encoding="utf-8")
        generated += 1

        if combined_ttl is not None:
            # Strip prefix block from individual entries for combined file
            lines = ttl.split("\n")
            # Find where prefixes end (first blank line after prefixes)
            body_start = 0
            for i, line in enumerate(lines):
                if line.strip() == "" and i > 0:
                    body_start = i + 1
                    break
            combined_ttl.append("\n".join(lines[body_start:]))

        if not args.all:
            # Single file mode: print the TTL
            print(ttl)

    if args.combined and combined_ttl and not args.dry_run:
        combined_path = REPO_ROOT / "knowledge-graph.ttl"
        combined_path.write_text("\n".join(combined_ttl), encoding="utf-8")
        print(f"  Combined graph: {combined_path}")

    # Summary
    total = generated + skipped + errors
    print(f"\n  {total} files scanned, {generated} TTL generated, "
          f"{skipped} skipped, {errors} errors")


if __name__ == "__main__":
    main()
