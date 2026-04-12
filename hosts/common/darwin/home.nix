{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  mkOpenRouterWrapper =
    name: opusModel: sonnetModel: haikuModel:
    pkgs.writeShellScriptBin name ''
      OPENROUTER_API_KEY=$(${pkgs._1password-cli}/bin/op read "op://Private/OpenRouter Key - Claude/password")
      export OPENROUTER_API_KEY
      export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
      export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
      export ANTHROPIC_API_KEY=""
      export ANTHROPIC_DEFAULT_OPUS_MODEL="${opusModel}"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="${sonnetModel}"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="${haikuModel}"
      export CLAUDE_CODE_SUBAGENT_MODEL="${sonnetModel}"
      exec ${pkgs.llm-agents.claude-code}/bin/claude --dangerously-skip-permissions "$@"
    '';

  cy-auto = mkOpenRouterWrapper "cy-auto" "openrouter/auto" "openrouter/auto" "openrouter/auto";
  cy-glm = mkOpenRouterWrapper "cy-glm" "z-ai/glm-5" "z-ai/glm-5" "z-ai/glm-5-turbo";
  cy-qwen =
    mkOpenRouterWrapper "cy-qwen" "qwen/qwen3.6-plus:free" "qwen/qwen3.6-plus:free"
      "qwen/qwen3.6-plus:free";
  cy-kimi =
    mkOpenRouterWrapper "cy-kimi" "moonshotai/kimi-k2.5" "moonshotai/kimi-k2.5"
      "moonshotai/kimi-k2.5";
  cy-ant =
    mkOpenRouterWrapper "cy-ant" "anthropic/claude-opus-4.6" "anthropic/claude-sonnet-4.6"
      "anthropic/claude-haiku-4.5";
in
{
  programs = {
    tmux = {
      enable = true;
      mouse = true;
      terminal = "tmux-256color";
      extraConfig = ''
        set -gq utf8 on
        set -gq status-utf8 on
        set -ga terminal-overrides ",*:Tc"
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zoxide.enable = true;

    atuin.enable = true;

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
      _1password-cli # 1Password CLI (op)
      gh # GitHub CLI

      just
      tree

      # p10k
      zsh-powerlevel10k
      meslo-lgs-nf

      # Nix LSP/formatter
      nixd
      nixfmt

      llm-agents.claude-code
      llm-agents.opencode

      # Google CLI
      google-cloud-sdk
      inputs.googleworkspace-cli.packages.${pkgs.stdenv.hostPlatform.system}.default

      bun
      nodejs_24

      delta
      glow

      uv
      cargo
      rustc
      rust-analyzer

      cy-auto
      cy-glm
      cy-qwen
      cy-kimi
      cy-ant
    ];

    sessionPath = [ "/Users/noah/.bun/bin" ];

    shellAliases = {
      "cy" = "claude --dangerously-skip-permissions";
    };

    file.".p10k.zsh".text = builtins.readFile ../../../modules/zsh/.p10k.zsh;

    activation.bootstrapRepos = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for repo in dot-claude nixos-config ararat; do
        if [ ! -d "$HOME/Developer/$repo" ]; then
          ${pkgs.git}/bin/git clone https://github.com/noahbres/$repo "$HOME/Developer/$repo"
        fi
      done
    '';

    stateVersion = "25.05";
  };
}
