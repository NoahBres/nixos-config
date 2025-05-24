{ pkgs, ... }:
{
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = with pkgs; [
    gh # GitHub CLI

    just

    # Nix LSP/formatter
    nil
    nixfmt-rfc-style
  ];

  home.stateVersion = "25.05";
}
