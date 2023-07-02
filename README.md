<a href="https://www.joshmedeski.com/posts/tmux-nerd-font-window-name-plugin/" target="_blank">

![thumbnail](https://github.com/joshmedeski/tmux-nerd-font-window-name/blob/main/tmux-nerd-font-window-name-thumb.jpeg?raw=true)

</a>

# tmux nerd font window name plugin

Automatically rename your tmux windows to Nerd Font Icons.

## Prerequisites

- [tmux](https://github.com/tmux/tmux)
- [tpm](https://github.com/tmux-plugins/tpm)
- [Nerd Font](https://www.nerdfonts.com/)

## How to install

### Install tpm plugin

This script can be installed with the [Tmux Plugin Manager (tpm)](https://github.com/tmux-plugins/tpm).

Add the following line to your `~/.tmux.conf` file:

```conf
set -g @plugin 'joshmedeski/tmux-nerd-font-window-name'
```

### Options

Add the following options to your `tmux.conf` before you set the plugin.

```sh
# shows the window name next to the icon (default false)
set -g @tmux-nerd-font-window-name-show-name true
```

### Minimalist format

If you want a minimalist format and only show the nerd font icon. You can update your window status to just `#W` (window name) in your tmux config.

```conf
set -g window-status-current-format '#[fg=magenta]#W'
set -g window-status-format         '#[fg=gray]#W'
```

### Customize icons

To specify a custom icon for your editor, music player, shell, and for unknown programs, use the following option to set any icon you prefer:

```sh
set -g @tmux-nerd-font-window-name-shell-icon "" # Shell
set -g @tmux-nerd-font-window-name-music-icon "󰝚" # Music
set -g @tmux-nerd-font-window-name-editor-icon "󰨞" # Editor
set -g @tmux-nerd-font-window-name-editor-enable-all true # Apply to all editors (above setting only applies to editors that are not Vim or Emacs)
set -g @tmux-nerd-font-window-name-git-icon "" # Git
set -g @tmux-nerd-font-window-name-fallback-icon "󰒓" # Unknown programs
```
## How it works

When installed, your window names will automatically update to a Nerd Font that matches the activity (ex: vim, bash, node, ect...).

## Tasks

- [x] Create tpm plugin

## Contributing

I encourage contributors! I want to make this plugin the best it can be. Feel free to fork it and submit pull requests with any new ideas or improvements you have.
