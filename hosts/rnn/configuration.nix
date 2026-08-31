{ ... }:
{
  imports = [ ../common/darwin/configuration.nix ];

  # Upstream nix-darwin has no declared option for this key; our fork used to
  # add one, but we dropped the fork, so set it via CustomUserPreferences instead.
  system.defaults.CustomUserPreferences.NSGlobalDomain.NSMenuEnableActionImages = false;

  determinateNix.customSettings.secret-key-files = "/etc/nix/signing-key.sec";

  homebrew.casks = [
    "zed"
    "voiceink"
    "codex"
  ];

  home-manager.users.noah = import ./home.nix;
}
