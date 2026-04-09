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
      Description = "Ararat Telegram Bot";
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      WorkingDirectory = "${config.home.homeDirectory}/Developer/ararat";
      Environment = [
        "PATH=/etc/profiles/per-user/noah/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin"
        "TERM=xterm-ghostty"
        "COLORTERM=truecolor"
      ];
      ExecStartPre = "${pkgs.git}/bin/git pull --ff-only";
      ExecStart = "${pkgs.dtach}/bin/dtach -N /tmp/ararat.sock ./claude-telegram.sh";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
