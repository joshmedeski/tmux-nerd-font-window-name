# tmux nerd font window name plugin

Automatically add Nerd Font support to your tmux window names!

![tmux-nerd-font-window-name screenshot](./tmux-nerd-font-window-name-screenshot.png)

## Requirements

The following dependencies are required in order to use this plugin:

- [tmux](https://github.com/tmux/tmux)
- [tpm](https://github.com/tmux-plugins/tpm)
- [yq](https://github.com/mikefarah/yq) (>=4)

## Installation (via tpm)

Add the following line to your tmux configuration file:

```sh
set -g @plugin 'joshmedeski/tmux-nerd-font-window-name'
```

Run `<prefix>+I` to trigger the tpm installer which will download and source the plugin.

## Configuration

You can configure this plugin by creating a `~/.config/tmux/tmux-nerd-font-window-name.yml`
file. The following options can be changed:

```yml
config:
  fallback-icon: "?" # show when no definition is found
  multi-pane-icon: "" # show when window has multiple panes (blank by default)
  show-name: true # show the window name with the icon (defaults to false)

icons:
  zsh: "" # overwrite with your own symbol (Nerd Font icon, emoji, whatever!)
  cmatrix: "🤯" # add new entries that aren't included
```

## Contributions

Contributions are welcome! Feel free to make a pull request to submit more
preset icon settings or improve the codebase!

## Intro Video

Here is the introduction blog post and video that I made for this plugin:

[![blog post](./tmux-nerd-font-window-name-thumb.jpeg)](https://www.joshmedeski.com/posts/tmux-nerd-font-window-name-plugin/)

## Additional tmux plugins

I've authored a few other tmux plugins that you might find useful:

- [t - the smart tmux session manager](https://github.com/joshmedeski/t-smart-tmux-session-manager)
- [tmux-fzf-url - Quickly open urls on your terminal screen!](https://github.com/joshmedeski/tmux-fzf-url)
