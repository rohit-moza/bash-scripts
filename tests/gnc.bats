#!/usr/bin/env bats
#
# Tests for bin/gnc (git new commit).

load test_helper

setup() {
  make_fixture master
}

teardown() {
  teardown_fixture
}

@test "gnc stages, commits with the message, and pushes the current branch" {
  echo "change" > file.txt

  run_script "${GNC}" "Add file.txt"
  [ "${status}" -eq 0 ]

  # Local HEAD carries the entered message.
  [ "$(git log -1 --pretty=%s)" = "Add file.txt" ]

  # The commit reached origin on the same branch.
  run git -C "${REMOTE}" log -1 --pretty=%s master
  [ "${status}" -eq 0 ]
  [ "${output}" = "Add file.txt" ]
}

@test "gnc commits untracked files (git add --all)" {
  echo "new" > brand_new.txt

  run_script "${GNC}" "Track new file"
  [ "${status}" -eq 0 ]

  run git ls-files --error-unmatch brand_new.txt
  [ "${status}" -eq 0 ]
}

@test "gnc pushes the feature branch it is run on, not master" {
  git checkout -b feature/x >/dev/null 2>&1
  echo "work" > work.txt

  run_script "${GNC}" "Work on feature"
  [ "${status}" -eq 0 ]

  # Branch exists on origin with our commit.
  run git -C "${REMOTE}" log -1 --pretty=%s feature/x
  [ "${status}" -eq 0 ]
  [ "${output}" = "Work on feature" ]
}

@test "gnc refuses to commit a clean working tree" {
  run_script "${GNC}" "Nothing here"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"nothing to commit"* ]]
}

@test "gnc rejects an empty commit message" {
  echo "change" > file.txt

  run_script "${GNC}" ""
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"commit message is required"* ]]

  # Nothing was committed on top of the initial commit.
  [ "$(git rev-list --count HEAD)" -eq 1 ]
}

@test "gnc refuses to commit from a detached HEAD" {
  echo "change" > file.txt
  git add file.txt >/dev/null
  git commit -m "temp" >/dev/null
  git checkout --detach HEAD >/dev/null 2>&1
  echo "more" > another.txt

  run_script "${GNC}" "Should not work"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"detached HEAD"* ]]
}
