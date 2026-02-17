#!/usr/bin/env bash

DEFAULT_CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/defaults.yml"

# Allow overriding user config path via tmux option
USER_CONFIG=$(tmux show-option -gqv @tmux-nerd-font-window-name-config-file)
USER_CONFIG=${USER_CONFIG:-"$HOME/.config/tmux/tmux-nerd-font-window-name.yml"}

# Parse a value from a flat YAML file (section + key lookup, POSIX awk)
get_yaml_value() {
  local section="$1"
  local key="$2"
  local file="$3"
  awk -v section="$section" -v key="$key" '
    /^[^ #]/ { current = $0; sub(/:.*/, "", current) }
    current == section {
      if ($0 ~ "^  " key ":") {
        val = $0
        sub(/^[^:]*: */, "", val)
        gsub(/^["'\''"]|["'\''"]$/, "", val)
        print val
        found = 1
        exit
      }
    }
    END { if (!found) print "null" }
  ' "$file"
}

# Function to retrieve a configuration value
get_config_value() {
  local section="$1"
  local key="$2"
  local config="$3"
  local value=""
  if [ -f "$config" ]; then
    value="$(get_yaml_value "$section" "$key" "$config")"
    if [ "$value" == "null" ]; then
      value="$(get_yaml_value "$section" "$key" "$DEFAULT_CONFIG")"
    fi
  else
    value="$(get_yaml_value "$section" "$key" "$DEFAULT_CONFIG")"
  fi
  echo "$value"
}
