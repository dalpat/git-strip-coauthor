#!/bin/sh
# Install global Git hooks that strip Co-authored-by from every commit.
# Safe to run from a clone, or piped: curl -fsSL …/install.sh | sh
#
# If core.hooksPath is already set, hooks are merged into that directory.
set -eu

write_helper() {
  dest_helper=$1
  cat > "$dest_helper" <<'EOF'
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
EOF
  chmod +x "$dest_helper"
}

existing=$(git config --global --get core.hooksPath || true)
if [ -n "$existing" ]; then
  dest=$existing
  case $dest in
    ~/*) dest=$HOME/${dest#~/} ;;
  esac
else
  dest=$HOME/.config/git/hooks
  mkdir -p "$dest"
  git config --global core.hooksPath "$dest"
fi

mkdir -p "$dest"
write_helper "$dest/git-strip-coauthor.sh"

snippet() {
  cat <<'EOF'
# git-strip-coauthor:start
. "$(dirname "$0")/git-strip-coauthor.sh"
git_strip_coauthored_by "$1"
# git-strip-coauthor:end
EOF
}

ensure_hook() {
  name=$1
  hook=$dest/$name
  if [ -f "$hook" ] && grep -q 'git-strip-coauthor:start' "$hook"; then
    return 0
  fi
  if [ ! -f "$hook" ]; then
    printf '%s\n' '#!/bin/sh' > "$hook"
    snippet >> "$hook"
    chmod +x "$hook"
    return 0
  fi
  tmp=$(mktemp)
  if head -n 1 "$hook" | grep -q '^#!'; then
    head -n 1 "$hook" > "$tmp"
    snippet >> "$tmp"
    tail -n +2 "$hook" >> "$tmp"
  else
    printf '%s\n' '#!/bin/sh' > "$tmp"
    snippet >> "$tmp"
    cat "$hook" >> "$tmp"
  fi
  mv "$tmp" "$hook"
  chmod +x "$hook"
}

ensure_hook prepare-commit-msg
ensure_hook commit-msg

echo "Installed into $dest"
echo "core.hooksPath=$(git config --global --get core.hooksPath)"
echo "Any git commit on this account is stripped, including --no-verify."
