{ pkgs, ... }:
{
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = with pkgs; [
    gh # GitHub CLI

    just
    bun
    tree

    # Nix LSP/formatter
    nil
    nixfmt-rfc-style

    # TODO:
    # comma?
  ];

  home.stateVersion = "25.05";
}
