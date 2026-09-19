#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)"
FIXTURES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/fixtures" && pwd)"

# Keep generated config caches away from the user's cache
XDG_CACHE_HOME="$(mktemp -d)"
export XDG_CACHE_HOME
source "$SCRIPT_DIR/tmux-nerd-font-window-name"

tear_down() {
    unset TMUX_NERD_FONT_USER_CONFIG
}

function test_empty_fallback_with_left_icon_shows_only_name() {
    export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/empty-fallback-left.yml"
    assert_equals "unknown-command" "$(main unknown-command 1)"
}

function test_empty_fallback_with_right_icon_shows_only_name() {
    export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/empty-fallback-right.yml"
    assert_equals "unknown-command" "$(main unknown-command 1)"
}

function test_empty_fallback_without_name_outputs_nothing() {
    export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/empty-fallback-hidden.yml"
    assert_empty "$(main unknown-command 1)"
}

function test_empty_fallback_with_always_show_name_shows_only_name() {
    export TMUX_NERD_FONT_USER_CONFIG="$FIXTURES_DIR/empty-fallback-always-name.yml"
    assert_equals "unknown-command" "$(main unknown-command 1)"
}
