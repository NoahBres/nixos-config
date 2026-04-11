{
  pkgs,
  inputs,
  ...
}:
{
  imports = [ ../common/darwin/home.nix ];

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
        cy-auto = mkOpenRouterWrapper "cy-auto" "openrouter/auto" "openrouter/auto";
        cy-glm = mkOpenRouterWrapper "cy-glm" "z-ai/glm-5" "z-ai/glm-5-turbo";
        cy-qwen = mkOpenRouterWrapper "cy-qwen" "qwen/qwen3.6-plus:free" "qwen/qwen3.6-plus:free";
        cy-kimi = mkOpenRouterWrapper "cy-kimi" "moonshotai/kimi-k2.5" "moonshotai/kimi-k2.5";
        cy-ant = pkgs.writeShellScriptBin "cy-ant" ''
          OPENROUTER_API_KEY=$(${pkgs._1password-cli}/bin/op read "op://Private/OpenRouter Key - Claude/password")
          export OPENROUTER_API_KEY
          export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
          export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
          export ANTHROPIC_API_KEY=""
          export ANTHROPIC_DEFAULT_OPUS_MODEL="anthropic/claude-opus-4.6"
          export ANTHROPIC_DEFAULT_SONNET_MODEL="anthropic/claude-sonnet-4.6"
          export ANTHROPIC_DEFAULT_HAIKU_MODEL="anthropic/claude-haiku-4.5"
          export CLAUDE_CODE_SUBAGENT_MODEL="anthropic/claude-sonnet-4.6"
          exec ${pkgs.llm-agents.claude-code}/bin/claude --dangerously-skip-permissions "$@"
        '';

      in
      [
        cy-auto
        cy-glm
        cy-qwen
        cy-kimi
        cy-ant
        inputs.googleworkspace-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
        llm-agents.claude-code
        llm-agents.opencode

        google-cloud-sdk

        bun
        nodejs_24

        delta

        uv
        cargo
        rustc
        rust-analyzer
      ];

    sessionPath = [ "/Users/noah/.bun/bin" ];
  };
}
