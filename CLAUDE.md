# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

tmux-nerd-font-window-name is a tmux plugin (installed via tpm) that automatically replaces tmux window names with Nerd Font icons based on the running command. It's a pure Bash project with no compiled dependencies.

## Commands

- **Run tests:** `make test`
- **Run tests directly:** `./lib/bashunit test/`
- **Run tests with coverage:** `./lib/bashunit test/ --coverage --coverage-paths bin/tmux-nerd-font-window-name --coverage-report coverage/lcov.info`
- **Install bashunit (test framework):** `curl -s https://bashunit.typeddevs.com/install.sh | bash` (installs to `lib/bashunit`)

## Architecture

The plugin has two main components:

1. **`tmux-nerd-font-window-name.tmux`** - Entry point loaded by tpm. Sets `automatic-rename-format` to call the main script. Supports a `#{window_icon}` placeholder for custom formats.

2. **`bin/tmux-nerd-font-window-name`** - Main script. Takes `pane_current_command` and `window_panes` as arguments, looks up the icon, and outputs the formatted string.

### Config Resolution

The script uses a custom `get_yaml_value()` awk-based parser for flat YAML (no `yq` dependency). Config lookup follows a two-level cascade:

- **User config** (`~/.config/tmux/tmux-nerd-font-window-name.yml`, overridable via `TMUX_NERD_FONT_USER_CONFIG` env var) is checked first
- **Default config** (`bin/defaults.yml`) is the fallback

`get_config_value(section, key, user_config)` checks user config, then defaults.

### Output Logic in `main()`

The `main()` function applies configuration in this order:
1. Look up icon by command name
2. If not found, use `fallback-icon` (and set `is_fallback=true`)
3. If multi-pane (panes > 1), prepend `multi-pane-icon`
4. If `show-name: true`, append/prepend the command name based on `icon-position`
5. If fallback and `always-show-fallback-name: true`, show name alongside fallback icon

## Testing

Tests use [bashunit](https://bashunit.typeddevs.com/). The test file sources the main script to call `main()` directly. Each test sets `TMUX_NERD_FONT_USER_CONFIG` to a fixture YAML in `test/fixtures/` to control config without touching real user files.

Test fixtures are minimal YAML files that each test a specific config combination (show-name, icon-position, fallback-name, multi-pane, override).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contributor guidelines including how to add icons, run tests, and submit PRs.
