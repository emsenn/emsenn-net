#!/usr/bin/env python3
import argparse
from datetime import date
from pathlib import Path

import yaml
from jinja2 import Environment, FileSystemLoader


def load_frontmatter(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    parts = text.split("---", 2)
    if len(parts) < 3:
        return {}
    frontmatter = parts[1]
    return yaml.safe_load(frontmatter) or {}


def as_link_path(path: Path) -> str:
    rel = path.as_posix().lstrip(".")
    if not rel.startswith("/"):
        rel = "/" + rel
    return rel


def gather_entries(vault_root: Path) -> list[dict]:
    entries = []
    for path in sorted(vault_root.rglob("*.md")):
        frontmatter = load_frontmatter(path)
        title = frontmatter.get("title") or frontmatter.get("name") or path.stem
        entry = {
            "title": title,
            "id": frontmatter.get("id"),
            "tags": frontmatter.get("tags") or [],
            "path": as_link_path(path),
        }
        entries.append(entry)
    return entries


def render_index(template_path: Path, context: dict) -> str:
    env = Environment(loader=FileSystemLoader(str(template_path.parent)), autoescape=False)
    template = env.get_template(template_path.name)
    return template.render(**context)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--vault-root", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument(
        "--template",
        default="library/mathematics/objects/interactive-semioverse/templates/markdown-vault-index.md.j2",
    )
    args = parser.parse_args()

    vault_root = Path(args.vault_root)
    output = Path(args.output)
    template_path = Path(args.template)

    entries = gather_entries(vault_root)
    context = {
        "date_created": date.today().isoformat(),
        "vault_root": as_link_path(vault_root),
        "entries": entries,
    }
    output.write_text(render_index(template_path, context), encoding="utf-8")


if __name__ == "__main__":
    main()
