#!/usr/bin/env bash
# Run multiple trials of each extraction strategy, capture PHEN/DIM outputs, and reset trial dirs.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_DIR="$ROOT_DIR/world-layout-base"
RESULTS_DIR="$ROOT_DIR/results/variability"
NL_DEFAULT="$ROOT_DIR/nl.txt"
BACKGROUND_FLAG="--run-internal"

usage() {
  cat <<'EOF'
Usage: ./tools.sh run-variability [trials] [nl_source]

Runs each strategy (all-at-once, stream-new-context, stream-same-context) for N trials
using the NL inputs from nl_source (default: nl.txt).

Trial dirs (reset each run, left in place for reuse):
  world-layout-all-at-once-trial
  world-layout-stream-new-context-trial
  world-layout-stream-same-context-trial

Outputs per trial:
  results/variability/<strategy>/t<trial>-latest.txt        # latest PHEN/DIM snapshot
  results/variability/<strategy>/t<trial>-world-layout.txt  # full layout file after run
EOF
}

if [[ "${1-}" =~ ^-h|--help$ ]]; then
  usage
  exit 0
fi

if [[ "${1-}" != "$BACKGROUND_FLAG" ]]; then
  # Fire-and-forget: spawn background job and exit.
  mkdir -p "$RESULTS_DIR"
  log_file="$RESULTS_DIR/run-$(date +%Y%m%d-%H%M%S).log"
  nohup "$0" "$BACKGROUND_FLAG" "$@" > "$log_file" 2>&1 &
  bg_pid=$!
  echo "Variability run started in background (pid $bg_pid). Log: $log_file"
  exit 0
fi

# Internal run (background) starts here.
shift # drop BACKGROUND_FLAG

TRIALS="${1:-1}"
NL_SOURCE_RAW="${2:-$NL_DEFAULT}"

# Resolve NL source to an absolute path to use from temp dirs
NL_SOURCE="$(python3 - "$NL_SOURCE_RAW" <<'PY'
import pathlib, sys
raw = sys.argv[1]
print(pathlib.Path(raw).expanduser().resolve())
PY
)"

if ! [[ "$TRIALS" =~ ^[0-9]+$ ]] || [[ "$TRIALS" -lt 1 ]]; then
  echo "error: trials must be a positive integer (got: $TRIALS)" >&2
  exit 1
fi

if [[ ! -f "$NL_SOURCE" ]]; then
  echo "error: NL source not found: $NL_SOURCE" >&2
  exit 1
fi

if [[ ! -d "$BASE_DIR" ]]; then
  echo "error: base directory not found: $BASE_DIR" >&2
  exit 1
fi

mkdir -p "$RESULTS_DIR"

reset_trial_dir() {
  local dest="$1"
  rm -rf "$dest"
  mkdir -p "$dest"
  cp "$BASE_DIR/world-layout.txt" "$dest/world-layout.txt"
  cp "$BASE_DIR/AGENTS.md" "$dest/AGENTS.md"
}

run_all_at_once() {
  local dest="$1"
  echo "[all-at-once] running in $dest"
  (cd "$dest" && python3 "$ROOT_DIR/tools/nl_text.py" "$NL_SOURCE" \
    | codex exec --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -)
}

run_stream_new_context() {
  local dest="$1"
  local cumulative=""
  echo "[stream-new-context] running in $dest"
  while IFS= read -r line; do
    if [[ -z "$cumulative" ]]; then
      cumulative="$line"
    else
      cumulative+=$'\n'"$line"
    fi
    (cd "$dest" && printf "%s\n" "$cumulative" | codex exec --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -)
  done < "$NL_SOURCE"
}

run_stream_same_context() {
  local dest="$1"
  echo "[stream-same-context] running in $dest"
  while IFS= read -r line; do
    (cd "$dest" && printf "%s\n" "$line" | codex exec --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -)
  done < "$NL_SOURCE"
}

for trial in $(seq 1 "$TRIALS"); do
  work_dir="$(mktemp -d /tmp/maze-variability-XXXXXXXX)"
  for strategy in all-at-once stream-new-context stream-same-context; do
    trial_dir="$work_dir/world-layout-${strategy}-trial"
    reset_trial_dir "$trial_dir"

    case "$strategy" in
      all-at-once)           run_all_at_once "$trial_dir" ;;
      stream-new-context)    run_stream_new_context "$trial_dir" ;;
      stream-same-context)   run_stream_same_context "$trial_dir" ;;
      *) echo "unknown strategy: $strategy" >&2; exit 1 ;;
    esac

    out_dir="$RESULTS_DIR/$strategy"
    mkdir -p "$out_dir"
    python3 "$ROOT_DIR/tools/latest_dim.py" "$trial_dir/world-layout.txt" > "$out_dir/t${trial}-latest.txt"
    cp "$trial_dir/world-layout.txt" "$out_dir/t${trial}-world-layout.txt"
  done
  rm -rf "$work_dir"
done

echo "Completed $TRIALS trial(s) per strategy. Results in $RESULTS_DIR"
