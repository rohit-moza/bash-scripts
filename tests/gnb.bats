#!/usr/bin/env bats
#
# Tests for bin/gnb (git new branch).

load test_helper

setup() {
  make_fixture master
}

teardown() {
  teardown_fixture
}

@test "gnb creates and checks out <type>/<name>" {
  run_script "${GNB}" "feature" "login"
  [ "${status}" -eq 0 ]
  [ "$(git branch --show-current)" = "feature/login" ]
}

@test "gnb reports the branch it creates" {
  run_script "${GNB}" "bugfix" "crash"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Creating branch: bugfix/crash"* ]]
}

@test "gnb normalises spaces in the name to hyphens" {
  run_script "${GNB}" "feature" "add new thing"
  [ "${status}" -eq 0 ]
  [ "$(git branch --show-current)" = "feature/add-new-thing" ]
}

@test "gnb trims surrounding whitespace before building the branch name" {
  run_script "${GNB}" "  feature  " "  shiny  "
  [ "${status}" -eq 0 ]
  [ "$(git branch --show-current)" = "feature/shiny" ]
}

@test "gnb rejects an empty branch type" {
  run_script "${GNB}" "" "login"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"required"* ]]
  # Still on the default branch; nothing was created.
  [ "$(git branch --show-current)" = "master" ]
}

@test "gnb rejects an empty branch name" {
  run_script "${GNB}" "feature" ""
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"required"* ]]
  [ "$(git branch --show-current)" = "master" ]
}

@test "gnb fails when the branch already exists" {
  git checkout -b feature/dup >/dev/null 2>&1
  git checkout master >/dev/null 2>&1
  run_script "${GNB}" "feature" "dup"
  [ "${status}" -ne 0 ]
}
