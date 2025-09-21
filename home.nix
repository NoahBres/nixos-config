{ pkgs, lib, ... }:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zoxide.enable = true;

    zsh = {
      enable = true;

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initContent =
        let
          zshConfigEarlyInit = lib.mkOrder 500 ''
            # From FAQ: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#how-do-i-initialize-direnv-when-using-instant-prompt
            (( ''${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"

             if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
               source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
             fi

             (( ''${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"
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
  };

  home = {
    packages = with pkgs; [
      gh # GitHub CLI

      just
      bun
      tree
      nodejs_24

      # p10k
      zsh-powerlevel10k
      meslo-lgs-nf

      # Nix LSP/formatter
      nixd
      nil
      nixfmt-rfc-style

      # TODO:
      # comma?

      uv
    ];

    sessionPath = [ "/Users/noah/.bun/bin" ];

    shellAliases = {
      "cy" = "claude --dangerously-skip-permissions";
    };

    file.".p10k.zsh".text = builtins.readFile ./zsh/.p10k.zsh;

    stateVersion = "25.05";
  };
}
