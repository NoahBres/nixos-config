{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:NoahBres/nix-darwin/defaults-add-nsmenuenableactionimages";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    googleworkspace-cli.url = "github:googleworkspace/cli";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      googleworkspace-cli,
      disko,
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

      # Deploy to Hetzner server using:
      # $ nixos-rebuild switch --flake .#hetzner --target-host root@hetzner --use-remote-sudo
      nixosConfigurations."hetzner" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./hosts/hetzner/configuration.nix
          ./hosts/hetzner/disk-config.nix
        ];
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
    };
}
