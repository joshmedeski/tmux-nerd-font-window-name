#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

plugin_format="#($CURRENT_DIR/bin/tmux-nerd-font-window-name #{pane_current_command} #{window_panes})"
user_format="$(tmux show-option -gv automatic-rename-format 2>/dev/null)"
placeholder="#{window_icon}"

if [[ -n "$user_format" && "$user_format" == *"$placeholder"* ]]; then
    new_format="${user_format//$placeholder/$plugin_format}"
else
    new_format="$plugin_format"
fi

tmux set-option -g automatic-rename-format "$new_format"
