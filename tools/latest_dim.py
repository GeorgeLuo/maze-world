#!/usr/bin/env python3
"""Print the latest PHEN/DIM snapshot from world-layout-all-at-once/world-layout.txt by default."""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Iterable, List, Tuple


def parse_snapshot(lines: Iterable[str]) -> Tuple[List[Tuple[str, str]], List[Tuple[str, str]]]:
    """Return PHEN and DIM entries from the most recent snapshot in the file."""
    current_phens: List[Tuple[str, str]] = []
    current_dims: List[Tuple[str, str]] = []

    for raw_line in lines:
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue

        if line.startswith("NL "):
            current_phens = []
            current_dims = []
            continue

        if line.startswith(("PHEN ", "DIM ")):
            parts = line.split(None, 2)
            if len(parts) < 3:
                continue

            _, identifier, remainder = parts
            desc_prefix = 'description="'
            description = ""
            if desc_prefix in remainder:
                after_prefix = remainder.split(desc_prefix, 1)[1]
                description = after_prefix.rstrip().rstrip('"')

            if line.startswith("PHEN "):
                current_phens.append((identifier, description))
            else:
                current_dims.append((identifier, description))

    return current_phens, current_dims


def print_snapshot(phens: List[Tuple[str, str]], dims: List[Tuple[str, str]]) -> None:
    """Print the snapshot in a human-readable layout."""
    print("Latest phenomenon and dimensionalities\n")

    if phens:
        print("Phenomena:")
        for identifier, description in phens:
            print(f"- {identifier}: {description}")
    else:
        print("Phenomena: none found.")

    print()

    if dims:
        print("Dimensionalities:")
        for identifier, description in dims:
            print(f"- {identifier}: {description}")
    else:
        print("Dimensionalities: none found.")


def default_layout_path() -> Path:
    """Return the default path to the world layout file, based on the current working directory."""
    return Path.cwd() / "world-layout-all-at-once" / "world-layout.txt"


def main() -> int:
    layout_path = default_layout_path()
    if len(sys.argv) > 1:
        layout_path = Path(sys.argv[1]).expanduser()

    if not layout_path.exists():
        sys.stderr.write(f"File not found: {layout_path}\n")
        return 1

    lines = layout_path.read_text(encoding="utf-8").splitlines()
    phens, dims = parse_snapshot(lines)

    if not phens and not dims:
        sys.stderr.write("No PHEN or DIM entries found in the layout file.\n")
        return 1

    print_snapshot(phens, dims)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
