#!/usr/bin/env bash

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENTRY_POINT="$PLUGIN_DIR/tmux-nerd-font-window-name.tmux"
FIXTURES_DIR="$PLUGIN_DIR/test/fixtures"

# Keep the config cache away from the user's real cache directory
export XDG_CACHE_HOME="$(mktemp -d)"

# Run the entry point against a fake tmux that records every call and reports
# $FAKE_USER_FORMAT as the existing automatic-rename-format
run_entry_point() {
  local user_format="$1"
  local pid="$BASHPID"
  local stub_dir="$XDG_CACHE_HOME/stub-$pid"
  mkdir -p "$stub_dir"
  TMUX_CALLS="$XDG_CACHE_HOME/calls-$pid"
  : >"$TMUX_CALLS"

  cat >"$stub_dir/tmux" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TMUX_CALLS"
if [ "$1 $2 $3" = "show-option -gv automatic-rename-format" ]; then
  printf '%s\n' "$FAKE_USER_FORMAT"
fi
exit 0
STUB
  chmod +x "$stub_dir/tmux"

  PATH="$stub_dir:$PATH" \
    TMUX_CALLS="$TMUX_CALLS" \
    FAKE_USER_FORMAT="$user_format" \
    TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/no-show-name.yml" \
    bash "$ENTRY_POINT"
}

# The format the entry point handed to `tmux set-option -g automatic-rename-format`
set_format() {
  grep '^set-option -g automatic-rename-format ' "$TMUX_CALLS" |
    tail -1 | sed 's|^set-option -g automatic-rename-format ||'
}

set_up() {
  _ORIGINAL_PATH="$PATH"
}

tear_down() {
  PATH="$_ORIGINAL_PATH"
}

# --- Async job fallback ---

function test_format_falls_back_while_job_is_not_ready() {
  run_entry_point ""
  # tmux substitutes "<'<command>' not ready>" after one second of job runtime
  assert_contains '#{?#{m:*not ready*,#(' "$(set_format)"
}

function test_format_falls_back_while_job_output_is_empty() {
  run_entry_point ""
  # A job with no output yet expands to nothing, which would blank the name
  assert_contains ")},#{pane_current_command},#{?#(" "$(set_format)"
}

function test_format_ends_with_the_job_and_its_fallback() {
  run_entry_point ""
  assert_contains ",#{pane_current_command}}}" "$(set_format)"
}

# --- User template ---

function test_user_template_keeps_the_fallback_around_the_job() {
  run_entry_point "#{window_icon} #{b:pane_current_path}"
  local format
  format="$(set_format)"
  assert_contains '#{?#{m:*not ready*,#(' "$format"
  assert_contains ' #{b:pane_current_path}' "$format"
}

function test_user_template_is_saved_for_the_rename_self_heal() {
  run_entry_point "#{window_icon} #{b:pane_current_path}"
  assert_contains \
    'set-option -g @tmux-nerd-font-window-name-template #{window_icon} #{b:pane_current_path}' \
    "$(cat "$TMUX_CALLS")"
}
