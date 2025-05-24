{ pkgs, lib, ... }:
{
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = with pkgs; [
    gh # GitHub CLI

    just
    bun
    tree
    nodejs_24

    # p10k
    zsh-powerlevel10k
    meslo-lgs-nf

    # Nix LSP/formatter
    nil
    nixfmt-rfc-style

    # TODO:
    # comma?
  ];

  home.sessionPath = [ "/Users/noah/.bun/bin" ];

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent =
      let
        zshConfigEarlyInit = lib.mkOrder 500 ''
          # # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
          # # Initialization code that may require console input (password prompts, [y/n]
          # # confirmations, etc.) must go above this block; everything else may go below.
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        '';
        zshConfig = lib.mkOrder 1000 ''
                    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme  
          source ~/.p10k.zsh

        '';
      in
      lib.mkMerge [
        zshConfigEarlyInit
        zshConfig
      ];
  };

  home.file.".p10k.zsh".text = builtins.readFile ./zsh/.p10k.zsh;

  home.stateVersion = "25.05";
}
