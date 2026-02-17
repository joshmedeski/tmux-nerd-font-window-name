#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)"
FORMAT_SCRIPT="$SCRIPT_DIR/generate-tmux-format"
FIXTURES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/fixtures" && pwd)"
DEFAULTS="$SCRIPT_DIR/defaults.yml"

# Source the scripts to make functions available
source "$FORMAT_SCRIPT"

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

# --- Icon-only format (no show-name) ---

function test_format_contains_known_icon_conditional() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/no-show-name.yml"
  local output
  output="$(generate_format)"
  local nvim_icon
  nvim_icon="$(get_default_icon nvim)"
  assert_contains "#{?#{==:#{pane_current_command},nvim},$nvim_icon," "$output"
}

function test_format_no_show_name_has_fallback_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/no-show-name.yml"
  local output
  output="$(generate_format)"
  assert_contains ",?}" "$output"
}

function test_format_no_show_name_does_not_append_command_name() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/no-show-name.yml"
  local output
  output="$(generate_format)"
  assert_not_contains "} #{pane_current_command}" "$output"
}

# --- show-name with icon-position ---

function test_format_show_name_left_appends_command_name() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/show-name-left.yml"
  local output
  output="$(generate_format)"
  # Format should end with #{pane_current_command}
  local suffix
  suffix="${output: -24}"
  assert_equals " #{pane_current_command}" "$suffix"
}

function test_format_show_name_right_prepends_command_name() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/show-name-right.yml"
  local output
  output="$(generate_format)"
  # Format should start with #{pane_current_command}
  local prefix
  prefix="${output:0:25}"
  assert_equals "#{pane_current_command} #" "$prefix"
}

# --- always-show-fallback-name ---

function test_format_fallback_name_left_includes_name_in_fallback() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/fallback-name.yml"
  local output
  output="$(generate_format)"
  # Fallback should be "? #{pane_current_command}" (icon left, then name)
  assert_contains "? #{pane_current_command}}" "$output"
}

function test_format_fallback_name_right_includes_name_in_fallback() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/fallback-name-right.yml"
  local output
  output="$(generate_format)"
  # Fallback should be "#{pane_current_command} ?" (name left, then icon)
  assert_contains "#{pane_current_command} ?}" "$output"
}

function test_format_fallback_name_known_icon_has_no_name() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/fallback-name.yml"
  local output
  output="$(generate_format)"
  local nvim_icon
  nvim_icon="$(get_default_icon nvim)"
  # Known icon branch should just have the icon, no #{pane_current_command} next to it
  assert_contains "nvim},$nvim_icon," "$output"
}

# --- Multi-pane prefix ---

function test_format_multi_pane_prefix() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/multi-pane.yml"
  local output
  output="$(generate_format)"
  assert_contains "#{?#{>:#{window_panes},1},M ,}#{?#{==:" "$output"
}

function test_format_no_multi_pane_without_config() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/no-show-name.yml"
  local output
  output="$(generate_format)"
  assert_not_contains "#{window_panes}" "$output"
}

# --- User config overrides ---

function test_format_user_override_replaces_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/override.yml"
  local output
  output="$(generate_format)"
  assert_contains "nvim},CUSTOM," "$output"
}

function test_format_user_override_replaces_fallback() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/override.yml"
  local output
  output="$(generate_format)"
  assert_contains ",X}" "$output"
}

# --- Multiple icons present ---

function test_format_contains_bash_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/no-show-name.yml"
  local output
  output="$(generate_format)"
  local bash_icon
  bash_icon="$(get_default_icon bash)"
  assert_contains "bash},$bash_icon," "$output"
}

function test_format_contains_git_icon() {
  export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/no-show-name.yml"
  local output
  output="$(generate_format)"
  local git_icon
  git_icon="$(get_default_icon git)"
  assert_contains "git},$git_icon," "$output"
}

# --- No user config file ---

function test_format_no_user_config_uses_defaults() {
  export TMUX_NERD_FONT_USER_CONFIG="/nonexistent/path/config.yml"
  local output
  output="$(generate_format)"
  # Default show-name is true, so should end with #{pane_current_command}
  local suffix
  suffix="${output: -24}"
  assert_equals " #{pane_current_command}" "$suffix"
}
