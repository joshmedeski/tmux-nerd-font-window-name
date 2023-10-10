# tmux nerd font window name plugin

Automatically add Nerd Font support to your tmux window names!

![tmux-nerd-font-window-name screenshot](./tmux-nerd-font-window-name-screenshot.png)

## Requirements

- [tmux](https://github.com/tmux/tmux)
- [tpm](https://github.com/tmux-plugins/tpm)
- [yq](https://github.com/mikefarah/yq)

## Installation

### Install tpm plugin

This plugin can be installed with the [Tmux Plugin Manager (tpm)](https://github.com/tmux-plugins/tpm).

Add the following line to your tmux configuration file:

```sh
set -g @plugin 'joshmedeski/tmux-nerd-font-window-name'
```

## Configuration

You can configure this plugin by creating a `~/.config/tmux/tmux-nerd-font-window-name.yml` file. The following options can be changed:

```yml
config:
  fallback-icon: "?" # icon to use if no definition is found
  multi-pane-icon: "" # icon to use for window with multiple panes, if not specified, only active pane's icon will used as the default.
  show-name: true # show the window name with the icon
  downcase-name: false # downcase the window name before icon lookup

icons:
  zsh: "" # overwrite with your own symbol (Nerd Font icon, emoji, whatever!)
  cmatrix: "🤯" # add new entries that aren't included
```

## Contributions

Contributions are welcome! Feel free to make a pull request to submit more preset icon settings or improve the codebase!
