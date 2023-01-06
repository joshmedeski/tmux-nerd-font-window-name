⚠️ This does not work yet! See https://github.com/tmux-plugins/tpm/issues/240

![thumbnail](https://github.com/joshmedeski/tmux-nerd-font-window-name/blob/main/tmux-nerd-font-window-name-screenshot.jpg?raw=true)

# tmux nerd font window name plugin

Automatically rename your tmux windows to Nerd Font Icons.

## Prerequisites

- [tmux](https://github.com/tmux/tmux)
- [tpm](https://github.com/tmux-plugins/tpm)
- [Nerd Font](https://www.nerdfonts.com/)

## How to install

### 1. Install tpm plugin

This script can be installed with the [Tmux Plugin Manager (tpm)](https://github.com/tmux-plugins/tpm).

Add the following line to your `~/.tmux.conf` file:

```conf
set -g @plugin 'joshmedeski/tmux-nerd-font-window-name'
```

## How it works

When installed, your window names will automatically update to a Nerd Font that matches the activity (ex: vim, bash, node, ect...).

## Tasks

- [x] Create tpm plugin
