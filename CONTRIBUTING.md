# Contributing

Thanks for your interest in contributing to tmux-nerd-font-window-name! Pull requests are welcome for new icon presets, bug fixes, and improvements.

## Getting Started

1. Fork and clone the repository
2. Install the test framework: `curl -sL https://bashunit.com/install.sh | bash`
3. Run tests to verify your setup: `make test`

## Adding a New Icon

1. Find the Nerd Font icon you want to use at [nerdfonts.com/cheat-sheet](https://www.nerdfonts.com/cheat-sheet)
2. Add your entry to `bin/defaults.yml` under the `icons:` section in alphabetical order
3. Run `make test` to make sure nothing is broken

## Project Structure

- `tmux-nerd-font-window-name.tmux` - Entry point loaded by tpm: generates the config cache and sets `automatic-rename-format`
- `bin/tmux-nerd-font-window-name` - Main script that resolves icons on each rename
- `bin/cache-config` - Generates a sourceable config cache at plugin load (`generate_cache`/`load_cache`), so no YAML is parsed at rename time
- `bin/lib.sh` - Shared helpers: YAML parsing, `shquote`, child-process listing, cached regex matching
- `bin/generate-tmux-format` - Builds the static (native tmux format) variant used when the config has no regex sections
- `bin/defaults.yml` - Default icon mappings and config
- `test/` - Test suite using [bashunit](https://bashunit.com)
- `test/fixtures/` - YAML fixtures for testing config combinations

## Running Tests

```sh
make test
```

Or run directly:

```sh
./lib/bashunit test/
```

Tests use bashunit and work by sourcing the main script and calling `main()` directly. Each test sets `TMUX_NERD_FONT_USER_CONFIG` to a fixture YAML to control config without touching real user files.

When adding new behavior, add a corresponding test with a fixture YAML in `test/fixtures/`. Things to know when writing tests:

- A test file that sources `bin/cache-config` (directly or via the main script) must `export XDG_CACHE_HOME="$(mktemp -d)"` **before** the `source` line, so tests never touch the real user cache.
- bashunit runs each test in a subshell: use `$BASHPID` (not `$$`) for the current test process, and capture it into a variable before any `$(...)` — inside a command substitution `BASHPID` refers to the substitution's own subshell.
- Regex tests need a child process to match against; spawn a disguised sleeper: `bash -c 'exec -a "npm run dev" sleep 5' &` (see `spawn_fake_child` in the test files).
- Note that `make test` runs with coverage instrumentation and is much slower than `./lib/bashunit test/`; coverage percentages for sourced files are unreliable, so treat them as a checklist of instrumented files.

## Guidelines

- **No breaking changes.** Existing behavior should stay the same. New features should be opt-in via configuration so current users aren't affected.
- **Discuss big changes first.** Before starting a large refactor or new feature, open a [discussion](https://github.com/joshmedeski/tmux-nerd-font-window-name/discussions) or [issue](https://github.com/joshmedeski/tmux-nerd-font-window-name/issues) to get clarity from the maintainer (@joshmedeski).
- Keep it simple -- this is a pure Bash project with no compiled dependencies
- The YAML parser (`get_yaml_value`) handles flat YAML only, no nested structures
- Regex patterns in config (`names-regex`/`icons-regex`) are POSIX ERE (bash `=~`): use `[0-9]`/`[[:space:]]`
- Test your changes against the existing test suite before submitting
- Use descriptive commit messages
