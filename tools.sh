#!/usr/bin/env bash
# Quick wrapper for the maze-world tools.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ./tools.sh <command> [args]

Available commands:
  concat-nl [layout_path]   Print all NL descriptions (default: nl.txt).
  latest-dim [layout_path]  Show the latest PHEN/DIM snapshot (default: world-layout-all-at-once/world-layout.txt).
  copy-base <suffix>        Create world-layout-<suffix> from world-layout-base.
  run-all-at-once           Run Codex with all NL descriptions in one prompt (world-layout-all-at-once).
  run-stream-new-context    Run Codex line-by-line, cumulatively (world-layout-stream-new-context).
  run-stream-same-context   Run Codex line-by-line, one line per prompt (world-layout-stream-same-context).
  run-variability [n]       Fire-and-forget: run n trials per strategy in background; logs/results under results/variability/.
  run-variability [n]       Run n trials of each strategy into fresh dirs and save snapshots.

If no layout_path is provided, concat-nl/nl-text pull NL lines from nl.txt in the repo root; latest-dim reads from world-layout-all-at-once/world-layout.txt; the runners read NL from nl.txt by default.

Examples:
  ./tools.sh concat-nl
  ./tools.sh latest-dim
  ./tools.sh copy-base test-run
  ./tools.sh run-all-at-once
  ./tools.sh run-stream-new-context
  ./tools.sh run-stream-same-context
  ./tools.sh concat-nl /path/to/custom-layout.txt
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

command="$1"
shift

case "$command" in
  concat-nl)
    exec python3 "$ROOT_DIR/tools/concat_nl.py" "$@"
    ;;
  latest-dim)
    exec python3 "$ROOT_DIR/tools/latest_dim.py" "$@"
    ;;
  copy-base)
    exec "$ROOT_DIR/tools/copy-world-layout-base.sh" "$@"
    ;;
  run-all-at-once)
    exec "$ROOT_DIR/tools/run_all_at_once.sh" "$@"
    ;;
  run-stream-new-context)
    exec "$ROOT_DIR/tools/run_stream_new_context.sh" "$@"
    ;;
  run-stream-same-context)
    exec "$ROOT_DIR/tools/run_stream_same_context.sh" "$@"
    ;;
  run-variability)
    exec "$ROOT_DIR/tools/run_variability.sh" "$@"
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    echo "Unknown command: $command" >&2
    usage
    exit 1
    ;;
esac
