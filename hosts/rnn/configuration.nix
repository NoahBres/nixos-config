{ ... }:
{
  imports = [ ../common/darwin/configuration.nix ];

  system.defaults.NSGlobalDomain.NSMenuEnableActionImages = false;

  homebrew.casks = [
    "zed"
    "jordanbaird-ice"
    "voiceink"
    "codex"
  ];

  home-manager.users.noah = import ./home.nix;
}
