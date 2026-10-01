#!/usr/bin/env bash
#
# run-tests.sh - run the bats test suite.
#
# Resolves a bats executable in this order:
#   1. `bats` already on PATH
#   2. a previously bootstrapped copy at tests/bats/bin/bats
#   3. a fresh shallow clone of bats-core into tests/bats (gitignored)
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="${ROOT_DIR}/tests"
VENDORED_BATS="${TESTS_DIR}/bats/bin/bats"

if command -v bats >/dev/null 2>&1; then
  BATS="bats"
elif [[ -x "${VENDORED_BATS}" ]]; then
  BATS="${VENDORED_BATS}"
else
  echo "bats not found; cloning bats-core into tests/bats ..."
  git clone --depth 1 https://github.com/bats-core/bats-core.git "${TESTS_DIR}/bats"
  BATS="${VENDORED_BATS}"
fi

echo "Using bats: ${BATS}"
exec "${BATS}" "${TESTS_DIR}"
