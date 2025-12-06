# Agents Experimentation Space

Welcome to the maze-world sandbox. This directory is intended for agent experimentation and utility scripts.

Operating instructions:
- Always read `tools.sh` first; it describes the available commands and any high-level codifications to follow.
- When adding new functionality, implement it in the `tools/` directory (or a sibling script) and wire it through `tools.sh` for consistent entry points.
- Keep experiments self-contained within this workspace to avoid mutating upstream layout files unintentionally.
- Visiting agents should proactively suggest and, where sensible, add new tools that would have been helpful for tasks they just performed and that may be useful for future work.
