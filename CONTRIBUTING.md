# Contributing

Thanks for your interest in contributing to tmux-nerd-font-window-name! Pull requests are welcome for new icon presets, bug fixes, and improvements.

## Getting Started

1. Fork and clone the repository
2. Install the test framework: `curl -s https://bashunit.typeddevs.com/install.sh | bash`
3. Run tests to verify your setup: `make test`

## Adding a New Icon

1. Find the Nerd Font icon you want to use at [nerdfonts.com/cheat-sheet](https://www.nerdfonts.com/cheat-sheet)
2. Add your entry to `bin/defaults.yml` under the `icons:` section in alphabetical order
3. Run `make test` to make sure nothing is broken

## Project Structure

- `tmux-nerd-font-window-name.tmux` - Entry point loaded by tpm
- `bin/tmux-nerd-font-window-name` - Main script that resolves icons
- `bin/defaults.yml` - Default icon mappings and config
- `test/` - Test suite using [bashunit](https://bashunit.typeddevs.com/)
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

When adding new behavior, add a corresponding test with a fixture YAML in `test/fixtures/`.

## Guidelines

- **No breaking changes.** Existing behavior should stay the same. New features should be opt-in via configuration so current users aren't affected.
- **Discuss big changes first.** Before starting a large refactor or new feature, open a [discussion](https://github.com/joshmedeski/tmux-nerd-font-window-name/discussions) or [issue](https://github.com/joshmedeski/tmux-nerd-font-window-name/issues) to get clarity from the maintainer (@joshmedeski).
- Keep it simple -- this is a pure Bash project with no compiled dependencies
- The YAML parser (`get_yaml_value`) handles flat YAML only, no nested structures
- Test your changes against the existing test suite before submitting
- Use descriptive commit messages
