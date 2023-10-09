#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmux set-option -g automatic-rename-format "#($CURRENT_DIR/bin/tmux-nerd-font-window-name #{pane_current_command} #{window_panes})"
