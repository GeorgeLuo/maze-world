#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_DIR="${ROOT_DIR}/world-layout-base"

usage() {
  cat <<'EOF'
Usage: ./copy-world-layout-base.sh <suffix>

Creates a new directory named world-layout-<suffix> by copying world-layout-base.
EOF
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

suffix="$1"

if [[ -z "$suffix" ]]; then
  echo "error: suffix must not be empty" >&2
  exit 1
fi

if [[ "$suffix" == */* ]]; then
  echo "error: suffix must not contain '/'" >&2
  exit 1
fi

if [[ ! -d "$BASE_DIR" ]]; then
  echo "error: base directory not found: $BASE_DIR" >&2
  exit 1
fi

dest="${ROOT_DIR}/world-layout-${suffix}"

if [[ -e "$dest" ]]; then
  echo "error: destination already exists: $dest" >&2
  exit 1
fi

cp -R "$BASE_DIR" "$dest"

echo "Created $dest"
