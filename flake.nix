{
  description = "tmux plugin to display Nerd Font icons for window names";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.tmuxPlugins.mkTmuxPlugin {
            pluginName = "tmux-nerd-font-window-name";
            version = "unstable-${self.shortRev or self.dirtyShortRev or "dev"}";
            src = self;
            rtpFilePath = "tmux-nerd-font-window-name.tmux";
          };
        }
      );

      overlays.default = final: prev: {
        tmuxPlugins = prev.tmuxPlugins // {
          tmux-nerd-font-window-name = self.packages.${final.system}.default;
        };
      };
    };
}
