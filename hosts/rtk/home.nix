{ pkgs, config, ... }:
let
  araratatStart = pkgs.writeShellScript "ararat-start" ''
    ${pkgs.git}/bin/git pull --ff-only
    ${pkgs.tmux}/bin/tmux kill-session -t ararat 2>/dev/null || true
    ${pkgs.tmux}/bin/tmux new-session -d -s ararat -x 80 -y 24 ./claude-telegram.sh
    trap '${pkgs.tmux}/bin/tmux kill-session -t ararat 2>/dev/null; exit 0' TERM INT
    while ${pkgs.tmux}/bin/tmux has-session -t ararat 2>/dev/null; do
      sleep 5
    done
    exit 1
  '';
in
{
  imports = [ ../common/darwin/home.nix ];

  home.packages = with pkgs; [
    ffmpeg
  ];

  home.shellAliases = {
    "attach-ararat" = "tmux attach-session -t ararat";
    "restart-ararat" = "launchctl kickstart -k gui/$UID/com.noahbres.ararat";
    "kill-ararat" = "launchctl kill SIGTERM gui/$UID/com.noahbres.ararat";
  };

  launchd.agents.things-today-tracker = {
    enable = true;
    config = {
      Label = "com.noahbres.things-today-tracker";
      ProgramArguments = [
        "/usr/bin/python3"
        "${config.home.homeDirectory}/Developer/ararat/tools/things-today-tracker.py"
      ];
      WorkingDirectory = "${config.home.homeDirectory}/Developer/ararat";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/etc/profiles/per-user/noah/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
      };
      StartCalendarInterval = [{ Hour = 9; Minute = 7; }];
      StandardOutPath = "/tmp/things-today-tracker.log";
      StandardErrorPath = "/tmp/things-today-tracker-error.log";
    };
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
