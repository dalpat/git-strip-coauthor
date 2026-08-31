#!/bin/sh
# Prove prepare-commit-msg strips a trailer even with --no-verify.
set -eu

repo=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

git init -q "$tmp"
git -C "$tmp" config user.email test@example.com
git -C "$tmp" config user.name test
printf 'x\n' > "$tmp/f"
git -C "$tmp" add f

git -C "$tmp" -c core.hooksPath="$repo/hooks" commit --no-verify -m "$(
  printf '%s\n' 'test strip' '' 'Co-authored-by: Cursor <cursoragent@cursor.com>'
)" >/dev/null

msg=$(git -C "$tmp" log -1 --format=%B)
if printf '%s\n' "$msg" | grep -qiE '^[[:space:]]*co-authored-by:'; then
  echo "FAIL: trailer survived --no-verify"
  printf '%s\n' "$msg"
  exit 1
fi
printf '%s\n' "$msg" | grep -qx 'test strip' || {
  echo "FAIL: subject missing"
  printf '%s\n' "$msg"
  exit 1
}

echo "OK: trailer stripped under --no-verify"
