#!/usr/bin/env bash
#
# rollback.sh — Rollback management for qwe1 development
#
# Usage:
#   tools/rollback.sh save          Tag current commit as last known-good
#   tools/rollback.sh list          List all rollback tags
#   tools/rollback.sh last          Show the last saved tag
#   tools/rollback.sh restore       Revert to last saved tag
#   tools/rollback.sh restore <tag> Revert to a specific tag
#   tools/rollback.sh drop <tag>    Remove a rollback tag
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG_PREFIX="rollback"
LAST_GOOD_FILE="$REPO_ROOT/.last-good-commit"

cd "$REPO_ROOT"

cmd_save() {
  local tag="${TAG_PREFIX}/$(date +%Y%m%d-%H%M%S)"
  local short_hash
  short_hash=$(git rev-parse --short HEAD)

  git tag -a "$tag" -m "Rollback point: $short_hash"
  echo "$tag" > "$LAST_GOOD_FILE"

  echo "Saved rollback point: $tag ($short_hash)"
  echo "Commit: $(git log --oneline -1)"
}

cmd_list() {
  echo "Rollback tags:"
  git tag -l "${TAG_PREFIX}/*" --sort=-creatordate | while read -r t; do
    local hash
    hash=$(git rev-parse --short "$t")
    local date
    date=$(git log -1 --format="%ai" "$t")
    local marker=""
    if [ -f "$LAST_GOOD_FILE" ] && [ "$(cat "$LAST_GOOD_FILE")" = "$t" ]; then
      marker=" <-- LAST GOOD"
    fi
    echo "  $t  ($hash)  $date$marker"
  done
}

cmd_last() {
  if [ ! -f "$LAST_GOOD_FILE" ]; then
    echo "No last-good-commit recorded. Run: tools/rollback.sh save"
    exit 1
  fi
  local tag
  tag=$(cat "$LAST_GOOD_FILE")
  echo "$tag"
}

cmd_restore() {
  local target=""
  if [ "${1:-}" != "" ]; then
    target="$1"
  elif [ -f "$LAST_GOOD_FILE" ]; then
    target=$(cat "$LAST_GOOD_FILE")
  else
    echo "No tag specified and no last-good-commit recorded."
    echo "Usage: tools/rollback.sh restore [tag]"
    exit 1
  fi

  if ! git rev-parse "$target" >/dev/null 2>&1; then
    echo "Error: tag '$target' does not exist."
    exit 1
  fi

  local hash
  hash=$(git rev-parse --short "$target")
  echo "Rolling back to: $target ($hash)"
  echo "Current branch: $(git branch --show-current)"
  echo ""

  read -r -p "Proceed? (y/N) " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi

  git checkout "$target"
  echo ""
  echo "Checked out $target."
  echo "Run 'flutter build apk --release' to rebuild."
}

cmd_drop() {
  local target="${1:-}"
  if [ -z "$target" ]; then
    echo "Usage: tools/rollback.sh drop <tag>"
    exit 1
  fi

  if ! git tag -l "$target" | grep -q .; then
    echo "Error: tag '$target' does not exist."
    exit 1
  fi

  git tag -d "$target"
  echo "Deleted tag: $target"

  if [ -f "$LAST_GOOD_FILE" ] && [ "$(cat "$LAST_GOOD_FILE")" = "$target" ]; then
    rm "$LAST_GOOD_FILE"
    echo "Cleared last-good-commit record."
  fi
}

case "${1:-}" in
  save)    cmd_save ;;
  list)    cmd_list ;;
  last)    cmd_last ;;
  restore) cmd_restore "${2:-}" ;;
  drop)    cmd_drop "${2:-}" ;;
  *)
    echo "qwe1 Rollback Manager"
    echo ""
    echo "Usage: tools/rollback.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  save          Tag current commit as last known-good"
    echo "  list          List all rollback tags"
    echo "  last          Show the last saved tag"
    echo "  restore       Revert to last saved tag"
    echo "  restore <tag> Revert to a specific tag"
    echo "  drop <tag>    Remove a rollback tag"
    ;;
esac
