# Maze World Experimentation

This repository captures agent experiments for deriving PHEN/DIM snapshots from a fixed set of natural-language (NL) lines.

## What’s here
- `nl.txt`: canonical NL inputs used across all runs.
- `world-layout-base/`: header-only template used to seed new layouts.
- `world-layout-all-at-once/`, `world-layout-stream-new-context/`, `world-layout-stream-same-context/`: outputs from three strategies (all NL at once, cumulative streaming, single-line streaming).
- `tools/`: helper scripts (`copy-world-layout-base.sh`, runners, NL utilities).
- `tools.sh`: entrypoint for the helper commands.

## How to use
- Create a fresh layout copy: `./tools.sh copy-base myrun`.
- Run strategies with default NL (`nl.txt`):
  - `./tools.sh run-all-at-once`
  - `./tools.sh run-stream-new-context`
  - `./tools.sh run-stream-same-context`
- Inspect NL inputs: `./tools.sh concat-nl` (or `python3 tools/nl_text.py`).
- View latest PHEN/DIM snapshot: `./tools.sh latest-dim` (defaults to `world-layout-all-at-once/world-layout.txt`).

All directories inherit the same header/AGENTS instructions; only `world-layout*.txt` files are modified by agents during runs.
