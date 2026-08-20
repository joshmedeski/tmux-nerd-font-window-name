# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

tmux-nerd-font-window-name is a tmux plugin (installed via tpm) that automatically replaces tmux window names with Nerd Font icons based on the running command. It's a pure Bash project with no compiled dependencies.

## Commands

- **Run tests:** `make test`
- **Run tests directly:** `./lib/bashunit test/`
- **Run tests with coverage:** `./lib/bashunit test/ --coverage --coverage-paths bin/tmux-nerd-font-window-name,bin/generate-tmux-format,bin/lib.sh,bin/cache-config --coverage-report coverage/lcov.info`
- **Install bashunit (test framework):** `curl -sL https://bashunit.com/install.sh | bash` (installs to `lib/bashunit`)

## Architecture

The plugin has four components:

1. **`tmux-nerd-font-window-name.tmux`** - Entry point loaded by tpm. Generates the config cache, then sets `automatic-rename-format` to a `#()` call to the main script, wrapped in a conditional that falls back to `#{pane_current_command}` while the job's output is unavailable — tmux runs `#()` jobs asynchronously, expanding to nothing until output arrives and to `<'<command>' not ready>` after one second, so without the fallback the window name flashes blank or shows tmux's placeholder text. Supports a `#{window_icon}` placeholder for custom formats (the original template is saved to the `@tmux-nerd-font-window-name-template` tmux option).

2. **`bin/tmux-nerd-font-window-name`** - Main script, run by tmux on every rename. Takes `pane_current_command`, `window_panes`, `pane_pid`, `window_id` as arguments, resolves the icon/name, and outputs the formatted string.

3. **`bin/cache-config`** - Cache generator (sourced, not executed). `generate_cache(user_config)` parses both YAML files once and writes a sourceable cache file to `$XDG_CACHE_HOME/tmux-nerd-font-window-name/config.sh`: `CFG_*` option variables, an `icon_for()` case function, ordered `REGEX_{NAMES,ICONS}_{PATTERNS,VALUES}` arrays, and `CACHE_SOURCE_CONFIG` (the config path it was built from). `load_cache` resets previously loaded state, then sources the cache.

4. **`bin/lib.sh`** - Shared helpers: awk YAML parsing (`get_yaml_value`, `yaml_section_pairs`, `merged_section_pairs`), `shquote` (single-quote escaping for generated code), `child_cmdlines` (one `ps` call listing pane child command lines, gated by argv[0] basename == pane command), `match_cached_regex` (first-match-wins loop over the cached regex arrays using bash `=~`, POSIX ERE).

### Config Resolution

**User config** (`~/.config/tmux/tmux-nerd-font-window-name.yml`, overridable via `TMUX_NERD_FONT_USER_CONFIG` env var) is checked first
**Default config** (`bin/defaults.yml`) is the fallback

Flat YAML parsed with awk (no `yq` dependency). Two-level cascade resolved **at cache generation time**: user config (`~/.config/tmux/tmux-nerd-font-window-name.yml`, overridable via the `@tmux-nerd-font-window-name-config-file` tmux option or `TMUX_NERD_FONT_USER_CONFIG` env var) overrides `bin/defaults.yml`. At rename time there is no YAML parsing — `main()` sources the cache and regenerates it only when it's missing or `CACHE_SOURCE_CONFIG` doesn't match the current config path (this mismatch check is what makes test fixtures work).

### Output Logic in `main()`

1. Load the cache (regenerate if stale/missing)
2. If regex rules exist, get child command lines (`child_cmdlines`) and match `names-regex` (renames) and `icons-regex` (sets icon) against them — both against the *original* pane command
3. Icon resolution precedence: regex icon → exact `icon_for(name)` lookup
4. If not found, use sem-version icon (for `1.2.3`-style names) or `fallback-icon` (sets `is_fallback=true`)
5. If multi-pane (panes > 1), prepend `multi-pane-icon`
6. If `show-name: true` (or fallback + `always-show-fallback-name: true`), append/prepend the name per `icon-position`
7. Stale-name self-heal: tmux displays `#()` output one rename cycle late, so if the displayed window name doesn't contain the computed result, the script renames the window directly (resolving the user's `#{window_icon}` template if set) and re-enables `automatic-rename`

## Testing

Tests use [bashunit](https://bashunit.com). Test files: `tmux_nerd_font_window_name_test.sh` (end-to-end through `main()`, including regex scenarios), `lib_test.sh` (lib.sh helpers), `cache_config_test.sh` (cache generation/loading), `generate_tmux_format_test.sh` (static format), `entry_point_test.sh` (the `automatic-rename-format` the `.tmux` file installs, via a fake `tmux` on `PATH`).

Conventions and traps:

- Each test sets `TMUX_NERD_FONT_USER_CONFIG` to a fixture YAML in `test/fixtures/`; the cache mismatch-regen makes this work without extra setup.
- Any test file that sources `cache-config` (directly or via the main script) must `export XDG_CACHE_HOME="$(mktemp -d)"` **before** the `source` line, or tests write to the real user cache.
- bashunit runs each test in a subshell: use `$BASHPID`, not `$$`, for the current test process — and capture it into a variable *before* any `$(...)` (inside a command substitution `BASHPID` is the substitution's own subshell).
- `entry_point_test.sh` runs the entry point in a subshell with a stub `tmux` that records its arguments; it asserts on format structure, so it needs updating whenever the format's shape changes.
- Regex tests spawn a real fake child process: `bash -c 'exec -a "npm run dev" sleep 5' &`.
- Coverage numbers from bashunit are unreliable for sourced files — treat the coverage table as a file checklist, not a metric. `make test` (with coverage) is ~10x slower than `./lib/bashunit test/`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contributor guidelines including how to add icons, run tests, and submit PRs.
