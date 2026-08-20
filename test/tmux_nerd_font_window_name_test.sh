#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)"
SCRIPT="$SCRIPT_DIR/tmux-nerd-font-window-name"
FIXTURES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/fixtures" && pwd)"
DEFAULTS="$SCRIPT_DIR/defaults.yml"

# Keep the config cache away from the user's real cache directory
export XDG_CACHE_HOME="$(mktemp -d)"

# Source the script to make main() available for coverage tracking
source "$SCRIPT"

# Helper: get expected icon from defaults.yml
get_default_icon() {
  get_yaml_value icons "$1" "$DEFAULTS"
}

set_up() {
  _ORIGINAL_PATH="$PATH"
}

tear_down() {
  PATH="$_ORIGINAL_PATH"
  unset TMUX_NERD_FONT_USER_CONFIG
}

# --- Icon lookup ---

function test_known_command_returns_its_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/no-show-name.yml"
  output="$(main nvim 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  expected="$(get_default_icon nvim)"
  assert_equals "$expected" "$output"
}

function test_unknown_command_returns_fallback_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/no-show-name.yml"
  output="$(main some-unknown-program 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "?" "$output"
}

# --- show-name with icon-position ---

function test_show_name_left_icon_before_name() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/show-name-left.yml"
  output="$(main nvim 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  expected="$(get_default_icon nvim) nvim"
  assert_equals "$expected" "$output"
}

function test_show_name_right_name_before_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/show-name-right.yml"
  output="$(main nvim 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  expected="nvim $(get_default_icon nvim)"
  assert_equals "$expected" "$output"
}

function test_show_name_with_unknown_command_shows_fallback_icon_and_name() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/show-name-left.yml"
  output="$(main some-unknown-program 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "? some-unknown-program" "$output"
}

# --- always-show-fallback-name ---

function test_always_show_fallback_name_unknown_command_shows_name_left() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/fallback-name.yml"
  output="$(main some-unknown-program 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "? some-unknown-program" "$output"
}

function test_always_show_fallback_name_known_command_stays_icon_only() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/fallback-name.yml"
  output="$(main nvim 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  expected="$(get_default_icon nvim)"
  assert_equals "$expected" "$output"
}

function test_always_show_fallback_name_respects_icon_position_right() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/fallback-name-right.yml"
  output="$(main some-unknown-program 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "some-unknown-program ?" "$output"
}

# --- Multi-pane ---

function test_multi_pane_prepends_icon_when_panes_greater_than_1() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/multi-pane.yml"
  output="$(main nvim 2 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  expected="M $(get_default_icon nvim)"
  assert_equals "$expected" "$output"
}

function test_multi_pane_no_prefix_for_single_pane() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/multi-pane.yml"
  output="$(main nvim 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  expected="$(get_default_icon nvim)"
  assert_equals "$expected" "$output"
}

# --- User config override ---

function test_user_config_overrides_default_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/override.yml"
  output="$(main nvim 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "CUSTOM" "$output"
}

function test_user_config_overrides_fallback_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/override.yml"
  output="$(main some-unknown-program 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "X" "$output"
}

# --- Edge cases ---

function test_no_user_config_file_falls_back_to_defaults() {
  export TMUX_NERD_FONT_USER_CONFIG="/nonexistent/path/config.yml"
  output="$(main nvim 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  expected="$(get_default_icon nvim) nvim"
  assert_equals "$expected" "$output"
}

function test_fallback_name_disabled_unknown_command_shows_only_fallback_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/no-show-name.yml"
  output="$(main some-unknown-program 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "?" "$output"
}

# --- Semantic version matching ---

function test_semver_three_part_returns_sem_version_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/sem-version.yml"
  output="$(main 2.1.23 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "V" "$output"
}

function test_semver_two_part_returns_sem_version_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/sem-version.yml"
  output="$(main 1.0 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "V" "$output"
}

function test_semver_not_matched_for_non_version() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/sem-version.yml"
  output="$(main node 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  expected="$(get_default_icon node)"
  assert_equals "$expected" "$output"
}

function test_semver_falls_to_fallback_when_not_configured() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/no-show-name.yml"
  output="$(main 2.1.23 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "?" "$output"
}

function test_semver_with_show_name() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/sem-version-show-name.yml"
  output="$(main 2.1.23 1 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "V 2.1.23" "$output"
}

# --- regex matching (names-regex / icons-regex) ---

spawn_fake_child() {
  bash -c 'exec -a "npm run dev" sleep 5' &
  _FAKE_CHILD_PID=$!
  sleep 0.2
}

kill_fake_child() {
  kill "$_FAKE_CHILD_PID" 2>/dev/null
  wait "$_FAKE_CHILD_PID" 2>/dev/null
}

function test_regex_icon_beats_exact_icon_lookup() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/icons-regex.yml"
  # capture BASHPID BEFORE the $() 
  # BASHPID is the substitution's own subshell, not this test shell
  local pid="$BASHPID"
  spawn_fake_child
  output="$(main npm 1 "$pid" 2>&1)" && exit_code=$? || exit_code=$?
  kill_fake_child
  (exit "$exit_code"); assert_successful_code
  assert_equals "D" "$output"
}

function test_exact_icon_used_when_no_child_matches_regex() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/icons-regex.yml"
  # no fake child spawned: nothing for the regex to match
  local pid="$BASHPID"
  output="$(main npm 1 "$pid" 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "N" "$output"
}

function test_names_regex_renames_and_resolves_icon_from_new_name() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/names-regex.yml"
  local pid="$BASHPID"
  spawn_fake_child
  output="$(main npm 1 "$pid" 2>&1)" && exit_code=$? || exit_code=$?
  kill_fake_child
  (exit "$exit_code"); assert_successful_code
  assert_equals "D devserver" "$output"
}

function test_regex_ignored_when_pane_pid_empty() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/icons-regex.yml"
  output="$(main npm 1 "" 2>&1)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_equals "N" "$output"
}
