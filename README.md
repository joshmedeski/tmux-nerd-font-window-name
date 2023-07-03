## Tmux Window Icons

![screenshot](./screenshot.png)

Automatically rename your tmux windows to your specificed icons.

## Requirements

- [tmux](https://github.com/tmux/tmux)
- [tpm](https://github.com/tmux-plugins/tpm)

## Installation

### Install tpm plugin

This plugin can be installed with the [Tmux Plugin Manager (tpm)](https://github.com/tmux-plugins/tpm).

Add the following line to your configuration file:

```sh
set -g @plugin 'joshmedeski/tmux-nerd-font-window-name'
```

## Configuration

### Show window name

Put the following line below to show the window name beside the icon. (This is not enabled by default)

```sh
set -g @tmux-nerd-font-window-name-show-name true
```

### Customize icons

The syntax of the setting of an icon is,

```sh
set -g @tmux-nerd-font-window-name-custom-<program> "<icon>"
```

`<program>` is the name of the program, and `<icon>` is the icon/text the program name is assigned to.

For example, lets use `lazygit`,

```sh
set -g @tmux-nerd-font-window-name-custom-lazygit "LZYGIT"
```

This makes the icon for every `lazygit` window `LZYGIT`

You can also set the fallback icon for programs that haven't been assigned to a icon,
```sh
set -g @tmux-nerd-font-window-name-fallback-icon "???"
```

### Recommended icon settings

To remove the duplication of effort, open the file `recommended-icons.conf` to get preset settings and copy the lines you need to your tmux configuration file.

## Contributions

Contributions are welcome! Feel free to make a pull request to submit more preset icon settings or improve the codebase!
