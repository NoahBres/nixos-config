{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:NoahBres/nix-darwin/defaults-add-nsmenuenableactionimages";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    googleworkspace-cli.url = "github:googleworkspace/cli";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      googleworkspace-cli,
      ...
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#rnn
      darwinConfigurations."rnn" = nix-darwin.lib.darwinSystem {
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
        ];
        specialArgs = { inherit inputs; };
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
