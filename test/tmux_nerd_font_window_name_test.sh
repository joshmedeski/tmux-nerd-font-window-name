#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)"
SCRIPT="$SCRIPT_DIR/tmux-nerd-font-window-name"
FIXTURES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/fixtures" && pwd)"
DEFAULTS="$SCRIPT_DIR/defaults.yml"

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
