{ inputs, ... }:
{
  environment.systemPackages = [ ];

  users.users.noah = {
    name = "noah";
    home = "/Users/noah";
  };

  environment.etc."nix/nix.custom.conf".text = ''
    lazy-trees = true
  '';

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.noah = import ./home.nix;

    backupFileExtension = "hm-backup";
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Turn off nix management as "Determinate uses its own daemon to manage
  # the Nix installation that conflicts with nix-darwin’s native Nix management."
  nix.enable = false;
  # nix.settings.experimental-features = "nix-command flakes";
}
