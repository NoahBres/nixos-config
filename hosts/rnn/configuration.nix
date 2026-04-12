{ ... }:
{
  imports = [ ../common/darwin/configuration.nix ];

  system.defaults.NSGlobalDomain.NSMenuEnableActionImages = false;

  determinateNix.customSettings.secret-key-files = "/etc/nix/signing-key.sec";

  homebrew.casks = [
    "zed"
    "jordanbaird-ice"
    "voiceink"
    "codex"
  ];

  home-manager.users.noah = import ./home.nix;
}
