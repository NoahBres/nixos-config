{ ... }:
{
  imports = [ ../common/darwin/configuration.nix ];

  home-manager.users.noah = import ./home.nix;
}
