#!/usr/bin/env bash
# Run the "stream with new context" strategy: submit NL lines one by one, cumulatively.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="${ROOT_DIR}/world-layout-stream-new-context"
DEFAULT_SOURCE="${ROOT_DIR}/nl.txt"

usage() {
  cat <<'EOF'
Usage: ./tools.sh run-stream-new-context [layout_path]

Feeds NL descriptions line-by-line to Codex, accumulating all prior lines into each subsequent prompt.
Runs inside world-layout-stream-new-context.
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
  echo "hint: create it with ./copy-world-layout-base.sh stream-new-context" >&2
  exit 1
fi

nl_lines=()
while IFS= read -r line; do
  nl_lines+=("$line")
done < <(python3 "$ROOT_DIR/tools/nl_text.py" "$LAYOUT_SOURCE")

if [[ "${#nl_lines[@]}" -eq 0 ]]; then
  echo "error: no NL lines found" >&2
  exit 1
fi

cumulative=""
for idx in "${!nl_lines[@]}"; do
  line="${nl_lines[$idx]}"
  if [[ -z "$cumulative" ]]; then
    cumulative="$line"
  else
    cumulative+=$'\n'"$line"
  fi

  echo "Submitting cumulative NL through line $((idx + 1))"
  printf "%s\n" "$cumulative" | codex exec --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check --cd "$DEST_DIR" -
done
