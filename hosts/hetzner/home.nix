{ pkgs, config, ... }:
{
  home.username = "noah";
  home.homeDirectory = "/home/noah";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    git
    ripgrep
    fd
    jq
    ghostty.terminfo
    direnv
    nix-direnv
    claude-code
    bun
    tmux
    dtach
    gh
    expect
    glow
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      "cy" = "claude --dangerously-skip-permissions";
      "attach-ararat" = "dtach -a /tmp/ararat.sock";
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Noah Bresler";
      email = "noahbres@gmail.com";
    };
  };

  programs.home-manager.enable = true;

  systemd.user.services.ararat = {
    Unit = {
      Description = "Ararat Telegram Bot (tmux session)";
      After = [ "network.target" ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardInput = "null";
      StandardOutput = "journal";
      StandardError = "journal";
      ExecStartPre = "/bin/sh -c '${pkgs.git}/bin/git -C ${config.home.homeDirectory}/Developer/ararat pull || true'";
      ExecStart = "${pkgs.tmux}/bin/tmux new-session -d -s ararat ${config.home.homeDirectory}/Developer/ararat/claude-telegram.sh";
      ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t ararat";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
