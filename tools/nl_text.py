#!/usr/bin/env python3
"""Print raw NL descriptions from the NL source layout file (one per line)."""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Iterable, List


def extract_nl_descriptions(lines: Iterable[str]) -> List[str]:
    """Return the ordered NL descriptions from the layout file."""
    descriptions: List[str] = []
    for raw_line in lines:
        line = raw_line.rstrip("\n")
        if line.startswith("NL "):
            descriptions.append(line[3:])
    return descriptions


def default_layout_path() -> Path:
    """Return the default path to the NL source layout file, based on the current working directory."""
    return Path.cwd() / "world-layout-nl-source" / "world-layout.txt"


def main() -> int:
    layout_path = default_layout_path()
    if len(sys.argv) > 1:
        layout_path = Path(sys.argv[1]).expanduser()

    if not layout_path.exists():
        sys.stderr.write(f"File not found: {layout_path}\n")
        return 1

    lines = layout_path.read_text(encoding="utf-8").splitlines()
    descriptions = extract_nl_descriptions(lines)

    if not descriptions:
        sys.stderr.write("No NL descriptions found in the layout file.\n")
        return 1

    print("\n".join(descriptions))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
