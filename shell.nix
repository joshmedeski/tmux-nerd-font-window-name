{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs;[
    tmux
    yq-go
    nodePackages.bash-language-server
  ];
}
