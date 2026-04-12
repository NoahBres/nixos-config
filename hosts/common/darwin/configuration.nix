{ inputs, ... }:
{
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
      secret-key-files = "/etc/nix/signing-key.sec";
    };
  };

  environment.systemPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    casks = [
      "claude"
      "ghostty"
      "google-chrome"
      "tailscale-app"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hm-backup";
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = "noah";
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
}
