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
        sub(/ (#.*)$/, "", val)
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

# Function to check if config has section and at least one field in it
config_has_section() {
  local section="$1"
  local config="$2"
  if [ -f "$config" ]; then
    awk -v section="$section" '
      /^[^ #]/ { current=$0; sub(/:.*/, "", current) }
      current == section && /^  [^ #]/ { found = 1; exit }
      END { exit !found }
    ' "$config"
  else
    return 1
  fi
}

merged_section_pairs() {
  local section="$1"
  local user_config="$2"
  {
    yaml_section_pairs "$section" "$DEFAULT_CONFIG"
    yaml_section_pairs "$section" "$user_config"
  } | awk -F'\t' '{ seen[$1] = $2 } END { for (k in seen) printf "%s\t%s\n", k, seen[k] }'
}

# Quote a value so it stays inert data when the generated cache is sourced:
# wrap in single quotes, escaping embedded single quotes as '\''
shquote() {
  local s="${1//\'/\'\\\'\'}"
  printf "'%s'" "$s"
}

yaml_section_pairs() {
  local section="$1"
  local file="$2"
  [ -f "$file" ] || return 0
  awk -v section="$section" '
    /^[^ #]/ { current = $0; sub(/:.*/, "", current) }
    current == section && /^  [^ #]/ {
      line = $0
      sub(/^ +/, "", line)
      idx = index(line, ": ")
      if (idx > 0) {
        key = substr(line, 1, idx - 1)
        val = substr(line, idx + 2)
        sub(/ (#.*)$/, "", val)
        gsub(/^["'\''"]|["'\''"]$/, "", key)
        gsub(/^["'\''"]|["'\''"]$/, "", val)
        printf "%s\t%s\n", key, val
      }
    }
  ' "$file"
}

# Command lines of the pane's child processes (the one ps call per rename),
child_cmdlines() {
  local current_cmd="$1"
  local pane_pid="$2"
  [ -n "$pane_pid" ] || return 0
  ps -Ao ppid=,args= 2>/dev/null | awk -v ppid="$pane_pid" -v cmd="$current_cmd" '
    $1 == ppid {
      line = $0
      sub(/^ *[0-9]+ +/, "", line)
      base = line
      sub(/ .*/, "", base)
      sub(/.*\//, "", base)
      if (cmd == "" || base == cmd) print line
    }'
}

# First match against the cached regex arrays, in file order.
# match_cached_regex REGEX_NAMES "$text" reads REGEX_NAMES_PATTERNS/_VALUES.
match_cached_regex() {
  local prefix="$1"
  local text="$2"
  local -a patterns=() values=()
  eval "patterns=(\"\${${prefix}_PATTERNS[@]}\")"
  eval "values=(\"\${${prefix}_VALUES[@]}\")"
  local i
  for i in "${!patterns[@]}"; do
    if [[ $text =~ ${patterns[$i]} ]]; then
      printf '%s\n' "${values[$i]}"
      return 0
    fi
  done
}
