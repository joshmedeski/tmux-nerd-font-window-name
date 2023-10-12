#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS="yq"
MISSING_PLUGINS_LIST=""

for i in $PLUGINS; do
  if [[ ! $(which $i) ]]; then
    MISSING_PLUGINS_LIST="${MISSING_PLUGINS_LIST}\t- ${i}\n";
  fi;
done
if [[ $MISSING_PLUGINS_LIST != "" ]]; then
    tmux display-popup 'echo "[33mError:[0m\n\
The following dependencies are required for tmux-nerd-font-window-name to work properly:\n\
'"${MISSING_PLUGINS_LIST}"'\n\
Please ensure all dependencies are installed correctly.\n\
[2;3m(Press [0;33;1mESC[0;2;3m key to dismiss)[0m"'
fi

tmux set-option -g automatic-rename-format "#($CURRENT_DIR/bin/tmux-nerd-font-window-name #{pane_current_command} #{window_panes})"
