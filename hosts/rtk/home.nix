{ pkgs, config, ... }:
let
  araratatStart = pkgs.writeShellScript "ararat-start" ''
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export LC_CTYPE=en_US.UTF-8
    ${pkgs.git}/bin/git pull --ff-only
    ${pkgs.tmux}/bin/tmux kill-session -t ararat 2>/dev/null || true
    ${pkgs.tmux}/bin/tmux new-session -d -s ararat \
      -e LANG=en_US.UTF-8 -e LC_ALL=en_US.UTF-8 -e LC_CTYPE=en_US.UTF-8 \
      ./claude-telegram.sh
    while ${pkgs.tmux}/bin/tmux has-session -t ararat 2>/dev/null; do
      sleep 5
    done
    exit 1
  '';
in
{
  imports = [ ../common/darwin/home.nix ];

  home.shellAliases = {
    "attach-ararat" = "tmux attach-session -t ararat";
  };

  launchd.agents.ararat = {
    enable = true;
    config = {
      Label = "com.noahbres.ararat";
      ProgramArguments = [ "${araratatStart}" ];
      WorkingDirectory = "${config.home.homeDirectory}/Developer/ararat";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/etc/profiles/per-user/noah/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin";
        TERM = "xterm-256color";
        COLORTERM = "truecolor";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        LC_CTYPE = "en_US.UTF-8";
      };
      KeepAlive = {
        SuccessfulExit = false;
      };
      ThrottleInterval = 5;
      RunAtLoad = true;
      StandardOutPath = "/tmp/ararat.log";
      StandardErrorPath = "/tmp/ararat-error.log";
    };
  };
}
