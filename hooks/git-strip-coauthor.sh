#!/bin/sh
# Shared by prepare-commit-msg and commit-msg.
# Removes Co-authored-by trailer lines from a commit message file.

git_strip_coauthored_by() {
  msg=$1
  [ -n "$msg" ] && [ -f "$msg" ] || return 0
  grep -qiE '^[[:space:]]*co-authored-by:' "$msg" || return 0
  tmp=$(mktemp)
  grep -viE '^[[:space:]]*co-authored-by:' "$msg" > "$tmp" || true
  mv "$tmp" "$msg"
}
