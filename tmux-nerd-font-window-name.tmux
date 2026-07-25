#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR//bin/lib.sh"
source "$CURRENT_DIR//bin/cache-config"

user_config="${TMUX_NERD_FONT_USER_CONFIG:-$USER_CONFIG}"
generate_cache "$user_config"

plugin_format="#($CURRENT_DIR/bin/tmux-nerd-font-window-name '#{pane_current_command}' '#{window_panes}' '#{pane_pid}' '#{window_id}')"
user_format="$(tmux show-option -gv automatic-rename-format 2>/dev/null)"
placeholder="#{window_icon}"

if [[ -n "$user_format" && "$user_format" == *"$placeholder"* ]]; then
    new_format="${user_format//$placeholder/$plugin_format}"
    tmux set-option -g @tmux-nerd-font-window-name-template "$user_format"
else
    new_format="$plugin_format"
    tmux set-option -gu @tmux-nerd-font-window-name-template 2>/dev/null
fi

tmux set-option -g automatic-rename-format "$new_format"
