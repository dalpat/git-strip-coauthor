# git-strip-coauthor

Global Git hooks that delete `Co-authored-by:` lines from the commit message before the commit object is created.

Works for every tool that runs `git commit` on that account: Cursor, Claude, Copilot, a human. `--no-verify` does not skip `prepare-commit-msg`.

## Install

```sh
git clone <this-repo> ~/development/ai/git-strip-coauthor
cd ~/development/ai/git-strip-coauthor
./install.sh
```

Install copies the helper into your existing `core.hooksPath` (or `~/.config/git/hooks` if unset) and prepends a small block to `prepare-commit-msg` and `commit-msg`. Other hook code is left alone.

```sh
./test.sh
./uninstall.sh
```

## What it does not catch

- `git -c core.hooksPath=/tmp commit`
- `git commit-tree`
- Commits created through a host API (GitHub, Bitbucket) instead of local `git`
