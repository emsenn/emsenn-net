#!/usr/bin/env python3
"""check-environment.py — Report available infrastructure without installing anything.

Probes for Node.js, Python, Ollama, Foundry Local, content submodule,
and MCP dependencies. Outputs JSON to stdout and a human summary to
stderr. Exit code is always 0 — this script reports, it does not enforce.

Usage:
    python3 scripts/check-environment.py
    python3 scripts/check-environment.py --json    # JSON only, no summary
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import urllib.request
import urllib.error
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent

OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
FOUNDRY_URL = os.environ.get("FOUNDRY_URL", "http://127.0.0.1:56805")


def probe_url(url: str, timeout: float = 2.0) -> dict | None:
    """GET a URL and return parsed JSON, or None on any failure."""
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read())
    except Exception:
        return None


def check_python() -> dict:
    return {
        "available": True,
        "version": f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
        "path": sys.executable,
    }


def check_node() -> dict:
    node = shutil.which("node")
    if not node:
        return {"available": False}
    try:
        result = subprocess.run(
            [node, "--version"], capture_output=True, text=True, timeout=5
        )
        version = result.stdout.strip().lstrip("v")
        return {"available": True, "version": version, "path": node}
    except Exception:
        return {"available": False}


def check_ollama() -> dict:
    url = OLLAMA_URL
    # Try to list models
    data = probe_url(f"{url}/api/tags")
    if data is None:
        return {"available": False, "url": url}

    models = []
    for m in data.get("models", []):
        name = m.get("name", "")
        size_bytes = m.get("size", 0)
        size_gb = round(size_bytes / (1024**3), 1) if size_bytes else 0
        models.append({"name": name, "size_gb": size_gb})

    return {
        "available": True,
        "url": url,
        "model_count": len(models),
        "models": models,
    }


def check_foundry() -> dict:
    url = FOUNDRY_URL
    data = probe_url(f"{url}/v1/models")
    if data is None:
        return {"available": False, "url": url}

    models = []
    model_list = data.get("data", [])
    if isinstance(model_list, list):
        for m in model_list:
            if isinstance(m, dict):
                models.append(m.get("id", str(m)))
            else:
                models.append(str(m))

    # Also check the simpler /openai/models endpoint
    if not models:
        simple = probe_url(f"{url}/openai/models")
        if isinstance(simple, list):
            models = simple

    return {
        "available": True,
        "url": url,
        "model_count": len(models),
        "models": models,
    }


def check_content_submodule() -> dict:
    content_dir = REPO_ROOT / "content"
    if not content_dir.is_dir():
        return {"available": False, "reason": "content/ directory missing"}

    # Check if it has files (not just an empty submodule)
    try:
        entries = list(content_dir.iterdir())
        has_files = any(e.name != ".git" for e in entries)
    except Exception:
        has_files = False

    if not has_files:
        return {"available": False, "reason": "content/ is empty (submodule not initialized)"}

    return {"available": True, "path": str(content_dir)}


def check_mcp_package() -> dict:
    try:
        import importlib
        spec = importlib.util.find_spec("mcp")
        return {"available": spec is not None}
    except Exception:
        return {"available": False}


def main():
    parser = argparse.ArgumentParser(
        description="Report available infrastructure (no side effects)")
    parser.add_argument("--json", action="store_true",
                        help="JSON output only, no human summary")
    args = parser.parse_args()

    report = {
        "python": check_python(),
        "node": check_node(),
        "ollama": check_ollama(),
        "foundry": check_foundry(),
        "content_submodule": check_content_submodule(),
        "mcp_package": check_mcp_package(),
    }

    # Classify environment
    has_llm = report["ollama"]["available"] or report["foundry"]["available"]
    report["environment"] = "local" if has_llm else "cloud"

    # JSON to stdout
    print(json.dumps(report, indent=2))

    # Human summary to stderr (unless --json)
    if not args.json:
        def status(available: bool) -> str:
            return "OK" if available else "--"

        print("\n--- Environment Summary ---", file=sys.stderr)
        print(f"  Python:    {status(report['python']['available'])}  {report['python'].get('version', '')}", file=sys.stderr)
        print(f"  Node.js:   {status(report['node']['available'])}  {report['node'].get('version', '')}", file=sys.stderr)
        print(f"  Ollama:    {status(report['ollama']['available'])}  {report['ollama'].get('model_count', 0)} models", file=sys.stderr)
        print(f"  Foundry:   {status(report['foundry']['available'])}  {report['foundry'].get('model_count', 0)} models", file=sys.stderr)
        print(f"  Content:   {status(report['content_submodule']['available'])}", file=sys.stderr)
        print(f"  MCP:       {status(report['mcp_package']['available'])}", file=sys.stderr)
        print(f"  Environment: {report['environment']}", file=sys.stderr)


if __name__ == "__main__":
    main()
