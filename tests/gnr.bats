#!/usr/bin/env bats
#
# Tests for bin/gnr (git new release).
#
# The fixture uses a "main" default branch to prove gnr is branch-agnostic
# rather than hardcoded to master.

load test_helper

setup() {
  make_fixture main
  # Seed an existing release tag so gnr can report the current release.
  git tag -a v0.1.0 -m "Release v0.1.0" >/dev/null
  git push origin v0.1.0 >/dev/null 2>&1
}

teardown() {
  teardown_fixture
}

@test "gnr creates and pushes an annotated v<version> tag on a main-based repo" {
  run_script "${GNR}" "1.0.0" "y"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Released v1.0.0"* ]]

  # Annotated tag exists locally.
  run git cat-file -t v1.0.0
  [ "${status}" -eq 0 ]
  [ "${output}" = "tag" ]

  # Tag was pushed to origin.
  run git -C "${REMOTE}" rev-parse --verify v1.0.0
  [ "${status}" -eq 0 ]
}

@test "gnr operates on the main branch (branch-agnostic, not hardcoded master)" {
  run_script "${GNR}" "1.2.3" "y"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Updating main"* ]]
  [ "$(git branch --show-current)" = "main" ]
}

@test "gnr reports the latest existing release tag" {
  run_script "${GNR}" "0.2.0" "y"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Current release: v0.1.0"* ]]
}

@test "gnr aborts without tagging when confirmation is declined" {
  run_script "${GNR}" "9.9.9" "n"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Aborted"* ]]

  # No tag created locally or on origin.
  run git rev-parse --verify v9.9.9
  [ "${status}" -ne 0 ]
  run git -C "${REMOTE}" rev-parse --verify v9.9.9
  [ "${status}" -ne 0 ]
}

@test "gnr rejects an empty version" {
  run_script "${GNR}" "" "y"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"version is required"* ]]
}
