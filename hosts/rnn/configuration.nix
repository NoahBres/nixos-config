{ inputs, ... }:
{
  environment.systemPackages = [ ];

  users.users.noah = {
    name = "noah";
    home = "/Users/noah";
  };

  determinateNix = {
    enable = true;
    determinateNixd.builder.state = "enabled";
    customSettings = {
      lazy-trees = true;
      eval-cores = 0;
      trusted-users = [
        "root"
        "noah"
      ];
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    # taps = [ "dan-hart/tap" ];
    # brews = [ "dan-hart/tap/clings" ];
    casks = [
      "zed"
      "jordanbaird-ice"

      "voiceink"
      "codex"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.noah = import ./home.nix;

    backupFileExtension = "hm-backup";
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.NSGlobalDomain.NSMenuEnableActionImages = false;

  system.primaryUser = "noah";
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
}
