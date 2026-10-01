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

## Testing / Development

The scripts are covered by a [bats](https://github.com/bats-core/bats-core) test
suite under [`tests/`](tests). Run it with:

```sh
./run-tests.sh
```

`run-tests.sh` uses `bats` if it is on your `PATH`; otherwise it shallow-clones
bats-core into `tests/bats/` (gitignored) and uses that, so no manual setup is
required.

Each test runs the script against a throwaway git fixture that has its own
**local bare repo as `origin`** — pushes, pulls, and tags stay entirely local,
nothing hits a real remote, and your real repo and git config are never touched.
The suite covers, per script:

- `gnb`: builds `<type>/<name>`, hyphenates spaces, trims whitespace, and
  rejects empty input.
- `gnc`: stages all changes (including untracked files), commits with the given
  message, pushes the current branch to `origin`, and refuses a clean tree,
  an empty message, or a detached HEAD.
- `gnr`: detects the default branch (verified on a `main`-based repo), reports
  the latest tag, and creates and pushes an annotated `v<version>` tag only
  after confirmation.

CI (GitHub Actions, [`.github/workflows/ci.yml`](.github/workflows/ci.yml)) runs
`shellcheck` on `bin/*`, `install.sh`, and `run-tests.sh`, and runs the bats
suite on every push and pull request.

## Notes

- All scripts use `set -euo pipefail`, quote their expansions, and read input with `read -r`.
- `gnr` auto-detects the default branch, so it works on both `main` and `master` repos.

## Removed

- **`gpl`** ("git pull") was removed — it only pulled the current branch, which plain `git pull` already does (git pulls the current branch's upstream by default). If you want a shortcut, add a git alias instead:

  ```sh
  git config --global alias.pl pull
  ```

  Then `git pl` does the same thing with no script to maintain.
