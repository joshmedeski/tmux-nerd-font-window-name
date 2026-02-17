{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs;[
    tmux
    yq-go
    nodePackages.bash-language-server
    # bashunit: install via 'curl -s https://bashunit.typeddevs.com/install.sh | bash'
  ];
}
