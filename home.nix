{
  pkgs,
  lib,
  inputs,
  ...
}:
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
    packages =
      with pkgs;
      let
        mkOpenRouterWrapper =
          name: model: turboModel:
          pkgs.writeShellScriptBin name ''
            OPENROUTER_API_KEY=$(${pkgs._1password-cli}/bin/op read "op://Private/OpenRouter Key - Claude/password")
            export OPENROUTER_API_KEY
            export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
            export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
            export ANTHROPIC_API_KEY=""
            export ANTHROPIC_DEFAULT_OPUS_MODEL="${model}"
            export ANTHROPIC_DEFAULT_SONNET_MODEL="${model}"
            export ANTHROPIC_DEFAULT_HAIKU_MODEL="${turboModel}"
            export CLAUDE_CODE_SUBAGENT_MODEL="${model}"
            exec ${pkgs.llm-agents.claude-code}/bin/claude --dangerously-skip-permissions "$@"
          '';
        cy-glm = mkOpenRouterWrapper "cy-glm" "z-ai/glm-5" "z-ai/glm-5-turbo";
        cy-qwen = mkOpenRouterWrapper "cy-qwen" "qwen/qwen3.6-plus:free" "qwen/qwen3.6-plus:free";
        cy-kimi = mkOpenRouterWrapper "cy-kimi" "moonshotai/kimi-k2.5" "moonshotai/kimi-k2.5";

      in
      [
        cy-glm
        cy-qwen
        cy-kimi
        inputs.googleworkspace-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
        llm-agents.claude-code
        llm-agents.opencode

        _1password-cli # 1Password CLI (op)
        gh # GitHub CLI
        google-cloud-sdk

        just
        bun
        tree
        nodejs_24

        # p10k
        zsh-powerlevel10k
        meslo-lgs-nf

        # Nix LSP/formatter
        nixd
        nixfmt

        # TODO:
        # comma?

        delta

        uv
        cargo
        rustc
        rust-analyzer
      ];

    sessionPath = [ "/Users/noah/.bun/bin" ];

    shellAliases = {
      "cy" = "claude --dangerously-skip-permissions";
    };

    file.".p10k.zsh".text = builtins.readFile ./modules/zsh/.p10k.zsh;

    stateVersion = "25.05";
  };
}
