#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)"
FIXTURE_DIR="$SCRIPT_DIR/../test/fixtures"
DEFAULTS="$SCRIPT_DIR/defaults.yml"

# Source the scripts to make functions available
source "$SCRIPT_DIR/lib.sh"

# Helpers
spawn_fake_child() {
  bash -c 'exec -a "npm run dev" sleep 5' &
  _FAKE_CHILD_PID=$!
  sleep 0.2   # give ps a moment to see it
}

kill_fake_child() {
  kill "$_FAKE_CHILD_PID" 2>/dev/null
  wait "$_FAKE_CHILD_PID" 2>/dev/null
}

function test_shquote_wraps_plain_string_in_single_quotes() {
  assert_equals "'hello'" "$(shquote hello)"
}

function test_shquote_escapes_embedded_single_quote() {
  assert_equals "'don'\''t'" "$(shquote "don't")"
}

function test_shquote_output_survives_eval() {
  local original="it's a \$test \`with\` weird chars"
  local quoted round_tripped
  quoted="$(shquote "$original")"
  eval "evaluated=$quoted"
  assert_equals "$original" "$evaluated"
}

function test_yaml_section_pairs_extracts_tab_separated_pairs() {
  local out
  out="$(yaml_section_pairs icons "$FIXTURE_DIR/pairs.yml")"
  assert_contains "$(printf 'nvim\tN')" "$out"
}

function test_yaml_section_pairs_strips_comments() {
  local out
  out="$(yaml_section_pairs icons "$FIXTURE_DIR/pairs.yml")"
  assert_contains "$(printf 'ssh\tS')" "$out"
}

function test_yaml_section_pairs_strips_surrounding_quotes() {
  local out
  out="$(yaml_section_pairs icons "$FIXTURE_DIR/pairs.yml")"
  assert_contains "$(printf 'quoted-key\tquoted-val')" "$out"
}

function test_merged_pairs_user_value_overrides_default() {
  local out
  out="$(merged_section_pairs icons "$FIXTURE_DIR/merge.yml")"
  assert_contains "$(printf 'nvim\tOVERRIDDEN')" "$out"
}

function test_merged_pairs_keeps_user_only_key() {
  local out
  out="$(merged_section_pairs icons "$FIXTURE_DIR/merge.yml")"
  assert_contains "$(printf 'my-own-tool\tM')" "$out"
}

function test_merged_pairs_keeps_default_only_key() {
  local out expected_ssh
  out="$(merged_section_pairs icons "$FIXTURE_DIR/merge.yml")"
  expected_ssh="$(get_yaml_value icons ssh "$DEFAULTS")"
  assert_contains "$(printf 'ssh\t%s' "$expected_ssh")" "$out"
}

function test_match_cached_regex_returns_value_of_matching_pattern() {
  REGEX_TEST_PATTERNS=('python.*jiratui')
  REGEX_TEST_VALUES=('J')
  assert_equals "J" "$(match_cached_regex REGEX_TEST "python3 /usr/bin/jiratui ui")"
}

function test_match_cached_regex_first_match_wins_in_order() {
  REGEX_TEST_PATTERNS=('python.*' 'python.*jiratui')
  REGEX_TEST_VALUES=('FIRST' 'SECOND')
  assert_equals "FIRST" "$(match_cached_regex REGEX_TEST "python3 jiratui")"
}

function test_match_cached_regex_no_match_returns_empty() {
  REGEX_TEST_PATTERNS=('node.*codex')
  REGEX_TEST_VALUES=('C')
  assert_empty "$(match_cached_regex REGEX_TEST "python3 jiratui")"
}

function test_match_cached_regex_supports_ere_syntax() {
  REGEX_TEST_PATTERNS=('^(npm|yarn) (run )?dev$')
  REGEX_TEST_VALUES=('D')
  assert_equals "D" "$(match_cached_regex REGEX_TEST "npm run dev")"
  assert_equals "D" "$(match_cached_regex REGEX_TEST "yarn dev")"
}

function test_match_cached_regex_empty_arrays_return_empty() {
  REGEX_EMPTY_PATTERNS=()
  REGEX_EMPTY_VALUES=()
  assert_empty "$(match_cached_regex REGEX_EMPTY "anything")"
}

function test_child_cmdlines_returns_matching_child_cmdline() {
  local pid="$BASHPID"
  spawn_fake_child
  local out
  out="$(child_cmdlines npm "$pid")"
  kill_fake_child
  assert_contains "npm run dev" "$out"
}

function test_child_cmdlines_filters_non_matching_command() {
  local pid="$BASHPID"
  spawn_fake_child
  local out
  out="$(child_cmdlines zsh "$pid")"
  kill_fake_child
  assert_not_contains "npm run dev" "$out"
}

function test_child_cmdlines_no_children_outputs_nothing_and_succeeds() {
  local out exit_code
  out="$(child_cmdlines npm 999999999)" && exit_code=$? || exit_code=$?
  (exit "$exit_code"); assert_successful_code
  assert_empty "$out"
}
