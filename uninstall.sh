#!/bin/sh
# Remove git-strip-coauthor from the current global hooksPath.
# Leaves other hook code (lefthook, etc.) in place.
set -eu

dest=$(git config --global --get core.hooksPath || true)
if [ -z "$dest" ]; then
  echo "No global core.hooksPath; nothing to uninstall."
  exit 0
fi
case $dest in
  ~/*) dest=$HOME/${dest#~/} ;;
esac

strip_block() {
  hook=$1
  [ -f "$hook" ] || return 0
  tmp=$(mktemp)
  awk '
    /# git-strip-coauthor:start/ { skip=1; next }
    /# git-strip-coauthor:end/ { skip=0; next }
    !skip { print }
  ' "$hook" > "$tmp"
  # Drop a hook that is only a shebang after uninstall.
  if [ "$(grep -cvE '^[[:space:]]*$|^#!' "$tmp")" -eq 0 ]; then
    rm -f "$hook" "$tmp"
    return 0
  fi
  mv "$tmp" "$hook"
}

strip_block "$dest/prepare-commit-msg"
strip_block "$dest/commit-msg"
rm -f "$dest/git-strip-coauthor.sh"

echo "Removed git-strip-coauthor from $dest"
echo "core.hooksPath is unchanged."
