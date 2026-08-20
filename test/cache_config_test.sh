#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)"
FIXTURES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/fixtures" && pwd)"
DEFAULTS="$SCRIPT_DIR/defaults.yml"

# MUST be set before sourcing
export XDG_CACHE_HOME="$(mktemp -d)"

source "$SCRIPT_DIR/cache-config"

# --- generate_cache output ---

function test_generated_cache_is_valid_bash() {
  generate_cache "$FIXTURES_DIR/merge.yml"
  local exit_code
  bash -n "$CACHE_FILE" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
}

function test_generated_cache_records_source_config() {
  generate_cache "$FIXTURES_DIR/merge.yml"
  load_cache
  assert_equals "$FIXTURES_DIR/merge.yml" "$CACHE_SOURCE_CONFIG"
}

# --- generate_cache content ---

function test_cache_icon_for_returns_user_override() {
  generate_cache "$FIXTURES_DIR/merge.yml"
  load_cache
  assert_equals "OVERRIDDEN" "$(icon_for nvim)"
}

function test_cache_icon_for_falls_back_to_defaults() {
  generate_cache "$FIXTURES_DIR/merge.yml"
  load_cache
  assert_equals "$(get_yaml_value icons ssh "$DEFAULTS")" "$(icon_for ssh)"
}

function test_cache_icon_for_unknown_returns_null() {
  generate_cache "$FIXTURES_DIR/merge.yml"
  load_cache
  assert_equals "null" "$(icon_for definitely-not-a-command)"
}

function test_cache_regex_arrays_preserve_file_order() {
  generate_cache "$FIXTURES_DIR/icons-regex.yml"
  load_cache
  assert_equals "npm.*dev" "${REGEX_ICONS_PATTERNS[0]}"
  assert_equals "D" "${REGEX_ICONS_VALUES[0]}"
}

# --- load_cache state reset ---

function test_load_cache_clears_values_from_previous_config() {
  generate_cache "$FIXTURES_DIR/icons-regex.yml"
  load_cache
  assert_equals "1" "${#REGEX_ICONS_PATTERNS[@]}"

  generate_cache "$FIXTURES_DIR/merge.yml"
  load_cache
  assert_equals "0" "${#REGEX_ICONS_PATTERNS[@]}"
}

function test_load_cache_fails_when_cache_file_missing() {
  rm -f "$CACHE_FILE"
  local exit_code
  load_cache && exit_code=$? || exit_code=$?
  assert_equals "1" "$([ "$exit_code" -ne 0 ] && echo 1)"
}
