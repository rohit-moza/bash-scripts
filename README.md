# bash-scripts

A small personal collection of interactive git-workflow shortcuts.

## Scripts

All scripts live in [`bin/`](bin) and prompt interactively for the values they need.

| Command | Name | What it does |
| ------- | ---- | ------------ |
| `gnb`   | git new branch  | Prompts for a branch type and name, then creates and checks out `<type>/<name>`. |
| `gnc`   | git new commit  | Stages all changes, shows the status, prompts for a message, commits, and pushes the current branch. |
| `gnr`   | git new release | Updates the default branch (auto-detects `main`/`master`), shows the latest release tag, then creates and pushes an annotated `v<version>` tag after confirmation. |

## Install

Symlink the scripts into a directory on your `PATH`:

```sh
./install.sh            # links into ~/.local/bin
./install.sh ~/bin      # or a directory of your choice
```

Make sure the target directory is on your `PATH`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

## Notes

- All scripts use `set -euo pipefail`, quote their expansions, and read input with `read -r`.
- `gnr` auto-detects the default branch, so it works on both `main` and `master` repos.

## Removed

- **`gpl`** ("git pull") was removed — it only pulled the current branch, which plain `git pull` already does (git pulls the current branch's upstream by default). If you want a shortcut, add a git alias instead:

  ```sh
  git config --global alias.pl pull
  ```

  Then `git pl` does the same thing with no script to maintain.
