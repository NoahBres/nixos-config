{ ... }:
{
  imports = [ ../common/darwin/configuration.nix ];

  home-manager.users.noah = import ./home.nix;

  determinateNix.customSettings = {
    extra-trusted-public-keys = [
      "rnn:WwyJul2LMpCUu2Pm33omQYvDpC5tCXLQL89Ow7GIdbY="
    ];
    require-sigs = false;
  };

}
