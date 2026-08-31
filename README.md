# git-strip-coauthor

Agents (Cursor, Claude, Copilot, and others) append a `Co-authored-by:` trailer to commits they create. Some hosts and teams reject that line. `--no-verify` does not help you here: the runtime adds the trailer after your message, and `--no-verify` only skips `pre-commit` and `commit-msg`.

This repo installs two **global** Git hooks that delete every `Co-authored-by:` line from the message **before** Git writes the commit object.

- `prepare-commit-msg` still runs under `--no-verify`
- `commit-msg` strips again after the editor
- Any process that calls `git commit` on that Unix account is covered: agents, GUIs, you

It does not reject the commit. The commit succeeds. The trailer is gone.

## Install

Needs `git` and a POSIX `sh`. No Node, no leftover leftover, no extra packages.

```sh
git clone https://github.com/dalpat/git-strip-coauthor.git
cd git-strip-coauthor
./install.sh
```

`install.sh` will:

1. Use your existing `core.hooksPath`, or set it to `~/.config/git/hooks` if unset
2. Copy `hooks/git-strip-coauthor.sh` into that directory
3. Prepend a marked block to `prepare-commit-msg` and `commit-msg`

Existing hook code (lefthook, lint-staged, a company `commit-msg`) is left in place. Running install twice is a no-op.

```sh
./test.sh
```

That creates a throwaway repo, commits with `--no-verify` and a Cursor trailer, and fails if the trailer is still on the commit.

## Uninstall

```sh
cd git-strip-coauthor
./uninstall.sh
```

Removes only the marked blocks and the helper script. `core.hooksPath` is not cleared, so your other global hooks keep running.

## What is stripped

Any commit-message line that matches:

```
^[[:space:]]*co-authored-by:
```

Case is ignored. The rest of the message is unchanged. `Signed-off-by:` and other trailers are not touched.

## What this does not catch

These never run the hooks:

| Path | Why |
| --- | --- |
| `git -c core.hooksPath=/tmp commit` | Hooks directory overridden |
| `git commit-tree` | Plumbing; no commit hooks |
| GitHub / Bitbucket / GitLab web or API | No local `git commit` |

A host-side ruleset is still required if you need the remote to refuse the trailer. This project only covers the machine that runs `git`.

## Why not a `commit-msg` reject?

A rejecting `commit-msg` is what most people try first. `--no-verify` skips it, so the agent commit still lands with the trailer. `prepare-commit-msg` is the hook Git still runs in that case. This project strips there, so the commit goes through and the line never exists.

## Layout

```
hooks/git-strip-coauthor.sh   # shared strip function
hooks/prepare-commit-msg      # runs even with --no-verify
hooks/commit-msg              # second pass after the editor
install.sh
uninstall.sh
test.sh
```
