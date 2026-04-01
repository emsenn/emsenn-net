#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path

import yaml


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--path", required=True)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    path = Path(args.path)
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    spread = data.get("spread")
    positions = {item.get("name"): item.get("role") for item in data.get("positions", [])}
    draw = data.get("draw", [])

    summary = []
    for entry in draw:
        position = entry.get("position")
        card = entry.get("card")
        orientation = entry.get("orientation", "upright")
        role = positions.get(position, "")
        summary.append(
            {
                "position": position,
                "role": role,
                "card": card,
                "orientation": orientation,
            }
        )

    result = {"spread": spread, "cards": summary}
    if args.json:
        print(json.dumps(result, ensure_ascii=True))
    else:
        for item in summary:
            role = f" ({item['role']})" if item["role"] else ""
            print(f"{item['position']}{role}: {item['card']} [{item['orientation']}]")


if __name__ == "__main__":
    main()
