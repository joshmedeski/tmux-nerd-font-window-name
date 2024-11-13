#!/usr/bin/env bash

# Check if yq command is available
if ! command -v yq >/dev/null 2>&1; then
  echo "$1 ⚠︎ yq missing"
  exit 1
fi

# Define variables with arguments and config paths
NAME="$1"
PANES="$2"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_CONFIG="$CURRENT_DIR/defaults.yml"
USER_CONFIG="$HOME/.config/tmux/tmux-nerd-font-window-name.yml"

# Function to retrieve a configuration value
get_config_value() {
  local key="$1"
  local value=""
  if [ -f "$USER_CONFIG" ]; then
    value="$(yq -r "$key" "$USER_CONFIG")"
    if [ "$value" == "null" ]; then
      # Fallback to default config if key is not found in user config
      value="$(yq -r "$key" "$DEFAULT_CONFIG")"
    fi
  else
    value="$(yq -r "$key" "$DEFAULT_CONFIG")"
  fi
  echo "$value"
}

# Retrieve the icon based on the NAME argument
ICON="$(get_config_value ".icons[\"$NAME\"]")"

# Fallback icon if no specific icon is found
if [ "$ICON" == "null" ] || [ -z "$ICON" ]; then
  ICON="$(get_config_value '.config["fallback-icon"]')"
fi

# If multiple panes are open, add a multi-pane icon if available
if [ "$PANES" -gt 1 ]; then
  MULTI_PANE_ICON="$(get_config_value '.config["multi-pane-icon"]')"
  if [ "$MULTI_PANE_ICON" != "null" ] && [ -n "$MULTI_PANE_ICON" ]; then
    ICON="$MULTI_PANE_ICON $ICON"
  fi
fi

# Check if the window name should be displayed and set icon position
SHOW_NAME="$(get_config_value '.config["show-name"]')"
if [ "$SHOW_NAME" = "true" ]; then
  ICON_POSITION="$(get_config_value '.config["icon-position"]')"
  if [ "$ICON_POSITION" == "right" ]; then
    ICON="$NAME $ICON"
  else
    ICON="$ICON $NAME"
  fi
fi

# Output the final icon
echo "$ICON"
