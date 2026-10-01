#!/usr/bin/env bash
#
# Shared helpers for the bats test suite.
#
# Every test builds an isolated, network-free git fixture: a LOCAL bare repo
# that acts as "origin" plus a working clone with one commit. Nothing ever
# touches the real repository or the real remote, and the host's global git
# config is replaced with an empty temp file so tests are deterministic.

# Absolute path to the repo root and the scripts under test.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="${REPO_ROOT}/bin"

GNB="${BIN_DIR}/gnb"
GNC="${BIN_DIR}/gnc"
GNR="${BIN_DIR}/gnr"

# make_fixture [default_branch]
#
# Creates a temp area containing:
#   $REMOTE  - a bare repo used as "origin"
#   $WORK    - a working clone with an initial commit on <default_branch>
# Leaves the shell's CWD inside $WORK. Exports GIT_CONFIG_GLOBAL /
# GIT_CONFIG_SYSTEM / HOME so no host git config leaks in.
make_fixture() {
  local default_branch="${1:-master}"

  TEST_TMP="$(mktemp -d "${BATS_TMPDIR:-/tmp}/gnhelpers.XXXXXX")"

  # Fully isolate from host git configuration.
  export HOME="${TEST_TMP}"
  export GIT_CONFIG_GLOBAL="${TEST_TMP}/gitconfig"
  export GIT_CONFIG_SYSTEM=/dev/null
  : > "${GIT_CONFIG_GLOBAL}"

  REMOTE="${TEST_TMP}/remote.git"
  WORK="${TEST_TMP}/work"

  git init --bare -b "${default_branch}" "${REMOTE}" >/dev/null 2>&1

  git clone "${REMOTE}" "${WORK}" >/dev/null 2>&1

  git -C "${WORK}" config user.email "tester@example.com"
  git -C "${WORK}" config user.name "Test User"
  git -C "${WORK}" config commit.gpgsign false
  git -C "${WORK}" config init.defaultBranch "${default_branch}"

  # Make sure the (as-yet unborn) checked-out branch is the requested one.
  git -C "${WORK}" symbolic-ref HEAD "refs/heads/${default_branch}"

  echo "initial" > "${WORK}/README"
  git -C "${WORK}" add README
  git -C "${WORK}" commit -m "initial commit" >/dev/null
  git -C "${WORK}" push -u origin "${default_branch}" >/dev/null 2>&1

  # Record origin/HEAD so gnr's primary detection path has something to read.
  git -C "${WORK}" remote set-head origin "${default_branch}" >/dev/null 2>&1

  cd "${WORK}"
}

# teardown_fixture - remove the temp area created by make_fixture.
teardown_fixture() {
  if [[ -n "${TEST_TMP:-}" && -d "${TEST_TMP}" ]]; then
    rm -rf "${TEST_TMP}"
  fi
}

# run_script <script> [stdin_lines...]
#
# Runs a script with the given lines fed to its interactive `read` prompts,
# one argument per line, in order. Populates bats' $status/$output.
run_script() {
  local script="$1"
  shift
  local input=""
  local line
  for line in "$@"; do
    input+="${line}"$'\n'
  done
  run bash "${script}" <<< "${input}"
}
