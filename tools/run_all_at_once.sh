#!/usr/bin/env bash
# Run the "all at once" strategy: feed all NL descriptions in one prompt.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="${ROOT_DIR}/world-layout-all-at-once"
DEFAULT_SOURCE="${ROOT_DIR}/nl.txt"

usage() {
  cat <<'EOF'
Usage: ./tools.sh run-all-at-once [layout_path]

Feeds all NL descriptions to Codex in a single prompt, working inside world-layout-all-at-once.
If layout_path is provided, NL descriptions are read from that file instead of nl.txt at the repo root.
EOF
}

if [[ "${1-}" == "-h" || "${1-}" == "--help" ]]; then
  usage
  exit 0
fi

LAYOUT_SOURCE="${1:-$DEFAULT_SOURCE}"

if [[ ! -f "$LAYOUT_SOURCE" ]]; then
  echo "error: layout file not found: $LAYOUT_SOURCE" >&2
  exit 1
fi

if [[ ! -d "$DEST_DIR" ]]; then
  echo "error: destination directory not found: $DEST_DIR" >&2
  echo "hint: create it with ./copy-world-layout-base.sh all-at-once" >&2
  exit 1
fi

python3 "$ROOT_DIR/tools/nl_text.py" "$LAYOUT_SOURCE" \
  | codex exec --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check --cd "$DEST_DIR" -
